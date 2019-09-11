//
//  Responder.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 28/08/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


/// A protocol implemented by views responding to mouse events
public protocol MouseResponder {
    
    /// Whether the object is the one responding to the mouse event at the given position.
    /// Can return true even if it does nothing.
    func doesRespondToMouseEvent(at position: Point) -> Bool
    
    /// Responds to the mouse event
    func respondToMouseEvent(_ mouseEvent: MouseEvent, at position: Point)
    
}

/// The type of a mouse event
public enum MouseEvent {
    
    case mouseUp
    case mouseDown
    case mouseDragged
    case verticalScroll(delta: Double)
}
