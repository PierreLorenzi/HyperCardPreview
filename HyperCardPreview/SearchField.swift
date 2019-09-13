//
//  SearchField.swift
//  HyperCardPreview
//
//  Created by Pierre Lorenzi on 14/09/2019.
//  Copyright © 2019 Pierre Lorenzi. All rights reserved.
//

import AppKit

/* A search field that goes to next/prev result on enter key */
class SearchField: NSSearchField {
    
    override func textDidEndEditing(_ notification: Notification) {
        
        if NSEvent.modifierFlags.contains(NSEvent.ModifierFlags.shift) {
            self.tag = 3
        }
        else {
            self.tag = 2
        }
        NSApp.sendAction(#selector(Document.performFindPanelAction(_:)), to: nil, from: self)
        
        super.textDidEndEditing(notification)
    }
}
