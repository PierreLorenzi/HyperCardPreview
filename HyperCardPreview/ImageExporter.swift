//
//  ImageExporter.swift
//  HyperCardPreview
//
//  Created by Pierre Lorenzi on 27/09/2018.
//  Copyright © 2018 Pierre Lorenzi. All rights reserved.
//

import Cocoa
import HyperCardCommon


class ImageExporter {
    
    private let stack: Stack
    private let layerType: LayerType
    
    @IBOutlet weak var accessoryView: NSView!
    @IBOutlet weak var layerTypeLabel: NSTextField!
    @IBOutlet weak var startIndexField: NSTextField!
    @IBOutlet weak var endIndexField: NSTextField!
    @IBOutlet weak var startIndexFormatter: NumberFormatter!
    @IBOutlet weak var endIndexFormatter: NumberFormatter!
    
    @IBOutlet weak var exportWindow: NSWindow!
    @IBOutlet weak var exportLabel: NSTextField!
    @IBOutlet weak var exportBar: NSProgressIndicator!
    
    private static let queue = DispatchQueue(label: "Image Export", qos: DispatchQoS.background, attributes: [DispatchQueue.Attributes.concurrent], autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency.inherit, target: nil)
    
    public static func export(stack: Stack, layerType: LayerType) {
        
        DispatchQueue.main.async {
            
            let exporter = ImageExporter(stack: stack, layerType: layerType)
            exporter.run()
        }
    }
    
    private init(stack: Stack, layerType: LayerType) {
        self.stack = stack
        self.layerType = layerType
    }
    
    private func run() {
        
        /* Load the accessory view */
        guard Bundle.main.loadNibNamed("ExportAccessoryView", owner: self, topLevelObjects: nil) else {
            
            /* Show the alert to the user */
            let alert = NSAlert()
            alert.messageText = "Internal error: can't open panel"
            alert.runModal()
            return
        }
        
        /* Set up the accessory view of the open panel */
        self.layerTypeLabel.stringValue = (self.layerType == .card) ? "Cards:" : "Backgrounds:"
        let maxValue =  (self.layerType == .card) ? self.stack.cards.count : self.stack.backgrounds.count
        self.startIndexField.intValue = 1
        self.endIndexField.intValue = Int32(truncatingIfNeeded: maxValue)
        self.startIndexFormatter.minimum = 1
        self.startIndexFormatter.maximum = NSNumber(integerLiteral: maxValue)
        self.startIndexFormatter.allowsFloats = false
        self.endIndexFormatter.minimum = 1
        self.endIndexFormatter.maximum = NSNumber(integerLiteral: maxValue)
        self.endIndexFormatter.allowsFloats = false
        
        /* Set up the open panel */
        let openPanel = NSOpenPanel()
        openPanel.title = "Export Images"
        openPanel.message = "Choose a directory where to export the images:"
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = false
        openPanel.accessoryView = self.accessoryView
        openPanel.isAccessoryViewDisclosed = true
        
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
            
            /* Get the values */
            let startIndex = self.startIndexField.integerValue - 1
            let endIndex = self.endIndexField.integerValue - 1
            guard startIndex >= 0, startIndex <= endIndex, endIndex < maxValue else {
                return
            }
            
            /* Open the window */
            guard Bundle.main.loadNibNamed("ExportProgress", owner: self, topLevelObjects: nil) else {
                
                /* Show the alert to the user */
                let alert = NSAlert()
                alert.messageText = "Internal error: can't open exportation window"
                alert.runModal()
                return
            }
            let exportMessage = "Export \(endIndex - startIndex + 1) \(self.layerType == .card ? "cards" : "backgrounds")"
            self.exportLabel.stringValue = "\(exportMessage):"
            self.exportBar.minValue = Double(startIndex-1)
            self.exportBar.maxValue = Double(endIndex)
            self.exportBar.doubleValue = Double(startIndex-1)
            self.exportWindow.makeKeyAndOrderFront(nil)
            
            let filePrefix = (self.layerType == .card) ? "Card" : "Background"
            
            ImageExporter.queue.async {
            
                for index in startIndex ... endIndex {
                    
                    /* Create an image of the layer, and if it doesn't exist, a transparent image */
                    let layerImage = (self.layerType == .card) ? self.stack.cards[index].image : self.stack.backgrounds[index].image
                    let image = layerImage ?? MaskedImage(width: self.stack.size.width, height: self.stack.size.height, image: MaskedImage.Layer.clear, mask: MaskedImage.Layer.clear)
                    let cgImage = RgbConverter.convertMaskedImage(image)
                    
                    /* Build the PNG data */
                    let nsImageRep = NSBitmapImageRep(cgImage: cgImage)
                    guard let data = nsImageRep.representation(using: NSBitmapImageRep.FileType.png, properties: [:]) else {
                        
                        DispatchQueue.main.async {
                            /* Show the alert to the user */
                            let alert = NSAlert()
                            alert.messageText = "Can't represent the image as PNG"
                            alert.runModal()
                        }
                        return
                    }
                    
                    do {
                        /* Save the PNG data */
                        try data.write(to: url.appendingPathComponent("\(filePrefix)\(index+1).png"))
                    }
                    catch let error {
                        
                        DispatchQueue.main.async {
                            /* Show the alert to the user */
                            let alert = NSAlert(error: error)
                            alert.messageText = "Can't export image"
                            alert.runModal()
                        }
                        return
                    }
                    
                    if let bar = self.exportBar {
                        /* Update the progress bar */
                        DispatchQueue.main.async {
                            bar.doubleValue = Double(index)
                        }
                    }
                    else {
                        /* The window was closed, stop */
                        return
                    }
                }
                
                /* It's completed */
                DispatchQueue.main.async {
                    if let window = self.exportWindow {
                        window.close()
                    }
                }
            }
            
        }
        
    }
    
}
