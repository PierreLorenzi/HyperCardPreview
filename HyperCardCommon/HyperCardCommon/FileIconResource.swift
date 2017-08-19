//
//  FileIcon.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 27/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//



private let fakeImage = Image(width: 0, height: 0)


public extension Resource where T == Image {
    
    public convenience init(resource: IconResourceBlock) {
        
        self.init(identifier: resource.identifier, name: resource.name, type: ResourceTypes.icon, content: fakeImage)
        
        /* Enable lazy initialization */
        
        /* content */
        self.contentProperty.observers.append(LazyInitializer(property: self.contentProperty, initialization: {
            return resource.image
        }))
        
    }
    
}

