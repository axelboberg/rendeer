//
//  AMCPServer.swift
//
//
//  Created by Axel Boberg on 2021-01-22.
//

import Network
import os
import WebKit

@available(iOS 12.0, *)
@available(OSX 10.14, *)
@available(macCatalyst 13.0, *)

typealias AMCPConnection = NWConnection

/**
 Declare the maximum size of TCP-messages
 to parse as a message in bytes
 */
let MTU = 65535

class AMCPServer {
    private let logger = RLogger.main
    
    private var listener: NWListener
    private let port: NWEndpoint.Port
    
    /**
     A delegate for receiving callbacks
     for events related to this server
     */
    public var delegate: AMCPServerDelegate?
    
    /**
     Create a new AMCPServer
     for a specified port
     - parameters:
        - port: The port that this server should listen on
     */
    init(_ port: UInt16) {
        self.port = NWEndpoint.Port(rawValue: port)!
        
        let params = NWParameters.tcp
        params.allowLocalEndpointReuse = true
        self.listener = try! NWListener(using: .tcp, on: self.port)
    }
    
    /**
     Start listening for incoming packets
     */
    func listen () {
        self.listener.newConnectionHandler = self.onConnection(_:)
        self.listener.stateUpdateHandler = self.onStateChange(to:)
        self.listener.start(queue: .main)
    }
    
    /**
     Cancel the listener and
     all current connections
     */
    func cancel () {
        self.listener.cancel()
    }
    
    private func onConnection (_ conn: NWConnection) {
        self.recieve(conn)
        conn.start(queue: .main)
    }

    private func onStateChange (to state: NWListener.State) {
        switch (state) {
        case .ready:
            self.logger.info("[AMCP] Listening on port \(self.port.rawValue)", flag: true)
            break
        case .failed(_):
            self.logger.info("[AMCP] Server failed, restarting...", flag: true)
            self.cancel()
            self.listen()
            break
        default:
            break
        }
    }
    
    /**
     Listen and handle incoming data on a connection,
     will try to parse messages as AMCP commands
     - parameters:
        - conn: An NWConnection to listen for incoming data on
     */
    private func recieve (_ conn: NWConnection) {
        if conn.state == .cancelled {
            return
        }
        
        conn.receive(minimumIncompleteLength: 1, maximumLength: MTU) { (data, ctx, isComplete, err) in
            if let data = data, !data.isEmpty {
                guard let message = String(data: data, encoding: .utf8) else { return }
                guard let command = AMCPCommand.parse(message) else { return }

                self.delegate?.amcp(didReceiveCommand: command)
                
                let res = "200 \(command.name) OK"
                conn.send(content: res.data(using: .utf8), completion: .idempotent)
                
                self.recieve(conn)
            }
        }
    }
    
    deinit {
        self.cancel()
    }
}
