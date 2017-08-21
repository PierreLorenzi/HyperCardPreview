//
//  LayerView.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 02/03/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


/// A view of a card or a background
public class LayerView: View {
    
    private let layer: Layer
    
    public init(layer: Layer) {
        self.layer = layer
    }
    
    public override func draw(in drawing: Drawing) {
        
        /* Image */
        if let image = layer.image, layer.showPict {
            drawing.drawMaskedImage(image, position: Point(x: 0, y: 0))
        }
        
    }
    
}
