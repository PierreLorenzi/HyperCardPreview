//
//  Button.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 26/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


public class Button: Part {
    
    public var content: HString         = ""
    
    public var enabled: Bool            = true
    public var hilite: Bool             = false
    public var autoHilite: Bool         = false
    public var sharedHilite: Bool       = false
    public var showName: Bool           = true
    
    public var iconIdentifier: Int      = 0
    public var family: Int              = 0
    
    /* Popup buttons */
    public var titleWidth: Int          = 0
    public var selectedItem: Int        = 0
    
    public var textAlign: TextAlign     = .center
    public var textFontIdentifier: Int  = 2002
    public var textFontSize: Int        = 12
    public var textStyle: TextStyle     = PlainTextStyle
    public var textHeight: Int          = 16
    
}

