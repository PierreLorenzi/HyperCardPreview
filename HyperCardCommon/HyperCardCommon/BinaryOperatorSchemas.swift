//
//  OperatorSchemas.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 30/08/2019.
//  Copyright © 2019 Pierre Lorenzi. All rights reserved.
//


public extension Schemas {
    
    
    static let binaryOperator = Schema<Operator>("\(addition)\(or: substraction)\(or: multiplication)\(or: division)\(or: exponentiation)\(or: modulo)\(or: integerDivision)\(or: equal1)\(or: equal2)\(or: unequal1)\(or: unequal2)\(or: unequal3)\(or: lesserThan)\(or: greaterThan)\(or: lesserThanOrEqual1)\(or: lesserThanOrEqual2)\(or: greaterThanOrEqual1)\(or: greaterThanOrEqual2)\(or: contains)\(or: isIn)\(or: isNotIn)\(or: isWithin)\(or: isNotWithin)\(or: and)\(or: or)\(or: isOfType)\(or: concatenation)\(or: concatenationWithSpace)")
    
    
    
    static let addition = Schema<Operator>("\(expression) + \(expression)")
        
        .returns { Operator.addition($0, $1) }
    
    static let substraction = Schema<Operator>("\(expression) - \(expression)")
        
        .returns { Operator.substraction($0,$1) }
    
    static let multiplication = Schema<Operator>("\(expression) * \(expression)")
        
        .returns { Operator.multiplication($0,$1) }
    
    static let division = Schema<Operator>("\(expression) / \(expression)")
        
        .returns { Operator.division($0,$1) }
    
    static let exponentiation = Schema<Operator>("\(expression) ^ \(expression)")
        
        .returns { Operator.exponentiation($0,$1) }
    
    static let modulo = Schema<Operator>("\(expression) mod \(expression)")
        
        .returns { Operator.modulo($0,$1) }
    
    static let integerDivision = Schema<Operator>("\(expression) div \(expression)")
        
        .returns { Operator.integerDivision($0,$1) }
    
    static let equal1 = Schema<Operator>("\(expression) = \(expression)")
        
        .returns { Operator.equal($0, $1) }
    
    static let equal2 = Schema<Operator>("\(expression) is \(expression)")
        
        .returns { Operator.equal($0, $1) }
    
    static let unequal1 = Schema<Operator>("\(expression) ≠ \(expression)")
        
        .returns { Operator.unequal($0, $1) }
    
    static let unequal2 = Schema<Operator>("\(expression) <> \(expression)")
        
        .returns { Operator.unequal($0, $1) }
    
    static let unequal3 = Schema<Operator>("\(expression) is not \(expression)")
        
        .returns { Operator.unequal($0, $1) }
    
    static let lesserThan = Schema<Operator>("\(expression) < \(expression)")
        
        .returns { Operator.lesserThan($0, $1) }
    
    static let greaterThan = Schema<Operator>("\(expression) > \(expression)")
        
        .returns { Operator.greaterThan($0, $1) }
    
    static let lesserThanOrEqual1 = Schema<Operator>("\(expression) <= \(expression)")
        
        .returns { Operator.lesserThanOrEqual($0, $1) }
    
    static let lesserThanOrEqual2 = Schema<Operator>("\(expression) ≤ \(expression)")
        
        .returns { Operator.lesserThanOrEqual($0, $1) }
    
    static let greaterThanOrEqual1 = Schema<Operator>("\(expression) >= \(expression)")
        
        .returns { Operator.greaterThanOrEqual($0, $1) }
    
    static let greaterThanOrEqual2 = Schema<Operator>("\(expression) ≥ \(expression)")
        
        .returns { Operator.greaterThanOrEqual($0, $1) }
    
    static let contains = Schema<Operator>("\(expression) contains \(expression)")
        
        .returns { Operator.contains($0, $1) }
    
    static let isIn = Schema<Operator>("\(expression) is in \(expression)")
        
        .returns { Operator.isIn($0, $1) }
    
    static let isNotIn = Schema<Operator>("\(expression) is not in \(expression)")
        
        .returns { Operator.isNotIn($0, $1) }
    
    static let isWithin = Schema<Operator>("\(expression) is within \(expression)")
        
        .returns { Operator.isWithin($0, $1) }
    
    static let isNotWithin = Schema<Operator>("\(expression) is not within \(expression)")
        
        .returns { Operator.isNotWithin($0, $1) }
    
    static let and = Schema<Operator>("\(expression) and \(expression)")
            
            .returns { Operator.and($0, $1) }
    
    static let or = Schema<Operator>("\(expression) or \(expression)")
        
        .returns { Operator.or($0, $1) }
    
    static let isOfType = Schema<Operator>("\(expression) is \(either: "a", "an") \(expressionType)")
        
        .returns { Operator.isOfType($0, $1) }
    
    static let concatenation = Schema<Operator>("\(expression) & \(expression)")
            
            .returns { Operator.concatenation($0, $1) }
    
    static let concatenationWithSpace = Schema<Operator>("\(expression) && \(expression)")
        
        .returns { Operator.concatenationWithSpace($0, $1) }
    
    // Just a stub for now
    static let expression = Schema<Expression>()
}
