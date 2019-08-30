//
//  Factor.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 30/08/2019.
//  Copyright © 2019 Pierre Lorenzi. All rights reserved.
//


public extension Schemas {
    
    
    static let factor = Schema<Expression>("\(literalFactor)\(or: unaryOperatorFactor)\(or: containerFactor)")
    
    
    
    static let literalFactor = Schema<Expression>("\(literal)")
    
        .returnsSingle { Expression.literal($0) }
    
    static let unaryOperatorFactor = Schema<Expression>("\(unaryOperator)")
        
        .returnsSingle { Expression.operator(Operator.unary($0)) }
    
    static let containerFactor = Schema<Expression>("\(containerDescriptor)")
        
        .returnsSingle { Expression.containerContent($0) }
}
