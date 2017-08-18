//
//  Field.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 26/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


/// A text field
public class Field: Part {
    
    /// The text contained in the field
    public var content: PartContent     = .string("")
    
    /// Whether editing of text within the specified field in the current stack is
    /// allowed or prevented
    public var lockText: Bool           = false
    
    /// Whether or not the specified nonscrolling field sends the tabKey message to
    /// the current card.
    public var autoTab: Bool            = false
    
    /// Whether or not the lines in the specified field have a fixed line height.
    public var fixedLineHeight: Bool    = false
    
    /// Whether the text in the specified background field appears on each card of
    /// that background.
    public var sharedText: Bool         = false
    
    /// Whether or not the specified field is searched with the find command.
    public var dontSearch: Bool         = false
    
    /// Whether or not text at the edge of the specified field automatically wraps around
    /// to the next line.
    public var dontWrap: Bool           = false
    
    /// Whether or not the user can select multiple lines in a list field.
    public var multipleLines: Bool      = false
    
    /// Whether some extra space is included at the left and right sides of each line in the
    /// specified field (to make the text easier to read).
    public var wideMargins: Bool        = false
    
    /// Whether the text baselines in the specified field appear or are invisible.
    public var showLines: Bool          = false
    
    /// Enables a field to behave as a list when its dontWrap and lockText property are
    /// also true.
    public var autoSelect: Bool         = false
    
    /// The index of the line where lies the beginning of the text selection
    public var selectedLine: Int        = 0
    
    /// The index of the line where lies the end of the text selection
    public var lastSelectedLine: Int    = 0
    
    /// How much material is hidden above the top of the specified scrolling field’s rectangle.
    /// In pixels.
    public var scroll: Int              = 0
    
    /// How lines of text are aligned in the specified field.
    public var textAlign: TextAlign     = .left
    
    /// The resource identifier of the font in which text in the specified field appears.
    public var textFontIdentifier: Int  = FontIdentifiers.geneva
    
    /// The type size in which text in the specified field appears.
    public var textFontSize: Int        = 12
    
    /// The style in which text in the specified field appears.
    public var textStyle: TextStyle     = PlainTextStyle
    
    /// The space between baselines of text in the specified field.
    public var textHeight: Int          = 16
    
}
