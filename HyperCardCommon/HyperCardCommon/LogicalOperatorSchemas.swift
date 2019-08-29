//
//  LogicalOperatorSchemas.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 29/08/2019.
//  Copyright © 2019 Pierre Lorenzi. All rights reserved.
//


public extension Schemas {
    
    
    static let comparisonOperato = Schema<LogicalOperator>("\(not)\(or: and)\(or: or)")
    
    
    
    static let not = Schema<LogicalOperator>("not \(expression)")
        
        .returnsSingle { LogicalOperator.not($0) }
    
    static let and = Schema<LogicalOperator>("\(expression) and \(expression)")
        
        .returns { LogicalOperator.and($0, $1) }
    
    static let or = Schema<LogicalOperator>("\(expression) or \(expression)")
        
        .returns { LogicalOperator.or($0, $1) }
}
