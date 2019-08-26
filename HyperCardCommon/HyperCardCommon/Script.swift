//
//  Script.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 09/06/2018.
//  Copyright © 2018 Pierre Lorenzi. All rights reserved.
//


public struct Script {
    
    var handlers: [Handler]
}

public struct Handler {
    
    var name: HString
    var type: HandlerType
    var argumentNames: [HString]
    var statements: [Statement]
}

public enum HandlerType {
    case message
    case function
}

public enum Statement {
    case flow(FlowStatement)
    case command(Command)
    case message(MessageCall)
}

public struct MessageCall {
    public var identifier: Identifier
    public var arguments: [Expression]
}
