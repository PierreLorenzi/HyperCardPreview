//
//  ResourceSystem.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 03/03/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


public struct ResourceSystem {
    
    public var repositories: [ResourceRepository]   = []
    
    public init() {}
    
    public func findResource<T>(ofType type: ResourceType<T>, withIdentifier identifier: Int) -> Resource<T>? {
        for repository in repositories {
            for resource in repository.resources {
                if let r = resource as? Resource<T>, r.type === type, r.identifier == identifier {
                    return r
                }
            }
        }
        return nil
    }
    
    public func listResources<T>(ofType type: ResourceType<T>) -> [Resource<T>] {
        var list = [Resource<T>]()
        var identifiers = Set<Int>()
        for repository in repositories {
            let repositoryList = repository.resources.flatMap( {
                (resource: Any) -> Resource<T>? in
                if let r = resource as? Resource<T>, r.type === type, !identifiers.contains(r.identifier) {
                    identifiers.insert(r.identifier)
                    return r
                }
                return nil
            } )
            list.append(contentsOf: repositoryList)
        }
        return list
    }
    
}
