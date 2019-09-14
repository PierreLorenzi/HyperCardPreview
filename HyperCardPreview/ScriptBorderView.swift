//
//  ScriptBorderView.swift
//  HyperCardPreview
//
//  Created by Pierre Lorenzi on 10/03/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//

import AppKit
import HyperCardCommon


/// The view displaying a ghost of a button or a field
class ScriptBorderView: NSView {
    
    let part: LayerPart
    let content: HString
    unowned let document: Document
    
    init(frame: NSRect, part: LayerPart, content: HString, document: Document) {
        self.part = part
        self.content = content
        self.document = document
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func mouseDown(with event: NSEvent) {
        self.layer!.backgroundColor =  CGColor(red: 0, green: 0, blue: 1, alpha: 0.7)
    }
    
    override func mouseUp(with event: NSEvent) {
        switch part {
        case .field(let field):
            document.displayInfo().displayField(field, withContent: content, stack: self.document.browser.stack)
        case .button(let button):
            document.displayInfo().displayButton(button, withContent: content, stack: self.document.browser.stack)
        }
    }
    
}
