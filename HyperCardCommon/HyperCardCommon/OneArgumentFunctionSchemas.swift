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
        
        FunctionCall.abs(number: $0)
    }
    
    private static let atan = OneArgumentFunction<Expression>(name: "atan", argumentSchema: expressionAgain) {
        
        FunctionCall.atan(number: $0)
    }
    
    private static let charToNum = OneArgumentFunction<Expression>(name: "charToNum", argumentSchema: expressionAgain) {
        
        FunctionCall.charToNum(character: $0)
    }
    
    private static let cos = OneArgumentFunction<Expression>(name: "cos", argumentSchema: expressionAgain) {
        
        FunctionCall.cos(number: $0)
    }
    
    private static let exp = OneArgumentFunction<Expression>(name: "exp", argumentSchema: expressionAgain) {
        
        FunctionCall.exp(number: $0)
    }
    
    private static let exp1 = OneArgumentFunction<Expression>(name: "exp1", argumentSchema: expressionAgain) {
        
        FunctionCall.exp1(number: $0)
    }
    
    private static let exp2 = OneArgumentFunction<Expression>(name: "exp2", argumentSchema: expressionAgain) {
        
        FunctionCall.exp2(number: $0)
    }
    
    private static let length = OneArgumentFunction<Expression>(name: "length", argumentSchema: expressionAgain) {
        
        FunctionCall.length($0)
    }
    
    
}
