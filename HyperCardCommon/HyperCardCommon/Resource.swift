//
//  Resource.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 28/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


/// A resource in a resource fork.
public class Resource {
    
    /// The identifier
    public var identifier: Int
    
    /// The name
    public var name: HString
    
    /// The type identifier, read in the content
    public var typeIdentifier: Int
    
    /// The data contained in the resource
    public var content: ResourceContent {
        get { return self.contentProperty.value }
        set { self.contentProperty.value = newValue }
    }
    public let contentProperty: Property<ResourceContent>
    
    /// Main constructor, explicit so it is public
    public init(identifier: Int, name: HString, typeIdentifier: Int, contentProperty: Property<ResourceContent>) {
        self.identifier = identifier
        self.name = name
        self.typeIdentifier = typeIdentifier
        self.contentProperty = contentProperty
    }
}

public enum ResourceContent {
    
    case icon(Icon)
    case fontFamily(FontFamily)
    case bitmapFont(BitmapFont)
    case bitmapFontOld(BitmapFont)
    case vectorFont(VectorFont)
    case cardColor(LayerColor)
    case backgroundColor(LayerColor)
    case picture(Picture)
    case notParsed(typeIdentifier: Int, data: DataRange)
}

public enum ResourceType {
    
    public static let icon = 0x49434F4E // ICON
    public static let fontFamily = 0x464F4E44 // FOND
    public static let bitmapFont = 0x4E464E54 // NFNT
    public static let bitmapFontOld = 0x464F4E54 // FONT
    public static let vectorFont = 0x73666E74 // sfnt
    public static let cardColor = 0x48436364 // HCcd
    public static let backgroundColor = 0x48436267 // HCbg
    public static let picture = 0x50494354 // PICT
}

/* The shortcut functions */
public extension Resource {
    
    func getIcon() -> Icon {
        
        guard case ResourceContent.icon(let icon) = self.content else {
            fatalError()
        }
        
        return icon
    }
    
    func getFontFamily() -> FontFamily {
        
        guard case ResourceContent.fontFamily(let fontFamily) = self.content else {
            fatalError()
        }
        
        return fontFamily
    }
    
    func getBitmapFont() -> BitmapFont {
        
        if case ResourceContent.bitmapFont(let bitmapFont) = self.content {
            return bitmapFont
        }
        
        if case ResourceContent.bitmapFontOld(let bitmapFontOld) = self.content {
            return bitmapFontOld
        }
        
        fatalError()
    }
    
    func getVectorFont() -> VectorFont {
        
        guard case ResourceContent.vectorFont(let vectorFont) = self.content else {
            fatalError()
        }
        
        return vectorFont
    }
    
    func getCardColor() -> LayerColor {
        
        guard case ResourceContent.cardColor(let cardColor) = self.content else {
            fatalError()
        }
        
        return cardColor
    }
    
    func getBackgroundColor() -> LayerColor {
        
        guard case ResourceContent.backgroundColor(let backgroundColor) = self.content else {
            fatalError()
        }
        
        return backgroundColor
    }
    
    func getPicture() -> Picture {
        
        guard case ResourceContent.picture(let picture) = self.content else {
            fatalError()
        }
        
        return picture
    }
    
    func getDataContent() -> DataRange {
        
        guard case ResourceContent.notParsed(_, let data) = self.content else {
            fatalError()
        }
        
        return data
    }
    
}
