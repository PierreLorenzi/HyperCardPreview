//
//  FilePart.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 19/08/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//



public extension Part {
    
    func setupLazyInitialization(partBlock: PartBlock) {
        
        /* Read now the scalar fields */
        self.identifier = partBlock.identifier
        self.style = partBlock.style
        self.visible = partBlock.visible
        self.rectangle = partBlock.rectangle
        
        /* name */
        self.nameProperty.lazyCompute = {
            return partBlock.name
        }
        
        /* script */
        self.scriptProperty.lazyCompute = {
            return partBlock.script
        }
        
    }
    
}
