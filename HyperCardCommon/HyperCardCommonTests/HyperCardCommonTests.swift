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
    
    /// Test interactions between stack, cards and backgrounds
    func testCardsBackgrounds() {
        
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
    
    /// Test security settings of the stacks
    func testSecurity() {
        
        /* Each time, check the file and the data */
        var path: String
        var file: HyperCardFile
        
        /* User Level 1 */
        path = Bundle(for: HyperCardCommonTests.self).path(forResource: "TestUserLevel1", ofType: "stack")!
        file = try! HyperCardFile(path: path)
        XCTAssert(file.parsedData.stack.userLevel == .browse)
        XCTAssert(file.stack.userLevel == .browse)
        
        /* User Level 5 */
        path = Bundle(for: HyperCardCommonTests.self).path(forResource: "TestUserLevel5", ofType: "stack")!
        file = try! HyperCardFile(path: path)
        XCTAssert(file.parsedData.stack.userLevel == .script)
        XCTAssert(file.stack.userLevel == .script)
        
        /* Can't Abort */
        path = Bundle(for: HyperCardCommonTests.self).path(forResource: "TestCantAbort", ofType: "stack")!
        file = try! HyperCardFile(path: path)
        XCTAssert(file.parsedData.stack.cantAbort)
        XCTAssert(file.stack.cantAbort)
        
        /* Can't Delete */
        path = Bundle(for: HyperCardCommonTests.self).path(forResource: "TestCantDelete", ofType: "stack")!
        file = try! HyperCardFile(path: path)
        XCTAssert(file.parsedData.stack.cantDelete)
        XCTAssert(file.stack.cantDelete)
        
        /* Can't Modify */
        path = Bundle(for: HyperCardCommonTests.self).path(forResource: "TestCantModify", ofType: "stack")!
        file = try! HyperCardFile(path: path)
        XCTAssert(file.parsedData.stack.cantModify)
        XCTAssert(file.stack.cantModify)
        
        /* Can't Peek */
        path = Bundle(for: HyperCardCommonTests.self).path(forResource: "TestCantPeek", ofType: "stack")!
        file = try! HyperCardFile(path: path)
        XCTAssert(file.parsedData.stack.cantPeek)
        XCTAssert(file.stack.cantPeek)
        
        /* Private Access */
        path = Bundle(for: HyperCardCommonTests.self).path(forResource: "TestPrivateAccess", ofType: "stack")!
        XCTAssertThrowsError(try HyperCardFile(path: path))
        XCTAssertThrowsError(try HyperCardFile(path: path, password: "false password"))
        XCTAssertNoThrow(try HyperCardFile(path: path, password: "AA éé 1234 ÀÂä"))
        XCTAssertNoThrow(try HyperCardFile(path: path, password: "AA ee 1234 AAa"))
        file = try! HyperCardFile(path: path, password: "AA éé 1234 ÀÂä")
        XCTAssert(file.parsedData.stack.privateAccess)
        XCTAssert(file.parsedData.stack.passwordHash != nil)
        XCTAssert(file.stack.privateAccess)
        XCTAssert(file.stack.passwordHash == file.parsedData.stack.passwordHash)
        
        /* Password without private access */
        path = Bundle(for: HyperCardCommonTests.self).path(forResource: "TestPassword", ofType: "stack")!
        XCTAssertNoThrow(try HyperCardFile(path: path))
        file = try! HyperCardFile(path: path)
        XCTAssert(file.parsedData.stack.passwordHash != nil)
        XCTAssert(file.stack.passwordHash == file.parsedData.stack.passwordHash)
        
        
        
    }
    
    /// Test versions of stacks
    func testVersion() {
        
        let path = Bundle(for: HyperCardCommonTests.self).path(forResource: "TestVersion", ofType: "stack")!
        let file = try! HyperCardFile(path: path)
        
        /* In HyperCard, result of "print the version of this stack":
         "02374001,02358000,02358000,02418000,<number of ticks since last edition>" */
        
        /* Check file */
        XCTAssert(file.parsedData.stack.versionAtCreation == Version(major: 2, minor1: 3, minor2: 7, state: .alpha, release: 1))
        XCTAssert(file.parsedData.stack.versionAtLastCompacting == Version(major: 2, minor1: 3, minor2: 5, state: .final, release: 0))
        XCTAssert(file.parsedData.stack.versionAtLastModificationSinceLastCompacting == Version(major: 2, minor1: 3, minor2: 5, state: .final, release: 0))
        XCTAssert(file.parsedData.stack.versionAtLastModification == Version(major: 2, minor1: 4, minor2: 1, state: .final, release: 0))
        
        /* Check data */
        XCTAssert(file.stack.versionAtCreation == file.parsedData.stack.versionAtCreation)
        XCTAssert(file.stack.versionAtLastCompacting == file.parsedData.stack.versionAtLastCompacting)
        XCTAssert(file.stack.versionAtLastModificationSinceLastCompacting == file.parsedData.stack.versionAtLastModificationSinceLastCompacting)
        XCTAssert(file.stack.versionAtLastModification == file.parsedData.stack.versionAtLastModification)
        
        
        
    }
    
}
