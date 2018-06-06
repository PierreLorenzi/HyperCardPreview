//
//  TextLayout.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 05/06/2018.
//  Copyright © 2018 Pierre Lorenzi. All rights reserved.
//


/// The structure of a text divided in lines to be drawn on the screen.
public struct TextLayout {
    
    /// The laid-out text
    public var text: RichText
    
    /// The lines dividing the text
    public var lines: [LineLayout]
}

/// The properties of a line in a text layout
public struct LineLayout {
    
    /// The portion of text composing the line
    public var textRange: CountableRange<Int>
    
    /// The width taken by the characters of the line
    public var width: Int
    
    /// The y-coordinate of the baseline, counted from the top of the text
    public var baseLineY: Int
    
    /// The maximum ascent of the characters in the line
    public var ascent: Int
    
    /// The maximum descent of the characters in the line
    public var descent: Int
    
    /// The minimum leading of the characters in the line
    public var leading: Int
    
    /// The y-coorodinate of the bottom of the line
    public var bottom: Int
    
    /// The index of the text attribute in use at the first character of the line
    public var initialAttributeIndex: Int
}

public extension TextLayout {
    
    private static let carriageReturn = HChar(13)
    private static let space = HChar(32)
    
    /// Layouts a text within a certain width. If the width is nil, the text is not
    /// wrapped. If a non-nil line height is provided, it is given to all the lines.
    public init(text: RichText, width possibleTextWidth: Int?, lineHeight: Int?) {
        
        /* Init the lines */
        var lineLayouts: [LineLayout] = []
        
        /* State */
        var index = 0
        var attributeIndex = 0
        var layout = TextLayout.buildEmptyLayout(atIndex: index, of: text, attributeIndex: attributeIndex)
        
        /* Space break monitoring */
        var layoutAfterLastSpace: LineLayout? = nil
        var indexAfterLastSpace = 0
        var attributeIndexAfterLastSpace = 0
        
        /* Loop through the characters to find the returns */
        while index <= text.string.length {
            
            /* Check if we must break because of a return or because we have reached the end */
            if (index > 0 && text.string[index-1] == TextLayout.carriageReturn) || index == text.string.length {
                
                /* Break at the current character */
                layout.textRange = layout.textRange.lowerBound..<index
                TextLayout.finalizeLayout(&layout, lineHeight: lineHeight, content: text, previousLayout: lineLayouts.last)
                lineLayouts.append(layout)
                
                if index < text.string.length {
                    /* Stay to the same character */
                    layout = TextLayout.buildEmptyLayout(atIndex: index, of: text, attributeIndex: attributeIndex)
                    layoutAfterLastSpace = nil
                }
                else {
                    break
                }
                
            }
            
            /* Get the current character */
            let character = text.string[index]
            let width = TextLayout.computeCharacterLength(atIndex: index, of: text, attributeIndex: attributeIndex)
            
            /* Monitor spaces (we mustn't do it if we have just break at that space) */
            if character != TextLayout.space && index > 0 && text.string[index-1] == TextLayout.space && layout.textRange.lowerBound != index {
                layoutAfterLastSpace = layout
                indexAfterLastSpace = index
                attributeIndexAfterLastSpace = attributeIndex
            }
            
            /* Check if we must break because the character is going over the line */
            if let textWidth = possibleTextWidth, layout.width + width > textWidth && character != TextLayout.space && character != TextLayout.carriageReturn && index != layout.textRange.lowerBound {
                
                /* Check if we can go back to the start of the word */
                if var l = layoutAfterLastSpace {
                    
                    /* Append the layout as it was after the last space */
                    l.textRange = l.textRange.lowerBound..<indexAfterLastSpace
                    TextLayout.finalizeLayout(&l, lineHeight: lineHeight, content: text, previousLayout: lineLayouts.last)
                    lineLayouts.append(l)
                    
                    /* Move to last space */
                    index = indexAfterLastSpace
                    attributeIndex = attributeIndexAfterLastSpace
                    layout = TextLayout.buildEmptyLayout(atIndex: index, of: text, attributeIndex: attributeIndex)
                    layoutAfterLastSpace = nil
                    continue
                }
                
                /* Break at the current character */
                layout.textRange = layout.textRange.lowerBound..<index
                TextLayout.finalizeLayout(&layout, lineHeight: lineHeight, content: text, previousLayout: lineLayouts.last)
                lineLayouts.append(layout)
                
                /* Stay to the same character */
                layout = TextLayout.buildEmptyLayout(atIndex: index, of: text, attributeIndex: attributeIndex)
                layoutAfterLastSpace = nil
                continue
                
            }
            
            /* Step to the end of the character */
            if text.attributes[attributeIndex].index == index {
                let font = text.attributes[attributeIndex].font
                layout.ascent = max(layout.ascent, font.maximumAscent)
                layout.descent = max(layout.descent, font.maximumDescent)
                layout.leading = min(layout.leading, font.leading)
            }
            index += 1
            if character != TextLayout.carriageReturn {
                layout.width += width
            }
            if index != text.string.length && attributeIndex+1 < text.attributes.count && index == text.attributes[attributeIndex+1].index {
                attributeIndex += 1
            }
        }
        
        self.init(text: text, lines: lineLayouts)
    }
    
    private static func buildEmptyLayout(atIndex index: Int, of text: RichText, attributeIndex: Int) -> LineLayout {
        
        let font = text.attributes[attributeIndex].font
        
        return LineLayout(textRange: index..<(index+1),
                          width: 0,
                          baseLineY: 0,
                          ascent: font.maximumAscent,
                          descent: font.maximumDescent,
                          leading: font.leading,
                          bottom: 0,
                          initialAttributeIndex: attributeIndex)
        
    }
    
    private static func computeCharacterLength(atIndex index: Int, of content: RichText, attributeIndex: Int) -> Int {
        
        var string = HString(stringLiteral: " ")
        string[0] = content.string[index]
        
        let font = content.attributes[attributeIndex].font
        return font.computeSizeOfString(string)
        
    }
    
    private static func finalizeLayout(_ layout: inout LineLayout, lineHeight possibleLineHeight: Int?, content: RichText, previousLayout: LineLayout?) {
        
        /* Get the current height of the text */
        let textBottom: Int
        if let lastLayout = previousLayout {
            textBottom = lastLayout.bottom
        }
        else {
            textBottom = 0
        }
        
        /* Compute the vertical position of the layout */
        if let lineHeight = possibleLineHeight {
            layout.bottom = textBottom + lineHeight
            layout.baseLineY = textBottom + lineHeight - lineHeight / 4
        }
        else {
            layout.bottom = textBottom + layout.ascent + layout.descent + layout.leading
            layout.baseLineY = textBottom + layout.ascent
        }
        
        /* Trim final whitespaces */
        var lastIndex = layout.textRange.upperBound - 1
        while lastIndex >= layout.textRange.lowerBound && (content.string[lastIndex] == space || content.string[lastIndex] == carriageReturn) {
            lastIndex -= 1
        }
        layout.textRange = layout.textRange.lowerBound..<(lastIndex + 1)
        
    }
    
}
