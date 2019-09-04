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

        XCTAssert(schema.parse("true") == Expression.literal(Literal.boolean(true)))
        XCTAssert(schema.parse("false") == Expression.literal(Literal.boolean(false)))
        XCTAssert(schema.parse("fàLSE") == Expression.literal(Literal.boolean(false)))
        XCTAssert(schema.parse("\"true\"") == Expression.literal(Literal.string("true")))
        XCTAssert(schema.parse("\"several words\"") == Expression.literal(Literal.string("several words")))
        XCTAssert(schema.parse("unquoted") == Expression.literal(Literal.string("unquoted")))
        XCTAssert(schema.parse("123") == Expression.literal(Literal.integer(123)))
        XCTAssert(schema.parse("00123") == Expression.literal(Literal.integer(123)))
        XCTAssert(schema.parse("123.25") == Expression.literal(Literal.realNumber(123.25)))
        XCTAssert(schema.parse("123.2500") == Expression.literal(Literal.realNumber(123.25)))
    }
    
    func testOperators() {
        
        let schema = Schemas.expression
        
        XCTAssert(schema.parse("2 + 2") == Expression.operator(Operator.addition(Expression.literal(Literal.integer(2)), Expression.literal(Literal.integer(2)))))
        XCTAssert(schema.parse("- 2 + 2") == Expression.operator(Operator.addition(Expression.operator(Operator.opposite(Expression.literal(Literal.integer(2)))), Expression.literal(Literal.integer(2)))))
        XCTAssert(schema.parse("the exp of 2") == Expression.functionCall(FunctionCall.exp(Expression.literal(Literal.integer(2)))))
        XCTAssert(schema.parse("exp of 2") == Expression.functionCall(FunctionCall.exp(Expression.literal(Literal.integer(2)))))
        XCTAssert(schema.parse("exp(2)") == Expression.functionCall(FunctionCall.exp(Expression.literal(Literal.integer(2)))))
        XCTAssert(schema.parse("the message box") == Expression.containerContent(ContainerDescriptor.messageBox))
//        XCTAssert(schema.parse("card field id 3") == Expression.containerContent(ContainerDescriptor.part(PartDescriptor(type: PartDescriptorType.field, typedPartDescriptor: TypedPartDescriptor(layer: LayerType.card, identification: HyperCardObjectIdentification.withIdentifier(Expression.literal(Literal.integer(3))), card: CardDescriptor(descriptor: LayerDescriptor.relative(RelativeOrdinal.current), parentBackground: nil))))))
//        XCTAssert(schema.parse("char 2 of \"aaa\"") == Expression.chunk(ChunkExpression(expression: Expression.literal(Literal.string("aaa")), chunk: Chunk(elements: [ChunkElement(type: ChunkType.character, number: ChunkNumber.single(Ordinal.number(Expression.literal(Literal.integer(2)))))]))))
    }
    
    func test() {
        
        let schema = Schemas.expression
        
        XCTAssert(schema.parse("char 2 of \"aaa\"")! == Expression.chunk(ChunkExpression(expression: Expression.literal(Literal.string("aaa")), chunk: Chunk(elements: [ChunkElement(type: ChunkType.character, number: ChunkNumber.single(Ordinal.number(Expression.literal(Literal.integer(2)))))]))))
    }
    
}
