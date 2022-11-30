//
//  Logger.swift
//  Rendeer
//
//  Created by Axel Boberg on 2021-04-17.
//

import Foundation

let MAX_STORED_ENTRIES_N: Int = 150

struct RLoggerEntry {
    enum LoggerEntryType {
        case log
        case error
    }
    
    var timestamp: Date = Date()
    var type: LoggerEntryType
    var flag: Bool
    var msg: String
}

protocol RLoggerDelegate {
    func RLogger(onEntry entry: RLoggerEntry)
}

class RLogger {
    private static var _main: RLogger = RLogger()
    static var main: RLogger {
        get { return _main }
    }
    
    var delegate: RLoggerDelegate?
    var entries = [RLoggerEntry]()
    
    /**
     Log a standard message
     - parameters:
        - msg: A message to log
        - flag: A boolean indicating wether to flag the entry
     */
    func log (_ msg: String, flag: Bool = false) {
        let entry = RLoggerEntry(type: .log, flag: flag, msg: msg)
        self.addEntry(entry)
    }
    
    /**
     Log an error
     - parameters:
        - msg: A message to log
        - flag: A boolean indicating wether to flag the entry
     */
    func error (_ msg: String, flag: Bool = false) {
        let entry = RLoggerEntry(type: .error, flag: flag, msg: msg)
        self.addEntry(entry)
    }
    
    /**
     An alias for log()
     - parameters:
        - msg: A message to log
        - flag: A boolean indicating wether to flag the entry
     */
    func info(_ msg: String, flag: Bool = false) {
        self.log(msg, flag: flag)
    }
    
    private func addEntry (_ entry: RLoggerEntry) {
        self.entries.append(entry)
        if self.entries.count > MAX_STORED_ENTRIES_N {
            self.entries.removeFirst()
        }
        self.delegate?.RLogger(onEntry: entry)
    }
}
