//
//  Factor.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 30/08/2019.
//  Copyright © 2019 Pierre Lorenzi. All rights reserved.
//


public extension Schemas {
    
    
    static let factor = Schema<Expression>("\(literal)\(or: unaryOperator)\(or: container)\(or: functionCall)\(or: chunkExpression)")
    
        .when(literal) { Expression.literal($0) }
        
        .when(unaryOperator) { Expression.operator($0) }
        
        .when(container) { Expression.containerContent($0) }
        
        .when(functionCall) { Expression.functionCall($0) }
        
        .when(chunkExpression) { Expression.chunk($0) }
    
    // not finished
    
    
    static let chunkExpression = Schema<ChunkExpression>("\(chunk) \(factorAgain)")
}
