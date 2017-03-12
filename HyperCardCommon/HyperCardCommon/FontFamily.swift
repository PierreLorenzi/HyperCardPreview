//
//  FontFamilyResource.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 16/02/2016.
//  Copyright © 2016 Pierre Lorenzi. All rights reserved.
//


public struct FontFamily {
    
    public var bitmapFonts: [FamilyBitmapFont]  = []
    public var vectorFonts: [FamilyVectorFont]  = []
    
    
    public struct FamilyBitmapFont {
        public let size: Int
        public let style: TextStyle
        public let font: BitmapFont
    }
    
    public struct FamilyVectorFont {
        public let style: TextStyle
        public let font: CGFont
    }
    
}
