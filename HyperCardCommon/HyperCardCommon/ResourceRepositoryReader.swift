//
//  ResourceRepositoryReader.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 05/06/2018.
//  Copyright © 2018 Pierre Lorenzi. All rights reserved.
//


public struct ResourceRepositoryReader {
    
    private let data: DataRange
    
    private let dataOffset: Int
    
    public init(data: DataRange) {
        self.data = data
        self.dataOffset = data.readUInt32(at: 0x0)
    }
    
    /// Offset from beginning of resource file to resource data
    public func readDataOffset() -> Int {
        return self.dataOffset
    }
    
    /// Offset from beginning of resource file to resource map
    public func readMapOffset() -> Int {
        return data.readUInt32(at: 0x4)
    }
    
    /// Length of resource data
    public func readDataLength() -> Int {
        return data.readUInt32(at: 0x8)
    }
    
    /// Length of resource map
    public func readMapLength() -> Int {
        return data.readUInt32(at: 0xC)
    }
    
    /// The resource map
    public func extractResourceMapReader() -> ResourceMapReader {
        let dataRange = DataRange(sharedData: data.sharedData, offset: data.offset + self.readMapOffset(), length: self.readMapLength())
        return ResourceMapReader(data: dataRange)
    }
    
    public func extractResourceData(at dataOffset: Int) -> DataRange {
        
        let offset = dataOffset + self.dataOffset
        let length = data.readUInt32(at: offset)
        return DataRange(sharedData: self.data.sharedData, offset: self.data.offset + offset + 4, length: length)
    }
    
}
