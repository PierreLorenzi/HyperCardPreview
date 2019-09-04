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
    private var schemaIndexesToParameterIndexes: [Int: Int] = [:]
    private var _isConstant: Bool? = nil
    
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
    
    private var matchingSchema: MatchingSchema<T>?
    
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
        
        self.schemaIndexesToParameterIndexes = [:]
        self.computation = ResultValue<T>(types: [], compute: { (_:[Any?]) -> T in return compute() })
        
    }
    
    public func computeSequenceBySingle<A>(_ compute: @escaping (A) -> T) {
        
        let schemaElements = self.sequenceElements.enumerated().filter({ !$0.element.isConstant })
        guard schemaElements.count == 1 else {
            fatalError()
        }
        
        let keysAndValues = schemaElements.enumerated().map({ ($0.element.offset, $0.offset)  })
        self.schemaIndexesToParameterIndexes = [Int: Int](uniqueKeysWithValues: keysAndValues)
        
        let types: [Any] = [A.self]
        
        self.computation = ResultValue<T>(types: types, compute: { (values: [Any?]) -> T in
            
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
        self.schemaIndexesToParameterIndexes = [Int: Int](uniqueKeysWithValues: keysAndValues)
        
        let types: [Any] = [A.self, B.self]
        
        self.computation = ResultValue<T>(types: types, compute: { (values: [Any?]) -> T in
            
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
        self.schemaIndexesToParameterIndexes = [Int: Int](uniqueKeysWithValues: keysAndValues)
        
        let types: [Any] = [A.self, B.self, C.self]
        
        self.computation = ResultValue<T>(types: types, compute: { (values: [Any?]) -> T in
            
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
        self.schemaIndexesToParameterIndexes = [Int: Int](uniqueKeysWithValues: keysAndValues)
        
        let types: [Any] = [A.self, B.self, C.self, D.self]
        
        self.computation = ResultValue<T>(types: types, compute: { (values: [Any?]) -> T in
            
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
        let schema = self.buildMatchingSchema()
        var initialContext = MatchingContext(index: -1, createdMatchers: [:])
        let matcher = schema.buildMatcher(context: &initialContext)
        var index = 0
        
        for token in tokens {
            
            if !matcher.canContinue {
                return nil
            }
            
            /* Init the map of the created matchers after that token */
            var context = MatchingContext(index: index, createdMatchers: [:])
            
            matcher.matchNextToken(token, context: &context)
            
            index += 1
        }
        
        return matcher.resultParsed
    }
    
    fileprivate func buildMatchingSchema() -> MatchingSchema<T> {
        
        if let existingSchema = self.matchingSchema {
            return existingSchema
        }
        
        /* To simplify, if we are reduced to one schema, set to it */
        if self.sequenceElements.count == 1 && self.branchElements.isEmpty && self.sequenceElements[0].isSameType && self.sequenceElements[0].minCount == 1 && self.sequenceElements[0].maxCount == 1 &&
            self.computation == nil {
            
            let schema = self.sequenceElements[0].createSchemaSameType()
            self.matchingSchema = schema
            return schema
        }
        
        let schema = ComplexSchema<T>()
        self.matchingSchema = schema
        self.fillMatchingSchema(schema)
        return schema
    }
    
    fileprivate func fillMatchingSchema(_ schema: ComplexSchema<T>) {
        
        /* To simplify, if we are reduced to one schema, set to it */
        if self.sequenceElements.count == 1 && self.branchElements.isEmpty && self.sequenceElements[0].isSameType && self.sequenceElements[0].minCount == 1 && self.sequenceElements[0].maxCount == 1 &&
            self.computation == nil {
            
            return
        }
        
        if self.branchElements.isEmpty {
            
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
            
            var buildNextSchema: ((ResultValue<T>) -> SubSchema<T>)? = nil
            
            for i in (0..<self.sequenceElements.count).reversed() {
                
                let element = self.sequenceElements[i]
                let parameterIndex = self.schemaIndexesToParameterIndexes[i]
                
                let previousBuildNextSchema = buildNextSchema
                
                buildNextSchema = { (resultValue: ResultValue<T>) -> SubSchema<T> in
                    
                    element.createSequenceSubSchema(parameterIndex: parameterIndex, resultValue: resultValue, buildNextSchema: previousBuildNextSchema)
                }
            }
            
            let initialSubSchema = buildNextSchema!(self.computation!)
            schema.subSchemas = [initialSubSchema]
        }
            
        else {
            
            let elements = self.sequenceElements.isEmpty ? self.branchElements : [self.sequenceElements[0]] + self.branchElements
            
            let subSchemas: [SubSchema<T>] = elements.map { $0.createChoiceSubSchema() }
            
            schema.subSchemas = subSchemas
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
    
    func computeAsBranchWith<U>(_ compute: @escaping (U) -> T) {
        fatalError()
    }
    
    func createChoiceSubSchema() -> SubSchema<T> {
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
    
    func createSequenceSubSchema(parameterIndex: Int?, resultValue: ResultValue<T>, buildNextSchema: ((ResultValue<T>) -> SubSchema<T>)?) -> SubSchema<T> {
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
    
    override func computeAsBranchWith<V>(_ compute: @escaping (V) -> T) {
        
        guard V.self == U.self else {
            fatalError()
        }
        
        self.computeBranch = (compute as! ((U) -> T))
    }
    
    override func createChoiceSubSchema() -> SubSchema<T> {
        
        if self.computeBranch == nil && T.self != U.self {
            fatalError()
        }
        
        let matchingSchema = self.schema.buildMatchingSchema()
        let compute = self.computeBranch ?? { (value: U) -> T in
            return value as! T }
        
        return ChoiceSubSchema<T,U>(schema: matchingSchema, compute: compute)
    }
    
    override func assignNewType<V>(_ type: V.Type) -> SchemaElement<V> {
        
        return TypedSchemaElement<V,U>(schema: self.schema, minCount: self.minCount, maxCount: self.maxCount, isConstant: self._isConstant)
    }
    
    override func createSchemaSameType() -> MatchingSchema<T> {
        
        return self.schema.buildMatchingSchema() as! MatchingSchema<T>
    }
    
    override func hasComputation() -> Bool {
        
        return self.computeBranch != nil
    }
    
    override func createSequenceSubSchema(parameterIndex: Int?, resultValue: ResultValue<T>, buildNextSchema: ((ResultValue<T>) -> SubSchema<T>)?) -> SubSchema<T> {
        
        let matchingSchema = self.schema.buildMatchingSchema()
        return SequenceSubSchema(schema: matchingSchema, occurrenceCount: 1, minCount: self.minCount, maxCount: self.maxCount, parameterIndex: parameterIndex, resultValue: resultValue, buildNextSchema: buildNextSchema)
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
    
    override func computeAsBranchWith<V>(_ compute: @escaping (V) -> T) {
        
        guard V.self == Token.self else {
            fatalError()
        }
        
        self.computeBranch = (compute as! ((Token) -> T))
    }
    
    override func createChoiceSubSchema() -> SubSchema<T> {
        
        if self.computeBranch == nil && T.self != Token.self {
            fatalError()
        }
        
        let matchingSchema = TokenSchema(isTokenValid: self.tokenFilter)
        let compute = self.computeBranch ?? { (value: Token) -> T in
            return value as! T }
        
        return ChoiceSubSchema<T,Token>(schema: matchingSchema, compute: compute)
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
    
    override func createSequenceSubSchema(parameterIndex: Int?, resultValue: ResultValue<T>, buildNextSchema: ((ResultValue<T>) -> SubSchema<T>)?) -> SubSchema<T> {
        
        let matchingSchema = TokenSchema(isTokenValid: self.tokenFilter)
        return SequenceSubSchema(schema: matchingSchema, occurrenceCount: 1, minCount: self.minCount, maxCount: self.maxCount, parameterIndex: parameterIndex, resultValue: resultValue, buildNextSchema: buildNextSchema)
    }
}

private class MatchingSchema<T> {
    
    func buildMatcher(context: inout MatchingContext) -> Matcher<T> {
        fatalError()
    }
}

private struct MatchingContext {
    
    let index: Int
    var createdMatchers: [ObjectIdentifier: MatcherCreation]
}

private struct MatcherCreation {
    
    var matcher: AnyObject
    var isParent: Bool
}

private typealias MatcherCallback = (inout MatchingContext) -> ()

private class Matcher<T> {
    
    var canContinue = false
    var resultParsed: T? = nil
    var hasCycle = false
    
    var changeCallbacks: [MatcherCallback] = []
    var cycleChangeCallbacks: [MatcherCallback] = []
    
    func addChangeCallback(_ callback: @escaping MatcherCallback) {
        self.changeCallbacks.append(callback)
    }
    
    func addCycleChangeCallback(_ callback: @escaping MatcherCallback) {
        self.cycleChangeCallbacks.append(callback)
    }
    
    func callChangeCallbacks(context: inout MatchingContext) {
        let callbacks = self.changeCallbacks
        for callback in callbacks {
            callback(&context)
        }
    }
    
    func callCycleChangeCallbacks(context: inout MatchingContext) {
        let callbacks = self.cycleChangeCallbacks
        for callback in callbacks {
            callback(&context)
        }
    }
    
    func matchNextToken(_ token: Token, context: inout MatchingContext) {
        fatalError()
    }
}

private class TokenSchema: MatchingSchema<Token> {
    
    private let isTokenValid: (Token) -> Bool
    
    init(isTokenValid: @escaping (Token) -> Bool) {
        
        self.isTokenValid = isTokenValid
    }
    
    override func buildMatcher(context: inout MatchingContext) -> Matcher<Token> {
        
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
    
    override func matchNextToken(_ token: Token, context: inout MatchingContext) {
        
        if self.isTokenValid(token) {
            
            self.resultParsed = token
        }
        
        self.canContinue = false
    }
    
}

private class ComplexSchema<T>: MatchingSchema<T> {
    
    var subSchemas: [SubSchema<T>] = []
    
    override func buildMatcher(context: inout MatchingContext) -> Matcher<T> {
        
        return ComplexMatcher<T>(schema: self, subSchemas: self.subSchemas, context: &context)
    }
}

private class ComplexMatcher<T>: Matcher<T> {
    
    private var branches: [Branch]
    private var resultMatcher: SubMatcher<T>?
    private var isSendingCycleCallback = false
    private var currentIndex: Int
    
    private struct Branch {
        
        var matcher: SubMatcher<T>
        var isCycleConnection: Bool
        var isShared: Bool
        weak var developedFrom: SubMatcher<T>?
        var removeNextTime: Bool
    }
    
    init(schema: MatchingSchema<T>, subSchemas: [SubSchema<T>], context: inout MatchingContext) {
        
        self.branches = []
        self.currentIndex = context.index
        
        super.init()
        
        self.createInitialBranches(schema: schema, subSchemas: subSchemas, context: &context)
    }
    
    private func createInitialBranches(schema: MatchingSchema<T>, subSchemas: [SubSchema<T>], context: inout MatchingContext) {
        
        /* Declare myself as created, and parent of the subsequent creations */
        let schemaIdentity = ObjectIdentifier(schema)
        context.createdMatchers[schemaIdentity] = MatcherCreation(matcher: self, isParent: true)
        
        /* Create the initial branches */
        self.createBranches(at: 0, with: subSchemas, context: &context, developedFrom: nil)
        self.updateState(context: &context)
        
        /* Declare myself still as created, but not anymore as parent */
        context.createdMatchers[schemaIdentity]!.isParent = false
    }
    
    private func createBranches(at index: Int, with schemas: [SubSchema<T>], context: inout MatchingContext, developedFrom: SubMatcher<T>?) {
        
        var insertionIndex = index
        
        for schema in schemas {
            
            let branch: Branch
            
            /* Check if this schema has already been instanciated */
            if let matcherCreation = schema.findExistingMatcher(in: &context) {
                
                /* If the schema is a direct ancestor, we're making a cycle */
                let changeCallback = self.makeChangeCallback(for: matcherCreation.subMatcher)
                
                if matcherCreation.isParent {
                    matcherCreation.subMatcher.addCycleChangeCallback(changeCallback)
                }
                else {
                    matcherCreation.subMatcher.addChangeCallback(changeCallback)
                }
                
                branch = Branch(matcher: matcherCreation.subMatcher, isCycleConnection: matcherCreation.isParent, isShared: true, developedFrom: developedFrom, removeNextTime: false)
            }
            else {
                
                /* Create a new matcher */
                let matcher = schema.buildSubMatcher(context: &context)
                
                let changeCallback = self.makeChangeCallback(for: matcher)
                matcher.addChangeCallback(changeCallback)
                
                branch = Branch(matcher: matcher, isCycleConnection: false, isShared: false, developedFrom: developedFrom, removeNextTime: false)
            }
            
            /* Add the branch */
            self.branches.insert(branch, at: insertionIndex)
            
            insertionIndex += 1
        }
    }
    
    private func makeChangeCallback(for matcher: SubMatcher<T>) -> MatcherCallback {
        
        return { [unowned self] (context: inout MatchingContext) in
            
            self.receiveChangeCallback(from: matcher, context: &context)
        }
    }
    
    private func updateState(context: inout MatchingContext) {
        
        /* As all the branches are in a new state, develop them */
        self.developAllBranches(context: &context)
        
        /* Update status */
        let _ = self.updateStatus(context: &context)
        
        /* Stabilize the cycles */
        self.stabilize(context: &context)
    }
    
    private func developAllBranches(context: inout MatchingContext) {
        
        var index = 0
        
        while index < self.branches.count {
            
            guard !self.branches[index].isCycleConnection else {
                index += 1
                continue
            }
            
            developBranch(at: index, context: &context)
            
            index += 1
        }
    }
    
    private func developBranch(at index: Int, context: inout MatchingContext) {
        
        let branch = self.branches[index]
        let matcher = branch.matcher
        let subBranches = matcher.subBranches
        
        guard !subBranches.isEmpty else {
            return
        }
        
        /* Add the sub-branches */
        self.createBranches(at: index + 1, with: subBranches, context: &context, developedFrom: branch.matcher)
    }
    
    private func receiveChangeCallback(from matcher: AnyObject, context: inout MatchingContext) {
        
        /* If we're receiving notifications from shared objects before being called, ignore them */
        guard context.index == self.currentIndex else {
            return
        }
        
        /* Remake the development of this matcher */
        let index = self.branches.firstIndex(where: { $0.matcher === matcher })!
        self.deleteMatcherDevelopment(at: index)
        self.developAllSubBranches(at: index, context: &context)
        
        /* If we are at the origin of that callback, let us in control of the update */
        guard !self.isSendingCycleCallback else {
            return
        }
        
        /* Update ourself */
        let didChange = self.updateStatus(context: &context)
        
        if didChange {
            
            /* Tell all our callbcaks */
            self.stabilize(context: &context)
            self.sendChangeCallbacks(context: &context)
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
    
    private func developAllSubBranches(at index: Int, context: inout MatchingContext) {
        
        var i = index
        let suffixLength = self.branches.count - index
        
        while i <= self.branches.count - suffixLength {
            
            developBranch(at: i, context: &context)
            
            i += 1
        }
    }
    
    private func updateStatus(context: inout MatchingContext) -> Bool {
        
        /* Update status */
        let newResultMatcher = self.branches.first(where: { !$0.isCycleConnection && $0.matcher.resultParsed != nil })?.matcher
        let newCanContinue = self.branches.first(where: { !$0.isCycleConnection && $0.matcher.canContinue }) != nil
        let newHasCycle = self.branches.first(where: { $0.isCycleConnection || $0.matcher.hasCycle }) != nil
        
        let didStatusChange = (newResultMatcher !== self.resultMatcher || newCanContinue != self.canContinue || newHasCycle != self.hasCycle)
        
        self.resultMatcher = newResultMatcher
        self.resultParsed = newResultMatcher?.resultParsed
        self.canContinue = newCanContinue
        self.hasCycle = newHasCycle
        
        return didStatusChange
    }
    
    private func stabilize(context: inout MatchingContext) {
        
        guard !self.cycleChangeCallbacks.isEmpty else {
            return
        }
        
        self.isSendingCycleCallback = true
        
        var didChange = false
        
        /* Call the cycle callbacks until we don't change */
        repeat {
            
            self.callCycleChangeCallbacks(context: &context)
            didChange = self.updateStatus(context: &context)
            
        } while didChange
        
        self.isSendingCycleCallback = false
    }
    
    private func sendChangeCallbacks(context: inout MatchingContext) {
        
        /* Save the value because it may change */
        let callbacks = self.changeCallbacks
        
        for callback in callbacks {
            callback(&context)
        }
    }
    
    override func matchNextToken(_ token: Token, context: inout MatchingContext) {
        
        self.currentIndex = context.index
        
        /* Remove the finished branches. We can't do it before because they
         may have results */
        self.branches.removeAll(where: { (!$0.matcher.canContinue && !$0.isShared && !$0.matcher.hasCycle && !$0.isCycleConnection) || $0.removeNextTime })
        
        /* Feed the branches */
        for i in 0..<self.branches.count {
            
            self.branches[i].developedFrom = nil
            
            let branch = self.branches[i]
            
            /* Shared branches have a status shifted in time, se we must check them now */
            if branch.isShared && !branch.matcher.canContinue && !branch.matcher.hasCycle && !branch.isCycleConnection {
                self.branches[i].removeNextTime = true
            }
            
            guard !branch.isShared && !branch.isCycleConnection else {
                branch.matcher.dontMatchNextToken()
                continue
            }
            
            branch.matcher.matchNextToken(token, context: &context)
        }
        
        /* Develop branches and update status */
        self.updateState(context: &context)
    }
}

private class SubSchema<T> {
    
    func findExistingMatcher(in context: inout MatchingContext) -> SubMatcherCreation<T>? {
        fatalError()
    }
    
    func buildSubMatcher(context: inout MatchingContext) -> SubMatcher<T> {
        fatalError()
    }
}

private struct SubMatcherCreation<T> {
    
    var subMatcher: SubMatcher<T>
    var isParent: Bool
}

private class SubMatcher<T> {
    
    var canContinue: Bool {
        fatalError()
    }
    var resultParsed: T? {
        fatalError()
    }
    var hasCycle: Bool {
        fatalError()
    }
    var subBranches: [SubSchema<T>] {
        fatalError()
    }
    
    func addChangeCallback(_ callback: @escaping MatcherCallback) {
        fatalError()
    }
    
    func addCycleChangeCallback(_ callback: @escaping MatcherCallback) {
        fatalError()
    }
    
    func matchNextToken(_ token: Token, context: inout MatchingContext) {
        fatalError()
    }
    
    func dontMatchNextToken() {
        
    }
}

private class SequenceSubSchema<T,U>: SubSchema<T> {
    
    private let schema: MatchingSchema<U>
    private let occurrenceCount: Int
    private let minCount: Int
    private let maxCount: Int?
    private let parameterIndex: Int?
    private var resultValue: ResultValue<T>
    private let buildNextSchema: ((ResultValue<T>) -> SubSchema<T>)?
    
    init(schema: MatchingSchema<U>, occurrenceCount: Int, minCount: Int, maxCount: Int?, parameterIndex: Int?, resultValue: ResultValue<T>, buildNextSchema: ((ResultValue<T>) -> SubSchema<T>)?) {
        
        self.schema = schema
        self.occurrenceCount = occurrenceCount
        self.minCount = minCount
        self.maxCount = maxCount
        self.parameterIndex = parameterIndex
        self.resultValue = resultValue
        self.buildNextSchema = buildNextSchema
        
        super.init()
    }
    
    override func findExistingMatcher(in context: inout MatchingContext) -> SubMatcherCreation<T>? {
        
        let schemaIdentity: ObjectIdentifier = ObjectIdentifier(self.schema)
        guard let matcherCreation = context.createdMatchers[schemaIdentity] else {
            return nil
        }
        
        let matcher = matcherCreation.matcher as! Matcher<U>
        let subMatcher = self.buildSubMatcher(matcher: matcher)
        
        return SubMatcherCreation<T>(subMatcher: subMatcher, isParent: matcherCreation.isParent)
    }
    
    override func buildSubMatcher(context: inout MatchingContext) -> SubMatcher<T> {
        
        let matcher = self.schema.buildMatcher(context: &context)
        
        return self.buildSubMatcher(matcher: matcher)
    }
    
    private func buildSubMatcher(matcher: Matcher<U>) -> SubMatcher<T> {
        
        let compute = self.makeCompute()
        let buildNextOccurrence = self.makeBuildNextOccurrence()
        let buildNextSchema = self.makeBuildNextSchema()
        let buildInitialNextSchema = self.makeBuildInitialNextSchema()
        
        return SequenceSubMatcher<T,U>(matcher: matcher, compute: compute, buildNextOccurrence: buildNextOccurrence, buildNextSchema: buildNextSchema, buildInitialNextSchema: buildInitialNextSchema)
    }
    
    private func makeCompute() -> ((U) -> T)? {
        
        guard self.canCompute() else {
            return nil
        }
        
        let buildResultValue = self.makeBuildResultValue()
        
        return { (parameterValue: U) -> T in
            
            let resultValue = buildResultValue(parameterValue)
            return resultValue.compute()
        }
    }
    
    private func canCompute() -> Bool {
        
        /* We can compute if the min/max counts are valid and
         if we are the last schema */
        
        guard self.buildNextSchema == nil else {
            return false
        }
        
        guard self.occurrenceCount >= self.minCount else {
            return false
        }
        
        return true
    }
    
    private func makeBuildNextOccurrence() -> ((U) -> SubSchema<T>)? {
        
        guard self.maxCount == nil || self.occurrenceCount < self.maxCount! else {
            return nil
        }
        
        let schema = self.schema
        let newOccurrenceCount = 1+self.occurrenceCount
        let minCount = self.minCount
        let maxCount = self.maxCount
        let parameterIndex = self.parameterIndex
        let buildResultValue = self.makeBuildResultValue()
        let buildNextSchema = self.buildNextSchema
        
        return { (parameterValue: U) -> SubSchema<T> in
            
            let newResultValue = buildResultValue(parameterValue)
            
            return SequenceSubSchema<T,U>(schema: schema, occurrenceCount: newOccurrenceCount, minCount: minCount, maxCount: maxCount, parameterIndex: parameterIndex, resultValue: newResultValue, buildNextSchema: buildNextSchema)
        }
    }
    
    private func makeBuildResultValue() -> (U) -> ResultValue<T> {
        
        let resultValue = self.resultValue
        
        guard let parameterIndex = self.parameterIndex else {
            return { (_: U) -> ResultValue<T> in
                return resultValue
            }
        }
        
        return { (parameterValue: U) -> ResultValue<T> in
            var newResultValue = resultValue
            newResultValue.setValue(parameterValue, at: parameterIndex)
            return newResultValue
        }
    }
    
    private func makeBuildNextSchema() -> ((U) -> SubSchema<T>)? {
        
        guard self.occurrenceCount >= self.minCount else {
            return nil
        }
        guard let buildNextSchema = self.buildNextSchema else {
            return nil
        }
        
        let buildResultValue = self.makeBuildResultValue()
        
        return { (parameterValue: U) -> SubSchema<T> in
            
            let resultValue = buildResultValue(parameterValue)
            let nextSchema = buildNextSchema(resultValue)
            return nextSchema
        }
    }
    
    private func makeBuildInitialNextSchema() -> (() -> SubSchema<T>)? {
        
        guard self.occurrenceCount == 1 && self.minCount == 0 else {
            return nil
        }
        guard let buildNextSchema = self.buildNextSchema else {
            return makeBuildFinalResult()
        }
        
        let resultValue = buildEmptyResultValue()
        
        return { () -> SubSchema<T> in
            
            let nextSchema = buildNextSchema(resultValue)
            return nextSchema
        }
    }
    
    private func buildEmptyResultValue() -> ResultValue<T> {
        
        let resultValue = self.resultValue
        
        guard let parameterIndex = self.parameterIndex else {
            return resultValue
        }
        
        var newResultValue = resultValue
        newResultValue.markParameterAbsent(at: parameterIndex, type: U.self)
        
        return newResultValue
    }
    
    private func makeBuildFinalResult() -> (() -> SubSchema<T>)? {
        
        let resultValue = buildEmptyResultValue()
        let result = resultValue.compute()
        
        return { () -> SubSchema<T> in
            return ResultSubSchema<T>(result: result)
        }
    }
}

private class SequenceSubMatcher<T,U>: SubMatcher<T> {
    
    private let matcher: Matcher<U>
    private let compute: ((U) -> T)?
    private let buildNextOccurrence: ((U) -> SubSchema<T>)?
    private let buildNextSchema: ((U) -> SubSchema<T>)?
    private var buildInitialNextSchema: (() -> SubSchema<T>)?
    
    init(matcher: Matcher<U>, compute: ((U) -> T)?, buildNextOccurrence: ((U) -> SubSchema<T>)?, buildNextSchema: ((U) -> SubSchema<T>)?, buildInitialNextSchema: (() -> SubSchema<T>)?) {
        
        self.matcher = matcher
        self.compute = compute
        self.buildNextOccurrence = buildNextOccurrence
        self.buildNextSchema = buildNextSchema
        self.buildInitialNextSchema = buildInitialNextSchema
        
        super.init()
    }
    
    override var canContinue: Bool {
        return self.matcher.canContinue
    }
    
    override var resultParsed: T? {
        
        guard let compute = self.compute else {
            return nil
        }
        guard let parameterResult = self.matcher.resultParsed else {
            return nil
        }
        
        return compute(parameterResult)
    }
    
    override var hasCycle: Bool {
        return self.matcher.hasCycle
    }
    
    override var subBranches: [SubSchema<T>] {
        
        var subBranches: [SubSchema<T>] = []
        
        if let buildInitialNextSchema = self.buildInitialNextSchema {
            
            let nextSchema = buildInitialNextSchema()
            subBranches.append(nextSchema)
        }
        
        /* The following sub-branches need a result */
        guard let parameterResult = self.matcher.resultParsed else {
            return subBranches
        }
        
        if let buildNextOccurrence = self.buildNextOccurrence {
            
            let nextOccurrence = buildNextOccurrence(parameterResult)
            subBranches.append(nextOccurrence)
        }
        
        if let buildNextSchema = self.buildNextSchema {
            
            let nextSchema = buildNextSchema(parameterResult)
            subBranches.append(nextSchema)
        }
        
        return subBranches
    }
    
    override func addChangeCallback(_ callback: @escaping MatcherCallback) {
        self.matcher.addChangeCallback(callback)
    }
    
    override func addCycleChangeCallback(_ callback: @escaping MatcherCallback) {
        self.matcher.addCycleChangeCallback(callback)
    }
    
    override func matchNextToken(_ token: Token, context: inout MatchingContext) {
        self.matcher.matchNextToken(token, context: &context)
        
        self.buildInitialNextSchema = nil
    }
    
    override func dontMatchNextToken() {
        
        self.buildInitialNextSchema = nil
    }
}

private class ResultSubSchema<T>: SubSchema<T> {
    
    private let result: T
    
    init(result: T) {
        self.result = result
    }
    
    override func findExistingMatcher(in context: inout MatchingContext) -> SubMatcherCreation<T>? {
        return nil
    }
    
    override func buildSubMatcher(context: inout MatchingContext) -> SubMatcher<T> {
        return ResultSubMatcher(result: self.result)
    }
}

private class ResultSubMatcher<T>: SubMatcher<T> {
    
    private let result: T
    
    init(result: T) {
        self.result = result
    }
    
    override var canContinue: Bool {
        return false
    }
    override var resultParsed: T? {
        return self.result
    }
    override var hasCycle: Bool {
        return false
    }
    override var subBranches: [SubSchema<T>] {
        return []
    }
    
    override func addChangeCallback(_ callback: @escaping MatcherCallback) {
    }
    
    override func addCycleChangeCallback(_ callback: @escaping MatcherCallback) {
    }
    
    override func matchNextToken(_ token: Token, context: inout MatchingContext) {
    }
}

private class ChoiceSubSchema<T,U>: SubSchema<T> {
    
    private let schema: MatchingSchema<U>
    private let compute: (U) -> T
    
    init(schema: MatchingSchema<U>, compute: @escaping (U) -> T) {
        
        self.schema = schema
        self.compute = compute
        
        super.init()
    }
    
    override func findExistingMatcher(in context: inout MatchingContext) -> SubMatcherCreation<T>? {
        
        let schemaIdentity: ObjectIdentifier = ObjectIdentifier(self.schema)
        guard let matcherCreation = context.createdMatchers[schemaIdentity] else {
            return nil
        }
        
        let matcher = matcherCreation.matcher as! Matcher<U>
        let subMatcher = ChoiceSubMatcher<T,U>(matcher: matcher, compute: self.compute)
        return SubMatcherCreation<T>(subMatcher: subMatcher, isParent: matcherCreation.isParent)
    }
    
    override func buildSubMatcher(context: inout MatchingContext) -> SubMatcher<T> {
        
        let matcher = self.schema.buildMatcher(context: &context)
        let subMatcher = ChoiceSubMatcher<T,U>(matcher: matcher, compute: self.compute)
        return subMatcher
    }
}

private class ChoiceSubMatcher<T,U>: SubMatcher<T> {
    
    private let matcher: Matcher<U>
    private let compute: (U) -> T
    
    init(matcher: Matcher<U>, compute: @escaping (U) -> T) {
        
        self.matcher = matcher
        self.compute = compute
        
        super.init()
    }
    
    override var canContinue: Bool {
        return self.matcher.canContinue
    }
    
    override var resultParsed: T? {
        
        guard let matcherResult = self.matcher.resultParsed else {
            return nil
        }
        
        return self.compute(matcherResult)
    }
    
    override var hasCycle: Bool {
        return self.matcher.hasCycle
    }
    
    override var subBranches: [SubSchema<T>] {
        return []
    }
    
    override func addChangeCallback(_ callback: @escaping MatcherCallback) {
        self.matcher.addChangeCallback(callback)
    }
    
    override func addCycleChangeCallback(_ callback: @escaping MatcherCallback) {
        self.matcher.addCycleChangeCallback(callback)
    }
    
    override func matchNextToken(_ token: Token, context: inout MatchingContext) {
        self.matcher.matchNextToken(token, context: &context)
    }
}

private struct ResultValue<T> {
    
    private var values: [Any?]
    private let types: [Any]
    private let computeWithParameters: ([Any?]) -> T
    
    init(types: [Any], compute: @escaping ([Any?]) -> T) {
        
        self.values = [Any?](repeating: nil, count: types.count)
        self.types = types
        self.computeWithParameters = compute
    }
    
    // Returns non-nil only if all parameters have a value or are marked absent
    func compute() -> T {
        return self.computeWithParameters(self.values)
    }
    
    mutating func setValue<U>(_ value: U, at index: Int) -> () {
        
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
    
    mutating func markParameterAbsent<U>(at index: Int, type: U.Type) -> () {
        
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

