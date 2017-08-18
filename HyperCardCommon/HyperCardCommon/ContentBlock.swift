//
//  ContentBlock.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 26/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


/// A layer can be either a card or a background
public enum LayerType {
    case card
    case background
}


/// Content of a part
/// <p>
/// Part contents are separated from parts because it makes text search easier, because
/// background fields have text contents in the card, because background buttons have hilite
/// contents in the card
public class ContentBlock: DataBlock {
    
    /// The identifier of the part, this parameter is read separately
    public let identifier: Int
    
    /// Whether the part is in the background or the card, this parameter is read separately
    public let layerType: LayerType
    
    /// Main constructor
    public init(data: DataRange, identifier: Int, layerType: LayerType) {
        self.identifier = identifier
        self.layerType = layerType
        
        super.init(data: data)
    }
    
    /// The string content
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
    
    
    /// A style record of a styled content
    public struct TextFormatting {
        
        /// Offset of the style in the string content
        public let offset: Int
        
        /// ID of the style in the style table
        public let styleIdentifier: Int
    }
    
    /// The style records. They are sorted by offset. If nil, the string has no associated style.
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
