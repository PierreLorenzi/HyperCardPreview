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
    var resourceFork: Data?
    var imageBuffer: ImageBuffer!
    var visualEffectImageBuffer: ImageBuffer!
    
    @IBOutlet weak var view: DocumentView!
    
    @IBOutlet weak var collectionView: CollectionView!
    @IBOutlet weak var collectionViewSuperview: NSView!
    @IBOutlet weak var imageView: NSImageView!
    
    private var collectionViewManager: CollectionViewManager? = nil
    private var resourceController: ResourceController? = nil
    
    override var windowNibName: NSNib.Name? {
        return "Document"
    }
    
    override func read(from url: URL, ofType typeName: String) throws {
        
        try self.readStack(atPath: url.path)
    }
    
    private func readStack(atPath path: String, password: HString? = nil) throws {
        
        do {
            let file = ClassicFile(path: path)
            let hyperCardFile = try HyperCardFile(file: file, password: password)
            let imageBuffer = ImageBuffer(width: hyperCardFile.stack.size.width, height: hyperCardFile.stack.size.height)
            self.browser = Browser(hyperCardFile: hyperCardFile, imageBuffer: imageBuffer)
            self.resourceFork = file.resourceFork
            self.imageBuffer = imageBuffer
        }
        catch Stack.OpeningError.notStack {
            
            /* Tell the user we can't open the file */
            let alert = NSAlert(error: Stack.OpeningError.notStack)
            alert.messageText = "The file is not a stack"
            alert.informativeText = "The file can't be opened because it is not recognized as a stack"
            alert.runModal()
            throw Stack.OpeningError.notStack
            
        }
        catch Stack.OpeningError.corrupted {
            
            /* Tell the user we can't open the file */
            let alert = NSAlert(error: Stack.OpeningError.notStack)
            alert.messageText = "The stack is corrupted"
            alert.informativeText = "The stack can't be opened because the data is corrupted"
            alert.runModal()
            throw Stack.OpeningError.notStack
            
        }
        catch Stack.OpeningError.missingPassword {
            
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
                throw Stack.OpeningError.wrongPassword
            }
            
            /* Get the password */
            let passwordString = textField.stringValue
            guard passwordString != "" else {
                throw Stack.OpeningError.wrongPassword
            }
            
            /* Convert it to Mac OS Roman encoding */
            guard let password = HString(converting: passwordString) else {
                
                /* Tell the user we can't convert */
                let alert = NSAlert()
                alert.messageText = "Wrong Password"
                alert.runModal()
                throw Stack.OpeningError.wrongPassword
            }
            
            /* Try again to open the file, this time with the password */
            try self.readStack(atPath: path, password: password)
            
        }
        catch Stack.OpeningError.wrongPassword {
            let alert = NSAlert()
            alert.messageText = "Wrong Password"
            alert.runModal()
            throw Stack.OpeningError.wrongPassword
        }
        
    }
    
    private var willRefreshBrowser = false
    
    override func windowControllerDidLoadNib(_ windowController: NSWindowController) {
        super.windowControllerDidLoadNib(windowController)
        
        windowController.shouldCloseDocument = true
        
        let window = self.windowControllers[0].window!
        let currentFrame = window.frame
        let newFrame = window.frameRect(forContentRect: NSMakeRect(currentFrame.origin.x, currentFrame.origin.y, CGFloat(browser.stack.size.width), CGFloat(browser.stack.size.height)))
        window.setFrame(newFrame, display: false)
        view.frame = NSMakeRect(0, 0, CGFloat(browser.stack.size.width), CGFloat(browser.stack.size.height))
        browser.cursorRectanglesProperty.startNotifications(for: self) {
            window.invalidateCursorRects(for: self.view)
        }
        
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
        collectionView.mainAction =  {
            [unowned self] in
            
            /* Display the selected card */
            self.warnCardWasSelected(atIndex: self.collectionView.selectionIndexPaths.first!.item)
        }
        collectionView.cancelAction =  {
            [unowned self] in
            
            /* Move back to the current card */
            self.warnCardWasSelected(atIndex: self.browser.cardIndex)
        }
        
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
            let image = NSImage(cgImage: self.imageBuffer.context.makeImage()!, size: NSZeroSize)
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
        
        self.animateImageView(isAppearing: true, cardIndex: cardIndex, image: image, onCompletion: {
            
            /* At the end, hide the card list */
            [unowned self] in
            self.collectionViewSuperview.isHidden = true
            self.view.window!.makeFirstResponder(self.view)
        })
    }
    
    private func animateCardDisappearing() {
        
        /* Animate the image becoming the thumbnail */
        let imageSize = NSSize(width: browser.image.width, height: browser.image.height)
        let image = NSImage(cgImage: self.imageBuffer.context.makeImage()!, size: imageSize)
        self.animateImageView(isAppearing: false, cardIndex: browser.cardIndex, image: image, onCompletion: {
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
    
    private func animateImageView(isAppearing: Bool, cardIndex: Int, image: NSImage?, onCompletion: @escaping () -> Void) {
        
        /* Parameters for the card animation */
        let cardSmallFrame = self.computeAnimationFrameInList(ofCardAtIndex: cardIndex)
        let cardBigFrame = self.view.frame
        let cardInitialFrame: NSRect = isAppearing ? cardSmallFrame : cardBigFrame
        let cardFinalFrame: NSRect = isAppearing ? cardBigFrame : cardSmallFrame
        
        /* Parameters for the card list animation */
        let listSmallFrame = self.computeRectangleFrame(of: Rectangle(x: 0, y: 0, width: browser.stack.size.width, height: browser.stack.size.height))
        let listBigFrame = self.view.frame
        let listInitialFrame: NSRect = isAppearing ? listBigFrame : listSmallFrame
        let listFinalFrame: NSRect = isAppearing ? listSmallFrame : listBigFrame
        
        self.imageView.frame = cardInitialFrame
        self.imageView.image = image
        self.imageView.isHidden = false
        
        self.collectionViewSuperview.frame = listInitialFrame
        if !isAppearing {
            self.collectionViewSuperview.isHidden = false
        }
        
        /* Store the end block */
        self.actionAfterAnimation = onCompletion
        self.hideListAfterAnimation = isAppearing
        
        /* Launch the animation */
        let cardAnimationInfo: [NSViewAnimation.Key: Any] = [
            NSViewAnimation.Key.target: self.imageView!,
            NSViewAnimation.Key.startFrame: NSValue(rect: cardInitialFrame),
            NSViewAnimation.Key.endFrame: NSValue(rect: cardFinalFrame)
        ]
        let listAnimationInfo: [NSViewAnimation.Key: Any] = [
            NSViewAnimation.Key.target: self.collectionViewSuperview!,
            NSViewAnimation.Key.startFrame: NSValue(rect: listInitialFrame),
            NSViewAnimation.Key.endFrame: NSValue(rect: listFinalFrame)
        ]
        let animation = NSViewAnimation(viewAnimations: [cardAnimationInfo, listAnimationInfo])
        animation.delegate = self
        animation.duration = 0.2
        animation.start()
        
    }
    
    private var actionAfterAnimation: (() -> Void)? = nil
    private var hideListAfterAnimation = false
    
    func animationDidEnd(_ animation: NSAnimation) {
        
        self.imageView.isHidden = true
        if self.hideListAfterAnimation {
            self.collectionViewSuperview.isHidden = true
        }
        if let onCompletion = self.actionAfterAnimation {
            onCompletion()
            self.actionAfterAnimation = nil
        }
        
    }
    
    private func computeRectangleFrame(of rectangle: Rectangle) -> NSRect {
        
        let rectangleOrigin = CGPoint(x: rectangle.left, y: rectangle.top)
        let rectangleEnd = CGPoint(x: rectangle.right, y: rectangle.bottom)
        
        let transform = self.view.transform
        let transformedOrigin = transform.transform(rectangleOrigin)
        let transformedEnd = transform.transform(rectangleEnd)
        
        let frameOrigin = NSPoint(x: min(transformedOrigin.x, transformedEnd.x), y: min(transformedOrigin.y, transformedEnd.y))
        let frameSize = NSSize(width: abs(transformedEnd.x - transformedOrigin.x), height: abs(transformedEnd.y - transformedOrigin.y))
        
        return NSRect(origin: frameOrigin, size: frameSize)
    }
    
    /// Redraws the HyperCard view
    func refresh() {
        removeScriptBorders()
        
        /* Update the image */
        browser.refresh()
        
        /* Display the image in the layer */
        view.drawBuffer(self.imageBuffer)
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
        
        if self.visualEffectImageBuffer == nil {
            self.visualEffectImageBuffer = ImageBuffer(width: self.imageBuffer.width, height: self.imageBuffer.height)
        }
        
        /* Convert the image to screen */
        self.visualEffectImageBuffer.drawImage(image)
        
        /* Display the image */
        self.view.drawBuffer(self.visualEffectImageBuffer)
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
        let frame = self.computeRectangleFrame(of: rectangle)
        
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
        
        let controller = InfoPanelController(windowNibName: "InfoPanel")
        _ = controller.window // Load the nib
        controller.setup()
        controller.showWindow(nil)
        self.addWindowController(controller)
        return controller
    }
    
    @objc func exportStackAsText(_ sender: AnyObject) {
        
        /* Choose a file */
        let savePanel = NSSavePanel()
        savePanel.title = "Export stack"
        savePanel.message = "Export to JSON (learn about it in the ReadMe):"
        savePanel.isExtensionHidden = false
        savePanel.allowedFileTypes = ["public.json"]
        savePanel.allowsOtherFileTypes = false
        savePanel.nameFieldStringValue = "\(self.fileURL!.lastPathComponent).json"
        
        savePanel.begin { (response: NSApplication.ModalResponse) in
            
            /* Check the user clicked "OK" */
            guard response == NSApplication.ModalResponse.OK else {
                return
            }
            
            /* Get the requested url */
            guard let url = savePanel.url else {
                return
            }
            
            /* Prepare the JSON encoder */
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            encoder.keyEncodingStrategy = JSONEncoder.KeyEncodingStrategy.convertToSnakeCase
            
            do {
                
                /* Export to JSON */
                let data = try encoder.encode(self.browser.stack)
                try data.write(to: url)
            }
            catch let error {
                
                /* Show the alert to the user */
                let alert = NSAlert(error: error)
                alert.messageText = "Can't export stack as text"
                alert.runModal()
            }
        }
    }
    
    @objc func exportCardImages(_ sender: AnyObject) {
        
        ImageExporter.export(stack: self.browser.stack, layerType: LayerType.card)
    }
    
    @objc func exportBackgroundImages(_ sender: AnyObject) {
        
        ImageExporter.export(stack: self.browser.stack, layerType: LayerType.background)
    }
    
    @objc func displayResources(_ sender: AnyObject) {
        
        /* Get the controller */
        let controller: ResourceController
        if let existingController = self.resourceController {
            controller = existingController
        }
        else {
            controller = self.buildResourceController()
            self.resourceController = controller
        }
        
        /* Display the window */
        controller.showWindow(nil)
        
        /* Append the window to the document hierarchy if necessary */
        if controller.document == nil {
            self.addWindowController(controller)
        }
    }
    
    private func buildResourceController() -> ResourceController {
        
        let controller = ResourceController(windowNibName: "ResourceWindow")
        _ = controller.window // Load the nib
        controller.setup(resourceFork: self.resourceFork)
        
        return controller
    }
    
}


