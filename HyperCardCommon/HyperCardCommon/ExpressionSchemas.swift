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
    
    
    static let or = Schema<Expression>("\(expressionPrecedence9) or \(expressionPrecedence9)")
        
        .returns { Expression.operator(Operator.or($0, $1)) }
}

public extension Schemas {
    
    
    static let expressionPrecedence9 = Schema<Expression>("\(expressionPrecedence8)\(or: and)")
    
    
    static let and = Schema<Expression>("\(expressionPrecedence8) and \(expressionPrecedence8)")
        
        .returns { Expression.operator(Operator.and($0, $1)) }
}

public extension Schemas {
    
    
    static let expressionPrecedence8 = Schema<Expression>("\(expressionPrecedence7)\(or: equal1)\(or: equal2)\(or: unequal1)\(or: unequal2)\(or: unequal3)")
    
    
    static let equal1 = Schema<Expression>("\(expressionPrecedence7) = \(expressionPrecedence7)")
        
        .returns { Expression.operator(Operator.equal($0, $1)) }
    
    static let equal2 = Schema<Expression>("\(expressionPrecedence7) is \(expressionPrecedence7)")
        
        .returns { Expression.operator(Operator.equal($0, $1)) }
    
    static let unequal1 = Schema<Expression>("\(expressionPrecedence7) ≠ \(expressionPrecedence7)")
        
        .returns { Expression.operator(Operator.unequal($0, $1)) }
    
    static let unequal2 = Schema<Expression>("\(expressionPrecedence7) <> \(expressionPrecedence7)")
        
        .returns { Expression.operator(Operator.unequal($0, $1)) }
    
    static let unequal3 = Schema<Expression>("\(expressionPrecedence7) is not \(expressionPrecedence7)")
        
        .returns { Expression.operator(Operator.unequal($0, $1)) }
}

public extension Schemas {
    
    
    static let expressionPrecedence7 = Schema<Expression>("\(expressionPrecedence6)\(or: lesserThan)\(or: greaterThan)\(or: lesserThanOrEqual1)\(or: lesserThanOrEqual2)\(or: greaterThanOrEqual1)\(or: greaterThanOrEqual2)\(or: contains)\(or: isIn)\(or: isNotIn)\(or: isOfType)")
    
    
    static let lesserThan = Schema<Expression>("\(expressionPrecedence6) < \(expressionPrecedence6)")
        
        .returns { Expression.operator(Operator.lesserThan($0, $1)) }
    
    static let greaterThan = Schema<Expression>("\(expressionPrecedence6) > \(expressionPrecedence6)")
        
        .returns { Expression.operator(Operator.greaterThan($0, $1)) }
    
    static let lesserThanOrEqual1 = Schema<Expression>("\(expressionPrecedence6) <= \(expressionPrecedence6)")
        
        .returns { Expression.operator(Operator.lesserThanOrEqual($0, $1)) }
    
    static let lesserThanOrEqual2 = Schema<Expression>("\(expressionPrecedence6) ≤ \(expressionPrecedence6)")
        
        .returns { Expression.operator(Operator.lesserThanOrEqual($0, $1)) }
    
    static let greaterThanOrEqual1 = Schema<Expression>("\(expressionPrecedence6) >= \(expressionPrecedence6)")
        
        .returns { Expression.operator(Operator.greaterThanOrEqual($0, $1)) }
    
    static let greaterThanOrEqual2 = Schema<Expression>("\(expressionPrecedence6) ≥ \(expressionPrecedence6)")
        
        .returns { Expression.operator(Operator.greaterThanOrEqual($0, $1)) }
    
    static let contains = Schema<Expression>("\(expressionPrecedence6) contains \(expressionPrecedence6)")
        
        .returns { Expression.operator(Operator.contains($0, $1)) }
    
    static let isIn = Schema<Expression>("\(expressionPrecedence6) is in \(expressionPrecedence6)")
        
        .returns { Expression.operator(Operator.isIn($0, $1)) }
    
    static let isNotIn = Schema<Expression>("\(expressionPrecedence6) is not in \(expressionPrecedence6)")
        
        .returns { Expression.operator(Operator.isNotIn($0, $1)) }
    
    static let isOfType = Schema<Expression>("\(expressionPrecedence6) is \(either: "a", "an") \(expressionType)")
        
        .returns { Expression.operator(Operator.isOfType($0, $1)) }
}

public extension Schemas {
    
    
    static let expressionPrecedence6 = Schema<Expression>("\(expressionPrecedence5)\(or: concatenation)\(or: concatenationWithSpace)")
    
    
    static let concatenation = Schema<Expression>("\(expressionPrecedence5) & \(expressionPrecedence5)")
        
        .returns { Expression.operator(Operator.concatenation($0, $1)) }
    
    static let concatenationWithSpace = Schema<Expression>("\(expressionPrecedence5) && \(expressionPrecedence5)")
        
        .returns { Expression.operator(Operator.concatenationWithSpace($0, $1)) }
}

public extension Schemas {
    
    
    static let expressionPrecedence5 = Schema<Expression>("\(expressionPrecedence4)\(or: addition)\(or: substraction)")
    
    
    static let addition = Schema<Expression>("\(expressionPrecedence4) + \(expressionPrecedence4)")
        
        .returns { Expression.operator(Operator.addition($0, $1)) }
    
    static let substraction = Schema<Expression>("\(expressionPrecedence4) - \(expressionPrecedence4)")
        
        .returns { Expression.operator(Operator.substraction($0,$1)) }
}

public extension Schemas {
    
    
    static let expressionPrecedence4 = Schema<Expression>("\(expressionPrecedence3)\(or: multiplication)\(or: division)\(or: modulo)\(or: integerDivision)")
    
    
    static let multiplication = Schema<Expression>("\(expressionPrecedence3) * \(expressionPrecedence3)")
        
        .returns { Expression.operator(Operator.multiplication($0,$1)) }
    
    static let division = Schema<Expression>("\(expressionPrecedence3) / \(expressionPrecedence3)")
        
        .returns { Expression.operator(Operator.division($0,$1)) }
    
    static let modulo = Schema<Expression>("\(expressionPrecedence3) mod \(expressionPrecedence3)")
        
        .returns { Expression.operator(Operator.modulo($0,$1)) }
    
    static let integerDivision = Schema<Expression>("\(expressionPrecedence3) div \(expressionPrecedence3)")
        
        .returns { Expression.operator(Operator.integerDivision($0,$1)) }
}

public extension Schemas {
    
    
    static let expressionPrecedence3 = Schema<Expression>("\(expressionPrecedence2)\(or: exponentiation)")
    
    
    static let exponentiation = Schema<Expression>("\(expressionPrecedence2) ^ \(expressionPrecedence2)")
        
        .returns { Expression.operator(Operator.exponentiation($0,$1)) }
}

public extension Schemas {
    
    
    static let expressionPrecedence2 = Schema<Expression>("\(factor)\(or: isWithin)\(or: isNotWithin)")
    
    
    static let isWithin = Schema<Expression>("\(factor) is within \(factor)")
        
        .returns { Expression.operator(Operator.isWithin($0, $1)) }
    
    static let isNotWithin = Schema<Expression>("\(factor) is not within \(factor)")
        
        .returns { Expression.operator(Operator.isNotWithin($0, $1)) }
    
}
