//
//  PageBlock.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 26/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//

/* Card references, ordered by index */

public struct CardReference {
    public var identifier: Int
    public var marked: Bool
    public var hasTextContent: Bool
    public var isStartOfBackground: Bool
    public var hasName: Bool
    public var searchHash: SearchHash
}



public class PageBlock: HyperCardFileBlock {
    
    override class var Name: NumericName {
        return NumericName(string: "PAGE")!
    }
    
    /* Parameters needed to read a page but only present in the list */
    public let cardCount: Int
    public let cardReferenceSize: Int
    public let hashValueCount: Int
    
    public init(data: DataRange, cardCount: Int, cardReferenceSize: Int, hashValueCount: Int) {
        self.cardCount = cardCount
        self.cardReferenceSize = cardReferenceSize
        self.hashValueCount = hashValueCount
        
        super.init(data: data)
    }
    
    public var listIdentifier: Int {
        return data.readUInt32(at: 0x10)
    }
    
    public var checksum: Int {
        return data.readUInt32(at: 0x14)
    }
    public func isChecksumValid() -> Bool {
        var c: UInt32 = 0
        for r in self.cardReferences {
            c = rotateRight3Bits(c &+ UInt32(r.identifier))
        }
        return c == UInt32(self.checksum)
    }
    
    public var cardReferences: [CardReference] {
        
        /* Read the references */
        var references = [CardReference]()
        var offset = 0x18
        for _ in 0..<self.cardCount {
            let identifier = data.readSInt32(at: offset)
            let marked = data.readFlag(at: offset + 4, bitOffset: 12)
            let hasTextContent = data.readFlag(at: offset + 4, bitOffset: 13)
            let isStartOfBackground = data.readFlag(at: offset + 4, bitOffset: 14)
            let hasName = data.readFlag(at: offset + 4, bitOffset: 15)
            let searchHash = SearchHash(data: self.data.sharedData, offset: data.offset + offset + 4, length: self.cardReferenceSize-4, valueCount: self.hashValueCount)
            references.append(CardReference(identifier: identifier, marked: marked, hasTextContent: hasTextContent, isStartOfBackground: isStartOfBackground, hasName: hasName, searchHash: searchHash))
            offset += self.cardReferenceSize
        }
        
        return references
        
    }
    
}


public extension SearchHash {
    
    public init(data: Data, offset: Int, length: Int, valueCount: Int) {
        var ints = [UInt32]()
        let count = length / 4
        for i in 0..<count {
            ints.append(UInt32(truncatingBitPattern: data.readUInt32(at: i*4)))
        }
        self.init(ints: ints, valueCount: valueCount)
    }
    
}
