//
//  DataTests.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 30/08/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//

import XCTest
import HyperCardCommon


/// Tests on binary data of stacks
class DataTests: XCTestCase {
    
    
    /// Test on some strange flags that appeared in some stacks, in the form of high bits activated in
    /// some values without apparent reason. If they are read, they crash the app.
    /// <p>
    /// The test uses the stack "Stack Templates", which has two of them: one high bit in Master Block length,
    /// and one high bit in window rectangle
    func testStrangeFlags() {
        
        /* Open stack */
        let path = Bundle(for: HyperCardCommonTests.self).path(forResource: "TestStrangeFlags", ofType: "stack")!
        let file = ClassicFile(path: path)
        let hyperCardFile = try! HyperCardFile(file: file)
        let stack = hyperCardFile.stack
        
        /* Check window rectangle */
        XCTAssert(stack.windowRectangle == Rectangle(top: 0, left: 0, bottom: 0x156, right: 0x200))
        
        /* Load the list by reading the cards */
        _ = stack.cards
        
    }
    
    
}
