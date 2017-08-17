//
//  main.swift
//  ExtractImage
//
//  Created by Pierre Lorenzi on 28/09/2015.
//  Copyright © 2015 Pierre Lorenzi. All rights reserved.
//


/// The stack block (STAK), containing the global data about the stack
public class StackBlock: HyperCardFileBlock {
    
    override class var Name: NumericName {
        return NumericName(string: "STAK")!
    }
    
    /* Size */
    public var totalSize: Int {
        return data.readUInt32(at: 0x14)
    }
    public var stackSize: Int {
        return data.readUInt32(at: 0x18)
    }
    
    /* Backgrounds */
    public var backgroundCount: Int {
        return data.readUInt32(at: 0x24)
    }
    public var firstBackgroundIdentifier: Int {
        return data.readUInt32(at: 0x28)
    }
    
    /* Cards */
    public var cardCount: Int {
        return data.readUInt32(at: 0x2C)
    }
    public var firstCardIdentifier: Int {
        return data.readUInt32(at: 0x30)
    }
    public var listIdentifier: Int {
        return data.readUInt32(at: 0x34)
    }
    
    /* Free */
    public var freeCount: Int {
        return data.readUInt32(at: 0x38)
    }
    public var freeSize: Int {
        return data.readUInt32(at: 0x3C)
    }
    
    public var printBlockIdentifier: Int {
        return data.readUInt32(at: 0x40)
    }
    
    public var passwordHash: Int? {
        let value = data.readUInt32(at: 0x44)
        guard value != 0 else {
            return nil
        }
        return value
    }
    
    /* User Level */
    public var userLevel: UserLevel {
        let userLevelIndex = data.readUInt16(at: 0x48)
        return UserLevel(rawValue: userLevelIndex)!
    }
    
    /* Security */
    public var cantAbort: Bool {
        return data.readFlag(at: 0x4C, bitOffset: 11)
    }
    public var cantDelete: Bool {
        return data.readFlag(at: 0x4C, bitOffset: 14)
    }
    public var cantModify: Bool {
        return data.readFlag(at: 0x4C, bitOffset: 15)
    }
    public var cantPeek: Bool {
        return data.readFlag(at: 0x4C, bitOffset: 10)
    }
    public var privateAccess: Bool {
        return data.readFlag(at: 0x4C, bitOffset: 13)
    }
    
    /* Version */
    public var versionAtCreation: Version? {
        let code = data.readUInt32(at: 0x60)
        guard code != 0 else {
            return nil
        }
        return Version(code: code)
    }
    public var versionAtLastCompacting: Version? {
        let code = data.readUInt32(at: 0x64)
        guard code != 0 else {
            return nil
        }
        return Version(code: code)
    }
    public var versionAtLastModificationSinceLastCompacting: Version? {
        let code = data.readUInt32(at: 0x68)
        guard code != 0 else {
            return nil
        }
        return Version(code: code)
    }
    public var versionAtLastModification: Version? {
        let code = data.readUInt32(at: 0x6C)
        guard code != 0 else {
            return nil
        }
        return Version(code: code)
    }
    
    public var checkSum: Int {
        return data.readUInt32(at: 0x70)
    }
    public func isChecksumValid() -> Bool {
        var sum: UInt32 = 0
        for i in 0..<0x180 {
            sum = sum &+ UInt32(data.readUInt32(at: i*4))
        }
        return sum == 0
    }
    
    public var markedCardCount: Int {
        return data.readUInt32(at: 0x74)
    }
    
    /* Window size */
    public var windowRectangle: Rectangle {
        return data.readRectangle(at: 0x78)
    }
    public var screenRectangle: Rectangle {
        return data.readRectangle(at: 0x80)
    }
    public var scrollPoint: Point {
        let y = data.readUInt32(at: 0x88)
        let x = data.readUInt32(at: 0x8A)
        return Point(x: x, y: y)
    }
    
    /* Text fonts and styles */
    public var fontBlockIdentifier: Int? {
        let value = data.readUInt32(at: 0x1B0)
        guard value != 0 else {
            return nil
        }
        return value
    }
    public var styleBlockIdentifier: Int? {
        let value = data.readUInt32(at: 0x1B4)
        guard value != 0 else {
            return nil
        }
        return value
    }
    
    public static let defaultWidth = 512
    public static let defaultHeight = 342
    
    /* Size */
    public var size: Size {
        let dataWidth = data.readUInt16(at: 0x1BA)
        let dataHeight = data.readUInt16(at: 0x1B8)
        let width = (dataWidth == 0) ? StackBlock.defaultWidth : dataWidth
        let height = (dataHeight == 0) ? StackBlock.defaultHeight : dataHeight
        return Size(width: width, height: height)
    }
    
    /* Patterns */
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
    
    /* Free blocks */
    public struct FreeLocation {
        public var offset: Int
        public var size: Int
    }
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
    
    /* Script */
    public var script: HString {
        guard self.data.length > 0x600 else {
            return ""
        }
        return data.readString(at: 0x600)
    }
    
}


