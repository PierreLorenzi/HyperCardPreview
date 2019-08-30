//
//  ChunkSchemas.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 30/08/2019.
//  Copyright © 2019 Pierre Lorenzi. All rights reserved.
//


public extension Schemas {
    
    
    static let chunk = Schema<Chunk>("\(multiple: chunkExtraction)")
    
    static let chunkExtraction = Schema<Chunk>("\(chunkElement) of")
}

public extension Schemas {
    
    
    static let chunkElement = Schema<Chunk>("\(numberChunkElement)\(or: ordinalChunkElement)\(or: rangeChunkElement)")
    
    
    
    static let numberChunkElement = Schema<Chunk>("\(chunkElementType) \(expressionAgain)")
    
        .returns { Chunk(type: $0, number: ChunkNumber.single(Ordinal.number($1))) }
    
    static let ordinalChunkElement = Schema<Chunk>("\(maybe: "the") \(ordinal) \(chunkElementType)")
        
        .returns { Chunk(type: $1, number: ChunkNumber.single($0)) }
    
    static let rangeChunkElement = Schema<Chunk>("\(chunkElementType) \(expressionAgain) to \(expressionAgain)")
        
        .returns { Chunk(type: $0, number: ChunkNumber.range(ChunkNumberRange(minimumNumber: $1, maximumNumber: $2))) }
}

public extension Schemas {
    
    
    static let chunkElementType = Schema<ChunkType>("\(lineChunk)\(or: itemChunk)\(or: wordChunk)\(or: characterChunk)")
    
    
    
    static let lineChunk = Schema<ChunkType>("line")
    
        .returns(ChunkType.line)
    
    static let itemChunk = Schema<ChunkType>("item")
        
        .returns(ChunkType.item)
    
    static let wordChunk = Schema<ChunkType>("word")
        
        .returns(ChunkType.word)
    
    static let characterChunk = Schema<ChunkType>("\(either: "character", "char")")
        
        .returns(ChunkType.character)
}

public extension Schemas {
    
    
    static let ordinal = Schema<Ordinal>("\(any)\(or: middle)\(or: last)\(or: first)\(or: second)\(or: third)\(or: fourth)\(or: fifth)\(or: sixth)\(or: seventh)\(or: eighth)\(or: ninth)\(or: tenth)")
    
    
    
    static let any = Schema<Ordinal>("any")
        
        .returns(Ordinal.any)
    
    static let middle = Schema<Ordinal>("middle")
        
        .returns(Ordinal.middle)
    
    static let last = Schema<Ordinal>("last")
        
        .returns(Ordinal.last)
    
    static let first = Schema<Ordinal>("first")
        
        .returns(Ordinal.number(Expression.literal(Literal.integer(1))))
    
    static let second = Schema<Ordinal>("second")
        
        .returns(Ordinal.number(Expression.literal(Literal.integer(2))))
    
    static let third = Schema<Ordinal>("third")
        
        .returns(Ordinal.number(Expression.literal(Literal.integer(3))))
    
    static let fourth = Schema<Ordinal>("fourth")
        
        .returns(Ordinal.number(Expression.literal(Literal.integer(4))))
    
    static let fifth = Schema<Ordinal>("fifth")
        
        .returns(Ordinal.number(Expression.literal(Literal.integer(5))))
    
    static let sixth = Schema<Ordinal>("sixth")
        
        .returns(Ordinal.number(Expression.literal(Literal.integer(6))))
    
    static let seventh = Schema<Ordinal>("seventh")
        
        .returns(Ordinal.number(Expression.literal(Literal.integer(7))))
    
    static let eighth = Schema<Ordinal>("eighth")
        
        .returns(Ordinal.number(Expression.literal(Literal.integer(8))))
    
    static let ninth = Schema<Ordinal>("ninth")
        
        .returns(Ordinal.number(Expression.literal(Literal.integer(9))))
    
    static let tenth = Schema<Ordinal>("tenth")
        
        .returns(Ordinal.number(Expression.literal(Literal.integer(10))))
}
