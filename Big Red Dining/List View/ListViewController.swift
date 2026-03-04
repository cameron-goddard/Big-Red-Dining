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
    
    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mma"
        formatter.amSymbol = "am"
        formatter.pmSymbol = "pm"
        formatter.timeZone = .current
        return formatter
    }()
    
    var currentLocation = 0
    
    var currentDiningHalls: [EateryInfo] {
        allEateries.values.filter { $0.location == currentLocation && !$0.isCafe }
    }
    
    var currentCafes: [EateryInfo] {
        allEateries.values.filter { $0.location == currentLocation && $0.isCafe }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = .clear
        tableView.reloadData()
    }
    
    override func viewDidAppear() {
        tableView.reloadData()
    }
    
    func changeLocation(location: Int) {
        currentLocation = location
        tableView.reloadData()
    }
    
    func getCurrentStatus(events: [Event]) -> EateryStatus {
        #if TESTING
        let time = 1686444300
        #else
        let time = Int(Date().timeIntervalSince1970)
        #endif
        
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
                        if i < events.count - 1 && event.endTimestamp == events[i+1].startTimestamp {
                            return .open
                        }
                        return .closingSoon
                    }
                    return .open
                }
                if abs(time - event.startTimestamp) < 30 * 60 {
                    return .openingSoon
                }
                return .closed(until: Self.timeFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(event.startTimestamp))).replacingOccurrences(of: ":00", with: ""))
            }
            i += 1
        }
        return .closed(until: "")
    }
    
    func getEateryFromRow(row: Int) -> EateryInfo {
        if row < currentDiningHalls.count {
            return currentDiningHalls[row]
        }
        return currentCafes[row - 1 - currentDiningHalls.count]
    }
}

extension ListViewController: NSTableViewDataSource {

    func numberOfRows(in tableView: NSTableView) -> Int {
        return currentDiningHalls.count + currentCafes.count + 1
    }

    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        if row == currentDiningHalls.count {
            return 30
        }
        return 40
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if row == currentDiningHalls.count {
            guard let separatorCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "separatorCell"), owner: self) as? NSTableCellView else { return nil }
            
            return separatorCell
        }
        guard let eateryCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "eateryCell"), owner: self) as? EateryCell else { return nil }
        
        let eatery = getEateryFromRow(row: row)

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
            NotificationCenter.default.post(name: Notification.Name("ShowInfo"), object: getEateryFromRow(row: row))
        }
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        let view = tableView.view(atColumn: 0, row: row, makeIfNecessary: true)
        if !(view is EateryCell) {
            return false
        }
        return true
    }
}
