//
//  ResourceExtractor.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 05/06/2018.
//  Copyright © 2018 Pierre Lorenzi. All rights reserved.
//


/// Builds resources in bulk from a resource fork data.
public struct ResourceExtractor {
    
    private let reader: ResourceRepositoryReader
    
    private let references: [ResourceReference]
    
    /// Inits with the reader of a resource fork
    public init(resourceForkReader: ResourceRepositoryReader) {
        self.reader = resourceForkReader
        
        let mapReader = reader.extractResourceMapReader()
        self.references = mapReader.readReferences()
    }
    
    /// Builds resources for all the resource data of a certain type in the resource fork.
    /// <p>
    /// The built resources lazily load their contents.
    public func listResources<T: ResourceType>(withType type: T.Type, typeName: NumericName, parse: @escaping (DataRange) -> T.ContentType) -> [Resource<T>] {
        
        let typeReferences = self.references.filter({ $0.type == typeName })
        
        return typeReferences.map({ (reference: ResourceReference) -> Resource<T> in
            
            let data = self.reader.extractResourceData(at: reference.dataOffset)
            let contentProperty = Property<T.ContentType>(lazy: { () -> T.ContentType in
                return parse(data)
            })
            return Resource<T>(identifier: reference.identifier, name: reference.name, contentProperty: contentProperty)
        })
    }
    
}
