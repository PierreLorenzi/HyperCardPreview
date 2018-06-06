//
//  HyperCardFileLoading.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 06/06/2018.
//  Copyright © 2018 Pierre Lorenzi. All rights reserved.
//


public extension HyperCardFile {
    
    public convenience init(file: ClassicFile, password possiblePassword: HString? = nil, hackEncryption: Bool = true) throws {
        
        /* Start initialization */
        self.init()
        
        /* Build the stack */
        self.stack = try Stack(loadFromData: file.dataFork!, password: possiblePassword, hackEncryption: hackEncryption)
        
        /* Register the resources */
        self.resourcesProperty.lazyCompute { () -> ResourceRepository? in
            guard let resourceFork = file.resourceFork else {
                return nil
            }
            return ResourceRepository(loadFromData: resourceFork)
        }
        
    }
    
}
