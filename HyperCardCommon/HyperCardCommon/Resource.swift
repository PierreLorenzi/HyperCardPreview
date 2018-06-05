//
//  Resource.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 28/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


public protocol ResourceType {
    associatedtype ContentType
}

/// A resource data in a resource fork. T is the type of the data contained in the resource.
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

/// Black & White Icons
public struct IconResourceType: ResourceType {
    public typealias ContentType = Image
}
public typealias IconResource = Resource<IconResourceType>

/// Fonts
public struct FontFamilyResourceType: ResourceType {
    public typealias ContentType = FontFamily
}
public typealias FontFamilyResource = Resource<FontFamilyResourceType>

/// Bitmap Fonts
public struct BitmapFontResourceType: ResourceType {
    public typealias ContentType = BitmapFont
}
public typealias BitmapFontResource = Resource<BitmapFontResourceType>

/// Vector Fonts
public struct VectorFontResourceType: ResourceType {
    public typealias ContentType = CGFont
}
public typealias VectorFontResource = Resource<VectorFontResourceType>

/// AddColor card colors
public struct CardColorResourceType: ResourceType {
    public typealias ContentType = [AddColorElement]
}
public typealias CardColorResource = Resource<CardColorResourceType>

/// AddColor background colors
public struct BackgroundColorResourceType: ResourceType {
    public typealias ContentType = [AddColorElement]
}
public typealias BackgroundColorResource = Resource<BackgroundColorResourceType>

/// Pictures
public struct PictureResourceType: ResourceType {
    public typealias ContentType = NSImage
}
public typealias PictureResource = Resource<PictureResourceType>
