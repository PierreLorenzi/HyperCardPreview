//
//  Matching.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 26/08/2019.
//  Copyright © 2019 Pierre Lorenzi. All rights reserved.
//


public final class Schema<T> {
    
    private var sequenceElements: [SchemaElement<T>] = []
    private var branchElements: [SchemaElement<T>] = []
    private var computation: ResultValue? = nil
    private var _isConstant: Bool?
    
    public init() {}
    
    public init(_ other: Schema<T>) {
        
        self.sequenceElements = other.sequenceElements
        self.branchElements = other.branchElements
        self.computation = other.computation
    }
    
    public init(schemaLiteral: Schema<Void>) {
        
        self.sequenceElements = schemaLiteral.sequenceElements.map { $0.assignNewType(T.self) }
        self.branchElements = schemaLiteral.branchElements.map { $0.assignNewType(T.self) }
    }
    
    private var possibleMatchingSchema: MatchingSchema? = nil
    
    fileprivate var matchingSchema: MatchingSchema {
        
        guard let matchingSchema = self.possibleMatchingSchema else {
            
            let matchingSchema = self.buildMatchingSchema()
            self.possibleMatchingSchema = matchingSchema
            return matchingSchema
        }
        
        return matchingSchema
    }
    
    public func appendTokenKind(filterBy isTokenValid: @escaping (Token) -> Bool, minCount: Int, maxCount: Int?, isConstant: Bool) {
        
        let element = TokenSchemaElement<T>(tokenFilter: isTokenValid, minCount: minCount, maxCount: maxCount, isConstant: isConstant)
        
        self.sequenceElements.append(element)
    }
    
    public func appendSchema<U>(_ schema: Schema<U>, minCount: Int, maxCount: Int?, isConstant: Bool?) {
        
        let element = TypedSchemaElement<T,U>(schema: schema, minCount: minCount, maxCount: maxCount, isConstant: isConstant)
        
        self.sequenceElements.append(element)
    }
    
    public func appendBranchedSchema<U>(_ schema: Schema<U>) {
        
        let element = TypedSchemaElement<T,U>(branchSchema: schema)
        
        self.branchElements.append(element)
    }
    
    public func computeSequenceBy(_ compute: @escaping () -> T) {
        
        // TODO
        
    }
    
    public func computeSequenceBySingle<A>(_ compute: @escaping (A) -> T) {
        
        // TODO
        
    }
    
    public func computeSequenceBy<A,B>(_ compute: @escaping (A,B) -> T) {
        
        // TODO
    }
    
    public func computeSequenceBy<A,B,C>(_ compute: @escaping (A,B,C) -> T) {
        
        // TODO
    }
    
    public func computeSequenceBy<A,B,C,D>(_ compute: @escaping (A,B,C,D) -> T) {
        
        // TODO
        
    }
    
    public func computeBranchBy<U>(for schema: Schema<U>, _ compute: @escaping (U) -> T) {
        
        let elements = [self.sequenceElements[0]] + self.branchElements
        
        for element in elements {
            
            if element.isSchema(schema) {
                
                element.computeAsBranchWith(compute)
                break
            }
        }
    }
    
    public func parse(_ string: HString) -> T? {
        
        let tokens = TokenSequence(string)
        let schema = self.matchingSchema
        var initialCreatedMatchers: MatcherMap = [:]
        let matcher = schema.buildMatcher(createdMatchers: &initialCreatedMatchers)
        
        for token in tokens {
            
            if !matcher.canContinue {
                return nil
            }
            
            /* Init the map of the created matchers after that token */
            var createdMatchers: MatcherMap = [:]
            
            matcher.matchNextToken(token, createdMatchers: &createdMatchers)
        }
        
        return matcher.resultParsed as! T?
    }
    
