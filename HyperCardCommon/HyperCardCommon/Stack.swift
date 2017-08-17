//
//  Stack.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 26/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


/// A stack, as an object, not as a file
public class Stack {
    
    /// The card list
    public var cards: [Card]                = []
    
    /// The background list. Backgrounds aren't just linked by cards, they form a list and have indexes.
    /// In a script there can be: "the third background"
    public var backgrounds: [Background]    = []
    
    /// The resources of the stack, present in the resource fork of the file
    public var resources: ResourceRepository?    = nil
    
    /// The hash of the password. It is just used to check the passwork, the file is not encrypted.
    public var passwordHash: Int?       = nil
    
    /// The user level used when browsing the stack
    public var userLevel: UserLevel     = .script
    
    /// Whether or not the user can use Command-period to stop execution of scripts
    public var cantAbort: Bool          = false
    
    /// Whether or not the user can delete the specified stack
    public var cantDelete: Bool         = false
    
    /// Whether or not the stack can be changed in any way.
    public var cantModify: Bool         = false
    
    /// Whether or not the user can look at button or field scripts with Command-Option
    public var cantPeek: Bool           = false
    
    /// If set, the user must enter the password before opening the stack
    public var privateAccess: Bool      = false
    
    /// The version of HyperCard used to create this stack
    public var versionAtCreation: Version?                              = nil
    
    /// The version of HyperCard that last compacted this stack
    public var versionAtLastCompacting: Version?                        = nil
    
    /// The version of HyperCard that last modified the stack
    public var versionAtLastModificationSinceLastCompacting: Version?   = nil
    
    /// The version of HyperCard that first modified the stack
    public var versionAtLastModification: Version?                      = nil
    
    /// The size of the card window
    public var size: Size               = Size(width: 512, height: 342)
    
    /// The position of the card window in the screen
    public var windowRectangle: Rectangle?  = nil
    
    /// The resolution of the screen where the card window was opened
    public var screenRectangle: Rectangle?  = nil
    
    /// If the window is too small for the card, the origin of the window rectangle in the card
    public var scrollPoint: Point?          = nil
    
    /// The graphic patterns, there are 40 of them
    public var patterns: [Image]    = []
    
    /// The script
    public var script: HString      = ""
    
}


