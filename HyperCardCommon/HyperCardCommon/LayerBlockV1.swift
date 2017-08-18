//
//  LayerBlockV1.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 07/03/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//



/* We can't make a common class because CardV1 inherits from Card and BackgroundV1 from Background.
 So there is just some common code here.
 */


/// Subclass for V1 stacks
public class LayerBlockV1: DataBlock {
    
    /* LAYER V1 VALUES, we have to write them here to keep inheriting from Card */
    
    /* The values are shifted */
    public var bitmapIdentifier: Int? {
        let value = data.readSInt32(at: 0xC)
        guard value != 0 else {
            return nil
        }
        return value
    }
    
    public var cantDelete: Bool {
        return data.readFlag(at: 0x10, bitOffset: 14)
    }
    
    public var showPict: Bool {
        return !data.readFlag(at: 0x10, bitOffset: 13)
    }
    
    public var dontSearch: Bool {
        return data.readFlag(at: 0x10, bitOffset: 11)
    }
    
    /* The contents are all unformatted strings */
    public func listContents(partOffset: Int, partSize: Int, contentCount: Int) -> [ContentBlock] {
        
        var contents = [ContentBlock]()
        
        var offset = partOffset + partSize
        
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
            let content = ContentBlockV1(data: dataRange, identifier: identifier, layerType: layerType)
            contents.append(content)
        }
        
        return contents
    }
    
}
