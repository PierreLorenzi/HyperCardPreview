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
        schema.branches = [ Schema<Int>.Branch(subSchemas: [Schema<Int>.StringSubSchema(string: "pierre", minCount: 0, maxCount: nil, update: { (count: inout Int, s: HString) in
            XCTAssert(s == "pierre")
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
    
    func testTwoStringRepeat() {
        
        let schema = Schema<Int>()
        schema.initial { 0 }
        schema.branches = [ Schema<Int>.Branch(subSchemas: [Schema<Int>.StringSubSchema(string: "pierre", minCount: 0, maxCount: nil, update: { (count: inout Int, _: HString) in
            count += 10
        }), Schema<Int>.StringSubSchema(string: "roc", minCount: 0, maxCount: nil, update: { (count: inout Int, _: HString) in
            count += 1
        })])]
        
        XCTAssert(schema.parse("") == 0)
        XCTAssert(schema.parse("pierre") == 10)
        XCTAssert(schema.parse("pier") == nil)
        XCTAssert(schema.parse("pierrep") == nil)
        XCTAssert(schema.parse("pierrepierre") == 20)
        XCTAssert(schema.parse("roc") == 1)
        XCTAssert(schema.parse("rocr") == nil)
        XCTAssert(schema.parse("rocrocroc") == 3)
        XCTAssert(schema.parse("pierreroc") == 11)
        XCTAssert(schema.parse("pierrepierrerocroc") == 22)
        XCTAssert(schema.parse("rocpierre") == nil)
        XCTAssert(schema.parse("pierrerocroc") == 12)
        XCTAssert(schema.parse("pierrepierreroc") == 21)
        
    }
    
    func testTwoStringRepeat2() {
        
        let schema = Schema<Int>()
        schema.initial { 0 }
        schema.branches = [ Schema<Int>.Branch(subSchemas: [Schema<Int>.StringSubSchema(string: "pierre", minCount: 2, maxCount: 2, update: { (count: inout Int, _: HString) in
            count += 10
        }), Schema<Int>.StringSubSchema(string: "roc", minCount: 1, maxCount: 1, update: { (count: inout Int, _: HString) in
            count += 1
        })])]
        
        XCTAssert(schema.parse("") == nil)
        XCTAssert(schema.parse("pierre") == nil)
        XCTAssert(schema.parse("pier") == nil)
        XCTAssert(schema.parse("pierrep") == nil)
        XCTAssert(schema.parse("pierrepierre") == nil)
        XCTAssert(schema.parse("roc") == nil)
        XCTAssert(schema.parse("rocr") == nil)
        XCTAssert(schema.parse("rocrocroc") == nil)
        XCTAssert(schema.parse("pierreroc") == nil)
        XCTAssert(schema.parse("pierrepierrerocroc") == nil)
        XCTAssert(schema.parse("rocpierre") == nil)
        XCTAssert(schema.parse("pierrerocroc") == nil)
        XCTAssert(schema.parse("pierrepierreroc") == 21)
        
    }
    
    func testTwoStringRepeat3() {
        
        let schema = Schema<Int>()
        schema.initial { 0 }
        schema.branches = [ Schema<Int>.Branch(subSchemas: [Schema<Int>.StringSubSchema(string: "pierre", minCount: 0, maxCount: nil, update: { (count: inout Int, _: HString) in
            count += 10
        }), Schema<Int>.StringSubSchema(string: "pier", minCount: 0, maxCount: nil, update: { (count: inout Int, _: HString) in
            count += 1
        })])]
        
        XCTAssert(schema.parse("") == 0)
        XCTAssert(schema.parse("pierre") == 10)
        XCTAssert(schema.parse("pierr") == nil)
        XCTAssert(schema.parse("pierrep") == nil)
        XCTAssert(schema.parse("pierrepierre") == 20)
        XCTAssert(schema.parse("pier") == 1)
        XCTAssert(schema.parse("pierp") == nil)
        XCTAssert(schema.parse("pierpierpier") == 3)
        XCTAssert(schema.parse("pierrepier") == 11)
        XCTAssert(schema.parse("pierrepierrepierpier") == 22)
        XCTAssert(schema.parse("pierpierre") == nil)
        XCTAssert(schema.parse("pierrepierpier") == 12)
        XCTAssert(schema.parse("pierrepierrepier") == 21)
        
    }
    
    func testSeveralStringRepeat() {
        
        let schema = Schema<Int>()
        schema.initial { 0 }
        schema.branches = [ Schema<Int>.Branch(subSchemas: [Schema<Int>.StringSubSchema(string: "pierre", minCount: 0, maxCount: nil, update: { (count: inout Int, s: HString) in
            XCTAssert(s == "pierre")
            count += 1
        }), Schema<Int>.StringSubSchema(string: "roc", minCount: 0, maxCount: nil, update: { (count: inout Int, s: HString) in
            XCTAssert(s == "roc")
            count += 2
        }), Schema<Int>.StringSubSchema(string: "ciseau", minCount: 0, maxCount: nil, update: { (count: inout Int, s: HString) in
            XCTAssert(s == "ciseau")
            count += 3
        }), Schema<Int>.StringSubSchema(string: "crayon", minCount: 0, maxCount: nil, update: { (count: inout Int, s: HString) in
            XCTAssert(s == "crayon")
            count += 4
        })])]
        
        XCTAssert(schema.parse("pierre") == 1)
        XCTAssert(schema.parse("roc") == 2)
        XCTAssert(schema.parse("ciseau") == 3)
        XCTAssert(schema.parse("crayon") == 4)
    }
    
    func testRepeatAmbiguity() {
        
        let schema = Schema<Int>()
        schema.initial { 0 }
        schema.branches = [ Schema<Int>.Branch(subSchemas: [Schema<Int>.StringSubSchema(string: "pierre", minCount: 0, maxCount: nil, update: { (count: inout Int, _: HString) in
            count += 10
        }), Schema<Int>.StringSubSchema(string: "pierre", minCount: 0, maxCount: nil, update: { (count: inout Int, _: HString) in
            count += 1
        })])]
        
        XCTAssert(schema.parse("") == 0)
        XCTAssert(schema.parse("pierre") == 10)
        XCTAssert(schema.parse("pierrepierre") == 20)
        XCTAssert(schema.parse("pierrepierrepierre") == 30)
        XCTAssert(schema.parse("pierrepierrepierrepierre") == 40)
        XCTAssert(schema.parse("pierrepierrepierrepierrep") == nil)
        
    }
    
    func testDisjunction() {
        
        let schema = Schema<Int>()
        schema.initial { 0 }
        schema.branches = [ Schema<Int>.Branch(subSchemas: [Schema<Int>.StringSubSchema(string: "pierre", minCount: 0, maxCount: nil, update: { (count: inout Int, s: HString) in
            XCTAssert(s == "pierre")
            count += 1
        })]), Schema<Int>.Branch(subSchemas: [Schema<Int>.StringSubSchema(string: "roc", minCount: 0, maxCount: nil, update: { (count: inout Int, s: HString) in
            XCTAssert(s == "roc")
            count -= 1
        })])]
        
        XCTAssert(schema.parse("") == 0)
        XCTAssert(schema.parse("pierre") == 1)
        XCTAssert(schema.parse("pierrepierre") == 2)
        XCTAssert(schema.parse("roc") == -1)
        XCTAssert(schema.parse("rocroc") == -2)
        XCTAssert(schema.parse("pierreroc") == nil)
        XCTAssert(schema.parse("rocpierre") == nil)
        
    }
    
    func testDisjunctionAmbiguity() {
        
        let schema = Schema<Int>()
        schema.initial { 0 }
        schema.branches = [ Schema<Int>.Branch(subSchemas: [Schema<Int>.StringSubSchema(string: "pierre", minCount: 0, maxCount: nil, update: { (count: inout Int, s: HString) in
            XCTAssert(s == "pierre")
            count += 1
        })]), Schema<Int>.Branch(subSchemas: [Schema<Int>.StringSubSchema(string: "pierre", minCount: 0, maxCount: nil, update: { (count: inout Int, s: HString) in
            XCTAssert(s == "pierre")
            count -= 1
        })])]
        
        XCTAssert(schema.parse("pierre") == 1)
        
    }
    
}
