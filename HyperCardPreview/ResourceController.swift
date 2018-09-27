//
//  ResourceController.swift
//  HyperCardPreview
//
//  Created by Pierre Lorenzi on 27/09/2018.
//  Copyright © 2018 Pierre Lorenzi. All rights reserved.
//

import Cocoa
import HyperCardCommon


class ResourceController: NSWindowController, NSCollectionViewDataSource {
    
    private var resources: [ResourceElement] = []
    
    @IBOutlet weak var collectionView: NSCollectionView!
    
    private static let resourceItemIdentifier = NSUserInterfaceItemIdentifier("ResourceItem")
    
    private class ResourceElement {
        
        let type: String
        let identifier: Int
        let name: String
        let data: DataRange
        
        private var cachedContent: ResourceContent?
        
        init(type: String, identifier: Int, name: String, data: DataRange) {
            self.type = type
            self.identifier = identifier
            self.name = name
            self.data = data
        }
        
        func readContent() -> ResourceContent {
            
            if let content = self.cachedContent {
                return content
            }
            
            let newContent = self.buildContent()
            self.cachedContent = newContent
            return newContent
        }
        
        private func buildContent() -> ResourceContent {
            
            switch self.type {
                
            case "ICON":
                let icon = Icon(loadFromData: self.data)
                let cgImage = RgbConverter.convertImage(icon.image)
                let image = NSImage(cgImage: cgImage, size: NSZeroSize)
                return ResourceContent.icon(image)
                
            case "PICT":
                let slice = self.data.sharedData[self.data.offset ..< self.data.offset + self.data.length]
                let pictureData = Data(slice)
                let image = NSImage(data: pictureData)!
                return ResourceContent.picture(image)
                
            default:
                return ResourceContent.generic(data: self.data)
            }
        }
    }
    
    private enum ResourceContent {
        case generic(data: DataRange)
        case icon(NSImage)
        case picture(NSImage)
    }
    
    func setup(resourceFork possibleResourceFork: Data?) {
        
        self.collectionView.register(NSNib(nibNamed: "ResourceItem", bundle: nil), forItemWithIdentifier: ResourceController.resourceItemIdentifier)
        
        guard let resourceFork = possibleResourceFork else {
            return
        }
        
        let dataRange = DataRange(sharedData: resourceFork, offset: 0, length: resourceFork.count)
        let forkReader = ResourceRepositoryReader(data: dataRange)
        let mapReader = forkReader.extractResourceMapReader()
        let references = mapReader.readReferences()
        
        self.resources = references.map({ (reference: ResourceReference) -> ResourceElement in
            
            let dataRange = forkReader.extractResourceData(at: reference.dataOffset)
            return ResourceElement(type: reference.type.description, identifier: reference.identifier, name: reference.name.description, data: dataRange)
        })
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.resources.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        
        let item = collectionView.makeItem(withIdentifier: ResourceController.resourceItemIdentifier, for: indexPath) as! ResourceItem
        
        let element = self.resources[indexPath.item]
        
        item.typeLabel.stringValue = element.type
        item.identifierLabel.intValue = Int32(truncatingIfNeeded: element.identifier)
        item.nameLabel.stringValue = element.name
        
        switch element.readContent() {
        case .generic:
            item.imageView!.image = nil
        case .icon(let image):
            item.imageView!.image = image
        case .picture(let image):
            item.imageView!.image = image
        }
        
        return item
    }
    
}

