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
        let factor = min( self.bounds.width / pixelImageWidth, self.bounds.height / pixelImageHeight )
        let imageWidth = pixelImageWidth * factor
        let imageHeight = pixelImageHeight * factor
        
        /* Layout the image at the center */
        let imageX = self.bounds.width / 2 - imageWidth / 2
        let imageY = self.bounds.height / 2 - imageHeight / 2
        imageLayer.frame = NSRect(x: imageX, y: imageY, width: imageWidth, height: imageHeight)
        
        /* Display the image */
        imageLayer.contents = image
        
    }
    
}

