//
//  Matching.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 26/08/2019.
//  Copyright © 2019 Pierre Lorenzi. All rights reserved.
//


// note to myself: it doesn't work because of the cycles. We must change
// the matchers states (canContinue and parsedResults) by callbacks. That way,
// in a cycle, there would be cycle callbacks. For example parse with the
// schemas 'Expression' and 'Expression + Expression'; at first the main schema
// asks addition schema if it has a result; by callback, addition answer 'waiting
// for cycle', ie, waiting for your own answer because I can't know. Then the main
// finishes, and if it has results on other branches, it sets the state and
// triggers the callbacks; addition then announces that is has a result (it would
// be ignored) or that it can't continue (then it is deleted).
public final class Schema<T> {
    
    private var sequenceElements: [SchemaElement<T>] = []
    private var branchElements: [SchemaElement<T>] = []
    private var computation: ResultComputation<T>? = nil
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
        
        self.computation = ResultComputation<T>(parameterValues: [], parameterTypes: [], subSchemaIndexesToParameterIndexes: [:], compute: { (_:[Any?]) -> T in return compute() })
        
    }
    
    public func computeSequenceBySingle<A>(_ compute: @escaping (A) -> T) {
        
        let schemaElements = self.sequenceElements.enumerated().filter({ !$0.element.isConstant })
        guard schemaElements.count == 1 else {
            fatalError()
        }
        
        let keysAndValues = schemaElements.enumerated().map({ ($0.element.offset, $0.offset)  })
        let subSchemaIndexesToParameterIndexes = [Int: Int](uniqueKeysWithValues: keysAndValues)
        
        let parameterValues = [Any?](repeating: nil, count: 1)
        let parameterTypes: [Any] = [A.self]
        
        self.computation = ResultComputation<T>(parameterValues: parameterValues, parameterTypes: parameterTypes, subSchemaIndexesToParameterIndexes: subSchemaIndexesToParameterIndexes, compute: { (values: [Any?]) -> T in
            
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
        let subSchemaIndexesToParameterIndexes = [Int: Int](uniqueKeysWithValues: keysAndValues)
        
        let parameterValues = [Any?](repeating: nil, count: 2)
        let parameterTypes: [Any] = [A.self, B.self]
        
        self.computation = ResultComputation<T>(parameterValues: parameterValues, parameterTypes: parameterTypes, subSchemaIndexesToParameterIndexes: subSchemaIndexesToParameterIndexes, compute: { (values: [Any?]) -> T in
            
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
        let subSchemaIndexesToParameterIndexes = [Int: Int](uniqueKeysWithValues: keysAndValues)
        
        let parameterValues = [Any?](repeating: nil, count: 3)
        let parameterTypes: [Any] = [A.self, B.self, C.self]
        
        self.computation = ResultComputation<T>(parameterValues: parameterValues, parameterTypes: parameterTypes, subSchemaIndexesToParameterIndexes: subSchemaIndexesToParameterIndexes, compute: { (values: [Any?]) -> T in
            
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
        let subSchemaIndexesToParameterIndexes = [Int: Int](uniqueKeysWithValues: keysAndValues)
        
        let parameterValues = [Any?](repeating: nil, count: 4)
        let parameterTypes: [Any] = [A.self, B.self, C.self, D.self]
        
        self.computation = ResultComputation<T>(parameterValues: parameterValues, parameterTypes: parameterTypes, subSchemaIndexesToParameterIndexes: subSchemaIndexesToParameterIndexes, compute: { (values: [Any?]) -> T in
            
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
        let matcher = schema.buildMatcher(parent: nil)
        
        for token in tokens {
            
            if !matcher.canContinue {
                return nil
            }
            
            matcher.matchNextToken(token)
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
            
            let subSchemas = self.sequenceElements.map({ $0.createSubSchema() })
            let sequenceSchema = SequenceSchema<T>(subSchemas: subSchemas, initialComputation: self.computation!)
            return sequenceSchema
        }
        
        else {
            
            let elements = self.sequenceElements.isEmpty ? self.branchElements : [self.sequenceElements[0]] + self.branchElements
            
            let subSchemas: [MatchingSchema<T>] = elements.map { (element: SchemaElement<T>) -> MatchingSchema<T> in
                
                if element.isSameType && element.minCount == 1 && element.maxCount == 1 && !element.hasComputation() {
                    
                    return element.createSchemaSameType()
                }
                
                let sequenceSubSchema = element.createSubSchema()
                let sequenceComputation = element.createBranchComputation()
                let sequenceSchema = SequenceSchema<T>(subSchemas: [sequenceSubSchema], initialComputation: sequenceComputation)
                
                return sequenceSchema
            }
            
            let branchSchema = ChoiceSchema<T>(choices: subSchemas)
            
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
    
    func createSubSchema() -> SubSchema<T> {
        fatalError()
    }
    
    func computeAsBranchWith<U>(_ compute: @escaping (U) -> T) {
        fatalError()
    }
    
    func createBranchComputation() -> ResultComputation<T> {
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
    
    override func createSubSchema() -> SubSchema<T> {
        
        let schema = self.schema
        let loadSchema = { () -> MatchingSchema<U> in schema.matchingSchema }
        
        return TypedSubSchema<T,U>(loadSchema: loadSchema, minCount: self.minCount, maxCount: self.maxCount)
    }
    
    override func computeAsBranchWith<V>(_ compute: @escaping (V) -> T) {
        
        guard V.self == U.self else {
            fatalError()
        }
        
        self.computeBranch = (compute as! ((U) -> T))
    }
    
    override func createBranchComputation() -> ResultComputation<T> {
        
        let compute = self.computeBranch!
        
        return ResultComputation<T>(parameterValues: [nil], parameterTypes: [U.self as Any], subSchemaIndexesToParameterIndexes: [0: 0], compute: { (values: [Any?]) -> T in
            
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
    
    override func createSubSchema() -> SubSchema<T> {
        
        let tokenFilter = self.tokenFilter
        let loadSchema = { () -> MatchingSchema<Token> in TokenSchema(checkTokenValid: tokenFilter) }
        
        return TypedSubSchema<T,Token>(loadSchema: loadSchema, minCount: self.minCount, maxCount: self.maxCount)
    }
    
    override func computeAsBranchWith<V>(_ compute: @escaping (V) -> T) {
        
        guard V.self == Token.self else {
            fatalError()
        }
        
        self.computeBranch = (compute as! ((Token) -> T))
    }
    
    override func createBranchComputation() -> ResultComputation<T> {
        
        let compute = self.computeBranch!
        
        return ResultComputation<T>(parameterValues: [nil], parameterTypes: [Token.self as Any], subSchemaIndexesToParameterIndexes: [0: 0], compute: { (values: [Any?]) -> T in
            
            let value = values[0]! as! Token
            
            return compute(value)
        })
    }
    
    override func assignNewType<V>(_ type: V.Type) -> SchemaElement<V> {
        
        return TokenSchemaElement<V>(tokenFilter: self.tokenFilter, minCount: self.minCount, maxCount: self.maxCount, isConstant: self.isConstant)
    }
    
    override func createSchemaSameType() -> MatchingSchema<T> {
        
        return TokenSchema(checkTokenValid: self.tokenFilter) as! MatchingSchema<T>
    }
    
    override func hasComputation() -> Bool {
        
        return self.computeBranch != nil
    }
}

private class MatchingSchema<T> {
    
    func buildMatcher(parent: MatcherLink?) -> Matcher<T> {
        fatalError()
    }
    
    // TODO test
    public var name: String? = nil
}

protocol MatcherLink {
    
    var parent: MatcherLink? { get }
    
    var schema: AnyObject { get }
}

private class Matcher<T>: MatcherLink {
    
    var canContinue: Bool
    var resultParsed: T?
    
    func matchNextToken(_ token: Token) {
        fatalError()
    }
    
    let parent: MatcherLink?
    let schema: AnyObject
    
    init(initialCanContinue: Bool, initialResultParsed: T?, parent: MatcherLink?, schema: AnyObject) {
        
        self.canContinue = initialCanContinue
        self.resultParsed = initialResultParsed
        self.parent = parent
        self.schema = schema
    }
}

private class SequenceSchema<T>: MatchingSchema<T> {
    
    private let subSchemas: [SubSchema<T>]
    private let initialComputation: ResultComputation<T>
    
    init(subSchemas: [SubSchema<T>], initialComputation: ResultComputation<T>) {
        
        self.subSchemas = subSchemas
        self.initialComputation = initialComputation
    }
    
    override func buildMatcher(parent: MatcherLink?) -> Matcher<T> {
        
        return SequenceMatcher<T>(subSchemas: self.subSchemas, initialComputation: self.initialComputation, parent: parent, schema: self)
    }
}

private class SubSchema<T> {
    
    let minCount: Int
    let maxCount: Int?
    
    init(minCount: Int, maxCount: Int?) {
        
        self.minCount = minCount
        self.maxCount = maxCount
    }
    
    func buildSubMatcher(parent: MatcherLink?) -> SubMatcher<T> {
        fatalError()
    }
    
    func integrateResult(from subMatcher: SubMatcher<T>, in computation: inout ResultComputation<T>, at index: Int) {
        fatalError()
    }
    
    func integrateResultAbsence(in computation: inout ResultComputation<T>, at index: Int) {
        fatalError()
    }
}

private class TypedSubSchema<T,U>: SubSchema<T> {
    
    private let schemaProperty: Property<MatchingSchema<U>>
    
    init(loadSchema: @escaping () -> MatchingSchema<U>, minCount: Int, maxCount: Int?) {
        
        self.schemaProperty = Property(lazy: loadSchema)
        
        super.init(minCount: minCount, maxCount: maxCount)
    }
    
    override func buildSubMatcher(parent: MatcherLink?) -> SubMatcher<T> {
        
        let schema = self.schemaProperty.value
        
        /* Cycle check: check that the same schema is not already being parsed */
        var possibleLink = parent
        while let link = possibleLink {
            if link.schema === schema {
                let sameMatcher = (link as! Matcher<U>)
                return TypedSubMatcher<T, U>(matcher: sameMatcher, isCycle: true)
            }
            possibleLink = link.parent
        }
        
        let matcher = schema.buildMatcher(parent: parent)
        
        return TypedSubMatcher<T, U>(matcher: matcher, isCycle: false)
    }
    
    override func integrateResult(from subMatcher: SubMatcher<T>, in computation: inout ResultComputation<T>, at index: Int) {
        
        let parameterType = computation.parameterTypes[index]
        let typedSubMatcher = subMatcher as! TypedSubMatcher<T,U>
        let result = typedSubMatcher.resultParsed!
        
        if parameterType is U.Type {
            
            computation.parameterValues[index] = Optional.some(result)
        }
        else if parameterType is (U?).Type {
            
            computation.parameterValues[index] = Optional.some(Optional.some(result) as Any)
        }
        else if parameterType is [U].Type {
            
            let possibleList = computation.parameterValues[index] as! [U]?
            
            let newList: [U]
            if let list = possibleList {
                
                var changingList = list
                changingList.append(result)
                
                newList = changingList
            }
            else {
                
                newList = [result]
            }
            
            computation.parameterValues[index] = Optional.some(newList)
        }
        else {
            
            fatalError()
        }
    }
    
    override func integrateResultAbsence(in computation: inout ResultComputation<T>, at index: Int) {
        
        let parameterType = computation.parameterTypes[index]
        
        if parameterType is (U?).Type {
            
            computation.parameterValues[index] = Optional.some(Optional<U>.none as Any)
        }
        else if parameterType is [U].Type {
            
            computation.parameterValues[index] = Optional.some([U]())
        }
        else {
            
            fatalError()
        }
    }
}

private class SubMatcher<T> {
    
    var canContinue: Bool
    var hasResult: Bool
    let isCycle: Bool
    
    func matchNextToken(_: Token) {
        fatalError()
    }
    
    init(initialCanContinue: Bool, initialHasResult: Bool, isCycle: Bool) {
        
        self.canContinue = initialCanContinue
        self.hasResult = initialHasResult
        self.isCycle = isCycle
    }
}

private class TypedSubMatcher<T, U>: SubMatcher<T> {
    
    private let matcher: Matcher<U>
    
    init(matcher: Matcher<U>, isCycle: Bool) {
        
        self.matcher = matcher
        
        /* Init status */
        super.init(initialCanContinue: matcher.canContinue, initialHasResult: matcher.resultParsed != nil, isCycle: isCycle)
    }
    
    var resultParsed: U? {
        return self.matcher.resultParsed
    }
    
    override func matchNextToken(_ token: Token) {
            
        self.matcher.matchNextToken(token)
        
        self.canContinue = self.matcher.canContinue
        self.hasResult = self.matcher.resultParsed != nil
    }
    
}

private struct ResultComputation<T> {
    
    var parameterValues: [Any?]
    
    let parameterTypes: [Any]
    let subSchemaIndexesToParameterIndexes: [Int: Int]
    
    let compute: ([Any?]) -> T
}

private class SequenceMatcher<T>: Matcher<T> {
    
    private var branches: [Branch]
    private let subSchemas: [SubSchema<T>]
    private var isNew: Bool
    
    private struct Branch {
        
        var subMatcher: SubMatcher<T>
        var computation: ResultComputation<T>
        var subSchemaIndex: Int
        var occurenceIndex: Int
        var isNew: Bool
    }
    
    init(subSchemas: [SubSchema<T>], initialComputation: ResultComputation<T>, parent: MatcherLink?, schema: AnyObject) {
        
        self.branches = []
        self.subSchemas = subSchemas
        self.isNew = false
        
        super.init(initialCanContinue: false, initialResultParsed: nil, parent: parent, schema: schema)
        
        /* Add the first branch */
        let initialSubMatcher = subSchemas[0].buildSubMatcher(parent: self)
        let firstBranch = Branch(subMatcher: initialSubMatcher, computation: initialComputation, subSchemaIndex: 0, occurenceIndex: 0, isNew: true)
        self.branches.append(firstBranch)
        
        /* Adjust the state to this branch */
        self.updateState()
    }
    
    override func matchNextToken(_ token: Token) {
        
        self.isNew = false
        
        for i in 0..<self.branches.count {
            
            self.branches[i].subMatcher.matchNextToken(token)
            
            self.branches[i].isNew = false
        }
        
        self.updateState()
    }
    
    private func updateState() {
        
        self.resultParsed = nil
        
        var i = 0
        
        while i < self.branches.count {
            
            /* Match */
            let branch = self.branches[i]
            let subMatcher = branch.subMatcher
            
            /* Make branches where we develop the possibility the matcher doesn't continue */
            self.addSubBranches(at: i)
            
            /* If the matcher must stop, remove it */
            if !subMatcher.canContinue {
                
                self.branches.remove(at: i)
                i -= 1
            }
            
            i += 1
        }
        
        self.canContinue = !self.branches.isEmpty
    }
    
    private func addSubBranches(at index: Int) {
        
        let branch = self.branches[index]
        let subMatcher = branch.subMatcher
        let subSchemaIndex = branch.subSchemaIndex
        let subSchema = self.subSchemas[subSchemaIndex]
        
        var insertionIndex = index + 1
        
        if subMatcher.hasResult {
        
            /* Consider the matcher as finished, so we include its result in the computation */
            var newComputation = branch.computation
            if let parameterIndex = newComputation.subSchemaIndexesToParameterIndexes[subSchemaIndex] {
                
                subSchema.integrateResult(from: subMatcher, in: &newComputation, at: parameterIndex)
            }
            
            /* Make a sub-branch where the same schema restarts. Avoid repeating indefinitely
             an empty match */
            if !branch.isNew {
                
                self.addSubBranchSameSchema(at: index, insertionIndex: &insertionIndex, computation: newComputation)
            }
            
            /* Make a sub-branch where the next schema starts */
            self.addSubBranchNextSchema(at: index, insertionIndex: &insertionIndex, computation: newComputation)
            
        }
        
        /* If the matcher has matched nothing and the schema's min count is 0, consider that the next
         schema starts with no value */
        if branch.isNew && subSchema.minCount == 0 && branch.occurenceIndex == 0 {
            
            /* Consider the matcher as finished, so we include its result in the computation */
            var newComputation = branch.computation
            if let parameterIndex = newComputation.subSchemaIndexesToParameterIndexes[subSchemaIndex] {
                
                subSchema.integrateResultAbsence(in: &newComputation, at: parameterIndex)
            }
            
            /* Make a sub-branch where the next schema starts */
            self.addSubBranchNextSchema(at: index, insertionIndex: &insertionIndex, computation: newComputation)
        }
        
    }
    
    private func addSubBranchSameSchema(at index: Int, insertionIndex: inout Int, computation: ResultComputation<T>) {
        
        /* Make a sub-branch where the same schema restarts */
        let branch = self.branches[index]
        let subSchema = self.subSchemas[branch.subSchemaIndex]
        
        /* Check if the schema can start again */
        let newOccurrenceIndex = 1 + branch.occurenceIndex
        guard subSchema.maxCount == nil || newOccurrenceIndex < subSchema.maxCount! else {
            return
        }
        
        /* Build the branch */
        let newSubMatcher = subSchema.buildSubMatcher(parent: self.isNew ? self : nil)
        let newBranch = Branch(subMatcher: newSubMatcher, computation: computation, subSchemaIndex: branch.subSchemaIndex, occurenceIndex: newOccurrenceIndex, isNew: true)
        
        self.branches.insert(newBranch, at: insertionIndex)
        insertionIndex += 1
    }
    
    private func addSubBranchNextSchema(at index: Int, insertionIndex: inout Int, computation: ResultComputation<T>) {
        
        /* Make a sub-branch where the next schema restarts */
        let branch = self.branches[index]
        let subSchemaIndex = branch.subSchemaIndex
        
        /* Check if the current schema has enough repeats */
        let newOccurrenceCount = branch.occurenceIndex + (branch.isNew ? 0 : 1)
        guard newOccurrenceCount >= self.subSchemas[subSchemaIndex].minCount else {
            return
        }
        
        /* Check if there is a schema after */
        let newSubSchemaIndex = subSchemaIndex + 1
        guard newSubSchemaIndex < self.subSchemas.count else {
            
            if self.resultParsed == nil {
                self.resultParsed = computation.compute(computation.parameterValues)
            }
            return
        }
        
        /* Build the branch */
        let newSubSchema = self.subSchemas[newSubSchemaIndex]
        let newSubMatcher = newSubSchema.buildSubMatcher(parent: self.isNew ? self : nil)
        let newBranch = Branch(subMatcher: newSubMatcher, computation: computation, subSchemaIndex: newSubSchemaIndex, occurenceIndex: 0, isNew: true)
        
        self.branches.insert(newBranch, at: insertionIndex)
        insertionIndex += 1
    }
    
}

private class ChoiceSchema<T>: MatchingSchema<T> {
    
    private let choices: [MatchingSchema<T>]
    
    init(choices: [MatchingSchema<T>]) {
        
        self.choices = choices
    }
    
    override func buildMatcher(parent: MatcherLink?) -> Matcher<T> {
                
        return ChoiceMatcher<T>(choices: self.choices, parent: parent, schema: self)
    }
}

private class ChoiceMatcher<T>: Matcher<T> {
    
    private var matchers: [Matcher<T>]
    
    init(choices: [MatchingSchema<T>], parent: MatcherLink?, schema: AnyObject) {
        
        self.matchers = []
        
        super.init(initialCanContinue: false, initialResultParsed: nil, parent: parent, schema: schema)
        
        self.matchers = choices.map({ $0.buildMatcher(parent: self) })
        updateState()
    }
    
    override func matchNextToken(_ token: Token) {
        
        for matcher in self.matchers {
            
            matcher.matchNextToken(token)
        }
        
        self.updateState()
    }
    
    private func updateState(){
        
        self.resultParsed = nil
        
        for i in (0..<self.matchers.count).reversed() {
            
            /* Match */
            let matcher = self.matchers[i]
            
            /* If the matcher can stop, so can we. We can stop when one of
             the matcher can, and we choose the best one, i.e., the first one */
            if let result = matcher.resultParsed {
                
                self.resultParsed = result
            }
            
            /* If the matcher must stop, remove it */
            if !matcher.canContinue {
                
                self.matchers.remove(at: i)
            }
        }
        
        self.canContinue = !self.matchers.isEmpty
    }
}

private class TokenSchema: MatchingSchema<Token> {
    
    private let checkTokenValid: (Token) -> Bool
    
    init(checkTokenValid: @escaping (Token) -> Bool) {
        self.checkTokenValid = checkTokenValid
    }
    
    override func buildMatcher(parent: MatcherLink?) -> Matcher<Token> {
        
        return TokenMatcher(checkTokenValid: self.checkTokenValid, parent: parent, schema: self)
    }
}

private class TokenMatcher: Matcher<Token> {
    
    private let checkTokenValid: (Token) -> Bool
    
    init(checkTokenValid: @escaping (Token) -> Bool, parent: MatcherLink?, schema: AnyObject) {
        
        self.checkTokenValid = checkTokenValid
        
        super.init(initialCanContinue: true, initialResultParsed: nil, parent: parent, schema: schema)
    }
    
    override func matchNextToken(_ token: Token) {
        
        self.canContinue = false
        
        if self.checkTokenValid(token) {
            
            self.resultParsed = token
        }
    }
}


