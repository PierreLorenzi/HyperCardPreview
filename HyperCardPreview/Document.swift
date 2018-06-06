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




class Document: NSDocument, NSAnimationDelegate {
    
    var browser: Browser!
    
    var panels: [InfoPanelController] = []
    
    @IBOutlet weak var view: DocumentView!
    
    @IBOutlet weak var collectionView: CollectionView!
    @IBOutlet weak var collectionViewSuperview: NSView!
    @IBOutlet weak var imageView: NSImageView!
    
    private var collectionViewManager: CollectionViewManager? = nil
    
    override var windowNibName: NSNib.Name? {
        return NSNib.Name(rawValue: "Document")
    }
    
    override func read(from url: URL, ofType typeName: String) throws {
        
        try self.readStack(atPath: url.path)
    }
    
    private func readStack(atPath path: String, password: HString? = nil) throws {
        
        do {
            let file = ClassicFile(path: path)
            let hyperCardFile = try HyperCardFile(file: file, password: password)
            self.browser = Browser(hyperCardFile: hyperCardFile)
        }
        catch OpeningError.notStack {
            
            /* Tell the user we can't open the file */
            let alert = NSAlert(error: OpeningError.notStack)
            alert.messageText = "The file is not a stack"
            alert.informativeText = "The file can't be opened because it is not recognized as a stack"
            alert.runModal()
            throw OpeningError.notStack
            
        }
        catch OpeningError.corrupted {
            
            /* Tell the user we can't open the file */
            let alert = NSAlert(error: OpeningError.notStack)
            alert.messageText = "The stack is corrupted"
            alert.informativeText = "The stack can't be opened because the data is corrupted"
            alert.runModal()
            throw OpeningError.notStack
            
        }
        catch OpeningError.missingPassword {
            
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
            guard answer == NSApplication.ModalResponse.alertFirstButtonReturn else {
                throw OpeningError.wrongPassword
            }
            
            /* Get the password */
            let passwordString = textField.stringValue
            guard passwordString != "" else {
                throw OpeningError.wrongPassword
            }
            
            /* Convert it to Mac OS Roman encoding */
            guard let password = HString(converting: passwordString) else {
                
                /* Tell the user we can't convert */
                let alert = NSAlert()
                alert.messageText = "Wrong Password"
                alert.runModal()
                throw OpeningError.wrongPassword
            }
            
            /* Try again to open the file, this time with the password */
            try self.readStack(atPath: path, password: password)
            
        }
        catch OpeningError.wrongPassword {
            let alert = NSAlert()
            alert.messageText = "Wrong Password"
            alert.runModal()
            throw OpeningError.wrongPassword
        }
        
    }
    
    private var willRefreshBrowser = false
    
    override func windowControllerDidLoadNib(_ windowController: NSWindowController) {
        super.windowControllerDidLoadNib(windowController)
        
        let window = self.windowControllers[0].window!
        let currentFrame = window.frame
        let newFrame = window.frameRect(forContentRect: NSMakeRect(currentFrame.origin.x, currentFrame.origin.y, CGFloat(browser.stack.size.width), CGFloat(browser.stack.size.height)))
        window.setFrame(newFrame, display: false)
        view.frame = NSMakeRect(0, 0, CGFloat(browser.stack.size.width), CGFloat(browser.stack.size.height))
        
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
        collectionView.document = self
        
        goToCard(at: 0, transition: .none)
    }
    
    @objc func showCards(_ sender: AnyObject) {
        
        /* If the card list is already visible, hide it and go to the selected card */
        guard self.collectionViewSuperview.isHidden else {
            
            /* Go to the selected card */
            let selectionIndexes = collectionView.selectionIndexes
            if let index = selectionIndexes.first {
                goToCard(at: index, transition: .none)
            }
            
            /* Animate the card view appearing */
            let imageSize = NSSize(width: browser.image.width, height: browser.image.height)
            let image = NSImage(cgImage: createScreenImage(from: browser.buildImage()), size: imageSize)
            animateCardAppearing(atIndex: browser.cardIndex, withImage: image)
            
            return
        }
        
        /* Check if the thumbnails are managed */
        if self.collectionViewManager == nil {
            self.collectionViewManager = CollectionViewManager(collectionView: self.collectionView, hyperCardFile: browser.hyperCardFile, document: self)
        }
        
        /* Display the card list */
        let selectionIndexSet = Set<IndexPath>([IndexPath(item: self.browser.cardIndex, section: 0)])
        self.collectionView.selectionIndexPaths = selectionIndexSet
        self.collectionView.scrollToItems(at: selectionIndexSet, scrollPosition: NSCollectionView.ScrollPosition.centeredVertically)
        self.collectionViewManager!.selectedIndex = self.browser.cardIndex
        
        /* Hide the card */
        removeScriptBorders()
        self.animateCardDisappearing()
        
    }
    
