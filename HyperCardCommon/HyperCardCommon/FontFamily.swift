//
//  FontFamilyResource.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 16/02/2016.
//  Copyright © 2016 Pierre Lorenzi. All rights reserved.
//


/// A font family, containing fonts of different sizes and styles. The fonts can be either
/// bitmap or vector.
public struct FontFamily {
    
    /// The bitmap fonts of the family
    public var bitmapFonts: [FamilyBitmapFont]  = []
    
    /// The vector fonts of the family
    public var vectorFonts: [FamilyVectorFont]  = []
    
    /// Parameters for when styles are applied
    public var styleProperties: FontStyleProperties? = nil
    
    /// A record of a bitmap font for a specific size and style
    public struct FamilyBitmapFont {
        public let size: Int
        public let style: TextStyle
        public let resource: BitmapFontResource
    }
    
    /// A record of a vector font for a specitif style
    public struct FamilyVectorFont {
        public let style: TextStyle
        public let resource: VectorFontResource
    }
    
}
