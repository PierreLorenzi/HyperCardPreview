//
//  Resource.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 28/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


/// Represents a resource type, symbolized in Mac OS by a four-letter name like
/// 'ICON' for icons or 'NFNT' for fonts.
/// <p>
/// ContentType is the type used in the code to represent its data content.
public protocol ResourceType {
    associatedtype ContentType
}

/// The content of a resource in a resource fork.
public class Resource<T: ResourceType> {
    
    /// The identifier
    public var identifier: Int
    
    /// The name
    public var name: HString
    
    /// The data contained in the resource
    public var content: T.ContentType {
        get { return self.contentProperty.value }
        set { self.contentProperty.value = newValue }
    }
    public let contentProperty: Property<T.ContentType>
    
    /// Main constructor, explicit so it is public
    public init(identifier: Int, name: HString, contentProperty: Property<T.ContentType>) {
        self.identifier = identifier
        self.name = name
        self.contentProperty = contentProperty
    }
    
}

/// Black & White Icons without mask, formerly named 'PICT'
public struct IconResourceType: ResourceType {
    public typealias ContentType = Icon
}
public typealias IconResource = Resource<IconResourceType>

/// Fonts, formerly named 'FOND'
public struct FontFamilyResourceType: ResourceType {
    public typealias ContentType = FontFamily
}
public typealias FontFamilyResource = Resource<FontFamilyResourceType>

/// Bitmap Fonts, naformerly namedmed 'NFNT' or 'FONT'
public struct BitmapFontResourceType: ResourceType {
    public typealias ContentType = BitmapFont
}
public typealias BitmapFontResource = Resource<BitmapFontResourceType>

/// Vector Fonts, formerly named 'sfnt'
public struct VectorFontResourceType: ResourceType {
    public typealias ContentType = VectorFont
}
public typealias VectorFontResource = Resource<VectorFontResourceType>

/// AddColor card colors, formerly named 'HCcd'
public struct CardColorResourceType: ResourceType {
    public typealias ContentType = LayerColor
}
public typealias CardColorResource = Resource<CardColorResourceType>

/// AddColor background colors, formerly named 'HCbg'
public struct BackgroundColorResourceType: ResourceType {
    public typealias ContentType = LayerColor
}
public typealias BackgroundColorResource = Resource<BackgroundColorResourceType>

/// Color Pictures, formerly named 'PICT'
public struct PictureResourceType: ResourceType {
    public typealias ContentType = Picture
}
public typealias PictureResource = Resource<PictureResourceType>