    func warnCardWasSelected(atIndex index: Int) {
        
        /* When a thumbnail is selected, go to the card and hide the card list */
        goToCard(at: index, transition: .none)
        
        /* Animate the thumbnail becoming the card view. Don't do it now because we're in a callback */
        DispatchQueue.main.async {
            [unowned self] in
            let thumbnailImage = self.collectionViewManager?.thumbnails[index]
            let image = (thumbnailImage == nil) ? nil : NSImage(cgImage: thumbnailImage!, size: NSZeroSize)
            self.animateCardAppearing(atIndex: index, withImage: image)
        }
        
    }
    
    private func animateCardAppearing(atIndex cardIndex: Int, withImage image: NSImage?) {
        
        let initialFrame = self.computeAnimationFrameInList(ofCardAtIndex: cardIndex)
        self.animateImageView(fromFrame: initialFrame, toFrame: self.view.frame, withImage: image, onCompletion: {
            
            /* At the end, hide the card list */
            [unowned self] in
            self.collectionViewSuperview.isHidden = true
            self.view.window!.makeFirstResponder(self.view)
        })
    }
    
    private func animateCardDisappearing() {
        
        /* Show the card list */
        self.collectionViewSuperview.isHidden = false
        
        /* Animate the image becoming the thumbnail */
        let imageSize = NSSize(width: browser.image.width, height: browser.image.height)
        let image = NSImage(cgImage: createScreenImage(from: browser.buildImage()), size: imageSize)
        let finalFrame = self.computeAnimationFrameInList(ofCardAtIndex: browser.cardIndex)
        self.animateImageView(fromFrame: self.view.frame, toFrame: finalFrame, withImage: image, onCompletion: {
            [unowned self] in
            self.collectionView.window!.makeFirstResponder(self.collectionView)
        })
        
    }
    
    private func computeAnimationFrameInList(ofCardAtIndex cardIndex: Int) -> NSRect {
        
        /* Check if the thumbnail of the card is still visible */
        let visibleIndexPaths = self.collectionView.indexPathsForVisibleItems()
        let isCardVisible = visibleIndexPaths.contains(where: { $0.item == cardIndex })
        
        /* If it is visible, start the animation from the thumbnail */
        if isCardVisible {
            let thumbnailFrame = self.collectionView.frameForItem(at: cardIndex)
            let imageFrame = NSRect(x: thumbnailFrame.origin.x + CardItemView.selectionMargin, y: thumbnailFrame.origin.y + CardItemView.selectionMargin, width: thumbnailFrame.size.width - 2.0 * CardItemView.selectionMargin, height: thumbnailFrame.size.height - 2.0 * CardItemView.selectionMargin)
            return self.collectionView.convert(imageFrame, to: nil)
        }
        
        /* Elsewhere, start the animation from the center of the window */
        let initialSize = CGFloat(30)
        return NSRect(x: view.frame.width/2 - initialSize/2, y: view.frame.height/2 - initialSize/2, width: initialSize, height: initialSize)
        
    }
    
    private func animateImageView(fromFrame initialFrame: NSRect, toFrame finalFrame: NSRect, withImage image: NSImage?, onCompletion: @escaping () -> Void) {
        
        /* Show the image view at the initial frame */
        self.imageView.frame = initialFrame
        self.imageView.image = image
        self.imageView.isHidden = false
        
        /* Store the end block */
        self.actionAfterAnimation = onCompletion
        
        /* Launch the animation */
        let animationInfo: [NSViewAnimation.Key: Any] = [
            NSViewAnimation.Key.target: self.imageView,
            NSViewAnimation.Key.startFrame: NSValue(rect: initialFrame),
            NSViewAnimation.Key.endFrame: NSValue(rect: finalFrame)
        ]
        let animation = NSViewAnimation(viewAnimations: [animationInfo])
        animation.delegate = self
        animation.duration = 0.2
        animation.start()
        
    }
    
    private var actionAfterAnimation: (() -> Void)? = nil
    
    func animationDidEnd(_ animation: NSAnimation) {
        
        if let onCompletion = self.actionAfterAnimation {
            onCompletion()
            self.actionAfterAnimation = nil
        }
        self.imageView.isHidden = true
        
    }
    
    /// Redraws the HyperCard view
    func refresh() {
        removeScriptBorders()
        
        /* Update the image */
        browser.refresh()
        
        /* Create a copy of the image for the screen */
        let screenImage = createScreenImage(from: browser.buildImage())
        
        /* Display the image in the layer */
        CATransaction.setDisableActions(true)
        view.layer!.contents = screenImage
    }
    
