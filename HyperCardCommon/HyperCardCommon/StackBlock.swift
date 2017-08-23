//
//  main.swift
//  ExtractImage
//
//  Created by Pierre Lorenzi on 28/09/2015.
//  Copyright © 2015 Pierre Lorenzi. All rights reserved.
//


/// The stack block (STAK), containing the global data about the stack
public class StackBlock: HyperCardFileBlock {
    
    private let decodedHeader: Data?
    
    public init(data: DataRange, decodedHeader: Data? = nil) {
        self.decodedHeader = decodedHeader
        
        super.init(data: data)
    }
    
    private func readDecodedUInt32(at offset: Int) -> Int {
        
        /* If the header is encrypted, use the decrypted version */
        if let decodedHeader = self.decodedHeader {
            return decodedHeader.readUInt32(at: offset - 0x18)
        }
        
        return data.readUInt32(at: offset)
    }
    
    private func readDecodedUInt16(at offset: Int) -> Int {
        
        /* If the header is encrypted, use the decrypted version */
        if let decodedHeader = self.decodedHeader {
            return decodedHeader.readUInt16(at: offset - 0x18)
        }
        
        return data.readUInt16(at: offset)
    }
    
    override class var Name: NumericName {
        return NumericName(string: "STAK")!
    }
    
    /// Total size of the stack data fork
    public var totalSize: Int {
        return data.readUInt32(at: 0x14)
    }
    
    /// Size of the STAK block
    public var stackSize: Int {
        return self.readDecodedUInt32(at: 0x18)
    }
    
    /// Number of backgrounds in this stack
    public var backgroundCount: Int {
        return self.readDecodedUInt32(at: 0x24)
    }
    
    /// ID of the first background
    public var firstBackgroundIdentifier: Int {
        return self.readDecodedUInt32(at: 0x28)
    }
    
    /// Number of cards in this stack
    public var cardCount: Int {
        return self.readDecodedUInt32(at: 0x2C)
    }
    
    /// ID of the first card
    public var firstCardIdentifier: Int {
        return self.readDecodedUInt32(at: 0x30)
    }
    
    /// ID of the 'LIST' block in the stack file
    public var listIdentifier: Int {
        return self.readDecodedUInt32(at: 0x34)
    }
    
    /// Number of FREE blocks
    public var freeCount: Int {
        return self.readDecodedUInt32(at: 0x38)
    }
    
    /// Total size of all FREE blocks (=the free size of this stack)
    public var freeSize: Int {
        return self.readDecodedUInt32(at: 0x3C)
    }
    
    /// ID of the 'PRNT' block in the stack file
    public var printBlockIdentifier: Int {
        return self.readDecodedUInt32(at: 0x40)
    }
    
    /// Hash of the password
    public var passwordHash: Int? {
        let value = self.readDecodedUInt32(at: 0x44)
        guard value != 0 else {
            return nil
        }
        return value
    }
    
    /// User Level for this stack
    public var userLevel: UserLevel {
        let userLevelIndex = self.readDecodedUInt16(at: 0x48)
        if userLevelIndex == 0 {
            return UserLevel.script
        }
        return UserLevel(rawValue: userLevelIndex)!
    }
    
    /// Can't Abort
    public var cantAbort: Bool {
        return data.readFlag(at: 0x4C, bitOffset: 11)
    }
    
    /// Can't Delete
    public var cantDelete: Bool {
        return data.readFlag(at: 0x4C, bitOffset: 14)
    }
    
    /// Can't Modify
    public var cantModify: Bool {
        return data.readFlag(at: 0x4C, bitOffset: 15)
    }
    
    /// Can't Peek
    public var cantPeek: Bool {
        return data.readFlag(at: 0x4C, bitOffset: 10)
    }
    
    /// Private Access
    public var privateAccess: Bool {
        return data.readFlag(at: 0x4C, bitOffset: 13)
    }
    
    /// HyperCard Version at creation
    public var versionAtCreation: Version? {
        let code = data.readUInt32(at: 0x60)
        guard code != 0 else {
            return nil
        }
        return Version(code: code)
    }
    
