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
    @IBOutlet weak var sizeLabel: NSTextField!
    @IBOutlet weak var openButton: NSButton!
    @IBOutlet weak var exportButton: NSButton!
    
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
            
            /* Parse the sound data */
            guard let sound = Sound(fromResourceData: data) else {
                return nil
            }
            
            /* Build the buffer */
            let fileLength = 2*sound.samples.count + 0x36
            let aiffData = UnsafeMutableRawPointer.allocate(byteCount: fileLength, alignment: 4)
            
            /* Fill the AIFF fields in the data */
            aiffData.advanced(by: 0x0).assumingMemoryBound(to: UInt32.self).pointee = UInt32(0x464F524D).byteSwapped
            aiffData.advanced(by: 0x4).assumingMemoryBound(to: UInt32.self).pointee = UInt32(truncatingIfNeeded: fileLength - 4).byteSwapped
            aiffData.advanced(by: 0x8).assumingMemoryBound(to: UInt32.self).pointee = UInt32(0x41494646).byteSwapped
            aiffData.advanced(by: 0xC).assumingMemoryBound(to: UInt32.self).pointee = UInt32(0x434F4D4D).byteSwapped
            aiffData.advanced(by: 0x10).assumingMemoryBound(to: UInt32.self).pointee = UInt32(18).byteSwapped
            aiffData.advanced(by: 0x14).assumingMemoryBound(to: UInt16.self).pointee = UInt16(1).byteSwapped
            aiffData.advanced(by: 0x16).assumingMemoryBound(to: UInt32.self).pointee = UInt32(truncatingIfNeeded: sound.samples.count).byteSwapped
            aiffData.advanced(by: 0x1A).assumingMemoryBound(to: UInt16.self).pointee = UInt16(16).byteSwapped
            aiffData.advanced(by: 0x1C).assumingMemoryBound(to: Float80.self).pointee = Float80(sound.sampleRate)
            for i in 0..<5 {
                let x = aiffData.advanced(by: 0x1C + i).assumingMemoryBound(to: UInt8.self).pointee
                aiffData.advanced(by: 0x1C + i).assumingMemoryBound(to: UInt8.self).pointee = aiffData.advanced(by: 0x26 - 1 - i).assumingMemoryBound(to: UInt8.self).pointee
                aiffData.advanced(by: 0x26 - 1 - i).assumingMemoryBound(to: UInt8.self).pointee = x
            }
            aiffData.advanced(by: 0x26).assumingMemoryBound(to: UInt32.self).pointee = UInt32(0x53534E44).byteSwapped
            aiffData.advanced(by: 0x2A).assumingMemoryBound(to: UInt32.self).pointee = UInt32(truncatingIfNeeded: 2*sound.samples.count + 8).byteSwapped
            aiffData.advanced(by: 0x2E).assumingMemoryBound(to: UInt32.self).pointee = UInt32(0).byteSwapped
            aiffData.advanced(by: 0x32).assumingMemoryBound(to: UInt32.self).pointee = UInt32(0).byteSwapped
            
            /* Fill the sound data (convert from 8-bit PCM to 16-bit PCM) */
            let sampleBuffer: UnsafeMutablePointer<Int16> = aiffData.advanced(by: 0x36).assumingMemoryBound(to: Int16.self)
            for i in 0..<sound.samples.count {
                sampleBuffer[i] = sound.samples[i].byteSwapped
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
        
        guard let resourceFork = possibleResourceFork else {
            self.refreshToolbar()
            self.refreshSizeLabel()
            self.refreshFooterLabel()
            return
        }
        
        let repository = ResourceRepository(loadFromData: resourceFork)
        
        self.resources = repository.resources.map({ (resource: Resource) -> ResourceElement in
            
            return ResourceElement(type: describeResourceType(resource.typeIdentifier), identifier: resource.identifier, name: resource.name.description, data: resource.getData())
        })
        self.listedResources = self.resources
        self.refreshFooterLabel()
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.collectionView.selectionIndexPaths = [IndexPath(item: 0, section: 0)]
            self.refreshSizeLabel()
            self.refreshToolbar()
        }
    }
    
    private func describeResourceType(_ value: Int) -> String {
        
        /* Build the string char per char */
        var string = ""
        
        for i in 0..<4 {
            
            let value = (value >> ((3-i) * 8)) & 0xFF
            
            /* Append the character to the string */
            let scalar = UnicodeScalar(value)
            let character = Character(scalar!)
            string.append(character)
        }
        
        return string
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
        
        guard !self.listedResources.isEmpty else {
            return
        }
        
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
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        
        self.refreshSizeLabel()
        self.refreshToolbar()
    }
    
    func collectionView(_ collectionView: NSCollectionView, didDeselectItemsAt indexPaths: Set<IndexPath>) {
        
        self.refreshSizeLabel()
        self.refreshToolbar()
    }
    
    private func refreshToolbar() {
        
        let areThereElements = !self.listedResources.isEmpty && !self.collectionView.selectionIndexPaths.isEmpty
        self.openButton.isEnabled = areThereElements
        self.exportButton.isEnabled = areThereElements
    }
    
    private func refreshSizeLabel() {
        
        /* If there are no resource, stop now because there may be selected rows in an empty table */
        guard !self.listedResources.isEmpty else {
            self.sizeLabel.stringValue = ""
            return
        }
        
        let selectionIndexes = self.collectionView.selectionIndexPaths
        
        guard !selectionIndexes.isEmpty else {
            
            self.sizeLabel.stringValue = ""
            return
        }
        
        let totalSize = selectionIndexes.lazy.map { (index: IndexPath) -> Int in
            return self.listedResources[index.item].data.length
            }.reduce(0, +)
        self.sizeLabel.stringValue = ByteCountFormatter.string(fromByteCount: Int64(totalSize), countStyle: ByteCountFormatter.CountStyle.binary)
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
        self.refreshSizeLabel()
        self.refreshToolbar()
        self.collectionView.reloadData()
    }
    
    private func refreshFooterLabel() {
        
        self.footerLabel.stringValue = "\(self.listedResources.count) resource\(self.listedResources.count > 1 ? "s" : "")"
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
        
        /* Security check */
        guard !self.listedResources.isEmpty else {
            return
        }
        
        let selectedIndexes = self.collectionView.selectionIndexPaths
        let selectionCount = selectedIndexes.count
        
        if selectionCount == 1 {
            
            self.exportSingleResource(at: selectedIndexes.first!)
        }
        else if selectionCount > 1 {
            
            self.exportMultipleResources(at: selectedIndexes)
        }
    }
    
    private func exportSingleResource(at index: IndexPath) {
        
        let resource = self.listedResources[index.item]
        
        /* Make a list of the single possible file extension */
        let allowedFileExtensions: [String]
        if let fileExtension = self.getFileExtensionForResource(resource) {
            allowedFileExtensions = [fileExtension]
        }
        else {
            allowedFileExtensions = []
        }
        
        
        /* Set up the save panel */
        let savePanel = NSSavePanel()
        savePanel.title = "Export Resource"
        savePanel.message = "Choose a file where to export the resource:"
        savePanel.allowedFileTypes = allowedFileExtensions
        savePanel.allowsOtherFileTypes = false
        
        /* Open panel */
        savePanel.begin { (response: NSApplication.ModalResponse) in
            
            /* Check the user clicked "OK" */
            guard response == NSApplication.ModalResponse.OK else {
                return
            }
            
            /* Get the requested url */
            guard let url = savePanel.url else {
                return
            }
            
            ResourceController.queue.async {
                
                do {
                    
                    try self.exportResource(resource, to: url)
                    
                }
                catch _ {
                    DispatchQueue.main.async {
                        let alert = NSAlert()
                        alert.alertStyle = .warning
                        alert.messageText = "Can't export the resource"
                        alert.informativeText = "The selected resource couldn't be exported"
                        alert.runModal()
                    }
                }
            }
            
        }
    }
    
    private func exportMultipleResources(at indexes: Set<IndexPath>) {
        
        /* Set up the open panel */
        let openPanel = NSOpenPanel()
        openPanel.title = "Export Multiple Resources"
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
            let selectedResources = indexes.map({ (index: IndexPath) -> ResourceElement in
                
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
                    let fileSuffix = (fileExtension != nil) ? ".\(fileExtension!)" : ""
                    let resourceFileName = "res-\(resource.type)-\(resource.identifier)\(fileSuffix)"
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
    
    private func getFileExtensionForResource(_ resource: ResourceElement) -> String? {
        
        switch resource.readContent() {
            
        case .generic:
            return nil
            
        case .icon:
            return "tif"
            
        case .picture:
            return "pict"
            
        case .sound:
            return "aiff"
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


