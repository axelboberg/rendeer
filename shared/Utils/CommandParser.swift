//
//  CommandParser.swift
//
//
//  Created by Axel Boberg on 2021-01-25.
//

import Foundation
class CommandParser {
    static func parse () -> [String: Any] {
        let args = CommandLine.arguments
        var out = [String: Any]()
        
        for var i in 0...args.count {
            if args.count == i { break }
            if !self.isArgument(args[i]) { continue }
            
            out[args[i]] = args[i + 1]
            i += 1
        }
        return out
    }
    
    private static func isArgument (_ str: String) -> Bool {
        return str.hasPrefix("--") ||
               str.hasPrefix("-")
    }
}
