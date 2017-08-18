//
//  CardList.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 12/02/2016.
//  Copyright © 2016 Pierre Lorenzi. All rights reserved.
//


/// Record of a page in the list
public struct PageReference {
    
    /// Identifier of the PAGE block
    public var identifier: Int
    
    /// Number of cards listed in the PAGE block
    public var cardCount: Int
}


/// The list block (LIST), containing the card list. To make insertions and deletions faster,
/// it is divided in sections called pages.
public class ListBlock: HyperCardFileBlock {
    
    override class var Name: NumericName {
        return NumericName(string: "LIST")!
    }
    
    /// Number of pages
    public var pageCount: Int {
        return data.readUInt32(at: 0x10)
    }
    
    /// Size of a page (always 0x800)
    public var pageSize: Int {
        return data.readUInt32(at: 0x14)
    }
    
    /// Total number of card entries in all the pages, should be equal to the number of cards
    public var cardCount: Int {
        return data.readUInt32(at: 0x18)
    }
    
    /// Size of a card entry in the pages
    public var cardReferenceSize: Int {
        return data.readUInt16(at: 0x1C)
    }
    
    /// Number of hash integers in a card entry in the pages, equal to (entry size - 4)/4
    /// (it is a parameter of the search hashes of the cards)
    public var hashCountInCardReference: Int {
        return data.readUInt16(at: 0x20)
    }
    
    /// Search hash value count (a parameter of the search hashes of the cards)
    public var hashValueCount: Int {
        return data.readUInt16(at: 0x22)
    }
    
    /// Checksum of the LIST block
    public var checksum: Int {
        return data.readUInt32(at: 0x24)
    }
    
    /// Checks the checksum
    public func isChecksumValid() -> Bool {
        var c: UInt32 = 0
        for reference in self.pageReferences {
            c = rotateRight3Bits(c + UInt32(reference.identifier)) + UInt32(reference.cardCount)
        }
        return c == UInt32(self.checksum)
    }
    
    /// Total number of entries in all the pages, should be equal to the number of cards
    public var totalPageEntryCount: Int {
        return data.readUInt32(at: 0x28)
    }
    
    /// Page References, ordered by index
    public var pageReferences: [PageReference] {
        let count = self.pageCount
        var references = [PageReference]()
        var offset = 0x30
        for _ in 0..<count {
            let identifier = data.readSInt32(at: offset)
            let cardCount = data.readUInt16(at: offset + 4)
            references.append(PageReference(identifier: identifier, cardCount: cardCount))
            offset += 6
        }
        return references
    }
    
}




