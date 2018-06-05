//
//  FileFontFamily.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 28/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//



/// Implementation of Font Family Resource with lazy loading from a file
/// <p>
/// Lazy loading is implemented by hand because an inherited property can't be made
/// lazy in swift.
public extension FontFamily {
    
    public init(reader: FontFamilyResourceReader, bitmapFonts: [BitmapFontResource], vectorFonts: [VectorFontResource]) {
        
        /* Get the references from the resource */
        let associations = reader.readFontAssociationTable()
        
        /* Load the bitmap fonts */
        let bitmapAssociations = associations.filter({ $0.size != 0 })
        let bitmapFonts = bitmapAssociations.compactMap { return FontFamily.convertAssociationToBitmapReference(association: $0, bitmapFonts: bitmapFonts)
        }
        
        /* Load the vector fonts */
        let vectorAssociations = associations.filter({ $0.size == 0 })
        let vectorFonts = vectorAssociations.compactMap { return FontFamily.convertAssociationToVectorReference(association: $0, vectorFonts: vectorFonts)
        }
        
        /* Build the family */
        self.init()
        self.bitmapFonts = bitmapFonts
        self.vectorFonts = vectorFonts
        self.styleProperties = (reader.readUseIntegerExtraWidth()) ? nil : reader.readStyleProperties()
        
    }
    
    private static func convertAssociationToBitmapReference(association: FontFamilyResourceReader.FontAssociation, bitmapFonts: [BitmapFontResource]) -> FontFamily.FamilyBitmapFont? {
        
        /* Find the font in the fork */
        guard let bitmapFont = bitmapFonts.first(where: {$0.identifier == association.resourceIdentifier}) else {
            return nil;
        }
        
        /* Build the reference */
        return FontFamily.FamilyBitmapFont(size: association.size, style: association.style, resource: bitmapFont)
        
    }
    
    private static func convertAssociationToVectorReference(association: FontFamilyResourceReader.FontAssociation, vectorFonts: [VectorFontResource]) -> FontFamily.FamilyVectorFont? {
        
        /* Find the vector font in the fork */
        guard let vectorFont = vectorFonts.first(where: {$0.identifier == association.resourceIdentifier}) else {
            return nil
        }
        
        /* Build the reference */
        return FontFamily.FamilyVectorFont(style: association.style, resource: vectorFont)
        
    }
    
}
