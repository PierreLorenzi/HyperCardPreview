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

typealias RgbColor2 = UInt64
let RgbWhite2: RgbColor2 = 0xFFFF_FFFF_FFFF_FFFF
let RgbBlack2: RgbColor2 = 0xFF00_0000_FF00_0000


let RgbColorSpace = CGColorSpaceCreateDeviceRGB()
let BitmapInfo:CGBitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)
let BitsPerComponent = 8
let BitsPerPixel = 32




class Document: NSDocument, NSCollectionViewDelegate {
    
    var file: HyperCardFile!
    var browser: Browser!
    
    var panels: [InfoPanelController] = []
    
    @IBOutlet weak var view: DocumentView!
    
    @IBOutlet weak var collectionView: NSCollectionView!
    @IBOutlet weak var collectionViewSuperview: NSView!
    
    private var collectionViewManager: CollectionViewManager? = nil
    
    private var areThereColors = false
    
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
                    
                    s.browser.refresh()
                    s.refresh()
                    s.willRefreshBrowser = false
                }
            }
            
        })
        
        view.browser = browser
        
        /* Check if there are colors in the stack resources */
        if let resources = browser.stack.resources?.resources {
            if let _ = resources.index(where: { $0 is Resource<[AddColorElement]> }) {
                self.areThereColors = true
            }
        }
        
        browser.refresh()
        refresh()
    }
    
    func showCards(_ sender: AnyObject) {
        
        guard self.collectionViewSuperview.isHidden else {
            self.collectionViewSuperview.isHidden = true
            return
        }
        
        if self.collectionViewManager == nil {
            self.collectionViewManager = CollectionViewManager(collectionView: self.collectionView, stack: file.stack)
        }
        
        self.collectionView.selectItems(at: Set<IndexPath>([IndexPath(item: self.browser.cardIndex, section: 0)]), scrollPosition: NSCollectionViewScrollPosition.centeredVertically)
        self.collectionViewSuperview.isHidden = false
    }
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        self.browser.cardIndex = indexPaths.first!.item
        self.collectionViewSuperview.isHidden = true
    }
    
    /// Redraws the HyperCard view
    func refresh() {
        
        displayImage(self.browser.image, withColors: self.areThereColors)
    }
    
    /// Redraws the HyperCard view
    func displayImage(_ image: Image, withColors: Bool = false) {
        
        /* Convert the 1-bit image to RGB */
        let bufferLength = browser.image.width * browser.image.height * 2 * MemoryLayout<RgbColor2>.size
        let data = NSMutableData(length: bufferLength)!
        let buffer = data.mutableBytes.assumingMemoryBound(to: RgbColor2.self)
        
        /* Add the colors if requested. They must be drawn behind the HyperCard image */
        if withColors {
            paintColors(onBuffer: buffer)
        }
        
        /* Draw the Hypercard image. Draw only the black pixels if there are colors behind. */
        self.fillBuffer(buffer, with: image, drawWhitePixels: !withColors)
        
        /* Build a CoreGraphics image */
        let providerRef = CGDataProvider(data: data)
        let width = file.stack.size.width;
        let height = file.stack.size.height;
        let cgimage = CGImage(
            width: width*2,
            height: height*2,
            bitsPerComponent: BitsPerComponent,
            bitsPerPixel: BitsPerPixel,
            bytesPerRow: width * MemoryLayout<RgbColor2>.size,
            space: RgbColorSpace,
            bitmapInfo: BitmapInfo,
            provider: providerRef!,
            decode: nil,
            shouldInterpolate: true,
            intent: CGColorRenderingIntent.defaultIntent)
        
        /* Display the image in the layer */
        CATransaction.setDisableActions(true)
        view.layer!.contents = cgimage
    }
    
    func fillBuffer(_ buffer: UnsafeMutablePointer<RgbColor2>, with image: Image, drawWhitePixels: Bool) {
        
        /* As the scale is two, there are two rows to fill at every pixel */
        var offset0 = 0
        var offset1 = image.width
        
        var integerIndex = 0
        
        for _ in 0..<image.height {
            for _ in 0..<image.integerCountInRow {
                
                let integer = image.data[integerIndex]
                integerIndex += 1
                
                for i in (UInt32(0)...UInt32(31)).reversed() {
                    let value = ((integer >> i & 1) == 1) ? RgbBlack2 : RgbWhite2
                    
                    guard drawWhitePixels || value != RgbWhite2 else {
                        offset0 += 1
                        offset1 += 1
                        continue;
                    }
                        
                    buffer[offset0] = value
                    buffer[offset1] = value
                    offset0 += 1
                    offset1 += 1
                }
            }
            offset0 += image.width
            offset1 += image.width
        }
    }
    
    func paintColors(onBuffer buffer: UnsafeMutablePointer<RgbColor2>) {
        
        /* Create a bitmap context to paint on it */
        let rawBuffer = UnsafeMutableRawPointer.init(buffer)!
        let context: CGContext! = CGContext.init(
            data: rawBuffer,
            width: browser.image.width * 2,
            height: browser.image.height * 2,
            bitsPerComponent: BitsPerComponent,
            bytesPerRow: 2 * browser.image.width * 4,
            space: RgbColorSpace,
            bitmapInfo: BitmapInfo.rawValue)
        
        /* Apply scale two */
        context.scaleBy(x: 2, y: 2)
        
        /* Flip the coordinates */
        context.translateBy(x: 0, y: CGFloat(browser.image.height))
        context.scaleBy(x: 1, y: -1)
        
        /* Draw a white background */
        context.setFillColor(CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
        context.fill(CGRect(x: 0, y: 0, width: browser.image.width, height: browser.image.height))
        
        /* Draw the color elements */
        AddColorPainter.paintAddColor(ofStack: browser.stack, atCardIndex: browser.cardIndex, excludeCardParts: browser.displayOnlyBackground, onContext: context)
        
        context.flush()
        
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
        createScriptBorders(in: browser.currentBackground, includingFields: includingFields, cardContents: browser.currentCard.backgroundPartContents)
        if !browser.displayOnlyBackground {
            createScriptBorders(in: browser.currentCard, includingFields: includingFields, cardContents: nil)
        }
        
    }
    
    func createScriptBorders(in layer: Layer, includingFields: Bool, cardContents: [Card.BackgroundPartContent]?) {
        
        for part in layer.parts {
            
            /* Exclude fields if necessary */
            if case LayerPart.field(_) = part, !includingFields {
                continue
            }
            
            /* Convert the rectangle into current coordinates */
            let rectangle = part.part.rectangle
            let frame = NSMakeRect(CGFloat(rectangle.x), CGFloat(file.stack.size.height - rectangle.bottom), CGFloat(rectangle.width), CGFloat(rectangle.height))
            
            /* Create a view */
            let view = ScriptBorderView(frame: frame, part: part, content: retrieveContent(part: part, cardContents: cardContents), document: self)
            view.wantsLayer = true
            view.layer!.borderColor = NSColor.blue.cgColor
            view.layer!.borderWidth = 1
            view.layer!.backgroundColor = CGColor(red: 0, green: 0, blue: 1, alpha: 0.03)
            
            self.windowControllers[0].window!.contentView!.addSubview(view)
            
        }
        
    }
    
    func retrieveContent(part: LayerPart, cardContents: [Card.BackgroundPartContent]?) -> HString {
        
        if let contents = cardContents {
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


