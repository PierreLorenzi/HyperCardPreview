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
    private let fork: ResourceFork
    
    private static let fakeFontFamily = FontFamily()
    
    public init(resource: FontFamilyResourceBlock, fork: ResourceFork) {
        self.resource = resource
        self.fork = fork
        
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
            super.content = newValue
        }
    }
    
    private func loadContent() -> FontFamily {
        
        /* Get the references from the resource */
        let associations = resource.fontAssociationTable
        
        /* Load the bitmap fonts */
        let bitmapAssociations = associations.filter({ $0.size != 0 })
        let bitmapFonts = bitmapAssociations.flatMap(self.convertAssociationToBitmapReference)
        
        /* Load the vector fonts */
        let vectorAssociations = associations.filter({ $0.size == 0 })
        let vectorFonts = vectorAssociations.flatMap(self.convertAssociationToVectorReference)
        
        /* Build the family */
        var family = FontFamily()
        family.bitmapFonts = bitmapFonts
        family.vectorFonts = vectorFonts
        return family
        
    }
    
    private func convertAssociationToBitmapReference(association: FontFamilyResourceBlock.FontAssociation) -> FontFamily.FamilyBitmapFont? {
        
        /* Find the font in the fork */
        guard let index = fork.bitmapFonts.index(where: {$0.identifier == association.resourceIdentifier}) else {
            return nil;
        }
        
        /* Build a new font */
        let fontResource = fork.bitmapFonts[index]
        let font = FileBitmapFont(block: fontResource)
        
        /* Build the reference */
        return FontFamily.FamilyBitmapFont(size: association.size, style: association.style, font: font)
        
    }
    
    private func convertAssociationToVectorReference(association: FontFamilyResourceBlock.FontAssociation) -> FontFamily.FamilyVectorFont? {
        
        /* Find the vector font in the fork */
        guard let index = fork.vectorFonts.index(where: {$0.identifier == association.resourceIdentifier}) else {
            return nil
        }
        
        /* Load the font */
        let fontResource = fork.vectorFonts[index]
        let font = fontResource.cgfont
        
        /* Build the reference */
        return FontFamily.FamilyVectorFont(style: association.style, font: font)
        
    }
    
}
