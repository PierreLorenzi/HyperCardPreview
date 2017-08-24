//
//  HyperCardCommonTests.swift
//  HyperCardCommonTests
//
//  Created by Pierre Lorenzi on 24/08/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//

import XCTest
import HyperCardCommon

class HyperCardCommonTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCardsBackgrounds() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        /* Open stack */
        let path = Bundle(for: HyperCardCommonTests.self).path(forResource: "TestCardsBackgrounds", ofType: "stack")!
        let file = try! HyperCardFile(path: path)
        
        /* Check cards and backgrounds */
        let stackBlock = file.parsedData.stack
        
        let cardIdentifier0 = 2842
        let cardIdentifier1 = 3767
        let cardIdentifier2 = 4162
        let cardIdentifier3 = 4585
        let cardIdentifier4 = 4660
        let cardIdentifier5 = 5225
        let backgroundIdentifier0 = 2769
        let backgroundIdentifier1 = 3887
        let backgroundIdentifier2 = 5065
        
        /* Check in STAK block */
        XCTAssert(stackBlock.cardCount == 6)
        XCTAssert(stackBlock.firstCardIdentifier == cardIdentifier0)
        XCTAssert(stackBlock.backgroundCount == 3)
        XCTAssert(stackBlock.firstBackgroundIdentifier == backgroundIdentifier0)
        
        /* Check CARD blocks */
        XCTAssert(file.parsedData.cards.count == 6)
        XCTAssert(file.parsedData.cards[0].identifier == cardIdentifier0)
        XCTAssert(file.parsedData.cards[0].backgroundIdentifier == backgroundIdentifier0)
        XCTAssert(file.parsedData.cards[0].isStartOfBackground == true)
        XCTAssert(file.parsedData.cards[1].identifier == cardIdentifier1)
        XCTAssert(file.parsedData.cards[1].backgroundIdentifier == backgroundIdentifier0)
        XCTAssert(file.parsedData.cards[1].isStartOfBackground == false)
        XCTAssert(file.parsedData.cards[2].identifier == cardIdentifier2)
        XCTAssert(file.parsedData.cards[2].backgroundIdentifier == backgroundIdentifier1)
        XCTAssert(file.parsedData.cards[2].isStartOfBackground == true)
        XCTAssert(file.parsedData.cards[3].identifier == cardIdentifier3)
        XCTAssert(file.parsedData.cards[3].backgroundIdentifier == backgroundIdentifier1)
        XCTAssert(file.parsedData.cards[3].isStartOfBackground == false)
        XCTAssert(file.parsedData.cards[4].identifier == cardIdentifier4)
        XCTAssert(file.parsedData.cards[4].backgroundIdentifier == backgroundIdentifier1)
        XCTAssert(file.parsedData.cards[4].isStartOfBackground == false)
        XCTAssert(file.parsedData.cards[5].identifier == cardIdentifier5)
        XCTAssert(file.parsedData.cards[5].backgroundIdentifier == backgroundIdentifier2)
        XCTAssert(file.parsedData.cards[5].isStartOfBackground == true)
        
        /* Check BKGD blocks */
        XCTAssert(file.parsedData.backgrounds.count == 3)
        XCTAssert(file.parsedData.backgrounds[0].identifier == backgroundIdentifier0)
        XCTAssert(file.parsedData.backgrounds[0].cardCount == 2)
        XCTAssert(file.parsedData.backgrounds[0].nextBackgroundIdentifier == backgroundIdentifier1)
        XCTAssert(file.parsedData.backgrounds[0].previousBackgroundIdentifier == backgroundIdentifier2)
        XCTAssert(file.parsedData.backgrounds[1].identifier == backgroundIdentifier1)
        XCTAssert(file.parsedData.backgrounds[1].cardCount == 3)
        XCTAssert(file.parsedData.backgrounds[1].nextBackgroundIdentifier == backgroundIdentifier2)
        XCTAssert(file.parsedData.backgrounds[1].previousBackgroundIdentifier == backgroundIdentifier0)
        XCTAssert(file.parsedData.backgrounds[2].identifier == backgroundIdentifier2)
        XCTAssert(file.parsedData.backgrounds[2].cardCount == 1)
        XCTAssert(file.parsedData.backgrounds[2].nextBackgroundIdentifier == backgroundIdentifier0)
        XCTAssert(file.parsedData.backgrounds[2].previousBackgroundIdentifier == backgroundIdentifier1)
        
        /* Check in data */
        let stack = file.stack
        XCTAssert(stack.cards.count == 6)
        XCTAssert(stack.cards[0].identifier == cardIdentifier0)
        XCTAssert(stack.cards[0].background === stack.backgrounds[0])
        XCTAssert(stack.cards[1].identifier == cardIdentifier1)
        XCTAssert(stack.cards[1].background === stack.backgrounds[0])
        XCTAssert(stack.cards[2].identifier == cardIdentifier2)
        XCTAssert(stack.cards[2].background === stack.backgrounds[1])
        XCTAssert(stack.cards[3].identifier == cardIdentifier3)
        XCTAssert(stack.cards[3].background === stack.backgrounds[1])
        XCTAssert(stack.cards[4].identifier == cardIdentifier4)
        XCTAssert(stack.cards[4].background === stack.backgrounds[1])
        XCTAssert(stack.cards[5].identifier == cardIdentifier5)
        XCTAssert(stack.cards[5].background === stack.backgrounds[2])
        XCTAssert(stack.backgrounds.count == 3)
        XCTAssert(stack.backgrounds[0].identifier == backgroundIdentifier0)
        XCTAssert(stack.backgrounds[1].identifier == backgroundIdentifier1)
        XCTAssert(stack.backgrounds[2].identifier == backgroundIdentifier2)
        
        
    }
    
}
