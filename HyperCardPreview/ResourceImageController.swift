//
//  ResourceImageController.swift
//  HyperCardPreview
//
//  Created by Pierre Lorenzi on 28/09/2018.
//  Copyright © 2018 Pierre Lorenzi. All rights reserved.
//

import Cocoa

class ResourceImageController: NSWindowController {
    
    @IBOutlet weak var imageView: NSImageView!
    
    func displayImage(image: NSImage) {
        
        self.imageView.image = image
        
        /* Grow the window if needed */
        if image.size.width > self.imageView.frame.width {
            
            self.window!.setFrame(NSRect(x: self.window!.frame.minX, y: self.window!.frame.minY, width: self.window!.frame.width + image.size.width - self.imageView.frame.size.width, height: self.window!.frame.height), display: true, animate: false)
        }
        if image.size.height > self.imageView.frame.height {
            
            self.window!.setFrame(NSRect(x: self.window!.frame.minX, y: self.window!.frame.minY, width: self.window!.frame.width, height: self.window!.frame.height + image.size.height - self.imageView.frame.size.height), display: true, animate: false)
        }
    }
    
    override func windowTitle(forDocumentDisplayName displayName: String) -> String {
        return "Picture"
    }
    
    @objc func copy(_ sender: AnyObject) {
        
        guard let image = self.imageView.image else {
            return
        }
        
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.writeObjects([image])
    }
    
}
