//
//  InfoViewController.swift
//  DiningBar
//
//  Created by Cameron Goddard on 12/18/22.
//

import Cocoa

class InfoViewController: NSViewController {

    @IBOutlet weak var back: NSButton!
    @IBOutlet weak var expandAll: NSButton!
    @IBOutlet weak var outlineView: NSOutlineView!
    
    // temporary data for testing
    var breakfastCategories : [MenuCategory] = [
        MenuCategory(category: "Grill", items: [
            MenuItem(item: "Spicy Macaroni & Cheese", healthy: false),
            MenuItem(item: "Hot Ham And Cheese Sandwich", healthy: false),
            MenuItem(item: "Seasoned Wedge Fries", healthy: false),
            MenuItem(item: "Grilled Hot Dogs", healthy: false)
        ]),
        MenuCategory(category: "Soup", items: [
            MenuItem(item: "Cornell Cream of Tomato Soup", healthy: false),
            MenuItem(item: "Black Bean Soup", healthy: false),
        ]),
        MenuCategory(category: "Beverage", items: [
            MenuItem(item: "Hot & Cold Beverage Service", healthy: false)
        ]),
        MenuCategory(category: "Chef's Table", items: [
            MenuItem(item: "Marinated Asian Tofu", healthy: false),
            MenuItem(item: "Chicken Rigatoni", healthy: false)
        ]),
        MenuCategory(category: "Salad", items: [
            MenuItem(item: "Healthy Style Salad Station", healthy: false),
            MenuItem(item: "Roasted Corn & Black Bean Salad", healthy: false),
            MenuItem(item: "Grilled Marinated Tofu", healthy: false),
            MenuItem(item: "Egg Salad", healthy: false),
            MenuItem(item: "White Wine Vinaigrette Tuna Salad", healthy: false),
            MenuItem(item: "Grilled Chicken Breast", healthy: false)
        ])
    ]
    var lunchCategories : [MenuCategory] = []
    var dinnerCategories : [MenuCategory] = []
    
    var currentCategory : [MenuCategory] = []
    
    var menuItems : [MenuItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        outlineView.backgroundColor = .clear
        
        currentCategory = breakfastCategories
        outlineView.reloadData()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
    }
    
    func updateInfo(name: String) {
    }
    
    func changeMeal(to: Int) {
        switch to {
        case 0:
            currentCategory = breakfastCategories
        case 1:
            currentCategory = lunchCategories
        default:
            currentCategory = dinnerCategories
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
            //categoryCell.name.font = NSFont.systemFont(ofSize: 14, weight: .semibold)
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
