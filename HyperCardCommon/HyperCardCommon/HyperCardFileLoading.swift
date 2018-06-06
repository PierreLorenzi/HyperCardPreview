//
//  HyperCardFileLoading.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 06/06/2018.
//  Copyright © 2018 Pierre Lorenzi. All rights reserved.
//


public extension HyperCardFile {
    
    /// Loads a HyperCard file from a stack file.
    /// <p>
    /// If the stack is private access, you can provide a password or ask to hack the encryption.
    /// The possibility of a password is let in case the hack doesn't work, but it should never happen.
    /// If the stack has a password but is not private access (so not encrypted), it is just opened
    /// without restriction.
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
