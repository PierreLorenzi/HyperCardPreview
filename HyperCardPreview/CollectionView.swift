//
//  CollectionView.swift
//  HyperCardPreview
//
//  Created by Pierre Lorenzi on 02/09/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//

import Cocoa


/// Sub-class of NSCollectionView made to intercept enter key and return key events
class CollectionView: NSCollectionView {
    
    weak var document: Document!
    
    override func keyDown(with event: NSEvent) {
        
        /* Get the involved characters */
        if let characters = event.charactersIgnoringModifiers {
            let character = characters.utf16[characters.utf16.indices.first!]
            
            /* Check if the character is return or enter */
            if (character == 13 || character == 3){
                
                /* Display the selected card */
                let item = self.item(at: self.selectionIndexPaths.first!)
                let itemView = item?.view
                let cardItemView = itemView as! CardItemView
                self.document.warnCardWasSelected(atIndex: cardItemView.index, withImage: cardItemView.imageLayer.contents as! CGImage?)
                return
            }
        }
        
        super.keyDown(with: event)
    }
    
}
