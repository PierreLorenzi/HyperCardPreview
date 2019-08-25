//
//  FontFamilyResource.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 16/02/2016.
//  Copyright © 2016 Pierre Lorenzi. All rights reserved.
//


/// A font family, containing fonts of different sizes and styles. The fonts can be either
/// bitmap or vector.
/// <p>
/// A font family represents what the user perceives as a font. It contains a list of
/// bitmap fonts and vector fonts to use for different sizes and styles.
/// <p>
/// All the sizes and styles don't need to be present. If one is missing, it is generated.
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
        public let resourceIdentifier: Int
    }
    
    /// A record of a vector font for a specitif style
    public struct FamilyVectorFont {
        public let style: TextStyle
        public let resourceIdentifier: Int
    }
    
}
