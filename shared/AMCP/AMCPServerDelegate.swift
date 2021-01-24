//
//  AMCPServerDelegate.swift
//
//
//  Created by Axel Boberg on 2021-01-22.
//

import Foundation
import Network

@available(iOS 12.0, *)
@available(OSX 10.14, *)
@available(macCatalyst 13.0, *)

protocol AMCPServerDelegate {
    func amcp(didReceiveCommand command: AMCPCommand)
}
