//
//  ConsoleViewController.swift
//  Rendeer
//
//  Created by Axel Boberg on 2021-04-17.
//

import Cocoa

class ConsoleViewController: NSViewController {
    override func viewDidLoad() {
        guard let console = self.view as? ConsoleView else { return }
        console.follow(RLogger.main)
    }
}
