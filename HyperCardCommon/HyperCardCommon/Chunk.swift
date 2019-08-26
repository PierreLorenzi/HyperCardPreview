//
//  Chunk.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 09/06/2018.
//  Copyright © 2018 Pierre Lorenzi. All rights reserved.
//


public typealias ContainerChunk = Chunk<ContainerDescriptor>
public typealias ExpressionChunk = Chunk<Expression>

public struct Chunk<Parent> {
    public var type: ChunkType
    public var number: ChunkNumber
    public var parent: Parent
}

public enum ChunkType {
    case line
    case item
    case word
    case character
}

public enum ChunkNumber {
    case single(Ordinal)
    case range(ChunkNumberRange)
}

public struct ChunkNumberRange {
    public var minimumNumber: Expression
    public var maximumNumber: Expression
}