    fileprivate func buildMatchingSchema() -> MatchingSchema {
        
        if self.branchElements.isEmpty {
            
            /* To simplify, if we are reduced to one schema, set to it */
            if self.sequenceElements.count == 1 && self.sequenceElements[0].isSameType && self.sequenceElements[0].minCount == 1 && self.sequenceElements[0].maxCount == 1 &&
                self.computation == nil {
                
                return self.sequenceElements[0].createSchemaSameType()
            }
            
            /* If there is only one value with the same type as us, get it */
            if self.computation == nil, self.sequenceElements.filter({ !$0.isConstant }).count == 1, let index = self.sequenceElements.firstIndex(where: { !$0.isConstant }), self.sequenceElements[index].isSameType, self.sequenceElements[index].minCount == 1, self.sequenceElements[index].maxCount == 1 {
                
                self.computeSequenceBySingle { (value: T) -> T in
                    return value
                }
            }
            
            /* Handle untyped schemas */
            if T.self == Void.self && self.computation == nil {
                
                self.computeSequenceBy({ () -> Void in return () } as! () -> T)
            }
            
            let subSchemas: [CountedSchema] = self.sequenceElements.map({ (element: SchemaElement<T>) -> CountedSchema in CountedSchema(schemaProperty: Property<MatchingSchema>(lazy: { element.createSubSchema() }), minCount: element.minCount, maxCount: element.maxCount, resultParameterIndex: nil) })
            let sequenceSchema = SequenceSchema(schemas: subSchemas, initialResultValue: self.computation!)
            return sequenceSchema
        }
        
        else {
            
            let elements = self.sequenceElements.isEmpty ? self.branchElements : [self.sequenceElements[0]] + self.branchElements
            
            let subSchemas: [MatchingSchema] = elements.map { (element: SchemaElement<T>) -> MatchingSchema in
                
                if element.isSameType && element.minCount == 1 && element.maxCount == 1 && !element.hasComputation() {
                    
                    return element.createSubSchema()
                }
                
                let sequenceComputation = element.createBranchComputation()
                let sequenceSchema = SequenceSchema(schemas: [CountedSchema(schemaProperty: Property<MatchingSchema>(lazy: { return element.createSubSchema() }), minCount: element.minCount, maxCount: element.maxCount, resultParameterIndex: nil)], initialResultValue: sequenceComputation)
                
                return sequenceSchema
            }
            
            let branchSchema = ChoiceSchema(schemas: subSchemas)
            
            return branchSchema
        }
    }
    
    var isConstant: Bool {
        
        get {
            return self._isConstant ?? (self.sequenceElements.allSatisfy({ $0.isConstant }) && self.branchElements.isEmpty)
        }
        set {
            self._isConstant = newValue
        }
    }
}

private class SchemaElement<T> {
    
    let minCount: Int
    let maxCount: Int?
    let isSameType: Bool
    
    var isConstant: Bool {
        fatalError()
    }
    
    func isSchema<U>(_ schema: Schema<U>) -> Bool {
        fatalError()
    }
    
    func createSubSchema() -> MatchingSchema {
        fatalError()
    }
    
    func computeAsBranchWith<U>(_ compute: @escaping (U) -> T) {
        fatalError()
    }
    
    func createBranchComputation() -> ResultValue {
        fatalError()
    }
    
    func assignNewType<U>(_ type: U.Type) -> SchemaElement<U> {
        fatalError()
    }
    
    func createSchemaSameType() -> MatchingSchema {
        fatalError()
    }
    
    func hasComputation() -> Bool {
        fatalError()
    }
    
    init(minCount: Int, maxCount: Int?, isSameType: Bool) {
        self.minCount = minCount
        self.maxCount = maxCount
        self.isSameType = isSameType
    }
}

private class TypedSchemaElement<T,U>: SchemaElement<T> {
    
    private var schema: Schema<U>
    private var computeBranch: ((U) -> T)? = nil
    private var _isConstant: Bool?
    
    init(schema: Schema<U>, minCount: Int, maxCount: Int?, isConstant: Bool?) {
        
        self.schema = schema
        self._isConstant = isConstant
        
        super.init(minCount: minCount, maxCount: maxCount, isSameType: T.self == U.self)
    }
    
    init(branchSchema: Schema<U>) {
        
        self.schema = branchSchema
        
        super.init(minCount: 1, maxCount: 1, isSameType: T.self == U.self)
    }
    
