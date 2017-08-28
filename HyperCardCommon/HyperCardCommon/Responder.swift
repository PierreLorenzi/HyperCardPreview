//
//  Responder.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 28/08/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//



public protocol MouseResponder {
    
    /// If the object is the one responding to the mouse event at the given position. Can return true even if it does nothing.
    func doesRespondToMouseEvent(at position: Point) -> Bool
    
    func respondToMouseEvent(_ mouseEvent: MouseEvent, at position: Point)
    
}

public enum MouseEvent {
    
    case mouseUp
    case mouseDown
    case verticalScroll(delta: Double)
}
