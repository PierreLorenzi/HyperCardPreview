//
//  Schemas.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 27/08/2019.
//  Copyright © 2019 Pierre Lorenzi. All rights reserved.
//


public enum Schemas {
    
    private static let wordToken = Schema<Token> { (token: Token) -> Bool in
        
        guard case Token.word = token else {
            return false
        }
        
        return true
    }
    
    public static let word = Schema<HString>("\(wordToken)")
    
        .returnsSingle { (t: Token) -> HString in
            
            guard case Token.word(let string) = t else {
                fatalError()
            }
            
            return string
        }
    
    
    private static let quotedStringToken = Schema<Token> { (token: Token) -> Bool in
        
        guard case Token.quotedString = token else {
            return false
        }
        
        return true
    }
    
    public static let quotedString = Schema<HString>("\(quotedStringToken)")
        
        .returnsSingle { (t: Token) -> HString in
            
            guard case Token.quotedString(let string) = t else {
                fatalError()
            }
            
            return string
    }
    
    private static let integerToken = Schema<Token> { (token: Token) -> Bool in
        
        guard case Token.integer = token else {
            return false
        }
        
        return true
    }
    
    public static let integer = Schema<Int>("\(integerToken)")
        
        .returnsSingle { (t: Token) -> Int in
            
            guard case Token.integer(let value) = t else {
                fatalError()
            }
            
            return value
    }
    
    private static let realNumberToken = Schema<Token> { (token: Token) -> Bool in
        
        guard case Token.realNumber = token else {
            return false
        }
        
        return true
    }
    
    public static let realNumber = Schema<Double>("\(realNumberToken)")
        
        .returnsSingle { (t: Token) -> Double in
            
            guard case Token.realNumber(let value) = t else {
                fatalError()
            }
            
            return value
    }
    
    private static let lineSeparatorToken = Schema<Token>(token: Token.lineSeparator)
    
    public static let lineSeparator = Schema<Void>("\(lineSeparatorToken)")
        
        .returnsSingle { (_: Token) -> Void in
            
            return ()
    }
    
    private static let trueToken = Schema<Token>(token: Token.word("true"))
    
    public static let trueLiteral = Schema<Bool>("\(trueToken)")
        
        .returnsSingle { (_: Token) -> Bool in
            
            return true
    }
    
    private static let falseToken = Schema<Token>(token: Token.word("false"))
    
    public static let falseLiteral = Schema<Bool>("\(falseToken)")
        
        .returnsSingle { (_: Token) -> Bool in
            
            return false
    }
    
    public static let boolean = Schema<Bool>("\(equal: trueLiteral)\(orEqual: falseLiteral)")
    
    public static let literal = Schema<Literal>("\(quotedString)\(or: boolean)\(or: integer)\(or: realNumber)\(or: word)")
        
        .initWhen(quotedString) {
            Literal.string($0)
        }
        
        .initWhen(boolean) {
            Literal.boolean($0)
        }
        
        .initWhen(integer) {
            Literal.integer($0)
        }
        
        .initWhen(realNumber) {
            Literal.floatingPoint($0)
        }
        
        .initWhen(word) {
            Literal.string($0)
    }

}

