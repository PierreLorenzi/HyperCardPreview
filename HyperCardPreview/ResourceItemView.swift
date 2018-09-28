//
//  ResourceItemView.swift
//  HyperCardPreview
//
//  Created by Pierre Lorenzi on 28/09/2018.
//  Copyright © 2018 Pierre Lorenzi. All rights reserved.
//

import Cocoa


class ResourceItemView: NSView {
    
    let imageLayer: CALayer
    
    let typeLayer: CATextLayer
    
    let identifierLayer: CATextLayer
    
    let nameLayer: CATextLayer
    
    var selectionLayer: CALayer? = nil
    
    private static let lineHeight = CGFloat(18.0)
    private static let iconTextMargin = CGFloat(5.0)
    
    static let selectionMargin: CGFloat = 10.0
    static let selectionColor = CGColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 0.8)
    
    required init?(coder: NSCoder) {
        
        /* Create the layers */
        self.imageLayer = CALayer()
        self.typeLayer = CATextLayer()
        self.identifierLayer = CATextLayer()
        self.nameLayer = CATextLayer()
        
        /* Init */
        super.init(coder: coder)
        
        /* Set-up us self as layer */
        let layer = CALayer()
        layer.isOpaque = true
        self.layer = layer
        self.wantsLayer = true
        
        /* Add the sublayers */
        layer.addSublayer(self.imageLayer)
        layer.addSublayer(self.typeLayer)
        layer.addSublayer(self.identifierLayer)
        layer.addSublayer(self.nameLayer)
        
        /* Layout the layers */
        self.imageLayer.frame = NSRect(x: 0.0, y: 3*ResourceItemView.lineHeight, width: self.bounds.width, height: self.bounds.height - 3*ResourceItemView.lineHeight)
        self.typeLayer.frame = NSRect(x: 0.0, y: 2*ResourceItemView.lineHeight, width: self.bounds.width, height: ResourceItemView.lineHeight)
        self.identifierLayer.frame = NSRect(x: 0.0, y: ResourceItemView.lineHeight, width: self.bounds.width, height: ResourceItemView.lineHeight)
        self.nameLayer.frame = NSRect(x: 0.0, y: 0, width: self.bounds.width, height: ResourceItemView.lineHeight)
    
        /* Set-up the image */
        self.imageLayer.autoresizingMask = [.layerHeightSizable, .layerWidthSizable]
        
        /* Set-up the texts */
        for layer in [self.typeLayer, self.identifierLayer, self.nameLayer] {
            layer.alignmentMode = CATextLayerAlignmentMode.center
            layer.font = NSFont.systemFont(ofSize: 12.0)
            layer.fontSize = 12.0
            layer.autoresizingMask = [.layerMaxYMargin, .layerWidthSizable]
        }

        self.nameLayer.truncationMode = CATextLayerTruncationMode.middle
    }
    
    func displayResource(image: NSImage, type: String, identifier: Int, name: String) {
        
        let imageFrame = self.computeImageFrame(forImageWidth: image.size.width, height: image.size.height)
        self.imageLayer.frame = imageFrame
        
        self.imageLayer.contents = image
        self.typeLayer.string = type
        self.identifierLayer.string = String(identifier)
        self.nameLayer.string = name
    }
    
    private func computeImageFrame(forImageWidth width: CGFloat, height: CGFloat) -> NSRect {
        
        let maxWidth = self.bounds.width
        let maxHeight = self.bounds.height - 3*ResourceItemView.lineHeight - ResourceItemView.iconTextMargin
        
        /* Compute the size of the image to fit it proportionaly */
        let factor: CGFloat
        if width <= maxWidth && height <= maxHeight {
            factor = 1.0
        }
        else {
            factor = min( maxWidth / width, maxHeight / height )
        }
        let imageWidth = width * factor
        let imageHeight = height * factor
        
        /* Layout the image at the center */
        let imageX = maxWidth / 2 - imageWidth / 2
        let imageY = 3*ResourceItemView.lineHeight + ResourceItemView.iconTextMargin
        return NSRect(x: imageX, y: imageY, width: imageWidth, height: imageHeight)
    }
    
    func displaySelected(_ selected: Bool) {
        
        if selected {
            
            /* Do not re-create a layer if there is already one */
            guard self.selectionLayer == nil else {
                return
            }
            
            let layer = buildSelectionLayer()
            self.selectionLayer = layer
            self.layer!.insertSublayer(layer, below: imageLayer)
        }
        else {
            if let layer = self.selectionLayer {
                layer.removeFromSuperlayer()
                self.selectionLayer = nil
            }
        }
        
    }
    
    private func buildSelectionLayer() -> CALayer {
        
        /* Create the layer */
        let layer = CALayer()
        
        /* Position it around the image */
        layer.frame = computeSelectionFrame()
        
        /* Set appearance */
        layer.backgroundColor = ResourceItemView.selectionColor
        layer.cornerRadius = ResourceItemView.selectionMargin
        
        return layer
    }
    
    private func computeSelectionFrame() -> NSRect {
        
        return self.bounds
        
    }
    
}

