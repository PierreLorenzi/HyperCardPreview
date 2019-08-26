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
    
    func test() {
        
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
    
    
}
