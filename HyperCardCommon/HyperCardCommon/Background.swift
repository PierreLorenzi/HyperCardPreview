//
//  Background.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 26/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//



/// A background
public class Background: Layer {
    
    /// The identifier
    public var identifier: Int {
        get { return self.identifierProperty.value }
        set { self.identifierProperty.value = newValue }
    }
    public var identifierProperty = Property<Int>(0)
    
    /// The name
    public var name: HString {
        get { return self.nameProperty.value }
        set { self.nameProperty.value = newValue }
    }
    public var nameProperty = Property<HString>("")
    
    /// The script
    public var script: HString {
        get { return self.scriptProperty.value }
        set { self.scriptProperty.value = newValue }
    }
    public var scriptProperty = Property<HString>("")
    
}
