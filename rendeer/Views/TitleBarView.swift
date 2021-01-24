//
//  TitleBarView.swift
//  rendeer
//
//  Created by Axel Boberg on 2021-01-22.
//

import UIKit

class TitleBarView: UIView {
    @IBOutlet weak var rootView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
    
    func setup() {
        Bundle.main.loadNibNamed("TitleBarView", owner: self, options: nil)
        self.rootView.autoresizingMask = [.flexibleWidth]
        self.rootView.translatesAutoresizingMaskIntoConstraints = true
        self.addSubview(rootView)
        
        NotificationCenter.default.addObserver(forName: .init("NSWindowDidBecomeMainNotification"), object: nil, queue: nil) { (notif) in
            self.rootView.isHidden = false
        }
        
        NotificationCenter.default.addObserver(forName: .init("NSWindowDidResignMainNotification"), object: nil, queue: nil) { (notif) in
            self.rootView.isHidden = true
        }
        
        NotificationCenter.default.addObserver(forName: .init("NSWindowWillEnterFullScreenNotification"), object: nil, queue: nil) { (notif) in
            self.rootView.isHidden = true
        }
        
        NotificationCenter.default.addObserver(forName: .init("NSWindowWillExitFullScreenNotification"), object: nil, queue: nil) { (notif) in
            self.rootView.isHidden = false
        }
    }
    
    func setTitle(_ title: String) {
        self.titleLabel.text = title
    }
}
