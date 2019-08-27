//
//  Schemas.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 27/08/2019.
//  Copyright © 2019 Pierre Lorenzi. All rights reserved.
//


public enum Schemas {
    
    static let word = Schema<HString>(initialValue: nil, branches: [
            Schema<HString>.Branch(subSchemas: [
                Schema<HString>.ValueSubSchema(accept: { (token: Token) -> Bool in
                    
                    guard case Token.word = token else {
                        return false
                    }
                    
                    return true
                }, minCount: 1, maxCount: 1, update: Schema<HString>.Update<Token>.initialization({ (token: Token) -> HString in
                    
                    guard case Token.word(let string) = token else {
                        fatalError()
                    }
                    
                    return string
                }))
                ])
        ])
    
    static let quotedString = Schema<HString>(initialValue: nil, branches: [
        Schema<HString>.Branch(subSchemas: [
            Schema<HString>.ValueSubSchema(accept: { (token: Token) -> Bool in
                
                guard case Token.quotedString = token else {
                    return false
                }
                
                return true
            }, minCount: 1, maxCount: 1, update: Schema<HString>.Update<Token>.initialization({ (token: Token) -> HString in
                
                guard case Token.quotedString(let string) = token else {
                    fatalError()
                }
                
                return string
            }))
            ])
        ])
    
    static let integer = Schema<Int>(initialValue: nil, branches: [
        Schema<Int>.Branch(subSchemas: [
            Schema<Int>.ValueSubSchema(accept: { (token: Token) -> Bool in
                
                guard case Token.integer = token else {
                    return false
                }
                
                return true
            }, minCount: 1, maxCount: 1, update: Schema<Int>.Update<Token>.initialization({ (token: Token) -> Int in
                
                guard case Token.integer(let value) = token else {
                    fatalError()
                }
                
                return value
            }))
            ])
        ])
    
    static let realNumber = Schema<Double>(initialValue: nil, branches: [
        Schema<Double>.Branch(subSchemas: [
            Schema<Double>.ValueSubSchema(accept: { (token: Token) -> Bool in
                
                guard case Token.realNumber = token else {
                    return false
                }
                
                return true
            }, minCount: 1, maxCount: 1, update: Schema<Double>.Update<Token>.initialization({ (token: Token) -> Double in
                
                guard case Token.realNumber(let value) = token else {
                    fatalError()
                }
                
                return value
            }))
            ])
        ])
    
    static let _r = Schema<Void>(initialValue: (), branches: [
        Schema<Void>.Branch(subSchemas: [
            Schema<Void>.ValueSubSchema(accept: { (token: Token) -> Bool in
                
                guard case Token.lineSeparator = token else {
                    return false
                }
                
                return true
            }, minCount: 1, maxCount: 1, update: Schema<Void>.Update<Token>.none)
            ])
        ])
    
    static let trueLiteral = Schema<Bool>(initialValue: nil, branches: [
        Schema<Bool>.Branch(subSchemas: [
            Schema<Bool>.ValueSubSchema(accept: { (token: Token) -> Bool in
                
                return token == Token.word("true")
            }, minCount: 1, maxCount: 1, update: Schema<Bool>.Update<Token>.initialization({ (token: Token) -> Bool in
                
                return true
            }))
            ])
        ])
    
    static let falseLiteral = Schema<Bool>(initialValue: nil, branches: [
        Schema<Bool>.Branch(subSchemas: [
            Schema<Bool>.ValueSubSchema(accept: { (token: Token) -> Bool in
                
                return token == Token.word("false")
            }, minCount: 1, maxCount: 1, update: Schema<Bool>.Update<Token>.initialization({ (token: Token) -> Bool in
                
                return false
            }))
            ])
        ])
    
    static let boolean = Schema<Bool>("\(equal: trueLiteral)\(orEqual: falseLiteral)")
    
    static let expression = Schema<Literal>("\(quotedString)\(or: word)\(or: boolean)\(or: integer)\(or: realNumber)")
        
        .initWhen(quotedString) {
            Literal.string($0)
        }
        
        .initWhen(word) {
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

}

