//
//  ViewController.swift
//  rendeer-mac
//
//  Created by Axel Boberg on 2021-01-24.
//

import Cocoa

class RendererViewController: NSViewController {
    var template: TemplateView?
    var channel: Int = 0 {
        didSet {
            self.updateTitle()
        }
    }
    
    var url: String?
    var width: CGFloat = 1920
    var height: CGFloat = 1080
    
    override func viewDidLoad() {
        super.viewDidLoad()

        /*
         Do the initial setup
         of the template view
         */
        self.template = TemplateView(width: self.width, height: self.height)
        if self.url != nil {
            self.template?.load(url: self.url!)
        }
        
        self.view.addSubview(self.template!)
    }
    
    private func updateTitle () {
        let bounds = self.view.bounds
        self.template?.setDisplaySize(width: bounds.width, height: bounds.height)
        
        self.view.window?.title = "\(Int(bounds.width))x\(Int(bounds.height)) [\(self.channel)]"
    }
    
    override func viewWillLayout() {
        self.updateTitle()
    }
}

