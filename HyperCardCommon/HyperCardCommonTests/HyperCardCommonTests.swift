//
//  HyperCardCommonTests.swift
//  HyperCardCommonTests
//
//  Created by Pierre Lorenzi on 24/08/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//

import XCTest
import HyperCardCommon

/// The tests in this class are performed with stacks created with HyperCard 2.4.1 final on emulated Mac OS 8.1
/// The data is checked against values given by HyperCard itself, not values read directly in the file. The
/// values can be read in the UI or by HyperTalk scripts.
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
        XCTAssert(stackBlock.markedCardCount == 2)
        
        /* Check CARD blocks */
        XCTAssert(file.parsedData.cards.count == 6)
        XCTAssert(file.parsedData.cards[0].identifier == cardIdentifier0)
        XCTAssert(file.parsedData.cards[0].backgroundIdentifier == backgroundIdentifier0)
        XCTAssert(file.parsedData.cards[0].isStartOfBackground == true)
        XCTAssert(file.parsedData.cards[0].marked == false)
        XCTAssert(file.parsedData.cards[1].identifier == cardIdentifier1)
        XCTAssert(file.parsedData.cards[1].backgroundIdentifier == backgroundIdentifier0)
        XCTAssert(file.parsedData.cards[1].isStartOfBackground == false)
        XCTAssert(file.parsedData.cards[1].marked == true)
        XCTAssert(file.parsedData.cards[2].identifier == cardIdentifier2)
        XCTAssert(file.parsedData.cards[2].backgroundIdentifier == backgroundIdentifier1)
        XCTAssert(file.parsedData.cards[2].isStartOfBackground == true)
        XCTAssert(file.parsedData.cards[2].marked == false)
        XCTAssert(file.parsedData.cards[3].identifier == cardIdentifier3)
        XCTAssert(file.parsedData.cards[3].backgroundIdentifier == backgroundIdentifier1)
        XCTAssert(file.parsedData.cards[3].isStartOfBackground == false)
        XCTAssert(file.parsedData.cards[3].marked == true)
        XCTAssert(file.parsedData.cards[4].identifier == cardIdentifier4)
        XCTAssert(file.parsedData.cards[4].backgroundIdentifier == backgroundIdentifier1)
        XCTAssert(file.parsedData.cards[4].isStartOfBackground == false)
        XCTAssert(file.parsedData.cards[4].marked == false)
        XCTAssert(file.parsedData.cards[5].identifier == cardIdentifier5)
        XCTAssert(file.parsedData.cards[5].backgroundIdentifier == backgroundIdentifier2)
        XCTAssert(file.parsedData.cards[5].isStartOfBackground == true)
        XCTAssert(file.parsedData.cards[5].marked == false)
        
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
        XCTAssert(stack.cards[0].marked == false)
        XCTAssert(stack.cards[1].identifier == cardIdentifier1)
        XCTAssert(stack.cards[1].background === stack.backgrounds[0])
        XCTAssert(stack.cards[1].marked == true)
        XCTAssert(stack.cards[2].identifier == cardIdentifier2)
        XCTAssert(stack.cards[2].background === stack.backgrounds[1])
        XCTAssert(stack.cards[2].marked == false)
        XCTAssert(stack.cards[3].identifier == cardIdentifier3)
        XCTAssert(stack.cards[3].background === stack.backgrounds[1])
        XCTAssert(stack.cards[3].marked == true)
        XCTAssert(stack.cards[4].identifier == cardIdentifier4)
        XCTAssert(stack.cards[4].background === stack.backgrounds[1])
        XCTAssert(stack.cards[4].marked == false)
        XCTAssert(stack.cards[5].identifier == cardIdentifier5)
        XCTAssert(stack.cards[5].background === stack.backgrounds[2])
        XCTAssert(stack.cards[5].marked == false)
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
    
    /// Test a stack with many cards so there are more than one page
    func testManyCards() {
        
        let path = Bundle(for: HyperCardCommonTests.self).path(forResource: "TestManyCards", ofType: "stack")!
        let file = try! HyperCardFile(path: path)
        
        let cardIdentifiers: [Int] = [
            2928,29104,29402,29579,29919,30161,30437,30554,30872,31217,31253,31697,31894,32111,32472,32516,32838,33200,33282,33767,34013,34081,34452,34677,35030,35107,35531,35624,36298,36607,36808,37050,37278,37619,37729,37900,38216,38410,38708,39131,39380,39518,39767,40037,40328,40637,40809,41151,41437,41643,41729,42016,42254,42539,42960,43061,43265,43678,43974,44241,44388,44590,44847,45258,45417,45634,45899,46203,46447,46596,46869,47323,47508,47685,47922,48379,48594,48734,49110,49273,49663,49821,50014,50397,50516,50806,51033,51436,51523,51941,52070,52682,52755,53230,53280,53595,53819,54053,54429,54753,54806,3662,3967,4152,4518,4785,4868,5327,5434,5688,6019,6360,6456,6833,7125,7298,7518,7740,8018,8232,8675,8854,8971,9447,9654,9742,10031,10378,10610,10956,11091,11502,11716,11854,12092,12400,12690,12858,13175,13495,13626,14035,14082,14411,14632,14870,15204,15507,15661,16028,16381,16502,16878,16976,17266,17416,17794,18003,18251,18512,18701,19134,19264,19587,19933,20192,20390,20698,20815,21227,21474,21564,21789,22129,22427,22686,22810,23195,23296,23694,23843,24211,24494,24813,25044,25276,25446,25709,25901,26351,26431,26759,26892,27356,27596,27804,28005,28284,28544,28851
        ]
        
        /* Check number of cards */
        XCTAssert(file.parsedData.stack.cardCount == cardIdentifiers.count)
        XCTAssert(file.parsedData.cards.count == cardIdentifiers.count)
        XCTAssert(file.stack.cards.count == cardIdentifiers.count)
        
        /* Check the identifiers of the cards */
        for i in 0..<file.parsedData.stack.cardCount {
            
            XCTAssert(file.parsedData.cards[i].identifier == cardIdentifiers[i])
            XCTAssert(file.stack.cards[i].identifier == cardIdentifiers[i])
        }
        
    }
    
    /// Test card window location
    func testWindowSize() {
        
        let path = Bundle(for: HyperCardCommonTests.self).path(forResource: "TestWindowSize", ofType: "stack")!
        let file = try! HyperCardFile(path: path)
        
        /* I couldn't test the scroll because it wasn't saved in HyperCard 2.4.1 */
        
        let cardSize = Size(width: 640, height: 480)
        let scroll = Point(x: 0, y: 0)
        let windowRectangle = Rectangle(top: 200, left: 272, bottom: 584, right: 848)
        let screenRectangle = Rectangle(top: 0, left: 0, bottom: 768, right: 1024)
        
        /* Check file */
        XCTAssert(file.parsedData.stack.size == cardSize)
        XCTAssert(file.parsedData.stack.scrollPoint == scroll)
        XCTAssert(file.parsedData.stack.windowRectangle == windowRectangle)
        XCTAssert(file.parsedData.stack.screenRectangle == screenRectangle)
        
        /* Check data */
        XCTAssert(file.stack.size == cardSize)
        
    }
    
    /// Test stack script
    func testStackScript() {
        
        let path = Bundle(for: HyperCardCommonTests.self).path(forResource: "TestStackScript", ofType: "stack")!
        let file = try! HyperCardFile(path: path)
        
        /* I couldn't test the scroll because it wasn't saved in HyperCard 2.4.1 */
        
        let script = "-- script of stack\r-- with two lines"
        
        /* Check file */
        XCTAssert(file.parsedData.stack.script == script)
        
        /* Check data */
        XCTAssert(file.stack.script == script)
        
    }
    
    /// Test the properties of cards
    func testCardProperties() {
        
        let path = Bundle(for: HyperCardCommonTests.self).path(forResource: "TestCardProperties", ofType: "stack")!
        let file = try! HyperCardFile(path: path)
        
        /* Can't Delete */
        XCTAssert(file.parsedData.cards[0].cantDelete == true)
        XCTAssert(file.stack.cards[0].cantDelete == true)
        
        /* Show Picture */
        XCTAssert(file.parsedData.cards[1].showPict == false)
        XCTAssert(file.stack.cards[1].showPict == false)
        
        /* Don't Search */
        XCTAssert(file.parsedData.cards[2].dontSearch == true)
        XCTAssert(file.stack.cards[2].dontSearch == true)
        
        /* Name */
        let name = "some card name"
        XCTAssert(file.parsedData.cards[3].name == name)
        XCTAssert(file.stack.cards[3].name == name)
        
        /* Script */
        let script = "-- card script"
        XCTAssert(file.parsedData.cards[4].script == script)
        XCTAssert(file.stack.cards[4].script == script)
        
    }
    
    /// Test the properties of backgrounds
    func testBackgroundProperties() {
        
        let path = Bundle(for: HyperCardCommonTests.self).path(forResource: "TestBackgroundProperties", ofType: "stack")!
        let file = try! HyperCardFile(path: path)
        
        /* Can't Delete */
        XCTAssert(file.parsedData.backgrounds[0].cantDelete == true)
        XCTAssert(file.stack.backgrounds[0].cantDelete == true)
        
        /* Show Picture */
        XCTAssert(file.parsedData.backgrounds[1].showPict == false)
        XCTAssert(file.stack.backgrounds[1].showPict == false)
        
        /* Don't Search */
        XCTAssert(file.parsedData.backgrounds[2].dontSearch == true)
        XCTAssert(file.stack.backgrounds[2].dontSearch == true)
        
        /* Name */
        let name = "some background name"
        XCTAssert(file.parsedData.backgrounds[3].name == name)
        XCTAssert(file.stack.backgrounds[3].name == name)
        
        /* Script */
        let script = "-- background script"
        XCTAssert(file.parsedData.backgrounds[4].script == script)
        XCTAssert(file.stack.backgrounds[4].script == script)
        
    }
    
}
