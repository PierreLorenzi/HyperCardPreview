//
//  AddColor.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 05/06/2018.
//  Copyright © 2018 Pierre Lorenzi. All rights reserved.
//


/// All the AddColor colors declared on a card or on a background
public struct LayerColor {
    
    /// The color declarations to apply
    public var elements: [AddColorElement]
}

/// An RGB color
public struct AddColor {
    public var red: Double
    public var green: Double
    public var blue: Double
}

/// A color declaration in a card or background.
/// <p>
/// The elements are displayed in the order of the resource, not the order of the HyperCard object
public enum AddColorElement {
    
    case button(AddColorButton)
    case field(AddColorField)
    case rectangle(AddColorRectangle)
    case pictureResource(AddColorPictureResource)
    case pictureFile(AddColorPictureFile)
}

/// A declaration to colorize a button
public struct AddColorButton {
    
    /// The ID of the button
    public var buttonIdentifier: Int
    
    /// Thickness of the 3D-like border
    public var bevel: Int
    
    /// The color to use
    public var color: AddColor
    
    /// If unset, this declaration is ignored
    public var enabled: Bool
}

/// A declaration to colorize a text field
public struct AddColorField {
    
    /// The ID of the field
    public var fieldIdentifier: Int
    
    /// Thickness of the 3D-like border
    public var bevel: Int
    
    /// The color to use
    public var color: AddColor
    
    /// If unset, this declaration is ignored
    public var enabled: Bool
}

/// A declaration to colorize a certain rectangle
public struct AddColorRectangle {
    
    /// Position of the rectangle
    public var rectangle: Rectangle
    
    /// Thickness of the 3D-like border
    public var bevel: Int
    
    /// The color to use
    public var color: AddColor
    
    /// If unset, this declaration is ignored
    public var enabled: Bool
}

/// A declaration to draw a colored picture out of a resource
public struct AddColorPictureResource {
    
    /// Rectangle where to draw the picture
    public var rectangle: Rectangle
    
    /// Transparent means that the white pixels of the image are drawn transparent
    public var transparent: Bool
    
    /// The name of the PICT resource containing the picture
    public var resourceName: HString
    
    /// If unset, this declaration is ignored
    public var enabled: Bool
}

/// A declaration to draw a colored picture out of a file
public struct AddColorPictureFile {
    
    /// Rectangle where to draw the picture
    public var rectangle: Rectangle
    
    /// Transparent means that the white pixels of the image are drawn transparent
    public var transparent: Bool
    
    /// The file name is just the name of the file, not the path. The file is supposed to be in the same folder
    ///  as the HyperCard application, the Home stack or the current stack
    public var fileName: HString
    
    /// If unset, this declaration is ignored
    public var enabled: Bool
}
