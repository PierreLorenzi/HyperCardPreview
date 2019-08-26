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
    let endIndex: Int?
    
    init(schema: Schema, parent: Match, sequenceIndex: Int, startIndex: Int, endIndex: Int?) {
        
        self.schema = schema
        self.parent = parent
        self.sequenceIndex = sequenceIndex
        self.startIndex = startIndex
        self.endIndex = endIndex
    }
}

class MatchInProgress: Match {
    
    var branches: [Branch] = []
}

struct Branch {
    
    var currentMatch: MatchInProgress
    var oldMatches: [Match]
}

extension MatchInProgress {
    
    func matchNextCharacter(_ character: HChar, index: Int, warnMatchFinished: (Match) -> ()) -> MatchingResult {
        
        // TODO
        return MatchingResult(isMatchValid: false, canContinue: false)
    }
}

struct MatchingResult {
    
    var isMatchValid: Bool
    var canContinue: Bool
}

