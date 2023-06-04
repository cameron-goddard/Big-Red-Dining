//
//  AppDelegate.swift
//  Big Red Dining
//
//  Created by Cameron Goddard on 12/17/22.
//

import Cocoa
import Sparkle

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.variableLength)
    let popover = NSPopover()
    
    var positioningView: NSView?
    var eventMonitor: EventMonitor?
    
    let updaterController: SPUStandardUpdaterController

    override init() {
        updaterController = SPUStandardUpdaterController(startingUpdater: true, updaterDelegate: nil, userDriverDelegate: nil)
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        if let button = statusItem.button {
            let statusImage = NSImage(systemSymbolName: "fork.knife", accessibilityDescription: nil)
            statusImage?.isTemplate = true
            button.image = statusImage
            button.action = #selector(AppDelegate.togglePopover(_:))
        }
        popover.contentViewController = ViewController.newController()
        
        eventMonitor = EventMonitor(mask: [NSEvent.EventTypeMask.leftMouseDown, NSEvent.EventTypeMask.rightMouseDown]) { [weak self] event in
            if let popover = self?.popover {
                if popover.isShown {
                    self?.closePopover(event)
                }
            }
        }
        eventMonitor?.start()
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
        
        popover.show(relativeTo: positioningView.bounds, of: positioningView, preferredEdge: .maxY)
        eventMonitor?.start()
    }
    
    func closePopover(_ sender: AnyObject?) {
        let positioningView = statusItem.button?.subviews.first {
            $0.identifier == NSUserInterfaceItemIdentifier(rawValue: "positioningView")
        }
        positioningView?.removeFromSuperview()
        eventMonitor?.stop()
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }


}

