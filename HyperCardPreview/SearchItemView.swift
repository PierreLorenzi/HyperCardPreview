//
//  SearchItemView.swift
//  HyperCardPreview
//
//  Created by Pierre Lorenzi on 12/09/2019.
//  Copyright © 2019 Pierre Lorenzi. All rights reserved.
//

import AppKit
import HyperCardCommon


class SearchItemView: NSView {
    
    var isSetup = false
    
    @IBOutlet weak var subview: NSView!
    @IBOutlet weak var cardLabel: NSTextField!
    @IBOutlet weak var occurrenceCountLabel: NSTextField!
    @IBOutlet weak var extractLabel: NSTextField!
    
    func setup() {
        self.subview.frame = self.bounds
        self.addSubview(self.subview)
        self.isSetup = true
    }
    
    func showResult(cardName: String, occurrenceCount: Int, extract: String) {
        self.cardLabel.stringValue = cardName
        self.occurrenceCountLabel.stringValue = "\(occurrenceCount) result\(occurrenceCount == 1 ? "" : "s")"
        self.extractLabel.stringValue = extract
    }
    
}
