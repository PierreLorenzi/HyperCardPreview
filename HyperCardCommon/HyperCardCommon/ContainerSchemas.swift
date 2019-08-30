//
//  ContainerSchemas.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 30/08/2019.
//  Copyright © 2019 Pierre Lorenzi. All rights reserved.
//


public extension Schemas {
    
    
    static let container = Schema<ContainerDescriptor>("\(variable)\(or: part)\(or: messageBox)\(or: selection)\(or: chunkContainer)")
    
        .when(part) { ContainerDescriptor.part($0) }
    
    
    
    static let variable = Schema<ContainerDescriptor> { (token: Token) -> ContainerDescriptor? in
        
        /* The token must be: [a-z][a-z0-9]* */
        guard case Token.word(let identifier) = token else {
            return nil
        }
        
        return ContainerDescriptor.variable(identifier: identifier)
    }
    
    static let messageBox = Schema<ContainerDescriptor>("\(maybe: "the") \(either: "message", "msg") box")
    
        .returns(ContainerDescriptor.messageBox)
    
    static let selection = Schema<ContainerDescriptor>("\(maybe: "the") selection")
        
        .returns(ContainerDescriptor.selection)
    
    static let chunkContainer = Schema<ContainerDescriptor>("\(chunk) \(containerAgain)")
    
        .returns { ContainerDescriptor.chunk(ChunkContainer(container: $1, chunk: $0)) }
}
