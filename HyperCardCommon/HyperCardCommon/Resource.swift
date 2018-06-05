//
//  Resource.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 28/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//



/// A resource data in a resource fork. T is the type of the data contained in the resource.
public class Resource<T> {
    
    /// The identifier
    public var identifier: Int
    
    /// The name
    public var name: HString
    
    /// The type, linked to the type of the data contained in the resource
    public var type: ResourceType<T>
    
    /// The data contained in the resource
    public var content: T {
        get { return self.contentProperty.value }
        set { self.contentProperty.value = newValue }
    }
    public let contentProperty: Property<T>
    
    /// Main constructor, explicit so it is public
    public init(identifier: Int, name: HString, type: ResourceType<T>, contentProperty: Property<T>) {
        self.identifier = identifier
        self.name = name
        self.type = type
        self.contentProperty = contentProperty
    }
    
}

/// A resource type, linked to the type of the data that the resources of that type contain.
public class ResourceType<T> {}

/// Common resource types
public enum ResourceTypes {
    
    /// Black & White Icons
    public static let icon = ResourceType<Image>()
    
    /// Fonts
    public static let fontFamily = ResourceType<FontFamily>()
    
    /// AddColor card colors
    public static let cardColor = ResourceType<[AddColorElement]>()
    
    /// AddColor background colors
    public static let backgroundColor = ResourceType<[AddColorElement]>()
    
    /// Pictures
    public static let picture = ResourceType<NSImage>()
}
