//
//  Matching.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 26/08/2019.
//  Copyright © 2019 Pierre Lorenzi. All rights reserved.
//


public final class Schema<T> {
    
    public var branches: [Branch] = []
    public var initialValue: T? = nil
    
    public init() {}
    
    public init(initialValue: T?, branches: [Branch]) {
        self.initialValue = initialValue
        self.branches = branches
    }
    
    public init(_ schema: Schema<T>) {
        self.branches = schema.branches
        self.initialValue = schema.initialValue
    }
    
    public struct Branch {
        public var subSchemas: [SubSchema]
        
        public init(subSchemas: [SubSchema]) {
            self.subSchemas = subSchemas
        }
    }
    
    private var matchesEmpty: Bool {
        
        /* The schema can match empty if one of the branch can */
        for branch in self.branches {
            
            let branchMatchesEmpty = branch.subSchemas.allSatisfy({ $0.minCount == 0 || $0.matchesEmpty })
            if branchMatchesEmpty {
                return true
            }
        }
        
        return false
    }
    
    private var matchesNotEmpty: Bool {
        
        /* The schema can match not empty if one of the branch can */
        for branch in self.branches {
            
            let branchMatchesNotEmpty = branch.subSchemas.first(where: { $0.matchesNotEmpty }) != nil
            if branchMatchesNotEmpty {
                return true
            }
        }
        
        return false
    }
    
    public enum MatchingStatus {
        
        case canContinue
        case mustStop
    }
    
    public class SubMatcher {
        
        var isMatching: Bool {
            fatalError()
        }
        
        var currentUpdate: SubUpdate {
            fatalError()
        }
        
        func matchNextToken(_ token: Token) -> MatchingStatus {
            fatalError()
        }
    }
    
    public class SubSchema {
        
        public var minCount: Int
        public var maxCount: Int?
        
        public init(minCount: Int, maxCount: Int?) {
            self.minCount = minCount
            self.maxCount = maxCount
        }
        
        var matchesEmpty: Bool {
            fatalError()
        }
        var matchesNotEmpty: Bool {
            fatalError()
        }
        
        func buildSubMatcher() -> SubMatcher {
            fatalError() // abstract
        }
    }
    
    public enum Update<U> {
        
        case none
        case change((inout T,U) -> ())
        case initialization((U) -> T)
    }
    
    public enum SubUpdate {
        
        case none
        case change((inout T) -> ())
        case initialization(() -> T)
    }
    
    public class TypedSubSchema<U>: SubSchema {
        
        public var schema: Schema<U>
        public var update: Update<U>
        
        public init(schema: Schema<U>, minCount: Int, maxCount: Int?, update: Update<U>) {
            
            self.schema = schema
            self.update = update
            
            super.init(minCount: minCount, maxCount: maxCount)
        }
        
        override var matchesEmpty: Bool {
            return schema.matchesEmpty
        }
        override var matchesNotEmpty: Bool {
            return schema.matchesNotEmpty
        }
        
        override func buildSubMatcher() -> SubMatcher {
            
            return TypedSubMatcher(schema: self.schema, update: self.update)
        }
        
        private class TypedSubMatcher: SubMatcher {
            
            private let matcher: Schema<U>.Matcher
            private let update: Update<U>
            
            init(schema: Schema<U>, update: Update<U>) {
                
                self.matcher = schema.buildMatcher()
                self.update = update
            }
            
            override var isMatching: Bool {
                return matcher.isMatching
            }
            
            override var currentUpdate: SubUpdate {
                
                guard let currentValue = self.matcher.currentValue else {
                    return SubUpdate.none
                }
                
                let update = self.update
                
                switch update {
                    
                case .none:
                    return SubUpdate.none
                    
                case .change(let change):
                    return SubUpdate.change({ (parentValue: inout T) in
                        change(&parentValue, currentValue)
                    })
                    
                case .initialization(let initialization):
                    return SubUpdate.initialization({ () -> T in
                        return initialization(currentValue)
                    })
                    
                }
            }
            
            override func matchNextToken(_ token: Token) -> MatchingStatus {
                
                let status = self.matcher.matchNextToken(token)
                
                /* We have to convert the status from Schema<U>.MatchingStatus to Schema<T>.MatchingStatus */
                switch status {
                    
                case .canContinue:
                    return Schema<T>.MatchingStatus.canContinue
                    
                case .mustStop:
                    return Schema<T>.MatchingStatus.mustStop
                }
            }
        }
    }
    