    override var isConstant: Bool {
        return self._isConstant ?? ((self.schema.isConstant && self.minCount == self.maxCount) || U.self == Void.self)
    }
    
    override func isSchema<V>(_ schema: Schema<V>) -> Bool {
        
        return schema === self.schema
    }
    
    override func createSubSchema() -> MatchingSchema {
        
        return self.schema.matchingSchema
    }
    
    override func computeAsBranchWith<V>(_ compute: @escaping (V) -> T) {
        
        guard V.self == U.self else {
            fatalError()
        }
        
        self.computeBranch = (compute as! ((U) -> T))
    }
    
    override func createBranchComputation() -> ResultValue {
        
        // TODO
        fatalError()
    }
    
    override func hasComputation() -> Bool {
        
        return self.computeBranch != nil
    }
}

private class TokenSchemaElement<T>: SchemaElement<T> {
    
    private var tokenFilter: (Token) -> Bool
    private var computeBranch: ((Token) -> T)? = nil
    let _isConstant: Bool
    
    init(tokenFilter: @escaping (Token) -> Bool, minCount: Int, maxCount: Int?, isConstant: Bool) {
        
        self.tokenFilter = tokenFilter
        self._isConstant = isConstant
        
        super.init(minCount: minCount, maxCount: maxCount, isSameType: T.self == Token.self)
    }
    
    override var isConstant: Bool {
        /* Even if a constant can appear several times, we don't consider it an obvious variable */
        return self._isConstant
    }
    
    override func isSchema<U>(_ schema: Schema<U>) -> Bool {
        return false
    }
    
    override func createSubSchema() -> MatchingSchema {
        
        return TokenSchema(isTokenValid: self.tokenFilter)
    }
    
    override func computeAsBranchWith<V>(_ compute: @escaping (V) -> T) {
        
        guard V.self == Token.self else {
            fatalError()
        }
        
        self.computeBranch = (compute as! ((Token) -> T))
    }
    
    override func createBranchComputation() -> ResultValue {
        
        // TODO
        fatalError()
    }
    
    override func hasComputation() -> Bool {
        
        return self.computeBranch != nil
    }
}

private typealias MatcherMap = [ObjectIdentifier: MatcherCreation]

private typealias MatcherCallback = (Matcher, inout MatcherMap) -> ()

private struct MatcherCreation {
    
    var matcher: Matcher
    var isParent: Bool
}

private protocol MatchingSchema: AnyObject {
    
    func buildMatcher(createdMatchers: inout MatcherMap) -> Matcher
}

private protocol Matcher: AnyObject {
    
    var canContinue: Bool { get }
    var resultParsed: Any? { get }
    
    func addChangeCallback(_: @escaping MatcherCallback)
    func addCycleChangeCallback(_: @escaping MatcherCallback)
    
    func matchNextToken(_ token: Token, createdMatchers: inout MatcherMap)
}

private protocol DevelopingMatcher: Matcher {
    
    var subSchemas: [MatchingSchema] { get }
}

private class ComplexMatcher: Matcher {
    
    private var branches: [Branch]
    private var changeCallbacks: [MatcherCallback] = []
    private var cycleChangeCallbacks: [MatcherCallback] = []
    var _canContinue: Bool
    var resultMatcher: Matcher?
    var isSendingCycleCallback = false
    
    private struct Branch {
        
        var matcher: Matcher
        var isCycleConnection: Bool
        var isShared: Bool
        weak var developedFrom: Matcher?
    }
    
    var canContinue: Bool {
        return self._canContinue
    }
    
    var resultParsed: Any? {
        return self.resultMatcher?.resultParsed
    }
    
    init(schemaIdentity: ObjectIdentifier, subSchemas: [MatchingSchema], createdMatchers: inout MatcherMap) {
        
        self.branches = []
        self._canContinue = false
        
        self.createInitialBranches(schemaIdentity: schemaIdentity, subSchemas: subSchemas, createdMatchers: &createdMatchers)
    }
    
