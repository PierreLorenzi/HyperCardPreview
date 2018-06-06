//
//  ListBlockReader.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 03/06/2018.
//  Copyright © 2018 Pierre Lorenzi. All rights reserved.
//


/// Reads inside a list (LIST) data block, which contains the card list of
/// the stack. The card list is divided into sections, called pages, in order
/// to speed up insertions and deletions.
public struct ListBlockReader {
    
    private let data: DataRange
    
    private let versionOffset: Int
    
    private static let version1Offset = -4
    
    public init(data: DataRange, version: FileVersion) {
        self.data = data
        self.versionOffset = version.isTwo() ? 0 : ListBlockReader.version1Offset
    }
    
    /// Identifier
    public func readIdentifier() -> Int {
        return data.readUInt32(at: 0x8)
    }
    
    /// Number of pages
    public func readPageCount() -> Int {
        return data.readUInt32(at: 0x10 + self.versionOffset)
    }
    
    /// Size of a page (always 0x800)
    public func readPageSize() -> Int {
        return data.readUInt32(at: 0x14 + self.versionOffset)
    }
    
    /// Total number of card entries in all the pages, should be equal to the number of cards
    public func readCardCount() -> Int {
        return data.readUInt32(at: 0x18 + self.versionOffset)
    }
    
    /// Size of a card entry in the pages
    public func readCardReferenceSize() -> Int {
        return data.readUInt16(at: 0x1C + self.versionOffset)
    }
    
    /// Number of hash integers in a card entry in the pages, equal to (entry size - 4)/4
    /// (it is a parameter of the search hashes of the cards)
    public func readHashCountInCardReference() -> Int {
        return data.readUInt16(at: 0x20 + self.versionOffset)
    }
    
    /// Search hash value count (a parameter of the search hashes of the cards)
    public func readHashValueCount() -> Int {
        return data.readUInt16(at: 0x22 + self.versionOffset)
    }
    
    /// Checksum of the LIST block
    public func readChecksum() -> Int {
        return data.readUInt32(at: 0x24 + self.versionOffset)
    }
    
    /// Checks the checksum
    public func isChecksumValid() -> Bool {
        var c: UInt32 = 0
        let pageReferences = self.readPageReferences()
        for reference in pageReferences {
            c = rotateRight3Bits(c + UInt32(reference.identifier)) + UInt32(reference.cardCount)
        }
        let expectedChecksum = self.readChecksum()
        return c == UInt32(expectedChecksum)
    }
    
    /// Total number of entries in all the pages, should be equal to the number of cards
    public func readTotalPageEntryCount() -> Int {
        return data.readUInt32(at: 0x28 + self.versionOffset)
    }
    
    /// Page References, ordered by index
    public func readPageReferences() -> [PageReference] {
        let count = self.readPageCount()
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

