//
//  Schemas.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 27/08/2019.
//  Copyright © 2019 Pierre Lorenzi. All rights reserved.
//


public enum Schemas {
    
    public static let word = Schema<HString> { (token: Token) -> HString? in
        
        guard case Token.word(let string) = token else {
            return nil
        }
        
        return string
    }
    
    
    public static let quotedString = Schema<HString> { (token: Token) -> HString? in
        
        guard case Token.quotedString(let string) = token else {
            return nil
        }
        
        return string
    }
    
    public static let integer = Schema<Int> { (token: Token) -> Int? in
        
        guard case Token.integer(let value) = token else {
            return nil
        }
        
        return value
    }
    
    public static let realNumber = Schema<Double> { (token: Token) -> Double? in
        
        guard case Token.realNumber(let value) = token else {
            return nil
        }
        
        return value
    }
    
    private static let lineSeparator = Schema<Void>("\(Token.lineSeparator)")
    
        .returns(())
    
    public static let trueLiteral = Schema<Bool>("true")
        
        .returns(true)
    
    public static let falseLiteral = Schema<Bool>("false")
        
        .returns(false)
    
    public static let boolean = Schema<Bool>("\(trueLiteral)\(or: falseLiteral)")
    
    public static let literal = Schema<Literal>("\(quotedString)\(or: boolean)\(or: integer)\(or: realNumber)\(or: word)")
        
        .when(quotedString) {
            Literal.string($0)
        }
        
        .when(boolean) {
            Literal.boolean($0)
        }
        
        .when(integer) {
            Literal.integer($0)
        }
        
        .when(realNumber) {
            Literal.floatingPoint($0)
        }
        
        .when(word) {
            Literal.string($0)
    }

}

