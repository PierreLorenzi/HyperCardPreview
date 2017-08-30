//
//  CardItemView.swift
//  HyperCardPreview
//
//  Created by Pierre Lorenzi on 30/08/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//

import Cocoa


/// The view displaying the thumbnail of a card
class CardItemView: NSView {
    
    let imageLayer: CALayer
    var selectionLayer: CALayer? = nil
    
    weak var document: Document!
    
    var index = -1
    
    static let selectionMargin: CGFloat = 10.0
    
    static let selectionColor = CGColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 0.8)
    
    required init?(coder: NSCoder) {
        
        /* Create the image layer */
        imageLayer = CALayer()
        
        /* Init with the requested size */
        super.init(coder: coder)
        
        /* Set-up us as layer */
        let layer = CALayer()
        layer.isOpaque = true
        self.layer = layer
        self.wantsLayer = true
        layer.addSublayer(imageLayer)
        
        /* Resize the image */
        imageLayer.frame = self.bounds
        imageLayer.autoresizingMask = [.layerHeightSizable, .layerWidthSizable]
        
        /* Give the layer a shadow */
        imageLayer.shadowOffset = NSSize(width: 1, height: -2)
        imageLayer.shadowRadius = 2
        imageLayer.shadowColor = CGColor(red: CGFloat(0.0), green: CGFloat(0.0), blue: CGFloat(0.0), alpha: CGFloat(1.0))
        imageLayer.shadowOpacity = 0.8
        
    }
    
    func displayImage(_ possibleImage: CGImage?) {
        
        /* Do not animate */
        CATransaction.setDisableActions(true)
        
        /* If there is not image, display nothing */
        guard let image = possibleImage else {
            imageLayer.contents = nil
            return
        }
        
        /* Compute the size of the image to fit it proportionaly */
        let pixelImageWidth = CGFloat(image.width)
        let pixelImageHeight = CGFloat(image.height)
        let factor = min( (self.bounds.width - 2.0*CardItemView.selectionMargin) / pixelImageWidth, (self.bounds.height - 2.0*CardItemView.selectionMargin) / pixelImageHeight )
        let imageWidth = pixelImageWidth * factor
        let imageHeight = pixelImageHeight * factor
        
        /* Layout the image at the center */
        let imageX = self.bounds.width / 2 - imageWidth / 2
        let imageY = self.bounds.height / 2 - imageHeight / 2
        imageLayer.frame = NSRect(x: imageX, y: imageY, width: imageWidth, height: imageHeight)
        
        /* Display the image */
        imageLayer.contents = image
        
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
    
    func buildSelectionLayer() -> CALayer {
        
        /* Create the layer */
        let layer = CALayer()
        
        /* Position it around the image */
        let imageFrame = imageLayer.frame
        layer.frame = NSRect(x: imageFrame.origin.x - CardItemView.selectionMargin, y: imageFrame.origin.y - CardItemView.selectionMargin, width: imageFrame.size.width + 2.0 * CardItemView.selectionMargin, height: imageFrame.size.height + 2.0 * CardItemView.selectionMargin)
        
        /* Set appearance */
        layer.backgroundColor = CardItemView.selectionColor
        layer.cornerRadius = CardItemView.selectionMargin
        
        return layer
    }
    
    var hasRespondedToMagnify = false
    
    override func magnify(with event: NSEvent) {
        
        if event.phase == .began {
            hasRespondedToMagnify = false
            return
        }
        
        /* If the user demagnifies the view, show the card list behind */
        if event.magnification > -0.05 && !hasRespondedToMagnify {
            document.warnCardWasSelected(atIndex: index, withImage: self.imageLayer.contents as! CGImage?)
            hasRespondedToMagnify = true
        }
    }
    
    override func mouseUp(with event: NSEvent) {
        
        /* Detect double-clicks */
        if event.clickCount == 2 {
            document.warnCardWasSelected(atIndex: index, withImage: self.imageLayer.contents as! CGImage?)
            return
        }
        
        super.mouseUp(with: event)
    }
    
}

