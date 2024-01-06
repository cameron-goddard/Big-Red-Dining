//
//  TimesViewController.swift
//  Big Red Dining
//
//  Created by Cameron Goddard on 12/24/23.
//

import Cocoa

class TimesViewController: NSViewController {
    
    @IBOutlet weak var tableView: NSTableView!
    
    var name: String = ""
    var days: [String] = ["Sunday", "Monday to Thursday", "Friday", "Saturday"]
    var hours: [String] = ["6:00pm - 12:00am", "11:00am - 3:00am", "Closed", "Closed"]

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = .clear
    }
    
    func updateInfo(name: String) {
        self.name = name
        
    }
    
    @IBAction func exitButtonPressed(_ sender: NSButton) {
        NotificationCenter.default.post(name: Notification.Name("ShowInfo"), object: self.name, userInfo: ["fromTimes": true])
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
