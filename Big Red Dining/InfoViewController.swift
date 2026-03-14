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

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mma"
        formatter.amSymbol = "am"
        formatter.pmSymbol = "pm"
        formatter.timeZone = .current
        return formatter
    }()

    private var eatery: EateryInfo?
    private var events: [Event] = []
    private var curr: Int = -1

    private var currentCategory: [MenuCategory] = []
    private var menuItems: [MenuItem] = []

    private var currentTime = -1

    override func viewDidLoad() {
        super.viewDidLoad()
        outlineView.backgroundColor = .clear

        // Adjust button sizes for macOS 15 and below
        if #unavailable(macOS 26, ) {
            back.frame = NSRect(x: 3, y: 153, width: 40, height: 32)
            expandAll.frame = NSRect(x: 265, y: 153, width: 40, height: 32)
        }
    }

    override func viewWillAppear() {
        // Update current time
        #if TESTING
        currentTime = 1686444300
        #else
        currentTime = Int(Date().timeIntervalSince1970)
        #endif
        
        // Get the current event and update its status
        curr = getCurrentEvent()
        let returnStatus = currentStatus(for: curr)
        status.image = returnStatus.0
        status.title = returnStatus.1
        
        // Show the current event's menu
        if curr == -1 {
            currentCategory = []
        } else {
            currentCategory = events[curr].menu
        }
        outlineView.reloadData()
        
        // Update the expandAll button
        if let state = UserDefaults.standard.object(forKey: "expandButton") as? NSControl.StateValue {
            expandAll.state = state
        }
        expandAllButtonPressed(expandAll)
    }

    /// Updates the view controller with new eatery data, replacing the current events list.
    /// - Parameter eatery: The ``EateryInfo`` containing events and menu data to display
    func updateInfo(eatery: EateryInfo) {
        self.events = eatery.events
        self.eatery = eatery
    }
    
    /// Switches the displayed menu to the specified meal
    /// - Parameter meal: The meal index to display
    func changeMeal(to meal: Int) {
        if meal == 0 {
            if !events.filter({ $0.descr == "Breakfast" }).isEmpty {
                currentCategory = events.filter({ $0.descr == "Breakfast" })[0].menu
            } else {
                currentCategory = events.filter({ $0.descr == "Brunch" })[0].menu
            }
        } else if meal == 1 {
            currentCategory = events.filter({ $0.descr == "Lunch" })[0].menu
        } else if meal == 2 {
            currentCategory = events.filter({ $0.descr == "Dinner" })[0].menu
        }
        
        outlineView.reloadData()
        expandAllButtonPressed(expandAll)
    }
    
    /// Returns the index of the most relevant event based on the current time.
    ///
    /// Prioritizes the currently active event, then the next upcoming event, and finally
    /// falls back to the last event in the list. Returns `-1` if there are no events.
    /// - Returns: The index of the current or most relevant event, or `-1` if none exist.
    private func getCurrentEvent() -> Int {
        if let i = events.firstIndex(where: { currentTime < $0.endTimestamp && currentTime >= $0.startTimestamp }) {
            return i
        }
        if let i = events.firstIndex(where: { currentTime < $0.startTimestamp }) {
            return i
        }
        return events.isEmpty ? -1 : events.count - 1
    }
    
    /// Returns the status image and description string for the given event index.
    /// - Parameter eventIndex: The index of the event to check, or `-1` if no events exist
    /// - Returns: A tuple of the status image and a human-readable status string
    private func currentStatus(for eventIndex: Int) -> (NSImage, String) {
        if eventIndex == -1 {
            if noEateryInfo {
                return (NSImage(named: "NSStatusNone")!, "Could not get eatery info")
            }
            return (NSImage(named: "NSStatusUnavailable")!, "Closed today")
        }
        
        let event = events[eventIndex]
        if currentTime < event.startTimestamp {
            // Before event started
            var image = NSImage(named: "NSStatusUnavailable")
            if abs(currentTime - event.startTimestamp) < 30 * 60 {
                image = .init(named: "NSStatusPartiallyAvailable")
            }
            return (image!, "Opens at " + Self.timeFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(event.startTimestamp))).replacingOccurrences(of: ":00", with: ""))
        } else {
            if currentTime > event.endTimestamp {
                // After event ended
                return (NSImage(named: "NSStatusUnavailable")!, "Closed since " + Self.timeFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(event.endTimestamp))).replacingOccurrences(of: ":00", with: ""))
            }
            // Event is happening now
            // Note: This is assuming the next event is >30 mins in duration
            if hasNextContiguous(for: eventIndex) {
                return (NSImage(named: "NSStatusAvailable")!, "Open until " + Self.timeFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(events[eventIndex+1].endTimestamp))).replacingOccurrences(of: ":00", with: ""))
            }
            
            if abs(currentTime - events[curr].endTimestamp) < 30 * 60 {
                return (NSImage(named: "NSStatusPartiallyAvailable")!, "Closing at " + Self.timeFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(event.endTimestamp))).replacingOccurrences(of: ":00", with: ""))
            }
            
            return (NSImage(named: "NSStatusAvailable")!, "Open until " + Self.timeFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(event.endTimestamp))).replacingOccurrences(of: ":00", with: ""))
        }
    }
    
    /// Checks whether the next event starts immediately when the given event ends.
    /// - Parameter eventIndex: The index of the event to check
    /// - Returns: Whether there is a following event whose start time equals this event's end time
    private func hasNextContiguous(for eventIndex: Int) -> Bool {
        eventIndex < events.count - 1 && events[eventIndex].endTimestamp == events[eventIndex + 1].startTimestamp
    }
    
    /// Handles the back button tap by posting a notification to return to the list view.
    /// - Parameter sender: The button that triggered the action
    @IBAction func backButtonPressed(_ sender: NSButton) {
        NotificationCenter.default.post(name: Notification.Name("ShowList"), object: nil)
    }
    
    /// Handles the times button tap by posting a notification to show the times view.
    /// - Parameter sender: The button that triggered the action
    @IBAction func timesButtonPressed(_ sender: NSButton) {
        NotificationCenter.default.post(name: Notification.Name("ShowTimes"), object: self.eatery!)
    }
    
    /// Toggles expanding or collapsing all outline view items and persists the state to user defaults.
    /// - Parameter sender: The button that triggered the action
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
    /// Returns the number of children for the given item: menu items for a category, or categories at the root level.
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if let category = item as? MenuCategory {
            return category.items.count
        }
        return currentCategory.count
    }
    
    /// Returns the child object at the given index: a menu item within a category, or a category at the root level.
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if let category = item as? MenuCategory {
            return category.items[index]
        }
        return currentCategory[index]
    }
    
    /// Returns whether the item can be expanded. Only `MenuCategory` items are expandable.
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if item is MenuCategory { return true }
        return false
    }
}

extension InfoViewController: NSOutlineViewDelegate {
    /// Returns the appropriate cell view for the given item, configured with the category name or menu item name.
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        if let category = item as? MenuCategory {
            guard let cell = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "categoryCell"), owner: self) as? NSTableCellView else { return nil }
            cell.textField?.stringValue = category.category
            return cell
        }
        if let menuItem = item as? MenuItem {
            guard let cell = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "menuItemCell"), owner: self) as? NSTableCellView else { return nil }
            cell.textField?.stringValue = menuItem.item
            return cell
        }
        return nil
    }
    
    /// Returns a fixed row height of 16 points for all outline view items.
    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        return 16
    }
    
    /// Prevents row selection in the outline view.
    func selectionShouldChange(in outlineView: NSOutlineView) -> Bool {
        return false
    }
}
