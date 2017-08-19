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
    public var cards: [Card] {
        get { return self.cardsProperty.value }
        set { self.cardsProperty.value = newValue }
    }
    public var cardsProperty = Property<[Card]>([])
    
    /// The background list. Backgrounds aren't just linked by cards, they form a list and have indexes.
    /// In a script there can be: "the third background"
    public var backgrounds: [Background] {
        get { return self.backgroundsProperty.value }
        set { self.backgroundsProperty.value = newValue }
    }
    public var backgroundsProperty = Property<[Background]>([])
    
    /// The resources of the stack, present in the resource fork of the file
    public var resources: ResourceRepository? {
        get { return self.resourcesProperty.value }
        set { self.resourcesProperty.value = newValue }
    }
    public var resourcesProperty = Property<ResourceRepository?>(nil)
    
    /// The hash of the password. It is just used to check the passwork, the file is not encrypted.
    public var passwordHash: Int? {
        get { return self.passwordHashProperty.value }
        set { self.passwordHashProperty.value = newValue }
    }
    public var passwordHashProperty = Property<Int?>(nil)
    
    /// The user level used when browsing the stack
    public var userLevel: UserLevel {
        get { return self.userLevelProperty.value }
        set { self.userLevelProperty.value = newValue }
    }
    public var userLevelProperty = Property<UserLevel>(.script)
    
    /// Whether or not the user can use Command-period to stop execution of scripts
    public var cantAbort: Bool {
        get { return self.cantAbortProperty.value }
        set { self.cantAbortProperty.value = newValue }
    }
    public var cantAbortProperty = Property<Bool>(false)
    
    /// Whether or not the user can delete the specified stack
    public var cantDelete: Bool {
        get { return self.cantDeleteProperty.value }
        set { self.cantDeleteProperty.value = newValue }
    }
    public var cantDeleteProperty = Property<Bool>(false)
    
    /// Whether or not the stack can be changed in any way.
    public var cantModify: Bool {
        get { return self.cantModifyProperty.value }
        set { self.cantModifyProperty.value = newValue }
    }
    public var cantModifyProperty = Property<Bool>(false)
    
    /// Whether or not the user can look at button or field scripts with Command-Option
    public var cantPeek: Bool {
        get { return self.cantPeekProperty.value }
        set { self.cantPeekProperty.value = newValue }
    }
    public var cantPeekProperty = Property<Bool>(false)
    
    /// If set, the user must enter the password before opening the stack
    public var privateAccess: Bool {
        get { return self.privateAccessProperty.value }
        set { self.privateAccessProperty.value = newValue }
    }
    public var privateAccessProperty = Property<Bool>(false)
    
    /// The version of HyperCard used to create this stack
    public var versionAtCreation: Version? {
        get { return self.versionAtCreationProperty.value }
        set { self.versionAtCreationProperty.value = newValue }
    }
    public var versionAtCreationProperty = Property<Version?>(nil)
    
    /// The version of HyperCard that last compacted this stack
    public var versionAtLastCompacting: Version? {
        get { return self.versionAtLastCompactingProperty.value }
        set { self.versionAtLastCompactingProperty.value = newValue }
    }
    public var versionAtLastCompactingProperty = Property<Version?>(nil)
    
    /// The version of HyperCard that last modified the stack
    public var versionAtLastModificationSinceLastCompacting: Version? {
        get { return self.versionAtLastModificationSinceLastCompactingProperty.value }
        set { self.versionAtLastModificationSinceLastCompactingProperty.value = newValue }
    }
    public var versionAtLastModificationSinceLastCompactingProperty = Property<Version?>(nil)
    
    /// The version of HyperCard that first modified the stack
    public var versionAtLastModification: Version? {
        get { return self.versionAtLastModificationProperty.value }
        set { self.versionAtLastModificationProperty.value = newValue }
    }
    public var versionAtLastModificationProperty = Property<Version?>(nil)
    
    /// The size of the card window
    public var size: Size {
        get { return self.sizeProperty.value }
        set { self.sizeProperty.value = newValue }
    }
    public var sizeProperty = Property<Size>(Size(width: 512, height: 342))
    
    /// The position of the card window in the screen
    public var windowRectangle: Rectangle? {
        get { return self.windowRectangleProperty.value }
        set { self.windowRectangleProperty.value = newValue }
    }
    public var windowRectangleProperty = Property<Rectangle?>(nil)
    
    /// The resolution of the screen where the card window was opened
    public var screenRectangle: Rectangle? {
        get { return self.screenRectangleProperty.value }
        set { self.screenRectangleProperty.value = newValue }
    }
    public var screenRectangleProperty = Property<Rectangle?>(nil)
    
    /// If the window is too small for the card, the origin of the window rectangle in the card
    public var scrollPoint: Point? {
        get { return self.scrollPointProperty.value }
        set { self.scrollPointProperty.value = newValue }
    }
    public var scrollPointProperty = Property<Point?>(nil)
    
    /// The graphic patterns, there are 40 of them
    public var patterns: [Image] {
        get { return self.patternsProperty.value }
        set { self.patternsProperty.value = newValue }
    }
    public var patternsProperty = Property<[Image]>([])
    
    /// The script
    public var script: HString {
        get { return self.scriptProperty.value }
        set { self.scriptProperty.value = newValue }
    }
    public var scriptProperty = Property<HString>("")
    
}


