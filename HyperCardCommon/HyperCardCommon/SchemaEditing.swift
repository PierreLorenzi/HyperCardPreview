//
//  SchemaEditing.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 26/08/2019.
//  Copyright © 2019 Pierre Lorenzi. All rights reserved.
//


public extension Schema {
    
    convenience init(tokenKind mapToken: @escaping (Token) -> T?) {
        
        self.init()
        
        self.appendTokenKind(filterBy: { mapToken($0) != nil }, minCount: 1, maxCount: 1, isConstant: false)
        
        self.computeSequenceBySingle({ mapToken($0)! })
    }
    
    func returns(_ value: T) -> Schema<T> {
        
        let compute = { () -> T in return value }
        self.computeSequenceBy(compute)
        return self
    }
    
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
    
    func when<U>(_ schema: Schema<U>, _ compute: @escaping (U) -> T) -> Schema<T> {
        
        self.computeBranchBy(for: schema, compute)
        return self
    }
}


