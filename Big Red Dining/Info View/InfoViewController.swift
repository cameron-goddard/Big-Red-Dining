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
    @IBOutlet weak var status: NSButton!
    
    var events : [Event] = []
    var curr : Int = -1
    
    var currentCategory : [MenuCategory] = []
    
    var menuItems : [MenuItem] = []
    
    var currentTime = -1
    
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
        // Update current time
        #if TESTING
        currentTime = 1686444300
        #else
        currentTime = Int(Date().timeIntervalSince1970)
        #endif
        
        // Get current event and update its status
        curr = getCurrentEvent()
        let returnStatus = currentStatus(for: curr)
        status.image = returnStatus.0
        status.title = returnStatus.1
        
        // Show current event's menu
        if curr == -1 {
            currentCategory = []
        } else {
            currentCategory = events[curr].menu
        }
        outlineView.reloadData()
        
        // Update expandAll button
        if let state = UserDefaults.standard.object(forKey: "expandButton") as? NSControl.StateValue {
            expandAll.state = state
        }
        expandAllButtonPressed(expandAll)
    }
    
    func getCurrentEvent() -> Int {
        if events.isEmpty {
            return -1
        }
        
        // Get event happening now
        
        var i = 0
        for event in events {
            if currentTime < event.endTimestamp && currentTime >= event.startTimestamp {
                return i
            }
            i += 1
        }
        
        i = 0
        // Get next upcoming event
        for event in events {
            if currentTime < event.startTimestamp {
                return i
            }
            i += 1
        }
        
        // Get last event that happened
        return events.count - 1
    }
    
    func currentStatus(for eventIndex: Int) -> (NSImage, String) {
        if eventIndex == -1 {
            if noEateryInfo {
                return (NSImage(named: "NSStatusNone")!, "Could not get eatery info")
            }
            return (NSImage(named: "NSStatusUnavailable")!, "Closed today")
        }
        
        let formatTime = DateFormatter()
        formatTime.timeZone = .current
        formatTime.dateFormat = "h:mma"
        formatTime.amSymbol = "am"
        formatTime.pmSymbol = "pm"
        
        let event = events[eventIndex]
        if currentTime < event.startTimestamp {
            // Before event started
            var image = NSImage(named: "NSStatusUnavailable")
            if abs(currentTime - event.startTimestamp) < 30 * 60 {
                image = .init(named: "NSStatusPartiallyAvailable")
            }
            return (image!, "Opens at " + formatTime.string(from: Date(timeIntervalSince1970: TimeInterval(event.startTimestamp))).replacingOccurrences(of: ":00", with: ""))
        } else {
            if currentTime > event.endTimestamp {
                // After event ended
                return (NSImage(named: "NSStatusUnavailable")!, "Closed since " + formatTime.string(from: Date(timeIntervalSince1970: TimeInterval(event.endTimestamp))).replacingOccurrences(of: ":00", with: ""))
            }
            // Event is happening now
            
            // TODO: This is assuming the next event is > 30 mins in duration
            if hasNextContiguous(for: eventIndex) {
                return (NSImage(named: "NSStatusAvailable")!, "Open until " + formatTime.string(from: Date(timeIntervalSince1970: TimeInterval(events[eventIndex+1].endTimestamp))).replacingOccurrences(of: ":00", with: ""))
            }
            
            if abs(currentTime - events[curr].endTimestamp) < 30 * 60 {
                return (NSImage(named: "NSStatusPartiallyAvailable")!, "Closing at " + formatTime.string(from: Date(timeIntervalSince1970: TimeInterval(event.endTimestamp))).replacingOccurrences(of: ":00", with: ""))
            }
            
            return (NSImage(named: "NSStatusAvailable")!, "Open until " + formatTime.string(from: Date(timeIntervalSince1970: TimeInterval(event.endTimestamp))).replacingOccurrences(of: ":00", with: ""))
        }
    }
    
    func hasNextContiguous(for eventIndex: Int) -> Bool {
        if eventIndex == events.count - 1 {
            return false
        }
        
        if events[eventIndex].endTimestamp == events[eventIndex+1].startTimestamp {
            return true
        }
        return false
    }
    
    func updateInfo(events: [Event]) {
        self.events = events
    }
    
    func changeMeal(to meal: Int) {
        if meal == 0 {
            if !events.filter({ $0.descr == "Breakfast" }).isEmpty {
                currentCategory = events.filter({ $0.descr == "Breakfast" })[0].menu
            } else {
                currentCategory = events.filter({ $0.descr == "Brunch" })[0].menu
            }
        }
        if meal == 1 {
            currentCategory = events.filter({ $0.descr == "Lunch" })[0].menu
        }
        if meal == 2 {
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