    private func createInitialBranches(schemaIdentity: ObjectIdentifier, subSchemas: [MatchingSchema], createdMatchers: inout MatcherMap) {
        
        /* Declare myself as created, and parent of the subsequent creations */
        createdMatchers[schemaIdentity] = MatcherCreation(matcher: self, isParent: true)
        
        /* Create the initial branches */
        self.createBranches(at: 0, with: subSchemas, createdMatchers: &createdMatchers, developedFrom: nil)
        self.updateState(createdMatchers: &createdMatchers)
        
        /* Declare myself still as created, but not anymore as parent */
        createdMatchers[schemaIdentity]!.isParent = false
    }
    
    private func createBranches(at index: Int, with schemas: [MatchingSchema], createdMatchers: inout MatcherMap, developedFrom: Matcher?) {
        
        let changeCallback: MatcherCallback = { [unowned self] (matcher: Matcher, createdMatchers: inout MatcherMap) in self.receiveChangeCallback(from: matcher, createdMatchers: &createdMatchers) }
        
        var insertionIndex = index
        
        for schema in schemas {
            
            let branch: Branch
            
            /* Check if this schema has already been instanciated */
            if let matcherCreation = createdMatchers[ObjectIdentifier(schema)] {
                
                /* If the schema is a direct ancestor, we're making a cycle */
                let isCycleConnection = matcherCreation.isParent
                
                /* Use the already existing matcher as matcher */
                if isCycleConnection {
                    matcherCreation.matcher.addCycleChangeCallback(changeCallback)
                }
                else {
                    matcherCreation.matcher.addChangeCallback(changeCallback)
                }
                
                branch = Branch(matcher: matcherCreation.matcher, isCycleConnection: isCycleConnection, isShared: true, developedFrom: developedFrom)
            }
            else {
                
                /* Create a new matcher */
                let matcher = schema.buildMatcher(createdMatchers: &createdMatchers)
                
                matcher.addChangeCallback(changeCallback)
                
                branch = Branch(matcher: matcher, isCycleConnection: false, isShared: false, developedFrom: developedFrom)
            }
            
            /* Add the branch */
            self.branches.insert(branch, at: insertionIndex)
            
            insertionIndex += 1
        }
    }
    
    private func updateState(createdMatchers: inout MatcherMap) {
        
        /* As all the branches are in a new state, develop them */
        self.developAllBranches(createdMatchers: &createdMatchers)
        
        /* Update status */
        let _ = self.updateStatus(createdMatchers: &createdMatchers)
        
        /* Stabilize the cycles */
        self.stabilize(createdMatchers: &createdMatchers)
    }
    
    private func developAllBranches(createdMatchers: inout MatcherMap) {
        
        var index = 0
        
        while index < self.branches.count {
            
            developBranch(at: index, createdMatchers: &createdMatchers)
            
            index += 1
        }
    }
    
    private func developBranch(at index: Int, createdMatchers: inout MatcherMap) {
        
        let branch = self.branches[index]
        
        /* Check if there are sub-branches */
        guard let developingMatcher = branch.matcher as? DevelopingMatcher else {
            return
        }
        
        /* Add the sub-branches */
        let subSchemas = developingMatcher.subSchemas
        self.createBranches(at: index + 1, with: subSchemas, createdMatchers: &createdMatchers, developedFrom: branch.matcher)
    }
    
    private func receiveChangeCallback(from matcher: Matcher, createdMatchers: inout MatcherMap) {
        
        /* Remake the development of this matcher */
        let index = self.branches.firstIndex(where: { $0.matcher === matcher })!
        self.deleteMatcherDevelopment(at: index)
        self.developAllSubBranches(at: index, createdMatchers: &createdMatchers)
        
        /* If we are at the origin of that callback, let us in control of the update */
        guard !self.isSendingCycleCallback else {
            return
        }
        
        /* Update ourself */
        let didChange = self.updateStatus(createdMatchers: &createdMatchers)
        
        if didChange {
            
            /* Tell all our callbcaks */
            self.stabilize(createdMatchers: &createdMatchers)
            self.sendChangeCallbacks(createdMatchers: &createdMatchers)
        }
    }
    
