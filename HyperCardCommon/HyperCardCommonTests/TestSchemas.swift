//
//  TestSchemas.swift
//  HyperCardCommonTests
//
//  Created by Pierre Lorenzi on 27/08/2019.
//  Copyright © 2019 Pierre Lorenzi. All rights reserved.
//

import XCTest
import HyperCardCommon


/// Tests on schemas

class SchemasTests: XCTestCase {
    
    func testLiteral() {

        let schema = Schemas.literal

        XCTAssert(schema.parse("true") == Literal.boolean(true))
        XCTAssert(schema.parse("false") == Literal.boolean(false))
        XCTAssert(schema.parse("fàLSE") == Literal.boolean(false))
        XCTAssert(schema.parse("\"true\"") == Literal.string("true"))
        XCTAssert(schema.parse("\"several words\"") == Literal.string("several words"))
        XCTAssert(schema.parse("unquoted") == Literal.string("unquoted"))
        XCTAssert(schema.parse("123") == Literal.integer(123))
        XCTAssert(schema.parse("00123") == Literal.integer(123))
        XCTAssert(schema.parse("123.25") == Literal.floatingPoint(123.25))
        XCTAssert(schema.parse("123.2500") == Literal.floatingPoint(123.25))
    }
    
}
