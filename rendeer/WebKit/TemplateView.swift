//
//  RDWebView.swift
//  MetalTest
//
//  Created by Axel Boberg on 2021-01-20.
//

import Foundation
import WebKit
import os
import AppKit

typealias TemplateViewExecutionCompletion = (Any?, Error?) -> Void

class TemplateView: NSView, WKNavigationDelegate {
    let logger = Logger()
    var webview: WKWebView?
    
    var onLoadCompletion: (() -> Void)?
    
    /**
     Create a new TemplateView
     for rendering an HTML template
     */
    init (width: CGFloat, height: CGFloat) {
        let frame = NSRect(x: 0, y: 0, width: width, height: height)
        super.init(frame: frame)
        
        let config = WKWebViewConfiguration()
            config.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
            config.preferences.setValue(true, forKey: "developerExtrasEnabled")
            config.preferences.setValue(true, forKey: "standalone")
            config.preferences.setValue(true, forKey: "peerConnectionEnabled")
            config.userContentController.add(self, name: "nativeHandler")
            config.mediaTypesRequiringUserActionForPlayback = []
        
        self.webview = WKWebView(frame: frame, configuration: config)
        self.webview?.navigationDelegate = self
        self.webview?.setValue(false, forKey: "drawsBackground")
        
        self.layer = CALayer()
        self.webview?.layer = CALayer()
        
        self.layer?.anchorPoint = CGPoint(x: 0, y: 0)
        self.webview?.layer?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        self.addSubview(self.webview!)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setDisplaySize (width: CGFloat, height: CGFloat) {
        let contentWidth = self.webview!.frame.width
        let contentHeight = self.webview!.frame.height
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(0)
        self.layer?.transform = CATransform3DMakeScale(width / contentWidth, height / contentHeight, 1)
        CATransaction.commit()
    }
    
    /**
     Load a local or remote file from a url
     - parameters:
        - url: A url to load, either local or remote
     */
    func load (url: String) {
        self.logger.info("[Template] Loading \(url)")
        if url.hasPrefix("http") {
            let _url = URL(string: url)!
            let request = URLRequest(url: _url)
            self.webview!.load(request)
        } else {
            let _url = URL(fileURLWithPath: url)
            self.webview!.loadFileURL(_url, allowingReadAccessTo: _url.deletingLastPathComponent())
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.onLoadCompletion?()
        self.onLoadCompletion = nil
    }
    
    func load (url: String, completion: @escaping () -> Void) {
        self.onLoadCompletion = completion
        self.load(url: url)
    }
    
    func play () {
        self.play { (_, _) in }
    }
    
    func play (completion: @escaping TemplateViewExecutionCompletion) {
        self.logger.info("[Template] Calling window.play()")
        self.webview!.evaluateJavaScript("""
            const fns = [
                "log",
                "info",
                "warn",
                "error"
            ]

            for (fn of fns) {
                window.console[fn] = (...args) => {
                    window.webkit.messageHandlers.nativeHandler.postMessage({
                        call: "console." + fn,
                        conc: args.join(" "),
                        args: args
                    })
                }
            }
        """, completionHandler: nil)
        self.webview!.evaluateJavaScript("window.play()", completionHandler: completion)
    }
    
    func stop () {
        self.stop { (_, _) in }
    }
    
    func stop (completion: @escaping TemplateViewExecutionCompletion) {
        self.logger.info("[Template] Calling window.stop()")
        self.webview!.evaluateJavaScript("window.stop()", completionHandler: completion)
    }
    
    func update (with data: String) {
        self.update(with: data) { (_, err) in
            if err != nil {
                self.logger.warning("[Template] \(err.debugDescription)")
            }
        }
    }
    
    func update (with data: String, completion: @escaping TemplateViewExecutionCompletion) {
        self.logger.info("[Template] Calling window.update()")
        self.webview?.evaluateJavaScript("window.update(\(data))", completionHandler: completion)
    }
    
    func clear () {
        self.logger.info("[Template] Clearing view")
        self.webview?.loadHTMLString("<html></html>", baseURL: nil)
    }
}

extension TemplateView: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let data = message.body as? [String: Any] else { return }
        self.logger.debug("[Template] \(data["conc"] as! String)")
    }
}
