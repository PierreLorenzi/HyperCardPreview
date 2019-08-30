//
//  Expression.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 09/06/2018.
//  Copyright © 2018 Pierre Lorenzi. All rights reserved.
//


public indirect enum Expression: Equatable {
    case literal(Literal)
    case `operator`(Operator)
    case containerContent(ContainerDescriptor)
    case functionCall(FunctionCall)
    case property(PropertyDescriptor)
    case chunk(ChunkExpression)
}

public enum Literal: Equatable {
    case boolean(Bool)
    case integer(Int)
    case realNumber(Double)
    case string(HString)
}

public indirect enum ContainerDescriptor: Equatable {
    case variable(identifier: HString)
    case part(PartDescriptor)
    case messageBox
    case selection
    case chunk(ChunkContainer)
    
    // Menus are included in the doc but in fact there are just for the "put" command, which is a special case
}


