//
//  HyperCardFileBackground.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 26/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


public extension Background {
    
    /// Loads a background from a BKGD data block inside the stack file data fork.
    public convenience init(loadFromData data: DataRange, version: FileVersion, loadBitmap: @escaping (Int) -> MaskedImage, styles: [IndexedStyle]) {
        
        let backgroundReader = BackgroundBlockReader(data: data, version: version)
        
        self.init()
        
        /* Read now the scalar fields */
        self.identifier = backgroundReader.readIdentifier()
        
        /* Enable lazy initialization */
        _ = self.initLayerProperties(layerReader: backgroundReader, version: version, layerType: LayerType.background, loadBitmap: loadBitmap, styles: styles)
        
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

