//
//  Part.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 26/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


/// An abstract class for fields and buttons
public class Part {
    
    /// The identifier
    public var identifier: Int {
        get { return self.identifierProperty.value }
        set { self.identifierProperty.value = newValue }
    }
    public var identifierProperty = Property<Int>(0)
    
    /// The name
    public var name: HString {
        get { return self.nameProperty.value }
        set { self.nameProperty.value = newValue }
    }
    public var nameProperty = Property<HString>("")
    
    /// The visual style of the part
    public var style: PartStyle {
        get { return self.styleProperty.value }
        set { self.styleProperty.value = newValue }
    }
    public var styleProperty = Property<PartStyle>(.transparent)
    
    /// The visual location of the part in its containing layer
    public var rectangle: Rectangle {
        get { return self.rectangleProperty.value }
        set { self.rectangleProperty.value = newValue }
    }
    public var rectangleProperty = Property<Rectangle>(Rectangle(top: 0, left: 0, bottom: 0, right: 0))
    
    /// Whether the part appears on the screen
    public var visible: Bool {
        get { return self.visibleProperty.value }
        set { self.visibleProperty.value = newValue }
    }
    public var visibleProperty = Property<Bool>(true)
    
    /// The script
    public var script: HString {
        get { return self.scriptProperty.value }
        set { self.scriptProperty.value = newValue }
    }
    public var scriptProperty = Property<HString>("")
    
    /// How lines of text are aligned in the specified field.
    public var textAlign: TextAlign {
        get { return self.textAlignProperty.value }
        set { self.textAlignProperty.value = newValue }
    }
    public var textAlignProperty = Property<TextAlign>(.left)
    
    /// The resource identifier of the font in which text in the specified field appears.
    public var textFontIdentifier: Int {
        get { return self.textFontIdentifierProperty.value }
        set { self.textFontIdentifierProperty.value = newValue }
    }
    public var textFontIdentifierProperty = Property<Int>(FontIdentifiers.geneva)
    
    /// The type size in which text in the specified field appears.
    public var textFontSize: Int {
        get { return self.textFontSizeProperty.value }
        set { self.textFontSizeProperty.value = newValue }
    }
    public var textFontSizeProperty = Property<Int>(12)
    
    /// The style in which text in the specified field appears.
    public var textStyle: TextStyle {
        get { return self.textStyleProperty.value }
        set { self.textStyleProperty.value = newValue }
    }
    public var textStyleProperty = Property<TextStyle>(PlainTextStyle)
    
    /// The space between baselines of text in the specified field.
    public var textHeight: Int {
        get { return self.textHeightProperty.value }
        set { self.textHeightProperty.value = newValue }
    }
    public var textHeightProperty = Property<Int>(16)
    
}

