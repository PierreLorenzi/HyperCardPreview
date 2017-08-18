//
//  FileIcon.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 27/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


/// Implementation of Icon Resource with lazy loading from a file
/// <p>
/// Lazy loading is implemented by hand because an inherited property can't be made
/// lazy in swift.
public class FileIconResource: Resource<Image> {
    
    private let resource: IconResourceBlock
    
    private static let fakeImage = Image(width: 0, height: 0)
    
    public init(resource: IconResourceBlock) {
        self.resource = resource
        
        super.init(identifier: resource.identifier, name: resource.name, type: ResourceTypes.icon, content: FileIconResource.fakeImage)
    }
    
    private var contentLoaded = false
    override public var content: Image {
        get {
            if !contentLoaded {
                super.content = resource.image
                contentLoaded = true
            }
            return super.content
        }
        set {
            super.content = newValue
        }
    }
    
}
