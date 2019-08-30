//
//  SchemaTests.swift
//  HyperCardCommonTests
//
//  Created by Pierre Lorenzi on 27/08/2019.
//  Copyright © 2019 Pierre Lorenzi. All rights reserved.
//

import XCTest
import HyperCardCommon


/// Tests on schemas

class SchemaTests: XCTestCase {
    
    func testToken() {
        
        let schema = Schema<Token>("\(Token.word("coucou"))")
        
        XCTAssert(schema.parse("coucou") == Token.word("coucou"))
        XCTAssert(schema.parse("couco") == nil)
        XCTAssert(schema.parse("coucouu") == nil)
        XCTAssert(schema.parse("coucou coucou") == nil)
        XCTAssert(schema.parse("asdasdsd") == nil)
        XCTAssert(schema.parse("") == nil)
    }
    
    func testTokenRepeat() {
        
        let schema = Schema<Int>()
        schema.appendTokenKind(filterBy: { $0 == Token.word("coucou") }, minCount: 0, maxCount: nil, isConstant: true)
        schema.computeSequenceBySingle { (tokens: [Token]) -> Int in return tokens.count }
        
        XCTAssert(schema.parse("") == 0)
        XCTAssert(schema.parse("coucou") == 1)
        XCTAssert(schema.parse("coucou coucou") == 2)
        XCTAssert(schema.parse("coucou coucou coucou") == 3)
        XCTAssert(schema.parse("coucou coucou coucou coucou") == 4)
        XCTAssert(schema.parse("aaa") == nil)
        XCTAssert(schema.parse("coucou coucou aaa") == nil)
        XCTAssert(schema.parse("aaa coucou coucou") == nil)
        
    }
    
    func testTokenRepeat2() {
        
        let schema = Schema<Int>()
        schema.appendTokenKind(filterBy: { $0 == Token.word("coucou") }, minCount: 2, maxCount: 4, isConstant: true)
        schema.computeSequenceBySingle { (tokens: [Token]) -> Int in return tokens.count }
        
        XCTAssert(schema.parse("") == nil)
        XCTAssert(schema.parse("coucou") == nil)
        XCTAssert(schema.parse("coucou coucou") == 2)
        XCTAssert(schema.parse("coucou coucou coucou") == 3)
        XCTAssert(schema.parse("coucou coucou coucou coucou") == 4)
        XCTAssert(schema.parse("coucou coucou coucou coucou coucou") == nil)
        XCTAssert(schema.parse("coucou coucou coucou coucou coucou coucou") == nil)
    }
    
    func testTokenRepeat3() {
        
        let schema = Schema<Int>()
        schema.appendTokenKind(filterBy: { $0 == Token.word("coucou") }, minCount: 3, maxCount: 3, isConstant: true)
        schema.computeSequenceBy({ return 3 })
        
        XCTAssert(schema.parse("") == nil)
        XCTAssert(schema.parse("coucou") == nil)
        XCTAssert(schema.parse("coucou coucou") == nil)
        XCTAssert(schema.parse("coucou coucou coucou") == 3)
        XCTAssert(schema.parse("coucou coucou coucou coucou") == nil)
        XCTAssert(schema.parse("coucou coucou coucou coucou coucou") == nil)
    }
    
    func testTwoTokenRepeat() {
        
        let schema = Schema<Int>()
        schema.appendTokenKind(filterBy: { $0 == Token.word("coucou") }, minCount: 0, maxCount: nil, isConstant: true)
        schema.appendTokenKind(filterBy: { $0 == Token.word("pierre") }, minCount: 0, maxCount: nil, isConstant: true)
        schema.computeSequenceBy { (tokens1: [Token], tokens2: [Token]) -> Int in return tokens1.count * 10 + tokens2.count }
        
        XCTAssert(schema.parse("") == 0)
        XCTAssert(schema.parse("coucou") == 10)
        XCTAssert(schema.parse("coucou coucou") == 20)
        XCTAssert(schema.parse("pierre") == 1)
        XCTAssert(schema.parse("pierre pierre") == 2)
        XCTAssert(schema.parse("coucou pierre pierre") == 12)
        XCTAssert(schema.parse("coucou coucou pierre") == 21)
        XCTAssert(schema.parse("pierre coucou") == nil)
        XCTAssert(schema.parse("aaa") == nil)
        
    }
    
    func testTwoTokenRepeat2() {
        
        let schema = Schema<Int>()
        schema.appendTokenKind(filterBy: { $0 == Token.word("coucou") }, minCount: 2, maxCount: 2, isConstant: true)
        schema.appendTokenKind(filterBy: { $0 == Token.word("pierre") }, minCount: 2, maxCount: 3, isConstant: true)
        schema.computeSequenceBySingle { (tokens2: [Token]) -> Int in return 20 + tokens2.count }
        
        XCTAssert(schema.parse("") == nil)
        XCTAssert(schema.parse("coucou") == nil)
        XCTAssert(schema.parse("coucou coucou") == nil)
        XCTAssert(schema.parse("coucou coucou coucou") == nil)
        XCTAssert(schema.parse("pierre") == nil)
        XCTAssert(schema.parse("pierre pierre") == nil)
        XCTAssert(schema.parse("coucou coucou pierre pierre") == 22)
        XCTAssert(schema.parse("coucou coucou pierre pierre pierre") == 23)
        XCTAssert(schema.parse("coucou coucou coucou pierre pierre") == nil)
        XCTAssert(schema.parse("coucou coucou pierre pierre pierre pierre") == nil)
        
    }
    
    func testSingleArgumentSameType() {
        
        let schema = Schema<Int>("here it is \(Schemas.integer) is the value")
        
        XCTAssert(schema.parse("here it is 123 is the value") == 123)
    }
    
    func testBranchAmbiguity() {
        
        /* When there are several competing branches, it must return the best one */
        let schema = Schema<Int>()
        schema.appendTokenKind(filterBy: { $0 == Token.word("pierre") }, minCount: 0, maxCount: nil, isConstant: true)
        schema.appendTokenKind(filterBy: { $0 == Token.word("pierre") }, minCount: 0, maxCount: nil, isConstant: true)
        schema.computeSequenceBy { (tokens1: [Token], tokens2: [Token]) -> Int in return tokens1.count * 10 + tokens2.count }
        
        XCTAssert(schema.parse("") == 0)
        XCTAssert(schema.parse("pierre") == 10)
        XCTAssert(schema.parse("pierre pierre") == 20)
        XCTAssert(schema.parse("pierre pierre pierre") == 30)
        
    }
    
    func test() {
        
        let schema: Schema<Literal> = "\(maybe: "the") number equal to \(Schemas.integer)"
        
        XCTAssert(schema.parse("the number equal to 444") == Literal.integer(444))
        
    }

}
