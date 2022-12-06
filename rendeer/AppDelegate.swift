//
//  AppDelegate.swift
//  rendeer-mac
//
//  Created by Axel Boberg on 2021-01-24.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate, AMCPServerDelegate {
    var consoleWindowController: NSWindowController?
    var renderWindowControllers: [(Int, NSWindowController)] = []
    
    let logger = RLogger.main
    
    /*
     Initialize the application state
     with default parameters
     */
    var state = ApplicationState(url: nil, width: 1920, height: 1080, amcpPort: 5250)
    
    @IBAction func onOpenConsole(_ sender: Any) {
        if self.consoleWindowController != nil { return }
        self.consoleWindowController = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "ConsoleWindowController") as! NSWindowController
        self.consoleWindowController?.showWindow(self)
        self.consoleWindowController?.window?.delegate = self
    }
    
    @IBAction func onOpenRenderer(_ sender: Any) {
        self.openNewRenderer()
    }
    
    /*
     Close the currently active window,
     no matter if it is a renderer or a console
     */
    @IBAction func onCloseWindow(_ sender: Any) {
        for controller in self.renderWindowControllers {
            if controller.1.window == nil {
                continue
            }
            if controller.1.window!.isMainWindow {
                controller.1.close()
                
                /*
                 Remove the reference
                 to the controller
                 */
                self.renderWindowControllers.removeAll { _controller in
                    return _controller.0 == controller.0
                }
                return
            }
        }
        
        if self.consoleWindowController?.window != nil && self.consoleWindowController!.window!.isMainWindow {
            self.consoleWindowController!.close()
        }
    }
    
    /**
     Calculate a new channel number,
     used for referencing newly opened channels
     - returns: An integer representing a new channel
     */
    private func getFirstEmptyChannel () -> Int {
        var channel = 0
        for window in self.renderWindowControllers {
            if window.0 > channel {
                channel = window.0
            }
        }
        return channel + 1
    }
    
    /**
     Open a new renderer window
     */
    private func openNewRenderer () {
        let channel = self.getFirstEmptyChannel()
        
        let window = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "RendererWindowController") as! NSWindowController
        window.showWindow(self)
        
        if let rendererViewController = window.contentViewController as? RendererViewController {
            rendererViewController.channel = channel
            rendererViewController.url = self.state.url
            rendererViewController.width = self.state.width
            rendererViewController.height = self.state.height
        }
        
        self.renderWindowControllers.append((channel, window))
        self.logger.log("Initialized")
    }
    
    /**
     Parse the runtime arguments
     as a new application state
     */
    private func parseArgumentsAsState () {
        let commands = CommandParser.parse()
        
        let url = commands["--url"] as? String
        let width = NumberFormatter().number(from: commands["--width"] as? String ?? "") as? CGFloat ?? 1920
        let height = NumberFormatter().number(from: commands["--height"] as? String ?? "") as? CGFloat ?? 1080
        let amcpPort = NumberFormatter().number(from: commands["--amcp-port"] as? String ?? "") ?? 5250
        
        self.state = ApplicationState(url: url, width: width, height: height, amcpPort: amcpPort)
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        self.parseArgumentsAsState()
        
        /*
         Setup a new AMCP server
         to listen on startup,
         the same server is used for
         all renderer windows
         */
        let amcpServer = AMCPServer(UInt16(truncating: self.state.amcpPort))
            amcpServer.delegate = self
        
        amcpServer.listen()
        self.openNewRenderer()
    }

    func applicationWillTerminate(_ aNotification: Notification) {}
    
    /**
     Get a window by its channel number
     - returns: The window controller rendering the channel number
     */
    func getWindowForChannel (_ channel: Int) -> NSWindowController? {
        for window in self.renderWindowControllers {
            if window.0 == channel {
                return window.1
            }
        }
        return nil
    }
    
    /**
     Handle AMCP commands and forward
     them to the correct renderer window
     */
    func amcp(didReceiveCommand command: AMCPCommand) {
        let cmd: String = {
            if command.name == "CG" { return command.tokens[2] }
            return command.name
        }()
        
        guard let window = self.getWindowForChannel(command.channel) else {
            return
        }
        
        guard let controller = window.contentViewController as? RendererViewController else {
            return
        }
        
        switch cmd {
        case "ADD":
            controller.template?.clear()
            controller.template?.load(url: command.tokens[4].replacingOccurrences(of: "\"", with: "")) {
                controller.template?.update(with: command.tokens.last ?? "")
                if command.tokens[5] == "1" { controller.template?.play() }
            }
            return
        case "PLAY":
            controller.template?.play()
            return
        case "STOP":
            controller.template?.stop()
            return
        case "REMOVE",
             "CLEAR":
            controller.template?.stop()
            controller.template?.clear()
            return
        case "UPDATE":
            if command.tokens.last != "UPDATE" {
                controller.template?.update(with: command.tokens.last ?? "")
            } else {
                controller.template?.update(with: "")
            }
            return
        default:
            return
        }
    }
}

extension AppDelegate: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        self.consoleWindowController = nil
    }
}
