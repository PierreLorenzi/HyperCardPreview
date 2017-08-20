//
//  RegularFieldView.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 03/03/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


private let FieldShadowShift = 3
private let FieldShadowThickness = 2

private let carriageReturn = HChar(13)
private let space = HChar(32)

private let FieldLineComposition: ImageComposition = { (a: inout UInt32, b: UInt32, integerIndex: Int, y: Int) in
    
    let gray = Grays[0]
    let inverseGray = Grays[1]
    a |= (b & gray)
    a &= ~(b & inverseGray)
    
}

private let ScrollWidth = 17
private let ScrollButtonHeight = 15
private let ScrollKnobHeight = 16

private let ScrollUpButtonImage = MaskedImage(named: "scroll up arrow")!
private let ScrollDownButtonImage = MaskedImage(named: "scroll down arrow")!

private let ScrollPatternImage = Image(named: "scroll pattern")!

private struct LineLayout {
    var textRange: CountableRange<Int>
    var width: Int
    var baseLineY: Int
    var ascent: Int
    var descent: Int
    var leading: Int
    var bottom: Int
    var initialAttributeIndex: Int
}



/// A view of a field
public class FieldView: View {
    
    /// The visual style of the view
    public var style: PartStyle         = .transparent { didSet { needsLayout = true }}
    
    /// The content text
    public var content: RichText        = RichText() { didSet { needsLayout = true }}
    
    /// The 2D position of the view
    public var rectangle: Rectangle     = Rectangle(top: 0, left: 0, bottom: 0, right: 0) { didSet { needsLayout = true }}
    
    /// Whether or not the lines all have the same height
    public var fixedLineHeight: Bool    = false { didSet { needsLayout = true }}
    
    /// Whether or not the text wraps to the next line when it reaches the right of the field
    public var dontWrap: Bool           = false { didSet { needsLayout = true }}
    
    /// If set, the margins are wider, which make a more readable text
    public var wideMargins: Bool        = false { didSet { needsLayout = true }}
    
    /// Whether or not the text lines are marked with gray lines
    public var showLines: Bool          = false
    
    /// Whether or not the view is visible
    public var visible: Bool            = true
    
    /// The alignment of the text
    public var alignment: TextAlign      = .left
    
    /// The height of the lines, if it is fixed
    public var textHeight: Int          = 16 { didSet { needsLayout = true }}
    
    /// The scroll shift, in pixels. Only used in scrolling fields.
    public var scroll: Int              = 0
    
    private var needsLayout: Bool      = false
    private var lineLayouts: [LineLayout] = []
    private var contentRectangle: Rectangle = Rectangle(top: 0, left: 0, bottom: 0, right: 0)
    private var textRectangle: Rectangle = Rectangle(top: 0, left: 0, bottom: 0, right: 0)
    
    public override init() {}
    
    public override func draw(in drawing: Drawing) {
        
        guard visible else {
            return
        }
        
        layoutIfNeeded()
        
        /* Draw the frame */
        drawFieldFrame(drawing: drawing)
        
        /* Draw the text */
        drawText(in: drawing)
        
    }
    
    private func computeContentRectangle() -> Rectangle {
        
        let baseRectangle = Rectangle(top: rectangle.top + 1,
                  left: rectangle.left + 1,
                  bottom: rectangle.bottom - 1,
                  right: rectangle.right - 1)
        
        switch style {
            
        case .shadow:
            return Rectangle(top: baseRectangle.top,
                             left: baseRectangle.left,
                             bottom: baseRectangle.bottom  - FieldShadowThickness,
                             right: baseRectangle.right - FieldShadowThickness)
            
        case .scrolling:
            return Rectangle(top: baseRectangle.top,
                             left: baseRectangle.left,
                             bottom: baseRectangle.bottom,
                             right: baseRectangle.right - ScrollWidth + 1)
            
        default:
            return baseRectangle
            
        }
        
    }
    
    private func computeTextRectangle() -> Rectangle {
        
        let contentRectangle = self.contentRectangle
        
        /* Compute margins */
        return Rectangle(top: contentRectangle.top + (wideMargins ? 4 : 0),
                         left: contentRectangle.left + 3 + (wideMargins ? 5 : 0),
                         bottom: contentRectangle.bottom,
                         right: contentRectangle.right - 3 - (wideMargins ? 3 : 0)
        )
    }
    
    private func drawFieldFrame(drawing: Drawing) {
        
        switch style {
            
        case .opaque:
            drawing.drawRectangle(rectangle, composition: Drawing.MaskComposition)
            
        case .rectangle:
            drawing.drawBorderedRectangle(rectangle)
            
        case .shadow:
            drawing.drawShadowedRectangle(rectangle, thickness: FieldShadowThickness, shift: FieldShadowShift)
            
        case .scrolling:
            self.drawScrollFrame(in: drawing)
            
            /* Draw active scroll if necessary */
            let lastLineLayout = lineLayouts[lineLayouts.count-1]
            let contentHeight = rectangle.height - 2
            let totalTextHeight = lastLineLayout.baseLineY + lastLineLayout.descent
            if totalTextHeight > contentHeight {
                let scrollFactor: Double = Double(scroll) / Double(totalTextHeight - contentHeight)
                drawActiveScroll(in: drawing, scrollFactor: scrollFactor)
            }
            
        default:
            break
            
        }
        
    }
    
