//
//  OperatorSchemas.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 30/08/2019.
//  Copyright © 2019 Pierre Lorenzi. All rights reserved.
//


public extension Schemas {
    
    
    static let expression = Schema<Expression>("\(factor)\(or: or)\(or: and)\(or: equal1)\(or: equal2)\(or: unequal1)\(or: unequal2)\(or: unequal3)\(or: lesserThan)\(or: greaterThan)\(or: lesserThanOrEqual1)\(or: lesserThanOrEqual2)\(or: greaterThanOrEqual1)\(or: greaterThanOrEqual2)\(or: contains)\(or: isIn)\(or: isNotIn)\(or: isOfType)\(or: concatenation)\(or: concatenationWithSpace)\(or: addition)\(or: substraction)\(or: multiplication)\(or: division)\(or: modulo)\(or: integerDivision)\(or: exponentiation)\(or: isWithin)\(or: isNotWithin)")
    
    
    
    static let or = Schema<Expression>("\(Expression) or \(Expression)")
        
        .returns { Expression.operator(Operator.or($0, $1)) }
    
    static let and = Schema<Expression>("\(Expression) and \(Expression)")
        
        .returns { Expression.operator(Operator.and($0, $1)) }
    
    static let equal1 = Schema<Expression>("\(Expression) = \(Expression)")
        
        .returns { Expression.operator(Operator.equal($0, $1)) }
    
    static let equal2 = Schema<Expression>("\(Expression) is \(Expression)")
        
        .returns { Expression.operator(Operator.equal($0, $1)) }
    
    static let unequal1 = Schema<Expression>("\(Expression) ≠ \(Expression)")
        
        .returns { Expression.operator(Operator.unequal($0, $1)) }
    
    static let unequal2 = Schema<Expression>("\(Expression) <> \(Expression)")
        
        .returns { Expression.operator(Operator.unequal($0, $1)) }
    
    static let unequal3 = Schema<Expression>("\(Expression) is not \(Expression)")
        
        .returns { Expression.operator(Operator.unequal($0, $1)) }
    
    static let lesserThan = Schema<Expression>("\(Expression) < \(Expression)")
        
        .returns { Expression.operator(Operator.lesserThan($0, $1)) }
    
    static let greaterThan = Schema<Expression>("\(Expression) > \(Expression)")
        
        .returns { Expression.operator(Operator.greaterThan($0, $1)) }
    
    static let lesserThanOrEqual1 = Schema<Expression>("\(Expression) <= \(Expression)")
        
        .returns { Expression.operator(Operator.lesserThanOrEqual($0, $1)) }
    
    static let lesserThanOrEqual2 = Schema<Expression>("\(Expression) ≤ \(Expression)")
        
        .returns { Expression.operator(Operator.lesserThanOrEqual($0, $1)) }
    
    static let greaterThanOrEqual1 = Schema<Expression>("\(Expression) >= \(Expression)")
        
        .returns { Expression.operator(Operator.greaterThanOrEqual($0, $1)) }
    
    static let greaterThanOrEqual2 = Schema<Expression>("\(Expression) ≥ \(Expression)")
        
        .returns { Expression.operator(Operator.greaterThanOrEqual($0, $1)) }
    
    static let contains = Schema<Expression>("\(Expression) contains \(Expression)")
        
        .returns { Expression.operator(Operator.contains($0, $1)) }
    
    static let isIn = Schema<Expression>("\(Expression) is in \(Expression)")
        
        .returns { Expression.operator(Operator.isIn($0, $1)) }
    
    static let isNotIn = Schema<Expression>("\(Expression) is not in \(Expression)")
        
        .returns { Expression.operator(Operator.isNotIn($0, $1)) }
    
    static let isOfType = Schema<Expression>("\(Expression) is \(either: "a", "an") \(expressionType)")
        
        .returns { Expression.operator(Operator.isOfType($0, $1)) }
    
    static let concatenation = Schema<Expression>("\(Expression) & \(Expression)")
        
        .returns { Expression.operator(Operator.concatenation($0, $1)) }
    
    static let concatenationWithSpace = Schema<Expression>("\(Expression) && \(Expression)")
        
        .returns { Expression.operator(Operator.concatenationWithSpace($0, $1)) }
    
    static let addition = Schema<Expression>("\(Expression) + \(Expression)")
        
        .returns { Expression.operator(Operator.addition($0, $1)) }
    
    static let substraction = Schema<Expression>("\(Expression) - \(Expression)")
        
        .returns { Expression.operator(Operator.substraction($0,$1)) }
    
    static let multiplication = Schema<Expression>("\(Expression) * \(Expression)")
        
        .returns { Expression.operator(Operator.multiplication($0,$1)) }
    
    static let division = Schema<Expression>("\(Expression) / \(Expression)")
        
        .returns { Expression.operator(Operator.division($0,$1)) }
    
    static let modulo = Schema<Expression>("\(Expression) mod \(Expression)")
        
        .returns { Expression.operator(Operator.modulo($0,$1)) }
    
    static let integerDivision = Schema<Expression>("\(Expression) div \(Expression)")
        
        .returns { Expression.operator(Operator.integerDivision($0,$1)) }

    static let exponentiation = Schema<Expression>("\(Expression) ^ \(Expression)")
        
        .returns { Expression.operator(Operator.exponentiation($0,$1)) }

    static let isWithin = Schema<Expression>("\(factor) is within \(factor)")
        
        .returns { Expression.operator(Operator.isWithin($0, $1)) }
    
    static let isNotWithin = Schema<Expression>("\(factor) is not within \(factor)")
        
        .returns { Expression.operator(Operator.isNotWithin($0, $1)) }
    
}
