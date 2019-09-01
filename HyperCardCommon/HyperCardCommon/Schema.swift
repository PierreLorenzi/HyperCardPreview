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
    private var computation: ResultValue<T>? = nil
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
    
    private var possibleMatchingSchema: MatchingSchema<T>? = nil
    
    fileprivate var matchingSchema: MatchingSchema<T> {
        
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
        
        self.computation = ResultValue<T>(types: [], schemaIndexesToParameterIndexes: [:], compute: { (_:[Any?]) -> T in return compute() })
        
    }
    
    public func computeSequenceBySingle<A>(_ compute: @escaping (A) -> T) {
        
        let schemaElements = self.sequenceElements.enumerated().filter({ !$0.element.isConstant })
        guard schemaElements.count == 1 else {
            fatalError()
        }
        
        let keysAndValues = schemaElements.enumerated().map({ ($0.element.offset, $0.offset)  })
        let schemaIndexesToParameterIndexes = [Int: Int](uniqueKeysWithValues: keysAndValues)
        
        let types: [Any] = [A.self]
        
        self.computation = ResultValue<T>(types: types, schemaIndexesToParameterIndexes: schemaIndexesToParameterIndexes, compute: { (values: [Any?]) -> T in
            
            let a = values[0]! as! A
            
            return compute(a)
        })
        
    }
    
    public func computeSequenceBy<A,B>(_ compute: @escaping (A,B) -> T) {
        
        let schemaElements = self.sequenceElements.enumerated().filter({ !$0.element.isConstant })
        guard schemaElements.count == 2 else {
            fatalError()
        }
        
        let keysAndValues = schemaElements.enumerated().map({ ($0.element.offset, $0.offset)  })
        let schemaIndexesToParameterIndexes = [Int: Int](uniqueKeysWithValues: keysAndValues)
        
        let types: [Any] = [A.self, B.self]
        
        self.computation = ResultValue<T>(types: types, schemaIndexesToParameterIndexes: schemaIndexesToParameterIndexes, compute: { (values: [Any?]) -> T in
            
            let a = values[0]! as! A
            let b = values[1]! as! B
            
            return compute(a,b)
        })
    }
    
    public func computeSequenceBy<A,B,C>(_ compute: @escaping (A,B,C) -> T) {
        
        let schemaElements = self.sequenceElements.enumerated().filter({ !$0.element.isConstant })
        guard schemaElements.count == 3 else {
            fatalError()
        }
        
        let keysAndValues = schemaElements.enumerated().map({ ($0.element.offset, $0.offset)  })
        let schemaIndexesToParameterIndexes = [Int: Int](uniqueKeysWithValues: keysAndValues)
        
        let types: [Any] = [A.self, B.self, C.self]
        
        self.computation = ResultValue<T>(types: types, schemaIndexesToParameterIndexes: schemaIndexesToParameterIndexes, compute: { (values: [Any?]) -> T in
            
            let a = values[0]! as! A
            let b = values[1]! as! B
            let c = values[2]! as! C
            
            return compute(a,b,c)
        })
    }
    
    public func computeSequenceBy<A,B,C,D>(_ compute: @escaping (A,B,C,D) -> T) {
        
        let schemaElements = self.sequenceElements.enumerated().filter({ !$0.element.isConstant })
        guard schemaElements.count == 4 else {
            fatalError()
        }
        
        let keysAndValues = schemaElements.enumerated().map({ ($0.element.offset, $0.offset)  })
        let schemaIndexesToParameterIndexes = [Int: Int](uniqueKeysWithValues: keysAndValues)
        
        let types: [Any] = [A.self, B.self, C.self, D.self]
        
        self.computation = ResultValue<T>(types: types, schemaIndexesToParameterIndexes: schemaIndexesToParameterIndexes, compute: { (values: [Any?]) -> T in
            
            let a = values[0]! as! A
            let b = values[1]! as! B
            let c = values[2]! as! C
            let d = values[3]! as! D
            
            return compute(a,b,c,d)
        })
        
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
        
        return matcher.resultParsed
    }
    
    fileprivate func buildMatchingSchema() -> MatchingSchema<T> {
        
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
            
            let subSchemas = self.sequenceElements.map({ $0.createCountedSchema() })
            let sequenceSchema = SequenceSchema<T>(schemas: subSchemas, initialResultValue: self.computation!)
            return sequenceSchema
        }
            
        else {
            
            let elements = self.sequenceElements.isEmpty ? self.branchElements : [self.sequenceElements[0]] + self.branchElements
            
            let subSchemas: [MatchingSchema<T>] = elements.map { (element: SchemaElement<T>) -> MatchingSchema<T> in
                
                if element.isSameType && element.minCount == 1 && element.maxCount == 1 && !element.hasComputation() {
                    
                    return element.createSchemaSameType()
                }
                
                let sequenceSubSchema = element.createCountedSchema()
                let sequenceComputation = element.createBranchComputation()
                let sequenceSchema = SequenceSchema<T>(schemas: [sequenceSubSchema], initialResultValue: sequenceComputation)
                
                return sequenceSchema
            }
            
            let branchSchema = ChoiceSchema<T>(schemas: subSchemas)
            
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
    
    func createCountedSchema() -> CountedSchema<T> {
        fatalError()
    }
    
    func computeAsBranchWith<U>(_ compute: @escaping (U) -> T) {
        fatalError()
    }
    
    func createBranchComputation() -> ResultValue<T> {
        fatalError()
    }
    
    func assignNewType<U>(_ type: U.Type) -> SchemaElement<U> {
        fatalError()
    }
    
    func createSchemaSameType() -> MatchingSchema<T> {
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
    
    override func createCountedSchema() -> CountedSchema<T> {
        
        let schema = self.schema
        
        return CountedSchema(schemaProperty: Property<SubSchema<T>>(lazy: { () -> SubSchema<T> in
            
            return TypedSubSchema<T, U>(schema: schema.matchingSchema)
        }), minCount: self.minCount, maxCount: self.maxCount)
    }
    
    override func computeAsBranchWith<V>(_ compute: @escaping (V) -> T) {
        
        guard V.self == U.self else {
            fatalError()
        }
        
        self.computeBranch = (compute as! ((U) -> T))
    }
    
    override func createBranchComputation() -> ResultValue<T> {
        
        let compute = self.computeBranch!
        
        return ResultValue<T>(types: [U.self as Any], schemaIndexesToParameterIndexes: [0: 0], compute: { (values: [Any?]) -> T in
            
            let value = values[0]! as! U
            
            return compute(value)
        })
    }
    
    override func assignNewType<V>(_ type: V.Type) -> SchemaElement<V> {
        
        return TypedSchemaElement<V,U>(schema: self.schema, minCount: self.minCount, maxCount: self.maxCount, isConstant: self._isConstant)
    }
    
    override func createSchemaSameType() -> MatchingSchema<T> {
        
        return self.schema.matchingSchema as! MatchingSchema<T>
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
    
    override func createCountedSchema() -> CountedSchema<T> {
        
        let tokenFilter = self.tokenFilter
        
        return CountedSchema(schemaProperty: Property<SubSchema<T>>(lazy: { () -> SubSchema<T> in
            
            let schema = TokenSchema(isTokenValid: tokenFilter)
            return TypedSubSchema<T,Token>(schema: schema)
        }), minCount: self.minCount, maxCount: self.maxCount)
        
    }
    
    override func computeAsBranchWith<V>(_ compute: @escaping (V) -> T) {
        
        guard V.self == Token.self else {
            fatalError()
        }
        
        self.computeBranch = (compute as! ((Token) -> T))
    }
    
    override func createBranchComputation() -> ResultValue<T> {
        
        let compute = self.computeBranch!
        
        return ResultValue<T>(types: [Token.self as Any], schemaIndexesToParameterIndexes: [0: 0], compute: { (values: [Any?]) -> T in
            
            let value = values[0]! as! Token
            
            return compute(value)
        })
    }
    
    override func assignNewType<V>(_ type: V.Type) -> SchemaElement<V> {
        
        return TokenSchemaElement<V>(tokenFilter: self.tokenFilter, minCount: self.minCount, maxCount: self.maxCount, isConstant: self.isConstant)
    }
    
    override func createSchemaSameType() -> MatchingSchema<T> {
        
        return TokenSchema(isTokenValid: self.tokenFilter) as! MatchingSchema<T>
    }
    
    override func hasComputation() -> Bool {
        
        return self.computeBranch != nil
    }
}

private typealias MatcherMap = [ObjectIdentifier: MatcherCreation]

private typealias MatcherCallback = (AnyObject, inout MatcherMap) -> ()

private struct MatcherCreation {
    
    var matcher: AnyObject
    var isParent: Bool
}

private class MatchingSchema<T> {
    
    func buildMatcher(createdMatchers: inout MatcherMap) -> Matcher<T> {
        fatalError()
    }
}

private class Matcher<T> {
    
    var canContinue = false
    var resultParsed: T? = nil
    
    var changeCallbacks: [MatcherCallback] = []
    var cycleChangeCallbacks: [MatcherCallback] = []
    
    func addChangeCallback(_ callback: @escaping MatcherCallback) {
        self.changeCallbacks.append(callback)
    }
    
    func addCycleChangeCallback(_ callback: @escaping MatcherCallback) {
        self.cycleChangeCallbacks.append(callback)
    }
    
    func matchNextToken(_ token: Token, createdMatchers: inout MatcherMap) {
        fatalError()
    }
}

private class ComplexMatcher<T>: Matcher<T> {
    
    private var branches: [Branch]
    var resultMatcher: Matcher<T>?
    var isSendingCycleCallback = false
    
    private struct Branch {
        
        var matcher: Matcher<T>
        var isCycleConnection: Bool
        var isShared: Bool
        weak var developedFrom: Matcher<T>?
    }
    
    init(schema: MatchingSchema<T>, subSchemas: [MatchingSchema<T>], createdMatchers: inout MatcherMap) {
        
        self.branches = []
        
        super.init()
        
        self.createInitialBranches(schema: schema, subSchemas: subSchemas, createdMatchers: &createdMatchers)
    }
    
    private func createInitialBranches(schema: MatchingSchema<T>, subSchemas: [MatchingSchema<T>], createdMatchers: inout MatcherMap) {
        
        /* Declare myself as created, and parent of the subsequent creations */
        let schemaIdentity = ObjectIdentifier(schema)
        createdMatchers[schemaIdentity] = MatcherCreation(matcher: self, isParent: true)
        
        /* Create the initial branches */
        self.createBranches(at: 0, with: subSchemas, createdMatchers: &createdMatchers, developedFrom: nil)
        self.updateState(createdMatchers: &createdMatchers)
        
        /* Declare myself still as created, but not anymore as parent */
        createdMatchers[schemaIdentity]!.isParent = false
    }
    
    private func createBranches(at index: Int, with schemas: [MatchingSchema<T>], createdMatchers: inout MatcherMap, developedFrom: Matcher<T>?) {
        
        let changeCallback: MatcherCallback = { [unowned self] (matcher: AnyObject, createdMatchers: inout MatcherMap) in self.receiveChangeCallback(from: matcher, createdMatchers: &createdMatchers) }
        
        var insertionIndex = index
        
        for schema in schemas {
            
            let branch: Branch
            
            /* Check if this schema has already been instanciated */
            if let matcherCreation = createdMatchers[ObjectIdentifier(schema)] {
                
                /* If the schema is a direct ancestor, we're making a cycle */
                let isCycleConnection = matcherCreation.isParent
                
                /* Use the already existing matcher as matcher */
                let matcher = matcherCreation.matcher as! Matcher<T>
                if isCycleConnection {
                    matcher.addCycleChangeCallback(changeCallback)
                }
                else {
                    matcher.addChangeCallback(changeCallback)
                }
                
                branch = Branch(matcher: matcher, isCycleConnection: isCycleConnection, isShared: true, developedFrom: developedFrom)
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
        guard let developingMatcher = branch.matcher as? DevelopingMatcher<T> else {
            return
        }
        
        /* Add the sub-branches */
        let subSchemas = developingMatcher.subSchemas
        self.createBranches(at: index + 1, with: subSchemas, createdMatchers: &createdMatchers, developedFrom: branch.matcher)
    }
    
    private func receiveChangeCallback(from matcher: AnyObject, createdMatchers: inout MatcherMap) {
        
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
        
        let didStatusChange = (newResultMatcher !== self.resultMatcher || newCanContinue != self.canContinue)
        
        self.resultMatcher = newResultMatcher
        self.resultParsed = newResultMatcher?.resultParsed
        self.canContinue = newCanContinue
        
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
    
    override func matchNextToken(_ token: Token, createdMatchers: inout MatcherMap) {
        
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

private class SequenceSchema<T>: MatchingSchema<T> {
    
    private let schemas: [CountedSchema<T>]
    private let initialResultValue: ResultValue<T>
    
    init(schemas: [CountedSchema<T>], initialResultValue: ResultValue<T>) {
        
        self.schemas = schemas
        self.initialResultValue = initialResultValue
    }
    
    override func buildMatcher(createdMatchers: inout MatcherMap) -> Matcher<T> {
        
        return SequenceElementMatcher(schemas: self.schemas, schemaIndex: 0, occurrenceIndex: 0, resultValue: self.initialResultValue, createdMatchers: &createdMatchers)
    }
}

private struct ResultValue<T> {
    
    private var values: [Any?]
    private let types: [Any]
    private let schemaIndexesToParameterIndexes: [Int: Int]
    private let computeWithParameters: ([Any?]) -> T
    
    init(types: [Any], schemaIndexesToParameterIndexes: [Int: Int], compute: @escaping ([Any?]) -> T) {
        
        self.values = [Any?](repeating: nil, count: types.count)
        self.types = types
        self.schemaIndexesToParameterIndexes = schemaIndexesToParameterIndexes
        self.computeWithParameters = compute
    }
    
    // Returns non-nil only if all parameters have a value or are marked absent
    func compute() -> T? {
        return self.computeWithParameters(self.values)
    }
    
    mutating func setValue<U>(_ value: U, at schemaIndex: Int) -> () {
        
        guard let index = self.schemaIndexesToParameterIndexes[schemaIndex] else {
            return
        }
        
        let parameterType = self.types[index]
        
        if parameterType is U.Type {
            
            self.values[index] = Optional.some(value)
        }
        else if parameterType is (U?).Type {
            
            self.values[index] = Optional.some(Optional.some(value) as Any)
        }
        else if parameterType is [U].Type {
            
            let possibleList = self.values[index] as! [U]?
            
            let newList: [U]
            if let list = possibleList {
                
                var changingList = list
                changingList.append(value)
                
                newList = changingList
            }
            else {
                
                newList = [value]
            }
            
            self.values[index] = Optional.some(newList)
        }
        else {
            
            fatalError()
        }
    }
    
    mutating func markParameterAbsent<U>(at schemaIndex: Int, type: U.Type) -> () {
        
        guard let index = self.schemaIndexesToParameterIndexes[schemaIndex] else {
            return
        }
        
        let parameterType = self.types[index]
        
        if parameterType is (U?).Type {
            
            self.values[index] = Optional.some(Optional<U>.none as Any)
        }
        else if parameterType is [U].Type {
            
            self.values[index] = Optional.some([U]())
        }
        else {
            
            fatalError()
        }
    }
}

private class DevelopingMatcher<T>: Matcher<T> {
    
    var subSchemas: [MatchingSchema<T>] = []
}

private class SubSchema<T> {
    
    func buildSubMatcher(createdMatchers: inout MatcherMap) -> SubMatcher<T> {
        fatalError()
    }
    
    func integrateResultAbsence(at index: Int, in resultValue: inout ResultValue<T>) {
        fatalError()
    }
}

private class SubMatcher<T>: Matcher<Any> {
    
    func integrateResult(at index: Int, in resultValue: inout ResultValue<T>) {
        fatalError()
    }
}

private class TypedSubSchema<T,U>: SubSchema<T> {
    
    private let schema: MatchingSchema<U>
    
    init(schema: MatchingSchema<U>) {
        
        self.schema = schema
        
        super.init()
    }
    
    override func buildSubMatcher(createdMatchers: inout MatcherMap) -> SubMatcher<T> {
        
        let matcher = self.schema.buildMatcher(createdMatchers: &createdMatchers)
        
        return TypedSubMatcher(matcher: matcher)
    }
    
    override func integrateResultAbsence(at index: Int, in resultValue: inout ResultValue<T>) {
        
        resultValue.markParameterAbsent(at: index, type: U.self)
    }
}

private class TypedSubMatcher<T, U>: SubMatcher<T> {
    
    private let matcher: Matcher<U>
    
    init(matcher: Matcher<U>) {
        
        self.matcher = matcher
        
        super.init()
        
        self.updateState()
    }
    
    private func updateState() {
        
        self.canContinue = self.matcher.canContinue
        self.resultParsed = self.matcher.resultParsed
    }
    
    override func matchNextToken(_ token: Token, createdMatchers: inout MatcherMap) {
        
        self.matcher.matchNextToken(token, createdMatchers: &createdMatchers)
        
        self.updateState()
    }
    
    override func integrateResult(at index: Int, in resultValue: inout ResultValue<T>) {
        
        guard let result = self.matcher.resultParsed else {
            return
        }
        
        resultValue.setValue(result, at: index)
    }
}

private struct CountedSchema<T> {
    
    var schemaProperty: Property<SubSchema<T>>
    var schema: SubSchema<T> {
        return self.schemaProperty.value
    }
    var minCount: Int
    var maxCount: Int?
}

private class SequenceElementMatcher<T>: DevelopingMatcher<T> {
    
    private let subMatcher: SubMatcher<T>
    private let schemas: [CountedSchema<T>]
    private let schemaIndex: Int
    private let occurrenceIndex: Int
    private var resultValue: ResultValue<T>
    private var isNew = true
    
    
    init(schemas: [CountedSchema<T>], schemaIndex: Int, occurrenceIndex: Int, resultValue: ResultValue<T>, createdMatchers: inout MatcherMap) {
        
        self.subMatcher = schemas[schemaIndex].schema.buildSubMatcher(createdMatchers: &createdMatchers)
        self.schemas = schemas
        self.schemaIndex = schemaIndex
        self.occurrenceIndex = occurrenceIndex
        self.resultValue = resultValue
        
        super.init()
        
        self.updateState(createdMatchers: &createdMatchers)
    }
    
    private func updateState(createdMatchers: inout MatcherMap) {
        
        self.canContinue = self.subMatcher.canContinue
        self.resultParsed = self.resultValue.compute()
        self.subSchemas = self.listSubSchemas(createdMatchers: &createdMatchers)
    }
    
    private func listSubSchemas(createdMatchers: inout MatcherMap) -> [MatchingSchema<T>] {
        
        var subSchemas: [MatchingSchema<T>] = []
        
        if self.subMatcher.resultParsed != nil {
            
            /* Consider the matcher as finished, so we include its result in the computation */
            var newResultValue = self.resultValue
            self.subMatcher.integrateResult(at: self.schemaIndex, in: &newResultValue)
            
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
            self.schemas[self.schemaIndex].schema.integrateResultAbsence(at: self.schemaIndex, in: &newResultValue)
            
            /* Make a sub-branch where the next schema starts */
            if let subSchema = self.buildNextSubSchema(newResultValue: newResultValue, createdMatchers: &createdMatchers) {
                subSchemas.append(subSchema)
            }
        }
        
        return subSchemas
    }
    
    private func buildSubSchemaNextOccurrence(newResultValue: ResultValue<T>, createdMatchers: inout MatcherMap) -> MatchingSchema<T>? {
        
        let schema = self.schemas[self.schemaIndex]
        
        /* Check if the schema can start again */
        let newOccurrenceIndex = 1 + self.occurrenceIndex
        guard schema.maxCount == nil || newOccurrenceIndex < schema.maxCount! else {
            return nil
        }
        
        return SequenceElementSchema<T>(schemas: self.schemas, schemaIndex: self.schemaIndex, occurrenceIndex: newOccurrenceIndex, resultValue: newResultValue)
    }
    
    private func buildNextSubSchema(newResultValue: ResultValue<T>, createdMatchers: inout MatcherMap) -> MatchingSchema<T>? {
        
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
    
    override func matchNextToken(_ token: Token, createdMatchers: inout MatcherMap) {
        
        
        self.subMatcher.matchNextToken(token, createdMatchers: &createdMatchers)
        
        self.isNew = false
        self.updateState(createdMatchers: &createdMatchers)
    }
}

private class SequenceElementSchema<T>: MatchingSchema<T> {
    
    private let schemas: [CountedSchema<T>]
    private let schemaIndex: Int
    private let occurrenceIndex: Int
    private var resultValue: ResultValue<T>
    
    init(schemas: [CountedSchema<T>], schemaIndex: Int, occurrenceIndex: Int, resultValue: ResultValue<T>) {
        
        self.schemas = schemas
        self.schemaIndex = schemaIndex
        self.occurrenceIndex = occurrenceIndex
        self.resultValue = resultValue
    }
    
    override func buildMatcher(createdMatchers: inout MatcherMap) -> Matcher<T> {
        
        return SequenceElementMatcher(schemas: self.schemas, schemaIndex: self.schemaIndex, occurrenceIndex: self.occurrenceIndex, resultValue: self.resultValue, createdMatchers: &createdMatchers)
    }
}

private class TokenSchema: MatchingSchema<Token> {
    
    private let isTokenValid: (Token) -> Bool
    
    init(isTokenValid: @escaping (Token) -> Bool) {
        
        self.isTokenValid = isTokenValid
    }
 
    override func buildMatcher(createdMatchers: inout MatcherMap) -> Matcher<Token> {
        
        return TokenMatcher(isTokenValid: self.isTokenValid)
    }
}

private class TokenMatcher: Matcher<Token> {
    
    private let isTokenValid: (Token) -> Bool
    
    init(isTokenValid: @escaping (Token) -> Bool) {
        
        self.isTokenValid = isTokenValid
        
        super.init()
        
        self.canContinue = true
        self.resultParsed = nil
    }
    
    override func matchNextToken(_ token: Token, createdMatchers: inout MatcherMap) {
        
        if self.isTokenValid(token) {
            
            self.resultParsed = token
        }
        
        self.canContinue = false
    }
    
}

private class ChoiceSchema<T>: MatchingSchema<T> {
    
    private let schemas: [MatchingSchema<T>]
    
    init(schemas: [MatchingSchema<T>]) {
        self.schemas = schemas
    }
    
    override func buildMatcher(createdMatchers: inout MatcherMap) -> Matcher<T> {
        
        return ComplexMatcher(schema: self, subSchemas: self.schemas, createdMatchers: &createdMatchers)
    }
}


