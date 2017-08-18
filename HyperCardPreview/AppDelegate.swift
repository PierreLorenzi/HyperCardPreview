//
//  AppDelegate.swift
//  HyperCardPreview
//
//  Created by Pierre Lorenzi on 06/03/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//

import Cocoa

enum VisualEffect: Int {
    case none
    case dissolve
    case wipe
    case scroll
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var visualEffectMenu: NSMenu!
    var selectedVisualEffect: VisualEffect = .none
    
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
            item.state = (item === menuItem) ? 1 : 0
        }
        
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

