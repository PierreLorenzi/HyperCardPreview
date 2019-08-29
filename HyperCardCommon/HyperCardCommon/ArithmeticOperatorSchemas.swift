//
//  OperatorSchemas.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 27/08/2019.
//  Copyright © 2019 Pierre Lorenzi. All rights reserved.
//



public extension Schemas {
    
    // Just a stub for now
    static let expression = Schema<Expression>()
    
    static let addition = Schema<(Expression,Expression)>("\(expression) + \(expression)")
    
        .returns { ($0,$1) }
    
    static let substraction = Schema<(Expression,Expression)>("\(expression) - \(expression)")
        
        .returns { ($0,$1) }
    
    static let opposite = Schema<Expression>("- \(expression)")
            
    static let multiplication = Schema<(Expression,Expression)>("\(expression) * \(expression)")
        
        .returns { ($0,$1) }
    
    static let division = Schema<(Expression,Expression)>("\(expression) / \(expression)")
        
        .returns { ($0,$1) }
    
    static let exponentiation = Schema<(Expression,Expression)>("\(expression) ^ \(expression)")
        
        .returns { ($0,$1) }
    
    static let modulo = Schema<(Expression,Expression)>("\(expression) mod \(expression)")
        
        .returns { ($0,$1) }
    
    static let integerDivision = Schema<(Expression,Expression)>("\(expression) div \(expression)")
        
        .returns { ($0,$1) }
    
    static let arithmeticOperator = Schema<ArithmeticOperator>("(\(addition)\(or: substraction)\(or: opposite)\(or: multiplication)\(or: division)\(or: exponentiation)\(or: modulo)\(or: integerDivision))")
    
        .initWhen(addition) {
            ArithmeticOperator.addition($0.0, $0.1)
        }
        
        .initWhen(substraction) {
            ArithmeticOperator.substraction($0.0, $0.1)
        }
        
        .initWhen(opposite) {
            ArithmeticOperator.opposite($0)
        }
        
        .initWhen(multiplication) {
            ArithmeticOperator.multiplication($0.0, $0.1)
        }
        
        .initWhen(division) {
            ArithmeticOperator.division($0.0, $0.1)
        }
        
        .initWhen(exponentiation) {
            ArithmeticOperator.exponentiation($0.0, $0.1)
        }
        
        .initWhen(modulo) {
            ArithmeticOperator.modulo($0.0, $0.1)
        }
        
        .initWhen(integerDivision) {
            ArithmeticOperator.integerDivision($0.0, $0.1)
        }
    
}
