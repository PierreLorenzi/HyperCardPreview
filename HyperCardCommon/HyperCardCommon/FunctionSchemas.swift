//
//  FunctionSchemas.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 30/08/2019.
//  Copyright © 2019 Pierre Lorenzi. All rights reserved.
//


public extension Schemas {
    
    
    static let functionCall = Schema<FunctionCall>("\(builtInFunctionCall)\(or: standardFunctionCall)")
    
    
    
    static let builtInFunctionCall = Schema<FunctionCall>("\(noArgumentFunctionCall)\(or: oneArgumentFunctionCall)")
    
    static let standardFunctionCall = Schema<FunctionCall>("\(identifier) ( \(maybe: argumentList) )")
    
        .returns { FunctionCall.custom(identifier: $0, arguments: $1) }
    
    private static let argumentList = Schema<[Expression]>("\(expression) \(multiple: supplementaryArgument)")
    
        .returns { [$0] + $1 }
    
    private static let supplementaryArgument = Schema<Expression>(", \(expression)")
    
    static let identifier = Schema<HString> { (token: Token) -> HString? in
        
        guard case Token.word(let string) = token else {
            return nil
        }
        
        return string
    }

}
