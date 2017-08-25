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
    
    public override var rectangle: Rectangle {
        return Rectangle(top: 0, left: 0, bottom: 10000, right: 10000)
    }
    
    public override func draw(in drawing: Drawing) {
        
        /* Image */
        if let image = layer.image, layer.showPict {
            drawing.drawMaskedImage(image, position: Point(x: 0, y: 0))
        }
        
    }
    
    public override func draw(in drawing: Drawing, rectangle: Rectangle) {
        
        /* Image */
        if let image = layer.image, layer.showPict {
            drawing.drawMaskedImage(image, position: Point(x: 0, y: 0), clipRectangle: rectangle)
        }
    }
    
    public override var visible: Bool {
        
        if !layer.showPict {
            return false
        }
        
        guard let image = layer.image else {
            return false
        }
        
        if case .clear = image.image, case .clear = image.mask {
            return false
        }
        
        return true
    }
    
    public override var canDrawSubrectangle: Bool {
        return true
    }
    
}
