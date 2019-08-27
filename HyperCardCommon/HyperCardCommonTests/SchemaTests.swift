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
        schema.initialValue = 0
        schema.branches = [ Schema<Int>.Branch(subSchemas: [Schema<Int>.ValueSubSchema(accept: { $0 == Token.word("pierre") }, minCount: 0, maxCount: nil, update: Schema<Int>.Update<Token>.change({ (parentValue: inout Int, value: Token) in
            parentValue += 1
        }))])]
        
        XCTAssert(schema.parse("pierre pierre pierre") == 3)
        XCTAssert(schema.parse("") == 0)
        XCTAssert(schema.parse("pierre") == 1)
        XCTAssert(schema.parse("pierre pierre pierr") == nil)
        XCTAssert(schema.parse("pierre pierre pierre p") == nil)
        XCTAssert(schema.parse("slfkdja;slk") == nil)
        
    }
    
    func testStringRepeat2() {
        
        let schema = Schema<Int>()
        schema.initialValue = 0
        schema.branches = [ Schema<Int>.Branch(subSchemas: [Schema<Int>.ValueSubSchema(accept: { $0 == Token.word("pierre") }, minCount: 3, maxCount: 4, update: Schema<Int>.Update<Token>.change({ (parentValue: inout Int, value: Token) in
            parentValue += 1
        }))])]
        
        XCTAssert(schema.parse("") == nil)
        XCTAssert(schema.parse("pierre") == nil)
        XCTAssert(schema.parse("pierre pierre") == nil)
        XCTAssert(schema.parse("pierre pierre pierre") == 3)
        XCTAssert(schema.parse("pierre pierre pierre pierre") == 4)
        XCTAssert(schema.parse("pierre pierre pierre pierre pierre") == nil)
        XCTAssert(schema.parse("pierre pierre pierre pierre pierre pierre") == nil)
        XCTAssert(schema.parse("pierre pierre pierr") == nil)
        XCTAssert(schema.parse("pierre pierre pierre p") == nil)
        XCTAssert(schema.parse("slfkdja;slk") == nil)
        
    }
    
    func testStringRepeat3() {
        
        let schema = Schema<Int>()
        schema.initialValue = 0
        schema.branches = [ Schema<Int>.Branch(subSchemas: [Schema<Int>.ValueSubSchema(accept: { $0 == Token.word("pierre") }, minCount: 3, maxCount: 3, update: Schema<Int>.Update<Token>.change({ (parentValue: inout Int, value: Token) in
            parentValue += 1
        }))])]
        
        XCTAssert(schema.parse("") == nil)
        XCTAssert(schema.parse("pierre") == nil)
        XCTAssert(schema.parse("pierre pierre") == nil)
        XCTAssert(schema.parse("pierre pierre pierre") == 3)
        XCTAssert(schema.parse("pierre pierre pierre pierre") == nil)
        XCTAssert(schema.parse("pierre pierre pierre pierre pierre") == nil)
        XCTAssert(schema.parse("pierre pierre pierre pierre pierre pierre") == nil)
        XCTAssert(schema.parse("pierre pierre pierr") == nil)
        XCTAssert(schema.parse("pierre pierre pierrep") == nil)
        XCTAssert(schema.parse("slfkdja;slk") == nil)
        
    }
    
    func testTwoStringRepeat() {
        
        let schema = Schema<Int>()
        schema.initialValue = 0
        schema.branches = [ Schema<Int>.Branch(subSchemas: [Schema<Int>.ValueSubSchema(accept: { $0 == Token.word("pierre") }, minCount: 0, maxCount: nil, update: Schema<Int>.Update<Token>.change({ (parentValue: inout Int, value: Token) in
            parentValue += 10
        })), Schema<Int>.ValueSubSchema(accept: { $0 == Token.word("roc") }, minCount: 0, maxCount: nil, update: Schema<Int>.Update<Token>.change({ (parentValue: inout Int, value: Token) in
            parentValue += 1
        }))])]
        
        XCTAssert(schema.parse("") == 0)
        XCTAssert(schema.parse("pierre") == 10)
        XCTAssert(schema.parse("pier") == nil)
        XCTAssert(schema.parse("pierre p") == nil)
        XCTAssert(schema.parse("pierre pierre") == 20)
        XCTAssert(schema.parse("roc") == 1)
        XCTAssert(schema.parse("roc r") == nil)
        XCTAssert(schema.parse("roc roc roc") == 3)
        XCTAssert(schema.parse("pierre roc") == 11)
        XCTAssert(schema.parse("pierre pierre roc roc") == 22)
        XCTAssert(schema.parse("roc pierre") == nil)
        XCTAssert(schema.parse("pierre roc roc") == 12)
        XCTAssert(schema.parse("pierre pierre roc") == 21)
        
    }
    
    func testTwoStringRepeat2() {
        
        let schema = Schema<Int>()
        schema.initialValue = 0
        schema.branches = [ Schema<Int>.Branch(subSchemas: [Schema<Int>.ValueSubSchema(accept: { $0 == Token.word("pierre") }, minCount: 2, maxCount: 2, update: Schema<Int>.Update<Token>.change({ (parentValue: inout Int, value: Token) in
            parentValue += 10
        })), Schema<Int>.ValueSubSchema(accept: { $0 == Token.word("roc") }, minCount: 1, maxCount: 1, update: Schema<Int>.Update<Token>.change({ (parentValue: inout Int, value: Token) in
            parentValue += 1
        }))])]
        
        XCTAssert(schema.parse("") == nil)
        XCTAssert(schema.parse("pierre") == nil)
        XCTAssert(schema.parse("pier") == nil)
        XCTAssert(schema.parse("pierre p") == nil)
        XCTAssert(schema.parse("pierre pierre") == nil)
        XCTAssert(schema.parse("roc") == nil)
        XCTAssert(schema.parse("roc r") == nil)
        XCTAssert(schema.parse("roc roc roc") == nil)
        XCTAssert(schema.parse("pierre roc") == nil)
        XCTAssert(schema.parse("pierre pierre roc roc") == nil)
        XCTAssert(schema.parse("roc pierre") == nil)
        XCTAssert(schema.parse("pierre roc roc") == nil)
        XCTAssert(schema.parse("pierre pierre roc") == 21)
        
    }
    
    func testSeveralStringRepeat() {
        
        let schema = Schema<Int>()
        schema.initialValue = 0
        schema.branches = [ Schema<Int>.Branch(subSchemas: [Schema<Int>.ValueSubSchema(accept: { $0 == Token.word("pierre") }, minCount: 0, maxCount: nil, update: Schema<Int>.Update<Token>.change({ (parentValue: inout Int, value: Token) in
            parentValue += 1
        })), Schema<Int>.ValueSubSchema(accept: { $0 == Token.word("roc") }, minCount: 0, maxCount: nil, update: Schema<Int>.Update<Token>.change({ (parentValue: inout Int, value: Token) in
            parentValue += 2
        })), Schema<Int>.ValueSubSchema(accept: { $0 == Token.word("ciseau") }, minCount: 0, maxCount: nil, update: Schema<Int>.Update<Token>.change({ (parentValue: inout Int, value: Token) in
            parentValue += 3
        })), Schema<Int>.ValueSubSchema(accept: { $0 == Token.word("crayon") }, minCount: 0, maxCount: nil, update: Schema<Int>.Update<Token>.change({ (parentValue: inout Int, value: Token) in
            parentValue += 4
        }))])]
        
        XCTAssert(schema.parse("pierre") == 1)
        XCTAssert(schema.parse("roc") == 2)
        XCTAssert(schema.parse("ciseau") == 3)
        XCTAssert(schema.parse("crayon") == 4)
    }
    
    func testRepeatAmbiguity() {
        
        let schema = Schema<Int>()
        schema.initialValue = 0
        schema.branches = [ Schema<Int>.Branch(subSchemas: [Schema<Int>.ValueSubSchema(accept: { $0 == Token.word("pierre") }, minCount: 0, maxCount: nil, update: Schema<Int>.Update<Token>.change({ (parentValue: inout Int, value: Token) in
            parentValue += 10
        })), Schema<Int>.ValueSubSchema(accept: { $0 == Token.word("pierre") }, minCount: 0, maxCount: nil, update: Schema<Int>.Update<Token>.change({ (parentValue: inout Int, value: Token) in
            parentValue += 1
        }))])]
        
        XCTAssert(schema.parse("") == 0)
        XCTAssert(schema.parse("pierre") == 10)
        XCTAssert(schema.parse("pierre pierre") == 20)
        XCTAssert(schema.parse("pierre pierre pierre") == 30)
        XCTAssert(schema.parse("pierre pierre pierre pierre") == 40)
        XCTAssert(schema.parse("pierre pierre pierre pierre p") == nil)
        
    }
    
    func testRepeatAmbiguity2() {
        
        let schema = Schema<Int>()
        schema.initialValue = 0
        schema.branches = [ Schema<Int>.Branch(subSchemas: [Schema<Int>.ValueSubSchema(accept: { $0 == Token.word("pierre") }, minCount: 1, maxCount: 1, update: Schema<Int>.Update<Token>.change({ (parentValue: inout Int, value: Token) in
            parentValue += 10
        })), Schema<Int>.ValueSubSchema(accept: { $0 == Token.word("coucou") }, minCount: 1, maxCount: 1, update: Schema<Int>.Update<Token>.change({ (parentValue: inout Int, value: Token) in
            parentValue += 10
        }))]), Schema<Int>.Branch(subSchemas: [Schema<Int>.ValueSubSchema(accept: { $0 == Token.word("pierre") }, minCount: 1, maxCount: 1, update: Schema<Int>.Update<Token>.change({ (parentValue: inout Int, value: Token) in
            parentValue += 1
        })), Schema<Int>.ValueSubSchema(accept: { $0 == Token.word("roc") }, minCount: 1, maxCount: 1, update: Schema<Int>.Update<Token>.change({ (parentValue: inout Int, value: Token) in
            parentValue += 1
        }))])]
        
        XCTAssert(schema.parse("pierre coucou") == 20)
        XCTAssert(schema.parse("pierre roc") == 2)
        XCTAssert(schema.parse("pierre") == nil)
        XCTAssert(schema.parse("") == nil)
        
    }
    
    func testDisjunction() {
        
        let schema = Schema<Int>()
        schema.initialValue = 0
        schema.branches = [ Schema<Int>.Branch(subSchemas: [Schema<Int>.ValueSubSchema(accept: { $0 == Token.word("pierre") }, minCount: 0, maxCount: nil, update: Schema<Int>.Update<Token>.change({ (parentValue: inout Int, value: Token) in
            XCTAssert(value == Token.word("pierre"))
            parentValue += 1
        }))]), Schema<Int>.Branch(subSchemas: [Schema<Int>.ValueSubSchema(accept: { $0 == Token.word("roc") }, minCount: 0, maxCount: nil, update: Schema<Int>.Update<Token>.change({ (parentValue: inout Int, value: Token) in
            XCTAssert(value == Token.word("roc"))
            parentValue -= 1
        }))])]
        
        XCTAssert(schema.parse("") == 0)
        XCTAssert(schema.parse("pierre") == 1)
        XCTAssert(schema.parse("pierre pierre") == 2)
        XCTAssert(schema.parse("roc") == -1)
        XCTAssert(schema.parse("roc roc") == -2)
        XCTAssert(schema.parse("pierre roc") == nil)
        XCTAssert(schema.parse("roc pierre") == nil)
        
    }
    
    func testDisjunctionAmbiguity() {
        
        let schema = Schema<Int>()
        schema.initialValue = 0
        schema.branches = [ Schema<Int>.Branch(subSchemas: [Schema<Int>.ValueSubSchema(accept: { $0 == Token.word("pierre") }, minCount: 0, maxCount: nil, update: Schema<Int>.Update<Token>.change({ (parentValue: inout Int, value: Token) in
            parentValue += 1
        }))]), Schema<Int>.Branch(subSchemas: [Schema<Int>.ValueSubSchema(accept: { $0 == Token.word("pierre") }, minCount: 0, maxCount: nil, update: Schema<Int>.Update<Token>.change({ (parentValue: inout Int, value: Token) in
            parentValue -= 1
        }))])]
        
        XCTAssert(schema.parse("pierre") == 1)
        
    }
    
    func testEmptyBranch() {
        
        /* Schemas with empty branches happen during interpolations */
        
        let schema = Schema<Void>()
        schema.initialValue = ()
        schema.branches = [ Schema<Void>.Branch(subSchemas: [])]
        
        XCTAssert(schema.parse("") != nil)
        XCTAssert(schema.parse("pierre") == nil)
        
    }
    
    func testEmptyBranch2() {
        
        /* Schemas with empty branches happen during interpolations */
        
        let schema = Schema<Void>()
        let schema2 = Schema<Void>()
        schema.initialValue = ()
        schema2.initialValue = ()
        schema.branches = [ Schema<Void>.Branch(subSchemas: [Schema<Void>.ValueSubSchema(accept: { $0 == Token.word("pierre") }, minCount: 1, maxCount: 1, update: Schema<Void>.Update<Token>.none), Schema<Void>.TypedSubSchema<Void>(schema: schema2, minCount: 1, maxCount: 1, update: Schema<Void>.Update<Void>.none)])]
        schema2.branches = [ Schema.Branch(subSchemas: []) ]
        
        XCTAssert(schema.parse("pierre") != nil)
        XCTAssert(schema.parse("") == nil)
        XCTAssert(schema.parse("pierre pierre") == nil)
        
    }
    
    func testEmptyBranch3() {
        
        /* Schemas with empty branches happen during interpolations */
        
        let schema = Schema<Void>()
        let schema2 = Schema<Void>()
        schema.initialValue = ()
        schema2.initialValue = ()
        schema.branches = [ Schema<Void>.Branch(subSchemas: [Schema<Void>.TypedSubSchema<Void>(schema: schema2, minCount: 1, maxCount: 1, update: Schema<Void>.Update<Void>.none), Schema<Void>.ValueSubSchema(accept: { $0 == Token.word("pierre") }, minCount: 1, maxCount: 1, update: Schema<Void>.Update<Token>.none)])]
        schema2.branches = [ Schema.Branch(subSchemas: []) ]
        
        XCTAssert(schema.parse("pierre") != nil)
        XCTAssert(schema.parse("") == nil)
        XCTAssert(schema.parse("pierre pierre") == nil)
        
    }
    
}
