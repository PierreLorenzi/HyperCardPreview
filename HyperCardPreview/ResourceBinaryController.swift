//
//  ResourceBinaryController.swift
//  HyperCardPreview
//
//  Created by Pierre Lorenzi on 28/09/2018.
//  Copyright © 2018 Pierre Lorenzi. All rights reserved.
//

import Cocoa
import HyperCardCommon

class ResourceBinaryController: NSWindowController {
    
    @IBOutlet weak var textView: NSTextView!
    
    private static let hexAlphabet = "0123456789ABCDEF".unicodeScalars.map { $0 }
    
    private func hexEncodedString(_ data: DataRange) -> String {
        return String(data.sharedData[data.offset ..< data.offset + data.length].reduce(into: "".unicodeScalars, { (result, value) in
            result.append(ResourceBinaryController.hexAlphabet[Int(value/16)])
            result.append(ResourceBinaryController.hexAlphabet[Int(value%16)])
        }))
    }
    
    func displayData(_ data: DataRange) {
        
        self.textView.string = self.hexEncodedString(data)
    }
    
    override func windowTitle(forDocumentDisplayName displayName: String) -> String {
        return "Binary Data"
    }
    
}
