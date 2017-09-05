//
//  View.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 02/03/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


/// A view is an object that can be drawn on a drawing. The object is supposed
/// to handle its position itself, no translation or clipping is applied.
public class View {
    
    /// How the view wants to be refreshed
    public var refreshNeed: RefreshNeed {
        get { return refreshNeedProperty.value }
        set { refreshNeedProperty.value = newValue }
    }
    public let refreshNeedProperty = Property<RefreshNeed>(.none)
    
    /// The position of the view. If it is absent, the view is not drawn.
    public var rectangle: Rectangle? {
        return nil
    }
    
    /// Draws the object on the drawing
    public func draw(in drawing: Drawing) {
    }
    
}

/// How a view must be refreshed
public enum RefreshNeed {
    
    /// The view doesn't need to be refreshed
    case none
    
    /// The view needs to be refreshed.
    case refresh
    
    /// The view needs to be refreshed and has made non opaque pixels, so views behind need to be refreshed.
    case refreshWithNewShape
}

/// A view that can draw sub-rectangles of itself
public protocol ClipableView {
    
    /// Draws a part of the object on the drawing
    func draw(in drawing: Drawing, rectangle: Rectangle)
    
}


