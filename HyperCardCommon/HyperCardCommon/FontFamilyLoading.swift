//
//  FileFontFamily.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 28/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


extension FontFamily: ResourceContent {
    
    /// Loads a font family from the data of a FOND resource
    public init(loadFromData data: DataRange) {
        
        let reader = FontFamilyResourceReader(data: data)
        
        /* Get the references from the resource */
        let associations = reader.readFontAssociationTable()
        
        /* Build the fonts */
        let bitmapFonts: [FontFamily.FamilyBitmapFont] = associations.filter({ $0.size != 0 }).map({ FontFamily.FamilyBitmapFont(size: $0.size, style: $0.style, resourceIdentifier: $0.resourceIdentifier) })
        let vectorFonts: [FontFamily.FamilyVectorFont] = associations.filter({ $0.size == 0 }).map({ FontFamily.FamilyVectorFont(style: $0.style, resourceIdentifier: $0.resourceIdentifier) })
        
        /* Build the family */
        self.init()
        self.bitmapFonts = bitmapFonts
        self.vectorFonts = vectorFonts
        self.styleProperties = (reader.readUseIntegerExtraWidth()) ? nil : reader.readStyleProperties()
        
    }
    
}
