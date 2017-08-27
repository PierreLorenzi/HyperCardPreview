//
//  Document.swift
//  HyperCardPreview
//
//  Created by Pierre Lorenzi on 06/03/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//

import Cocoa
import HyperCardCommon
import QuickLook




class Document: NSDocument {
    
    var file: HyperCardFile!
    var browser: Browser!
    
    var panels: [InfoPanelController] = []
    
    @IBOutlet weak var view: DocumentView!
    
    @IBOutlet weak var collectionView: NSCollectionView!
    @IBOutlet weak var collectionViewSuperview: NSView!
    
    private var collectionViewManager: CollectionViewManager? = nil
    
    override var windowNibName: String? {
        return "Document"
    }
    
    override func read(from url: URL, ofType typeName: String) throws {
        
        try self.readStack(atPath: url.path)
    }
    
    private func readStack(atPath path: String, password: HString? = nil) throws {
        
        do {
            try file = HyperCardFile(path: path, password: password)
        }
        catch HyperCardFile.StackError.notStack {
            
            /* Tell the user we can't open the file */
            let alert = NSAlert(error: HyperCardFile.StackError.notStack)
            alert.messageText = "The file is not a stack"
            alert.informativeText = "The file can't be opened because it is not recognized as a stack"
            alert.runModal()
            throw HyperCardFile.StackError.notStack
            
        }
        catch HyperCardFile.StackError.corrupted {
            
            /* Tell the user we can't open the file */
            let alert = NSAlert(error: HyperCardFile.StackError.notStack)
            alert.messageText = "The stack is corrupted"
            alert.informativeText = "The stack can't be opened because the data is corrupted"
            alert.runModal()
            throw HyperCardFile.StackError.notStack
            
        }
        catch HyperCardFile.StackError.missingPassword {
            
            /* Ask the user for a password */
            let alert = NSAlert()
            alert.messageText = "What's the password?"
            alert.informativeText = "The stack is private access, which means the data is encrypted. A password is needed to read it."
            alert.addButton(withTitle: "OK")
            alert.addButton(withTitle: "Cancel")
            let textField = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 22))
            alert.accessoryView = textField
            let answer = alert.runModal()
            
            /* If cancel, stop */
            guard answer == NSAlertFirstButtonReturn else {
                throw HyperCardFile.StackError.wrongPassword
            }
            
            /* Get the password */
            let passwordString = textField.stringValue
            guard passwordString != "" else {
                throw HyperCardFile.StackError.wrongPassword
            }
            
            /* Convert it to Mac OS Roman encoding */
            guard let password = HString(converting: passwordString) else {
                
                /* Tell the user we can't convert */
                let alert = NSAlert()
                alert.messageText = "Wrong Password"
                alert.runModal()
                throw HyperCardFile.StackError.wrongPassword
            }
            
