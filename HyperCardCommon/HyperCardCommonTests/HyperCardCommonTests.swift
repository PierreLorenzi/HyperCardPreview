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
        let stackBlock = file.extractParsedData().extractStack()
        
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
        XCTAssert(stackBlock.readCardCount() == 6)
        XCTAssert(stackBlock.readFirstCardIdentifier() == cardIdentifier0)
        XCTAssert(stackBlock.readBackgroundCount() == 3)
        XCTAssert(stackBlock.readFirstBackgroundIdentifier() == backgroundIdentifier0)
        XCTAssert(stackBlock.readMarkedCardCount() == 2)
        
        /* Check CARD blocks */
        XCTAssert(file.extractParsedData().extractCards().count == 6)
        XCTAssert(file.extractParsedData().extractCards()[0].readIdentifier() == cardIdentifier0)
        XCTAssert(file.extractParsedData().extractCards()[0].backgroundIdentifier == backgroundIdentifier0)
        XCTAssert(file.extractParsedData().extractCards()[0].isStartOfBackground == true)
        XCTAssert(file.extractParsedData().extractCards()[0].marked == false)
        XCTAssert(file.extractParsedData().extractCards()[1].readIdentifier() == cardIdentifier1)
        XCTAssert(file.extractParsedData().extractCards()[1].backgroundIdentifier == backgroundIdentifier0)
        XCTAssert(file.extractParsedData().extractCards()[1].isStartOfBackground == false)
        XCTAssert(file.extractParsedData().extractCards()[1].marked == true)
        XCTAssert(file.extractParsedData().extractCards()[2].readIdentifier() == cardIdentifier2)
        XCTAssert(file.extractParsedData().extractCards()[2].backgroundIdentifier == backgroundIdentifier1)
        XCTAssert(file.extractParsedData().extractCards()[2].isStartOfBackground == true)
        XCTAssert(file.extractParsedData().extractCards()[2].marked == false)
        XCTAssert(file.extractParsedData().extractCards()[3].readIdentifier() == cardIdentifier3)
        XCTAssert(file.extractParsedData().extractCards()[3].backgroundIdentifier == backgroundIdentifier1)
        XCTAssert(file.extractParsedData().extractCards()[3].isStartOfBackground == false)
        XCTAssert(file.extractParsedData().extractCards()[3].marked == true)
        XCTAssert(file.extractParsedData().extractCards()[4].readIdentifier() == cardIdentifier4)
        XCTAssert(file.extractParsedData().extractCards()[4].backgroundIdentifier == backgroundIdentifier1)
        XCTAssert(file.extractParsedData().extractCards()[4].isStartOfBackground == false)
        XCTAssert(file.extractParsedData().extractCards()[4].marked == false)
        XCTAssert(file.extractParsedData().extractCards()[5].readIdentifier() == cardIdentifier5)
        XCTAssert(file.extractParsedData().extractCards()[5].backgroundIdentifier == backgroundIdentifier2)
        XCTAssert(file.extractParsedData().extractCards()[5].isStartOfBackground == true)
        XCTAssert(file.extractParsedData().extractCards()[5].marked == false)
        
        /* Check BKGD blocks */
        XCTAssert(file.extractParsedData().extractBackgrounds().count == 3)
        XCTAssert(file.extractParsedData().extractBackgrounds()[0].readIdentifier() == backgroundIdentifier0)
        XCTAssert(file.extractParsedData().extractBackgrounds()[0].cardCount == 2)
        XCTAssert(file.extractParsedData().extractBackgrounds()[0].nextBackgroundIdentifier == backgroundIdentifier1)
        XCTAssert(file.extractParsedData().extractBackgrounds()[0].previousBackgroundIdentifier == backgroundIdentifier2)
        XCTAssert(file.extractParsedData().extractBackgrounds()[1].readIdentifier() == backgroundIdentifier1)
        XCTAssert(file.extractParsedData().extractBackgrounds()[1].cardCount == 3)
        XCTAssert(file.extractParsedData().extractBackgrounds()[1].nextBackgroundIdentifier == backgroundIdentifier2)
        XCTAssert(file.extractParsedData().extractBackgrounds()[1].previousBackgroundIdentifier == backgroundIdentifier0)
        XCTAssert(file.extractParsedData().extractBackgrounds()[2].readIdentifier() == backgroundIdentifier2)
        XCTAssert(file.extractParsedData().extractBackgrounds()[2].cardCount == 1)
        XCTAssert(file.extractParsedData().extractBackgrounds()[2].nextBackgroundIdentifier == backgroundIdentifier0)
        XCTAssert(file.extractParsedData().extractBackgrounds()[2].previousBackgroundIdentifier == backgroundIdentifier1)
        
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
    
    /// Test the free size setting of stacks
    func testFreeSize() {
        
        let path = Bundle(for: HyperCardCommonTests.self).path(forResource: "TestFreeSize", ofType: "stack")!
        let file = try! HyperCardFile(path: path)
        
        XCTAssert(file.extractParsedData().extractStack().readFreeSize() == 3232)
        
    }
    
    /// Test security settings of the stacks
    func testSecurity() {
        
        /* Each time, check the file and the data */
        var path: String
        var file: HyperCardFile
        
        /* User Level 1 */
        path = Bundle(for: HyperCardCommonTests.self).path(forResource: "TestUserLevel1", ofType: "stack")!
        file = try! HyperCardFile(path: path)
        XCTAssert(file.extractParsedData().extractStack().readUserLevel() == .browse)
        XCTAssert(file.stack.userLevel == .browse)
        
        /* User Level 5 */
        path = Bundle(for: HyperCardCommonTests.self).path(forResource: "TestUserLevel5", ofType: "stack")!
        file = try! HyperCardFile(path: path)
        XCTAssert(file.extractParsedData().extractStack().readUserLevel() == .script)
        XCTAssert(file.stack.userLevel == .script)
        
        /* Can't Abort */
        path = Bundle(for: HyperCardCommonTests.self).path(forResource: "TestCantAbort", ofType: "stack")!
        file = try! HyperCardFile(path: path)
        XCTAssert(file.extractParsedData().extractStack().readCantAbort())
        XCTAssert(file.stack.cantAbort)
        
        /* Can't Delete */
        path = Bundle(for: HyperCardCommonTests.self).path(forResource: "TestCantDelete", ofType: "stack")!
        file = try! HyperCardFile(path: path)
        XCTAssert(file.extractParsedData().extractStack().readCantDelete())
        XCTAssert(file.stack.cantDelete)
        
        /* Can't Modify */
        path = Bundle(for: HyperCardCommonTests.self).path(forResource: "TestCantModify", ofType: "stack")!
        file = try! HyperCardFile(path: path)
        XCTAssert(file.extractParsedData().extractStack().readCantModify())
        XCTAssert(file.stack.cantModify)
        
        /* Can't Peek */
        path = Bundle(for: HyperCardCommonTests.self).path(forResource: "TestCantPeek", ofType: "stack")!
        file = try! HyperCardFile(path: path)
        XCTAssert(file.extractParsedData().extractStack().readCantPeek())
        XCTAssert(file.stack.cantPeek)
        
        /* Private Access */
        path = Bundle(for: HyperCardCommonTests.self).path(forResource: "TestPrivateAccess", ofType: "stack")!
        XCTAssertNoThrow(try HyperCardFile(path: path, password: "AA éé 1234 ÀÂä"))
        XCTAssertNoThrow(try HyperCardFile(path: path, password: "AA ee 1234 AAa"))
        file = try! HyperCardFile(path: path, password: "AA éé 1234 ÀÂä")
        XCTAssert(file.extractParsedData().extractStack().readPrivateAccess())
        XCTAssert(file.extractParsedData().extractStack().readPasswordHash() != nil)
        XCTAssert(file.stack.privateAccess)
        XCTAssert(file.stack.passwordHash == file.extractParsedData().extractStack().readPasswordHash())
        
        /* Password without private access */
        path = Bundle(for: HyperCardCommonTests.self).path(forResource: "TestPassword", ofType: "stack")!
        XCTAssertNoThrow(try HyperCardFile(path: path))
        file = try! HyperCardFile(path: path)
        XCTAssert(file.extractParsedData().extractStack().readPasswordHash() != nil)
        XCTAssert(file.stack.passwordHash == file.extractParsedData().extractStack().readPasswordHash())
        
        
        
    }
    
    /// Test versions of stacks
    func testVersion() {
        
        let path = Bundle(for: HyperCardCommonTests.self).path(forResource: "TestVersion", ofType: "stack")!
        let file = try! HyperCardFile(path: path)
        
        /* In HyperCard, result of "print the version of this stack":
         "02374001,02358000,02358000,02418000,<number of ticks since last edition>" */
        
        /* Check file */
        XCTAssert(file.extractParsedData().extractStack().readVersionAtCreation() == Version(major: 2, minor1: 3, minor2: 7, state: .alpha, release: 1))
        XCTAssert(file.extractParsedData().extractStack().readVersionAtLastCompacting() == Version(major: 2, minor1: 3, minor2: 5, state: .final, release: 0))
        XCTAssert(file.extractParsedData().extractStack().readVersionAtLastModificationSinceLastCompacting() == Version(major: 2, minor1: 3, minor2: 5, state: .final, release: 0))
        XCTAssert(file.extractParsedData().extractStack().readVersionAtLastModification() == Version(major: 2, minor1: 4, minor2: 1, state: .final, release: 0))
        
        /* Check data */
        XCTAssert(file.stack.versionAtCreation == file.extractParsedData().extractStack().readVersionAtCreation())
        XCTAssert(file.stack.versionAtLastCompacting == file.extractParsedData().extractStack().readVersionAtLastCompacting())
        XCTAssert(file.stack.versionAtLastModificationSinceLastCompacting == file.extractParsedData().extractStack().readVersionAtLastModificationSinceLastCompacting())
        XCTAssert(file.stack.versionAtLastModification == file.extractParsedData().extractStack().readVersionAtLastModification())
        
        
        
    }
    
    /// Test a stack with many cards so there are more than one page
    func testManyCards() {
        
        let path = Bundle(for: HyperCardCommonTests.self).path(forResource: "TestManyCards", ofType: "stack")!
        let file = try! HyperCardFile(path: path)
        
        let cardIdentifiers: [Int] = [
            2928,29104,29402,29579,29919,30161,30437,30554,30872,31217,31253,31697,31894,32111,32472,32516,32838,33200,33282,33767,34013,34081,34452,34677,35030,35107,35531,35624,36298,36607,36808,37050,37278,37619,37729,37900,38216,38410,38708,39131,39380,39518,39767,40037,40328,40637,40809,41151,41437,41643,41729,42016,42254,42539,42960,43061,43265,43678,43974,44241,44388,44590,44847,45258,45417,45634,45899,46203,46447,46596,46869,47323,47508,47685,47922,48379,48594,48734,49110,49273,49663,49821,50014,50397,50516,50806,51033,51436,51523,51941,52070,52682,52755,53230,53280,53595,53819,54053,54429,54753,54806,3662,3967,4152,4518,4785,4868,5327,5434,5688,6019,6360,6456,6833,7125,7298,7518,7740,8018,8232,8675,8854,8971,9447,9654,9742,10031,10378,10610,10956,11091,11502,11716,11854,12092,12400,12690,12858,13175,13495,13626,14035,14082,14411,14632,14870,15204,15507,15661,16028,16381,16502,16878,16976,17266,17416,17794,18003,18251,18512,18701,19134,19264,19587,19933,20192,20390,20698,20815,21227,21474,21564,21789,22129,22427,22686,22810,23195,23296,23694,23843,24211,24494,24813,25044,25276,25446,25709,25901,26351,26431,26759,26892,27356,27596,27804,28005,28284,28544,28851
        ]
        
        /* Check number of cards */
        XCTAssert(file.extractParsedData().extractStack().readCardCount() == cardIdentifiers.count)
        XCTAssert(file.extractParsedData().extractCards().count == cardIdentifiers.count)
        XCTAssert(file.stack.cards.count == cardIdentifiers.count)
        
        /* Check the identifiers of the cards */
        for i in 0..<file.extractParsedData().extractStack().readCardCount() {
            
            XCTAssert(file.extractParsedData().extractCards()[i].readIdentifier() == cardIdentifiers[i])
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
        XCTAssert(file.extractParsedData().extractStack().readSize() == cardSize)
        XCTAssert(file.extractParsedData().extractStack().readScrollPoint() == scroll)
        XCTAssert(file.extractParsedData().extractStack().readWindowRectangle() == windowRectangle)
        XCTAssert(file.extractParsedData().extractStack().readScreenRectangle() == screenRectangle)
        
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
        XCTAssert(file.extractParsedData().extractStack().readScript() == script)
        
        /* Check data */
        XCTAssert(file.stack.script == script)
        
    }
    
    /// Test the properties of cards
    func testCardProperties() {
        
        let path = Bundle(for: HyperCardCommonTests.self).path(forResource: "TestCardProperties", ofType: "stack")!
        let file = try! HyperCardFile(path: path)
        
        /* Can't Delete */
        XCTAssert(file.extractParsedData().extractCards()[0].cantDelete == true)
        XCTAssert(file.stack.cards[0].cantDelete == true)
        XCTAssert(file.extractParsedData().extractCards()[1].cantDelete == false)
        XCTAssert(file.stack.cards[1].cantDelete == false)
        
        /* Show Picture */
        XCTAssert(file.extractParsedData().extractCards()[1].showPict == false)
        XCTAssert(file.stack.cards[1].showPict == false)
        XCTAssert(file.extractParsedData().extractCards()[2].showPict == true)
        XCTAssert(file.stack.cards[2].showPict == true)
        
        /* Don't Search */
        XCTAssert(file.extractParsedData().extractCards()[2].dontSearch == true)
        XCTAssert(file.stack.cards[2].dontSearch == true)
        XCTAssert(file.extractParsedData().extractCards()[3].dontSearch == false)
        XCTAssert(file.stack.cards[3].dontSearch == false)
        
        /* Name */
        let name = "some card name"
        XCTAssert(file.extractParsedData().extractCards()[3].name == name)
        XCTAssert(file.stack.cards[3].name == name)
        
        /* Script */
        let script = "-- card script"
        XCTAssert(file.extractParsedData().extractCards()[4].script == script)
        XCTAssert(file.stack.cards[4].script == script)
        
    }
    
    /// Test the properties of backgrounds
    func testBackgroundProperties() {
        
        let path = Bundle(for: HyperCardCommonTests.self).path(forResource: "TestBackgroundProperties", ofType: "stack")!
        let file = try! HyperCardFile(path: path)
        
        /* Can't Delete */
        XCTAssert(file.extractParsedData().extractBackgrounds()[0].cantDelete == true)
        XCTAssert(file.stack.backgrounds[0].cantDelete == true)
        XCTAssert(file.extractParsedData().extractBackgrounds()[1].cantDelete == false)
        XCTAssert(file.stack.backgrounds[1].cantDelete == false)
        
        /* Show Picture */
        XCTAssert(file.extractParsedData().extractBackgrounds()[1].showPict == false)
        XCTAssert(file.stack.backgrounds[1].showPict == false)
        XCTAssert(file.extractParsedData().extractBackgrounds()[2].showPict == true)
        XCTAssert(file.stack.backgrounds[2].showPict == true)
        
        /* Don't Search */
        XCTAssert(file.extractParsedData().extractBackgrounds()[2].dontSearch == true)
        XCTAssert(file.stack.backgrounds[2].dontSearch == true)
        XCTAssert(file.extractParsedData().extractBackgrounds()[3].dontSearch == false)
        XCTAssert(file.stack.backgrounds[3].dontSearch == false)
        
        /* Name */
        let name = "some background name"
        XCTAssert(file.extractParsedData().extractBackgrounds()[3].name == name)
        XCTAssert(file.stack.backgrounds[3].name == name)
        
        /* Script */
        let script = "-- background script"
        XCTAssert(file.extractParsedData().extractBackgrounds()[4].script == script)
        XCTAssert(file.stack.backgrounds[4].script == script)
        
    }
    
    /// Test the properties of buttons
    func testButtonProperties() {
        
        let path = Bundle(for: HyperCardCommonTests.self).path(forResource: "TestButtonProperties", ofType: "stack")!
        let file = try! HyperCardFile(path: path)
        
        /* General properties */
        
        /* Identifier */
        XCTAssert(file.extractParsedData().extractBackgrounds()[0].parts[0].identifier == 1)
        XCTAssert(file.stack.backgrounds[0].buttons[0].identifier == 1)
        XCTAssert(file.extractParsedData().extractBackgrounds()[0].parts[1].identifier == 2)
        XCTAssert(file.stack.backgrounds[0].buttons[1].identifier == 2)
        
        /* Enabled */
        XCTAssert(file.extractParsedData().extractBackgrounds()[0].parts[1].enabled == false)
        XCTAssert(file.stack.backgrounds[0].buttons[1].enabled == false)
        XCTAssert(file.extractParsedData().extractBackgrounds()[0].parts[2].enabled == true)
        XCTAssert(file.stack.backgrounds[0].buttons[2].enabled == true)
        
        /* Visible */
        XCTAssert(file.extractParsedData().extractBackgrounds()[0].parts[2].visible == false)
        XCTAssert(file.stack.backgrounds[0].buttons[2].visible == false)
        XCTAssert(file.extractParsedData().extractBackgrounds()[0].parts[3].visible == true)
        XCTAssert(file.stack.backgrounds[0].buttons[3].visible == true)
        
        /* Rectangle */
        let rectangle = Rectangle(top: 188, left: 44, bottom: 210, right: 139)
        XCTAssert(file.extractParsedData().extractBackgrounds()[0].parts[3].rectangle == rectangle)
        XCTAssert(file.stack.backgrounds[0].buttons[3].rectangle == rectangle)
        
        /* Family */
        XCTAssert(file.extractParsedData().extractBackgrounds()[0].parts[4].family == 6)
        XCTAssert(file.stack.backgrounds[0].buttons[4].family == 6)
        
        /* Shared Hilite */
        XCTAssert(file.extractParsedData().extractBackgrounds()[0].parts[5].sharedHilite == false)
        XCTAssert(file.stack.backgrounds[0].buttons[5].sharedHilite == false)
        XCTAssert(file.extractParsedData().extractBackgrounds()[0].parts[6].sharedHilite == true)
        XCTAssert(file.stack.backgrounds[0].buttons[6].sharedHilite == true)
        
        /* Auto Hilite */
        XCTAssert(file.extractParsedData().extractBackgrounds()[0].parts[6].autoHilite == true)
        XCTAssert(file.stack.backgrounds[0].buttons[6].autoHilite == true)
        XCTAssert(file.extractParsedData().extractBackgrounds()[0].parts[7].autoHilite == false)
        XCTAssert(file.stack.backgrounds[0].buttons[7].autoHilite == false)
        
        /* Hilite */
        XCTAssert(file.extractParsedData().extractBackgrounds()[0].parts[7].hilite == true)
        XCTAssert(file.stack.backgrounds[0].buttons[7].hilite == true)
        XCTAssert(file.extractParsedData().extractBackgrounds()[0].parts[8].hilite == false)
        XCTAssert(file.stack.backgrounds[0].buttons[8].hilite == false)
        
        /* Show Name */
        XCTAssert(file.extractParsedData().extractBackgrounds()[0].parts[8].showName == false)
        XCTAssert(file.stack.backgrounds[0].buttons[8].showName == false)
        XCTAssert(file.extractParsedData().extractBackgrounds()[0].parts[9].showName == true)
        XCTAssert(file.stack.backgrounds[0].buttons[9].showName == true)
        
        /* Icon */
        XCTAssert(file.extractParsedData().extractBackgrounds()[0].parts[9].icon == 30504)
        XCTAssert(file.stack.backgrounds[0].buttons[9].iconIdentifier == 30504)
        
        /* Name */
        let name = "some button name"
        XCTAssert(file.extractParsedData().extractBackgrounds()[0].parts[10].name == name)
        XCTAssert(file.stack.backgrounds[0].buttons[10].name == name)
        
        /* Script */
        let script = "-- some button script"
        XCTAssert(file.extractParsedData().extractBackgrounds()[0].parts[11].script == script)
        XCTAssert(file.stack.backgrounds[0].buttons[11].script == script)
        
        /* Content */
        let content = "some button content"
        XCTAssert(file.extractParsedData().extractBackgrounds()[0].contents[0].string == content)
        XCTAssert(file.stack.backgrounds[0].buttons[12].content == content)
        
        /* Pop-up properties */
        
        /* Popup selected item */
        XCTAssert(file.extractParsedData().extractBackgrounds()[1].parts[0].selectedLine == 3)
        XCTAssert(file.stack.backgrounds[1].buttons[0].selectedItem == 3)
        
        /* Popup selected item */
        let titleWidth = 23
        XCTAssert(file.extractParsedData().extractBackgrounds()[1].parts[1].titleWidth == titleWidth)
        XCTAssert(file.stack.backgrounds[1].buttons[1].titleWidth == titleWidth)
        
        /* Style */
        XCTAssert(file.extractParsedData().extractBackgrounds()[2].parts[0].style == .transparent)
        XCTAssert(file.stack.backgrounds[2].buttons[0].style == .transparent)
        XCTAssert(file.extractParsedData().extractBackgrounds()[2].parts[1].style == .opaque)
        XCTAssert(file.stack.backgrounds[2].buttons[1].style == .opaque)
        XCTAssert(file.extractParsedData().extractBackgrounds()[2].parts[2].style == .rectangle)
        XCTAssert(file.stack.backgrounds[2].buttons[2].style == .rectangle)
        XCTAssert(file.extractParsedData().extractBackgrounds()[2].parts[3].style == .shadow)
        XCTAssert(file.stack.backgrounds[2].buttons[3].style == .shadow)
        XCTAssert(file.extractParsedData().extractBackgrounds()[2].parts[4].style == .checkBox)
        XCTAssert(file.stack.backgrounds[2].buttons[4].style == .checkBox)
        XCTAssert(file.extractParsedData().extractBackgrounds()[2].parts[5].style == .radio)
        XCTAssert(file.stack.backgrounds[2].buttons[5].style == .radio)
        XCTAssert(file.extractParsedData().extractBackgrounds()[2].parts[6].style == .standard)
        XCTAssert(file.stack.backgrounds[2].buttons[6].style == .standard)
        XCTAssert(file.extractParsedData().extractBackgrounds()[2].parts[7].style == .`default`)
        XCTAssert(file.stack.backgrounds[2].buttons[7].style == .`default`)
        XCTAssert(file.extractParsedData().extractBackgrounds()[2].parts[8].style == .oval)
        XCTAssert(file.stack.backgrounds[2].buttons[8].style == .oval)
        XCTAssert(file.extractParsedData().extractBackgrounds()[2].parts[9].style == .popup)
        XCTAssert(file.stack.backgrounds[2].buttons[9].style == .popup)
        XCTAssert(file.extractParsedData().extractBackgrounds()[2].parts[10].style == .roundRect)
        XCTAssert(file.stack.backgrounds[2].buttons[10].style == .roundRect)
        
        /* Text properties */
        
        /* Style */
        let textStyle = TextStyle(bold: true, italic: false, underline: true, outline: false, shadow: true, condense: false, extend: true, group: false)
        XCTAssert(file.extractParsedData().extractBackgrounds()[3].parts[0].textStyle == textStyle)
        XCTAssert(file.stack.backgrounds[3].buttons[0].textStyle == textStyle)
        
        /* Font */
        XCTAssert(file.extractParsedData().extractBackgrounds()[3].parts[1].textFontIdentifier == FontIdentifiers.geneva)
        XCTAssert(file.stack.backgrounds[3].buttons[1].textFontIdentifier == FontIdentifiers.geneva)
        
        /* Size */
        XCTAssert(file.extractParsedData().extractBackgrounds()[3].parts[2].textFontSize == 17)
        XCTAssert(file.stack.backgrounds[3].buttons[2].textFontSize == 17)
        
        /* Alignment */
        XCTAssert(file.extractParsedData().extractBackgrounds()[3].parts[3].textAlign == .left)
        XCTAssert(file.stack.backgrounds[3].buttons[3].textAlign == .left)
        XCTAssert(file.extractParsedData().extractBackgrounds()[3].parts[4].textAlign == .center)
        XCTAssert(file.stack.backgrounds[3].buttons[4].textAlign == .center)
        XCTAssert(file.extractParsedData().extractBackgrounds()[3].parts[5].textAlign == .right)
        XCTAssert(file.stack.backgrounds[3].buttons[5].textAlign == .right)
        
        
    }
    
    /// Test the properties of fields
    func testFieldProperties() {
        
        let path = Bundle(for: HyperCardCommonTests.self).path(forResource: "TestFieldProperties", ofType: "stack")!
        let file = try! HyperCardFile(path: path)
        
        /* General properties */
        
        /* Identifier */
        XCTAssert(file.extractParsedData().extractBackgrounds()[0].parts[0].identifier == 5)
        XCTAssert(file.stack.backgrounds[0].fields[0].identifier == 5)
        XCTAssert(file.extractParsedData().extractBackgrounds()[0].parts[1].identifier == 6)
        XCTAssert(file.stack.backgrounds[0].fields[1].identifier == 6)
        
        /* Lock Text */
        XCTAssert(file.extractParsedData().extractBackgrounds()[0].parts[1].lockText == true)
        XCTAssert(file.stack.backgrounds[0].fields[1].lockText == true)
        XCTAssert(file.extractParsedData().extractBackgrounds()[0].parts[2].lockText == false)
        XCTAssert(file.stack.backgrounds[0].fields[2].lockText == false)
        
        /* Auto Tab */
        XCTAssert(file.extractParsedData().extractBackgrounds()[0].parts[2].autoTab == true)
        XCTAssert(file.stack.backgrounds[0].fields[2].autoTab == true)
        XCTAssert(file.extractParsedData().extractBackgrounds()[0].parts[3].autoTab == false)
        XCTAssert(file.stack.backgrounds[0].fields[3].autoTab == false)
        
        /* Fixed Line Height */
        XCTAssert(file.extractParsedData().extractBackgrounds()[0].parts[3].fixedLineHeight == true)
        XCTAssert(file.stack.backgrounds[0].fields[3].fixedLineHeight == true)
        XCTAssert(file.extractParsedData().extractBackgrounds()[0].parts[4].fixedLineHeight == false)
        XCTAssert(file.stack.backgrounds[0].fields[4].fixedLineHeight == false)
        
        /* Shared Text */
        XCTAssert(file.extractParsedData().extractBackgrounds()[0].parts[4].sharedText == true)
        XCTAssert(file.stack.backgrounds[0].fields[4].sharedText == true)
        XCTAssert(file.extractParsedData().extractBackgrounds()[0].parts[5].sharedText == false)
        XCTAssert(file.stack.backgrounds[0].fields[5].sharedText == false)
        
        /* Don't Search */
        XCTAssert(file.extractParsedData().extractBackgrounds()[0].parts[5].dontSearch == true)
        XCTAssert(file.stack.backgrounds[0].fields[5].dontSearch == true)
        XCTAssert(file.extractParsedData().extractBackgrounds()[0].parts[6].dontSearch == false)
        XCTAssert(file.stack.backgrounds[0].fields[6].dontSearch == false)
        
        /* Don't Wrap */
        XCTAssert(file.extractParsedData().extractBackgrounds()[0].parts[6].dontWrap == true)
        XCTAssert(file.stack.backgrounds[0].fields[6].dontWrap == true)
        XCTAssert(file.extractParsedData().extractBackgrounds()[0].parts[7].dontWrap == false)
        XCTAssert(file.stack.backgrounds[0].fields[7].dontWrap == false)
        
        /* Visible */
        XCTAssert(file.extractParsedData().extractBackgrounds()[0].parts[7].visible == false)
        XCTAssert(file.stack.backgrounds[0].fields[7].visible == false)
        XCTAssert(file.extractParsedData().extractBackgrounds()[0].parts[8].visible == true)
        XCTAssert(file.stack.backgrounds[0].fields[8].visible == true)
        
        /* Rectangle */
        let rectangle = Rectangle(top: 210, left: 271, bottom: 238, right: 446)
        XCTAssert(file.extractParsedData().extractBackgrounds()[0].parts[8].rectangle == rectangle)
        XCTAssert(file.stack.backgrounds[0].fields[8].rectangle == rectangle)
        
        /* Multiple Lines */
        XCTAssert(file.extractParsedData().extractBackgrounds()[0].parts[9].multipleLines == true)
        XCTAssert(file.stack.backgrounds[0].fields[9].multipleLines == true)
        XCTAssert(file.extractParsedData().extractBackgrounds()[0].parts[8].multipleLines == false)
        XCTAssert(file.stack.backgrounds[0].fields[8].multipleLines == false)
        
        /* Wide Margins */
        XCTAssert(file.extractParsedData().extractBackgrounds()[1].parts[0].wideMargins == true)
        XCTAssert(file.stack.backgrounds[1].fields[0].wideMargins == true)
        XCTAssert(file.extractParsedData().extractBackgrounds()[1].parts[1].wideMargins == false)
        XCTAssert(file.stack.backgrounds[1].fields[1].wideMargins == false)
        
        /* Show Lines */
        XCTAssert(file.extractParsedData().extractBackgrounds()[1].parts[1].showLines == true)
        XCTAssert(file.stack.backgrounds[1].fields[1].showLines == true)
        XCTAssert(file.extractParsedData().extractBackgrounds()[1].parts[2].showLines == false)
        XCTAssert(file.stack.backgrounds[1].fields[2].showLines == false)
        
        /* Auto Select */
        XCTAssert(file.extractParsedData().extractBackgrounds()[1].parts[2].autoSelect == true)
        XCTAssert(file.stack.backgrounds[1].fields[2].autoSelect == true)
        XCTAssert(file.extractParsedData().extractBackgrounds()[1].parts[1].autoSelect == false)
        XCTAssert(file.stack.backgrounds[1].fields[1].autoSelect == false)
        
        /* Selected Lines */
        XCTAssert(file.extractParsedData().extractBackgrounds()[1].parts[3].selectedLine == 2)
        XCTAssert(file.stack.backgrounds[1].fields[3].selectedLine == 2)
        XCTAssert(file.extractParsedData().extractBackgrounds()[1].parts[3].lastSelectedLine == 5)
        XCTAssert(file.stack.backgrounds[1].fields[3].lastSelectedLine == 5)
        
        /* Name */
        let name = "some field name"
        XCTAssert(file.extractParsedData().extractBackgrounds()[1].parts[4].name == name)
        XCTAssert(file.stack.backgrounds[1].fields[4].name == name)
        
        /* Script */
        let script = "-- some field script"
        XCTAssert(file.extractParsedData().extractBackgrounds()[1].parts[5].script == script)
        XCTAssert(file.stack.backgrounds[1].fields[5].script == script)
        
        /* Text properties */
        
        /* Style */
        let textStyle = TextStyle(bold: false, italic: true, underline: false, outline: true, shadow: false, condense: true, extend: false, group: true)
        XCTAssert(file.extractParsedData().extractBackgrounds()[2].parts[0].textStyle == textStyle)
        XCTAssert(file.stack.backgrounds[2].fields[0].textStyle == textStyle)
        
        /* Font */
        XCTAssert(file.extractParsedData().extractBackgrounds()[2].parts[1].textFontIdentifier == FontIdentifiers.palatino)
        XCTAssert(file.stack.backgrounds[2].fields[1].textFontIdentifier == FontIdentifiers.palatino)
        
        /* Size */
        XCTAssert(file.extractParsedData().extractBackgrounds()[2].parts[2].textFontSize == 17)
        XCTAssert(file.stack.backgrounds[2].fields[2].textFontSize == 17)
        
        /* Alignment */
        XCTAssert(file.extractParsedData().extractBackgrounds()[2].parts[3].textAlign == .left)
        XCTAssert(file.stack.backgrounds[2].fields[3].textAlign == .left)
        XCTAssert(file.extractParsedData().extractBackgrounds()[2].parts[4].textAlign == .center)
        XCTAssert(file.stack.backgrounds[2].fields[4].textAlign == .center)
        XCTAssert(file.extractParsedData().extractBackgrounds()[2].parts[5].textAlign == .right)
        XCTAssert(file.stack.backgrounds[2].fields[5].textAlign == .right)
        
        /* Line Height */
        XCTAssert(file.extractParsedData().extractBackgrounds()[2].parts[6].textHeight == 21)
        XCTAssert(file.stack.backgrounds[2].fields[6].textHeight == 21)
        
        /* Styles */
        XCTAssert(file.extractParsedData().extractBackgrounds()[3].parts[0].style == .transparent)
        XCTAssert(file.stack.backgrounds[3].fields[0].style == .transparent)
        XCTAssert(file.extractParsedData().extractBackgrounds()[3].parts[1].style == .opaque)
        XCTAssert(file.stack.backgrounds[3].fields[1].style == .opaque)
        XCTAssert(file.extractParsedData().extractBackgrounds()[3].parts[2].style == .rectangle)
        XCTAssert(file.stack.backgrounds[3].fields[2].style == .rectangle)
        XCTAssert(file.extractParsedData().extractBackgrounds()[3].parts[3].style == .shadow)
        XCTAssert(file.stack.backgrounds[3].fields[3].style == .shadow)
        XCTAssert(file.extractParsedData().extractBackgrounds()[3].parts[4].style == .scrolling)
        XCTAssert(file.stack.backgrounds[3].fields[4].style == .scrolling)
        
        
    }
    
    /// Test the distribution of the text contents between cards and backgrounds
    func testContents() {
        
        let path = Bundle(for: HyperCardCommonTests.self).path(forResource: "TestContents", ofType: "stack")!
        let file = try! HyperCardFile(path: path)
        
        /* Shared contents in file */
        XCTAssert(file.extractParsedData().extractBackgrounds()[0].contentCount == 1)
        XCTAssert(file.extractParsedData().extractBackgrounds()[0].contents.count == 1)
        XCTAssert(file.extractParsedData().extractBackgrounds()[0].contents[0].identifier == 2)
        XCTAssert(file.extractParsedData().extractBackgrounds()[0].contents[0].string == "shared content")
        XCTAssert(file.extractParsedData().extractBackgrounds()[0].parts[2].hilite == false)
        XCTAssert(file.extractParsedData().extractBackgrounds()[0].parts[3].hilite == true)
        
        /* Shared contents in data */
        if case let PartContent.string(string) = file.stack.backgrounds[0].fields[0].content, string == "" {
        }
        else {
            XCTFail()
        }
        if case let PartContent.string(string) = file.stack.backgrounds[0].fields[1].content, string == "shared content" {
        }
        else {
            XCTFail()
        }
        XCTAssert(file.stack.backgrounds[0].buttons[0].hilite == false)
        XCTAssert(file.stack.backgrounds[0].buttons[1].hilite == true)
        
        /* Card contents */
        XCTAssert(file.extractParsedData().extractCards()[0].contentCount == 3)
        XCTAssert(file.extractParsedData().extractCards()[0].contents.count == 3)
        for content in file.extractParsedData().extractCards()[0].contents {
            switch (content.identifier, content.layerType) {
            case (1, .background):
                XCTAssert(content.string == "card content in bg field")
            case (3, .background):
                XCTAssert(content.string == "1")
            case (1, .card):
                XCTAssert(content.string == "card content")
            default:
                XCTFail()
            }
        }
        XCTAssert(file.extractParsedData().extractCards()[0].parts[1].hilite == true)
        XCTAssert(file.stack.cards[0].buttons[0].hilite == true)
        
    }
    
    /// Test contents with or without complex styles
    func testFormattedContent() {
        
        let path = Bundle(for: HyperCardCommonTests.self).path(forResource: "TestFormattedContent", ofType: "stack")!
        let file = try! HyperCardFile(path: path)
        
        let textUnformatted = "unformatted content"
        let textFormatted = "formatted content: fontsizestyleall"
        
        /* Formatted content in file */
        XCTAssert(file.extractParsedData().extractCards()[0].contentCount == 2)
        XCTAssert(file.extractParsedData().extractCards()[0].contents.count == 2)
        for content in file.extractParsedData().extractCards()[0].contents {
            switch (content.identifier, content.layerType) {
            case (1, .card):
                XCTAssert(content.string == textUnformatted)
                XCTAssert(content.formattingChanges == nil)
            case (2, .card):
                XCTAssert(content.string == textFormatted)
                XCTAssert(content.formattingChanges != nil)
            default:
                XCTFail()
            }
        }
        
        /* Formatted content in data */
        if case let PartContent.string(string) = file.stack.cards[0].fields[0].content, string == textUnformatted {
        }
        else {
            XCTFail()
        }
        if case let PartContent.formattedString(text) = file.stack.cards[0].fields[1].content {
            XCTAssert(text.string == textFormatted)
            XCTAssert(text.attributes.count == 5)
            
            XCTAssert(text.attributes[0].offset == 0)
            XCTAssert(text.attributes[0].formatting.fontFamilyIdentifier == nil)
            XCTAssert(text.attributes[0].formatting.size == nil)
            XCTAssert(text.attributes[0].formatting.style == nil)
            
            XCTAssert(text.attributes[1].offset == 0x13)
            XCTAssert(text.attributes[1].formatting.fontFamilyIdentifier == FontIdentifiers.palatino)
            XCTAssert(text.attributes[1].formatting.size == nil)
            XCTAssert(text.attributes[1].formatting.style == nil)
            
            XCTAssert(text.attributes[2].offset == 0x17)
            XCTAssert(text.attributes[2].formatting.fontFamilyIdentifier == nil)
            XCTAssert(text.attributes[2].formatting.size == 18)
            XCTAssert(text.attributes[2].formatting.style == nil)
            
            XCTAssert(text.attributes[3].offset == 0x1B)
            XCTAssert(text.attributes[3].formatting.fontFamilyIdentifier == nil)
            XCTAssert(text.attributes[3].formatting.size == nil)
            XCTAssert(text.attributes[3].formatting.style == TextStyle(bold: true, italic: false, underline: false, outline: false, shadow: false, condense: false, extend: true, group: false))
            
            XCTAssert(text.attributes[4].offset == 0x20)
            XCTAssert(text.attributes[4].formatting.fontFamilyIdentifier == FontIdentifiers.courier)
            XCTAssert(text.attributes[4].formatting.size == 10)
            XCTAssert(text.attributes[4].formatting.style == TextStyle(bold: false, italic: false, underline: true, outline: false, shadow: false, condense: false, extend: false, group: false))
        }
        else {
            XCTFail()
        }
        
    }
    
    /// Test stack in V 1.x format
    func testV1() {
        
        let path = Bundle(for: HyperCardCommonTests.self).path(forResource: "TestV1", ofType: "stack")!
        let file = try! HyperCardFile(path: path)
        
        XCTAssert(file.stack.cards.count == 9)
        XCTAssert(file.stack.backgrounds.count == 3)
        XCTAssert(file.stack.cards[0].buttons.count == 7)
        XCTAssert(file.stack.cards[0].fields.count == 0)
        XCTAssert(file.stack.cards[0].background.buttons.count == 3)
        XCTAssert(file.stack.cards[0].background.fields.count == 0)
        XCTAssert(file.stack.cards[1].backgroundPartContents.count == 1)
        if case let PartContent.string(string) = file.stack.cards[1].backgroundPartContents[0].partContent, string == "First, Previous, Next, Last, Return" {
        }
        else {
            XCTFail()
        }
        
    }
    
}
