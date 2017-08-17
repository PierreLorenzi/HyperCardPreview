//
//  CardList.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 12/02/2016.
//  Copyright © 2016 Pierre Lorenzi. All rights reserved.
//


public struct PageReference {
    public var identifier: Int
    public var cardCount: Int
}


/// The list block (LIST), containing the card list. To make insertions and deletions faster,
/// it is divided in sections called pages.
public class ListBlock: HyperCardFileBlock {
    
    override class var Name: NumericName {
        return NumericName(string: "LIST")!
    }
    
    public var pageCount: Int {
        return data.readUInt32(at: 0x10)
    }
    
    public var pageSize: Int {
        return data.readUInt32(at: 0x14)
    }
    
    public var cardCount: Int {
        return data.readUInt32(at: 0x18)
    }
    
    public var cardReferenceSize: Int {
        return data.readUInt16(at: 0x1C)
    }
    
    public var hashCountInCardReference: Int {
        return data.readUInt16(at: 0x20)
    }
    
    public var hashValueCount: Int {
        return data.readUInt16(at: 0x22)
    }
    
    public var checksum: Int {
        return data.readUInt32(at: 0x24)
    }
    public func isChecksumValid() -> Bool {
        var c: UInt32 = 0
        for reference in self.pageReferences {
            c = rotateRight3Bits(c + UInt32(reference.identifier)) + UInt32(reference.cardCount)
        }
        return c == UInt32(self.checksum)
    }
    
    public var totalPageEntryCount: Int {
        return data.readUInt32(at: 0x28)
    }
    
    /* Page References, ordered by index */
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




