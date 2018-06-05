//
//  ClassicFile.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 22/03/2016.
//  Copyright © 2016 Pierre Lorenzi. All rights reserved.
//

import Foundation


/// A file as it appears in Classic Mac OS, with a data fork and a resource fork.
open class ClassicFile {
    
    /// The raw data fork
    public let dataFork: Data?
    
    /// The raw resource fork
    public let resourceFork: Data?
    
    /// The resources contained in the resource fork
    public let resourceRepository: ResourceRepository?
    
    /// The parsed resource fork
    public let parsedResourceData: ResourceFork?
    
    /// Reads a file at the specified path. Reads the resource fork as an X_ATTR attribute.
    /// <p>
    /// Set loadResourcesFromDataFork for a rsrc file with the resources in the data fork.
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
    
    /// Reads the raw resource fork of the file at the specified path.
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
    
    /// Reads the raw data fork of the file at the specified path.
    public static func loadDataFork(_ path: String) -> Data? {
        
        return (try? Data(contentsOf: URL(fileURLWithPath: path)))
    }
    
}

public extension ResourceRepository {
    
    /// Makes a list of the resources in a parsed resource fork.
    public init(fromFork fork: ResourceFork) {
        self.init()
        
        /* Add the icons */
        for iconResourceBlock in fork.extractIcons() {
            let contentProperty = Property<Image> { () -> Image in
                return iconResourceBlock.readImage()
            }
            let iconResource = IconResource(identifier: iconResourceBlock.identifier, name: iconResourceBlock.name, contentProperty: contentProperty)
            self.resources.append(iconResource)
        }
        
        /* Add the font families */
        let bitmapFonts = fork.extractBitmapFonts()
        let vectorFonts = fork.extractVectorFonts()
        for fontFamilyResourceBlock in fork.extractFontFamilies() {
            let contentProperty = Property<FontFamily> { () -> FontFamily in
                return FontFamily(resource: fontFamilyResourceBlock, bitmapFonts: bitmapFonts, vectorFonts: vectorFonts)
            }
            let fontFamilyResource = FontFamilyResource(identifier: fontFamilyResourceBlock.identifier, name: fontFamilyResourceBlock.name, contentProperty: contentProperty)
            self.resources.append(fontFamilyResource)
        }
        
        /* Add the AddColor elements in cards */
        for resourceBlock in fork.extractCardColors() {
            let contentProperty = Property<[AddColorElement]> { () -> [AddColorElement] in
                return resourceBlock.readElements()
            }
            let resource = CardColorResource(identifier: resourceBlock.identifier, name: resourceBlock.name, contentProperty: contentProperty)
            self.resources.append(resource)
        }
        
        /* Add the AddColor elements in backgrounds */
        for resourceBlock in fork.extractBackgroundColors() {
            let contentProperty = Property<[AddColorElement]> { () -> [AddColorElement] in
                return resourceBlock.readElements()
            }
            let resource = BackgroundColorResource(identifier: resourceBlock.identifier, name: resourceBlock.name, contentProperty: contentProperty)
            self.resources.append(resource)
        }
        
        /* Add the pictures */
        for resourceBlock in fork.extractPictures() {
            let contentProperty = Property<NSImage> { () -> NSImage in
                return resourceBlock.readImage()
            }
            let resource = PictureResource(identifier: resourceBlock.identifier, name: resourceBlock.name, contentProperty: contentProperty)
            self.resources.append(resource)
        }
    }
    
}
