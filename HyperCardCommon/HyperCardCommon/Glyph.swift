//
//  BitmapFontCharacter.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 06/03/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


/// A glyph in a bitmap font.
/// <p>
/// It is a class, not a struct, so it can be lazily loaded and shared (the missing glyph in a font is
/// always used for several characters).
public class Glyph {
    
    /// The width of a character is the distance from the origin of the character to the origin of the next one.
    public var width: Int {
        get { return self.widthProperty.value }
        set { self.widthProperty.value = newValue }
    }
    public var widthProperty = Property<Int>(0)
    
    ///  The offset is the position of the character bitmap relative to the character origin. Positive towards the right.
    public var imageOffset: Int {
        get { return self.imageOffsetProperty.value }
        set { self.imageOffsetProperty.value = newValue }
    }
    public var imageOffsetProperty = Property<Int>(0)
    
    /// Top of image, from the baseline
    public var imageTop: Int {
        get { return self.imageTopProperty.value }
        set { self.imageTopProperty.value = newValue }
    }
    public var imageTopProperty = Property<Int>(0)
    
    /// The image of the character
    public var image: MaskedImage? {
        get { return self.imageProperty.value }
        set { self.imageProperty.value = newValue }
    }
    public var imageProperty = Property<MaskedImage?>(nil)
}
