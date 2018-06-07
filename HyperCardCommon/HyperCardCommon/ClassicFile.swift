//
//  ClassicFile.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 22/03/2016.
//  Copyright © 2016 Pierre Lorenzi. All rights reserved.
//

import Foundation


/// A file as in classic Mac OS, with a data fork and a resource fork.
public class ClassicFile {
    
    /// The data fork
    public let dataFork: Data?
    
    /// The resource fork
    public let resourceFork: Data?
    
    public init(dataFork: Data?, resourceFork: Data?) {
        self.dataFork = dataFork
        self.resourceFork = resourceFork
    }
}

public extension ClassicFile {
    
    /// Reads a file at the specified path. Reads the resource fork as an X_ATTR attribute.
    public convenience init(path: String) {
        
        /* Register the data */
        let dataFork = ClassicFile.loadDataFork(path)
        
        /* Read the resources */
        let resourceFork = ClassicFile.loadResourceFork(path)
        
        self.init(dataFork: dataFork, resourceFork: resourceFork)
    }
    
    private static func loadResourceFork(_ path: String) -> Data? {
        
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
    
    private static func loadDataFork(_ path: String) -> Data? {
        
        return (try? Data(contentsOf: URL(fileURLWithPath: path)))
    }
    
}