    private func deleteMatcherDevelopment(at index: Int) {
        
        let endIndex = self.findDevelopmentEnd(at: index)
        
        self.branches.removeSubrange((index + 1) ..< endIndex)
    }
    
    private func findDevelopmentEnd(at index: Int) -> Int {
        
        let matcher = self.branches[index].matcher
        var i = index + 1
        
        while i < self.branches.count {
            
            guard self.branches[i].developedFrom === matcher else {
                break
            }
            
            i = self.findDevelopmentEnd(at: i)
        }
        
        return i
    }
    
    private func developAllSubBranches(at index: Int, createdMatchers: inout MatcherMap) {
        
        var i = index
        let suffixLength = self.branches.count - index
        
        while i <= self.branches.count - suffixLength {
            
            developBranch(at: i, createdMatchers: &createdMatchers)
            
            i += 1
        }
    }
    
    private func updateStatus(createdMatchers: inout MatcherMap) -> Bool {
        
        /* Update status */
        let newResultMatcher = self.branches.first(where: { $0.matcher.resultParsed != nil })?.matcher
        let newCanContinue = self.branches.first(where: { !$0.matcher.canContinue }) == nil
        
        let didStatusChange = (newResultMatcher !== self.resultMatcher || newCanContinue != self._canContinue)
        
        self.resultMatcher = newResultMatcher
        self._canContinue = newCanContinue
        
        return didStatusChange
    }
    
    private func stabilize(createdMatchers: inout MatcherMap) {
        
        self.isSendingCycleCallback = true
        
        var didChange = false
        
        /* Call the cycle callbacks until we don't change */
        repeat {
            
            self.sendCycleChangeCallbacks(createdMatchers: &createdMatchers)
            
            didChange = self.updateStatus(createdMatchers: &createdMatchers)
            
        } while didChange
        
        self.isSendingCycleCallback = false
    }
    
    private func sendCycleChangeCallbacks(createdMatchers: inout MatcherMap) {
        
        /* Save the value because it may change */
        let callbacks = self.cycleChangeCallbacks
        
        for callback in callbacks {
            
            callback(self, &createdMatchers)
        }
    }
    
    private func sendChangeCallbacks(createdMatchers: inout MatcherMap) {
        
        /* Save the value because it may change */
        let callbacks = self.changeCallbacks
        
        for callback in callbacks {
            
            callback(self, &createdMatchers)
        }
    }
    
    func addChangeCallback(_ callback: @escaping MatcherCallback) {
        
        self.changeCallbacks.append(callback)
    }
    
    func addCycleChangeCallback(_ callback: @escaping MatcherCallback) {
        
        self.cycleChangeCallbacks.append(callback)
    }
    
    func matchNextToken(_ token: Token, createdMatchers: inout MatcherMap) {
        
        /* Remove the finished branches. We can't do it before because they
         may have results */
        self.branches.removeAll(where: { !$0.matcher.canContinue })
        
        /* Feed the branches */
        for branch in self.branches {
            
            branch.matcher.matchNextToken(token, createdMatchers: &createdMatchers)
        }
        
        /* Develop branches and update status */
        self.updateState(createdMatchers: &createdMatchers)
    }
}

private class SequenceSchema: MatchingSchema {
    
    private let schemas: [CountedSchema]
    private let initialResultValue: ResultValue
    
    init(schemas: [CountedSchema], initialResultValue: ResultValue) {
        
        self.schemas = schemas
        self.initialResultValue = initialResultValue
    }
    
    func buildMatcher(createdMatchers: inout MatcherMap) -> Matcher {
        
        return SequenceElementMatcher(schemas: self.schemas, schemaIndex: 0, occurrenceIndex: 0, resultValue: self.initialResultValue, createdMatchers: &createdMatchers)
    }
}

private protocol ResultValue {
    
    // Returns non-nil only if all parameters have a value or are marked absent
    func compute() -> Any?
    
    mutating func setValue(_: Any, at: Int) -> ()
    mutating func markParameterAbsent(at: Int) -> ()
}

