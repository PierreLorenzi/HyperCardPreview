//
//  Stack.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 26/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


public class Stack {
    
    public var cards: [Card]                = []
    public var backgrounds: [Background]    = []
    
    /* Resources */
    public var resources: ResourceRepository?    = nil
    
    /* Security */
    public var passwordHash: Int?       = nil
    public var userLevel: UserLevel     = .script
    public var cantAbort: Bool          = false
    public var cantDelete: Bool         = false
    public var cantModify: Bool         = false
    public var cantPeek: Bool           = false
    public var privateAccess: Bool      = false
    
    /* HyperCard Version */
    public var versionAtCreation: Version?                              = nil
    public var versionAtLastCompacting: Version?                        = nil
    public var versionAtLastModificationSinceLastCompacting: Version?   = nil
    public var versionAtLastModification: Version?                      = nil
    
    /* Size */
    public var size: Size               = Size(width: 512, height: 342)
    public var windowRectangle: Rectangle?  = nil
    public var screenRectangle: Rectangle?  = nil
    public var scrollPoint: Point?          = nil
    
    /* Patterns */
    public var patterns: [Image]    = []
    
    /* Script */
    public var script: HString      = ""
    
}