    public class ValueSubSchema: SubSchema {
        
        public var accept: (Token) -> Bool
        public var update: Update<Token>
        
        public init(accept: @escaping (Token) -> Bool, minCount: Int, maxCount: Int?, update: Update<Token>) {
            
            self.accept = accept
            self.update = update
            
            super.init(minCount: minCount, maxCount: maxCount)
        }
        
        override var matchesEmpty: Bool {
            return false
        }
        override var matchesNotEmpty: Bool {
            return true
        }
        
        override func buildSubMatcher() -> SubMatcher {
            
            return ValueSubMatcher(accept: self.accept, update: self.update)
        }
        
        class ValueSubMatcher: SubMatcher {
            
            private let accept: (Token) -> Bool
            private let update: Update<Token>
            
            private var token: Token? = nil
            
            init(accept: @escaping (Token) -> Bool, update: Update<Token>) {
                
                self.accept = accept
                self.update = update
            }
            
            override var isMatching: Bool {
                
                guard let token = self.token else {
                    return false
                }
                
                return self.accept(token)
            }
            
            override var currentUpdate: SubUpdate {
                
                guard self.isMatching else {
                    return SubUpdate.none
                }
                
                let update = self.update
                let token = self.token!
                
                switch update {
                    
                case .none:
                    return SubUpdate.none
                    
                case .change(let change):
                    return SubUpdate.change({ (parentValue: inout T) in
                        return change(&parentValue, token)
                    })
                    
                case .initialization(let initialization):
                    return SubUpdate.initialization({ () -> T in
                        return initialization(token)
                    })
                }
            }
            
            override func matchNextToken(_ token: Token) -> MatchingStatus {
                
                self.token = token
                return MatchingStatus.mustStop
            }
        }
    }
    
    public func parse(_ string: HString) -> T? {
        
        let tokenizer = Tokenizer(string: string)
        
        let matcher = self.buildMatcher()
        var status = MatchingStatus.canContinue
        
        while let token = tokenizer.readNextToken() {
            
            guard status == MatchingStatus.canContinue else {
                return nil
            }
            
            status = matcher.matchNextToken(token)
        }
        
        return matcher.currentValue
    }
    
    private func buildMatcher() -> Matcher {
        
        return Matcher(branches: self.branches, initialValue: self.initialValue, matchesEmpty: self.matchesEmpty)
    }
    
    private class Matcher {
        
        private let branches: [Branch]
        
        /* The branches are sorted from best to worst */
        private var branchMatchers: [BranchMatcher]
        
        var isMatching: Bool
        private var bestValue: T? = nil
        
        private struct BranchMatcher {
            
            let value: T?
            let subMatcher: SubMatcher
            let branchIndex: Int
            let subSchemaIndex: Int
            let occurrenceIndex: Int
        }
        
        init(branches: [Branch], initialValue: T?, matchesEmpty: Bool) {
            
            self.branches = branches
            self.branchMatchers = []
            
            self.isMatching = matchesEmpty
            if matchesEmpty {
                self.bestValue = initialValue
            }
            
            /* Make the first branch matchers */
            for i in 0..<branches.count {
                
                self.addBranchMatchersAtSchema(branchIndex: i, schemaIndex: 0, insertionIndex: self.branchMatchers.count, value: initialValue)
            }
        }
        
        var currentValue: T? {
            
            return self.bestValue
        }
        
        func matchNextToken(_ token: Token) -> MatchingStatus {
            
            self.isMatching = false
            self.bestValue = nil
            
            /* Update the matchers in the reverse order so we can remove and add elements from the list */
            for i in (0 ..< self.branchMatchers.count).reversed() {
                
                let subMatcher = self.branchMatchers[i].subMatcher
                
                /* Feed the matcher */
                let status = subMatcher.matchNextToken(token)
                
                /* Check if the sub-matcher has a match, and so can update our value */
                if subMatcher.isMatching {
                    
                    let newValue: T? = self.updateValue(self.branchMatchers[i].value, with: subMatcher.currentUpdate)
                    
                    /* Register this value, as ours if the branch is the best one */
                    if checkBranchMatcherIsValid(at: i) {
                        
                        self.isMatching = true
                        self.bestValue = newValue
                    }
                    
                    /* As it returns an update, it has a match, so we can consider it ends here */
                    self.addSubBranchMatchers(branchingFrom: self.branchMatchers[i], index: i, value: newValue)
                }
                
                /* If the matcher is over, remove it */
                if status == MatchingStatus.mustStop {
                    
                    self.branchMatchers.remove(at: i)
                }
            }
            
            return self.branchMatchers.isEmpty ? MatchingStatus.mustStop : MatchingStatus.canContinue
        }
        
