//
//  ConsoleView.swift
//  Rendeer
//
//  Created by Axel Boberg on 2021-04-17.
//

import AppKit
import WebKit

class ConsoleView: NSView, RLoggerDelegate, WKNavigationDelegate {
    @IBOutlet var root: ConsoleView!
    @IBOutlet weak var webview: WKWebView!
    
    var logger: RLogger?
    
    func follow (_ logger: RLogger) {
        self.logger = logger
        self.logger?.delegate = self
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
    
    private func setup () {
        Bundle.main.loadNibNamed("ConsoleView", owner: self, topLevelObjects: nil)
        self.root.frame = bounds
        self.addSubview(root)
        
        self.webview.navigationDelegate = self
        
        guard let url = Bundle.main.url(forResource: "ConsoleView", withExtension: "html") else {
            print("Did not find console view html")
            return
        }
        self.webview.loadFileURL(url, allowingReadAccessTo: url)
        let request = URLRequest(url: url)
        self.webview.load(request)
    }
    
    func RLogger(onEntry: RLoggerEntry) {
        self.showEntry(onEntry)
    }
    
    func showEntry (_ entry: RLoggerEntry) {
        self.webview.evaluateJavaScript("""
            window.addEntry('\(entry.timestamp)', '\(entry.type)', '\(entry.msg)', \(entry.flag))
        """) { (res, err) in
            if err != nil { print(err.debugDescription) }
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.logger?.entries.forEach({ (entry) in
            self.showEntry(entry)
        })
    }
}
