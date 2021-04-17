//
//  AppDelegate.swift
//  rendeer-mac
//
//  Created by Axel Boberg on 2021-01-24.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var consoleWindowController: NSWindowController?
    
    @IBAction func onOpenConsole(_ sender: Any) {
        if self.consoleWindowController != nil { return }
        self.consoleWindowController = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "ConsoleWindowController") as! NSWindowController
        self.consoleWindowController?.showWindow(self)
        self.consoleWindowController?.window?.delegate = self
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}

extension AppDelegate: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        self.consoleWindowController = nil
    }
}
