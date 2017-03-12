//
//  HyperCardView.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 02/03/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


public class StackView: View {
    
    public var backgroundView: LayerView   = LayerView()
    public var cardView: LayerView         = LayerView()
    
    public override func draw(in drawing: Drawing) {
        backgroundView.draw(in: drawing)
        cardView.draw(in: drawing)
    }
    
}
