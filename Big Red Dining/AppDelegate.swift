//
//  AppDelegate.swift
//  Big Red Dining
//
//  Created by Cameron Goddard on 12/17/22.
//

import Cocoa

@main
@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
    
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let popover = NSPopover()
    
    private var positioningView: NSView?
    private var eventMonitor: EventMonitor?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Set up the status bar button
        if let button = statusItem.button {
            let statusImage = NSImage(systemSymbolName: "fork.knife", accessibilityDescription: nil)
            statusImage?.isTemplate = true
            button.image = statusImage
            button.action = #selector(AppDelegate.togglePopover(_:))
        }
        popover.contentViewController = ViewController.newController()

        // Handle closing the popover when the user clicks away
        eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            guard let self, self.popover.isShown else { return }
            self.closePopover()
        }
        eventMonitor?.start()
    }
    
    /// Toggles the popover's visibility.
    /// - Parameter sender: The status bar button that triggered the action
    @objc func togglePopover(_ sender: NSButton) {
        if popover.isShown {
            closePopover()
        } else {
            openPopover(sender)
        }
    }
    
    /// Opens the popover.
    /// - Parameter sender: The status bar button that triggered the action
    func openPopover(_ sender: NSButton) {
        let view = NSView(frame: sender.bounds)
        sender.addSubview(view)
        self.positioningView = view

        popover.show(relativeTo: view.bounds, of: view, preferredEdge: .maxY)
        popover.contentViewController?.view.window?.makeKeyAndOrderFront(nil)

        NSApp.activate(ignoringOtherApps: true)

        eventMonitor?.start()
    }
    
    /// Closes the popover.
    func closePopover() {
        positioningView?.removeFromSuperview()
        positioningView = nil
        popover.performClose(nil)

        eventMonitor?.stop()
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}
