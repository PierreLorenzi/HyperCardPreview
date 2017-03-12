//
//  LayerView.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 02/03/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


public class LayerView: View {
    
    public var partViews: [View]     = []
    public var image: MaskedImage?   = nil
    
    public var showImage: Bool       = true
    
    public override func draw(in drawing: Drawing) {
        
        /* Image */
        if let image = self.image, showImage {
            drawing.drawMaskedImage(image, position: Point(x: 0, y: 0))
        }
        
        /* Parts */
        for partView in partViews {
            partView.draw(in: drawing)
        }
        
    }
    
}
