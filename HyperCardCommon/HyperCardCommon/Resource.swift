//
//  Resource.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 28/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//



public class Resource<T> {
    
    public var identifier: Int
    public var name: HString
    public var type: ResourceType<T>
    public var content: T
    
    public init(identifier: Int, name: HString, type: ResourceType<T>, content: T) {
        self.identifier = identifier
        self.name = name
        self.type = type
        self.content = content
    }
    
}

public class ResourceType<T> {}

public enum ResourceTypes {
    public static let icon = ResourceType<Image>()
    public static let fontFamily = ResourceType<FontFamily>()
}
