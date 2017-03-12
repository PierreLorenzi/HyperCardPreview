//
//  DataObject.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 12/02/2016.
//  Copyright © 2016 Pierre Lorenzi. All rights reserved.
//

import Foundation


public struct DataRange {
    
    public let sharedData: Data
    public let offset: Int
    public let length: Int
    
    public init(sharedData: Data, offset: Int, length: Int) {
        self.sharedData = sharedData
        self.offset = offset
        self.length = length
    }
    
    public func readUInt8(at offset: Int) -> Int {
        return self.sharedData.readUInt8(at: self.offset + offset)
    }
    
    public func readSInt8(at offset: Int) -> Int {
        return self.sharedData.readSInt8(at: self.offset + offset)
    }
    
    public func readUInt16(at offset: Int) -> Int {
        return self.sharedData.readUInt16(at: self.offset + offset)
    }
    
    public func readSInt16(at offset: Int) -> Int {
        return self.sharedData.readSInt16(at: self.offset + offset)
    }
    
    public func readUInt32(at offset: Int) -> Int {
        return self.sharedData.readUInt32(at: self.offset + offset)
    }
    
    public func readSInt32(at offset: Int) -> Int {
        return self.sharedData.readSInt32(at: self.offset + offset)
    }
    
}


public extension DataRange {
    
    public func readFlag(at offset: Int, bitOffset: Int) -> Bool {
        
        let flags = readUInt16(at: offset)
        return (flags & (1 << bitOffset)) != 0
    }
    
    public func readRectangle(at offset: Int) -> Rectangle {
        /* Sometimes a flag is added to top bit, so remove it */
        let top = self.readUInt16(at: offset) & 0x7FFF
        let left = self.readUInt16(at: offset + 2) & 0x7FFF
        let bottom = self.readUInt16(at: offset + 4) & 0x7FFF
        let right = self.readUInt16(at: offset + 6) & 0x7FFF
        return Rectangle(top: top, left: left, bottom: bottom, right: right)
    }
    
    public func readString(at offset: Int) -> HString {
        return HString(copyNullTerminatedFrom: sharedData, at: self.offset + offset)
    }
    
    public func readString(at offset: Int, length: Int) -> HString {
        return HString(copyFrom: sharedData, at: self.offset + offset, length: length)
    }
    
}

public extension Data {
    
    public func readUInt8(at offset: Int) -> Int {
        return Int(self[offset])
    }
    
    public func readSInt8(at offset: Int) -> Int {
        let value = readUInt8(at: offset)
        if value > Int(Int8.max) {
            return value - Int(UInt8.max) - 1
        }
        return value
    }
    
    public func readUInt16(at offset: Int) -> Int {
        return Int(self[offset]) << 8 | Int(self[offset+1])
    }
    
    public func readSInt16(at offset: Int) -> Int {
        let value = readUInt16(at: offset)
        if value > Int(Int16.max) {
            return value - Int(UInt16.max) - 1
        }
        return value
    }
    
    public func readUInt32(at offset: Int) -> Int {
        return Int(self[offset]) << 24 | Int(self[offset+1]) << 16 | Int(self[offset+2]) << 8 | Int(self[offset+3])
    }
    
    public func readSInt32(at offset: Int) -> Int {
        let value = readUInt32(at: offset)
        if value > Int(Int32.max) {
            return value - Int(UInt32.max) - 1
        }
        return value
    }
    
}

public extension Image {
    
    public init(data: Data, offset: Int, width: Int, height: Int) {
        
        /* Create the image */
        self.init(width: width, height: height)
        
        /* Optimization if data can be read with 32-bit integers */
        if width & 31 == 0 {
            let count = width * height / 32
            for i in 0..<count {
                self.data[i] = UInt32(data.readUInt32(at: offset + i*4))
            }
            return
        }
        
        /* Fill the rows */
        let rowSize = width / 8
        var integerIndex = 0
        var shift: UInt32 = 24
        var i = offset
        for _ in 0..<height {
            for _ in 0..<rowSize {
                let byte = data[i]
                i += 1
                self.data[integerIndex] |= UInt32(byte) << shift
                if shift == 0 {
                    shift = 24
                    integerIndex += 1
                }
                else {
                    shift -= 8
                }
            }
            if shift != 24 {
                integerIndex += 1
                shift = 24
            }
        }
        
    }
    
}

public extension HString {
    
    /// Init with null-terminated data
    public init(copyNullTerminatedFrom data: Data, at offset: Int) {
        
        /* Find the null termination */
        let dataFromOffset = data.suffix(from: offset)
        let nullIndex = dataFromOffset.index(of: UInt8(0))!
        
        /* Extract the data for the string */
        let stringSlice = data[offset..<nullIndex]
        let stringData = Data(stringSlice)
        
        self.init(data: stringData)
    }
    
    /// Init with null-terminated data
    public init(copyFrom data: Data, at offset: Int, length: Int) {
        
        /* Extract the data for the string */
        let stringSlice = data[offset..<offset + length]
        let stringData = Data(stringSlice)
        
        self.init(data: stringData)
    }
    
}
