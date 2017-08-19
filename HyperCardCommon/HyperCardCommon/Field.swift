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
    public var content: PartContent {
        get { return self.contentProperty.value }
        set { self.contentProperty.value = newValue }
    }
    public let contentProperty = Property<PartContent>(.string(""))
    
    /// Whether editing of text within the specified field in the current stack is
    /// allowed or prevented
    public var lockText: Bool {
        get { return self.lockTextProperty.value }
        set { self.lockTextProperty.value = newValue }
    }
    public let lockTextProperty = Property<Bool>(false)
    
    /// Whether or not the specified nonscrolling field sends the tabKey message to
    /// the current card.
    public var autoTab: Bool {
        get { return self.autoTabProperty.value }
        set { self.autoTabProperty.value = newValue }
    }
    public let autoTabProperty = Property<Bool>(false)
    
    /// Whether or not the lines in the specified field have a fixed line height.
    public var fixedLineHeight: Bool {
        get { return self.fixedLineHeightProperty.value }
        set { self.fixedLineHeightProperty.value = newValue }
    }
    public let fixedLineHeightProperty = Property<Bool>(false)
    
    /// Whether the text in the specified background field appears on each card of
    /// that background.
    public var sharedText: Bool {
        get { return self.sharedTextProperty.value }
        set { self.sharedTextProperty.value = newValue }
    }
    public let sharedTextProperty = Property<Bool>(false)
    
    /// Whether or not the specified field is searched with the find command.
    public var dontSearch: Bool {
        get { return self.dontSearchProperty.value }
        set { self.dontSearchProperty.value = newValue }
    }
    public let dontSearchProperty = Property<Bool>(false)
    
    /// Whether or not text at the edge of the specified field automatically wraps around
    /// to the next line.
    public var dontWrap: Bool {
        get { return self.dontWrapProperty.value }
        set { self.dontWrapProperty.value = newValue }
    }
    public let dontWrapProperty = Property<Bool>(false)
    
    /// Whether or not the user can select multiple lines in a list field.
    public var multipleLines: Bool {
        get { return self.multipleLinesProperty.value }
        set { self.multipleLinesProperty.value = newValue }
    }
    public let multipleLinesProperty = Property<Bool>(false)
    
    /// Whether some extra space is included at the left and right sides of each line in the
    /// specified field (to make the text easier to read).
    public var wideMargins: Bool {
        get { return self.wideMarginsProperty.value }
        set { self.wideMarginsProperty.value = newValue }
    }
    public let wideMarginsProperty = Property<Bool>(false)
    
    /// Whether the text baselines in the specified field appear or are invisible.
    public var showLines: Bool {
        get { return self.showLinesProperty.value }
        set { self.showLinesProperty.value = newValue }
    }
    public let showLinesProperty = Property<Bool>(false)
    
    /// Enables a field to behave as a list when its dontWrap and lockText property are
    /// also true.
    public var autoSelect: Bool {
        get { return self.autoSelectProperty.value }
        set { self.autoSelectProperty.value = newValue }
    }
    public let autoSelectProperty = Property<Bool>(false)
    
    /// The index of the line where lies the beginning of the text selection
    public var selectedLine: Int {
        get { return self.selectedLineProperty.value }
        set { self.selectedLineProperty.value = newValue }
    }
    public let selectedLineProperty = Property<Int>(0)
    
    /// The index of the line where lies the end of the text selection
    public var lastSelectedLine: Int {
        get { return self.lastSelectedLineProperty.value }
        set { self.lastSelectedLineProperty.value = newValue }
    }
    public let lastSelectedLineProperty = Property<Int>(0)
    
    /// How much material is hidden above the top of the specified scrolling field’s rectangle.
    /// In pixels.
    public var scroll: Int {
        get { return self.scrollProperty.value }
        set { self.scrollProperty.value = newValue }
    }
    public let scrollProperty = Property<Int>(0)
    
    /// How lines of text are aligned in the specified field.
    public var textAlign: TextAlign {
        get { return self.textAlignProperty.value }
        set { self.textAlignProperty.value = newValue }
    }
    public let textAlignProperty = Property<TextAlign>(.left)
    
    /// The resource identifier of the font in which text in the specified field appears.
    public var textFontIdentifier: Int {
        get { return self.textFontIdentifierProperty.value }
        set { self.textFontIdentifierProperty.value = newValue }
    }
    public let textFontIdentifierProperty = Property<Int>(FontIdentifiers.geneva)
    
    /// The type size in which text in the specified field appears.
    public var textFontSize: Int {
        get { return self.textFontSizeProperty.value }
        set { self.textFontSizeProperty.value = newValue }
    }
    public let textFontSizeProperty = Property<Int>(12)
    
    /// The style in which text in the specified field appears.
    public var textStyle: TextStyle {
        get { return self.textStyleProperty.value }
        set { self.textStyleProperty.value = newValue }
    }
    public let textStyleProperty = Property<TextStyle>(PlainTextStyle)
    
    /// The space between baselines of text in the specified field.
    public var textHeight: Int {
        get { return self.textHeightProperty.value }
        set { self.textHeightProperty.value = newValue }
    }
    public let textHeightProperty = Property<Int>(16)
    
}