    /// HyperCard Version at last compacting
    public var versionAtLastCompacting: Version? {
        let code = data.readUInt32(at: 0x64)
        guard code != 0 else {
            return nil
        }
        return Version(code: code)
    }
    
    /// HyperCard Version at last modification since last compacting
    public var versionAtLastModificationSinceLastCompacting: Version? {
        let code = data.readUInt32(at: 0x68)
        guard code != 0 else {
            return nil
        }
        return Version(code: code)
    }
    
    /// HyperCard Version at last modification
    public var versionAtLastModification: Version? {
        let code = data.readUInt32(at: 0x6C)
        guard code != 0 else {
            return nil
        }
        return Version(code: code)
    }
    
    /// Checksum of the STAK block
    public var checkSum: Int {
        return data.readUInt32(at: 0x70)
    }
    
    /// Checks the checksum
    public func isChecksumValid() -> Bool {
        var sum: UInt32 = 0
        for i in 0..<0x180 {
            sum = sum &+ UInt32(data.readUInt32(at: i*4))
        }
        
        /* The checksum is done with the decoded data */
        if let decodedHeader = self.decodedHeader {
            for i in 0..<0xC {
                sum = sum &+ UInt32(decodedHeader.readUInt32(at: i*4))
                sum = sum &- UInt32(data.readUInt32(at: 0x18 + i*4))
            }
            sum = sum &+ UInt32(decodedHeader.readUInt16(at: 0x30) << 16)
            sum = sum &- UInt32(data.readUInt32(at: 0x48))
        }
        
        return sum == 0
    }
    
    /// Number of marked cards in this stack
    public var markedCardCount: Int {
        return data.readUInt32(at: 0x74)
    }
    
    /// Rectangle of the card window in the screen
    public var windowRectangle: Rectangle {
        return data.readRectangle(at: 0x78)
    }
    
    /// Screen resolution for the window rectangle
    public var screenRectangle: Rectangle {
        return data.readRectangle(at: 0x80)
    }
    
    /// Origin of scroll
    public var scrollPoint: Point {
        let y = data.readUInt32(at: 0x88)
        let x = data.readUInt32(at: 0x8A)
        return Point(x: x, y: y)
    }
    
    /// ID of the FTBL (font table) block
    public var fontBlockIdentifier: Int? {
        let value = data.readUInt32(at: 0x1B0)
        guard value != 0 else {
            return nil
        }
        return value
    }
    
    /// ID of the STBL (style table) block
    public var styleBlockIdentifier: Int? {
        let value = data.readUInt32(at: 0x1B4)
        guard value != 0 else {
            return nil
        }
        return value
    }
    
    public static let defaultWidth = 512
    public static let defaultHeight = 342
    
    /// 2D size of the cards in this stack
    public var size: Size {
        let dataWidth = data.readUInt16(at: 0x1BA)
        let dataHeight = data.readUInt16(at: 0x1B8)
        let width = (dataWidth == 0) ? StackBlock.defaultWidth : dataWidth
        let height = (dataHeight == 0) ? StackBlock.defaultHeight : dataHeight
        return Size(width: width, height: height)
    }
    
    /// Table of patterns
    public var patterns: [Image] {
        var offset = 0x2C0
        var patterns = [Image]()
        for _ in 0..<40 {
            
            /* Read the pattern */
            let pattern = Image(data: self.data.sharedData, offset: self.data.offset + offset, width: 8, height: 8)
            patterns.append(pattern)
            
            /* Move to next pattern */
            offset += 8
        }
        
        return patterns
    }
    
    /// Record of a free block in a stack file
    public struct FreeLocation {
        public var offset: Int
        public var size: Int
    }
    
    /// Table of the FREE blocks
    public var freeLocations: [FreeLocation] {
        var locations = [FreeLocation]()
        var offset = 0x400
        let count = self.freeCount
        for _ in 0..<count {
            let freeOffset = data.readUInt32(at: offset)
            let freeSize = data.readUInt32(at: offset + 4)
            locations.append(FreeLocation(offset: freeOffset, size: freeSize))
            offset += 8
        }
        return locations
    }
    
    /// Stack script
    public var script: HString {
        guard self.data.length > 0x600 else {
            return ""
        }
        return data.readString(at: 0x600)
    }
    
}


