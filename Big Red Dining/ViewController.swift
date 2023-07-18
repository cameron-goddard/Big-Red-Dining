//
//  ViewController.swift
//  Big Red Dining
//
//  Created by Cameron Goddard on 12/17/22.
//

import Cocoa
import Sparkle
import LaunchAtLogin

class ViewController: NSViewController {
    
    @IBOutlet weak var titleField: NSTextField!
    @IBOutlet weak var infoButton: NSButton!
    
    @IBOutlet weak var mainControl: NSSegmentedControl!
    
    var controlIsLocation = true
    var savedLocation = 0
    
    var tabVC: NSTabViewController?
    var listVC: ListViewController?
    var infoVC: InfoViewController?
    
    let allowedEateries = [3, 4, 20, 25, 26, 27, 29, 30, 31, 43]
    var lastMainAPILoad : Date = Date(timeIntervalSince1970: .zero)
    var eateries : [Eatery] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.showEateryInfo(notification:)), name: Notification.Name("ShowInfo"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.showEateryList(notification:)), name: Notification.Name("ShowList"), object: nil)
    }
    
    override func viewDidAppear() {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "EDT")
        dateFormatter.dateFormat = "yMMdd"
        
        let current = Date()
        
        // Download API data if the date has changed or if connection failed last time
        if dateFormatter.string(from: current) != dateFormatter.string(from: lastMainAPILoad) || noEateryInfo {
            NetworkManager.getEateryInfo(completion: { json, error in
                if error != nil {
                    noEateryInfo = true
                    // This might be a hacky way to do it, change
                    DispatchQueue.main.async {
                        self.listVC!.tableView.reloadData()
                    }
                    return
                } else {
                    noEateryInfo = false
                }
                
                for eatery in json! {
                    if self.allowedEateries.contains(eatery.id) {
                        self.eateries.append(eatery)
                    }
                }
                DispatchQueue.main.async {
                    dateFormatter.dateFormat = "dd"
                    #if TESTING
                    let currentDay = "10"
                    #else
                    let currentDay = dateFormatter.string(from: current)
                    #endif
                    for e in self.eateries {
                        for oh in e.operatingHours {
                            dateFormatter.dateFormat = "yyyy-MM-dd"
                            let date = dateFormatter.date(from: oh.date)
                            dateFormatter.dateFormat = "dd"
                            dateFormatter.string(from: date!)
                            
                            if currentDay == dateFormatter.string(from: date!) {
                                for i in 0..<allEateries.count {
                                    if e.id == allEateries[i].id {
                                        allEateries[i].events = oh.events
                                    }
                                }
                            }
                        }
                    }
                    self.listVC!.tableView.reloadData()
                }
            })
            lastMainAPILoad = current
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func controlDidChange(_ sender: NSSegmentedControl) {
        if controlIsLocation {
            listVC!.changeLocation(location: sender.selectedSegment)
            savedLocation = sender.selectedSegment
        } else {
            infoVC?.changeMeal(to: sender.selectedSegment)
        }
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        guard let tabViewController = segue.destinationController
          as? NSTabViewController else { return }
        tabVC = tabViewController
        listVC = tabViewController.tabViewItems[0].viewController as? ListViewController
        infoVC = tabViewController.tabViewItems[1].viewController as? InfoViewController
    }
    
    @objc func showEateryInfo(notification: Notification) {
        controlIsLocation = false
        infoButton.isHidden = true
        let name = notification.object as! String
        
        // Set eatery display name
        var shortName = ""
        if name.contains("House") {
            shortName = name.components(separatedBy: " ").first!
        } else {
            shortName = name
        }
        titleField.stringValue = shortName
        
        let events = allEateries.filter({ $0.name == name })[0].events
        
        mainControl.segmentDistribution = .fit
        
        mainControl.setLabel("Breakfast", forSegment: 0)
        mainControl.setLabel("Lunch", forSegment: 1)
        mainControl.setLabel("Dinner", forSegment: 2)
        
        var selected = getSelectedSegment(events: events)
        
        if selected == -1 {
            for i in 0..<3 { mainControl.setSelected(false, forSegment: i) }
            for i in 0..<3 { mainControl.setEnabled(false, forSegment: i) }
        } else {
            let meals = events.map({ $0.descr })
            
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
            mainControl.setSelected(true, forSegment: selected)
        }
        
        infoVC?.updateInfo(events: events)
        tabVC?.transition(from: listVC!, to: infoVC!, options: .slideLeft)
    }
    
    // TODO: fix
    func getSelectedSegment(events: [Event]) -> Int {
        #if TESTING
        let current = 1686444300
        #else
        let current = Int(Date().timeIntervalSince1970)
        #endif
        
        if events.count == 0 {
            return -1
        }
        var eventNames: [String] = []
        for i in 0..<events.count {
            eventNames.append(events[i].descr)
            if current < events[i].endTimestamp {
                return i
            }
        }
        
        // Handle multiple events with the same name (e.g. Morrison's two lunches)
        if eventNames.count != Set(eventNames).count {
            return events.count - abs(eventNames.count - Set(eventNames).count) - 1
        }
        return events.count - 1
    }
    
    @objc func showEateryList(notification: Notification) {
        controlIsLocation = true
        infoButton.isHidden = false
        titleField.stringValue = "All Eateries"
        
        mainControl.segmentDistribution = .fillEqually
        
        mainControl.setLabel("West", forSegment: 0)
        mainControl.setLabel("Central", forSegment: 1)
        mainControl.setLabel("North", forSegment: 2)
        
        for i in 0..<3 { mainControl.setEnabled(true, forSegment: i) }
        
        mainControl.setSelected(true, forSegment: savedLocation)
        
        tabVC?.transition(from: infoVC!, to: listVC!, options: .slideRight)
    }
    
    @objc func quitApp() {
        NSApp.terminate(self)
    }
    
    @objc func showAboutPanel() {
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        appDelegate.closePopover(nil)
        NSApplication.shared.activate(ignoringOtherApps: true)
        NSApplication.shared.orderFrontStandardAboutPanel()
    }
    
    @objc func toggleLaunchAtLogin(_ sender: NSMenuItem) {
        if LaunchAtLogin.isEnabled {
            sender.state = .off
        } else {
            sender.state = .on
        }
        LaunchAtLogin.isEnabled.toggle()
    }
    
    @IBAction func infoButtonPressed(_ sender: NSButton) {
        let infoMenu = NSMenu()
        infoMenu.addItem(withTitle: "About Big Red Dining", action: #selector(showAboutPanel), keyEquivalent: "")
        
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        
        let checkForUpdatesItem = NSMenuItem()
        checkForUpdatesItem.title = "Check for Updates..."
        checkForUpdatesItem.target = appDelegate.updaterController
        checkForUpdatesItem.action = #selector(SPUStandardUpdaterController.checkForUpdates(_:))
        
        infoMenu.addItem(checkForUpdatesItem)
        infoMenu.addItem(NSMenuItem.separator())
        
        let launchAtLoginItem = NSMenuItem(title: "Launch at login", action: #selector(toggleLaunchAtLogin), keyEquivalent: "")
        if LaunchAtLogin.isEnabled {
            launchAtLoginItem.state = .on
        } else {
            launchAtLoginItem.state = .off
        }
        infoMenu.addItem(launchAtLoginItem)
        
        infoMenu.addItem(NSMenuItem.separator())
        infoMenu.addItem(withTitle: "Quit Big Red Dining", action: #selector(quitApp), keyEquivalent: "q")
        
        let p = NSPoint(x: -110, y: sender.frame.height+15)
        infoMenu.popUp(positioning: nil, at: p, in: sender)
    }
}

extension ViewController {
    static func newController() -> ViewController {
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let identifier = NSStoryboard.SceneIdentifier("ViewController")
        guard let vc = storyboard.instantiateController(withIdentifier: identifier) as? ViewController else {
          fatalError("Nah")
        }
        return vc
    }
}
