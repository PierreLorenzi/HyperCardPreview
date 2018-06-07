//
//  TextDrawing.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 06/06/2018.
//  Copyright © 2018 Pierre Lorenzi. All rights reserved.
//


public extension TextLayout {
    
    /// Draws the laid-out text in the given drawing
    public func draw(in drawing: Drawing, at textOrigin: Point, clipRectangle: Rectangle) {
        
        var lineIndex = 0
        
        /* Skip the lines above the clip rectangle */
        while lineIndex < self.lines.count {
            
            let line = self.lines[lineIndex]
            
            /* Compute the origin of the line */
            let lineOrigin = Point(x: textOrigin.x + line.origin.x, y: textOrigin.y + line.origin.y)
            
            /* Check if the line start being visible */
            if lineOrigin.y >= clipRectangle.top {
                break
            }
            
            lineIndex += 1
        }
        
        /* If there were invisible lines, draw the last one because it may be partially visible */
        if lineIndex > 0 {
            lineIndex -= 1
        }
        
        /* Draw the lines */
        while lineIndex < self.lines.count {
            
            let line = self.lines[lineIndex]
            
            /* Compute the origin of the line */
            let lineOrigin = Point(x: textOrigin.x + line.origin.x, y: textOrigin.y + line.origin.y)
            
            /* Draw the line */
            drawLine(layout: line, in: drawing, at: lineOrigin, clipRectangle: clipRectangle)
            
            /* If the lines start being below the clip rectangle, stop */
            if lineOrigin.y >= clipRectangle.bottom {
                break
            }
            
            lineIndex += 1
        }
    }
    
    private func drawLine(layout: LineLayout, in drawing: Drawing, at origin: Point, clipRectangle: Rectangle) {
        
        /* Initialize the state */
        var point = origin
        var characterIndex = layout.startIndex
        var attributeIndex = layout.initialAttributeIndex
        
        while characterIndex < layout.endIndex {
            
            /* Get the extent of the current run */
            let runCharacterEndIndex = (attributeIndex == self.text.attributes.count-1) ? layout.endIndex : min(layout.endIndex, self.text.attributes[attributeIndex+1].index)
            let runFont = self.text.attributes[attributeIndex].font
            let runWidth = runFont.computeSizeOfString(self.text.string, index: characterIndex, length: runCharacterEndIndex - characterIndex)
            
            drawing.drawString(self.text.string, index: characterIndex, length: runCharacterEndIndex - characterIndex, position: point, font: runFont, clip: clipRectangle)
            
            characterIndex = runCharacterEndIndex
            point.x += runWidth
            attributeIndex += 1
            
        }
        
        
    }
    
}
