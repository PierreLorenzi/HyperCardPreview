//
//  SchemaEditing.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 26/08/2019.
//  Copyright © 2019 Pierre Lorenzi. All rights reserved.
//


public extension Schema {
    
    func setTo(_ value: T) -> Schema<T> {
        
        self.initialValue = value
        
        return self
    }
    
    func when<U>(_ schema: Schema<U>, _ update: @escaping (inout T,U) -> ()) -> Schema<T> {
        
        for i in 0..<self.branches.count {
            
            let subSchemas = self.branches[i].subSchemas
            
            for subSchema in subSchemas {
                
                guard let typeSubSchema = subSchema as? TypedSubSchema<U> else {
                    continue
                }
                guard typeSubSchema.schema === schema else {
                    continue
                }
                
                typeSubSchema.update = Update<U>.change(update)
            }
        }
        
        return self
    }
    
    func when<U>(_ schema: Schema<U>, number: Int, _ update: @escaping (inout T,U) -> ()) -> Schema<T> {
        
        var metCount = 0
        
        for i in 0..<self.branches.count {
            
            let subSchemas = self.branches[i].subSchemas
            
            for subSchema in subSchemas {
                
                guard let typeSubSchema = subSchema as? TypedSubSchema<U> else {
                    continue
                }
                guard typeSubSchema.schema === schema else {
                    continue
                }
                
                metCount += 1
                guard metCount == number else {
                    continue
                }
                
                typeSubSchema.update = Update<U>.change(update)
            }
        }
        
        return self
    }
    
    func initWhen<U>(_ schema: Schema<U>, _ initialization: @escaping (U) -> T) -> Schema<T> {
        
        for i in 0..<self.branches.count {
            
            let subSchemas = self.branches[i].subSchemas
            
            for subSchema in subSchemas {
                
                guard let typeSubSchema = subSchema as? TypedSubSchema<U> else {
                    continue
                }
                guard typeSubSchema.schema === schema else {
                    continue
                }
                
                typeSubSchema.update = Update<U>.initialization(initialization)
            }
        }
        
        return self
    }
}


