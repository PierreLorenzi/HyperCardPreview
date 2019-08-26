//
//  FlowStatement.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 09/06/2018.
//  Copyright © 2018 Pierre Lorenzi. All rights reserved.
//


public enum FlowStatement {
    
    case `do`(Expression, language: Expression)
    
    case exit(handlerName: Identifier)
    case exitRepeat
    case exitToHyperCard
    
    case global([Identifier])
    
    case `if`([Condition], else: [Statement])
    
    case nextRepeat
    
    case pass(handlerName: Identifier)
    
    case `repeat`([Statement])
    case repeatTimes(Expression, [Statement])
    case repeatUntil(condition: Expression, [Statement])
    case repeatWhile(condition: Expression, [Statement])
    case repeatWithCounter(counterName: Identifier, startValue: Expression, endValue: Expression, [Statement])
    case repeatWithDownCounter(counterName: Identifier, startValue: Expression, endValue: Expression, [Statement])
    
    case `return`
    case returnExpression(Expression)
    
    case send(Expression, to: HyperCardObjectDescriptor)
    case sendToHyperCard(Expression)
    case sendToProgram(Expression, to: ProgramDescriptor, withoutReply: Bool)
}

public struct Condition {
    public var condition: Expression
    public var statements: [Statement]
}

