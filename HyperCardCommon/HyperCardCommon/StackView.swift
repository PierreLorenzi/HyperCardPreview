//
//  HyperCardView.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 02/03/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


/// A view of a card in a stack, with the background and card layers.
public class StackView: View {
    
    /// The background layer
    public var backgroundView: LayerView   = LayerView()
    
    /// The card layer
    public var cardView: LayerView         = LayerView()
    
    public override func draw(in drawing: Drawing) {
        backgroundView.draw(in: drawing)
        cardView.draw(in: drawing)
    }
    
}
