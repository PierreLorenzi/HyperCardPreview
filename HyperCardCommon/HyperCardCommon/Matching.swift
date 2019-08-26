//
//  Matching.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 26/08/2019.
//  Copyright © 2019 Pierre Lorenzi. All rights reserved.
//


class Schema<T> {
    
    private var branches: [Branch] = []
    private var makeValue: (() -> T)! = nil
    
    private struct Branch {
        var subSchemas: [SubSchema]
    }
    
    private struct MatchingStatus {
        
        var currentValue: T?
        var mustStop: Bool
    }
    
    private class SubMatcher {
        
        func matchNextCharacter(_ character: HChar) -> SubMatchingStatus {
            fatalError()
        }
    }
    
    private struct SubMatchingStatus {
        
        var currentUpdate: ((inout T) -> ())?
        var mustStop: Bool
    }
    
    private class SubSchema {
        
        var minCount: Int
        var maxCount: Int
        
        init(minCount: Int, maxCount: Int) {
            self.minCount = minCount
            self.maxCount = maxCount
        }
        
        func buildSubMatcher() -> SubMatcher {
            fatalError() // abstract
        }
    }
    
    private class TypedSubSchema<U>: SubSchema {
        
        var schema: Schema<U>
        var update: (inout T,U) -> ()
        
        init(schema: Schema<U>, minCount: Int, maxCount: Int, update: @escaping (inout T,U) -> ()) {
            
            self.schema = schema
            self.update = update
            
            super.init(minCount: minCount, maxCount: maxCount)
        }
        
        override func buildSubMatcher() -> SubMatcher {
            
            return TypedSubMatcher(schema: self.schema, update: self.update)
        }
        
        private class TypedSubMatcher: SubMatcher {
            
            private let matcher: Schema<U>.Matcher
            private let update: (inout T,U) -> ()
            
            init(schema: Schema<U>, update: @escaping (inout T,U) -> ()) {
                
                self.matcher = schema.buildMatcher()
                self.update = update
            }
            
            override func matchNextCharacter(_ character: HChar) -> SubMatchingStatus {
                
                let status = self.matcher.matchNextCharacter(character)
                
                let currentUpdate: ((inout T) -> ())?
                if let currentValue = status.currentValue {
                    
                    let localUpdate = self.update
                    
                    currentUpdate = { (parentValue: inout T) in
                        localUpdate(&parentValue, currentValue)
                    }
                }
                else {
                    currentUpdate = nil
                }
                
                return SubMatchingStatus(currentUpdate: currentUpdate, mustStop: status.mustStop)
            }
        }
    }
    
    private class StringSubSchema: SubSchema {
        
        private let string: HString
        private let update: (inout T, HString) -> ()
        
        init(string: HString, minCount: Int, maxCount: Int, update: @escaping (inout T, HString) -> ()) {
            
            self.string = string
            self.update = update
            
            super.init(minCount: minCount, maxCount: maxCount)
        }
        
        override func buildSubMatcher() -> SubMatcher {
            
            return StringSubMatcher(string: self.string, update: self.update)
        }
        
        class StringSubMatcher: SubMatcher {
            
            private let string: HString
            private let update: (inout T, HString) -> ()
            private var currentIndex = 0
            
            init(string: HString, update: @escaping (inout T, HString) -> ()) {
                
                self.string = string
                self.update = update
            }
            
            override func matchNextCharacter(_ character: HChar) -> SubMatchingStatus {
                
                /* If the character is wrong, there is no value */
                guard character == self.string[self.currentIndex] else {
                    
                    return SubMatchingStatus(currentUpdate: nil, mustStop: true)
                }
                
                self.currentIndex += 1
                
                guard self.currentIndex < string.length else {
                    
                    let localUpdate = self.update
                    let localString = self.string
                    let currentUpdate = {(parentValue: inout T) in
                        localUpdate(&parentValue, localString)
                    }
                    
                    /* Parsing is finished */
                    return SubMatchingStatus(currentUpdate: currentUpdate, mustStop: true)
                    
                }
                return SubMatchingStatus(currentUpdate: nil, mustStop: false)
            }
        }
    }
    
    func parse(_ string: HString) -> T? {
        
        let matcher = self.buildMatcher()
        var status = MatchingStatus(currentValue: nil, mustStop: false)
        
        for i in 0..<string.length {
            
            guard !status.mustStop else {
                break
            }
            
            let character = string[i]
            status = matcher.matchNextCharacter(character)
        }
        
        return status.currentValue
    }
    
