//
//  ResourceRepository.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 27/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


/// The content of a resource fork
public struct ResourceRepository {
    
    /// The icons
    public var icons: [IconResource]
    
    /// The font families
    public var fontFamilies: [FontFamilyResource]
    
    /// The bitmap fonts
    public var bitmapFonts: [BitmapFontResource]
    
    /// The vector fonts
    public var vectorFonts: [VectorFontResource]
    
    /// The AddColor resources for the cards
    public var cardColors: [CardColorResource]
    
    /// The AddColor resources for the backgrounds
    public var backgroundColors: [BackgroundColorResource]
    
    /// The color pictures
    public var pictures: [PictureResource]
}

