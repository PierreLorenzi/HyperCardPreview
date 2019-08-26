//
//  HandlerLocating.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 11/06/2018.
//  Copyright © 2018 Pierre Lorenzi. All rights reserved.
//


public struct HandlerLocation: Equatable {
    public var name: HString
    public var type: HandlerType
    public var offset: Int
    
    public init(name: HString, type: HandlerType, offset: Int) {
        self.name = name
        self.type = type
        self.offset = offset
    }
    
    public static func ==(h1: HandlerLocation, h2: HandlerLocation) -> Bool {
        return compareCaseDiacritics(h1.name, h2.name) == .equal && h1.type == h2.type && h1.offset == h2.offset
    }
}


public extension HString {
    
    private static let messagePrefix: HString = "on"
    private static let functionPrefix: HString = "function"
    
    /// Looks for the handler declarations in the script.
    /// <p>
    /// This process is made by HyperCard without a tokenizer, because for example
    /// it doesn't accept tabs: "on\tmouseUp" is not accepted. Tokenization happens
    /// only when the handler is called.
    func locateHandlers() -> [HandlerLocation] {
        
        var locations: [HandlerLocation] = []
        var index = 0
        
        let length = self.length
        
        while true {
            
            /* Check if we have reached the end */
            guard index < length else {
                break
            }
            
            /* When we have finished this loop, move to next line */
            defer {
                while index < length && self[index] != HChar.carriageReturn {
                    index += 1
                }
                if index < length {
                    index += 1
                }
            }
            
            let lineStartIndex = index
            
            /* Skip the spaces */
            while index < length && self[index] == HChar.space {
                index += 1
            }
            
            let handlerType: HandlerType
            
            /* Check message declaration */
            if self.isNextWord(HString.messagePrefix, at: index) {
                index += HString.messagePrefix.length
                handlerType = .message
            }
            /* Check function declaration */
            else if self.isNextWord(HString.functionPrefix, at: index) {
                index += HString.functionPrefix.length
                handlerType = .function
            }
            /* If there is no declaration, stop reading the line */
            else {
                continue
            }
            
            /* Skip the spaces */
            while index < length && self[index] == HChar.space {
                index += 1
            }
            
            let handlerNameStartIndex = index
            
            /* Read the handler name */
            while index < length && self[index] != HChar.space && self[index] != HChar.carriageReturn {
                index += 1
            }
            
            /* Check there is a name */
            if handlerNameStartIndex == index {
                continue
            }
            
            /* Register the handler name */
            let handlerName = self[handlerNameStartIndex ..< index]
            let location = HandlerLocation(name: handlerName, type: handlerType, offset: lineStartIndex)
            locations.append(location)
        }
        
        return locations
    }
    
    private func isNextWord(_ word: HString, at index: Int) -> Bool {
        
        /* Check that the following word is the word and a space */
        
        guard index < self.length - word.length else {
            return false
        }
        
        let followingCharacters = self[index ..< (index + word.length)]
        guard compareCaseDiacritics(followingCharacters, word) == .equal else {
            return false
        }
        
        guard self[index + word.length] == HChar.space else {
            return false
        }
        
        return true
    }
    
}
