//
//  SchemaInterpolation.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 26/08/2019.
//  Copyright © 2019 Pierre Lorenzi. All rights reserved.
//



extension Schema: ExpressibleByStringInterpolation, ExpressibleByStringLiteral {
    
    public typealias StringInterpolation = SchemaInterpolation
    public typealias StringLiteralType = String
    
    public convenience init(stringLiteral: String) {
        
        self.init()
        
        fillSchemaWithLiteral(self, stringLiteral)
    }
    
    public convenience init(stringInterpolation: SchemaInterpolation) {
        
        self.init(schemaLiteral: stringInterpolation.schema)
        
        for after in stringInterpolation.afters {
            
            after.apply(to: self)
        }
    }
    
}

private func fillSchemaWithLiteral<U>(_ schema: Schema<U>, _ literal: String) {
    
    let string = HString(stringLiteral: literal)
    return fillSchemaWithHString(schema, string)
}

private func fillSchemaWithHString<U>(_ schema: Schema<U>, _ string: HString) {
    
    let tokens = TokenSequence(string)
    
    for token in tokens {
        
        schema.appendTokenKind(filterBy: { (t: Token) -> Bool in
            t == token
        }, minCount: 1, maxCount: 1, isConstant: true)
    }
}

public struct SchemaInterpolation: StringInterpolationProtocol {
    
    public typealias StringLiteralType = String
    
    let schema = Schema<Void>()
    
    var afters: [After] = []
    
    class After {
        
        func apply<T>(to schema: Schema<T>) {
            fatalError()
        }
    }
    
    private class ComputeBranchAfter<T>: After {
        
        override func apply<U>(to schema: Schema<U>) {
            
            guard T.self == U.self else {
                fatalError()
            }
            
            schema.computeBranchBy(for: schema, { (value: U) -> U in
                return value
            })
        }
    }
    
    public init(literalCapacity: Int, interpolationCount: Int) {
    }
    
    public func appendLiteral(_ literal: String) {
        
        fillSchemaWithLiteral(self.schema, literal)
    }
    
    public func appendInterpolation<U>(_ schema: Schema<U>) {
        
        self.schema.appendSchema(schema, minCount: 1, maxCount: 1, isConstant: nil)
    }
    
    public func appendInterpolation<U>(multiple schema: Schema<U>, atLeast minCount: Int = 0, atMost maxCount: Int? = nil) {
        
        self.schema.appendSchema(schema, minCount: minCount, maxCount: maxCount, isConstant: nil)
    }
    
    public func appendInterpolation<U>(maybe schema: Schema<U>) {
        
        self.schema.appendSchema(schema, minCount: 0, maxCount: 1, isConstant: nil)
    }
    
    public func appendInterpolation(string: HString) {
        
        let stringSchema = Schema<Void>()
        stringSchema.computeSequenceBy({ return () })
        fillSchemaWithHString(stringSchema, string)
        
        self.schema.appendSchema(stringSchema, minCount: 1, maxCount: 1, isConstant: true)
    }
    
    public func appendInterpolation(maybe literal: String) {
        
        let stringSchema = Schema<Void>()
        stringSchema.computeSequenceBy({ return () })
        fillSchemaWithLiteral(stringSchema, literal)
        
        self.schema.appendSchema(stringSchema, minCount: 0, maxCount: 1, isConstant: true)
    }
    
    public func appendInterpolation(either literals: String...) {
                
        let schemas: [Schema<Void>] = literals.map { (literal: String) -> Schema<Void> in
            
            let stringSchema = Schema<Void>()
            stringSchema.computeSequenceBy({ return () })
            fillSchemaWithLiteral(stringSchema, literal)
            
            return stringSchema
        }
        
        let parentSchema = Schema<Void>()
        for schema in schemas {
            
            parentSchema.appendBranchedSchema(schema)
        }
        
        self.schema.appendSchema(parentSchema, minCount: 1, maxCount: 1, isConstant: true)
    }
    
    public func appendInterpolation<U>(or schema: Schema<U>) {
        
        self.schema.appendBranchedSchema(schema)
    }
    
    public func appendInterpolation(_ token: Token) {
        
        self.schema.appendTokenKind(filterBy: { $0 == token }, minCount: 1, maxCount: 1, isConstant: true)
    }
}




