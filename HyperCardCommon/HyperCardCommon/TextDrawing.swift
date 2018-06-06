//
//  TextDrawing.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 06/06/2018.
//  Copyright © 2018 Pierre Lorenzi. All rights reserved.
//


public extension TextLayout {
    
    public func draw(in drawing: Drawing, at origin: Point, width: Int, alignment: TextAlign, clipRectangle: Rectangle) {
        
        for lineLayout in self.lines {
            
            /* Compute the absolute baseline */
            let baseLineY = origin.y + lineLayout.baseLineY
            
            /* Check if the lines start being visible */
            if baseLineY + lineLayout.descent <= clipRectangle.top {
                continue
            }
            
            /* Check if the lines stop being visible */
            if baseLineY - lineLayout.ascent >= clipRectangle.bottom {
                break
            }
            
            /* Draw the line */
            let lineOrigin = Point(x: origin.x, y: baseLineY)
            drawLine(layout: lineLayout, in: drawing, at: lineOrigin, width: width, alignment: alignment, clipRectangle: clipRectangle)
        }
    }
    
    private func drawLine(layout: LineLayout, in drawing: Drawing, at origin: Point, width: Int, alignment: TextAlign, clipRectangle: Rectangle) {
        
        /* Apply alignment */
        let lineX = computeLineStartX(lineWidth: layout.width, origin: origin, textWidth: width, alignment: alignment)
        var point = Point(x: lineX, y: origin.y)
        
        /* Initialize the state */
        var characterIndex = layout.textRange.lowerBound
        var attributeIndex = layout.initialAttributeIndex
        
        while characterIndex < layout.textRange.upperBound {
            
            /* Get the extent of the current run */
            let runCharacterEndIndex = (attributeIndex == self.text.attributes.count-1) ? layout.textRange.upperBound : min(layout.textRange.upperBound, self.text.attributes[attributeIndex+1].index)
            let runFont = self.text.attributes[attributeIndex].font
            let runWidth = runFont.computeSizeOfString(self.text.string, index: characterIndex, length: runCharacterEndIndex - characterIndex)
            
            drawing.drawString(self.text.string, index: characterIndex, length: runCharacterEndIndex - characterIndex, position: point, font: runFont, clip: clipRectangle)
            
            characterIndex = runCharacterEndIndex
            point.x += runWidth
            attributeIndex += 1
            
        }
        
        
    }
    
    private func computeLineStartX(lineWidth: Int, origin: Point, textWidth: Int, alignment: TextAlign) -> Int {
        
        switch alignment {
        case .left:
            return origin.x
        case .center:
            return origin.x + textWidth/2 - lineWidth/2
        case .right:
            return origin.x + textWidth - lineWidth
        }
        
    }
    
}
