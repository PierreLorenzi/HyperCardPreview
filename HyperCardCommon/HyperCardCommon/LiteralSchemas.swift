//
//  Schemas.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 27/08/2019.
//  Copyright © 2019 Pierre Lorenzi. All rights reserved.
//


public extension Schemas {
    
    
    static let literal = Schema<Literal>("\(quotedString)\(or: boolean)\(or: integer)\(or: realNumber)")
    
        .when(quotedString, { Literal.quotedString($0) })
        .when(boolean, { Literal.boolean($0) })
        .when(integer, { Literal.integer($0) })
        .when(realNumber, { Literal.realNumber($0) })
    
    
    static let quotedString = Schema<HString> { (token: Token) -> HString? in
        
        guard case Token.quotedString(let string) = token else {
            return nil
        }
        
        return string
    }
    
    static let integer = Schema<Int> { (token: Token) -> Int? in
        
        guard case Token.integer(let value) = token else {
            return nil
        }
        
        return value
    }
    
    static let realNumber = Schema<Double> { (token: Token) -> Double? in
        
        guard case Token.realNumber(let value) = token else {
            return nil
        }
        
        return value
    }
    
    static let boolean = Schema<Bool> { (token: Token) -> Bool? in
        
        if token == Token.word("true") {
            return true
        }
        if token == Token.word("false") {
            return false
        }
        return nil
    }
    

}

