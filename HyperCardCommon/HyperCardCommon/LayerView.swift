//
//  LayerView.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 02/03/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


/// A view of a card or a background
public class LayerView: View, ClipableView {
    
    private let layer: Layer
    
    public init(layer: Layer) {
        self.layer = layer
    }
    
    public override var rectangle: Rectangle? {
        
        /* Check if the layer is visible */
        guard layer.showPict else {
            return nil
        }
        
        /* Get the image */
        guard let image = layer.image else {
            return nil
        }
        
        /* Get the rectangles of both image layers */
        let imageRectangle = computeLayerRectangle(image.image)
        let maskRectangle = computeLayerRectangle(image.mask)
        
        /* Merge both rectangles */
        return computeEnclosingRectangle(imageRectangle, maskRectangle)
        
    }
    
    private func computeLayerRectangle(_ layer: MaskedImage.Layer) -> Rectangle? {
        
        switch layer {
            
        case .clear:
            return nil
            
        case .rectangular(rectangle: let rectangle):
            return rectangle
            
        case .bitmap(image: _, imageRectangle: let rectangle, realRectangleInImage: _):
            return rectangle
        }
        
    }
    
    public override func draw(in drawing: Drawing) {
        
        /* Image */
        if let image = layer.image, layer.showPict {
            drawing.drawMaskedImage(image, position: Point(x: 0, y: 0))
        }
        
    }
    
    public func draw(in drawing: Drawing, rectangle: Rectangle) {
        
        /* Image */
        if let image = layer.image, layer.showPict {
            drawing.drawMaskedImage(image, position: Point(x: 0, y: 0), clipRectangle: rectangle)
        }
    }
    
}
