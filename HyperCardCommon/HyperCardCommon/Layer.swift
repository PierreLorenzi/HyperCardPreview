//
//  Layer.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 26/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//



public class Layer {
    
    public var image: MaskedImage?      = nil
    
    public var showPict: Bool           = true
    public var dontSearch: Bool         = false
    public var cantDelete: Bool         = false
    
    public var parts: [LayerPart]                   = []
    public var nextAvailablePartIdentifier: Int     = 1
    
    
    public var fields: [Field] {
        return parts.flatMap({
            if case LayerPart.field(let field) = $0 {
                return field
            }
            return nil
        })
    }
    
    public var buttons: [Button] {
        return parts.flatMap({
            if case LayerPart.button(let button) = $0 {
                return button
            }
            return nil
        })
    }
    
}



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
