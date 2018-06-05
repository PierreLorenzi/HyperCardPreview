//
//  ResourceSystem.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 03/03/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


/// A stack of resource forks. In Classic Mac OS, resource forks are stacked, from
/// local to global. When a resource is present in several forks, the first one has
/// precedence, so the global resources of the system can be overriden by local
/// resources in stacks.
public struct ResourceSystem {
    
    /// The resource forks in their order
    public var repositories: [ResourceRepository]   = []
    
    /// Main constructor, declared to be public
    public init() {}
    
    /// Finds a resource by identifier in the forks, respecting the order of precedence
    public func findResource<T: ResourceType>(ofType type: T.Type, withIdentifier identifier: Int) -> Resource<T>? {
        for repository in repositories {
            for resource in repository.resources {
                if let r = resource as? Resource<T>, r.identifier == identifier {
                    return r
                }
            }
        }
        return nil
    }
    
    /// Finds a resource by name in the forks, respecting the order of precedence
    public func findResource<T: ResourceType>(ofType type: T.Type, withName name: HString) -> Resource<T>? {
        for repository in repositories {
            for resource in repository.resources {
                if let r = resource as? Resource<T>, r.name == name {
                    return r
                }
            }
        }
        return nil
    }
    
    /// Lists all the resources of a certain type. Respects the order of precedence.
    public func listResources<T: ResourceType>(ofType type: T.Type) -> [Resource<T>] {
        var list = [Resource<T>]()
        var identifiers = Set<Int>()
        for repository in repositories {
            let repositoryList = repository.resources.compactMap( {
                (resource: Any) -> Resource<T>? in
                if let r = resource as? Resource<T>, !identifiers.contains(r.identifier) {
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
