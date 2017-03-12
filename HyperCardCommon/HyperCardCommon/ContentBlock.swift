//
//  ContentBlock.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 26/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


public enum LayerType {
    case card
    case background
}


public class ContentBlock: DataBlock {
    
    public let identifier: Int
    public let layerType: LayerType
    
    public init(data: DataRange, identifier: Int, layerType: LayerType) {
        self.identifier = identifier
        self.layerType = layerType
        
        super.init(data: data)
    }
    
    public var string: HString {
        
        /* Check if we're a raw string or a formatted text */
        let plainTextMarker = data.readUInt8(at: 4)
        
        /* Plain text */
        if plainTextMarker == 0 {
            return data.readString(at: 5, length:data.length - 5)
        }
        else {
            let formattingLengthValue = data.readUInt16(at: 4)
            let formattingLength = formattingLengthValue - 0x8000
            let stringOffset = 4 + formattingLength
            return data.readString(at: stringOffset, length:data.length - 4 - formattingLength)
        }
    }
    
    
    public struct TextFormatting {
        let offset: Int
        let styleIdentifier: Int
    }
    
    public var formattingChanges: [TextFormatting]? {
        
        /* Check if we're a raw string or a formatted text */
        let plainTextMarker = data.readUInt8(at: 4)
        guard plainTextMarker != 0 else {
            return nil
        }
        
        /* Plain text */
        var changes: [TextFormatting] = []
        let formattingLengthValue = data.readUInt16(at: 4)
        let formattingLength = formattingLengthValue ^ 0x8000
        let formattingCount = (formattingLength - 2) / 4
        var offset = 6
        for _ in 0..<formattingCount {
            let changeOffset = data.readUInt16(at: offset)
            let styleIdentifier = data.readUInt16(at: offset + 2)
            changes.append(TextFormatting(offset: changeOffset, styleIdentifier: styleIdentifier))
            offset += 4
        }
        return changes
    }
    
}
