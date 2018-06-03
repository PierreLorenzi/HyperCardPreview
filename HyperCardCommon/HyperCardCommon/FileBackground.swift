//
//  HyperCardFileBackground.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 26/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


public extension Background {
    
    public convenience init(backgroundBlock: BackgroundBlock, bitmaps: [BitmapBlock], styles: [StyleBlock.Style]) {
        
        self.init()
        
        /* Read now the scalar fields */
        self.identifier = backgroundBlock.readIdentifier()
        
        /* Enable lazy initialization */
        super.setupLazyInitialization(layerBlock: backgroundBlock, bitmaps: bitmaps, styles: styles)
        
        /* name */
        self.nameProperty.lazyCompute = {
            return backgroundBlock.readName()
        }
        
        /* script */
        self.scriptProperty.lazyCompute = {
            return backgroundBlock.readScript()
        }
        
    }
    
}

