//
//  CardItem.swift
//  HyperCardPreview
//
//  Created by Pierre Lorenzi on 30/08/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//

import Cocoa

class CardItem: NSCollectionViewItem {
    
    override var isSelected: Bool {
        get {
            return super.isSelected
        }
        set {
            super.isSelected = newValue
            
            (self.view as! CardItemView).displaySelected(newValue)
        }
    }
    
}
