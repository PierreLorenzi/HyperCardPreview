//
//  ComparisonOperatorSchemas.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 29/08/2019.
//  Copyright © 2019 Pierre Lorenzi. All rights reserved.
//


public extension Schemas {
    
    
    static let comparisonOperator = Schema<ComparisonOperator>("\(equal1)\(or: equal2)\(or: unequal1)\(or: unequal2)\(or: unequal3)\(or: lesserThan)\(or: greaterThan)\(or: lesserThanOrEqual1)\(or: lesserThanOrEqual2)\(or: greaterThanOrEqual1)\(or: greaterThanOrEqual2)\(or: contains)\(or: isIn)\(or: isNotIn)\(or: isWithin)\(or: isNotWithin)")
    
    
    
    static let equal1 = Schema<ComparisonOperator>("\(expression) = \(expression)")
        
        .returns { ComparisonOperator.equal($0, $1) }
    
    static let equal2 = Schema<ComparisonOperator>("\(expression) is \(expression)")
        
        .returns { ComparisonOperator.equal($0, $1) }
    
    static let unequal1 = Schema<ComparisonOperator>("\(expression) ≠ \(expression)")
        
        .returns { ComparisonOperator.unequal($0, $1) }
    
    static let unequal2 = Schema<ComparisonOperator>("\(expression) <> \(expression)")
        
        .returns { ComparisonOperator.unequal($0, $1) }
    
    static let unequal3 = Schema<ComparisonOperator>("\(expression) is not \(expression)")
        
        .returns { ComparisonOperator.unequal($0, $1) }
    
    static let lesserThan = Schema<ComparisonOperator>("\(expression) < \(expression)")
        
        .returns { ComparisonOperator.lesserThan($0, $1) }
    
    static let greaterThan = Schema<ComparisonOperator>("\(expression) > \(expression)")
        
        .returns { ComparisonOperator.greaterThan($0, $1) }
    
    static let lesserThanOrEqual1 = Schema<ComparisonOperator>("\(expression) <= \(expression)")
        
        .returns { ComparisonOperator.lesserThanOrEqual($0, $1) }
    
    static let lesserThanOrEqual2 = Schema<ComparisonOperator>("\(expression) ≤ \(expression)")
        
        .returns { ComparisonOperator.lesserThanOrEqual($0, $1) }
    
    static let greaterThanOrEqual1 = Schema<ComparisonOperator>("\(expression) >= \(expression)")
        
        .returns { ComparisonOperator.greaterThanOrEqual($0, $1) }
    
    static let greaterThanOrEqual2 = Schema<ComparisonOperator>("\(expression) ≥ \(expression)")
        
        .returns { ComparisonOperator.greaterThanOrEqual($0, $1) }
    
    static let contains = Schema<ComparisonOperator>("\(expression) contains \(expression)")
        
        .returns { ComparisonOperator.contains($0, $1) }
    
    static let isIn = Schema<ComparisonOperator>("\(expression) is in \(expression)")
        
        .returns { ComparisonOperator.isIn($0, $1) }
    
    static let isNotIn = Schema<ComparisonOperator>("\(expression) is not in \(expression)")
        
        .returns { ComparisonOperator.isNotIn($0, $1) }
    
    static let isWithin = Schema<ComparisonOperator>("\(expression) is within \(expression)")
        
        .returns { ComparisonOperator.isWithin($0, $1) }
    
    static let isNotWithin = Schema<ComparisonOperator>("\(expression) is not within \(expression)")
        
        .returns { ComparisonOperator.isNotWithin($0, $1) }

}
