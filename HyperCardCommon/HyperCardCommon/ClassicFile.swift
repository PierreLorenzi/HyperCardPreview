//
//  ClassicFile.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 22/03/2016.
//  Copyright © 2016 Pierre Lorenzi. All rights reserved.
//

import Foundation


/// A file as it appears in Classic Mac OS, with a data fork and a resource fork.
public class ClassicFile {
    
    /// The raw data fork
    public let dataFork: Data?
    
    /// The raw resource fork
    public let resourceFork: Data?
    
    /// Reads a file at the specified path. Reads the resource fork as an X_ATTR attribute.
    /// <p>
    /// Set loadResourcesFromDataFork for a rsrc file with the resources in the data fork.
    public init(path: String) {
        
        /* Register the data */
        self.dataFork = ClassicFile.loadDataFork(path)
        
        /* Read the resources */
        self.resourceFork = ClassicFile.loadResourceFork(path)
        
    }
    
    /// Reads the raw resource fork of the file at the specified path.
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
    
    /// Reads the raw data fork of the file at the specified path.
    private static func loadDataFork(_ path: String) -> Data? {
        
        return (try? Data(contentsOf: URL(fileURLWithPath: path)))
    }
    
}
