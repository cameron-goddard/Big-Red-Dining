//
//  TimesViewController.swift
//  Big Red Dining
//
//  Created by Cameron Goddard on 12/24/23.
//

import Cocoa

class TimesViewController: NSViewController {
    
    @IBOutlet weak var tableView: NSTableView!
    
    var eatery: EateryInfo?
    var days: [String] = []
    var hours: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = .clear
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        tableView.reloadData()
    }
    
    func updateInfo(eatery: EateryInfo) {
        days = []
        hours = []
        self.eatery = eatery
        let oh = eatery.obj!.operatingHours
        let formatter = DateFormatter()
        
        for i in 1..<oh.count {
            formatter.dateFormat = "yyyy-MM-dd"
            let date = formatter.date(from: oh[i].date)!
            formatter.dateFormat = "E"
            days.append(formatter.string(from: date))
            
            if oh[i].events.isEmpty {
                hours.append("Closed")
            } else {
                let start = oh[i].events.first!.start
                let end = oh[i].events.last!.end
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
    
    @IBAction func exitButtonPressed(_ sender: NSButton) {
        NotificationCenter.default.post(name: Notification.Name("ShowInfo"), object: self.eatery!.name, userInfo: ["fromTimes": true])
    }
}

extension TimesViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return hours.count
    }

    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 25
    }

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
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        
    }
}
