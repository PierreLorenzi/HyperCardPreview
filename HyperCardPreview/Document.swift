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




class Document: NSDocument {
    
    var file: HyperCardFile!
    var browser: Browser!
    
    var pixels: [RgbColor2] = []
    
    var panels: [InfoPanelController] = []
    
    @IBOutlet weak var view: DocumentView!
    
    override var windowNibName: String? {
        return "Document"
    }
    
    override func read(from url: URL, ofType typeName: String) throws {
        file = HyperCardFile(path: url.path)
        
    }
    
    override func windowControllerDidLoadNib(_ windowController: NSWindowController) {
        super.windowControllerDidLoadNib(windowController)
        
        let window = self.windowControllers[0].window!
        let currentFrame = window.frame
        let newFrame = window.frameRect(forContentRect: NSMakeRect(currentFrame.origin.x, currentFrame.origin.y, CGFloat(file.stack.size.width), CGFloat(file.stack.size.height)))
        window.setFrame(newFrame, display: false)
        view.frame = NSMakeRect(0, 0, CGFloat(file.stack.size.width), CGFloat(file.stack.size.height))
        
        browser = Browser(stack: file.stack)
        browser.cardIndex = 0
        
        let width = file.stack.size.width;
        let height = file.stack.size.height;
        self.pixels = [RgbColor2](repeating: RgbWhite2, count: width*height*2)
        refresh()
    }
    
    /// Redraws the HyperCard view
    func refresh() {
        
        displayImage(self.browser.image)
    }
    
    /// Redraws the HyperCard view
    func displayImage(_ image: Image) {
        
        /* Convert the 1-bit image to a Core Graphics image and display it in the HyperCard view */
        
        self.fillBuffer(with: image)
        
        let data = NSMutableData(bytes: &pixels, length: self.pixels.count * MemoryLayout<RgbColor2>.size)
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
        CATransaction.setDisableActions(true)
        view.layer!.contents = cgimage
    }
    
    func fillBuffer(with image: Image) {
        
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
                    self.pixels[offset0] = value
                    self.pixels[offset1] = value
                    offset0 += 1
                    offset1 += 1
                }
            }
            offset0 += image.width
            offset1 += image.width
        }
    }
    
    func applyVisualEffect(from image: Image) {
        
        /* Get the selected visual effect */
        let appDelegate = NSApp.delegate as! AppDelegate
        let visualEffect = appDelegate.selectedVisualEffect
        
        /* Apply it */
        switch visualEffect {
            
        case .dissolve:
            applyDissolveVisualEffect(from: image)
            
        default:
            refresh()
        }
        
    }
    
    func applyDissolveVisualEffect(from image: Image) {
        
        let thread = Thread(block: {
            
            let drawing = Drawing(image: image)
            let startDate = Date()
            let stepDuration: TimeInterval = VisualEffects.duration / Double(VisualEffects.dissolveStepCount)
            
            /* Apply all the steps of the dissolve */
            for i in 0..<VisualEffects.dissolveStepCount {
                
                /* Wait if we're too fast */
                Thread.sleep(until: startDate.addingTimeInterval(stepDuration * Double(i)))
                
                /* Apply the effect */
                VisualEffects.dissolve(self.browser.image, on: drawing, at: i)
                
                /* Display the intermediary image */
                DispatchQueue.main.sync {
                    self.displayImage(drawing.image)
                }
            }
            
        })
        
        thread.start()
        
    }
    
    /// Move to a card with a visual effect
    func goToPage(at index: Int) {
        let oldImage = browser.image
        browser.cardIndex = index
        self.applyVisualEffect(from: oldImage)
    }
    
    func goToFirstPage(_ sender: AnyObject) {
        self.goToPage(at: 0)
    }
    
    func goToLastPage(_ sender: AnyObject) {
        self.goToPage(at: browser.stack.cards.count-1)
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
        self.goToPage(at: cardIndex)
    }
    
    func displayOnlyBackground(_ sender: AnyObject) {
        browser.displayOnlyBackground = !browser.displayOnlyBackground
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
            guard view !== self.view else {
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