private struct CountedSchema {
    
    var schemaProperty: Property<MatchingSchema>
    var schema: MatchingSchema {
        return self.schemaProperty.value
    }
    var minCount: Int
    var maxCount: Int?
    var resultParameterIndex: Int?
}

private class SequenceElementMatcher: DevelopingMatcher {
    
    private let matcher: Matcher
    private let schemas: [CountedSchema]
    private let schemaIndex: Int
    private let occurrenceIndex: Int
    private var resultValue: ResultValue
    private var _canContinue: Bool
    private var _parsedResult: Any?
    private var _subSchemas: [MatchingSchema]
    private var isNew = true
    private var changeCallbacks: [MatcherCallback] = []
    private var cycleChangeCallbacks: [MatcherCallback] = []
    
    
    init(schemas: [CountedSchema], schemaIndex: Int, occurrenceIndex: Int, resultValue: ResultValue, createdMatchers: inout MatcherMap) {
        
        self.matcher = schemas[schemaIndex].schema.buildMatcher(createdMatchers: &createdMatchers)
        self.schemas = schemas
        self.schemaIndex = schemaIndex
        self.occurrenceIndex = occurrenceIndex
        self.resultValue = resultValue
        self._canContinue = false
        self._subSchemas = []
        
        self.updateState(createdMatchers: &createdMatchers)
    }
    
    private func updateState(createdMatchers: inout MatcherMap) {
        
        self._canContinue = self.matcher.canContinue
        self._parsedResult = self.resultValue.compute()
        self._subSchemas = self.listSubSchemas(createdMatchers: &createdMatchers)
    }
    
    private func listSubSchemas(createdMatchers: inout MatcherMap) -> [MatchingSchema] {
        
        var subSchemas: [MatchingSchema] = []
        
        if let result = self.matcher.resultParsed {
            
            /* Consider the matcher as finished, so we include its result in the computation */
            var newResultValue = self.resultValue
            if let index = self.schemas[self.schemaIndex].resultParameterIndex {
                newResultValue.setValue(result, at: index)
            }
            
            /* Make a sub-branch where the same schema restarts. Avoid repeating indefinitely
             an empty match */
            if !self.isNew {
                
                if let subSchema = self.buildSubSchemaNextOccurrence(newResultValue: newResultValue, createdMatchers: &createdMatchers) {
                    subSchemas.append(subSchema)
                }
            }
            
            /* Make a sub-branch where the next schema starts */
            if let subSchema = self.buildNextSubSchema(newResultValue: newResultValue, createdMatchers: &createdMatchers) {
                subSchemas.append(subSchema)
            }
            
        }
        
        /* If the matcher has matched nothing and the schema's min count is 0, consider that the next
         schema starts with no value */
        if self.isNew && self.schemas[self.schemaIndex].minCount == 0 && self.occurrenceIndex == 0 {
            
            /* Consider the matcher as absent, so we include it in the computation */
            var newResultValue = self.resultValue
            if let index = self.schemas[self.schemaIndex].resultParameterIndex {
                newResultValue.markParameterAbsent(at: index)
            }
            
            /* Make a sub-branch where the next schema starts */
            if let subSchema = self.buildNextSubSchema(newResultValue: newResultValue, createdMatchers: &createdMatchers) {
                subSchemas.append(subSchema)
            }
        }
        
        return subSchemas
    }
    
    private func buildSubSchemaNextOccurrence(newResultValue: ResultValue, createdMatchers: inout MatcherMap) -> MatchingSchema? {
        
        let schema = self.schemas[self.schemaIndex]
        
        /* Check if the schema can start again */
        let newOccurrenceIndex = 1 + self.occurrenceIndex
        guard schema.maxCount == nil || newOccurrenceIndex < schema.maxCount! else {
            return nil
        }
        
        return SequenceElementSchema(schemas: self.schemas, schemaIndex: self.schemaIndex, occurrenceIndex: newOccurrenceIndex, resultValue: newResultValue)
    }
    
