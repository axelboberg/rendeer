//
//  ViewController.swift
//  rendeer-mac
//
//  Created by Axel Boberg on 2021-01-24.
//

import Cocoa

class ViewController: NSViewController, AMCPServerDelegate, RenderViewDelegate {
    func renderView(willDraw: Bool) {
        print("Will draw")
        
        let frame = self.template?.render()
        self.renderView?.backgroundImage = frame
        
        print(frame)
    }
    
    var template: TemplateView?
    var renderView: RenderView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let commands = CommandParser.parse()
        
        let url = commands["--url"] as? String
        let width = NumberFormatter().number(from: commands["--width"] as? String ?? "") as? CGFloat ?? 1920
        let height = NumberFormatter().number(from: commands["--height"] as? String ?? "") as? CGFloat ?? 1080
        let amcpPort = NumberFormatter().number(from: commands["--amcp-port"] as? String ?? "") ?? 5000
        
        self.template = TemplateView(width: CGFloat(width), height: CGFloat(height))
        if url != nil {
            self.template?.load(url: url!)
        }
        
        self.template?.load(url: "https://apple.com")
        
        let amcpServer = AMCPServer(UInt16(truncating: amcpPort))
            amcpServer.delegate = self
        
        amcpServer.listen()
        
        self.view.addSubview(self.template!)
        
        guard let device = MTLCreateSystemDefaultDevice() else { return }
        self.renderView = RenderView(frame: CGRect(x: 0, y: 0, width: 1920, height: 1080), device: device)
        self.renderView?.setup()
        
        self.renderView?.renderDelegate = self

        self.view.addSubview(self.renderView!)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    override func viewWillLayout() {
        let bounds = self.view.bounds
        self.template?.setDisplaySize(width: bounds.width, height: bounds.height)
        
        self.view.window?.title = "\(Int(bounds.width))x\(Int(bounds.height))"
    }

    func amcp(didReceiveCommand command: AMCPCommand) {
        let cmd: String = {
            if command.name == "CG" { return command.tokens[2] }
            return command.name
        }()
        
        switch cmd {
        case "ADD":
            self.template?.clear()
            self.template?.load(url: command.tokens[4].replacingOccurrences(of: "\"", with: "")) {
                self.template?.update(with: command.tokens.last ?? "")
                if command.tokens[5] == "1" { self.template?.play() }
            }
            return
        case "PLAY":
            self.template?.play()
            return
        case "STOP":
            self.template?.stop()
            return
        case "REMOVE",
             "CLEAR":
            self.template?.stop()
            self.template?.clear()
            return
        case "UPDATE":
            if command.tokens.last != "UPDATE" {
                self.template?.update(with: command.tokens.last ?? "")
            } else {
                self.template?.update(with: "")
            }
            return
        default:
            return
        }
    }
}

