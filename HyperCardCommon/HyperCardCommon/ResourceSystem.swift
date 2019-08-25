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
    public func findResource(ofType typeIdentifier: Int, withIdentifier identifier: Int) -> Resource? {
        for repository in repositories {
            if let resource = repository.resources.first(where: { $0.typeIdentifier == typeIdentifier && $0.identifier == identifier }) {
                return resource
            }
        }
        return nil
    }
    
    /// Finds a resource by name in the forks, respecting the order of precedence
    public func findResource(ofType typeIdentifier: Int, withName name: HString) -> Resource? {
        for repository in repositories {
            if let resource = repository.resources.first(where: { $0.typeIdentifier == typeIdentifier && compareCase($0.name, name) == .equal }) {
                return resource
            }
        }
        return nil
    }
    
}