    private func drawScrollFrame(in drawing: Drawing) {
        
        /* Draw the main border */
        drawing.drawBorderedRectangle(rectangle)
        
        /* Draw the scroll borders */
        
        /* Left scroll border */
        drawing.drawRectangle(Rectangle(x: rectangle.right - ScrollWidth, y: rectangle.top, width: 1, height: rectangle.height))
        
        /* Up scroll border */
        drawing.drawRectangle(Rectangle(x: rectangle.right - ScrollWidth, y: rectangle.top + ScrollButtonHeight, width: ScrollWidth, height: 1))
        
        /* Down scroll border */
        drawing.drawRectangle(Rectangle(x: rectangle.right - ScrollWidth, y: rectangle.bottom - ScrollButtonHeight - 1, width: ScrollWidth, height: 1))
        
        /* Draw the arrow buttons */
        guard rectangle.height > 2 * ScrollButtonHeight else {
            return
        }
        
        /* Up arrow */
        drawing.drawMaskedImage(ScrollUpButtonImage, position: Point(x: rectangle.right - ScrollWidth + 1, y: rectangle.top + 1))
        
        /* Down arrow */
        drawing.drawMaskedImage(ScrollDownButtonImage, position: Point(x: rectangle.right - ScrollWidth + 1, y: rectangle.bottom - ScrollButtonHeight))
        
    }
    
    private func drawActiveScroll(in drawing: Drawing, scrollFactor: Double) {
        
        /* Draw the background */
        let backgroundRectangle = Rectangle(top: rectangle.top + ScrollButtonHeight + 1, left: rectangle.right - ScrollWidth + 1, bottom: rectangle.bottom - ScrollButtonHeight - 1, right: rectangle.right - 1)
        drawing.drawPattern(ScrollPatternImage, rectangle: backgroundRectangle, offset: Point(x: -(backgroundRectangle.x % 2), y: 0))
        
        /* Draw the knob */
        if backgroundRectangle.height >= ScrollKnobHeight {
            let scrollRange = backgroundRectangle.height - ScrollKnobHeight
            let knobOffset = Int(scrollFactor * Double(scrollRange))
            drawing.drawBorderedRectangle(Rectangle(x: backgroundRectangle.x, y: backgroundRectangle.y + knobOffset, width: backgroundRectangle.width, height: ScrollKnobHeight))
        }
        
    }
    
    private func layoutIfNeeded() {
        
        if !needsLayout {
            return
        }
        needsLayout = false
        
        /* Compute the layout rectangles */
        contentRectangle = computeContentRectangle()
        textRectangle = computeTextRectangle()
        
        /* Init the lines */
        lineLayouts = []
        
        /* State */
        var index = 0
        var attributeIndex = 0
        var layout = buildEmptyLayout(atIndex: index, attributeIndex: attributeIndex)
        
        /* Space break monitoring */
        var layoutAfterLastSpace: LineLayout? = nil
        var indexAfterLastSpace = 0
        var attributeIndexAfterLastSpace = 0
        
        /* Loop through the characters to find the returns */
        while index <= content.string.length {
            
            /* Check if we must break because of a return or because we have reached the end */
            if (index > 0 && content.string[index-1] == carriageReturn) || index == content.string.length {
                
                /* Break at the current character */
                layout.textRange = layout.textRange.lowerBound..<index
                finalizeLayout(&layout)
                lineLayouts.append(layout)
                
                if index < content.string.length {
                    /* Stay to the same character */
                    layout = buildEmptyLayout(atIndex: index, attributeIndex: attributeIndex)
                    layoutAfterLastSpace = nil
                }
                else {
                    break
                }
                
            }
            
            /* Get the current character */
            let character = content.string[index]
            let width = computeCharacterLength(atIndex: index, attributeIndex: attributeIndex)
            
            /* Monitor spaces (we mustn't do it if we have just break at that space) */
            if character != space && index > 0 && content.string[index-1] == space && layout.textRange.lowerBound != index {
                layoutAfterLastSpace = layout
                indexAfterLastSpace = index
                attributeIndexAfterLastSpace = attributeIndex
            }
            
            /* Check if we must break because the character is going over the line */
            if !dontWrap && layout.width + width > textRectangle.width && character != space && character != carriageReturn && index != layout.textRange.lowerBound {
                
                /* Check if we can go back to the start of the word */
                if var l = layoutAfterLastSpace {
                    
                    /* Append the layout as it was after the last space */
                    l.textRange = l.textRange.lowerBound..<indexAfterLastSpace
                    finalizeLayout(&l)
                    lineLayouts.append(l)
                    
                    /* Move to last space */
                    index = indexAfterLastSpace
                    attributeIndex = attributeIndexAfterLastSpace
                    layout = buildEmptyLayout(atIndex: index, attributeIndex: attributeIndex)
                    layoutAfterLastSpace = nil
                    continue
                }
                
                /* Break at the current character */
                layout.textRange = layout.textRange.lowerBound..<index
                finalizeLayout(&layout)
                lineLayouts.append(layout)
                
                /* Stay to the same character */
                layout = buildEmptyLayout(atIndex: index, attributeIndex: attributeIndex)
                layoutAfterLastSpace = nil
                continue
                
            }
            
            /* Step to the end of the character */
            if content.attributes[attributeIndex].index == index {
                let font = content.attributes[attributeIndex].font
                layout.ascent = max(layout.ascent, font.maximumAscent)
                layout.descent = max(layout.descent, font.maximumDescent)
                layout.leading = min(layout.leading, font.leading)
            }
            index += 1
            if character != carriageReturn {
                layout.width += width
            }
            if index != content.string.length && attributeIndex+1 < content.attributes.count && index == content.attributes[attributeIndex+1].index {
                attributeIndex += 1
            }
        }
    }
    
