//
//  ContainerSchemas.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 30/08/2019.
//  Copyright © 2019 Pierre Lorenzi. All rights reserved.
//


public extension Schemas {
    
    
    static let containerDescriptor = Schema<ContainerDescriptor>("\(variableDescriptor)\(or: buttonOrFieldDescriptor)\(or: messageBoxDescriptor)\(or: selectionDescriptor)\(or: chunkDescriptor)")
    
    
    
    static let variableDescriptor = Schema<ContainerDescriptor> { (token: Token) -> ContainerDescriptor? in
        
        /* The token must be: [a-z][a-z0-9]* */
        guard case Token.word(let identifier) = token else {
            return nil
        }
        guard identifier[0].isLetter() else {
            return nil
        }
        guard (1..<identifier.length).allSatisfy({ identifier[$0].isAlphaNumeric() }) else {
            
            return nil
        }
        
        return ContainerDescriptor.variable(identifier: identifier)
    }
    
    static let messageBoxDescriptor = Schema<ContainerDescriptor>("\(maybe: "the") \(either: "message", "msg") box")
    
        .returns(ContainerDescriptor.messageBox)
    
    static let selectionDescriptor = Schema<ContainerDescriptor>("\(maybe: "the") selection")
        
        .returns(ContainerDescriptor.selection)
    
    // stub
    static let buttonOrFieldDescriptor = Schema<ContainerDescriptor>()
    
    // stub
    static let chunkDescriptor = Schema<ContainerChunk>()
}
