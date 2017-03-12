//
//  BitmapFontCharacter.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 06/03/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//

import Cocoa

public class Glyph {
    
    /** The width of a character is the distance from the origin of the character to the origin of the next one. */
    public var width: Int           = 0
    
    /** The offset is the position of the character bitmap relative to the character origin. Positive towards the right. */
    public var imageOffset: Int     = 0
    /** Top of image, from the baseline */
    public var imageTop: Int        = 0
    public var image: MaskedImage?   = nil
}
