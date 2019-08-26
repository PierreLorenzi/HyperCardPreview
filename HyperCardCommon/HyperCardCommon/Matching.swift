//
//  Matching.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 26/08/2019.
//  Copyright © 2019 Pierre Lorenzi. All rights reserved.
//


class Schema {
    
    var content: SchemaContent
    
    init(content: SchemaContent) {
        self.content = content
    }
}

enum SchemaContent {
    
    case character(HChar)
    case concatenation(Schema, Schema)
    case disjunction(Schema, Schema)
    case multiple(Schema, minCount: Int, maxCount: Int)
}

class Match {
    
    let schema: Schema
    
    unowned let parent: Match
    let sequenceIndex: Int
    
    let startIndex: Int
    
    init(schema: Schema, parent: Match, sequenceIndex: Int, startIndex: Int) {
        
        self.schema = schema
        self.parent = parent
        self.sequenceIndex = sequenceIndex
        self.startIndex = startIndex
    }
}

struct MatchingStatus {
    
    var isMatching: Bool
    var mustStop: Bool
}

// We can make two classes: character matcher and complex matcher.
// I've done it and it is a little mess, but it could be made simple
// with string interpolations like (in a namespace):
//      let procedure = "on \(identifier) \(return) \(multiple: statement) end \(identifier) \(return)"
//      let card = "\(maybe: "the") \(either: "card", either: "cd")"
// The space would match to any sequence of whitespace.
protocol Matcher {
    
    func matchNextCharacter(_ character: HChar, index: Int) -> MatchingStatus
    
    // remove all the lower branches (in a complex matcher, the best branch is the one with
    // the longest first matches).
    // can only be called if the matcher is matching
    // the matcher becomes unamgibuous and over, as all its descendants
    func endMatch()
    
    // capture the unambiguous matches that are over (children in order then parent),
    // then delete them
    func capture(_: (Match) -> ())
}




