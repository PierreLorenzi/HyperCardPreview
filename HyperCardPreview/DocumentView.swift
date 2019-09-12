//
//  DocumentView.swift
//  LittleStackReader
//
//  Created by Pierre Lorenzi on 05/03/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//

import Cocoa
import HyperCardCommon

/// The view displaying the HyperCard stack
class DocumentView: NSView, NSMenuDelegate {
    
    private var commandQueue: MTLCommandQueue
    
    required init?(coder: NSCoder) {
        
        let device = MTLCreateSystemDefaultDevice()!
        self.commandQueue = device.makeCommandQueue()!
        
        super.init(coder: coder)
        
        let layer = CAMetalLayer()
        layer.framebufferOnly = false
        layer.device = device
        layer.isOpaque = true
        layer.contentsGravity = CALayerContentsGravity.resizeAspect
        self.layer = layer
        self.wantsLayer = true
    }
    
    func drawBuffer(_ imageBuffer: ImageBuffer) {
        
        if drawMetal(imageBuffer) {
            return
        }
        
        CATransaction.setDisableActions(true)
        layer!.contents = imageBuffer.context.makeImage()
    }
    
    private func drawMetal(_ imageBuffer: ImageBuffer) -> Bool {
        
        let metalLayer = (self.layer! as! CAMetalLayer)
        
        guard let drawable = metalLayer.nextDrawable() else {
            return false
        }
        
        let commandBuffer = commandQueue.makeCommandBuffer()!
        
        let texture = drawable.texture
        guard texture.width == imageBuffer.width && texture.height == imageBuffer.height else {
            return false
        }
        
        texture.replace(region: MTLRegion(origin: MTLOrigin(x: 0, y: 0, z: 0), size: MTLSize(width: imageBuffer.width, height: imageBuffer.height, depth: texture.depth)), mipmapLevel: 0, withBytes: UnsafeRawPointer(imageBuffer.pixels.baseAddress!), bytesPerRow: imageBuffer.countPerRow*4)
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
        
        return true
    }
    
