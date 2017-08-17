//
//  Layer.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 26/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//



/// An abstract class for cards and backgrounds
public class Layer {
    
    /// The graphic image of the layer, displayed behind the parts
    public var image: MaskedImage?      = nil
    
    /// Whether the image is displayed
    public var showPict: Bool           = true
    
    /// Whether or not the fields are searched with the find command
    public var dontSearch: Bool         = false
    
    /// Whether or not the user can delete the specified layer
    public var cantDelete: Bool         = false
    
    /// The part list. This list defines the order in which the parts are drawn, and their
    /// indexes when in a script when there is "part 3"
    public var parts: [LayerPart]                   = []
    
    /// The identifier to be given to the next created part
    public var nextAvailablePartIdentifier: Int     = 1
    
    
    /// A filter on the parts to access the fields. This list is necessary because fields have
    /// indexes of their own, in a script there can be "field 3".
    public var fields: [Field] {
        return parts.flatMap({
            if case LayerPart.field(let field) = $0 {
                return field
            }
            return nil
        })
    }
    
    /// A filter on the parts to access the buttons This list is necessary because buttons have
    /// indexes of their own, in a script there can be "button 3".
    public var buttons: [Button] {
        return parts.flatMap({
            if case LayerPart.button(let button) = $0 {
                return button
            }
            return nil
        })
    }
    
}



/// A part: either a button or a field
public enum LayerPart {
    case button(Button)
    case field(Field)
    
    public var part: Part {
        switch (self) {
        case .button(let button):
            return button
        case .field(let field):
            return field
        }
    }
}