    private func buildMatcher() -> Matcher {
        
        return Matcher(branches: self.branches, makeValue: self.makeValue)
    }
    
    private class Matcher {
        
        private let branches: [Branch]
        private var branchMatchers: [BranchMatcher]
        
        private struct BranchMatcher {
            
            var value: T
            var subMatcher: SubMatcher
            var branchIndex: Int
            var subSchemaIndex: Int
            var occurrenceCount: Int
        }
        
        init(branches: [Branch], makeValue: () -> T) {
            
            self.branches = branches
            self.branchMatchers = []
            
            let value = makeValue()
            
            /* Make the first branch matchers */
            for i in 0..<branches.count {
                
                self.addBranchMatchersAtSchema(branchIndex: i, schemaIndex: 0, insertionIndex: self.branchMatchers.count, value: value)
            }
        }
        
        func matchNextCharacter(_ character: HChar) -> MatchingStatus {
            
            var bestValue: T? = nil
            
            /* Update the matchers in the reverse order so we can remove and add elements from the list */
            for i in (0 ..< self.branchMatchers.count).reversed() {
                
                /* Feed the matcher */
                let status = self.branchMatchers[i].subMatcher.matchNextCharacter(character)
                
                /* Update the value if possible */
                if let update = status.currentUpdate {
                    
                    update(&self.branchMatchers[i].value)
                    
                    /* Register for the global value */
                    bestValue = self.branchMatchers[i].value
                    
                    /* As it returns an update, it has a match, so we can consider it ends here */
                    self.addSubBranchMatchers(branchingFrom: self.branchMatchers[i], index: i)
                }
                
                /* If the matcher is over, remove it */
                if status.mustStop {
                    
                    self.branchMatchers.remove(at: i)
                }
            }
            
            return MatchingStatus(currentValue: bestValue, mustStop: self.branchMatchers.isEmpty)
        }
        
        private func addSubBranchMatchers(branchingFrom branchMatcher: BranchMatcher, index: Int) {
            
            /* Get the schema of the matcher */
            let branchIndex = branchMatcher.branchIndex
            let subSchemaIndex = branchMatcher.subSchemaIndex
            let subSchema = self.branches[branchIndex].subSchemas[subSchemaIndex]
            
            var insertionIndex = index + 1
            
            /* Consider the same schema restarts */
            if branchMatcher.occurrenceCount + 1 < subSchema.maxCount {
                
                let newSubMatcher = subSchema.buildSubMatcher()
                let newBranchMatcher = BranchMatcher(value: branchMatcher.value, subMatcher: newSubMatcher, branchIndex: branchIndex, subSchemaIndex: subSchemaIndex, occurrenceCount: branchMatcher.occurrenceCount + 1)
                
                self.branchMatchers.insert(newBranchMatcher, at: insertionIndex)
                insertionIndex += 1
            }
            
            /* Consider the next schema starts */
            if subSchemaIndex + 1 < self.branches[branchIndex].subSchemas.count {
                
                self.addBranchMatchersAtSchema(branchIndex: branchIndex, schemaIndex: subSchemaIndex+1, insertionIndex: insertionIndex, value: branchMatcher.value)
            }
        }
        
        private func addBranchMatchersAtSchema(branchIndex: Int, schemaIndex: Int, insertionIndex: Int, value: T) {
            
            let subSchemas = self.branches[branchIndex].subSchemas
            var currentInsertionIndex = insertionIndex
            
            for i in schemaIndex..<subSchemas.count {
                
                let subSchema = subSchemas[i]
                
                /* Very small precaution */
                guard subSchema.maxCount > 0 else {
                    continue
                }
                
                /* Create a matcher starting that sub-schema */
                let subMatcher = subSchema.buildSubMatcher()
                let branchMatcher = BranchMatcher(value: value, subMatcher: subMatcher, branchIndex: branchIndex, subSchemaIndex: i, occurrenceCount: 1)
                
                /* Insert */
                self.branchMatchers.insert(branchMatcher, at: currentInsertionIndex)
                currentInsertionIndex += 1
                
                /* If the minCount is 0, we must consider the next schema starts */
                guard subSchema.minCount == 0 else {
                    break
                }
            }
        }
    }
}





