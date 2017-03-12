//
//  Part.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 26/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


public class Part {
    
    public var identifier: Int          = 0
    public var name: HString            = ""
    public var style: PartStyle         = .transparent
    public var rectangle: Rectangle     = Rectangle(top: 0, left: 0, bottom: 0, right: 0)
    
    public var visible: Bool            = true
    
    public var script: HString          = ""
    
}

