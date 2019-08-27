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
        
        let string = HString(stringLiteral: stringLiteral)
        self.branches = [
            Branch(subSchemas: [StringSubSchema(string: string, minCount: 1, maxCount: 1, update: Update<HString>.none)])
        ]
        
        /* If the schema must return a string, let's return itself */
        if let stringValue = string as? T {
            self.initialValue = stringValue
        }
    }
    
    public convenience init(stringInterpolation: SchemaInterpolation) {
        
        self.init()
        
        let subSchemas: [SubSchema] = stringInterpolation.creators.map({ $0.create(for: self) })
        let branch = Branch(subSchemas: subSchemas)
        
        self.branches = [branch]
    }
}

public struct SchemaInterpolation: StringInterpolationProtocol {
    
    public typealias StringLiteralType = String
    
    fileprivate var creators: [SubSchemaCreator] = []
    
    fileprivate class SubSchemaCreator {
        
        var minCount: Int
        var maxCount: Int?
        
        init(minCount: Int, maxCount: Int?) {
            self.minCount = minCount
            self.maxCount = maxCount
        }
        
        func create<T>(for schema: Schema<T>) -> Schema<T>.SubSchema {
            fatalError()
        }
    }
    
    private class TypedSubSchemaCreator<U>: SubSchemaCreator {
        
        var schema: Schema<U>
        
        init(schema: Schema<U>, minCount: Int, maxCount: Int?) {
            
            self.schema = schema
            
            super.init(minCount: minCount, maxCount: maxCount)
        }
        
        override func create<T>(for _: Schema<T>) -> Schema<T>.SubSchema {
            
            if T.self == U.self {
                
                /* So, if an interpolation has a type, the strings will pass the values */
                return Schema<T>.TypedSubSchema<U>(schema: self.schema, minCount: self.minCount, maxCount: self.maxCount, update: Schema<T>.Update<U>.initialization({ (value: U) -> T in
                    return value as! T
                }))
            }
            
            return Schema<T>.TypedSubSchema<U>(schema: self.schema, minCount: self.minCount, maxCount: self.maxCount, update: Schema<T>.Update<U>.none)
        }
    }
    
    private class StringSubSchemaCreator: SubSchemaCreator {
        
        var string: HString
        
        init(string: HString, minCount: Int, maxCount: Int) {
            
            self.string = string
            
            super.init(minCount: minCount, maxCount: maxCount)
        }
        
        override func create<T>(for _: Schema<T>) -> Schema<T>.SubSchema {
            
            return Schema<T>.StringSubSchema(string: self.string, minCount: self.minCount, maxCount: self.maxCount, update: Schema<T>.Update<HString>.none)
        }
    }
    
    public init(literalCapacity: Int, interpolationCount: Int) {
        
    }
    
    public mutating func appendLiteral(_ literal: String) {
        
        let string = HString(converting: literal)!
        let creator = StringSubSchemaCreator(string: string, minCount: 1, maxCount: 1)
        
        self.creators.append(creator)
    }
    
    public mutating func appendInterpolation<U>(_ schema: Schema<U>) {
        
        let creator = TypedSubSchemaCreator(schema: schema, minCount: 1, maxCount: 1)
        
        self.creators.append(creator)
    }
    
    public mutating func appendInterpolation<U>(multiple schema: Schema<U>) {
        
        let creator = TypedSubSchemaCreator(schema: schema, minCount: 0, maxCount: nil)
        
        self.creators.append(creator)
    }
    
    public mutating func appendInterpolation<U>(maybe schema: Schema<U>) {
        
        let creator = TypedSubSchemaCreator(schema: schema, minCount: 0, maxCount: 1)
        
        self.creators.append(creator)
    }
    
    public mutating func appendInterpolation<U,V>(either schema1: Schema<U>, either schema2: Schema<V>) {
        
        // We can't make a typed disjunction in a string literal
        let schema = Schema<Void>()
        schema.initialValue = ()
        schema.branches = [Schema<Void>.Branch(subSchemas: [Schema<Void>.TypedSubSchema<U>(schema: schema1, minCount: 1, maxCount: 1, update: Schema<Void>.Update<U>.none)]), Schema<Void>.Branch(subSchemas: [Schema<Void>.TypedSubSchema<V>(schema: schema2, minCount: 1, maxCount: 1, update: Schema<Void>.Update<V>.none)])]
        
        let creator = TypedSubSchemaCreator(schema: schema, minCount: 0, maxCount: 1)
        
        self.creators.append(creator)
    }
    
    public mutating func appendInterpolation<U>(oneOf schemas: [Schema<U>]) {
        
        // We can't make a typed disjunction in a string literal
        let globalSchema = Schema<U>()
        globalSchema.branches = schemas.map({ (schema: Schema<U>) -> Schema<U>.Branch in
            Schema<U>.Branch(subSchemas: [Schema<U>.TypedSubSchema<U>(schema: schema, minCount: 1, maxCount: 1, update: Schema<U>.Update<U>.initialization({ (u: U) -> U in return u }))])
        })
        
        let creator = TypedSubSchemaCreator(schema: globalSchema, minCount: 0, maxCount: 1)
        
        self.creators.append(creator)
    }
}




