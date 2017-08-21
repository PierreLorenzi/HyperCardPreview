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
    
    public var needsDisplay: Bool {
        get { return needsDisplayProperty.value }
        set { needsDisplayProperty.value = newValue }
    }
    public let needsDisplayProperty = Property<Bool>(false)
    
    /// Draws the object on the drawing
    public func draw(in drawing: Drawing) {
    }
    
    public func respondsToMouseEvent(at position: Point) -> Bool {
        return false
    }
    
    public func respondToClick(at position: Point) {
        
    }
    
    public func respondToScroll(at position: Point, delta: Double) {
        
    }
    
}


public extension View {
    
    public func dependsOn<T>(_ property: Property<T>) {
        let needsDisplayProperty = self.needsDisplayProperty
        property.startNotifications(for: self.needsDisplayProperty, by: {
            [unowned needsDisplayProperty] in needsDisplayProperty.value = true
        })
    }
    
}
