//
//  AppDelegate.swift
//  HyperCardPreview
//
//  Created by Pierre Lorenzi on 06/03/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//

import Cocoa
import WebKit

enum VisualEffect: Int {
    case none
    case dissolve
    case wipe
    case scroll
    case barnDoor
    case iris
    case venetianBlinds
    case checkerBoard
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var visualEffectMenu: NSMenu!
    var selectedVisualEffect: VisualEffect = .none
    
    @IBOutlet var helpPanel: NSPanel!
    @IBOutlet weak var helpView: WKWebView!
    
    @IBAction func selectVisualEffect(_ sender: Any?) {
        
        guard let menuItem = sender as? NSMenuItem else {
            return
        }
        
        /* Extract the index of the visual effect */
        let index = menuItem.tag
        
        /* Update the state */
        self.selectedVisualEffect = VisualEffect(rawValue: index)!
        
        /* Handle menu selection */
        for i in 0..<self.visualEffectMenu.numberOfItems {
            
            let item = self.visualEffectMenu.item(at: i)!
            item.state = (item === menuItem) ? NSControl.StateValue.on : NSControl.StateValue.off
        }
        
    }
    
    @IBAction func displayShortcuts(_ sender: Any) {
        
        /* Load the panel if necessary */
        if helpPanel == nil {
            
            /* Load the nib */
            let nib = NSNib(nibNamed: "Help", bundle: nil)
            nib!.instantiate(withOwner: self, topLevelObjects: nil)
            
            /* Load the HTML content into the WebView */
            let helpUrl = Bundle.main.url(forResource: "Shortcuts", withExtension: "html")
            self.helpView.loadFileURL(helpUrl!, allowingReadAccessTo: helpUrl!)
        }
        
        /* Open the panel */
        helpPanel.makeKeyAndOrderFront(self)
        
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

