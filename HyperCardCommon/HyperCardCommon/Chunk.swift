//
//  Chunk.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 09/06/2018.
//  Copyright © 2018 Pierre Lorenzi. All rights reserved.
//


public struct ChunkExpression: Equatable {
    public var expression: Expression
    public var chunk: Chunk
    
    public init(expression: Expression, chunk: Chunk) {
        self.expression = expression
        self.chunk = chunk
    }
}

public struct ChunkContainer: Equatable {
    public var container: ContainerDescriptor
    public var chunk: Chunk
}

public struct ChunkElement: Equatable {
    public var type: ChunkType
    public var number: ChunkNumber
    
    public init(type: ChunkType, number: ChunkNumber) {
        self.type = type
        self.number = number
    }
}

public struct Chunk: Equatable {
    
    /* Ordered from smallest to greatest */
    public var elements: [ChunkElement]
    
    public init(elements: [ChunkElement]) {
        self.elements = elements
    }
}

public enum ChunkType: Equatable {
    case line
    case item
    case word
    case character
}

public enum ChunkNumber: Equatable {
    case single(Ordinal)
    case range(ChunkNumberRange)
}

public struct ChunkNumberRange: Equatable {
    public var minimumNumber: Expression
    public var maximumNumber: Expression
    
    public init(minimumNumber: Expression, maximumNumber: Expression) {
        self.minimumNumber = minimumNumber
        self.maximumNumber = maximumNumber
    }
}
