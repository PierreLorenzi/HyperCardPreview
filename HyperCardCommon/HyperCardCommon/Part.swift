//
//  Part.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 26/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


/// An abstract class for fields and buttons
public class Part {
    
    /// The identifier
    public var identifier: Int {
        get { return self.identifierProperty.value }
        set { self.identifierProperty.value = newValue }
    }
    public let identifierProperty = Property<Int>(0)
    
    /// The name
    public var name: HString {
        get { return self.nameProperty.value }
        set { self.nameProperty.value = newValue }
    }
    public let nameProperty = Property<HString>("")
    
    /// The visual style of the part
    public var style: PartStyle {
        get { return self.styleProperty.value }
        set { self.styleProperty.value = newValue }
    }
    public let styleProperty = Property<PartStyle>(.transparent)
    
    /// The visual location of the part in its containing layer
    public var rectangle: Rectangle {
        get { return self.rectangleProperty.value }
        set { self.rectangleProperty.value = newValue }
    }
    public let rectangleProperty = Property<Rectangle>(Rectangle(top: 0, left: 0, bottom: 0, right: 0))
    
    /// Whether the part appears on the screen
    public var visible: Bool {
        get { return self.visibleProperty.value }
        set { self.visibleProperty.value = newValue }
    }
    public let visibleProperty = Property<Bool>(true)
    
    /// The script
    public var script: HString {
        get { return self.scriptProperty.value }
        set { self.scriptProperty.value = newValue }
    }
    public let scriptProperty = Property<HString>("")
    
}

