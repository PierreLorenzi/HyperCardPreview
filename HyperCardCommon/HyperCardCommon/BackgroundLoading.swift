//
//  HyperCardFileBackground.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 26/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


public extension Background {
    
    public convenience init(loadFromData data: DataRange, version: FileVersion, loadBitmap: @escaping (Int) -> BitmapBlockReader, styles: [IndexedStyle]) {
        
        let backgroundReader = BackgroundBlockReader(data: data, version: version)
        
        self.init()
        
        /* Read now the scalar fields */
        self.identifier = backgroundReader.readIdentifier()
        
        /* Enable lazy initialization */
        self.initLayerProperties(layerReader: backgroundReader, loadBitmap: loadBitmap, styles: styles)
        
        /* name */
        self.nameProperty.lazyCompute {
            return backgroundReader.readName()
        }
        
        /* script */
        self.scriptProperty.lazyCompute {
            return backgroundReader.readScript()
        }
        
    }
    
}

