//
//  EateryCell.swift
//  DiningBar
//
//  Created by Cameron Goddard on 12/18/22.
//

import Cocoa

class EateryCell: NSTableCellView {

    @IBOutlet weak var name: NSTextField!
    @IBOutlet weak var icon: NSImageView!
    @IBOutlet weak var status: NSButton!
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}
