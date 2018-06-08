//
//  GraphicTests.swift
//  HyperCardCommonTests
//
//  Created by Pierre Lorenzi on 07/06/2018.
//  Copyright © 2018 Pierre Lorenzi. All rights reserved.
//

import XCTest
import HyperCardCommon


/// Tests on binary data of stacks
class GraphicTests: XCTestCase {
    
    private func makeTestOfStack(withName stackName: String) {
            
        /* Load the stack. We must use a separate resource file to be handled
         by non-mac commands. */
        let bundle = Bundle(for: GraphicTests.self)
        let dataUrl = bundle.url(forResource: stackName, withExtension: "stack")!
        let dataFork = try! Data(contentsOf: dataUrl)
        var resourceFork: Data? = nil
        if let resourceUrl = bundle.url(forResource: stackName, withExtension: "rsrc") {
            resourceFork = try! Data(contentsOf: resourceUrl)
        }
        let file = ClassicFile(dataFork: dataFork, resourceFork: resourceFork)
        let hyperCardFile = try! HyperCardFile(file: file)
        
        /* Make a browser to draw the cards */
        let browser = Browser(hyperCardFile: hyperCardFile)
        
        for cardIndex in 0..<hyperCardFile.stack.cards.count {
            
            /* Draw the card */
            browser.cardIndex = cardIndex
            browser.refresh()
            
            /* Load the expected image */
            let expectedImageName = "\(stackName) \(cardIndex + 1)"
            guard let path = bundle.pathForImageResource(NSImage.Name(rawValue: expectedImageName)),
                let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
                let representation = NSBitmapImageRep(data: data) else {
                    XCTFail()
                    continue
            }
            guard let maskedImage = MaskedImage(representation: representation) else {
                XCTFail()
                continue
            }
            guard case MaskedImage.Layer.bitmap(image: let expectedImage, imageRectangle: _, realRectangleInImage: _) = maskedImage.image else {
                XCTFail()
                continue
            }
            
            /* XOR: un-comment to see the result of a test */
//                if browser.image != expectedImage {
//                    let drawing = Drawing(image: expectedImage)
//                    drawing.drawImage(browser.image, position: Point(x: 0, y: 0), composition: Drawing.XorComposition)
//                    let cgimage = RgbConverter.convertImage(drawing.image)
//                    let nsimage = NSImage(cgImage: cgimage, size: NSSize(width: 512, height: 342))
//                    print("breakpoint here")
//                }
            
            /* Check the card graphic */
            XCTAssert(browser.image == expectedImage, "Graphic test failed in stack \"\(stackName)\" at card \(cardIndex + 1)")
            
        }
        
    }
    
    func testHome() {
        self.makeTestOfStack(withName: "Home")
    }
    
    func testBitmap() {
        self.makeTestOfStack(withName: "TestBitmap")
    }
    
    
}
