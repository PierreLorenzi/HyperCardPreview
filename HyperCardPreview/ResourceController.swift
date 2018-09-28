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
                
            case "snd ":
                let possibleAiff = ResourceElement.convertSndToAIFF(data: self.data)
                let possibleSound: NSSound?
                if let aiff = possibleAiff {
                    possibleSound = NSSound(data: aiff)
                }
                else {
                    possibleSound = nil
                }
                return ResourceContent.sound(possibleSound)
                
            default:
                return ResourceContent.generic(data: self.data)
            }
        }
        
        private static func convertSndToAIFF(data: DataRange) -> Data? {
            
            /* This is a very limited and messy function to make an AIFF
             out of a snd resource. It is the fastest way I've found to play an old sound. */
            
            /* We only accept format 2 'snd ' resources, because HyperCard did (and it's easier that way) */
            guard data.readUInt16(at: 0x0) == 2 else {
                return nil
            }
            
            /* The first command of a format 2 resource should be bufferCmd or soundCmd */
            guard data.readUInt16(at: 0x6) == 0x8050 || data.readUInt16(at: 0x6) == 0x8051 else {
                return nil
            }
            
            /* Get the offset of the sampled sound */
            let soundOffset = data.readUInt32(at: 0xA)
            
            /* Check that the sampled sound is in the data */
            guard data.readUInt32(at: soundOffset + 0x0) == 0 else {
                return nil
            }
            
            /* Read the header of the sampled sound, which contain the parameters */
            let byteCount = data.readUInt32(at: soundOffset + 0x4)
            let sampleRateValue = data.readUInt32(at: soundOffset + 0x8)
            let sampleRate: Double
            switch sampleRateValue {
            case 0xAC440000:
                sampleRate = 44100.0
            case 0x56EE8BA3:
                sampleRate = 22254.54545
            case 0x2B7745D1:
                sampleRate = 11127.27273
            default:
                sampleRate = 11127.27273 //Double(sampleRateValue)
            }
            guard data.readUInt8(at: soundOffset + 0x14) == 0 else {
                return nil
            }
            
            /* Build the buffer */
            let fileLength = 2*byteCount + 0x36
            let aiffData = UnsafeMutableRawPointer.allocate(byteCount: fileLength, alignment: 4)
            
            /* Fill the AIFF fields in the data */
            aiffData.advanced(by: 0x0).assumingMemoryBound(to: UInt32.self).pointee = UInt32(0x464F524D).byteSwapped
            aiffData.advanced(by: 0x4).assumingMemoryBound(to: UInt32.self).pointee = UInt32(truncatingIfNeeded: fileLength - 4).byteSwapped
            aiffData.advanced(by: 0x8).assumingMemoryBound(to: UInt32.self).pointee = UInt32(0x41494646).byteSwapped
            aiffData.advanced(by: 0xC).assumingMemoryBound(to: UInt32.self).pointee = UInt32(0x434F4D4D).byteSwapped
            aiffData.advanced(by: 0x10).assumingMemoryBound(to: UInt32.self).pointee = UInt32(18).byteSwapped
            aiffData.advanced(by: 0x14).assumingMemoryBound(to: UInt16.self).pointee = UInt16(1).byteSwapped
            aiffData.advanced(by: 0x16).assumingMemoryBound(to: UInt32.self).pointee = UInt32(truncatingIfNeeded: byteCount).byteSwapped
            aiffData.advanced(by: 0x1A).assumingMemoryBound(to: UInt16.self).pointee = UInt16(16).byteSwapped
            aiffData.advanced(by: 0x1C).assumingMemoryBound(to: Float80.self).pointee = Float80(sampleRate)
            for i in 0..<5 {
                let x = aiffData.advanced(by: 0x1C + i).assumingMemoryBound(to: UInt8.self).pointee
                aiffData.advanced(by: 0x1C + i).assumingMemoryBound(to: UInt8.self).pointee = aiffData.advanced(by: 0x26 - 1 - i).assumingMemoryBound(to: UInt8.self).pointee
                aiffData.advanced(by: 0x26 - 1 - i).assumingMemoryBound(to: UInt8.self).pointee = x
            }
            aiffData.advanced(by: 0x26).assumingMemoryBound(to: UInt32.self).pointee = UInt32(0x53534E44).byteSwapped
            aiffData.advanced(by: 0x2A).assumingMemoryBound(to: UInt32.self).pointee = UInt32(truncatingIfNeeded: 2*byteCount + 8).byteSwapped
            aiffData.advanced(by: 0x2E).assumingMemoryBound(to: UInt32.self).pointee = UInt32(0).byteSwapped
            aiffData.advanced(by: 0x32).assumingMemoryBound(to: UInt32.self).pointee = UInt32(0).byteSwapped
            
            /* Fill the sound data (convert from 8-bit PCM to 16-bit PCM) */
            for i in 0..<byteCount {
                let byte = data.sharedData[data.offset + soundOffset + 0x16 + i]
                let shiftedByte = byte &+ UInt8(128)
                aiffData.advanced(by: 0x36 + 2*i).assumingMemoryBound(to: UInt8.self).pointee = shiftedByte
            }
            
            /* Use the data */
            let finalData = Data(bytesNoCopy: aiffData, count: fileLength, deallocator: Data.Deallocator.free)
            return finalData
        }
    }
    
    private enum ResourceContent {
        case generic(data: DataRange)
        case icon(NSImage)
        case picture(NSImage)
        case sound(NSSound?)
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
    
    override func windowTitle(forDocumentDisplayName displayName: String) -> String {
        return "Resources"
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.resources.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        
        let item = collectionView.makeItem(withIdentifier: ResourceController.resourceItemIdentifier, for: indexPath) as! ResourceItem
        
        let element = self.resources[indexPath.item]
        
        let view = item.view as! ResourceItemView
        
        let image: NSImage
        switch element.readContent() {
        case .generic:
            image = NSImage(named: "BinaryResourceIcon")!
        case .icon(let icon):
            image = icon
        case .picture(let picture):
            image = picture
        case .sound:
            image = NSImage(named: "SoundResourceIcon")!
        }
        
        view.displayResource(image: image, type: element.type, identifier: element.identifier, name: element.name)
        
        if view.doubleClickAction == nil {
            view.doubleClickAction = {
                [unowned self] in
                self.openSelectedResources()
            }
        }
        
        return item
    }
    
    private func openSelectedResources() {
        
        for indexPath in self.collectionView.selectionIndexPaths {
            
            let element = self.resources[indexPath.item]
            
            switch element.readContent() {
                
            case .picture(let image):
                let controller = ResourceImageController(windowNibName: "ResourceImageWindow")
                _ = controller.window // Load the nib
                controller.displayImage(image: image)
                controller.showWindow(nil)
                self.document!.addWindowController(controller)
                
            case .icon(let image):
                let controller = ResourceImageController(windowNibName: "ResourceImageWindow")
                _ = controller.window // Load the nib
                controller.displayImage(image: image)
                controller.showWindow(nil)
                self.document!.addWindowController(controller)
                
            case .sound(let possibleSound):
                if let sound = possibleSound {
                    sound.play()
                }
                else {
                    NSSound.beep()
                }
                
            case .generic(let data):
                let controller = ResourceBinaryController(windowNibName: "ResourceBinaryWindow")
                _ = controller.window // Load the nib
                controller.displayData(data)
                controller.showWindow(nil)
                self.document!.addWindowController(controller)
                
            }
        }
    }
    
}

