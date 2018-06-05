//
//  ResourceExtractor.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 05/06/2018.
//  Copyright © 2018 Pierre Lorenzi. All rights reserved.
//


public struct ResourceExtractor {
    
    private let reader: ResourceForkReader
    
    private let references: [ResourceReference]
    
    public init(resourceForkReader: ResourceForkReader) {
        self.reader = resourceForkReader
        
        let mapReader = reader.extractResourceMapReader()
        self.references = mapReader.readReferences()
    }
    
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