    private func buildEmptyLayout(atIndex index: Int, attributeIndex: Int) -> LineLayout {
        
        let font = content.attributes[attributeIndex].font
        
        return LineLayout(textRange: index..<(index+1),
                                       width: 0,
                                       baseLineY: 0,
                                       ascent: font.maximumAscent,
                                       descent: font.maximumDescent,
                                       leading: font.leading,
                                       bottom: 0,
                                       initialAttributeIndex: attributeIndex)
        
    }
    
    private func computeCharacterLength(atIndex index: Int, attributeIndex: Int) -> Int {
    
        var string = HString(stringLiteral: " ")
        string[0] = content.string[index]
        
        let font = content.attributes[attributeIndex].font
        return font.computeSizeOfString(string)
    
    }
    
    private func finalizeLayout(_ layout: inout LineLayout) {
        
        /* Get the current height of the text */
        let textBottom: Int
        if let lastLayout = lineLayouts.last {
            textBottom = lastLayout.bottom
        }
        else {
            textBottom = 0
        }
        
        /* Compute the vertical position of the layout */
        if fixedLineHeight {
            layout.bottom = textBottom + textHeight
            layout.baseLineY = textBottom + textHeight - (layout.leading + layout.descent) * textHeight / (layout.ascent + layout.descent + layout.leading)
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
    
    private func drawText(in drawing: Drawing) {
        
        if textRectangle.width == 0 || textRectangle.height == 0  {
            return
        }
        
        var baseLineY = 0
        var descent = 0
        var ascent = 0
        
        var lineIndex = 0
        
        while true {
            
            if lineIndex < lineLayouts.count {
                let layout = lineLayouts[lineIndex]
                baseLineY = textRectangle.top + layout.baseLineY - scroll
                ascent = layout.ascent
                descent = showLines ? max(layout.descent, 2) : layout.descent
            }
            else if showLines {
                baseLineY += textHeight
                descent = 2
                ascent = 0
            }
            else {
                break
            }
            
            /* Check if the lines start being visible */
            if baseLineY + descent <= contentRectangle.top {
                continue
            }
            
            /* Check if the lines stop being visible */
            if baseLineY - ascent >= contentRectangle.bottom {
                break
            }
            
            /* Draw the line */
            if showLines {
                drawing.drawRectangle(Rectangle(top: baseLineY + 1, left: contentRectangle.left, bottom: baseLineY+2, right: contentRectangle.right), clipRectangle: contentRectangle, composition: FieldLineComposition)
            }
            
            /* Draw the line */
            if lineIndex < lineLayouts.count {
                drawLine(atIndex: lineIndex, atLineBaseY: baseLineY, in: drawing)
                lineIndex += 1
            }
            
        }
        
    }
    
    private func drawLine(atIndex lineIndex: Int, atLineBaseY lineY: Int, in drawing: Drawing) {
        
        /* Get the layout for that line */
        let layout = lineLayouts[lineIndex]
        
        /* Apply alignment */
        let lineX = computeLineStartX(lineWidth: layout.width)
        var point = Point(x: lineX, y: lineY)
        
        /* Initialize the state */
        var characterIndex = layout.textRange.lowerBound
        var attributeIndex = layout.initialAttributeIndex
        
        while characterIndex < layout.textRange.upperBound {
            
            /* Get the extent of the current run */
            let runCharacterEndIndex = (attributeIndex == content.attributes.count-1) ? layout.textRange.upperBound : min(layout.textRange.upperBound,content.attributes[attributeIndex+1].index)
            let runString = content.string[characterIndex..<runCharacterEndIndex]
            let runFont = content.attributes[attributeIndex].font
            let runWidth = runFont.computeSizeOfString(runString)
            
            drawing.drawString(runString, position: point, font: runFont, clip: contentRectangle)
            
            characterIndex = runCharacterEndIndex
            point.x += runWidth
            attributeIndex += 1
            
        }
        
        
    }
    
    private func computeLineStartX(lineWidth: Int) -> Int {
        
        switch alignment {
        case .left:
            return textRectangle.left
        case .center:
            return textRectangle.left + textRectangle.width/2 - lineWidth/2
        case .right:
            return textRectangle.right - lineWidth
        }
        
    }
    
}