        private func updateValue(_ possibleValue: T?, with update: SubUpdate) -> T? {
            
            switch update {
                
            case .none:
                
                return possibleValue
                
            case .change(let change):
                
                guard let value = possibleValue else {
                    return nil
                }
                
                var changingValue = value
                change(&changingValue)
                return changingValue
                
            case .initialization(let initialization):
                
                return initialization()
                
            }
        }
        
        private func checkBranchMatcherIsValid(at index: Int) -> Bool {
            
            /* Get the schema of the matcher */
            let branchMatcher = self.branchMatchers[index]
            let branchIndex = branchMatcher.branchIndex
            let subSchemaIndex = branchMatcher.subSchemaIndex
            let subSchemas = self.branches[branchIndex].subSchemas
            let subSchema = subSchemas[subSchemaIndex]
            
            /* Check the current matcher */
            guard branchMatcher.occurrenceIndex+1 >= subSchema.minCount else {
                return false
            }
            guard subSchema.maxCount == nil || branchMatcher.occurrenceIndex < subSchema.maxCount! else {
                return false
            }
            
            /* We assume the previous ones were good */
            
            /* Check if the following schemas can be absent */
            for i in (subSchemaIndex+1)..<subSchemas.count {
                
                let subSchema = subSchemas[i]
                
                guard subSchema.minCount == 0 || subSchema.matchesEmpty else {
                    return false
                }
            }
            
            return true
        }
        
        private func addSubBranchMatchers(branchingFrom branchMatcher: BranchMatcher, index: Int, value: T?) {
            
            /* Get the schema of the matcher */
            let branchIndex = branchMatcher.branchIndex
            let subSchemaIndex = branchMatcher.subSchemaIndex
            let subSchema = self.branches[branchIndex].subSchemas[subSchemaIndex]
            
            var insertionIndex = index + 1
            
            /* Consider the same schema restarts */
            if subSchema.maxCount == nil || branchMatcher.occurrenceIndex + 1 < subSchema.maxCount! {
                
                let newSubMatcher = subSchema.buildSubMatcher()
                let newBranchMatcher = BranchMatcher(value: value, subMatcher: newSubMatcher, branchIndex: branchIndex, subSchemaIndex: subSchemaIndex, occurrenceIndex: branchMatcher.occurrenceIndex + 1)
                
                self.branchMatchers.insert(newBranchMatcher, at: insertionIndex)
                insertionIndex += 1
            }
            
            /* Consider the next schema starts */
            if subSchemaIndex + 1 < self.branches[branchIndex].subSchemas.count &&
               branchMatcher.occurrenceIndex+1 >= subSchema.minCount {
                
                self.addBranchMatchersAtSchema(branchIndex: branchIndex, schemaIndex: subSchemaIndex+1, insertionIndex: insertionIndex, value: value)
            }
        }
        
        private func addBranchMatchersAtSchema(branchIndex: Int, schemaIndex: Int, insertionIndex: Int, value: T?) {
            
            let subSchemas = self.branches[branchIndex].subSchemas
            var currentInsertionIndex = insertionIndex
            
            for i in schemaIndex..<subSchemas.count {
                
                let subSchema = subSchemas[i]
                
                /* If the schema doesn't match anything, skip it */
                guard subSchema.matchesNotEmpty else {
                    
                    guard subSchema.matchesEmpty else {
                        break
                    }
                    
                    continue
                }
                
                /* Very small precaution */
                guard subSchema.maxCount == nil || subSchema.maxCount! > 0 else {
                    continue
                }
                
                /* Create a matcher starting that sub-schema */
                let subMatcher = subSchema.buildSubMatcher()
                let branchMatcher = BranchMatcher(value: value, subMatcher: subMatcher, branchIndex: branchIndex, subSchemaIndex: i, occurrenceIndex: 0)
                
                /* Insert */
                self.branchMatchers.insert(branchMatcher, at: currentInsertionIndex)
                currentInsertionIndex += 1
                
                /* If the minCount is 0, we must consider the next schema starts */
                guard subSchema.minCount == 0 || subSchema.matchesEmpty else {
                    break
                }
            }
        }
    }
    
}


