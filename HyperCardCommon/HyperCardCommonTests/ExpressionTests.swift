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

class ExpressionTests: XCTestCase {
    
    override class func setUp() {
        
        Schemas.finalizeSchemas()
    }
    
    func testLiteral() {

        let schema = Schemas.expression

        XCTAssert(schema.parse("true")! == Expression.literal(Literal.boolean(true)))
        XCTAssert(schema.parse("false")! == Expression.literal(Literal.boolean(false)))
        XCTAssert(schema.parse("fàLSE")! == Expression.literal(Literal.boolean(false)))
        XCTAssert(schema.parse("\"true\"")! == Expression.literal(Literal.string("true")))
        XCTAssert(schema.parse("\"several words\"")! == Expression.literal(Literal.string("several words")))
        XCTAssert(schema.parse("unquoted")! == Expression.literal(Literal.string("unquoted")))
        XCTAssert(schema.parse("123")! == Expression.literal(Literal.integer(123)))
        XCTAssert(schema.parse("00123")! == Expression.literal(Literal.integer(123)))
        XCTAssert(schema.parse("123.25")! == Expression.literal(Literal.realNumber(123.25)))
        XCTAssert(schema.parse("123.2500")! == Expression.literal(Literal.realNumber(123.25)))
    }
    
    func testOperators() {
        
        let schema = Schemas.expression
        
        XCTAssert(schema.parse("2 + 2")! == Expression.operator(Operator.addition(Expression.literal(Literal.integer(2)), Expression.literal(Literal.integer(2)))))
    }
    
}
