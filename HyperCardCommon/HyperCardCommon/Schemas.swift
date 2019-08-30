//
//  CycleSchemas.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 30/08/2019.
//  Copyright © 2019 Pierre Lorenzi. All rights reserved.
//


/// The HyperTalk schemas for parsing
public enum Schemas {
    
}

public extension Schemas {
    
    /* Represents 'factor', but used to avoid dependency cycles */
    static let factorAgain: Schema<Expression> = buildFakeSchema()
    
    /* Represents 'expression', but used to avoid dependency cycles */
    static let expressionAgain: Schema<Expression> = buildFakeSchema()
    
    // Just a temporary stub
    static let objectDescriptor: Schema<ObjectDescriptor> = buildFakeSchema()
    
    static func finalizeSchemas() {
        
        /* Join the dependency cycles. It makes a strong dependency cycle but
         the objets are all static anyway */
        factorAgain.appendSchema(factor, minCount: 1, maxCount: 1, isConstant: nil)
        expressionAgain.appendSchema(expression, minCount: 1, maxCount: 1, isConstant: nil)
        
    }
    
    private static func buildFakeSchema<T>() -> Schema<T> {
        
        let schema = Schema<T>()
        
        /* As the schema is empty, it will tell the others it is constant, so prevent it */
        schema.isConstant = false
        
        return schema
    }
}
