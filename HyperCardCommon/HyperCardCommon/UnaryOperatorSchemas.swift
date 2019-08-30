//
//  OperatorSchemas.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 30/08/2019.
//  Copyright © 2019 Pierre Lorenzi. All rights reserved.
//


public extension Schemas {
    
    
    static let unaryOperator = Schema<Operator>("\(parentheses)\(or: opposite)\(or: not)\(or: thereIs)\(or: thereIsNotA)")
    
    
    
    static let parentheses = Schema<Operator>("( \(expressionAgain) )")
    
    static let opposite = Schema<Operator>("- \(factorAgain)")
        
        .returnsSingle { Operator.opposite($0) }
    
    static let not = Schema<Operator>("not \(factorAgain)")
        
        .returnsSingle { Operator.not($0) }
    
    static let thereIs = Schema<Operator>("there is \(either: "a", "an") \(objectDescriptor)")
        
        .returnsSingle { Operator.thereIs($0) }
    
    static let thereIsNotA = Schema<Operator>("there is not \(either: "a", "an") \(objectDescriptor)")
        
        .returnsSingle { Operator.thereIsNotA($0) }
    
}

// Expression types
public extension Schemas {
    
    
    static let expressionType = Schema<ExpressionType>("\(numberType)\(or: integerType)\(or: pointType)\(or: rectangleType)\(or: dateType)\(or: logicalType)")
    
    
    
    static let numberType = Schema<ExpressionType>("number")
        
        .returns(ExpressionType.number)
    
    static let integerType = Schema<ExpressionType>("integer")
        
        .returns(ExpressionType.integer)
    
    static let pointType = Schema<ExpressionType>("point")
        
        .returns(ExpressionType.point)
    
    static let rectangleType = Schema<ExpressionType>("rectangle")
        
        .returns(ExpressionType.rectangle)
    
    static let dateType = Schema<ExpressionType>("date")
        
        .returns(ExpressionType.date)
    
    static let logicalType = Schema<ExpressionType>("logical")
        
        .returns(ExpressionType.logical)
}
