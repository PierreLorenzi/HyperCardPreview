//
//  Token.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 14/06/2018.
//  Copyright © 2018 Pierre Lorenzi. All rights reserved.
//


public enum Token: Equatable {
    case word(HString)
    case quotedString(HString)
    case symbol(HString)
    case integer(Int)
    case realNumber(Double)
    case lineSeparator
    
    public static func ==(token1: Token, token2: Token) -> Bool {
        
        switch (token1, token2) {
            
        case (.word(let word1), .word(let word2)):
            return compareCaseDiacritics(word1, word2) == .equal
            
        case (.quotedString(let quotedString1), .quotedString(let quotedString2)):
            return compareCaseDiacritics(quotedString1, quotedString2) == .equal
            
        case (.symbol(let symbol1), .symbol(let symbol2)):
            return compareCaseDiacritics(symbol1, symbol2) == .equal
            
        case (.integer(let value1), .integer(let value2)):
            return value1 == value2
            
        case (.realNumber(let value1), .realNumber(let value2)):
            return value1 == value2
            
        case (.lineSeparator, .lineSeparator):
            return true
            
        default:
            return false
        }
    }
}

