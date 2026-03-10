//
//  ViewController.swift
//  Big Red Dining
//
//  Created by Cameron Goddard on 12/17/22.
//

import Cocoa
import ServiceManagement

class ViewController: NSViewController {

    @IBOutlet weak var titleField: NSTextField!
    @IBOutlet weak var infoButton: NSButton!

    @IBOutlet weak var mainControl: NSSegmentedControl!

    private var controlIsLocation = true
    private var savedLocation: Location = .west

    private var tabVC: NSTabViewController?
    private var listVC: ListViewController?
    private var infoVC: InfoViewController?
    private var timesVC: TimesViewController?

    private var lastAPILoad: Date = Date(timeIntervalSince1970: .zero)

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "America/New_York")
        formatter.dateFormat = "yMMdd"
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.showEateryInfo(notification:)), name: Notification.Name("ShowInfo"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.showEateryList(notification:)), name: Notification.Name("ShowList"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.showEateryTimes(notification:)), name: Notification.Name("ShowTimes"), object: nil)
    }

    override func viewDidAppear() {
        let current = Date()
        
        // Only download API data if the date has changed or if the last connection failed
        if Self.dateFormatter.string(from: current) != Self.dateFormatter.string(from: lastAPILoad) || noEateryInfo {
            lastAPILoad = current
            
            Task {
                do {
                    let eateries = try await NetworkManager.getEateryInfo()
                    noEateryInfo = false
                    
                    for e in eateries {
                        allEateries[e.id]?.update(with: e)
                    }
                } catch {
                    noEateryInfo = true
                }
                listVC?.tableView.reloadData()
            }
        }
    }

    @IBAction func controlDidChange(_ sender: NSSegmentedControl) {
        if controlIsLocation {
            let location = Location(rawValue: sender.selectedSegment) ?? .west
            listVC?.changeLocation(location: location)
            savedLocation = location
        } else {
            infoVC?.changeMeal(to: sender.selectedSegment)
        }
    }
    
    /// Captures references to the child view controllers (list, info, times) from the embedded tab view controller.
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        guard let tabViewController = segue.destinationController
          as? NSTabViewController else { return }
        tabVC = tabViewController
        
        listVC = tabViewController.tabViewItems[0].viewController as? ListViewController
        infoVC = tabViewController.tabViewItems[1].viewController as? InfoViewController
        timesVC = tabViewController.tabViewItems[2].viewController as? TimesViewController
    }
    
    /// Transitions to the info view for the selected eatery.
    /// - Parameter notification: A notification whose object is the `EateryInfo` to display.
    @objc func showEateryInfo(notification: Notification) {
        controlIsLocation = false
        infoButton.isHidden = true
        guard let e = notification.object as? EateryInfo else { return }
        
        if (e.shortName == "") {
            titleField.stringValue = e.name
        } else {
            titleField.stringValue = e.shortName
        }
        
        mainControl.setLabel("Breakfast", forSegment: 0)
        mainControl.setLabel("Lunch", forSegment: 1)
        mainControl.setLabel("Dinner", forSegment: 2)
        
        if e.isCafe {
            for i in 0..<3 {
                mainControl.setSelected(false, forSegment: i)
                mainControl.setEnabled(false, forSegment: i)
            }
        } else {
            // Necessary to enable all when coming back from times view
            for i in 0..<3 { mainControl.setEnabled(true, forSegment: i) }
            
            var selected = getSelectedSegment(events: e.events)
            
            if selected == -1 {
                for i in 0..<3 { mainControl.setSelected(false, forSegment: i) }
                for i in 0..<3 { mainControl.setEnabled(false, forSegment: i) }
            } else {
                let meals = e.events.map({ $0.descr })
                
                if !meals.contains("Breakfast") {
                    mainControl.setEnabled(false, forSegment: 0)
                    selected += 1
                }
                if !meals.contains("Lunch") {
                    mainControl.setEnabled(false, forSegment: 1)
                    if selected == 1 { selected += 1 }
                }
                if !meals.contains("Dinner") {
                    mainControl.setEnabled(false, forSegment: 2)
                }
                if meals.contains("Brunch") {
                    mainControl.setLabel("Brunch", forSegment: 0)
                    mainControl.setEnabled(false, forSegment: 1)
                    if selected == 1 { selected += 1 }
                }
                if selected > 2 {
                    selected = 2
                }
                mainControl.setSelected(true, forSegment: selected)
            }
        }
        
        // Handle display of main view
        if notification.userInfo?["fromTimes"] is Bool {
            tabVC?.transition(from: timesVC!, to: infoVC!, options: .slideUp)
        } else {
            infoVC?.updateInfo(eatery: e)
            tabVC?.transition(from: listVC!, to: infoVC!, options: .slideLeft)
        }
    }

    /// Transitions to the eatery list view.
    /// - Parameter notification: The notification that triggered this navigation
    @objc func showEateryList(notification: Notification) {
        controlIsLocation = true
        infoButton.isHidden = false
        titleField.stringValue = "Eateries"
        
        mainControl.setLabel("West", forSegment: 0)
        mainControl.setLabel("Central", forSegment: 1)
        mainControl.setLabel("North", forSegment: 2)
        
        for i in 0..<3 { mainControl.setEnabled(true, forSegment: i) }
        mainControl.setSelected(true, forSegment: savedLocation.rawValue)
        
        tabVC?.transition(from: infoVC!, to: listVC!, options: .slideRight)
    }

    /// Transitions to the times view for the selected eatery.
    /// - Parameter notification: A notification whose object is the `EateryInfo` to display
    @objc func showEateryTimes(notification: Notification) {
        guard let e = notification.object as? EateryInfo else { return }
        timesVC?.updateInfo(eatery: e)
        for i in 0..<3 {
            mainControl.setSelected(false, forSegment: i)
            mainControl.setEnabled(false, forSegment: i)
        }
        tabVC?.transition(from: infoVC!, to: timesVC!, options: .slideDown)
    }

    /// Determines which main control segment should be selected based on the current time and available events.
    /// - Parameter events: The eatery's meal periods for the day
    /// - Returns: The index of the segment to select, or `-1` if there are no events
    private func getSelectedSegment(events: [Event]) -> Int {
        #if TESTING
        let current = 1686444300
        #else
        let current = Int(Date().timeIntervalSince1970)
        #endif
        
        if events.isEmpty {
            return -1
        }
        var eventNames: [String] = []
        for i in 0..<events.count {
            eventNames.append(events[i].descr)
            if current < events[i].endTimestamp {
                return i
            }
        }
        
        // This may no longer be relevant since the API changed naming
        // Handle multiple events with the same name (e.g. Morrison's two lunches)
        if eventNames.count != Set(eventNames).count {
            return events.count - abs(eventNames.count - Set(eventNames).count) - 1
        }
        
        // TODO: Fix this monstrosity
        if events.count == 3 {
            return 2
        }
        return events.count - 1
    }

    /// Quits the application.
    @objc func quitApp() {
        NSApp.terminate(self)
    }

    /// Shows the standard About panel.
    @objc func showAboutPanel() {
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        appDelegate.closePopover()
        NSApplication.shared.activate(ignoringOtherApps: true)
        NSApplication.shared.orderFrontStandardAboutPanel()
    }

    /// Toggles whether the app should open at login by default.
    /// - Parameter sender: The menu item that triggered the action
    @objc func toggleOpenAtLogin(_ sender: NSMenuItem) {
        if SMAppService.mainApp.status != .enabled {
            do {
                try SMAppService.mainApp.register()
            } catch {
                NSLog("Unable to register as a login item")
            }
        } else {
            do {
                try SMAppService.mainApp.unregister()
            } catch {
                NSLog("Unable to unregister as a login item")
            }
        }
    }

    /// Presents a context menu anchored to the info button with app options.
    /// - Parameter sender: The button that triggered the action
    @IBAction func infoButtonPressed(_ sender: NSButton) {
        let infoMenu = NSMenu()
        infoMenu.addItem(withTitle: "About Big Red Dining", action: #selector(showAboutPanel), keyEquivalent: "")
        infoMenu.addItem(NSMenuItem.separator())
        
        let openAtLoginItem = NSMenuItem(title: "Open at login", action: #selector(toggleOpenAtLogin), keyEquivalent: "")
        if SMAppService.mainApp.status == .enabled {
            openAtLoginItem.state = .on
        } else {
            openAtLoginItem.state = .off
        }
        infoMenu.addItem(openAtLoginItem)
        
        infoMenu.addItem(NSMenuItem.separator())
        infoMenu.addItem(withTitle: "Quit Big Red Dining", action: #selector(quitApp), keyEquivalent: "q")
        
        let p = NSPoint(x: -110, y: sender.frame.height+15)
        infoMenu.popUp(positioning: nil, at: p, in: sender)
    }
}

extension ViewController {
    /// Instantiates and returns a new `ViewController` from the Main storyboard.
    static func newController() -> ViewController {
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let identifier = NSStoryboard.SceneIdentifier("ViewController")
        guard let vc = storyboard.instantiateController(withIdentifier: identifier) as? ViewController else {
          fatalError("Nah")
        }
        return vc
    }
}
