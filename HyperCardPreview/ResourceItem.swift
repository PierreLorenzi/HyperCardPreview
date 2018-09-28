//
//  ResourceItem.swift
//  HyperCardPreview
//
//  Created by Pierre Lorenzi on 27/09/2018.
//  Copyright © 2018 Pierre Lorenzi. All rights reserved.
//

import Cocoa


class ResourceItem: NSCollectionViewItem {
    
    override var isSelected: Bool {
        get {
            return super.isSelected
        }
        set {
            super.isSelected = newValue
            
            (self.view as! ResourceItemView).displaySelected(isSelected)
        }
    }
    
}

