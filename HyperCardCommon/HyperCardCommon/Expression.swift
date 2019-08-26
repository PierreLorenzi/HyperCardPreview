//
//  Expression.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 09/06/2018.
//  Copyright © 2018 Pierre Lorenzi. All rights reserved.
//


public indirect enum Expression {
    case literal(Literal)
    case `operator`(Operator)
    case containerContent(ContainerDescriptor)
    case functionCall(FunctionCall)
    case property(PropertyDescriptor)
    case chunk(ExpressionChunk)
}

public enum Literal {
    case boolean(Bool)
    case integer(Int)
    case floatingPoint(Double)
    case string(HString)
}

public indirect enum ContainerDescriptor {
    case variable(VariableDescriptor)
    case buttonOrField(ButtonOrFieldDescriptor)
    case messageBox
    case selection
    case chunk(ContainerChunk)
    
    // Menus are included in the doc but in fact there are just for the "put" command, which is a special case
}

public struct VariableDescriptor {
    public var identifier: Identifier
}


