//
//  TimesViewController.swift
//  Big Red Dining
//
//  Created by Cameron Goddard on 12/24/23.
//

import Cocoa

class TimesViewController: NSViewController {

    @IBOutlet weak var back: NSButton!
    @IBOutlet weak var tableView: NSTableView!

    private static let dateParser: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    private static let dayOfWeekFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter
    }()

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mma"
        formatter.amSymbol = "am"
        formatter.pmSymbol = "pm"
        formatter.timeZone = .current
        return formatter
    }()
    
    private var eatery: EateryInfo?
    private var days: [String] = []
    private var hours: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = .clear
        
        // Adjust button size for macOS 15 and below
        if #unavailable(macOS 26, ) {
            back.frame = NSRect(x: 3, y: 153, width: 40, height: 32)
        }
    }

    override func viewWillAppear() {
        super.viewWillAppear()
        tableView.reloadData()
    }

    /// Populates the view with the given eatery's operating hours.
    /// - Parameter eatery: The ``EateryInfo`` whose hours should be displayed
    func updateInfo(eatery: EateryInfo) {
        days = []
        hours = []
        self.eatery = eatery
        guard let oh = eatery.obj?.operatingHours else { return }
        
        for i in 1..<oh.count {
            let date = Self.dateParser.date(from: oh[i].date)!
            days.append(Self.dayOfWeekFormatter.string(from: date))
            
            if oh[i].events.isEmpty {
                hours.append("Closed")
            } else {
                let startDate = Date(timeIntervalSince1970: TimeInterval(oh[i].events.first!.startTimestamp))
                let endDate = Date(timeIntervalSince1970: TimeInterval(oh[i].events.last!.endTimestamp))

                let start = Self.timeFormatter.string(from: startDate)
                let end = Self.timeFormatter.string(from: endDate)
                hours.append("\(start) - \(end)")
            }
        }
        
        var streak = false
        var streakStart : String = ""
        
        var combinedDays : [String] = []
        var combinedHours : [String] = []
        
        for i in 0..<hours.count - 1 {
            if hours[i] == hours[i+1] {
                if !streak {
                    streak = true
                    streakStart = days[i]
                }
                if i == hours.count - 2 {
                    combinedDays.append("\(streakStart) to \(days[i+1])")
                    combinedHours.append(hours[i+1])
                }
            } else {
                if streak {
                    combinedDays.append("\(streakStart) to \(days[i])")
                    combinedHours.append(hours[i])
                    
                    streak = false
                    streakStart = ""
                } else {
                    combinedDays.append(days[i])
                    combinedHours.append(hours[i])
                }
                if i == hours.count - 2 {
                    combinedDays.append(days[i+1])
                    combinedHours.append(hours[i+1])
                }
            }
        }
        days = combinedDays
        hours = combinedHours
    }

    /// Handles the exit button tap by posting a notification to navigate back to the info view.
    /// - Parameter sender: The button that triggered the action
    @IBAction func exitButtonPressed(_ sender: NSButton) {
        NotificationCenter.default.post(name: Notification.Name("ShowInfo"), object: self.eatery, userInfo: ["fromTimes": true])
    }
}

extension TimesViewController: NSTableViewDataSource {
    /// Returns the number of rows, corresponding to the number of day/hour entries.
    func numberOfRows(in tableView: NSTableView) -> Int {
        return hours.count
    }

    /// Returns a fixed row height of 25 points for all rows.
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 25
    }

    /// Returns the appropriate cell for the given column.
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if tableColumn == tableView.tableColumns[0] {
            guard let dayCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "dayCell"), owner: self) as? NSTableCellView else { return nil }
            
            dayCell.textField?.stringValue = days[row]
            return dayCell
        } else {
            guard let hourCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "hourCell"), owner: self) as? NSTableCellView else { return nil }
            
            hourCell.textField?.stringValue = hours[row]
            return hourCell
        }
    }
}

extension TimesViewController: NSTableViewDelegate {
    
    /// Row selection is not used in this view.
    func tableViewSelectionDidChange(_ notification: Notification) {
        
    }
}
