//
//  ResourceController.swift
//  HyperCardPreview
//
//  Created by Pierre Lorenzi on 27/09/2018.
//  Copyright © 2018 Pierre Lorenzi. All rights reserved.
//

import Cocoa
import HyperCardCommon


class ResourceController: NSWindowController, NSCollectionViewDataSource, NSCollectionViewDelegate {
    
    private var resources: [ResourceElement] = []
    
    private var listedResources: [ResourceElement] = []
    
    @IBOutlet weak var collectionView: CollectionView!
    @IBOutlet weak var searchField: NSSearchField!
    @IBOutlet weak var footerLabel: NSTextField!
    
    private static let resourceItemIdentifier = NSUserInterfaceItemIdentifier("ResourceItem")
    
    private static let queue = DispatchQueue(label: "Resource Export", qos: DispatchQoS.background, attributes: [DispatchQueue.Attributes.concurrent], autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency.inherit, target: nil)
    
    private enum ExportError: Error {
        case error
    }
    
    private class ResourceElement {
        
        let type: String
        let identifier: Int
        let name: String
        let data: DataRange
        
        private var cachedContent: ResourceContent?
        private var cachedSearchString: String?
        
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
        
        static func convertSndToAIFF(data: DataRange) -> Data? {
            
            /* This is a very limited and messy function to make an AIFF
             out of a snd resource. It is the fastest way I've found to play an old sound. */
            
            /* There are two format of sdn resources, the data is not in the same place */
            let format = data.readUInt16(at: 0x0)
            let commandOffset: Int
            switch format {
            case 1:
                commandOffset = 0xC
            case 2:
                commandOffset = 0x6
            default:
                return nil
            }
            
            /* The first command of a format 2 resource should be bufferCmd or soundCmd */
            guard data.readUInt16(at: commandOffset) == 0x8050 || data.readUInt16(at: commandOffset) == 0x8051 else {
                return nil
            }
            
            /* Get the offset of the sampled sound */
            let soundOffset = data.readUInt32(at: commandOffset + 0x4)
            
            /* Check that the sampled sound is in the data */
            guard data.readUInt32(at: soundOffset + 0x0) == 0 else {
                return nil
            }
            
            /* Read the header of the sampled sound, which contain the parameters */
            let byteCount = data.readUInt32(at: soundOffset + 0x4)
            let sampleRateValue = data.readUInt32(at: soundOffset + 0x8)
            let sampleRate = Double(sampleRateValue) / 65536.0
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
        
        func readSearchString() -> String {
            
            if let searchString = self.cachedSearchString {
                return searchString
            }
            
            let newSearchString = self.buildSearchString()
            self.cachedSearchString = newSearchString
            return newSearchString
        }
        
        private func buildSearchString() -> String {
            
            return "\(self.type) \(self.identifier) \(self.name)".uppercased()
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
        self.collectionView.mainAction = {
            [unowned self] in
            self.openSelectedResources(nil)
        }
        self.collectionView.setDraggingSourceOperationMask(NSDragOperation.copy, forLocal: false)
        
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
        self.listedResources = self.resources
        self.refreshFooterLabel()
        
        DispatchQueue.main.async {
            self.collectionView.selectionIndexPaths = [IndexPath(item: 0, section: 0)]
        }
    }
    
    override func windowTitle(forDocumentDisplayName displayName: String) -> String {
        return "Resources"
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.listedResources.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        
        let item = collectionView.makeItem(withIdentifier: ResourceController.resourceItemIdentifier, for: indexPath) as! ResourceItem
        
        let element = self.listedResources[indexPath.item]
        
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
                self.openSelectedResources(nil)
            }
        }
        
        return item
    }
    
