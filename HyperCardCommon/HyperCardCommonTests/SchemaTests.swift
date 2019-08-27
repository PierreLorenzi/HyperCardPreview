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
    
    func testStringRepeat() {
        
        let schema = Schema<Int>()
        schema.initial { 0 }
        schema.branches = [ Schema<Int>.Branch(subSchemas: [Schema<Int>.StringSubSchema(string: "pierre", minCount: 0, maxCount: nil, update: { (count: inout Int, _: HString) in
            count += 1
        })])]
        
        XCTAssert(schema.parse("pierrepierrepierre") == 3)
        XCTAssert(schema.parse("") == 0)
        XCTAssert(schema.parse("pierre") == 1)
        XCTAssert(schema.parse("pierrepierrepierr") == nil)
        XCTAssert(schema.parse("pierrepierrepierrep") == nil)
        XCTAssert(schema.parse("slfkdja;slk") == nil)
        
    }
    
    func testStringRepeat2() {
        
        let schema = Schema<Int>()
        schema.initial { 0 }
        schema.branches = [ Schema<Int>.Branch(subSchemas: [Schema<Int>.StringSubSchema(string: "pierre", minCount: 3, maxCount: 4, update: { (count: inout Int, _: HString) in
            count += 1
        })])]
        
        XCTAssert(schema.parse("") == nil)
        XCTAssert(schema.parse("pierre") == nil)
        XCTAssert(schema.parse("pierrepierre") == nil)
        XCTAssert(schema.parse("pierrepierrepierre") == 3)
        XCTAssert(schema.parse("pierrepierrepierrepierre") == 4)
        XCTAssert(schema.parse("pierrepierrepierrepierrepierre") == nil)
        XCTAssert(schema.parse("pierrepierrepierrepierrepierrepierre") == nil)
        XCTAssert(schema.parse("pierrepierrepierr") == nil)
        XCTAssert(schema.parse("pierrepierrepierrep") == nil)
        XCTAssert(schema.parse("slfkdja;slk") == nil)
        
    }
    
    func testStringRepeat3() {
        
        let schema = Schema<Int>()
        schema.initial { 0 }
        schema.branches = [ Schema<Int>.Branch(subSchemas: [Schema<Int>.StringSubSchema(string: "pierre", minCount: 3, maxCount: 3, update: { (count: inout Int, _: HString) in
            count += 1
        })])]
        
        XCTAssert(schema.parse("") == nil)
        XCTAssert(schema.parse("pierre") == nil)
        XCTAssert(schema.parse("pierrepierre") == nil)
        XCTAssert(schema.parse("pierrepierrepierre") == 3)
        XCTAssert(schema.parse("pierrepierrepierrepierre") == nil)
        XCTAssert(schema.parse("pierrepierrepierrepierrepierre") == nil)
        XCTAssert(schema.parse("pierrepierrepierrepierrepierrepierre") == nil)
        XCTAssert(schema.parse("pierrepierrepierr") == nil)
        XCTAssert(schema.parse("pierrepierrepierrep") == nil)
        XCTAssert(schema.parse("slfkdja;slk") == nil)
        
    }
    
    
}
