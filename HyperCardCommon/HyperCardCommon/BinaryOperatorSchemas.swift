//
//  OperatorSchemas.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 30/08/2019.
//  Copyright © 2019 Pierre Lorenzi. All rights reserved.
//


public extension Schemas {
    
    
    static let binaryOperator = Schema<Operator>("\(addition)\(or: substraction)\(or: multiplication)\(or: division)\(or: exponentiation)\(or: modulo)\(or: integerDivision)\(or: equal1)\(or: equal2)\(or: unequal1)\(or: unequal2)\(or: unequal3)\(or: lesserThan)\(or: greaterThan)\(or: lesserThanOrEqual1)\(or: lesserThanOrEqual2)\(or: greaterThanOrEqual1)\(or: greaterThanOrEqual2)\(or: contains)\(or: isIn)\(or: isNotIn)\(or: isWithin)\(or: isNotWithin)\(or: and)\(or: or)\(or: isOfType)\(or: concatenation)\(or: concatenationWithSpace)")
    
    
    
    static let addition = Schema<Operator>("\(expressionAgain) + \(expressionAgain)")
        
        .returns { Operator.addition($0, $1) }
    
    static let substraction = Schema<Operator>("\(expressionAgain) - \(expressionAgain)")
        
        .returns { Operator.substraction($0,$1) }
    
    static let multiplication = Schema<Operator>("\(expressionAgain) * \(expressionAgain)")
        
        .returns { Operator.multiplication($0,$1) }
    
    static let division = Schema<Operator>("\(expressionAgain) / \(expressionAgain)")
        
        .returns { Operator.division($0,$1) }
    
    static let exponentiation = Schema<Operator>("\(expressionAgain) ^ \(expressionAgain)")
        
        .returns { Operator.exponentiation($0,$1) }
    
    static let modulo = Schema<Operator>("\(expressionAgain) mod \(expressionAgain)")
        
        .returns { Operator.modulo($0,$1) }
    
    static let integerDivision = Schema<Operator>("\(expressionAgain) div \(expressionAgain)")
        
        .returns { Operator.integerDivision($0,$1) }
    
    static let equal1 = Schema<Operator>("\(expressionAgain) = \(expressionAgain)")
        
        .returns { Operator.equal($0, $1) }
    
    static let equal2 = Schema<Operator>("\(expressionAgain) is \(expressionAgain)")
        
        .returns { Operator.equal($0, $1) }
    
    static let unequal1 = Schema<Operator>("\(expressionAgain) ≠ \(expressionAgain)")
        
        .returns { Operator.unequal($0, $1) }
    
    static let unequal2 = Schema<Operator>("\(expressionAgain) <> \(expressionAgain)")
        
        .returns { Operator.unequal($0, $1) }
    
    static let unequal3 = Schema<Operator>("\(expressionAgain) is not \(expressionAgain)")
        
        .returns { Operator.unequal($0, $1) }
    
    static let lesserThan = Schema<Operator>("\(expressionAgain) < \(expressionAgain)")
        
        .returns { Operator.lesserThan($0, $1) }
    
    static let greaterThan = Schema<Operator>("\(expressionAgain) > \(expressionAgain)")
        
        .returns { Operator.greaterThan($0, $1) }
    
    static let lesserThanOrEqual1 = Schema<Operator>("\(expressionAgain) <= \(expressionAgain)")
        
        .returns { Operator.lesserThanOrEqual($0, $1) }
    
    static let lesserThanOrEqual2 = Schema<Operator>("\(expressionAgain) ≤ \(expressionAgain)")
        
        .returns { Operator.lesserThanOrEqual($0, $1) }
    
    static let greaterThanOrEqual1 = Schema<Operator>("\(expressionAgain) >= \(expressionAgain)")
        
        .returns { Operator.greaterThanOrEqual($0, $1) }
    
    static let greaterThanOrEqual2 = Schema<Operator>("\(expressionAgain) ≥ \(expressionAgain)")
        
        .returns { Operator.greaterThanOrEqual($0, $1) }
    
    static let contains = Schema<Operator>("\(expressionAgain) contains \(expressionAgain)")
        
        .returns { Operator.contains($0, $1) }
    
    static let isIn = Schema<Operator>("\(expressionAgain) is in \(expressionAgain)")
        
        .returns { Operator.isIn($0, $1) }
    
    static let isNotIn = Schema<Operator>("\(expressionAgain) is not in \(expressionAgain)")
        
        .returns { Operator.isNotIn($0, $1) }
    
    static let isWithin = Schema<Operator>("\(expressionAgain) is within \(expressionAgain)")
        
        .returns { Operator.isWithin($0, $1) }
    
    static let isNotWithin = Schema<Operator>("\(expressionAgain) is not within \(expressionAgain)")
        
        .returns { Operator.isNotWithin($0, $1) }
    
    static let and = Schema<Operator>("\(expressionAgain) and \(expressionAgain)")
            
            .returns { Operator.and($0, $1) }
    
    static let or = Schema<Operator>("\(expressionAgain) or \(expressionAgain)")
        
        .returns { Operator.or($0, $1) }
    
    static let isOfType = Schema<Operator>("\(expressionAgain) is \(either: "a", "an") \(expressionType)")
        
        .returns { Operator.isOfType($0, $1) }
    
    static let concatenation = Schema<Operator>("\(expressionAgain) & \(expressionAgain)")
            
            .returns { Operator.concatenation($0, $1) }
    
    static let concatenationWithSpace = Schema<Operator>("\(expressionAgain) && \(expressionAgain)")
        
        .returns { Operator.concatenationWithSpace($0, $1) }
}
