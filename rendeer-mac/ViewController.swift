//
//  ViewController.swift
//  rendeer-mac
//
//  Created by Axel Boberg on 2021-01-24.
//

import Cocoa

class ViewController: NSViewController, AMCPServerDelegate {
    var template: TemplateView = TemplateView(width: 1920, height: 1080)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let amcpServer = AMCPServer(5000)
            amcpServer.delegate = self
        
        try? amcpServer.listen()
        
        self.view.addSubview(self.template)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    override func viewWillLayout() {
        let bounds = self.view.bounds
        self.template.setDisplaySize(width: bounds.width, height: bounds.height)
        
        self.view.window?.title = "\(Int(bounds.width))x\(Int(bounds.height))"
    }

    func amcp(didReceiveCommand command: AMCPCommand) {
        let cmd: String = {
            if command.name == "CG" { return command.tokens[2] }
            return command.name
        }()
        
        switch cmd {
        case "ADD":
            self.template.clear()
            self.template.load(url: command.tokens[4].replacingOccurrences(of: "\"", with: "")) {
                self.template.update(with: command.tokens.last ?? "")
                if command.tokens[5] == "1" { self.template.play() }
            }
            return
        case "PLAY":
            self.template.play()
            return
        case "REMOVE",
             "CLEAR",
             "STOP":
            self.template.stop()
            self.template.clear()
            return
        case "UPDATE":
            if command.tokens.last != "UPDATE" {
                self.template.update(with: command.tokens.last ?? "")
            } else {
                self.template.update(with: "")
            }
            return
        default:
            return
        }
    }
}

