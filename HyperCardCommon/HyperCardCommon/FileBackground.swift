//
//  HyperCardFileBackground.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 26/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


public extension Background {
    
    public convenience init(backgroundBlock: BackgroundBlock, fileContent: HyperCardFileData) {
        
        self.init()
        
        /* Read now the scalar fields */
        self.identifier = backgroundBlock.identifier
        
        /* Enable lazy initialization */
        super.setupLazyInitialization(layerBlock: backgroundBlock, fileContent: fileContent)
        
        /* name */
        self.nameProperty.compute = {
            return backgroundBlock.name
        }
        
        /* script */
        self.scriptProperty.compute = {
            return backgroundBlock.script
        }
        
    }
    
}

