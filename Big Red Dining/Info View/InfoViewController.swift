//
//  InfoViewController.swift
//  Big Red Dining
//
//  Created by Cameron Goddard on 12/18/22.
//

import Cocoa

class InfoViewController: NSViewController {

    @IBOutlet weak var back: NSButton!
    @IBOutlet weak var expandAll: NSButton!
    @IBOutlet weak var outlineView: NSOutlineView!
    @IBOutlet weak var openStatus: NSTextField!
    
    var events : [Event] = []
    
    var breakfastCategories : [MenuCategory] = []
    var lunchCategories : [MenuCategory] = []
    var dinnerCategories : [MenuCategory] = []
    
    var currentCategory : [MenuCategory] = []
    
    var menuItems : [MenuItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        outlineView.backgroundColor = .clear
        
        if #available(macOS 13, *) {
            expandAll.image = NSImage(systemSymbolName: "arrow.up.and.down.text.horizontal", accessibilityDescription: nil)
        } else {
            expandAll.image = NSImage(named: "arrow.up.and.down.text.horizontal")
        }
    }
    
    override func viewWillAppear() {
        // Update status
        if events.isEmpty {
            currentCategory = []
            openStatus.stringValue = "Closed today"
        }
        else {
            showCurrentEvent()
        }
        outlineView.reloadData()
        
        // Update expandAll button
        if let state = UserDefaults.standard.object(forKey: "expandButton") as? NSControl.StateValue {
            expandAll.state = state
        }
        expandAllButtonPressed(expandAll)
    }
    
    func showCurrentEvent() {
        #if TESTING
        let current = 1686444300
        #else
        let current = Int(Date().timeIntervalSince1970)
        #endif
        
        let currentTime = Date(timeIntervalSince1970: TimeInterval(current))
        let format = DateFormatter()
        format.dateFormat = "MM-dd-yyyy HH:mm"
        format.timeZone = .current
        let str = format.string(from: currentTime)
        print("current: \(str)")
        
        let formatTime = DateFormatter()
        formatTime.timeZone = .current
        formatTime.dateFormat = "h:mm a"
        
        for event in events {
            print("\(event.descr) opening time: \(format.string(from: Date(timeIntervalSince1970: TimeInterval(event.startTimestamp))))")
            print("\(event.descr) closing time: \(format.string(from: Date(timeIntervalSince1970: TimeInterval(event.endTimestamp))))")
            
            if current < event.endTimestamp {
                
                // set openStatus
                if current > event.startTimestamp {
                    let timeRemaining = abs(current - event.endTimestamp)
                    let closingTime = Date(timeIntervalSince1970: TimeInterval(event.endTimestamp))
                    if timeRemaining <= 30 * 60 {
                        
                        openStatus.stringValue = "Closes at " + formatTime.string(from: closingTime)
                    } else {
                        openStatus.stringValue = "Open until " + formatTime.string(from: closingTime)
                    }
                } else {
                    let timeUntilOpen = abs(current - event.startTimestamp)
                    if timeUntilOpen <= 30 * 60 {
                        let openingTime = Date(timeIntervalSince1970: TimeInterval(event.startTimestamp))
                        openStatus.stringValue = "Opens at " + formatTime.string(from: openingTime)
                    } else {
                        let startTime = Date(timeIntervalSince1970: TimeInterval(event.startTimestamp))
                        let dateFormatter = DateFormatter()
                        dateFormatter.timeZone = TimeZone(abbreviation: "EST")
                        dateFormatter.dateFormat = "h:mm"
                        
                        openStatus.stringValue = "Opens for " + event.descr.lowercased() + " at " + dateFormatter.string(from: startTime)
                    }
                }
                print("---")
                currentCategory = event.menu
                return
            }
        }
    }
    
    func updateInfo(events: [Event], meals: [String]) {
        self.events = events
    }
    
    func changeMeal(to: Int) {
        if to == 0 {
            if !events.filter({ $0.descr == "Breakfast" }).isEmpty {
                currentCategory = events.filter({ $0.descr == "Breakfast" })[0].menu
            } else {
                currentCategory = events.filter({ $0.descr == "Brunch" })[0].menu
            }
        }
        if to == 1 {
            currentCategory = events.filter({ $0.descr == "Lunch" })[0].menu
        }
        if to == 2 {
            currentCategory = events.filter({ $0.descr == "Dinner" })[0].menu
        }
        
        outlineView.reloadData()
        expandAllButtonPressed(expandAll)
    }
    
    @IBAction func backButtonPressed(_ sender: NSButton) {
        NotificationCenter.default.post(name: Notification.Name("ShowList"), object: nil)
    }
    
    @IBAction func expandAllButtonPressed(_ sender: NSButton) {
        if sender.state == .on {
            outlineView.animator().expandItem(nil, expandChildren: true)
        } else {
            outlineView.animator().collapseItem(nil, collapseChildren: true)
        }
        UserDefaults.standard.set(sender.state, forKey: "expandButton")
    }
    
}

extension InfoViewController: NSOutlineViewDataSource {
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if let category = item as? MenuCategory {
            return category.items.count
        }
        return currentCategory.count
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if let category = item as? MenuCategory {
            return category.items[index]
        }
        return currentCategory[index]
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if item is MenuCategory { return true }
        return false
    }
}

extension InfoViewController: NSOutlineViewDelegate {
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        if item is MenuCategory {
            guard let categoryCell = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "categoryCell"), owner: self) as? CategoryCell else { return nil }
            
            categoryCell.name.stringValue = (item as! MenuCategory).category
            return categoryCell
        }
        if item is MenuItem {
            guard let menuItemCell = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "menuItemCell"), owner: self) as? MenuItemCell else { return nil }
            
            menuItemCell.name.stringValue = (item as! MenuItem).item
            return menuItemCell
        }
        return nil
    }
    
    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        return 16
    }
    
    func selectionShouldChange(in outlineView: NSOutlineView) -> Bool {
        return false
    }
}

extension Date {

    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }

}
