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
    
    
    
}
