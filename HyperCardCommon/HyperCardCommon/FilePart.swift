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
        self.nameProperty.observers.append(LazyInitializer(property: self.nameProperty, initialization: {
            return partBlock.name
        }))
        
        /* script */
        self.scriptProperty.observers.append(LazyInitializer(property: self.scriptProperty, initialization: {
            return partBlock.script
        }))
        
    }
    
}
