//
//  ViewController.swift
//  DiningBar
//
//  Created by Cameron Goddard on 12/17/22.
//

import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet weak var locationControl: NSSegmentedControl!
    @IBOutlet weak var tableView: NSTableView!
    
    let northEateries = [("Morrison", "text.book.closed"), ("North Star", "moon.stars.fill"), ("Risley", "theatermasks")]
    let westEateries = [("104West!", "fork.knife"), ("Becker House", "books.vertical"), ("Bethe House", "atom"), ("Cook House", "hammer"), ("Keeton House", "pawprint.fill"), ("Rose House", "lightbulb")]
    let centralEateries = [("Okenshields", "crown")]
    
    var currentEateries : [(String, String)] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = .clear
        currentEateries = westEateries
        

    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


    @IBAction func locationDidChange(_ sender: NSSegmentedControl) {
        switch sender.selectedSegment {
        case 0:
            currentEateries = westEateries
        case 1:
            currentEateries = centralEateries
        default:
            currentEateries = northEateries
        }
        self.tableView.reloadData()
    }
}

extension ViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return currentEateries.count
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let eateryCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "eateryCell"), owner: self) as? EateryCell else { return nil }
        
        eateryCell.name.stringValue = currentEateries[row].0
        eateryCell.icon.image = NSImage(systemSymbolName: currentEateries[row].1, accessibilityDescription: nil)
        
        return eateryCell
    }
    
}

extension ViewController: NSTableViewDelegate {
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        
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



