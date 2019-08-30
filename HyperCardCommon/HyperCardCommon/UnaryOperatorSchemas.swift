//
//  UnaryOperatorSchemas.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 30/08/2019.
//  Copyright © 2019 Pierre Lorenzi. All rights reserved.
//


public extension Schemas {
    
    
    static let unaryOperator = Schema<UnaryOperator>("\(parentheses)\(or: opposite)\(or: not)\(or: thereIs)\(or: thereIsNotA)")
    
    
    
    static let parentheses = Schema<Expression>("( \(expression) )")
        
        .returnsSingle { Expression.literal($0) }
    
    static let opposite = Schema<UnaryOperator>("- \(factor)")
        
        .returnsSingle { UnaryOperator.opposite($0) }
    
    static let not = Schema<UnaryOperator>("not \(factor)")
        
        .returnsSingle { UnaryOperator.not($0) }
    
    static let thereIs = Schema<UnaryOperator>("there is \(either: "a", "an") \(objectDescriptor)")
        
        .returnsSingle { UnaryOperator.thereIs($0) }
    
    static let thereIsNotA = Schema<UnaryOperator>("there is not \(either: "a", "an") \(objectDescriptor)")
        
        .returnsSingle { UnaryOperator.thereIsNotA($0) }
    
    // stub
    static let objectDescriptor = Schema<ObjectDescriptor>()
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
