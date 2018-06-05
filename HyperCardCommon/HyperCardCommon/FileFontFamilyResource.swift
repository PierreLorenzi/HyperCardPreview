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
public extension Resource where T == FontFamilyResourceType {
    
    private static let fakeFontFamily = FontFamily()
    
    public convenience init(resource: FontFamilyResourceBlock, bitmapFonts: [BitmapFontResourceBlock], vectorFonts: [VectorFontResourceBlock]) {
        
        let contentProperty = Property<FontFamily> { () -> FontFamily in
            return Resource.loadContent(resource: resource, bitmapFonts: bitmapFonts, vectorFonts: vectorFonts)
        }
        
        self.init(identifier: resource.identifier, name: resource.name, contentProperty: contentProperty)
    }
    
    private static func loadContent(resource: FontFamilyResourceBlock, bitmapFonts: [BitmapFontResourceBlock], vectorFonts: [VectorFontResourceBlock]) -> FontFamily {
        
        /* Get the references from the resource */
        let associations = resource.readFontAssociationTable()
        
        /* Load the bitmap fonts */
        let bitmapAssociations = associations.filter({ $0.size != 0 })
        let bitmapFonts = bitmapAssociations.compactMap { return convertAssociationToBitmapReference(association: $0, bitmapFonts: bitmapFonts)
        }
        
        /* Load the vector fonts */
        let vectorAssociations = associations.filter({ $0.size == 0 })
        let vectorFonts = vectorAssociations.compactMap { return convertAssociationToVectorReference(association: $0, vectorFonts: vectorFonts)
        }
        
        /* Build the family */
        var family = FontFamily()
        family.bitmapFonts = bitmapFonts
        family.vectorFonts = vectorFonts
        family.styleProperties = (resource.readUseIntegerExtraWidth()) ? nil : resource.readStyleProperties()
        return family
        
    }
    
    private static func convertAssociationToBitmapReference(association: FontFamilyResourceBlock.FontAssociation, bitmapFonts: [BitmapFontResourceBlock]) -> FontFamily.FamilyBitmapFont? {
        
        /* Find the font in the fork */
        guard let index = bitmapFonts.index(where: {$0.identifier == association.resourceIdentifier}) else {
            return nil;
        }
        
        /* Build a new font */
        let fontResource = bitmapFonts[index]
        let font = BitmapFont(block: fontResource)
        
        /* Build the reference */
        return FontFamily.FamilyBitmapFont(size: association.size, style: association.style, font: font)
        
    }
    
    private static func convertAssociationToVectorReference(association: FontFamilyResourceBlock.FontAssociation, vectorFonts: [VectorFontResourceBlock]) -> FontFamily.FamilyVectorFont? {
        
        /* Find the vector font in the fork */
        guard let index = vectorFonts.index(where: {$0.identifier == association.resourceIdentifier}) else {
            return nil
        }
        
        /* Load the font */
        let fontResource = vectorFonts[index]
        let font = fontResource.readCGFont()
        
        /* Build the reference */
        return FontFamily.FamilyVectorFont(style: association.style, font: font)
        
    }
    
}
