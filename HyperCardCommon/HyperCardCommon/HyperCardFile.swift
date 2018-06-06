//
//  HyperCardFile.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 06/06/2018.
//  Copyright © 2018 Pierre Lorenzi. All rights reserved.
//


public class HyperCardFile {

    /// The content stack
    public var stack: Stack {
        get { return self.stackProperty.value }
        set { self.stackProperty.value = newValue }
    }
    public var stackProperty = Property<Stack>(Stack())
    
    
    /// The resources of the stack, present in the resource fork of the file
    public var resources: ResourceRepository? {
        get { return self.resourcesProperty.value }
        set { self.resourcesProperty.value = newValue }
    }
    public var resourcesProperty = Property<ResourceRepository?>(nil)
    
}
