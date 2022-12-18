//
//  AppDelegate.swift
//  DiningBar
//
//  Created by Cameron Goddard on 12/17/22.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.variableLength)
    let popover = NSPopover()
    var positioningView: NSView?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if let button = statusItem.button {
            let statusImage = NSImage(systemSymbolName: "fork.knife", accessibilityDescription: nil)
            statusImage?.isTemplate = true
            button.image = statusImage
            button.action = #selector(AppDelegate.togglePopover(_:))
        }
        popover.contentViewController = ViewController.newController()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    @objc func togglePopover(_ sender: NSButton) {
        if popover.isShown {
            closePopover(sender)
        } else {
            openPopover(sender)
        }
    }
    
    func openPopover(_ sender: NSButton) {
        let positioningView = NSView(frame: sender.bounds)
        positioningView.identifier = NSUserInterfaceItemIdentifier(rawValue: "positioningView")
        sender.addSubview(positioningView)
        
        popover.animates = false
        popover.show(relativeTo: positioningView.bounds, of: positioningView, preferredEdge: .maxY)
        
        sender.bounds = sender.bounds.offsetBy(dx: 0, dy: sender.bounds.height)
        if let popoverWindow = popover.contentViewController?.view.window {
            popoverWindow.setFrame(popoverWindow.frame.offsetBy(dx: 0, dy: 13), display: false)
        }
    }
    
    func closePopover(_ sender: NSButton) {
        let positioningView = statusItem.button?.subviews.first {
            $0.identifier == NSUserInterfaceItemIdentifier(rawValue: "positioningView")
        }
        positioningView?.removeFromSuperview()
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }


}