            /* Try again to open the file, this time with the password */
            try self.readStack(atPath: path, password: password)
            
        }
        catch HyperCardFile.StackError.wrongPassword {
            let alert = NSAlert()
            alert.messageText = "Wrong Password"
            alert.runModal()
            throw HyperCardFile.StackError.wrongPassword
        }
        
    }
    
    private var willRefreshBrowser = false
    
    override func windowControllerDidLoadNib(_ windowController: NSWindowController) {
        super.windowControllerDidLoadNib(windowController)
        
        let window = self.windowControllers[0].window!
        let currentFrame = window.frame
        let newFrame = window.frameRect(forContentRect: NSMakeRect(currentFrame.origin.x, currentFrame.origin.y, CGFloat(file.stack.size.width), CGFloat(file.stack.size.height)))
        window.setFrame(newFrame, display: false)
        view.frame = NSMakeRect(0, 0, CGFloat(file.stack.size.width), CGFloat(file.stack.size.height))
        
        browser = Browser(stack: file.stack)
        
        browser.needsDisplayProperty.startNotifications(for: self, by: {
            [weak self] in
            
            guard let s = self else {
                return
            }
            
            if s.browser.needsDisplay && !s.willRefreshBrowser {
                s.willRefreshBrowser = true
                DispatchQueue.main.async {
                    [weak self] in
                    
                    guard let s = self else {
                        return
                    }
                    
                    s.refresh()
                    s.willRefreshBrowser = false
                }
            }
            
        })
        
        view.document = self
        
        browser.refresh()
        refresh()
    }
    
    func showCards(_ sender: AnyObject) {
        
        guard self.collectionViewSuperview.isHidden else {
            self.collectionViewSuperview.isHidden = true
            return
        }
        
        if self.collectionViewManager == nil {
            self.collectionViewManager = CollectionViewManager(collectionView: self.collectionView, stack: file.stack, didSelectCard: {
                [unowned self] (index: Int) in
                
                self.browser.cardIndex = index
                self.collectionViewSuperview.isHidden = true
            })
        }
        
        self.collectionView.selectItems(at: Set<IndexPath>([IndexPath(item: self.browser.cardIndex, section: 0)]), scrollPosition: NSCollectionViewScrollPosition.centeredVertically)
        self.collectionViewSuperview.isHidden = false
    }
    
    /// Redraws the HyperCard view
    func refresh() {
        
        /* Update the image */
        browser.refresh()
        
        /* Create a copy of the image for the screen */
        let screenImage = createScreenImage(from: browser.cgimage)
        
        /* Display the image in the layer */
        CATransaction.setDisableActions(true)
        view.layer!.contents = screenImage
    }
    
    private func createScreenImage(from image: CGImage) -> CGImage {
        
        /* Create a new bitmap with a context to draw on it. Make it pixel-accurate so we can
         display a very aliased image */
        let scale = Int(NSScreen.main()!.backingScaleFactor)
        let width = image.width * scale
        let height = image.height  * scale
        let data = RgbConverter.createRgbData(width: width, height: height)
        let context = RgbConverter.createContext(forRgbData: data, width: width, height: height)
        
        /* Make the context aliased */
        context.setShouldAntialias(false)
        context.interpolationQuality = .none
        
        /* Fill the image */
        context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        return context.makeImage()!
    }
    
    func applyVisualEffect(from image: Image, advance: Bool) {
        
        /* Stop any current effect */
        if let visualEffectThread = self.visualEffectThread {
            visualEffectThread.cancel()
            self.visualEffectThread = nil
        }
        
        /* Get the selected visual effect */
        let appDelegate = NSApp.delegate as! AppDelegate
        let visualEffect = appDelegate.selectedVisualEffect
        
        /* Apply it */
        switch visualEffect {
            
        case .dissolve:
            applyDissolveVisualEffect(from: image)
            
        case .wipe:
            applyContinuousVisualEffect(VisualEffects.Wipe(to: advance ? .left : .right), from: image)
            
        case .scroll:
            applyContinuousVisualEffect(VisualEffects.Scroll(to: advance ? .left : .right), from: image)
            
        case .barnDoor:
            applyContinuousVisualEffect(VisualEffects.BarnDoor(advance ? .open : .close), from: image)
            
        case .iris:
            applyContinuousVisualEffect(VisualEffects.Iris(advance ? .open : .close), from: image)
            
        case .venetianBlinds:
            applyContinuousVisualEffect(VisualEffects.VenetianBlinds(), from: image)
            
        case .checkerBoard:
            applyContinuousVisualEffect(VisualEffects.CheckerBoard(), from: image)
            
        default:
            refresh()
        }
        
    }
    
    private var visualEffectThread: Thread? = nil
    
    func applyDissolveVisualEffect(from image: Image) {
        
        let thread = Thread(block: {
            
            let drawing = Drawing(image: image)
            let startDate = Date()
            let stepDuration: TimeInterval = VisualEffects.duration / Double(VisualEffects.dissolveStepCount)
            
            /* Apply all the steps of the dissolve, except the last because we draw the final image
             with refresh */
            for i in 0..<VisualEffects.dissolveStepCount - 1 {
                
                /* Wait if we're too fast */
                Thread.sleep(until: startDate.addingTimeInterval(stepDuration * Double(i)))
                
                /* Check cancel */
                if Thread.current.isCancelled {
                    break
                }
                
                /* Apply the effect */
                VisualEffects.dissolve(self.browser.image, on: drawing, at: i)
                
                /* Display the intermediary image */
                DispatchQueue.main.sync {
                    self.displayImage(drawing.image)
                }
            }
            
            /* Display the final state */
            DispatchQueue.main.async {
                self.refresh()
            }
            
        })
        
        thread.start()
        self.visualEffectThread = thread
        
    }
    
    private func displayImage(_ image: Image) {
        
        /* Convert the image to screen */
        let rgbImage = RgbConverter.convertImage(image)
        let screenImage = self.createScreenImage(from: rgbImage)
        
        /* Display the image */
        CATransaction.setDisableActions(true)
        view.layer!.contents = screenImage
    }
    
    func applyContinuousVisualEffect(_ effect: VisualEffects.ContinuousVisualEffect, from image: Image) {
        
        let thread = Thread(block: {
            
            let drawing = Drawing(image: image)
            let startDate = Date()
            
            var interval: TimeInterval = 0
            
            /* Animate with the greatest rate possible */
            while interval < VisualEffects.duration {
                
                /* Apply the effect */
                let step = interval / VisualEffects.duration
                effect.draw(self.browser.image, on: drawing, step: step)
                
                /* Check cancel */
                if Thread.current.isCancelled {
                    break
                }
                
                /* Display the intermediary image */
                DispatchQueue.main.sync {
                    self.displayImage(drawing.image)
                }
                
                /* Check the time */
                interval = -startDate.timeIntervalSinceNow
            }
            
            /* Display the final state */
            DispatchQueue.main.async {
                self.refresh()
            }
            
        })
        
        thread.start()
        self.visualEffectThread = thread
        
    }
    
    /// Move to a card with a visual effect
    func goToPage(at index: Int, advance: Bool = true) {
        let oldImage = browser.image
        
        /* Stop refresh */
        self.willRefreshBrowser = true
        
        browser.cardIndex = index
        browser.refresh()
        self.applyVisualEffect(from: oldImage, advance: advance)
        
        /* Start refresh */
        self.willRefreshBrowser = false
    }
    
    func goToFirstPage(_ sender: AnyObject) {
        self.goToPage(at: 0, advance: false)
    }
    
    func goToLastPage(_ sender: AnyObject) {
        self.goToPage(at: browser.stack.cards.count-1, advance: false)
    }
    
    func goToNextPage(_ sender: AnyObject) {
        var cardIndex = browser.cardIndex
        cardIndex += 1
        if cardIndex == browser.stack.cards.count {
            cardIndex = 0
        }
        self.goToPage(at: cardIndex)
    }
    
    func goToPreviousPage(_ sender: AnyObject) {
        var cardIndex = browser.cardIndex
        cardIndex -= 1
        if cardIndex == -1 {
            cardIndex = browser.stack.cards.count - 1
        }
        self.goToPage(at: cardIndex, advance: false)
    }
    
    func displayOnlyBackground(_ sender: AnyObject) {
        browser.displayOnlyBackground = !browser.displayOnlyBackground
        
        if let menuItem = sender as? NSMenuItem {
            menuItem.state = browser.displayOnlyBackground ? NSOnState : NSOffState
        }
        
        refresh()
    }
    
    func displayButtonScriptBorders(_ sender: AnyObject) {
        createScriptBorders(includingFields: false)
    }
    
    func displayPartScriptBorders(_ sender: AnyObject) {
        createScriptBorders(includingFields: true)
    }
    
    func hideScriptBorders(_ sender: AnyObject) {
        removeScriptBorders()
    }
    
    func createScriptBorders(includingFields: Bool) {
        
        removeScriptBorders()
        createScriptBorders(in: browser.currentBackground, includingFields: includingFields, layerType: .background)
        if !browser.displayOnlyBackground {
            createScriptBorders(in: browser.currentCard, includingFields: includingFields, layerType: .card)
        }
        
    }
    
    func createScriptBorders(in layer: Layer, includingFields: Bool, layerType: LayerType) {
        
        for part in layer.parts {
            
            /* Exclude fields if necessary */
            if case LayerPart.field(_) = part, !includingFields {
                continue
            }
            
            createScriptBorder(forPart: part, inLayerType: layerType)
            
        }
        
    }
    
    func createScriptBorder(forPart part: LayerPart, inLayerType layerType: LayerType) {
        
        /* Convert the rectangle into current coordinates */
        let rectangle = part.part.rectangle
        let frame = NSMakeRect(CGFloat(rectangle.x), CGFloat(file.stack.size.height - rectangle.bottom), CGFloat(rectangle.width), CGFloat(rectangle.height))
        
        /* Create a view */
        let view = ScriptBorderView(frame: frame, part: part, content: retrieveContent(part: part, inLayerType: layerType), document: self)
        view.wantsLayer = true
        view.layer!.borderColor = NSColor.blue.cgColor
        view.layer!.borderWidth = 1
        view.layer!.backgroundColor = CGColor(red: 0, green: 0, blue: 1, alpha: 0.03)
        
        self.windowControllers[0].window!.contentView!.addSubview(view)
        
    }
    
    func retrieveContent(part: LayerPart, inLayerType layerType: LayerType) -> HString {
        
        if case LayerPart.field(let field) = part, !field.sharedText, layerType == .background {
            let contents = browser.currentCard.backgroundPartContents
            if let content = contents.first(where: {$0.partIdentifier == part.part.identifier}) {
                return content.partContent.string
            }
            return ""
        }
        
        switch part {
        case .field(let field):
            return field.content.string
        case .button(let button):
            return button.content
        }
    }
    
    func removeScriptBorders() {
        
        for view in self.windowControllers[0].window!.contentView!.subviews {
            guard view !== self.view && view !== self.collectionViewSuperview else {
                continue
            }
            view.removeFromSuperview()
        }
    }
    
    func displayStackInfo(_ sender: AnyObject) {
        displayInfo().displayStack(browser.stack)
    }
    
    func displayBackgroundInfo(_ sender: AnyObject) {
        displayInfo().displayBackground(browser.currentBackground)
    }
    
    func displayCardInfo(_ sender: AnyObject) {
        displayInfo().displayCard(browser.currentCard)
    }
    
    func displayInfo() -> InfoPanelController {
        removeScriptBorders()
        
        let controller = InfoPanelController()
        Bundle.main.loadNibNamed("InfoPanel", owner: controller, topLevelObjects: nil)
        controller.setup()
        controller.window.makeKeyAndOrderFront(nil)
        panels.append(controller)
        return controller
    }
    
}