    var transform: AffineTransform {
        
        var transform = AffineTransform()
        let scaleX = CGFloat(document.browser.image.width) / self.bounds.width
        let scaleY = CGFloat(document.browser.image.height) / self.bounds.height
        let scale = max(scaleX, scaleY)
        let cardOriginX = (self.bounds.size.width - CGFloat(document.browser.image.width) / scale) / 2.0
        let cardOriginY = (self.bounds.size.height - CGFloat(document.browser.image.height) / scale) / 2.0
        
        /* Center vertically */
        transform.translate(x: cardOriginX, y: cardOriginY)
        
        /* Scale */
        transform.scale(1.0 / scale)
        
        /* Flip */
        transform.translate(x: 0.0, y: CGFloat(document.browser.stack.size.height))
        transform.scale(x: 1.0, y: -1.0)
        
        return transform
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
        
        /* Enter Key / Return Key */
        if let characters = event.charactersIgnoringModifiers,
            let characterValue = characters.utf16.first {
            let character = Int(characterValue)
            
            /* Check if the character is return or enter */
            if (character == 13 || character == 3){
                
                document.showCards(self)
                return
            }
            
            /* Page Down */
            if character == NSEvent.SpecialKey.pageDown.rawValue {
                
                document.goToNextPage(self)
                return
            }
            
            /* Page Up */
            if character == NSEvent.SpecialKey.pageUp.rawValue {
                
                document.goToPreviousPage(self)
                return
            }
            
            /* Begin */
            if character == NSEvent.SpecialKey.begin.rawValue || character == NSEvent.SpecialKey.home.rawValue {
                
                document.goToFirstPage(self)
                return
            }
            
            /* End */
            if character == NSEvent.SpecialKey.end.rawValue {
                
                document.goToLastPage(self)
                return
            }
        }
        
        /* Arrow keys */
        if event.modifierFlags.rawValue & NSEvent.ModifierFlags.numericPad.rawValue != 0 {
            
            guard let characters = event.charactersIgnoringModifiers else {
                return
            }
            
            /* Reject dead keys */
            guard characters.utf16.count == 1 else {
                return
            }
            
            let character = Int(characters.utf16[characters.utf16.startIndex])
            
            switch character {
            case NSEvent.SpecialKey.rightArrow.rawValue:
                NSApp.sendAction(#selector(Document.goToNextPage), to: nil, from: nil)
            case NSEvent.SpecialKey.leftArrow.rawValue:
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
        
        if event.modifierFlags.contains(NSEvent.ModifierFlags.command) && event.modifierFlags.contains(NSEvent.ModifierFlags.option) {
            
            if event.modifierFlags.contains(NSEvent.ModifierFlags.shift) {
                if !partScriptDisplayed {
                    partScriptDisplayed = true
                    NSApp.sendAction(#selector(Document.displayPartScriptBorders(_:)), to: nil, from: nil)
                }
            }
            else if partScriptDisplayed {
                partScriptDisplayed = false
                buttonScriptDisplayed = true
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
    
    weak var document: Document!
    var mouseDownResponder: MouseResponder? = nil
    
    override func mouseDown(with event: NSEvent) {
        
        /* If the user hold the control key, act like for a right click */
        guard !event.modifierFlags.contains(NSEvent.ModifierFlags.control) else {
            
            self.handleRightClick(with: event)
            return
        }
        
        /* Find the stack part responding to the event */
        let browserPosition = extractPosition(from: event)
        let responder = document.browser.findViewRespondingToMouseEvent(at: browserPosition)
        
        /* Special case for a pop-up button (works with a little hack)  */
        if let button = responder as? ButtonView, let items = button.popupItems, items.count > 0 {
            self.displayPopupMenu(withItemNames: items, button: button, event: event)
            return
        }
        
        /* Save it */
        self.mouseDownResponder = responder
        
        /* Call it with the event */
        responder.respondToMouseEvent(.mouseDown, at: browserPosition)
        
    }
    
    private var popupButton: ButtonView? = nil
    
    private func displayPopupMenu(withItemNames itemNames: [HString], button: ButtonView, event: NSEvent) {
        
        /* Create the menu */
        let menu = NSMenu(title: "Pop Up Menu")
        
        var index = 0
        
        for itemName in itemNames {
            
            /* Create a menu item */
            let menuItem = NSMenuItem(title: itemName.description, action: #selector(DocumentView.selectPopupItem(_:)), keyEquivalent: "")
            menuItem.target = self
            menuItem.tag = index
            
            /* Add it to the menu */
            menu.addItem(menuItem)
            
            index += 1
            
        }
        
        /* Select the right item */
        if button.selectedIndex >= 0 && button.selectedIndex < itemNames.count {
            menu.item(at: button.selectedIndex)?.state = NSControl.StateValue.on
        }
        
        /* Display the menu */
        self.popupButton = button
        NSMenu.popUpContextMenu(menu, with: event, for: self)
        
    }
    
    @objc private func selectPopupItem(_ sender: AnyObject) {
        
        /* Select the right item in the button */
        let menuItem = sender as! NSMenuItem
        let index = menuItem.tag
        self.popupButton?.selectedIndex = index
        
        /* Forget the button */
        self.popupButton = nil
        
    }
    
    override func mouseUp(with event: NSEvent) {
        
        /* Send the event to the view that responded to the mouse down event */
        let browserPosition = extractPosition(from: event)
        self.mouseDownResponder?.respondToMouseEvent(.mouseUp, at: browserPosition)
        
        /* Forget that view */
        self.mouseDownResponder = nil
        
        self.draggedResponder = nil
    }
    
    private func extractPosition(from event: NSEvent) -> Point {
        
        let locationInWindow = event.locationInWindow
        let locationInMe = self.convert(locationInWindow, from: nil)
        
        let transform = self.transform.inverted()!
        let newPoint = transform.transform(locationInMe)
        
        return Point(x: Int(newPoint.x), y: Int(newPoint.y))
    }
    
    private var partsInMenu: [PartInMenu]? = nil
    
    private struct PartInMenu {
        let part: LayerPart
        let layerType: LayerType
        let number: Int
    }
    
    override func rightMouseDown(with event: NSEvent) {
        
        self.handleRightClick(with: event)
    }
    
    private func handleRightClick(with event: NSEvent) {
        
        /* List the parts where the mouse clicks */
        let position = extractPosition(from: event)
        let partsAtClickPosition = listParts(atPoint: position)
        
        /* Save the parts to handle the menu actions */
        self.partsInMenu = partsAtClickPosition
        
        /* Display a menu with the list of the parts */
        let menu = buildContextualMenu(forParts: partsAtClickPosition)
        menu.delegate = self
        NSMenu.popUpContextMenu(menu, with: event, for: self)
    }
    
    private func listParts(atPoint point: Point) -> [PartInMenu] {
        
        /* List the parts from the foremost to the outmost */
        var parts: [PartInMenu] = []
        
        /* Look in the card parts */
        if !document.browser.displayOnlyBackground {
            let cardParts = listParts(atPoint: point, inLayer: document.browser.currentCard, layerType: .card)
            parts.append(contentsOf: cardParts)
        }
        
        /* Look in the background parts */
        let backgroundParts = listParts(atPoint: point, inLayer: document.browser.currentBackground, layerType: .background)
        parts.append(contentsOf: backgroundParts)
        
        return parts
    }
    
    private func listParts(atPoint point: Point, inLayer layer: Layer, layerType: LayerType) -> [PartInMenu] {
        
        var parts: [PartInMenu] = []
        
        /* Keep trace of the part numbers */
        var fieldNumber = 0
        var buttonNumber = 0
        
        for part in layer.parts {
            
            var number = 0
            
            /* Update the part numbers */
            switch part {
            case .button(_):
                buttonNumber += 1
                number = buttonNumber
            case .field(_):
                fieldNumber += 1
                number = fieldNumber
            }
            
            /* Check if the part lies at the position */
            if part.part.rectangle.containsPosition(point) {
                let partInMenu = PartInMenu(part: part, layerType: layerType, number: number)
                parts.append(partInMenu)
            }
        }
        
        return parts.reversed()
    }
    
    private func buildContextualMenu(forParts parts: [PartInMenu]) -> NSMenu {
        
        let menu = NSMenu(title: "Parts")
        
        /* Menu item explaining the menu */
        let explanationItem = NSMenuItem(title: "Parts at that point:", action: nil, keyEquivalent: "")
        explanationItem.isEnabled = false
        menu.addItem(explanationItem)
        
        var index = 0
        
        /* Menu item for the parts */
        for part in parts {
            
            /* Create the menu item */
            let title = findTitle(forPart: part)
            let menuItem = NSMenuItem(title: title, action: #selector(DocumentView.displayPartInfo), keyEquivalent: "")
            menuItem.target = self
            menuItem.tag = index
            
            /* Add it to the menu */
            menu.addItem(menuItem)
            
            index += 1
        }
        
        return menu
    }
    
    private func findTitle(forPart part: PartInMenu) -> String {
        
        var type = ""
        switch (part.layerType, part.part) {
        case (.card, .field(_)):
            type = "card field"
        case (.card, .button(_)):
            type = "button"
        case (.background, .field(_)):
            type = "field"
        case (.background, .button(_)):
            type = "background button"
        }
        
        let qualifier = (part.part.part.name != "") ? "\"\(part.part.part.name)\"" : "\(part.number)"
        
        return "\(type) \(qualifier)"
        
    }
    
    func menu(_ menu: NSMenu, willHighlight possibleMenuItem: NSMenuItem?) {
        
        /* Remove the script borders currently displayed  */
        document.removeScriptBorders()
        
        /* Check if a menu item is selected */
        guard let menuItem = possibleMenuItem else {
            return
        }
        
        /* Retrieve the part */
        let tag = menuItem.tag
        let part = self.partsInMenu![tag]
        
        /* Show the script border of the part */
        document.createScriptBorder(forPart: part.part, inLayerType: part.layerType)
    }
    
    func menuDidClose(_ menu: NSMenu) {
        document.removeScriptBorders()
    }
    
    @objc private func displayPartInfo(_ sender: AnyObject) {
        
        /* Retrieve the part */
        let menuItem = sender as! NSMenuItem
        let tag = menuItem.tag
        let part = self.partsInMenu![tag]
        let content = document.retrieveContent(part: part.part, inLayerType: part.layerType)
        
        switch part.part {
        case .field(let field):
            document.displayInfo().displayField(field, withContent: content)
        case .button(let button):
            document.displayInfo().displayButton(button, withContent: content)
        }
        
    }
    
    var hasRespondedToScroll = false
    var scrollIsVertical = false
    
    override func scrollWheel(with event: NSEvent) {
        
        /* If the scroll begins, check if it is horizontal or vertical */
        if event.phase == NSEvent.Phase.began {
            hasRespondedToScroll = false
            scrollIsVertical = abs(event.scrollingDeltaX) / 2.0 < abs(event.scrollingDeltaY)
            return
        }
        
        /* Vertical scroll are sent to scrolling fields */
        if scrollIsVertical {
            let browserPosition = extractPosition(from: event)
            let responder = document.browser.findViewRespondingToMouseEvent(at: browserPosition)
            responder.respondToMouseEvent(.verticalScroll(delta: Double(event.deltaY)), at: browserPosition)
            hasRespondedToScroll = true
            return
        }
        
        /* Horizontal scrolls are for changing card */
        if !scrollIsVertical && !hasRespondedToScroll && abs(event.scrollingDeltaX) > 10.0 {
            hasRespondedToScroll = true
            if event.scrollingDeltaX > 0 {
                document.goToPreviousPage(self)
            }
            else {
                document.goToNextPage(self)
            }
        }
        
    }
    
    var hasRespondedToMagnify = false
    
    override func magnify(with event: NSEvent) {
        
        if event.phase == NSEvent.Phase.began {
            hasRespondedToMagnify = false
            return
        }
        
        /* If the user demagnifies the view, show the card list behind */
        if event.magnification < -0.05 && !hasRespondedToMagnify {
            document.showCards(self)
            hasRespondedToMagnify = true
        }
    }
    
    override func swipe(with event: NSEvent) {
            if event.deltaX < 0 {
                document.goToPreviousPage(self)
            }
            else {
                document.goToNextPage(self)
            }        
    }
    
    private var draggedResponder: MouseResponder? = nil
    
    override func mouseDragged(with event: NSEvent) {
        
        let browserPosition = extractPosition(from: event)
        
        if let formerResponder = self.draggedResponder {
            formerResponder.respondToMouseEvent(.mouseDragged, at: browserPosition)
            return
        }
        
        let responder = self.document.browser.findViewRespondingToMouseEvent(at: browserPosition)
        
        self.draggedResponder = responder
        responder.respondToMouseEvent(.mouseDragged, at: browserPosition)
    }
    
} 
