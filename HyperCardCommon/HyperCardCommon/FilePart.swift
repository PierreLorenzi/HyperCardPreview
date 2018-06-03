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
        self.identifier = partBlock.readIdentifier()
        self.style = partBlock.readStyle()
        self.visible = partBlock.readVisible()
        self.rectangle = partBlock.readRectangle()
        
        /* name */
        self.nameProperty.lazyCompute = {
            return partBlock.readName()
        }
        
        /* script */
        self.scriptProperty.lazyCompute = {
            return partBlock.readScript()
        }
        
    }
    
}
