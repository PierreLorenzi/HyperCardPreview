//
//  SchemaEditing.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 26/08/2019.
//  Copyright © 2019 Pierre Lorenzi. All rights reserved.
//


public extension Schema {
    
    func returnsSingle<A>(_ compute: @escaping (A) -> T) -> Schema<T> {
        
        self.computeSequenceBySingle(compute)
        return self
    }
    
    func returns<A,B>(_ compute: @escaping (A,B) -> T) -> Schema<T> {
        
        self.computeSequenceBy(compute)
        return self
    }
    
    func returns<A,B,C>(_ compute: @escaping (A,B,C) -> T) -> Schema<T> {
        
        self.computeSequenceBy(compute)
        return self
    }
    
    func returns<A,B,C,D>(_ compute: @escaping (A,B,C,D) -> T) -> Schema<T> {
        
        self.computeSequenceBy(compute)
        return self
        
    }
    
    func initWhen<U>(_ schema: Schema<U>, _ compute: @escaping (U) -> T) -> Schema<T> {
        
        self.computeBranchBy(for: schema, compute)
        return self
    }
}

public extension Schema where T == Token {
    
    convenience init(token: Token) {
        
        self.init()
        
        self.appendTokenKind(filterBy: { $0 == token }, minCount: 1, maxCount: 1)
    }
    
    convenience init(tokenKind: @escaping (Token) -> Bool) {
        
        self.init()
        
        self.appendTokenKind(filterBy: tokenKind, minCount: 1, maxCount: 1)
    }
}


