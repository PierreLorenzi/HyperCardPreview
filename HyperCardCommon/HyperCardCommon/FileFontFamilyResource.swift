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
public class FileFontFamilyResource : Resource<FontFamily> {
    
    private let resource: FontFamilyResourceBlock
    private let bitmapFonts: [BitmapFontResourceBlock]
    private let vectorFonts: [VectorFontResourceBlock]
    
    private static let fakeFontFamily = FontFamily()
    
    public init(resource: FontFamilyResourceBlock, bitmapFonts: [BitmapFontResourceBlock], vectorFonts: [VectorFontResourceBlock]) {
        self.resource = resource
        self.bitmapFonts = bitmapFonts
        self.vectorFonts = vectorFonts
        
        super.init(identifier: resource.identifier, name: resource.name, type: ResourceTypes.fontFamily, content: FileFontFamilyResource.fakeFontFamily)
    }
    
    private var contentLoaded = false
    override public var content: FontFamily {
        get {
            if !contentLoaded {
                super.content = loadContent()
                contentLoaded = true
            }
            return super.content
        }
        set {
            contentLoaded = true
            super.content = newValue
        }
    }
    
    private func loadContent() -> FontFamily {
        
        /* Get the references from the resource */
        let associations = resource.readFontAssociationTable()
        
        /* Load the bitmap fonts */
        let bitmapAssociations = associations.filter({ $0.size != 0 })
        let bitmapFonts = bitmapAssociations.compactMap(self.convertAssociationToBitmapReference)
        
        /* Load the vector fonts */
        let vectorAssociations = associations.filter({ $0.size == 0 })
        let vectorFonts = vectorAssociations.compactMap(self.convertAssociationToVectorReference)
        
        /* Build the family */
        var family = FontFamily()
        family.bitmapFonts = bitmapFonts
        family.vectorFonts = vectorFonts
        family.styleProperties = (resource.readUseIntegerExtraWidth()) ? nil : resource.readStyleProperties()
        return family
        
    }
    
    private func convertAssociationToBitmapReference(association: FontFamilyResourceBlock.FontAssociation) -> FontFamily.FamilyBitmapFont? {
        
        /* Find the font in the fork */
        guard let index = self.bitmapFonts.index(where: {$0.identifier == association.resourceIdentifier}) else {
            return nil;
        }
        
        /* Build a new font */
        let fontResource = self.bitmapFonts[index]
        let font = BitmapFont(block: fontResource)
        
        /* Build the reference */
        return FontFamily.FamilyBitmapFont(size: association.size, style: association.style, font: font)
        
    }
    
    private func convertAssociationToVectorReference(association: FontFamilyResourceBlock.FontAssociation) -> FontFamily.FamilyVectorFont? {
        
        /* Find the vector font in the fork */
        guard let index = self.vectorFonts.index(where: {$0.identifier == association.resourceIdentifier}) else {
            return nil
        }
        
        /* Load the font */
        let fontResource = self.vectorFonts[index]
        let font = fontResource.readCGFont()
        
        /* Build the reference */
        return FontFamily.FamilyVectorFont(style: association.style, font: font)
        
    }
    
}
