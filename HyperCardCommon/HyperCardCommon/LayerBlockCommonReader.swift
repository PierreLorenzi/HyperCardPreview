//
//  LayerBlockReaderV2.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 03/06/2018.
//  Copyright © 2018 Pierre Lorenzi. All rights reserved.
//


/// Reads common fields between background and card blocks. The common fields are either
/// at the beginning of the block, either at the end, and the specific fields are in-between.
/// So, to build a LayerBlockReaderV2, a partOffset must be provided to locate the end of the block.
public struct LayerBlockCommonReader: LayerBlockReader {
    
    private let data: DataRange
    
    private let version: FileVersion
    
    private let partOffset: Int
    
    private static let version1Offset = -4
    
    public init(data: DataRange, version: FileVersion, partOffset: Int) {
        self.data = data
        self.version = version
        self.partOffset = partOffset
    }
    
    public func readIdentifier() -> Int {
        return data.readUInt32(at: 0x8)
    }
    
    public func readBitmapIdentifier() -> Int? {
        let value = data.readSInt32(at: 0x10 + self.computeVersionOffset())
        guard value != 0 else {
            return nil
        }
        return value
    }
    
    private func computeVersionOffset() -> Int {
        return version.isTwo() ? 0 : LayerBlockCommonReader.version1Offset
    }
    
    public func readCantDelete() -> Bool {
        return data.readFlag(at: 0x14 + self.computeVersionOffset(), bitOffset: 14)
    }
    
    public func readShowPict() -> Bool {
        return !data.readFlag(at: 0x14 + self.computeVersionOffset(), bitOffset: 13)
    }
    
    public func readDontSearch() -> Bool {
        return data.readFlag(at: 0x14 + self.computeVersionOffset(), bitOffset: 11)
    }
    
    public func readPartCount() -> Int {
        return data.readUInt16(at: self.partOffset - 0xE)
    }
    
    public func readNextAvailableIdentifier() -> Int {
        return data.readUInt16(at: self.partOffset - 0xC)
    }
    
    public func readPartSize() -> Int {
        return data.readUInt32(at: self.partOffset - 0xA)
    }
    
    public func readContentCount() -> Int {
        return data.readUInt16(at: self.partOffset - 0x6)
    }
    
    public func readContentSize() -> Int {
        return data.readUInt32(at: self.partOffset - 0x4)
    }
    
    public func extractPartReaders() -> [PartBlockReader] {
        
        var parts = [PartBlockReader]()
        var offset = self.partOffset
        let partCount = self.readPartCount()
        
        /* Read the parts */
        for _ in 0..<partCount {
            
            /* Read the size of the part block */
            let size = data.readUInt16(at: offset)
            
            /* Build the part block */
            let dataRange = DataRange(sharedData: self.data.sharedData, offset: self.data.offset + offset, length: size)
            let part = PartBlockReader(data: dataRange)
            parts.append(part)
            
            /* Move to the next part data */
            offset += size
        }
        return parts
    }
    
    public func extractContentReaders() -> [ContentBlockReader] {
        
        /* Special case for v1 */
        guard self.version.isTwo() else {
            return self.extractContentReadersV1()
        }
        
        var contents = [ContentBlockReader]()
        
        let partSize = self.readPartSize()
        let contentCount = self.readContentCount()
        var offset = self.partOffset + partSize
        
        for _ in 0..<contentCount {
            
            /* Read the identifier and size */
            let storedIdentifier = data.readSInt16(at: offset)
            let size = data.readUInt16(at: offset + 2)
            
            /* If the identifier is 0 the file is corrupted, but HyperCard opens it anyway  */
            guard storedIdentifier != 0 else {
                break
            }
            
            /* If the identifier is <0, then it is a card content */
            let identifier = abs(storedIdentifier)
            let layerType: LayerType = (storedIdentifier < 0) ? .card : .background
            
            /* Build the content block */
            let dataRange = DataRange(sharedData: self.data.sharedData, offset: self.data.offset + offset, length: size + 4)
            let content = ContentBlockReader(data: dataRange, version: self.version, identifier: identifier, layerType: layerType)
            contents.append(content)
            
            /* Skip the content */
            offset += size + 4
            /* Round to 32 bits */
            offset = upToMultiple(offset, 2)
        }
        
        return contents
    }
    
    /* The contents are all unformatted strings */
    private func extractContentReadersV1() -> [ContentBlockReader] {
        
        var contents = [ContentBlockReader]()
        
        let partSize = self.readPartSize()
        let contentCount = self.readContentCount()
        var offset = self.partOffset + partSize
        
        for _ in 0..<contentCount {
            
            /* Read the identifier and size */
            let storedIdentifier = data.readSInt16(at: offset)
            
            /* If the identifier is <0, then it is a card content */
            let identifier = abs(storedIdentifier)
            let layerType: LayerType = (storedIdentifier < 0) ? .card : .background
            
            let contentOffset = offset
            
            /* Skip the content */
            offset += 2
            while data.readUInt8(at: offset) != 0 {
                offset += 1
            }
            offset += 1
            
            /* Build the content block */
            let dataRange = DataRange(sharedData: self.data.sharedData, offset: self.data.offset + contentOffset, length: offset - contentOffset)
            let content = ContentBlockReader(data: dataRange, version: self.version, identifier: identifier, layerType: layerType)
            contents.append(content)
        }
        
        return contents
    }
    
    public func readName() -> HString {
        return data.readString(at: self.partOffset + self.readPartSize() + self.readContentSize())
    }
    
    public func readScript() -> HString {
        return data.readString(at: self.partOffset + self.readPartSize() + self.readContentSize() + self.readName().length + 1)
    }
    
}