    private func buildNextSubSchema(newResultValue: ResultValue, createdMatchers: inout MatcherMap) -> MatchingSchema? {
        
        let schema = self.schemas[self.schemaIndex]
        
        /* Check if the current schema has enough repeats */
        let newOccurrenceIndex = self.occurrenceIndex + (self.isNew ? 0 : 1)
        guard newOccurrenceIndex >= schema.minCount else {
            return nil
        }
        
        /* Check if there is a schema after */
        let newSchemaIndex = self.schemaIndex + 1
        guard newSchemaIndex < self.subSchemas.count else {
            return nil
        }
        
        return SequenceElementSchema(schemas: self.schemas, schemaIndex: newSchemaIndex, occurrenceIndex: newOccurrenceIndex, resultValue: newResultValue)
    }
    
    var subSchemas: [MatchingSchema] {
        return self._subSchemas
    }
    
    var canContinue: Bool {
        return self._canContinue
    }
    
    var resultParsed: Any? {
        return self._parsedResult
    }
    
    func addChangeCallback(_ callback: @escaping MatcherCallback) {
        self.changeCallbacks.append(callback)
    }
    
    func addCycleChangeCallback(_ callback: @escaping MatcherCallback) {
        self.cycleChangeCallbacks.append(callback)
    }
    
    func matchNextToken(_ token: Token, createdMatchers: inout MatcherMap) {
        
        
        self.matcher.matchNextToken(token, createdMatchers: &createdMatchers)
        
        self.isNew = false
        self.updateState(createdMatchers: &createdMatchers)
    }
}

private class SequenceElementSchema: MatchingSchema {
    
    private let schemas: [CountedSchema]
    private let schemaIndex: Int
    private let occurrenceIndex: Int
    private var resultValue: ResultValue
    
    init(schemas: [CountedSchema], schemaIndex: Int, occurrenceIndex: Int, resultValue: ResultValue) {
        
        self.schemas = schemas
        self.schemaIndex = schemaIndex
        self.occurrenceIndex = occurrenceIndex
        self.resultValue = resultValue
    }
    
    func buildMatcher(createdMatchers: inout MatcherMap) -> Matcher {
        
        return SequenceElementMatcher(schemas: self.schemas, schemaIndex: self.schemaIndex, occurrenceIndex: self.occurrenceIndex, resultValue: self.resultValue, createdMatchers: &createdMatchers)
    }
}

private class TokenSchema: MatchingSchema {
    
    private let isTokenValid: (Token) -> Bool
    
    init(isTokenValid: @escaping (Token) -> Bool) {
        
        self.isTokenValid = isTokenValid
    }
 
    func buildMatcher(createdMatchers: inout MatcherMap) -> Matcher {
        
        return TokenMatcher(isTokenValid: self.isTokenValid)
    }
}

private class TokenMatcher: Matcher {
    
    private let isTokenValid: (Token) -> Bool
    
    private var didMatch = false
    
    private var seenToken: Token? = nil
    
    init(isTokenValid: @escaping (Token) -> Bool) {
        
        self.isTokenValid = isTokenValid
    }
    
    var canContinue: Bool {
        return !self.didMatch
    }
    
    var resultParsed: Any? {
        return self.seenToken
    }
    
    func addChangeCallback(_: @escaping MatcherCallback) {
    }
    
    func addCycleChangeCallback(_: @escaping MatcherCallback) {
    }
    
    func matchNextToken(_ token: Token, createdMatchers: inout MatcherMap) {
        
        if self.isTokenValid(token) {
            
            self.seenToken = token
        }
        
        self.didMatch = true
    }
    
}

private class ChoiceSchema: MatchingSchema {
    
    private let schemas: [MatchingSchema]
    
    init(schemas: [MatchingSchema]) {
        self.schemas = schemas
    }
    
    func buildMatcher(createdMatchers: inout MatcherMap) -> Matcher {
        
        let schemaIdentity = ObjectIdentifier(self)
        
        return ComplexMatcher(schemaIdentity: schemaIdentity, subSchemas: self.schemas, createdMatchers: &createdMatchers)
    }
}


