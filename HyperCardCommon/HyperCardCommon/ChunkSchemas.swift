//
//  ChunkSchemas.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 30/08/2019.
//  Copyright © 2019 Pierre Lorenzi. All rights reserved.
//


public extension Schemas {
    
    
    static let chunk = Schema<Chunk>("\(multiple: chunkExtraction)")
    
        .returnsSingle { Chunk(elements: $0) }
    
    static let chunkExtraction = Schema<ChunkElement>("\(chunkElement) \(Vocabulary.of)")
}

public extension Schemas {
    
    
    static let chunkElement = Schema<ChunkElement>("\(lineChunkElement)\(or: itemChunkElement)\(or: wordChunkElement)\(or: characterChunkElement)")
    
    
    
    static let lineChunkElement = buildChunkElementSchema(type: ChunkType.line, typeName: Vocabulary.line)
    
    static let itemChunkElement = buildChunkElementSchema(type: ChunkType.item, typeName: Vocabulary.item)
    
    static let wordChunkElement = buildChunkElementSchema(type: ChunkType.word, typeName: Vocabulary.word)
    
    static let characterChunkElement = buildChunkElementSchema(type: ChunkType.character, typeName: Vocabulary.character)
    
    
    private static func buildChunkElementSchema(type: ChunkType, typeName: Schema<Void>) -> Schema<ChunkElement> {
        
        /* Schema for 'the second line' or 'line 2' */
        let ordinalSchema: Schema<ChunkElement> = buildOrdinalIdentification(typeName: typeName) {
            
            return ChunkElement(type: type, number: ChunkNumber.single($0))
        }
        
        /* Schema for 'line 2 to 4' */
        let rangeElement = Schema<ChunkElement>("\(typeName) \(expressionAgain) to \(expressionAgain)")
            
            .returns { ChunkElement(type: type, number: ChunkNumber.range(ChunkNumberRange(minimumNumber: $0, maximumNumber: $1))) }
        
        let schema = Schema<ChunkElement>("\(ordinalSchema)\(or: rangeElement)")
        
        return schema
    }
    
}
