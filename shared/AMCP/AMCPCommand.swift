//
//  AMCPCommand.swift
//  rendeer
//
//  Created by Axel Boberg on 2021-01-23.
//

import Foundation

typealias AMCPLayerDescriptor = (Int, Int)

struct AMCPCommand {
    let name: String
    let layer: Int
    let channel: Int
    let tokens: [String]
    
    /**
     Extract a touple describing the channel
     and layer for a command,
     returns -1 for missing values
     - parameters:
        - str: A string representing an AMCP command
     - returns: An AMCPLayerDescriptor containing the channel and layer
     */
    static func layerDescriptor (from str: String) -> AMCPLayerDescriptor {
        /*
         The pattern matches:
            - Two digits separated by a hyphen (e.g. 1-2 or 54-234)
            - Single digits
         */
        let rex = try! NSRegularExpression(pattern: #"(\d+)\-(\d+)|\d+"#, options: .init())

        guard let match = rex.firstMatch(
                in: str,
                options: .init(),
                range: NSRange(location: 0, length: str.count)
        ) else { return (-1, -1) }
        
        let str = NSString(string: str).substring(with: match.range)
        let parts = str.split(separator: "-")
        
        if parts.count == 0 { return (-1, -1) }
        if parts.count == 1 { return (Int(parts[0]) ?? -1, -1) }
        return (Int(parts[0]) ?? -1, Int(parts[1]) ?? -1)
    }
    
    /**
     Parse a string as an AMCP command
     - parameters:
        - str: A string to parse
     - returns: An AMCP command
     */
    static func parse (_ str: String) -> AMCPCommand {
        let tokens = tokenize(str)
        let (channel, layer) = AMCPCommand.layerDescriptor(from: str)
        return AMCPCommand(name: tokens[0], layer: layer, channel: channel, tokens: tokens)
    }
    
    /**
     Tokenize a string according
     to the AMCP specification
     - parameters:
        - str: A string to tokenize
     - returns: An array of tokens
     */
    static func tokenize (_ str: String) -> [String] {
        let opts = NSRegularExpression.Options()
        
        /*
         Use a regular expression to split the string
         by space while maintaining quoted strings
         
         The pattern matches:
            - Quoted strings with single or double quotes
            - Words, characters (a-z) or digits separated by a space (that's not between quotes)
            - Two digits separated by a hyphen (e.g. 1-2 or 43-234), used to extract the channel and layer
         */
        let rex = try! NSRegularExpression(
            pattern: #"(["'])(?:(?=(\\?))\2.)*?\1|(\d+\-\d+)|([A-Za-z\d])+"#,
            options: opts
        )
        
        let matches = rex.matches(
            in: str,
            options: .init(),
            range: NSRange(location: 0, length: str.count)
        )
        
        /*
         Create an array of strings from the
         ranges found using the regular expression
         */
        let _str = NSString(string: str)
        let tokens = matches.map { (res) -> String in
            return _str.substring(with: res.range)
        }
        
        return tokens
    }
}
