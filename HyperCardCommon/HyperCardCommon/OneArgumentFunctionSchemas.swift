//
//  OneArgumentFunctionSchemas.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 30/08/2019.
//  Copyright © 2019 Pierre Lorenzi. All rights reserved.
//


public extension Schemas {
    
    
    static let oneArgumentFunctionCall = buildOneArgumentFunctionCall()
    
    
    private static func buildOneArgumentFunctionCall() -> Schema<FunctionCall> {
        
        let schema = Schema<FunctionCall>()
        
        appendOneArgumentFunction(abs, to: schema)
        appendOneArgumentFunction(atan, to: schema)
        appendOneArgumentFunction(charToNum, to: schema)
        appendOneArgumentFunction(cos, to: schema)
        appendOneArgumentFunction(exp, to: schema)
        appendOneArgumentFunction(exp1, to: schema)
        appendOneArgumentFunction(exp2, to: schema)
        appendOneArgumentFunction(length, to: schema)
        appendOneArgumentFunction(ln, to: schema)
        appendOneArgumentFunction(log1, to: schema)
        appendOneArgumentFunction(log2, to: schema)
        
        return schema
    }
    
    private static func appendOneArgumentFunction<T>(_ call: OneArgumentFunction<T>, to schema: Schema<FunctionCall>) {
        
        /* If the function argument is an expression, the form 'the <function> of <argument> takes a factor */
        let schemaArgument1: Schema<T> = (call.argumentSchema === expressionAgain) ? (factorAgain as! Schema<T>) : call.argumentSchema
        
        let schema1 = Schema<FunctionCall>("\(maybe: "the") \(string: call.name) of \(schemaArgument1)")
        
            .returnsSingle(call.returns)
        
        let schema2 = Schema<FunctionCall>("\(string: call.name) ( \(call.argumentSchema) )")
            
            .returnsSingle(call.returns)
        
        schema.appendBranchedSchema(schema1)
        schema.appendBranchedSchema(schema2)
    }
    
    private struct OneArgumentFunction<T> {
        
        var name: HString
        var argumentSchema: Schema<T>
        var returns: (T) -> FunctionCall
    }
    
    private static let abs = OneArgumentFunction<Expression>(name: "abs", argumentSchema: expressionAgain) {
        
        FunctionCall.abs($0)
    }
    
    private static let atan = OneArgumentFunction<Expression>(name: "atan", argumentSchema: expressionAgain) {
        
        FunctionCall.atan($0)
    }
    
    private static let charToNum = OneArgumentFunction<Expression>(name: "charToNum", argumentSchema: expressionAgain) {
        
        FunctionCall.charToNum($0)
    }
    
    private static let cos = OneArgumentFunction<Expression>(name: "cos", argumentSchema: expressionAgain) {
        
        FunctionCall.cos($0)
    }
    
    private static let exp = OneArgumentFunction<Expression>(name: "exp", argumentSchema: expressionAgain) {
        
        FunctionCall.exp($0)
    }
    
    private static let exp1 = OneArgumentFunction<Expression>(name: "exp1", argumentSchema: expressionAgain) {
        
        FunctionCall.exp1($0)
    }
    
    private static let exp2 = OneArgumentFunction<Expression>(name: "exp2", argumentSchema: expressionAgain) {
        
        FunctionCall.exp2($0)
    }
    
    private static let length = OneArgumentFunction<Expression>(name: "length", argumentSchema: expressionAgain) {
        
        FunctionCall.length($0)
    }
    
    private static let ln = OneArgumentFunction<Expression>(name: "ln", argumentSchema: expressionAgain) {
        
        FunctionCall.ln($0)
    }
    
    private static let log1 = OneArgumentFunction<Expression>(name: "log1", argumentSchema: expressionAgain) {
        
        FunctionCall.log1($0)
    }
    
    private static let log2 = OneArgumentFunction<Expression>(name: "log2", argumentSchema: expressionAgain) {
        
        FunctionCall.log2($0)
    }
    
    
}

public extension Schemas {
    
    
    static let countable = Schema<Countable>()
    
    
    static let cardParts = Schema<Countable>("\(Vocabulary.cardParts)")
    
        .returns(Countable.parts(LayerType.card))
    
    static let backgroundParts = Schema<Countable>("\(Vocabulary.backgroundParts)")
        
        .returns(Countable.parts(LayerType.background))
    
    static let cardButtons = Schema<Countable>("\(Vocabulary.cardButtons)")
        
        .returns(Countable.buttons(LayerType.card))
    
    static let backgroundButtons = Schema<Countable>("\(Vocabulary.backgroundButtons)")
        
        .returns(Countable.buttons(LayerType.background))
    
    static let cardFields = Schema<Countable>("\(Vocabulary.cardFields)")
        
        .returns(Countable.fields(LayerType.card))
    
    static let backgroundFields = Schema<Countable>("\(Vocabulary.backgroundFields)")
        
        .returns(Countable.fields(LayerType.background))
    
    // not finished
}
