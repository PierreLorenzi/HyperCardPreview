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
            Branch(subSchemas: [StringSubSchema(string: string, minCount: 1, maxCount: 1, update: { (_: inout T, _: HString) in })])
        ]
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
        var maxCount: Int
        
        init(minCount: Int, maxCount: Int) {
            self.minCount = minCount
            self.maxCount = maxCount
        }
        
        func create<T>(for schema: Schema<T>) -> Schema<T>.SubSchema {
            fatalError()
        }
    }
    
    private class TypedSubSchemaCreator<U>: SubSchemaCreator {
        
        var schema: Schema<U>
        
        init(schema: Schema<U>, minCount: Int, maxCount: Int) {
            
            self.schema = schema
            
            super.init(minCount: minCount, maxCount: maxCount)
        }
        
        override func create<T>(for _: Schema<T>) -> Schema<T>.SubSchema {
            
            return Schema<T>.TypedSubSchema<U>(schema: self.schema, minCount: self.minCount, maxCount: self.maxCount, update: { (_: inout T, _: U) in })
        }
    }
    
    private class StringSubSchemaCreator: SubSchemaCreator {
        
        var string: HString
        
        init(string: HString, minCount: Int, maxCount: Int) {
            
            self.string = string
            
            super.init(minCount: minCount, maxCount: maxCount)
        }
        
        override func create<T>(for _: Schema<T>) -> Schema<T>.SubSchema {
            
            return Schema<T>.StringSubSchema(string: self.string, minCount: self.minCount, maxCount: self.maxCount, update: { (_: inout T, _: HString) in })
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
}




