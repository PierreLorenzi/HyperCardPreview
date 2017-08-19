//
//  FilePart.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 19/08/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//



public extension Part {
    
    func setupLazyInitialization(partBlock: PartBlock) {
        
        /* identifier */
        self.identifierProperty.observers.append(LazyInitializer(property: self.identifierProperty, initialization: {
            return partBlock.identifier
        }))
        
        /* name */
        self.nameProperty.observers.append(LazyInitializer(property: self.nameProperty, initialization: {
            return partBlock.name
        }))
        
        /* style */
        self.styleProperty.observers.append(LazyInitializer(property: self.styleProperty, initialization: {
            return partBlock.style
        }))
        
        /* visible */
        self.visibleProperty.observers.append(LazyInitializer(property: self.visibleProperty, initialization: {
            return partBlock.visible
        }))
        
        /* rectangle */
        self.rectangleProperty.observers.append(LazyInitializer(property: self.rectangleProperty, initialization: {
            return partBlock.rectangle
        }))
        
        /* script */
        self.scriptProperty.observers.append(LazyInitializer(property: self.scriptProperty, initialization: {
            return partBlock.script
        }))
        
    }
    
}
