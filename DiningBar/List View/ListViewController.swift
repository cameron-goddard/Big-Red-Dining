//
//  ListViewController.swift
//  DiningBar
//
//  Created by Cameron Goddard on 12/18/22.
//

import Cocoa

class ListViewController: NSViewController {
    
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
    
    func changeLocation(location: Int) {
        switch location {
        case 0:
            currentEateries = westEateries
        case 1:
            currentEateries = centralEateries
        default:
            currentEateries = northEateries
        }
        tableView.reloadData()
    }
}

extension ListViewController: NSTableViewDataSource {

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

extension ListViewController: NSTableViewDelegate {

    func tableViewSelectionDidChange(_ notification: Notification) {
        let row = tableView.selectedRow
        tableView.deselectRow(row)
        if row != -1 {
            NotificationCenter.default.post(name: Notification.Name("ShowInfo"), object: "test", userInfo: ["row": currentEateries[row].0])
        }
    }
}
