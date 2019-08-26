//
//  SchemaEditing.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 26/08/2019.
//  Copyright © 2019 Pierre Lorenzi. All rights reserved.
//


extension Schema {
    
    func build(_ initFields: @escaping () -> ()) {
        
        self.initFields = initFields
    }
    
    func initial(_ makeValue: @escaping () -> T) {
        
        self.makeValue = makeValue
    }
    
    func when<U>(_ schema: Schema<U>, _ update: @escaping (inout T,U) -> ()) {
        
        for i in 0..<self.branches.count {
            
            let subSchemas = self.branches[i].subSchemas
            
            for subSchema in subSchemas {
                
                guard let typeSubSchema = subSchema as? TypedSubSchema<U> else {
                    continue
                }
                
                typeSubSchema.update = update
            }
        }
    }
}


