//
//  ExistenceOperatorSchemas.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 29/08/2019.
//  Copyright © 2019 Pierre Lorenzi. All rights reserved.
//


public extension Schemas {
    
    
    static let existenceOperator = Schema<ExistenceOperator>("\(not)\(or: and)")
    
    
    
    static let isOfType1 = Schema<ExistenceOperator>("\(expression) is a \(expressionType)")
        
        .returns { ExistenceOperator.isOfType($0, $1) }
    
    static let isOfType2 = Schema<ExistenceOperator>("\(expression) is an \(expressionType)")
        
        .returns { ExistenceOperator.isOfType($0, $1) }
    
    static let thereIs1 = Schema<ExistenceOperator>("there is a \(objectDescriptor)")
        
        .returnsSingle { ExistenceOperator.thereIs($0) }
    
    static let thereIs2 = Schema<ExistenceOperator>("there is an \(objectDescriptor)")
        
        .returnsSingle { ExistenceOperator.thereIs($0) }
    
    static let thereIsNotA1 = Schema<ExistenceOperator>("there is not a \(objectDescriptor)")
        
        .returnsSingle { ExistenceOperator.thereIsNotA($0) }
    
    static let thereIsNotA2 = Schema<ExistenceOperator>("there is not an \(objectDescriptor)")
        
        .returnsSingle { ExistenceOperator.thereIsNotA($0) }
    
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
