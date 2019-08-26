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
    case integer([Digit])
    case realNumber([Digit], fractional: [Digit])
    case lineSeparator
    
    public static func ==(token1: Token, token2: Token) -> Bool {
        
        switch (token1, token2) {
            
        case (.word(let word1), .word(let word2)):
            return compareCaseDiacritics(word1, word2) == .equal
            
        case (.quotedString(let quotedString1), .quotedString(let quotedString2)):
            return compareCaseDiacritics(quotedString1, quotedString2) == .equal
            
        case (.symbol(let symbol1), .symbol(let symbol2)):
            return compareCaseDiacritics(symbol1, symbol2) == .equal
            
        case (.integer(let digits1), .integer(let digits2)):
            return digits1 == digits2
            
        case (.realNumber(let digits1, let fractionalDigits1), .realNumber(let digits2, let fractionalDigits2)):
            return digits1 == digits2 && fractionalDigits1 == fractionalDigits2
            
        case (.lineSeparator, .lineSeparator):
            return true
            
        default:
            return false
        }
    }
}

public enum Digit: Int {
    case zero = 0
    case one = 1
    case two = 2
    case three = 3
    case four = 4
    case five = 5
    case six = 6
    case seven = 7
    case eight = 8
    case nine = 9
}

