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
    public var identifier: Int {
        get { return self.identifierProperty.value }
        set { self.identifierProperty.value = newValue }
    }
    public var identifierProperty: Property<Int>
    
    /// The name
    public var name: HString {
        get { return self.nameProperty.value }
        set { self.nameProperty.value = newValue }
    }
    public var nameProperty: Property<HString>
    
    /// The type, linked to the type of the data contained in the resource
    public var type: ResourceType<T> {
        get { return self.typeProperty.value }
        set { self.typeProperty.value = newValue }
    }
    public var typeProperty: Property<ResourceType<T>>
    
    /// The data contained in the resource
    public var content: T {
        get { return self.contentProperty.value }
        set { self.contentProperty.value = newValue }
    }
    public var contentProperty: Property<T>
    
    /// Main constructor, explicit so it is public
    public init(identifier: Int, name: HString, type: ResourceType<T>, content: T) {
        self.identifierProperty = Property<Int>(identifier)
        self.nameProperty = Property<HString>(name)
        self.typeProperty = Property<ResourceType<T>>(type)
        self.contentProperty = Property<T>(content)
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
}
