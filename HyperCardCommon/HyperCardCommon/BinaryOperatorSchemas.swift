//
//  BinaryOperatorSchemas.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 30/08/2019.
//  Copyright © 2019 Pierre Lorenzi. All rights reserved.
//


public extension Schemas {
    
    
    static let binaryOperator = Schema<BinaryOperator>("\(addition)\(or: substraction)\(or: multiplication)\(or: division)\(or: exponentiation)\(or: modulo)\(or: integerDivision)\(or: equal1)\(or: equal2)\(or: unequal1)\(or: unequal2)\(or: unequal3)\(or: lesserThan)\(or: greaterThan)\(or: lesserThanOrEqual1)\(or: lesserThanOrEqual2)\(or: greaterThanOrEqual1)\(or: greaterThanOrEqual2)\(or: contains)\(or: isIn)\(or: isNotIn)\(or: isWithin)\(or: isNotWithin)\(or: and)\(or: or)\(or: isOfType)\(or: concatenation)\(or: concatenationWithSpace)")
    
    
    
    static let addition = Schema<BinaryOperator>("\(expression) + \(expression)")
        
        .returns { BinaryOperator.addition($0, $1) }
    
    static let substraction = Schema<BinaryOperator>("\(expression) - \(expression)")
        
        .returns { BinaryOperator.substraction($0,$1) }
    
    static let multiplication = Schema<BinaryOperator>("\(expression) * \(expression)")
        
        .returns { BinaryOperator.multiplication($0,$1) }
    
    static let division = Schema<BinaryOperator>("\(expression) / \(expression)")
        
        .returns { BinaryOperator.division($0,$1) }
    
    static let exponentiation = Schema<BinaryOperator>("\(expression) ^ \(expression)")
        
        .returns { BinaryOperator.exponentiation($0,$1) }
    
    static let modulo = Schema<BinaryOperator>("\(expression) mod \(expression)")
        
        .returns { BinaryOperator.modulo($0,$1) }
    
    static let integerDivision = Schema<BinaryOperator>("\(expression) div \(expression)")
        
        .returns { BinaryOperator.integerDivision($0,$1) }
    
    static let equal1 = Schema<BinaryOperator>("\(expression) = \(expression)")
        
        .returns { BinaryOperator.equal($0, $1) }
    
    static let equal2 = Schema<BinaryOperator>("\(expression) is \(expression)")
        
        .returns { BinaryOperator.equal($0, $1) }
    
    static let unequal1 = Schema<BinaryOperator>("\(expression) ≠ \(expression)")
        
        .returns { BinaryOperator.unequal($0, $1) }
    
    static let unequal2 = Schema<BinaryOperator>("\(expression) <> \(expression)")
        
        .returns { BinaryOperator.unequal($0, $1) }
    
    static let unequal3 = Schema<BinaryOperator>("\(expression) is not \(expression)")
        
        .returns { BinaryOperator.unequal($0, $1) }
    
    static let lesserThan = Schema<BinaryOperator>("\(expression) < \(expression)")
        
        .returns { BinaryOperator.lesserThan($0, $1) }
    
    static let greaterThan = Schema<BinaryOperator>("\(expression) > \(expression)")
        
        .returns { BinaryOperator.greaterThan($0, $1) }
    
    static let lesserThanOrEqual1 = Schema<BinaryOperator>("\(expression) <= \(expression)")
        
        .returns { BinaryOperator.lesserThanOrEqual($0, $1) }
    
    static let lesserThanOrEqual2 = Schema<BinaryOperator>("\(expression) ≤ \(expression)")
        
        .returns { BinaryOperator.lesserThanOrEqual($0, $1) }
    
    static let greaterThanOrEqual1 = Schema<BinaryOperator>("\(expression) >= \(expression)")
        
        .returns { BinaryOperator.greaterThanOrEqual($0, $1) }
    
    static let greaterThanOrEqual2 = Schema<BinaryOperator>("\(expression) ≥ \(expression)")
        
        .returns { BinaryOperator.greaterThanOrEqual($0, $1) }
    
    static let contains = Schema<BinaryOperator>("\(expression) contains \(expression)")
        
        .returns { BinaryOperator.contains($0, $1) }
    
    static let isIn = Schema<BinaryOperator>("\(expression) is in \(expression)")
        
        .returns { BinaryOperator.isIn($0, $1) }
    
    static let isNotIn = Schema<BinaryOperator>("\(expression) is not in \(expression)")
        
        .returns { BinaryOperator.isNotIn($0, $1) }
    
    static let isWithin = Schema<BinaryOperator>("\(expression) is within \(expression)")
        
        .returns { BinaryOperator.isWithin($0, $1) }
    
    static let isNotWithin = Schema<BinaryOperator>("\(expression) is not within \(expression)")
        
        .returns { BinaryOperator.isNotWithin($0, $1) }
    
    static let and = Schema<BinaryOperator>("\(expression) and \(expression)")
            
            .returns { BinaryOperator.and($0, $1) }
    
    static let or = Schema<BinaryOperator>("\(expression) or \(expression)")
        
        .returns { BinaryOperator.or($0, $1) }
    
    static let isOfType = Schema<BinaryOperator>("\(expression) is \(either: "a", "an") \(expressionType)")
        
        .returns { BinaryOperator.isOfType($0, $1) }
    
    static let concatenation = Schema<BinaryOperator>("\(expression) & \(expression)")
            
            .returns { BinaryOperator.concatenation($0, $1) }
    
    static let concatenationWithSpace = Schema<BinaryOperator>("\(expression) && \(expression)")
        
        .returns { BinaryOperator.concatenationWithSpace($0, $1) }
    
    // Just a stub for now
    static let expression = Schema<Expression>()
}
