//
//  OperatorSchemas.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 30/08/2019.
//  Copyright © 2019 Pierre Lorenzi. All rights reserved.
//


public extension Schemas {
    
    /* We handle operator precedence by inheritances. It is possible because all
     the other expressions are inside the 'factor' schema, including the unary
     operators so we don't have to handle precedence with them. */
    static let expression = Schema<Expression>("\(expressionPrecedence9)\(or: or)")
    
    
    static let or = Schema<Operator>("\(expressionPrecedence9) or \(expressionPrecedence9)")
        
        .returns { Operator.or($0, $1) }
}

public extension Schemas {
    
    
    static let expressionPrecedence9 = Schema<Expression>("\(expressionPrecedence8)\(or: and)")
    
    
    static let and = Schema<Operator>("\(expressionPrecedence8) and \(expressionPrecedence8)")
        
        .returns { Operator.and($0, $1) }
}

public extension Schemas {
    
    
    static let expressionPrecedence8 = Schema<Expression>("\(expressionPrecedence7)\(or: equal1)\(or: equal2)\(or: unequal1)\(or: unequal2)\(or: unequal3)")
    
    
    static let equal1 = Schema<Operator>("\(expressionPrecedence7) = \(expressionPrecedence7)")
        
        .returns { Operator.equal($0, $1) }
    
    static let equal2 = Schema<Operator>("\(expressionPrecedence7) is \(expressionPrecedence7)")
        
        .returns { Operator.equal($0, $1) }
    
    static let unequal1 = Schema<Operator>("\(expressionPrecedence7) ≠ \(expressionPrecedence7)")
        
        .returns { Operator.unequal($0, $1) }
    
    static let unequal2 = Schema<Operator>("\(expressionPrecedence7) <> \(expressionPrecedence7)")
        
        .returns { Operator.unequal($0, $1) }
    
    static let unequal3 = Schema<Operator>("\(expressionPrecedence7) is not \(expressionPrecedence7)")
        
        .returns { Operator.unequal($0, $1) }
}

public extension Schemas {
    
    
    static let expressionPrecedence7 = Schema<Expression>("\(expressionPrecedence6)\(or: lesserThan)\(or: greaterThan)\(or: lesserThanOrEqual1)\(or: lesserThanOrEqual2)\(or: greaterThanOrEqual1)\(or: greaterThanOrEqual2)\(or: contains)\(or: isIn)\(or: isNotIn)\(or: isOfType)")
    
    
    static let lesserThan = Schema<Operator>("\(expressionPrecedence6) < \(expressionPrecedence6)")
        
        .returns { Operator.lesserThan($0, $1) }
    
    static let greaterThan = Schema<Operator>("\(expressionPrecedence6) > \(expressionPrecedence6)")
        
        .returns { Operator.greaterThan($0, $1) }
    
    static let lesserThanOrEqual1 = Schema<Operator>("\(expressionPrecedence6) <= \(expressionPrecedence6)")
        
        .returns { Operator.lesserThanOrEqual($0, $1) }
    
    static let lesserThanOrEqual2 = Schema<Operator>("\(expressionPrecedence6) ≤ \(expressionPrecedence6)")
        
        .returns { Operator.lesserThanOrEqual($0, $1) }
    
    static let greaterThanOrEqual1 = Schema<Operator>("\(expressionPrecedence6) >= \(expressionPrecedence6)")
        
        .returns { Operator.greaterThanOrEqual($0, $1) }
    
    static let greaterThanOrEqual2 = Schema<Operator>("\(expressionPrecedence6) ≥ \(expressionPrecedence6)")
        
        .returns { Operator.greaterThanOrEqual($0, $1) }
    
    static let contains = Schema<Operator>("\(expressionPrecedence6) contains \(expressionPrecedence6)")
        
        .returns { Operator.contains($0, $1) }
    
    static let isIn = Schema<Operator>("\(expressionPrecedence6) is in \(expressionPrecedence6)")
        
        .returns { Operator.isIn($0, $1) }
    
    static let isNotIn = Schema<Operator>("\(expressionPrecedence6) is not in \(expressionPrecedence6)")
        
        .returns { Operator.isNotIn($0, $1) }
    
    static let isOfType = Schema<Operator>("\(expressionPrecedence6) is \(either: "a", "an") \(expressionType)")
        
        .returns { Operator.isOfType($0, $1) }
}

public extension Schemas {
    
    
    static let expressionPrecedence6 = Schema<Expression>("\(expressionPrecedence5)\(or: concatenation)\(or: concatenationWithSpace)")
    
    
    static let concatenation = Schema<Operator>("\(expressionPrecedence5) & \(expressionPrecedence5)")
        
        .returns { Operator.concatenation($0, $1) }
    
    static let concatenationWithSpace = Schema<Operator>("\(expressionPrecedence5) && \(expressionPrecedence5)")
        
        .returns { Operator.concatenationWithSpace($0, $1) }
}

public extension Schemas {
    
    
    static let expressionPrecedence5 = Schema<Expression>("\(expressionPrecedence4)\(or: addition)\(or: substraction)")
    
    
    static let addition = Schema<Operator>("\(expressionPrecedence4) + \(expressionPrecedence4)")
        
        .returns { Operator.addition($0, $1) }
    
    static let substraction = Schema<Operator>("\(expressionPrecedence4) - \(expressionPrecedence4)")
        
        .returns { Operator.substraction($0,$1) }
}

public extension Schemas {
    
    
    static let expressionPrecedence4 = Schema<Expression>("\(expressionPrecedence3)\(or: multiplication)\(or: division)\(or: modulo)\(or: integerDivision)")
    
    
    static let multiplication = Schema<Operator>("\(expressionPrecedence3) * \(expressionPrecedence3)")
        
        .returns { Operator.multiplication($0,$1) }
    
    static let division = Schema<Operator>("\(expressionPrecedence3) / \(expressionPrecedence3)")
        
        .returns { Operator.division($0,$1) }
    
    static let modulo = Schema<Operator>("\(expressionPrecedence3) mod \(expressionPrecedence3)")
        
        .returns { Operator.modulo($0,$1) }
    
    static let integerDivision = Schema<Operator>("\(expressionPrecedence3) div \(expressionPrecedence3)")
        
        .returns { Operator.integerDivision($0,$1) }
}

public extension Schemas {
    
    
    static let expressionPrecedence3 = Schema<Expression>("\(expressionPrecedence2)\(or: exponentiation)")
    
    
    static let exponentiation = Schema<Operator>("\(expressionPrecedence2) ^ \(expressionPrecedence2)")
        
        .returns { Operator.exponentiation($0,$1) }
}

public extension Schemas {
    
    
    static let expressionPrecedence2 = Schema<Expression>("\(factor)\(or: isWithin)\(or: isNotWithin)")
    
    
    static let isWithin = Schema<Operator>("\(factor) is within \(factor)")
        
        .returns { Operator.isWithin($0, $1) }
    
    static let isNotWithin = Schema<Operator>("\(factor) is not within \(factor)")
        
        .returns { Operator.isNotWithin($0, $1) }
    
}