    @objc @IBAction func openSelectedResources(_ sender: AnyObject?) {
        
        for indexPath in self.collectionView.selectionIndexPaths {
            
            let element = self.listedResources[indexPath.item]
            
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
    
    func collectionView(_ collectionView: NSCollectionView, canDragItemsAt indexPaths: Set<IndexPath>, with event: NSEvent) -> Bool {
        
        return true
    }
    
    func collectionView(_ collectionView: NSCollectionView, pasteboardWriterForItemAt indexPath: IndexPath) -> NSPasteboardWriting? {
        
        let element = self.listedResources[indexPath.item]
        switch element.readContent() {
            
        case .generic:
            return nil
            
        case .icon(let image):
            return image
            
        case .picture(let image):
            return image
            
        case .sound(let possibleSound):
            return possibleSound ?? NSSound(named: "EmptySound")!
        }
    }
    
    @objc @IBAction func search(_ sender: AnyObject) {
        
        let query = self.searchField.stringValue
        let uppercaseQuery = query.uppercased()
        let terms = uppercaseQuery.components(separatedBy: CharacterSet.whitespaces)
        
        self.listedResources = self.resources.filter({ (element: ResourceController.ResourceElement) -> Bool in
            
            for term in terms {
                
                guard !term.isEmpty else {
                    continue
                }
                
                guard self.doesStringContainString(element.readSearchString(), substring: term) else {
                    return false
                }
            }
            
            return true
        })
        
        self.refreshFooterLabel()
        self.collectionView.reloadData()
    }
    
    private func refreshFooterLabel() {
        
        self.footerLabel.stringValue = "\(self.listedResources.count) resources"
    }
    
    private func doesStringContainString(_ string: String, substring: String) -> Bool {
        
        var index = 0
        let stringCount = string.count
        let substringCount = substring.count
        
        for char in string {
            if stringCount - index < substringCount {
                break
            }
            if substring.first == char {
                // Create a start and end index to ultimately creata range
                //
                // Hello Agnosticdev, I love Tutorials
                //       6   ->   17 - rage of substring from 7 to 18
                //
                let startOfFoundCharacter = string.index(string.startIndex, offsetBy: index)
                let lengthOfFoundCharacter = string.index(string.startIndex, offsetBy: (substringCount + index))
                
                // Grab the substring from the parent string and compare it against substring
                // Essentially, looking for the needle in a haystack
                if string[startOfFoundCharacter..<lengthOfFoundCharacter] == substring {
                    return true
                }
                
            }
            index += 1
        }
        
        return false
    }
    
    @objc @IBAction func exportSelectedResources(_ sender: AnyObject?) {
        
        /* Set up the open panel */
        let openPanel = NSOpenPanel()
        openPanel.title = "Export Resources"
        openPanel.message = "Choose a directory where to export the resources:"
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = false
        
        /* Open panel */
        openPanel.begin { (response: NSApplication.ModalResponse) in
            
            /* Check the user clicked "OK" */
            guard response == NSApplication.ModalResponse.OK else {
                return
            }
            
            /* Get the requested url */
            guard let url = openPanel.url else {
                return
            }
            
            /* Get the selected elements */
            let selectedResources = self.collectionView.selectionIndexPaths.map({ (index: IndexPath) -> ResourceElement in
                
                return self.listedResources[index.item]
            })
            
            guard !selectedResources.isEmpty else {
                return
            }
            
            ResourceController.queue.async {
                
                var failedResources: [ResourceElement] = []
                
                /* Save every resource */
                for resource in selectedResources {
                    
                    let fileExtension = self.getFileExtensionForResource(resource)
                    let resourceFileName = "res-\(resource.type)-\(resource.identifier)\(fileExtension)"
                    let resourceUrl = URL(fileURLWithPath: resourceFileName, relativeTo: url)
                    
                    
                    do {
                        
                        try self.exportResource(resource, to: resourceUrl)
                        
                    }
                    catch _ {
                        failedResources.append(resource)
                    }
                }
                
                if !failedResources.isEmpty {
                    DispatchQueue.main.async {
                        var resourceString = failedResources.map({ "\($0.type) \($0.identifier), " }).reduce("", +)
                        resourceString = String(resourceString.prefix(resourceString.count - 2))
                        
                        let alert = NSAlert()
                        alert.alertStyle = .warning
                        alert.messageText = "Can't export some resources"
                        alert.informativeText = "The following resources couldn't be exported: \(resourceString)"
                        alert.runModal()
                    }
                }
            }
            
        }
    }
    
    private func getFileExtensionForResource(_ resource: ResourceElement) -> String {
        
        switch resource.readContent() {
            
        case .generic:
            return ""
            
        case .icon:
            return ".tif"
            
        case .picture:
            return ".pict"
            
        case .sound:
            return ".aiff"
        }
    }
    
    private func exportResource(_ resource: ResourceElement, to resourceUrl: URL) throws {
        
        switch resource.readContent() {
            
        case .generic:
            let slice = resource.data.sharedData[resource.data.offset ..< resource.data.offset + resource.data.length]
            let data = Data(slice)
            try data.write(to: resourceUrl)
            
        case .picture:
            let slice = resource.data.sharedData[resource.data.offset ..< resource.data.offset + resource.data.length]
            let data = Data(slice)
            try data.write(to: resourceUrl)
            
        case .sound:
            if let data = ResourceElement.convertSndToAIFF(data: resource.data) {
                try data.write(to: resourceUrl)
            }
            else {
                throw ExportError.error
            }
            
        case .icon:
            let icon = Icon(loadFromData: resource.data)
            let image = icon.image
            let cgimage = RgbConverter.convertImage(image)
            let nsimagerep = NSBitmapImageRep(cgImage: cgimage)
            if let data = nsimagerep.tiffRepresentation {
                try data.write(to: resourceUrl)
            }
            else {
                throw ExportError.error
            }
        }
    }
    
}


