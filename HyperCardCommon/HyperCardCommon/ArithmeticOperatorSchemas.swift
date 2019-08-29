//
//  OperatorSchemas.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 27/08/2019.
//  Copyright © 2019 Pierre Lorenzi. All rights reserved.
//



public extension Schemas {
    
    
    static let arithmeticOperator = Schema<ArithmeticOperator>("(\(addition)\(or: substraction)\(or: opposite)\(or: multiplication)\(or: division)\(or: exponentiation)\(or: modulo)\(or: integerDivision))")
    
    
    
    static let addition = Schema<ArithmeticOperator>("\(expression) + \(expression)")
    
        .returns { ArithmeticOperator.addition($0, $1) }
    
    static let substraction = Schema<ArithmeticOperator>("\(expression) - \(expression)")
        
        .returns { ArithmeticOperator.substraction($0,$1) }
    
    static let opposite = Schema<ArithmeticOperator>("- \(expression)")
    
        .returnsSingle { ArithmeticOperator.opposite($0) }
            
    static let multiplication = Schema<ArithmeticOperator>("\(expression) * \(expression)")
        
        .returns { ArithmeticOperator.multiplication($0,$1) }
    
    static let division = Schema<ArithmeticOperator>("\(expression) / \(expression)")
        
        .returns { ArithmeticOperator.division($0,$1) }
    
    static let exponentiation = Schema<ArithmeticOperator>("\(expression) ^ \(expression)")
        
        .returns { ArithmeticOperator.exponentiation($0,$1) }
    
    static let modulo = Schema<ArithmeticOperator>("\(expression) mod \(expression)")
        
        .returns { ArithmeticOperator.modulo($0,$1) }
    
    static let integerDivision = Schema<ArithmeticOperator>("\(expression) div \(expression)")
        
        .returns { ArithmeticOperator.integerDivision($0,$1) }
    
    // Just a stub for now
    static let expression = Schema<Expression>()
    
}
