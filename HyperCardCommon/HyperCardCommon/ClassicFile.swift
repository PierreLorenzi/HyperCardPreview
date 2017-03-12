//
//  ClassicFile.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 22/03/2016.
//  Copyright © 2016 Pierre Lorenzi. All rights reserved.
//

import Foundation

open class ClassicFile {
    
    public let dataFork: Data?
    public let resourceFork: Data?
    
    public let resourceRepository: ResourceRepository?
    public let parsedResourceData: ResourceFork?
    
    public init(path: String, loadResourcesFromDataFork: Bool = false) {
        
        /* Register the data */
        self.dataFork = ClassicFile.loadDataFork(path)
        
        /* Read the resources */
        self.resourceFork = ClassicFile.loadResourceFork(path)
        self.parsedResourceData = (loadResourcesFromDataFork) ? ClassicFile.loadResources(dataFork) : ClassicFile.loadResources(resourceFork)
        
        /* Build the resource repository */
        if let resourceFork = self.parsedResourceData {
            self.resourceRepository = ResourceRepository(fromFork: resourceFork)
        }
        else {
            self.resourceRepository = nil
        }
        
    }
    
    private static func loadResources(_ fork: Data?) -> ResourceFork? {
        
        guard let data = fork else {
            return nil
        }
        
        let dataRange = DataRange(sharedData: data, offset: 0, length: data.count)
        return ResourceFork(data: dataRange)
    }
    
    public static func loadResourceFork(_ path: String) -> Data? {
        
        /* Get the size of the fork */
        let cPath = (path as NSString).utf8String
        let size = getxattr(cPath, XATTR_RESOURCEFORK_NAME, nil, 0, 0, 0)
        guard size > 0 else {
            return nil
        }
        
        /* Read the fork */
        guard let data = NSMutableData(capacity: size) else {
            return nil
        }
        data.length = size
        let readSize = getxattr(cPath, XATTR_RESOURCEFORK_NAME, UnsafeMutableRawPointer(mutating: data.bytes.bindMemory(to: Void.self, capacity: size)), size, 0, 0)
        guard readSize == size else {
            return nil
        }
        
        return data as Data
    }
    
    public static func loadDataFork(_ path: String) -> Data? {
        
        return (try? Data(contentsOf: URL(fileURLWithPath: path)))
    }
    
}

public extension ResourceRepository {
    
    public init(fromFork fork: ResourceFork) {
        self.init()
        
        /* Add the icons */
        for iconResourceBlock in fork.icons {
            let iconResource = FileIconResource(resource: iconResourceBlock)
            self.resources.append(iconResource)
        }
        
        /* Add the font families */
        for fontFamilyResourceBlock in fork.fontFamilies {
            let fontFamilyResource = FileFontFamilyResource(resource: fontFamilyResourceBlock, fork: fork)
            self.resources.append(fontFamilyResource)
        }
    }
    
}
