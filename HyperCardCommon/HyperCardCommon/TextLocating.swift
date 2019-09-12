//
//  TextLocating.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 11/09/2019.
//  Copyright © 2019 Pierre Lorenzi. All rights reserved.
//


public extension TextLayout {
    
    func findCharacterIndex(at point: Point) -> Int {

        /* Special case if the point is above or below the text */
        guard point.y >= 0 else {
            return 0
        }
        guard point.y < self.size.height else {
            return text.string.length
        }
        
        /* Look for the line at the level of the point */
        let line = self.findLineAtHeight(point.y)
        
        /* Special case if the point is on the left or right of the line */
        guard point.x >= 0 else {
            return line.startIndex
        }
        guard point.x < self.size.width else {
            return line.endIndex+1
        }
        
        /* Look for the character index at the level of the point */
        let index = self.findCharacterIndex(at: point.x, in: line)
        
        return index
    }

    private func findLineAtHeight(_ height: Int) -> LineLayout {

        /* Estimate the line index with the height */
        let estimatedIndex = self.lines.count * height / self.size.height

        var index = estimatedIndex
        
        while true {
            
            let line = self.lines[index]
            let comparisonResult = compareHeightToLine(height, line)
            
            switch comparisonResult {
                
            case .equal:
                return line
                
            case .greater:
                index += 1
                
            case .less:
                index -= 1
            }
        }
        
        fatalError()
    }
    
    private func compareHeightToLine(_ height: Int, _ line: LineLayout) -> ComparisonResult {
        
        if height < line.top {
            return .less
        }
        
        if height >= line.bottom {
            return .greater
        }
        
        return .equal
    }
    
    private func findCharacterIndex(at offset: Int, in line: LineLayout) -> Int {
        
        var currentOffset = 0
        var attributeIndex = line.initialAttributeIndex
        var font = self.text.attributes[attributeIndex].font
        var nextAttributeIndex: Int? = (attributeIndex+1 == self.text.attributes.count) ? nil : self.text.attributes[attributeIndex+1].index
        
        /* Follow the characters one by one */
        for i in line.startIndex ..< line.endIndex {
            
            if i == nextAttributeIndex {
                attributeIndex += 1
                font = self.text.attributes[attributeIndex].font
                nextAttributeIndex = (attributeIndex+1 == self.text.attributes.count) ? nil : self.text.attributes[attributeIndex+1].index
            }
            
            let characterValue = Int(self.text.string[i])
            let characterWidth = font.glyphs[characterValue].width
            
            /* Check if the user is clicking at the left of the character */
            /* The '+1' is hastily retro-engineered from HyperCard */
            if offset <= currentOffset + (characterWidth+1)/2 {
                return i
            }
            
            /* Check if the user is clicking at the right of the character */
            if offset < currentOffset + characterWidth {
                return i+1
            }
            
            /* Update state */
            currentOffset += characterWidth
        }
        
        /* If we're here, the offset is after the characters */
        return min(line.endIndex+1, self.text.string.length)
    }
    
    struct TextPosition {
        var lineIndex: Int
        var offset: Offset
        
        enum Offset: Equatable {
            case value(Int)
            case endOfLine
        }
    }
    
    func findPosition(at index: Int) -> TextPosition {
        
        guard index < self.text.string.length else {
            return TextPosition(lineIndex: self.lines.count-1, offset: .endOfLine)
        }
        
        let lineIndex = self.findLineIndexAtCharacterIndex(index)
        let offset = self.findCharacterOffset(at: index, lineIndex: lineIndex)
        
        return TextPosition(lineIndex: lineIndex, offset: offset)
    }
    
    private func findLineIndexAtCharacterIndex(_ characterIndex: Int) -> Int {
        
        /* Estimate the line index with the height */
        let estimatedIndex = self.lines.count * characterIndex / self.text.string.length
        
        var index = estimatedIndex
        var direction: Direction? = nil
        
        while true {
            
            let line = self.lines[index]
            
            if characterIndex < line.startIndex {
                
                /* Handle characters between lines */
                if direction == .up {
                    return index-1
                }
                
                index -= 1
                direction = .down
                continue
            }
            
            if characterIndex >= line.endIndex {
                
                /* Handle characters between lines */
                if direction == .down || index == self.lines.count-1 {
                    return index
                }
                
                index += 1
                direction = .up
                continue
            }
            
            return index
        }
        
        fatalError()
    }
    
    private func findCharacterOffset(at index: Int, lineIndex: Int) -> TextPosition.Offset {
        
        let line = self.lines[lineIndex]
        guard index <= line.endIndex else {
            return .endOfLine
        }
        
        var offset = 0
        var attributeIndex = line.initialAttributeIndex
        var font = self.text.attributes[attributeIndex].font
        var nextAttributeIndex: Int? = (attributeIndex+1 == self.text.attributes.count) ? nil : self.text.attributes[attributeIndex+1].index
        
        /* Follow the characters one by one */
        for i in line.startIndex ..< index {
            
            if i == nextAttributeIndex {
                attributeIndex += 1
                font = self.text.attributes[attributeIndex].font
                nextAttributeIndex = (attributeIndex+1 == self.text.attributes.count) ? nil : self.text.attributes[attributeIndex+1].index
            }
            
            let characterValue = Int(self.text.string[i])
            let characterWidth = font.glyphs[characterValue].width
            offset += characterWidth
        }
        
        return .value(offset)
    }
}
