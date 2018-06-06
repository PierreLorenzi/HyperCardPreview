//
//  AddColor.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 05/06/2018.
//  Copyright © 2018 Pierre Lorenzi. All rights reserved.
//


public struct LayerColor {
    
    public var elements: [AddColorElement]
}

public struct AddColor {
    public var red: Double
    public var green: Double
    public var blue: Double
}

/// The elements are displayed in the order of the resource, not the order of the HyperCard object
public enum AddColorElement {
    
    case button(AddColorButton)
    case field(AddColorField)
    case rectangle(AddColorRectangle)
    case pictureResource(AddColorPictureResource)
    case pictureFile(AddColorPictureFile)
}

public struct AddColorButton {
    
    public var buttonIdentifier: Int
    public var bevel: Int
    public var color: AddColor
    public var enabled: Bool
}

public struct AddColorField {
    
    public var fieldIdentifier: Int
    public var bevel: Int
    public var color: AddColor
    public var enabled: Bool
}

public struct AddColorRectangle {
    
    public var rectangle: Rectangle
    public var bevel: Int
    public var color: AddColor
    public var enabled: Bool
}

public struct AddColorPictureResource {
    
    public var rectangle: Rectangle
    
    /// Transparent means that the white pixels of the image are drawn transparent
    public var transparent: Bool
    public var resourceName: HString
    public var enabled: Bool
}

public struct AddColorPictureFile {
    
    public var rectangle: Rectangle
    
    /// Transparent means that the white pixels of the image are drawn transparent
    public var transparent: Bool
    
    /// The file name is just the name of the file, not the path. The file is supposed to be in the same folder
    ///  as the HyperCard application, the Home stack or the current stack
    public var fileName: HString
    public var enabled: Bool
}
