//
//  ViewController.swift
//  DiningBar
//
//  Created by Cameron Goddard on 12/17/22.
//

import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet weak var titleField: NSTextField!
    @IBOutlet weak var locationControl: NSSegmentedControl!
    
    var tabVC: NSTabViewController?
    var listVC: ListViewController?
    var infoVC: InfoViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.showEateryInfo(notification:)), name: Notification.Name("ShowInfo"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.showEateryList(notification:)), name: Notification.Name("ShowList"), object: nil)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func locationDidChange(_ sender: NSSegmentedControl) {
        listVC!.changeLocation(location: sender.selectedSegment)
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        guard let tabViewController = segue.destinationController
          as? NSTabViewController else { return }
        
        tabVC = tabViewController
        listVC = tabViewController.tabViewItems[0].viewController as? ListViewController
        infoVC = tabViewController.tabViewItems[1].viewController as? InfoViewController
    }
    
    @objc func showEateryInfo(notification: Notification) {
        print(notification)
        titleField.stringValue = notification.userInfo!.values.first! as! String
        
        locationControl.segmentDistribution = .fit
        
        locationControl.setLabel("Breakfast", forSegment: 0)
        locationControl.setLabel("Lunch", forSegment: 1)
        locationControl.setLabel("Dinner", forSegment: 2)
        
        infoVC?.updateInfo(name: notification.userInfo!.values.first! as! String)
        
        tabVC?.transition(from: listVC!, to: infoVC!, options: .slideLeft)
    }
    
    @objc func showEateryList(notification: Notification) {
        titleField.stringValue = "DiningBar"
        
        locationControl.segmentDistribution = .fillEqually
        
        locationControl.setLabel("West", forSegment: 0)
        locationControl.setLabel("Central", forSegment: 1)
        locationControl.setLabel("North", forSegment: 2)
        
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
