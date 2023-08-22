//
//  ListViewController.swift
//  Big Red Dining
//
//  Created by Cameron Goddard on 12/18/22.
//

import Cocoa

enum EateryStatus {
    case open
    case closed(until: String)
    case closedToday
    case closingSoon
    case openingSoon
    case error
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
    
    override func viewDidAppear() {
        //TODO: Handle reload after day change
        tableView.reloadData()
    }
    
    func changeLocation(location: Int) {
        currentEateries = allEateries.filter({
            $0.location == location
        })
        tableView.reloadData()
    }
    
    func getCurrentStatus(events: [Event]) -> EateryStatus {
        #if TESTING
        let time = 1686421800
        #else
        let time = Int(Date().timeIntervalSince1970)
        #endif
        
        let format = DateFormatter()
        format.dateFormat = "MM-dd-yyyy HH:mm"
        format.timeZone = .current
        
        if noEateryInfo {
            return .error
        }
        
        if events.isEmpty {
            return .closedToday
        }
        
        var i = 0
        for event in events {
            if time < event.endTimestamp {
                if time >= event.startTimestamp {
                    if abs(time - event.endTimestamp) < 30 * 60 {
                        // TODO: Clean this up
                        if i < events.count && event.endTimestamp == events[i+1].startTimestamp {
                            return .open
                        }
                        return .closingSoon
                    }
                    return .open
                }
                if abs(time - event.startTimestamp) < 30 * 60 {
                    return .openingSoon
                }
                let formatTime = DateFormatter()
                formatTime.dateFormat = "h:mma"
                formatTime.amSymbol = "am"
                formatTime.pmSymbol = "pm"
                formatTime.timeZone = .current
                
                return .closed(until: formatTime.string(from: Date(timeIntervalSince1970: TimeInterval(event.startTimestamp))).replacingOccurrences(of: ":00", with: ""))
            }
            i += 1
        }
        return .closed(until: "")
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
            eateryCell.statusIcon.image = NSImage(named: "NSStatusAvailable")!
            eateryCell.statusText.stringValue = "Open now"
        case .openingSoon:
            eateryCell.statusIcon.image = NSImage(named: "NSStatusPartiallyAvailable")!
            eateryCell.statusText.stringValue = "Opening soon"
        case .closingSoon:
            eateryCell.statusIcon.image = NSImage(named: "NSStatusPartiallyAvailable")!
            eateryCell.statusText.stringValue = "Closing soon"
        case let .closed(until: time):
            eateryCell.statusIcon.image = NSImage(named: "NSStatusUnavailable")!
            if time == "" {
                eateryCell.statusText.stringValue = "Closed"
            } else {
                eateryCell.statusText.stringValue = "Closed until " + time
            }
        case .error:
            eateryCell.statusIcon.image = NSImage(named: "NSStatusNone")!
            eateryCell.statusText.stringValue = "No info"
        default:
            eateryCell.statusIcon.image = NSImage(named: "NSStatusUnavailable")!
            eateryCell.statusText.stringValue = "Closed"
        }
        return eateryCell
    }
}

extension ListViewController: NSTableViewDelegate {

    func tableViewSelectionDidChange(_ notification: Notification) {
        let row = tableView.selectedRow
        tableView.deselectRow(row)
        if row != -1 {
            NotificationCenter.default.post(name: Notification.Name("ShowInfo"), object: currentEateries[row].name)
        }
    }
}
