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
    public var identifier: Int          = 0
    
    /// The name
    public var name: HString            = ""
    
    /// The visual style of the part
    public var style: PartStyle         = .transparent
    
    /// The visual location of the part in its containing layer
    public var rectangle: Rectangle     = Rectangle(top: 0, left: 0, bottom: 0, right: 0)
    
    /// Whether the part appears on the screen
    public var visible: Bool            = true
    
    /// The script
    public var script: HString          = ""
    
}

