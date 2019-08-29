//
//  StringOperatorSchemas.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 29/08/2019.
//  Copyright © 2019 Pierre Lorenzi. All rights reserved.
//


public extension Schemas {
    
    
    static let stringOperator = Schema<StringOperator>("\(concatenation)\(or: concatenationWithSpace)")
    
    
    
    static let concatenation = Schema<StringOperator>("\(expression) & \(expression)")
        
        .returns { StringOperator.concatenation($0, $1) }
    
    static let concatenationWithSpace = Schema<StringOperator>("\(expression) && \(expression)")
        
        .returns { StringOperator.concatenationWithSpace($0, $1) }
    
}
