//
//  PageBlock.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 26/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


/// Record of a card in a page
public struct CardReference {
    
    /// Identifier of the card
    public var identifier: Int
    
    /// Is card marked
    public var marked: Bool
    
    /// Has the card text content in the fields
    public var hasTextContent: Bool
    
    /// Is the card at the beginning of a background
    public var isStartOfBackground: Bool
    
    /// Has the card a name
    public var hasName: Bool
    
    /// The search hash of the card
    public var searchHash: SearchHash
}



/// A page block contains a section of the card list
public class PageBlock: HyperCardFileBlock {
    
    override class var Name: NumericName {
        return NumericName(string: "PAGE")!
    }
    
    /// Number of cards in the page
    /// <p>
    /// This parameter is needed to read a page but it is only present in the list
    public let cardCount: Int
    
    /// Size of a card entry
    /// <p>
    /// This parameter is needed to read a page but it is only present in the list
    public let cardReferenceSize: Int
    
    /// Number of hash integers in a card entry
    /// <p>
    /// This parameter is needed to read a page but it is only present in the list
    public let hashValueCount: Int
    
    /// To build a new page, some parameters only present in the LIST block must be provided
    public init(data: DataRange, cardCount: Int, cardReferenceSize: Int, hashValueCount: Int) {
        self.cardCount = cardCount
        self.cardReferenceSize = cardReferenceSize
        self.hashValueCount = hashValueCount
        
        super.init(data: data)
    }
    
    /// ID of the list
    public var listIdentifier: Int {
        return data.readUInt32(at: 0x10)
    }
    
    /// Checksum of the PAGE block
    public var checksum: Int {
        return data.readUInt32(at: 0x14)
    }
    
    /// Checks the checksum
    public func isChecksumValid() -> Bool {
        var c: UInt32 = 0
        for r in self.cardReferences {
            c = rotateRight3Bits(c &+ UInt32(r.identifier))
        }
        return c == UInt32(self.checksum)
    }
    
    /// The records of the cards
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
    
    /// Builds a search hash from a binary data in a stack file
    public init(data: Data, offset: Int, length: Int, valueCount: Int) {
        var ints = [UInt32]()
        let count = length / 4
        for i in 0..<count {
            ints.append(UInt32(truncatingBitPattern: data.readUInt32(at: i*4)))
        }
        self.init(ints: ints, valueCount: valueCount)
    }
    
}
