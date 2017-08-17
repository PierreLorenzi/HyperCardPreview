//
//  Button.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 26/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


/// A button
public class Button: Part {
    
    /// The content
    public var content: HString         = ""
    
    /// Whether the specified button appears and behaves in an enabled or disabled
    /// state.
    public var enabled: Bool            = true
    
    /// Whether the specified button is highlighted (displayed in inverse video).
    public var hilite: Bool             = false
    
    /// Whether the specified button highlights when that button is pressed.
    public var autoHilite: Bool         = false
    
    /// Whether the specified background button is displayed highlighted on all cards
    /// of that background.
    public var sharedHilite: Bool       = false
    
    /// Whether the name of the specified button (if it has one) is displayed in its
    /// rectangle on the screen.
    public var showName: Bool           = true
    
    /// The resource identifier of the icon displayed in the button
    public var iconIdentifier: Int      = 0
    
    /// Groups two or more buttons together into a family specified by the numbers 1 to
    /// 15, inclusive.
    public var family: Int              = 0
    
    /// For pop-up buttons: the width of the area in which the button’s name appears.
    public var titleWidth: Int          = 0
    
    /// For pop-up buttons: the index of the selected item.
    public var selectedItem: Int        = 0
    
    /// How lines of text are aligned in the specified button
    public var textAlign: TextAlign     = .center
    
    /// The resource identifier of the font in which text in the specified button appears.
    public var textFontIdentifier: Int  = FontManager.UsualIdentifiers.charcoal
    
    /// The type size in which text in the specified button appears.
    public var textFontSize: Int        = 12
    
    /// The style in which text in the specified button appears.
    public var textStyle: TextStyle     = PlainTextStyle
    
    /// The space between baselines of text in the specified button
    public var textHeight: Int          = 16
    
}

