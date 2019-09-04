//
//  Operator.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 09/06/2018.
//  Copyright © 2018 Pierre Lorenzi. All rights reserved.
//


public enum Operator: Equatable {
    
    case parentheses(Expression)  // ( )
    
    /* Arithmetic Operators */
    case addition(Expression, Expression)  // +
    case substraction(Expression, Expression)  // -
    case opposite(Expression) // -
    case multiplication(Expression, Expression)  // *
    case division(Expression, Expression)  // /
    case exponentiation(Expression, Expression)  // ^
    case modulo(Expression, Expression)  // mod
    case integerDivision(Expression, Expression)  // div
    
    /* Comparison Operators */
    case equal(Expression, Expression)  // =, is
    case unequal(Expression, Expression)  // ≠, <>, is not
    case lesserThan(Expression, Expression)  // <
    case greaterThan(Expression, Expression)  // >
    case lesserThanOrEqual(Expression, Expression)  // <=, ≤
    case greaterThanOrEqual(Expression, Expression)  // >=, ≥
    case contains(Expression, Expression)  // contains
    case isIn(Expression, Expression)  // is in
    case isNotIn(Expression, Expression)  // is not in
    case isWithin(Expression, Expression)  // is within
    case isNotWithin(Expression, Expression)  // is not within
    
    /* Logical Operators */
    case not(Expression)  // not
    case and(Expression, Expression)  // and
    case or(Expression, Expression)  // or
    
    /* Existence Operators */
    case thereIs(ObjectDescriptor)  // is a, is an
    case thereIsNotA(ObjectDescriptor)  // there is not a
    case isOfType(Expression, ExpressionType)  // is a, is an

    /* String Operators */
    case concatenation(Expression, Expression)   // &
    case concatenationWithSpace(Expression, Expression)  // &&
}

public enum ExpressionType: Equatable {
    case number
    case integer
    case point
    case rectangle
    case date
    case logical
}

