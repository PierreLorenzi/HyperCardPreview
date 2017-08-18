//
//  Layer.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 12/02/2016.
//  Copyright © 2016 Pierre Lorenzi. All rights reserved.
//

/// Abstract class for card and background blocks. They share a lot of fields.
public class LayerBlock: HyperCardFileBlock {
    
    /// The offset of the part list, it is different between cards and backgrounds
    public let partOffset: Int
    
    /// Builds a layer block. The data must be provided, as well as the offset of the part list
    public init(data: DataRange, partOffset: Int) {
        self.partOffset = partOffset
        super.init(data: data)
    }
    
    /// ID of bitmap block storing the picture of the layer. Nil if there is no picture.
    public var bitmapIdentifier: Int? {
        let value = data.readSInt32(at: 0x10)
        guard value != 0 else {
            return nil
        }
        return value
    }
    
    /// Can't Delete
    public var cantDelete: Bool {
        return data.readFlag(at: 0x14, bitOffset: 14)
    }
    
    /// Show Picture
    public var showPict: Bool {
        return !data.readFlag(at: 0x14, bitOffset: 13)
    }
    
    /// Don't Search
    public var dontSearch: Bool {
        return data.readFlag(at: 0x14, bitOffset: 11)
    }
    
    /// Number of parts
    public var partCount: Int {
        return data.readUInt16(at: self.partOffset - 0xE)
    }
    
    /// ID to give to a new part
    public var nextAvailableIdentifier: Int {
        return data.readUInt16(at: self.partOffset - 0xC)
    }
    
    /// Total size of the part list, in bytes
    public var partSize: Int {
        return data.readUInt32(at: self.partOffset - 0xA)
    }
    
    /// Number of part contents
    public var contentCount: Int {
        return data.readUInt16(at: self.partOffset - 0x6)
    }
    
    /// Total size of the part content list, in bytes
    public var contentSize: Int {
        return data.readUInt32(at: self.partOffset - 0x4)
    }
    
    /// The parts in the layer
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
    
    /// The part contents in the layer
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
    
    /// Name
    public var name: HString {
        return data.readString(at: self.partOffset + self.partSize + self.contentSize)
    }
    
    /// Script
    public var script: HString {
        return data.readString(at: self.partOffset + self.partSize + self.contentSize + self.name.length + 1)
    }
    
}
