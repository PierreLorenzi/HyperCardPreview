//
//  FileFontFamily.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 28/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//



private let fakeFontFamily = FontFamily()


public extension Resource where T == FontFamily {
    
    public convenience init(resource: FontFamilyResourceBlock, fork: ResourceFork) {
        
        self.init(identifier: resource.identifier, name: resource.name, type: ResourceTypes.fontFamily, content: fakeFontFamily)
        
        /* Enable lazy initialization */
        
        /* content */
        self.contentProperty.observers.append(LazyInitializer(property: self.contentProperty, initialization: {
            return self.loadContent(resource: resource, fork: fork)
        }))
        
    }
    
    private func loadContent(resource: FontFamilyResourceBlock, fork: ResourceFork) -> FontFamily {
        
        /* Get the references from the resource */
        let associations = resource.fontAssociationTable
        
        /* Load the bitmap fonts */
        let bitmapAssociations = associations.filter({ $0.size != 0 })
        let bitmapFonts = bitmapAssociations.flatMap({ return self.convertAssociationToBitmapReference(association: $0, fork: fork) })
        
        /* Load the vector fonts */
        let vectorAssociations = associations.filter({ $0.size == 0 })
        let vectorFonts = vectorAssociations.flatMap({ return self.convertAssociationToVectorReference(association: $0, fork: fork) })
        
        /* Build the family */
        var family = FontFamily()
        family.bitmapFonts = bitmapFonts
        family.vectorFonts = vectorFonts
        return family
        
    }
    
    private func convertAssociationToBitmapReference(association: FontFamilyResourceBlock.FontAssociation, fork: ResourceFork) -> FontFamily.FamilyBitmapFont? {
        
        /* Find the font in the fork */
        guard let index = fork.bitmapFonts.index(where: {$0.identifier == association.resourceIdentifier}) else {
            return nil;
        }
        
        /* Build a new font */
        let fontResource = fork.bitmapFonts[index]
        let font = BitmapFont(block: fontResource)
        
        /* Build the reference */
        return FontFamily.FamilyBitmapFont(size: association.size, style: association.style, font: font)
        
    }
    
    private func convertAssociationToVectorReference(association: FontFamilyResourceBlock.FontAssociation, fork: ResourceFork) -> FontFamily.FamilyVectorFont? {
        
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

