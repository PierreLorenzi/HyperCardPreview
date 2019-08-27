//
//  SchemaEditing.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 26/08/2019.
//  Copyright © 2019 Pierre Lorenzi. All rights reserved.
//


public extension Schema {
    
    func build(_ initFields: @escaping () -> ()) {
        
        self.initFields = initFields
    }
    
    func when<U>(_ schema: Schema<U>, _ update: @escaping (inout T,U) -> ()) {
        
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
    }
    
    func when<U>(_ schema: Schema<U>, number: Int, _ update: @escaping (inout T,U) -> ()) {
        
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
                return
            }
        }
    }
    
    func initWhen<U>(_ schema: Schema<U>, _ initialization: @escaping (U) -> T) {
        
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
    }
}


