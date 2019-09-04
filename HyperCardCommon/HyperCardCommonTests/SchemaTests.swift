//
//  SchemaTests.swift
//  HyperCardCommonTests
//
//  Created by Pierre Lorenzi on 04/09/2019.
//  Copyright © 2019 Pierre Lorenzi. All rights reserved.
//

import XCTest
import HyperCardCommon



class SchemaTests: XCTestCase {
    
    func testToken() {
        
        let schema = Schema<Int> { (token: Token) -> Int? in
            guard case Token.word(let string) = token else {
                return nil
            }
            return string.length
        }
        
        XCTAssert(schema.parse("coucou") == 6)
        XCTAssert(schema.parse("paf") == 3)
        XCTAssert(schema.parse("123") == nil)
        XCTAssert(schema.parse("123.1") == nil)
    }
    
    func testShared() {
        
        let base = Schema<Int>("ploc")
            .returns(0)
        let plus = Schema<Void>("+")
        let star = Schema<Void>("*")
        let superior1 = Schema<Int>("\(base)\(multiple: plus)")
            .returns(1)
        let superior2 = Schema<Int>("\(superior1)\(multiple: star)")
            .returns(2)
        let schema = Schema<Int>("\(superior2)\(or: base)\(or: superior1)")
        
        XCTAssert(schema.parse("ploc") == 2)
    }
    
    func testCycle() {
        
        let base = Schema<Int>("ploc")
            .returns(0)
        let plus = Schema<Void>("+")
        let star = Schema<Void>("*")
        let schemaAgain = Schema<Int>()
        let superior1 = Schema<Int>("\(schemaAgain)\(multiple: plus)")
            .returns(1)
        let superior2 = Schema<Int>("\(schemaAgain)\(multiple: star)")
            .returns(2)
        let schema = Schema<Int>("\(superior2)\(or: base)\(or: superior1)")
        schemaAgain.appendSchema(schema, minCount: 1, maxCount: 1, isConstant: nil)
        
        XCTAssert(schema.parse("ploc") == 2)
    }
    
    func testMultiple() {
        
        let ploc = Schema<Int>("ploc")
            .returns(1)
        
        let schema1 = Schema<Int>("\(multiple: ploc)")
            .returnsSingle({ (ints: [Int]) -> Int in ints.count })
        XCTAssert(schema1.parse("") == 0)
        XCTAssert(schema1.parse("ploc") == 1)
        XCTAssert(schema1.parse("ploc ploc") == 2)
        XCTAssert(schema1.parse("ploc ploc ploc") == 3)
        XCTAssert(schema1.parse("ploc ploc ploc ploc") == 4)
        XCTAssert(schema1.parse("ploc paf") == nil)
        XCTAssert(schema1.parse("paf ploc") == nil)
        
        let schema2 = Schema<Int>("\(multiple: ploc, atLeast: 2, atMost: 3)")
            .returnsSingle({ (ints: [Int]) -> Int in ints.count })
        XCTAssert(schema2.parse("") == nil)
        XCTAssert(schema2.parse("ploc") == nil)
        XCTAssert(schema2.parse("ploc ploc") == 2)
        XCTAssert(schema2.parse("ploc ploc ploc") == 3)
        XCTAssert(schema2.parse("ploc ploc ploc ploc") == nil)
        
        let schema3 = Schema<Int>("\(multiple: ploc, atLeast: 2, atMost: 2)")
            .returnsSingle({ (ints: [Int]) -> Int in ints.count })
        XCTAssert(schema3.parse("") == nil)
        XCTAssert(schema3.parse("ploc") == nil)
        XCTAssert(schema3.parse("ploc ploc") == 2)
        XCTAssert(schema3.parse("ploc ploc ploc") == nil)
        XCTAssert(schema3.parse("ploc ploc ploc ploc") == nil)
        
        let schema4 = Schema<Int>("\(multiple: ploc, atMost: 2)")
            .returnsSingle({ (ints: [Int]) -> Int in ints.count })
        XCTAssert(schema4.parse("") == 0)
        XCTAssert(schema4.parse("ploc") == 1)
        XCTAssert(schema4.parse("ploc ploc") == 2)
        XCTAssert(schema4.parse("ploc ploc ploc") == nil)
        XCTAssert(schema4.parse("ploc ploc ploc ploc") == nil)
        
        let schema5 = Schema<Int>("\(multiple: ploc, atLeast: 2)")
            .returnsSingle({ (ints: [Int]) -> Int in ints.count })
        XCTAssert(schema5.parse("") == nil)
        XCTAssert(schema5.parse("ploc") == nil)
        XCTAssert(schema5.parse("ploc ploc") == 2)
        XCTAssert(schema5.parse("ploc ploc ploc") == 3)
        
        let schema6 = Schema<Int>("\(multiple: ploc, atLeast: 1)")
            .returnsSingle({ (ints: [Int]) -> Int in ints.count })
        XCTAssert(schema6.parse("") == nil)
        XCTAssert(schema6.parse("ploc") == 1)
        XCTAssert(schema6.parse("ploc ploc") == 2)
        XCTAssert(schema6.parse("ploc ploc ploc") == 3)
    }
}
