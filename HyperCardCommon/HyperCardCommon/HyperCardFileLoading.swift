//
//  HyperCardFileLoading.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 06/06/2018.
//  Copyright © 2018 Pierre Lorenzi. All rights reserved.
//


public extension HyperCardFile {
    
    public convenience init(file: ClassicFile, password possiblePassword: HString? = nil, hackEncryption: Bool = true) throws {
        
        let dataRange = DataRange(sharedData: file.dataFork!, offset: 0, length: file.dataFork!.count)
        let fileReader = try HyperCardFileReader(data: dataRange, password: possiblePassword, hackEncryption: hackEncryption)
        
        /* Start initialization */
        self.init()
        
        /* Build the stack */
        self.stackProperty.lazyCompute { () -> Stack in
            return Stack(fileReader: fileReader)
        }
        
        /* Register the resources */
        self.resourcesProperty.lazyCompute { () -> ResourceRepository? in
            guard let resourceFork = file.resourceFork else {
                return nil
            }
            return ResourceRepository(loadFromData: resourceFork)
        }
        
    }
    
}
