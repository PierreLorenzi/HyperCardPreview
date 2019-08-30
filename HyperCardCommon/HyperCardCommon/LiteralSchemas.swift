//
//  Schemas.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 27/08/2019.
//  Copyright © 2019 Pierre Lorenzi. All rights reserved.
//


public extension Schemas {
    
    
    static let literal = Schema<Literal>("\(quotedString)\(or: boolean)\(or: integer)\(or: realNumber)\(or: word)")
    
    
    
    static let word = Schema<Literal> { (token: Token) -> Literal? in
        
        guard case Token.word(let string) = token else {
            return nil
        }
        
        return Literal.string(string)
    }
    
    static let quotedString = Schema<Literal> { (token: Token) -> Literal? in
        
        guard case Token.quotedString(let string) = token else {
            return nil
        }
        
        return Literal.string(string)
    }
    
    static let integer = Schema<Literal> { (token: Token) -> Literal? in
        
        guard case Token.integer(let value) = token else {
            return nil
        }
        
        return Literal.integer(value)
    }
    
    static let realNumber = Schema<Literal> { (token: Token) -> Literal? in
        
        guard case Token.realNumber(let value) = token else {
            return nil
        }
        
        return Literal.realNumber(value)
    }
    
    static let boolean = Schema<Literal>("\(trueLiteral)\(or: falseLiteral)")
    
    static let trueLiteral = Schema<Literal>("true")
        
        .returns(Literal.boolean(true))
    
    static let falseLiteral = Schema<Literal>("false")
        
        .returns(Literal.boolean(false))
    

}

