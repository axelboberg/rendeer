//
//  ViewController.swift
//  rendeer
//
//  Created by Axel Boberg on 2021-01-21.
//

import UIKit

class ViewController: UIViewController, AMCPServerDelegate {
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
    
    @IBOutlet weak var titleBarView: TitleBarView!
    
    var template: TemplateView = TemplateView(width: 1920, height: 1080)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let amcpServer = AMCPServer(5000)
            amcpServer.delegate = self
            amcpServer.listen()
        
        self.view.insertSubview(self.template, belowSubview: self.titleBarView)
        self.template.frame = self.view.frame
    }
    
    @IBAction func setPreset1080 (_ sender: UICommand) {
        
    }

    @IBAction func setPreset720 (_ sender: UICommand) {

    }
    
    override func viewWillLayoutSubviews() {
        let bounds = self.view.bounds
        self.template.setDisplaySize(width: bounds.width, height: bounds.height)
        
        self.titleBarView.setTitle("\(Int(bounds.width)) x \(Int(bounds.height))")
    }
}
