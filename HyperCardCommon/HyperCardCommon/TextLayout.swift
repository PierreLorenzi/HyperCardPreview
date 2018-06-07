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
    
    /// The total height of the lines
    public var height: Int
}

/// A line in a laid-out text
public struct LineLayout {
    
    /// Index of the first character included in the line
    public var startIndex: Int
    
    /// Index after the last character included in the line
    public var endIndex: Int
    
    /// The text attribute in use at the first character
    public var initialAttributeIndex: Int
    
    /// The point where to draw the text, y is the baseline
    public var origin: Point
}

private let carriageReturn = HChar(13)
private let space = HChar(32)

public extension TextLayout {
    
    /// Layouts a text within a certain width. If the width is nil, the text is not
    /// wrapped. If a non-nil line height is provided, it is given to all the lines.
    public init(for text: RichText, textWidth: Int, alignment: TextAlign, dontWrap: Bool, lineHeight: Int?) {
        
        /* The algorithm doesn't handle empty texts */
        guard text.string.length > 0 else {
            self.init(text: text, lines: [], height: 0)
            return
        }
        
        /* Init the lines */
        var lineLayouts: [LineLayout] = []
        
        /* Line state */
        var state = State(endFont: text.attributes[0].font)
        
        var stateAtWordStart: State? = nil
        
        /* Loop on the characters */
        while state.endIndex <= text.string.length {
            
            /* Check if we must break because of a return or because we have reached the end */
            if (state.endIndex > 0 && text.string[state.endIndex-1] == carriageReturn) || state.endIndex == text.string.length {
                
                /* Break line */
                let newLine = state.moveToNextLine(text: text, textWidth: textWidth, alignment: alignment, dontWrap: dontWrap, lineHeight: lineHeight)
                lineLayouts.append(newLine)
                
                /* If we have finished, stop. Elsewhere, continue on the same character */
                if state.endIndex == text.string.length {
                    break
                }
            }
            
            /* Get the current character */
            let character = text.string[state.endIndex]
            let characterWidth = character == carriageReturn ? 0 : state.endFont.glyphs[Int(character)].width
            
            /* If we're going to start a word, save the current state in case we wrap here */
            if !dontWrap && character != space && state.endIndex > 0 && text.string[state.endIndex-1] == space && state.startIndex != state.endIndex {
                stateAtWordStart = state
            }
            
            /* Check if we must break because the line is too large */
            if !dontWrap, state.width + characterWidth > textWidth && character != space && character != carriageReturn && state.startIndex != state.endIndex {
                
                /* If there were spaces in the line, move to the start of the last word */
                if let wrapState = stateAtWordStart {
                    state = wrapState
                    stateAtWordStart = nil
                }
                
                /* Break line */
                let newLine = state.moveToNextLine(text: text, textWidth: textWidth, alignment: alignment, dontWrap: dontWrap, lineHeight: lineHeight)
                lineLayouts.append(newLine)
                
                continue
            }
            
            /* Step */
            let switchToNewAttribute: Bool = state.endIndex < text.string.length - 1 && state.endAttributeIndex < text.attributes.count - 1 && text.attributes[state.endAttributeIndex + 1].index == state.endIndex + 1
            let newAttribute: RichText.Attribute? = switchToNewAttribute ? text.attributes[state.endAttributeIndex + 1] : nil
            state.step(endCharacterWidth: characterWidth, newEndAttribute: newAttribute)
            
        }
        
        self.init(text: text, lines: lineLayouts, height: state.top)
    }
    
    private struct State {
        var startIndex = 0
        var startAttributeIndex = 0
        var endIndex = 0
        var endAttributeIndex = 0
        var endFont: BitmapFont
        var top = 0
        var width = 0
        var ascent = 0
        var descent = 0
        var leading = 0
        
        init(endFont: BitmapFont) {
            self.endFont = endFont
            self.ascent = self.endFont.maximumAscent
            self.descent = self.endFont.maximumDescent
            self.leading = self.endFont.leading
        }
        
        mutating func step(endCharacterWidth: Int, newEndAttribute: RichText.Attribute?) {
            self.endIndex += 1
            self.width += endCharacterWidth
            
            if let attribute = newEndAttribute {
                
                self.endAttributeIndex += 1
                self.endFont = attribute.font
                self.ascent = max(self.ascent, attribute.font.maximumAscent)
                self.descent = max(self.descent, attribute.font.maximumDescent)
                self.leading = min(self.leading, attribute.font.leading)
            }
        }
        
        mutating func moveToNextLine(text: RichText, textWidth: Int, alignment: TextAlign, dontWrap: Bool, lineHeight possibleLineHeight: Int?) -> LineLayout {
            
            /* Compute the horizontal position of the layout */
            let originX: Int
            switch alignment {
            case .left:
                originX = 0
            case .center:
                originX = textWidth/2 - self.width/2
            case .right:
                originX = textWidth - self.width
            }
            
            /* Compute the vertical position of the layout */
            let bottom: Int
            let originY: Int
            if let lineHeight = possibleLineHeight {
                bottom = self.top + lineHeight
                originY = self.top + lineHeight - lineHeight / 4
            }
            else {
                bottom = self.top + self.ascent + self.descent + self.leading
                originY = self.top + self.ascent
            }
            
            /* Do not include a trailing carriage return, and also trim all spaces to save time */
            var lineEndIndex = self.endIndex
            var lastCharacter = text.string[lineEndIndex-1]
            while lastCharacter == space || lastCharacter == carriageReturn {
                lineEndIndex -= 1
                guard lineEndIndex > self.startIndex else {
                    break
                }
                lastCharacter = text.string[lineEndIndex-1]
            }
            
            /* Buid the layout */
            let lineLayout = LineLayout(startIndex: self.startIndex, endIndex: lineEndIndex, initialAttributeIndex: self.startAttributeIndex, origin: Point(x: originX, y: originY))
            
            /* Update the state */
            self.startIndex = self.endIndex
            self.startAttributeIndex = self.endAttributeIndex
            self.top = bottom
            self.width = 0
            self.ascent = self.endFont.maximumAscent
            self.descent = self.endFont.maximumDescent
            self.leading = self.endFont.leading
            
            return lineLayout
        }
        
    }
    
}
