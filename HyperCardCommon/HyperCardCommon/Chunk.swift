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
}

public struct ChunkContainer: Equatable {
    public var container: ContainerDescriptor
    public var chunk: Chunk
}

public struct Chunk: Equatable {
    public var type: ChunkType
    public var number: ChunkNumber
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
}
