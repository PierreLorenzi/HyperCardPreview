//
//  DocumentView.swift
//  LittleStackReader
//
//  Created by Pierre Lorenzi on 05/03/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//

import Cocoa

class DocumentView: NSView {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        let layer = CALayer()
        layer.isOpaque = true
        self.layer = layer
        self.wantsLayer = true
    }

    override var wantsUpdateLayer: Bool {
        return true
    }
    
    override var isOpaque: Bool {
        return true
    }
    
    override func layout() {
        self.layer!.frame = self.bounds
    }
    
    override var acceptsFirstResponder: Bool {
        return true
    }
    
    override func keyDown(with event: NSEvent) {
        
        /* Arrow keys */
        if event.modifierFlags.rawValue & NSEventModifierFlags.numericPad.rawValue != 0 {
            
            guard let characters = event.charactersIgnoringModifiers else {
                return
            }
            
            /* Reject dead keys */
            guard characters.utf16.count == 1 else {
                return
            }
            
            let character = Int(characters.utf16[String.UTF16View.Index(0)])
            
            switch character {
            case NSRightArrowFunctionKey:
                NSApp.sendAction(#selector(Document.goToNextPage), to: nil, from: nil)
            case NSLeftArrowFunctionKey:
                NSApp.sendAction(#selector(Document.goToPreviousPage), to: nil, from: nil)
            default:
                break;
            }
            
            return
        }
        
        super.keyDown(with: event)
    }
    
    var buttonScriptDisplayed = false
    var partScriptDisplayed = false
    
    override func flagsChanged(with event: NSEvent) {
        
        if event.modifierFlags.contains(NSEventModifierFlags.command) && event.modifierFlags.contains(NSEventModifierFlags.option) {
            
            if event.modifierFlags.contains(NSEventModifierFlags.shift) {
                if !partScriptDisplayed {
                    partScriptDisplayed = true
                    NSApp.sendAction(#selector(Document.displayPartScriptBorders(_:)), to: nil, from: nil)
                }
            }
            else if partScriptDisplayed {
                partScriptDisplayed = false
                NSApp.sendAction(#selector(Document.displayButtonScriptBorders(_:)), to: nil, from: nil)
            }
            else if !buttonScriptDisplayed {
                buttonScriptDisplayed = true
                NSApp.sendAction(#selector(Document.displayButtonScriptBorders(_:)), to: nil, from: nil)
            }
            
        }
        else if partScriptDisplayed || buttonScriptDisplayed {
            partScriptDisplayed = false
            buttonScriptDisplayed = false
            NSApp.sendAction(#selector(Document.hideScriptBorders(_:)), to: nil, from: nil)
        }
        
    }
    
}
