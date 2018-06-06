//
//  FontManager.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 03/03/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


/// Associates font descriptor, with user-friendly font names and variations, to low-level
/// bitmap fonts that can be directly drawn.
/// <p>
/// It needs a stack of resource forks to look for font resources in it.
public class FontManager {
    
    private let resources: ResourceSystem
    
    private let fontNameReferences: [FontNameReference]
    
    private var cachedFonts: [FontDescriptor: BitmapFont]
    
    /// Builds a manager. A stack of resource forks must be provided, the fonts are searched in it.
    public init(resources: ResourceSystem, fontNameReferences: [FontNameReference]) {
        self.resources = resources
        self.fontNameReferences = fontNameReferences
        cachedFonts = [:]
    }
    
    /// Associates a font descriptor with a bitmap font
    /// <p>
    /// If no mathing font is found, a font is automatically generated for the descriptor.
    public func findFont(withIdentifier identifier: Int, size: Int, style: TextStyle) -> BitmapFont {
        
        /* Ignore the 'group' variation, it is only a HyperCard flag to handle links */
        var visualStyle = style
        visualStyle.group = false
        
        /* Look in the cache */
        let descriptor = FontDescriptor(identifier: identifier, size: size, style: visualStyle)
        if let cachedFont = cachedFonts[descriptor] {
            return cachedFont
        }
        
        /* Build it */
        let font = retrieveFont(forDescriptor: descriptor)
        cachedFonts[descriptor] = font
        return font
        
    }
    
    private func retrieveFont(forDescriptor descriptor: FontDescriptor) -> BitmapFont {
                
        /* Look for the font family */
        let possibleFamily = findFontFamily(withIdentifier: descriptor.identifier)
        
        /* If the family exists, find a font resource */
        if let family = possibleFamily {
            
            /* Check if a bitmap font with the right parameters is available */
            if let existingFamilyFont = family.bitmapFonts.first(where: { $0.size == descriptor.size && $0.style == descriptor.style }) {
                return existingFamilyFont.resource.content
            }
            
            /* Look for a vector font (during tests, it appeared that it is only loaded for plain fonts) */
            if descriptor.style == PlainTextStyle {
                if let vectorFont = family.vectorFonts.first(where: { $0.style == descriptor.style }) {
                    let ctfont = CTFontCreateWithGraphicsFont(vectorFont.resource.content, CGFloat(descriptor.size), nil, nil)
                    return BitmapFont(fromVectorFont: ctfont)
                }
            }
        }
        
        /* If the style is not plain, look for a plain version on which to apply the style */
        if descriptor.style != PlainTextStyle {
            let plainDescriptor = FontDescriptor(identifier: descriptor.identifier, size: descriptor.size, style: PlainTextStyle)
            let plainFont = retrieveFont(forDescriptor: plainDescriptor)
            return BitmapFont(decorate: plainFont, with: descriptor.style, in: possibleFamily, size: descriptor.size)
        }
        
        /* Look for a Mac OS X font */
        if let macOSXFont = findMacOSXFont(forDescriptor: descriptor) {
            return macOSXFont
        }
        
        /* We can't do anything, just return whatever font */
        NSLog("Unavailable font family: \(descriptor.identifier) for size \(descriptor.size) and style \(descriptor.style), name \(fontNameReferences.first(where: { $0.identifier == descriptor.identifier })?.name ?? "<unkown>")")
        return findAnyFont(forDescriptor: descriptor)
    }
    
    private func findFontFamily(withIdentifier identifier: Int) -> FontFamily? {
        
        /* Look for the resource */
        let possibleFamilyResource = resources.findResource(ofType: \ResourceRepository.fontFamilies, withIdentifier: identifier)
        let possibleFamily = possibleFamilyResource?.content
        
        /* Get the expected name of the font */
        guard let fontNameReference = fontNameReferences.first(where: { $0.identifier == identifier }) else {
            return possibleFamily
        }
        let fontName = fontNameReference.name
        
        /* If the name is right, we're good */
        if let familyResource = possibleFamilyResource, familyResource.name == fontName {
            return possibleFamily
        }
        
        /* If the name doesn't match, try searching by name */
        guard let familyResourceByName = resources.findResource(ofType: \ResourceRepository.fontFamilies, withName: fontName) else {
            return possibleFamily
        }
        
        /* During the tests, I saw that the Font Manager gives precedence to familes with the right name */
        return familyResourceByName.content
        
    }
    
    private func findAnyFont(forDescriptor descriptor: FontDescriptor) -> BitmapFont {
        
        return findFont(withIdentifier: FontIdentifiers.geneva, size: descriptor.size, style: descriptor.style)
    }
    
    private func findMacOSXFont(forDescriptor descriptor: FontDescriptor) -> BitmapFont? {
        
        /* We don't handle styled font */
        guard descriptor.style == PlainTextStyle else {
            return nil
        }
    
        /* Check if we have the font in the table */
        guard let fontNameReference = fontNameReferences.first(where: { $0.identifier == descriptor.identifier }) else {
            return nil
        }
        
        /* Find the font in Mac OS X */
        let name = fontNameReference.name
        let stringName = name.description
        let font = CTFontCreateWithName(stringName as CFString, CGFloat(descriptor.size), nil)
        
        /* We must check the name of the font because if the system doesn't find the right font, it returns an other one */
        let ctFontName = CTFontCopyFamilyName(font) as String
        guard ctFontName == stringName else {
            return nil
        }
        
        return BitmapFont(fromVectorFont: font)
    
    }
    
}



private struct FontDescriptor: Equatable, Hashable {
    public var identifier: Int
    public var size: Int
    public var style: TextStyle
    
    public init(identifier: Int, size: Int, style: TextStyle) {
        self.identifier = identifier
        self.size = size
        self.style = style
    }
    
    public var hashValue: Int {
        var hash = identifier &* 31 ^ size
        hash = style.bold ? hash << 3 ^ 80 : hash
        hash = style.italic ? hash << 3 ^ 70 : hash
        hash = style.underline ? hash << 3 ^ 60 : hash
        hash = style.shadow ? hash << 3 ^ 50 : hash
        hash = style.outline ? hash << 3 ^ 40 : hash
        hash = style.condense ? hash << 3 ^ 30 : hash
        hash = style.extend ? hash << 3 ^ 20 : hash
        hash = style.group ? hash << 3 ^ 10 : hash
        return hash
    }
    
    public static func ==(f1: FontDescriptor, f2: FontDescriptor) -> Bool {
        return f1.identifier == f2.identifier && f1.size == f2.size && f1.style == f2.style
    }
}

