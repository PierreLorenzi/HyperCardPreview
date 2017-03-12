//
//  Layer.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 12/02/2016.
//  Copyright © 2016 Pierre Lorenzi. All rights reserved.
//

public class LayerBlock: HyperCardFileBlock {
    
    public let partOffset: Int
    
    public init(data: DataRange, partOffset: Int) {
        self.partOffset = partOffset
        super.init(data: data)
    }
    
    public var bitmapIdentifier: Int? {
        let value = data.readSInt32(at: 0x10)
        guard value != 0 else {
            return nil
        }
        return value
    }
    
    public var cantDelete: Bool {
        return data.readFlag(at: 0x14, bitOffset: 14)
    }
    
    public var showPict: Bool {
        return !data.readFlag(at: 0x14, bitOffset: 13)
    }
    
    public var dontSearch: Bool {
        return data.readFlag(at: 0x14, bitOffset: 11)
    }
    
    public var partCount: Int {
        return data.readUInt16(at: self.partOffset - 0xE)
    }
    
    public var nextAvailableIdentifier: Int {
        return data.readUInt16(at: self.partOffset - 0xC)
    }
    
    public var partSize: Int {
        return data.readUInt32(at: self.partOffset - 0xA)
    }
    
    public var contentCount: Int {
        return data.readUInt16(at: self.partOffset - 0x6)
    }
    
    public var contentSize: Int {
        return data.readUInt32(at: self.partOffset - 0x4)
    }
    
    public var parts: [PartBlock] {
        
        var parts = [PartBlock]()
        var offset = self.partOffset
        let partCount = self.partCount
        
        /* Read the parts */
        for _ in 0..<partCount {
            
            /* Read the size of the part block */
            let size = data.readUInt16(at: offset)
            
            /* Build the part block */
            let dataRange = DataRange(sharedData: self.data.sharedData, offset: self.data.offset + offset, length: size)
            let part = PartBlock(data: dataRange)
            parts.append(part)
            
            /* Move to the next part data */
            offset += size
        }
        return parts
    }
    
    public var contents: [ContentBlock] {
        
        var contents = [ContentBlock]()
        
        let partSize = self.partSize
        let contentCount = self.contentCount
        var offset = self.partOffset + partSize
        
        for _ in 0..<contentCount {
            
            /* Read the identifier and size */
            let storedIdentifier = data.readSInt16(at: offset)
            let size = data.readUInt16(at: offset + 2)
            
            /* If the identifier is <0, then it is a card content */
            let identifier = abs(storedIdentifier)
            let layerType: LayerType = (storedIdentifier < 0) ? .card : .background
            
            /* Build the content block */
            let dataRange = DataRange(sharedData: self.data.sharedData, offset: self.data.offset + offset, length: size + 4)
            let content = ContentBlock(data: dataRange, identifier: identifier, layerType: layerType)
            contents.append(content)
            
            /* Skip the content */
            offset += size + 4
            /* Round to 32 bits */
            offset = upToMultiple(offset, 2)
        }
        
        return contents
    }
    
    public var name: HString {
        return data.readString(at: self.partOffset + self.partSize + self.contentSize)
    }
    
    public var script: HString {
        return data.readString(at: self.partOffset + self.partSize + self.contentSize + self.name.length + 1)
    }
    
}
