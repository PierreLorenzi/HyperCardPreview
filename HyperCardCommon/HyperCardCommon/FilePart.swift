//
//  FilePart.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 19/08/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//



public extension Part {
    
    func initPartProperties(partReader: PartBlockReader) {
        
        /* Read now the scalar fields */
        self.identifier = partReader.readIdentifier()
        self.style = partReader.readStyle()
        self.visible = partReader.readVisible()
        self.rectangle = partReader.readRectangle()
        
        /* name */
        self.nameProperty.lazyCompute = {
            return partReader.readName()
        }
        
        /* script */
        self.scriptProperty.lazyCompute = {
            return partReader.readScript()
        }
        
    }
    
}
