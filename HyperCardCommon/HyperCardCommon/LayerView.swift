//
//  LayerView.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 02/03/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


/// A view of a card or a background
public class LayerView: View {
    
    /// The views of the parts
    public var partViews: [View]     = []
    
    /// The image of the layer, drawn behind the parts
    public var image: MaskedImage?   = nil
    
    /// Whether or not the image is drawn
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
