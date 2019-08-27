//
//  SchemaInterpolationTests.swift
//  HyperCardCommonTests
//
//  Created by Pierre Lorenzi on 27/08/2019.
//  Copyright © 2019 Pierre Lorenzi. All rights reserved.
//

import XCTest
import HyperCardCommon


/// Tests on schemas

class SchemaInterpolationTests: XCTestCase {
    
    func testLiteral() {
        
        let schema: Schema<Void> = "coucou"
        schema.initialValue = ()
        
        XCTAssert(schema.parse("coucou") != nil)
        XCTAssert(schema.parse("") == nil)
        XCTAssert(schema.parse("couco") == nil)
        XCTAssert(schema.parse("coucouc") == nil)
    }
    
    func testSimple() {
        
        let schemaLiteral: Schema<Void> = "coucou"
        schemaLiteral.initialValue = ()
        let schema: Schema<Void> = "\(schemaLiteral)"
        schema.initialValue = ()
        
        XCTAssert(schema.parse("coucou") != nil)
        XCTAssert(schema.parse("") == nil)
        XCTAssert(schema.parse("couco") == nil)
        XCTAssert(schema.parse("coucouc") == nil)
    }
    
    func testSeveral() {
        
        let schemaLiteral: Schema<Void> = "coucou"
        schemaLiteral.initialValue = ()
        let schemaLiteral2: Schema<Void> = "pierre"
        schemaLiteral2.initialValue = ()
        let schema: Schema<Void> = "\(schemaLiteral) et \(schemaLiteral2)"
        schema.initialValue = ()
        
        XCTAssert(schema.parse("coucou et pierre") != nil)
        XCTAssert(schema.parse("coucou") == nil)
        XCTAssert(schema.parse("pierre") == nil)
        XCTAssert(schema.parse("") == nil)
        XCTAssert(schema.parse("coucoupierre") == nil)
        XCTAssert(schema.parse("coucou  pierre") == nil)
    }
    
    func testMultiple() {
        
        let schemaLiteral: Schema<Void> = "pierre"
        schemaLiteral.initialValue = ()
        
        let schema: Schema<Void> = "\(maybe: schemaLiteral)ppp"
        schema.initialValue = ()
        XCTAssert(schema.parse("pierreppp") != nil)
        XCTAssert(schema.parse("ppp") != nil)
        XCTAssert(schema.parse("pierrepierreppp") == nil)
        
        let schema2: Schema<Void> = "\(multiple: schemaLiteral)ppp"
        schema2.initialValue = ()
        XCTAssert(schema2.parse("pierrepierrepierreppp") != nil)
        XCTAssert(schema2.parse("pierrepierreppp") != nil)
        XCTAssert(schema2.parse("pierreppp") != nil)
        XCTAssert(schema2.parse("ppp") != nil)
        
        let schemaLiteral2: Schema<Void> = "coucou"
        schemaLiteral2.initialValue = ()
        let schema3: Schema<Void> = "\(either: schemaLiteral, either: schemaLiteral2)ppp"
        schema3.initialValue = ()
        XCTAssert(schema3.parse("pierreppp") != nil)
        XCTAssert(schema3.parse("coucouppp") != nil)
    }
    
    
}
