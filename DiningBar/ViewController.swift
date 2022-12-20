//
//  ViewController.swift
//  DiningBar
//
//  Created by Cameron Goddard on 12/17/22.
//

import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet weak var titleField: NSTextField!
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
        
        if dateFormatter.string(from: current) != dateFormatter.string(from: lastMainAPILoad) {
            NetworkManager.getEateryInfo(completion: { json, error in
                for eatery in json!.data["eateries"]! {
                    if self.allowedEateries.contains(eatery.id) {
                        self.eateries.append(eatery)
                    }
                }
                DispatchQueue.main.async {
                    dateFormatter.dateFormat = "dd"
                    let currentDay = dateFormatter.string(from: Date())
                    
                    for e in self.eateries {
                        for oh in e.operatingHours {
                            dateFormatter.dateFormat = "yyyy-MM-dd"
                            let date = dateFormatter.date(from: oh.date)
                            dateFormatter.dateFormat = "dd"
                            if currentDay == dateFormatter.string(from: date!) {
                                for i in 0..<allEateries.count {
                                    if e.id == allEateries[i].id {
                                        for event in oh.events {
                                            allEateries[i].events.append(event)
                                        }
                                    }
                                }
                            }
                        }
                    }
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
        titleField.stringValue = notification.object as! String
        
        
        mainControl.segmentDistribution = .fit
        
        mainControl.setLabel("Breakfast", forSegment: 0)
        mainControl.setLabel("Lunch", forSegment: 1)
        mainControl.setLabel("Dinner", forSegment: 2)
        
        infoVC?.updateInfo(name: notification.object as! String)
        
        tabVC?.transition(from: listVC!, to: infoVC!, options: .slideLeft, completionHandler: {
            
        })
    }
    
    @objc func showEateryList(notification: Notification) {
        controlIsLocation = true
        titleField.stringValue = "DiningBar"
        
        mainControl.segmentDistribution = .fillEqually
        
        mainControl.setLabel("West", forSegment: 0)
        mainControl.setLabel("Central", forSegment: 1)
        mainControl.setLabel("North", forSegment: 2)
        
        mainControl.setSelected(true, forSegment: savedLocation)
        
        tabVC?.transition(from: infoVC!, to: listVC!, options: .slideRight)
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
