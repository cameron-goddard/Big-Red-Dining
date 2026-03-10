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

    /// The amount of time, in minutes, before closing that will mark the eatery
    /// as closing or opening soon
    private static let soonThreshold = 30 * 60

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mma"
        formatter.amSymbol = "am"
        formatter.pmSymbol = "pm"
        formatter.timeZone = .current
        return formatter
    }()

    private var currentLocation: Location = .west

    private var currentDiningHalls: [EateryInfo] {
        allEateries.values.filter { $0.location == currentLocation && !$0.isCafe }
    }

    private var currentCafes: [EateryInfo] {
        let cafes = allEateries.values.filter { $0.location == currentLocation && $0.isCafe }

        // Always show open eateries above closed ones
        return cafes.sorted { a, b in
            let aOpen = isOpen(status: getCurrentStatus(events: a.events))
            let bOpen = isOpen(status: getCurrentStatus(events: b.events))
            if aOpen != bOpen {
                return aOpen
            }
            return a.name < b.name
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = .clear
        tableView.reloadData()
    }

    override func viewDidAppear() {
        tableView.reloadData()
    }

    /// Updates the eatery list for a new location.
    /// - Parameter location: The new location
    func changeLocation(location: Location) {
        currentLocation = location
        tableView.reloadData()
    }

    /// Determines the current operating status of an eatery based on its scheduled events.
    ///
    /// - Parameter events: The list of today's events for the eatery, ordered chronologically
    /// - Returns: An ``EateryStatus`` representing the eatery's current state:
    ///   - `.open` if the current time falls within an event's time range
    ///   - `.closingSoon` if the eatery is open but will close within the soon threshold
    ///   - `.openingSoon` if the eatery is closed but will open within the soon threshold
    ///   - `.closed(until:)` with the next opening time if a future event exists today
    ///   - `.closedToday` if there are no events scheduled
    ///   - `.error` if eatery information is unavailable
    private func getCurrentStatus(events: [Event]) -> EateryStatus {
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
        
        for (index, event) in events.enumerated() {
            if time < event.endTimestamp {
                if time >= event.startTimestamp {
                    if abs(time - event.endTimestamp) < Self.soonThreshold {
                        if index < events.count - 1 && event.endTimestamp == events[index+1].startTimestamp {
                            return .open
                        }
                        return .closingSoon
                    }
                    return .open
                }
                if abs(time - event.startTimestamp) < Self.soonThreshold {
                    return .openingSoon
                }
                return .closed(until: Self.timeFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(event.startTimestamp))).replacingOccurrences(of: ":00", with: ""))
            }
        }
        return .closed(until: "")
    }

    /// Helper function to determine which ``EateryStatus`` values are considered open.
    /// - Parameter status: The ``EateryStatus`` to query
    /// - Returns: Whether the given status is considered open
    private func isOpen(status: EateryStatus) -> Bool {
        switch status {
        case .open, .closingSoon, .openingSoon:
            return true
        case .closed, .closedToday, .error:
            return false
        }
    }

    /// Returns the eatery at a given row index.
    /// - Parameter row: The row
    /// - Returns: The ``EateryInfo`` object at that row index
    private func getEateryFromRow(row: Int) -> EateryInfo {
        if row < currentDiningHalls.count {
            return currentDiningHalls[row]
        }
        return currentCafes[row - 1 - currentDiningHalls.count]
    }
}

extension ListViewController: NSTableViewDataSource {

    /// Returns the total number of rows, including dining halls, cafes, and a separator row.
    func numberOfRows(in tableView: NSTableView) -> Int {
        return currentDiningHalls.count + currentCafes.count + 1
    }

    /// Returns the height for a given row, using a smaller height for the separator row.
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        if row == currentDiningHalls.count {
            return 30
        }
        return 40
    }

    /// Configures and returns the appropriate cell view for a row.
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
        case .closedToday:
            eateryCell.statusIcon.image = NSImage(named: "NSStatusUnavailable")!
            eateryCell.statusText.stringValue = "Closed"
        }
        return eateryCell
    }
}

extension ListViewController: NSTableViewDelegate {

    /// Handles row selection by posting a ``ShowInfo`` notification with the selected eatery.
    func tableViewSelectionDidChange(_ notification: Notification) {
        let row = tableView.selectedRow
        tableView.deselectRow(row)
        if row != -1 {
            NotificationCenter.default.post(name: Notification.Name("ShowInfo"), object: getEateryFromRow(row: row))
        }
    }
    
    /// Prevents the separator row from being selected.
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return tableView.view(atColumn: 0, row: row, makeIfNecessary: true) is EateryCell
    }
}
