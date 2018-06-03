//
//  StackBlockReader.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 03/06/2018.
//  Copyright © 2018 Pierre Lorenzi. All rights reserved.
//


/// The stack block (STAK), containing the global data about the stack
public struct StackBlockReader {
    
    private let data: DataRange
    
    private let decodedHeader: Data?
    
    public init(data: DataRange, decodedHeader: Data?) {
        self.data = data
        self.decodedHeader = decodedHeader
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
    
    // The version of the stack format: V1 or V2. Parsed here because it must be read before
    /// parsing the file.
    public func readVersion() -> FileVersion {
        let format = self.data.readUInt32(at: 0x10)
        switch format {
        case 1...7:
            /* Pre-release */
            return .v1
        case 8:
            return .v1
        case 9:
            /* Pre-release */
            return .v2
        case 10:
            return .v2
        default:
            fatalError()
        }
    }
    
    /// Total size of the stack data fork
    public func readTotalSize() -> Int {
        return data.readUInt32(at: 0x14)
    }
    
    /// Size of the STAK block
    public func readStackSize() -> Int {
        return self.readDecodedUInt32(at: 0x18)
    }
    
    /// Number of backgrounds in this stack
    public func readBackgroundCount() -> Int {
        return self.readDecodedUInt32(at: 0x24)
    }
    
    /// ID of the first background
    public func readFirstBackgroundIdentifier() -> Int {
        return self.readDecodedUInt32(at: 0x28)
    }
    
    /// Number of cards in this stack
    public func readCardCount() -> Int {
        return self.readDecodedUInt32(at: 0x2C)
    }
    
    /// ID of the first card
    public func readFirstCardIdentifier() -> Int {
        return self.readDecodedUInt32(at: 0x30)
    }
    
    /// ID of the 'LIST' block in the stack file
    public func readListIdentifier() -> Int {
        return self.readDecodedUInt32(at: 0x34)
    }
    
    /// Number of FREE blocks
    public func readFreeCount() -> Int {
        return self.readDecodedUInt32(at: 0x38)
    }
    
    /// Total size of all FREE blocks (=the free size of this stack)
    public func readFreeSize() -> Int {
        return self.readDecodedUInt32(at: 0x3C)
    }
    
    /// ID of the 'PRNT' block in the stack file
    public func readPrintBlockIdentifier() -> Int {
        return self.readDecodedUInt32(at: 0x40)
    }
    
    /// Hash of the password
    public func readPasswordHash() -> Int? {
        let value = self.readDecodedUInt32(at: 0x44)
        guard value != 0 else {
            return nil
        }
        return value
    }
    
    /// User Level for this stack
    public func readUserLevel() -> UserLevel {
        let userLevelIndex = self.readDecodedUInt16(at: 0x48)
        if userLevelIndex == 0 {
            return UserLevel.script
        }
        return UserLevel(rawValue: userLevelIndex)!
    }
    
    /// Can't Abort
    public func readCantAbort() -> Bool {
        return data.readFlag(at: 0x4C, bitOffset: 11)
    }
    
    /// Can't Delete
    public func readCantDelete() -> Bool {
        return data.readFlag(at: 0x4C, bitOffset: 14)
    }
    
    /// Can't Modify
    public func readCantModify() -> Bool {
        return data.readFlag(at: 0x4C, bitOffset: 15)
    }
    
    /// Can't Peek
    public func readCantPeek() -> Bool {
        return data.readFlag(at: 0x4C, bitOffset: 10)
    }
    
    /// Private Access
    public func readPrivateAccess() -> Bool {
        return data.readFlag(at: 0x4C, bitOffset: 13)
    }
    
    /// Private Access
    public func readVersionAtCreation() -> Version? {
        let code = data.readUInt32(at: 0x60)
        guard code != 0 else {
            return nil
        }
        return Version(code: code)
    }
    
    /// HyperCard Version at last compacting
    public func readVersionAtLastCompacting() -> Version? {
        let code = data.readUInt32(at: 0x64)
        guard code != 0 else {
            return nil
        }
        return Version(code: code)
    }
    
    /// HyperCard Version at last modification since last compacting
    public func readVersionAtLastModificationSinceLastCompacting() -> Version? {
        let code = data.readUInt32(at: 0x68)
        guard code != 0 else {
            return nil
        }
        return Version(code: code)
    }
    
    /// HyperCard Version at last modification
    public func readVersionAtLastModification() -> Version? {
        let code = data.readUInt32(at: 0x6C)
        guard code != 0 else {
            return nil
        }
        return Version(code: code)
    }
    
    /// Checksum of the STAK block
    public func readCheckSum() -> Int {
        
        /* In version 1, the checksum was somewhere else */
        guard self.readVersion().isTwo() else {
            return self.data.readUInt32(at: 0xC)
        }
        
        return data.readUInt32(at: 0x70)
    }
    
    /// Checks the checksum
    public func isChecksumValid() -> Bool {
        var sum: UInt32 = 0
        for i in 0..<0x180 {
            sum = sum &+ UInt32(data.readUInt32(at: i*4))
        }
        
        /* The checksum is done with the decoded data, so subtract the encoded data and
         add the decoded one. */
        if let decodedHeader = self.decodedHeader {
            for i in 0..<0xC {
                sum = sum &+ UInt32(decodedHeader.readUInt32(at: i*4))
                sum = sum &- UInt32(data.readUInt32(at: 0x18 + i*4))
            }
            
            /* The last integer is half encoded half clear */
            sum = sum &+ UInt32(decodedHeader.readUInt16(at: 0x30) << 16 | data.readUInt16(at: 0x4A))
            sum = sum &- UInt32(data.readUInt32(at: 0x48))
        }
        
        return sum == 0
    }
    
    /// Number of marked cards in this stack
    public func readMarkedCardCount() -> Int {
        return data.readUInt32(at: 0x74)
    }
    
    /// Rectangle of the card window in the screen
    public func readWindowRectangle() -> Rectangle {
        return data.readRectangle(at: 0x78)
    }
    
    /// Screen resolution for the window rectangle
    public func readScreenRectangle() -> Rectangle {
        return data.readRectangle(at: 0x80)
    }
    
    /// Origin of scroll
    public func readScrollPoint() -> Point {
        let y = data.readUInt32(at: 0x88)
        let x = data.readUInt32(at: 0x8A)
        return Point(x: x, y: y)
    }
    
    /// ID of the FTBL (font table) block
    public func readFontBlockIdentifier() -> Int? {
        let value = data.readUInt32(at: 0x1B0)
        guard value != 0 else {
            return nil
        }
        return value
    }
    
    /// ID of the STBL (style table) block
    public func readStyleBlockIdentifier() -> Int? {
        let value = data.readUInt32(at: 0x1B4)
        guard value != 0 else {
            return nil
        }
        return value
    }
    
    private static let defaultWidth = 512
    private static let defaultHeight = 342
    
    /// 2D size of the cards in this stack
    public func readSize() -> Size {
        let dataWidth = data.readUInt16(at: 0x1BA)
        let dataHeight = data.readUInt16(at: 0x1B8)
        let width = (dataWidth == 0) ? StackBlockReader.defaultWidth : dataWidth
        let height = (dataHeight == 0) ? StackBlockReader.defaultHeight : dataHeight
        return Size(width: width, height: height)
    }
    
    /// Table of patterns
    public func readPatterns() -> [Image] {
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
    
    /// Table of the FREE blocks
    public func readFreeLocations() -> [FreeLocation] {
        var locations = [FreeLocation]()
        var offset = 0x400
        let count = self.readFreeCount()
        for _ in 0..<count {
            let freeOffset = data.readUInt32(at: offset)
            let freeSize = data.readUInt32(at: offset + 4)
            locations.append(FreeLocation(offset: freeOffset, size: freeSize))
            offset += 8
        }
        return locations
    }
    
    /// Stack script
    public func readScript() -> HString {
        guard self.data.length > 0x600 else {
            return ""
        }
        return data.readString(at: 0x600)
    }
    
}
