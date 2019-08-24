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
    var mainAction: (() -> Void)? = nil
    var cancelAction: (() -> Void)? = nil
    
    override func keyDown(with event: NSEvent) {
        
        /* Get the involved characters */
        if let characters = event.charactersIgnoringModifiers {
            let character = characters.utf16[characters.utf16.indices.first!]
            
            /* Check if the character is return or enter or space */
            if (character == 13 || character == 3){
                
                /* Apply the action */
                if let action = mainAction {
                    action()
                }
                return
            }
            
            /* Check if the character escape */
            if (character == 27){
                
                /* Apply the action */
                if let action = cancelAction {
                    action()
                }
                return
            }
        }
        
        super.keyDown(with: event)
    }
    
}
