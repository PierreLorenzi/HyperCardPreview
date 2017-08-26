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
    
    /// The position of the view
    public var rectangle: Rectangle {
        return Rectangle(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    /// If the view is visible
    public var visible: Bool {
        return true
    }
    
    /// Draws the object on the drawing
    public func draw(in drawing: Drawing) {
    }
    
    /// If the view is the one responding to the mouse event at the given position. Can return true even if it does nothing.
    public func respondsToMouseEvent(at position: Point) -> Bool {
        return false
    }
    
    public func respondToClick(at position: Point) {
        
    }
    
    public func respondToScroll(at position: Point, delta: Double) {
        
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


