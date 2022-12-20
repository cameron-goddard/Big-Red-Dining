//
//  ListViewController.swift
//  DiningBar
//
//  Created by Cameron Goddard on 12/18/22.
//

import Cocoa

enum Status {
    case open
    case closed
    case closingSoon
}

class ListViewController: NSViewController {
    
    @IBOutlet weak var tableView: NSTableView!
    
    var currentEateries : [EateryInfo] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = .clear
        
        currentEateries = allEateries.filter({
            $0.location == 0
        })
    }
    
    func changeLocation(location: Int) {
        currentEateries = allEateries.filter({
            $0.location == location
        })
        tableView.reloadData()
    }
    
    func getCurrentStatus(events: [Event]) -> Status {
        let time = Int(Date().timeIntervalSince1970)
        
        for event in events {
            if time >= event.startTimestamp && abs(time - event.endTimestamp) < 30 {
                return .closingSoon
            }
            else if time >= event.startTimestamp && time < event.endTimestamp {
                return .open
            }
        }
        return .closed
    }
}

extension ListViewController: NSTableViewDataSource {

    func numberOfRows(in tableView: NSTableView) -> Int {
        return currentEateries.count
    }

    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 40
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let eateryCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "eateryCell"), owner: self) as? EateryCell else { return nil }
        
        let eatery = currentEateries[row]

        eateryCell.name.stringValue = eatery.name
        eateryCell.icon.image = NSImage(systemSymbolName: eatery.icon, accessibilityDescription: nil)
        
        switch getCurrentStatus(events: eatery.events) {
        case .open:
            eateryCell.status.image! = NSImage(named: "NSStatusAvailable")!
            eateryCell.status.title = "Open now"
        case .closingSoon:
            eateryCell.status.image! = NSImage(named: "NSStatusPartiallyAvailable")!
            eateryCell.status.title = "Closing soon"
        default:
            eateryCell.status.image! = NSImage(named: "NSStatusUnavailable")!
            eateryCell.status.title = "Closed"
        }
        return eateryCell
    }

}

extension ListViewController: NSTableViewDelegate {

    func tableViewSelectionDidChange(_ notification: Notification) {
        let row = tableView.selectedRow
        tableView.deselectRow(row)
        if row != -1 {
            var shortName = ""
            if currentEateries[row].name.contains("House") {
                shortName = currentEateries[row].name.components(separatedBy: " ").first!
            } else {
                shortName = currentEateries[row].name
            }
            NotificationCenter.default.post(name: Notification.Name("ShowInfo"), object: shortName)
        }
    }
}