    private func createScreenImage(from image: CGImage) -> CGImage {
        
        /* Create a new bitmap with a context to draw on it. Make it pixel-accurate so we can
         display a very aliased image */
        let scale = Int(NSScreen.main!.backingScaleFactor)
        let width = image.width * scale
        let height = image.height  * scale
        let data = RgbConverter.createRgbData(width: width, height: height)
        let context = RgbConverter.createContext(forRgbData: data, width: width, height: height)
        
        /* Make the context aliased */
        context.setShouldAntialias(false)
        context.interpolationQuality = .none
        
        /* Fill the image */
        context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        return RgbConverter.createImage(forRgbData: data, isOwner: true, width: width, height: height)
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
    
    enum Transition {
        case none
        case forward
        case backward
    }
    
    /// Move to a card with a visual effect
    func goToCard(at index: Int, transition: Transition) {
        let possibleOldImage = (transition != .none) ? browser.image : nil
        
        /* Stop refresh */
        self.willRefreshBrowser = true
        browser.cardIndex = index
        browser.refresh()
        
        /* Move to the card */
        if let oldImage = possibleOldImage, transition != .none {
            self.applyVisualEffect(from: oldImage, advance: transition == .forward)
        }
        else {
            self.refresh()
        }
        
        /* Restart refresh */
        self.willRefreshBrowser = false
        
        /* Update the title of the window */
        self.windowControllers[0].window!.title = self.displayName
    }
    
    override var displayName: String! {
        get {
            guard let browser = self.browser else {
                return super.displayName
            }
            return "\(super.displayName!)   \(browser.cardIndex + 1) / \(browser.stack.cards.count)"
        }
        set {
            super.displayName = newValue
        }
    }
    
    @objc func goToFirstPage(_ sender: AnyObject) {
        self.goToCard(at: 0, transition: .backward)
    }
    
    @objc func goToLastPage(_ sender: AnyObject) {
        self.goToCard(at: browser.stack.cards.count-1, transition: .forward)
    }
    
    @objc func goToNextPage(_ sender: AnyObject) {
        var cardIndex = browser.cardIndex
        cardIndex += 1
        if cardIndex == browser.stack.cards.count {
            cardIndex = 0
        }
        self.goToCard(at: cardIndex, transition: .forward)
    }
    
    @objc func goToPreviousPage(_ sender: AnyObject) {
        var cardIndex = browser.cardIndex
        cardIndex -= 1
        if cardIndex == -1 {
            cardIndex = browser.stack.cards.count - 1
        }
        self.goToCard(at: cardIndex, transition: .backward)
    }
    
    @objc func displayOnlyBackground(_ sender: AnyObject) {
        browser.displayOnlyBackground = !browser.displayOnlyBackground
        
        if let menuItem = sender as? NSMenuItem {
            menuItem.state = browser.displayOnlyBackground ? NSControl.StateValue.on : NSControl.StateValue.off
        }
        
        refresh()
    }
    
    @objc func displayButtonScriptBorders(_ sender: AnyObject) {
        createScriptBorders(includingFields: false)
    }
    
    @objc func displayPartScriptBorders(_ sender: AnyObject) {
        createScriptBorders(includingFields: true)
    }
    
    @objc func hideScriptBorders(_ sender: AnyObject) {
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
        let frame = NSMakeRect(CGFloat(rectangle.x), CGFloat(browser.stack.size.height - rectangle.bottom), CGFloat(rectangle.width), CGFloat(rectangle.height))
        
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
            guard view !== self.view && view !== self.collectionViewSuperview && view !== self.imageView else {
                continue
            }
            view.removeFromSuperview()
        }
    }
    
    @objc func displayStackInfo(_ sender: AnyObject) {
        displayInfo().displayStack(browser.hyperCardFile)
    }
    
    @objc func displayBackgroundInfo(_ sender: AnyObject) {
        displayInfo().displayBackground(browser.currentBackground)
    }
    
    @objc func displayCardInfo(_ sender: AnyObject) {
        displayInfo().displayCard(browser.currentCard)
    }
    
    func displayInfo() -> InfoPanelController {
        removeScriptBorders()
        
        let controller = InfoPanelController()
        Bundle.main.loadNibNamed(NSNib.Name(rawValue: "InfoPanel"), owner: controller, topLevelObjects: nil)
        controller.setup()
        controller.window.makeKeyAndOrderFront(nil)
        panels.append(controller)
        return controller
    }
    
}


