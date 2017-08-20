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



public class FieldView: View {
    
    private let field: Field
    
    private var richText: RichText {
        get { return self.richTextProperty.value }
    }
    private let richTextProperty: Property<RichText>
    
    private var lineLayouts: [LineLayout] {
        get { return self.lineLayoutsProperty.value }
    }
    private let lineLayoutsProperty: Property<[LineLayout]>
    
    public init(field: Field, contentProperty: Property<PartContent>, fontManager: FontManager) {
        
        self.field = field
        
        /* rich text */
        self.richTextProperty = Property<RichText>(compute: {
            return FieldView.buildRichText(from: contentProperty.value, withDefaultFontIdentifier: field.textFontIdentifier, defaultSize: field.textFontSize, defaultStyle: field.textStyle, fontManager: fontManager)
        })
        
        /* line layouts */
        let richTextProperty = self.richTextProperty
        self.lineLayoutsProperty = Property<[LineLayout]>(compute: {
            return FieldView.layout(field: field, content: richTextProperty.value)
        })
        
        super.init()
        
        /* Listen to content change */
        contentProperty.startNotifications(for: self, by: {
            self.richTextProperty.invalidate()
        })
        
    }
    
    private static func buildRichText(from content: PartContent, withDefaultFontIdentifier defaultIdentifier: Int, defaultSize: Int, defaultStyle: TextStyle, fontManager: FontManager) -> RichText {
        
        switch content {
        case .string(let string):
            let font = fontManager.findFont(withIdentifier: defaultIdentifier, size: defaultSize, style: defaultStyle)
            return RichText(string: string, attributes: [RichText.Attribute(index: 0, font: font)])
            
        case .formattedString(let text):
            let attributes = text.attributes.map({
                (f: Text.FormattingAssociation) -> RichText.Attribute in
                let identifier = f.formatting.fontFamilyIdentifier ?? defaultIdentifier
                let size = f.formatting.size ?? defaultSize
                let style = f.formatting.style ?? defaultStyle
                let font = fontManager.findFont(withIdentifier: identifier, size: size, style: style)
                return RichText.Attribute(index: f.offset, font: font)
            })
            return RichText(string: text.string, attributes: attributes)
        }
        
    }
    
    private static func layout(field: Field, content: RichText) -> [LineLayout] {
        
        /* Init the lines */
        var lineLayouts: [LineLayout] = []
        
        /* Compute the layout rectangles */
        let textRectangle = FieldView.computeTextRectangle(of: field)
        
        /* State */
        var index = 0
        var attributeIndex = 0
        var layout = buildEmptyLayout(atIndex: index, of: content, attributeIndex: attributeIndex)
        
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
                finalizeLayout(&layout, field: field, content: content, previousLayout: lineLayouts.last)
                lineLayouts.append(layout)
                
                if index < content.string.length {
                    /* Stay to the same character */
                    layout = buildEmptyLayout(atIndex: index, of: content, attributeIndex: attributeIndex)
                    layoutAfterLastSpace = nil
                }
                else {
                    break
                }
                
            }
            
            /* Get the current character */
            let character = content.string[index]
            let width = computeCharacterLength(atIndex: index, of: content, attributeIndex: attributeIndex)
            
            /* Monitor spaces (we mustn't do it if we have just break at that space) */
            if character != space && index > 0 && content.string[index-1] == space && layout.textRange.lowerBound != index {
                layoutAfterLastSpace = layout
                indexAfterLastSpace = index
                attributeIndexAfterLastSpace = attributeIndex
            }
            
            /* Check if we must break because the character is going over the line */
            if !field.dontWrap && layout.width + width > textRectangle.width && character != space && character != carriageReturn && index != layout.textRange.lowerBound {
                
                /* Check if we can go back to the start of the word */
                if var l = layoutAfterLastSpace {
                    
                    /* Append the layout as it was after the last space */
                    l.textRange = l.textRange.lowerBound..<indexAfterLastSpace
                    finalizeLayout(&l, field: field, content: content, previousLayout: lineLayouts.last)
                    lineLayouts.append(l)
                    
                    /* Move to last space */
                    index = indexAfterLastSpace
                    attributeIndex = attributeIndexAfterLastSpace
                    layout = buildEmptyLayout(atIndex: index, of: content, attributeIndex: attributeIndex)
                    layoutAfterLastSpace = nil
                    continue
                }
                
                /* Break at the current character */
                layout.textRange = layout.textRange.lowerBound..<index
                finalizeLayout(&layout, field: field, content: content, previousLayout: lineLayouts.last)
                lineLayouts.append(layout)
                
                /* Stay to the same character */
                layout = buildEmptyLayout(atIndex: index, of: content, attributeIndex: attributeIndex)
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
        
        return lineLayouts
    }
    
    private static func computeContentRectangle(of field: Field) -> Rectangle {
        
        let baseRectangle = Rectangle(top: field.rectangle.top + 1,
                                      left: field.rectangle.left + 1,
                                      bottom: field.rectangle.bottom - 1,
                                      right: field.rectangle.right - 1)
        
        switch field.style {
            
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
    
    private static func computeTextRectangle(of field: Field) -> Rectangle {
        
        let contentRectangle = FieldView.computeContentRectangle(of: field)
        
        /* Compute margins */
        return Rectangle(top: contentRectangle.top + (field.wideMargins ? 4 : 0),
                         left: contentRectangle.left + 3 + (field.wideMargins ? 5 : 0),
                         bottom: contentRectangle.bottom,
                         right: contentRectangle.right - 3 - (field.wideMargins ? 3 : 0)
        )
    }
    
    private static func buildEmptyLayout(atIndex index: Int, of content: RichText, attributeIndex: Int) -> LineLayout {
        
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
    
    private static func computeCharacterLength(atIndex index: Int, of content: RichText, attributeIndex: Int) -> Int {
        
        var string = HString(stringLiteral: " ")
        string[0] = content.string[index]
        
        let font = content.attributes[attributeIndex].font
        return font.computeSizeOfString(string)
        
    }
    
    private static func finalizeLayout(_ layout: inout LineLayout, field: Field, content: RichText, previousLayout: LineLayout?) {
        
        /* Get the current height of the text */
        let textBottom: Int
        if let lastLayout = previousLayout {
            textBottom = lastLayout.bottom
        }
        else {
            textBottom = 0
        }
        
        /* Compute the vertical position of the layout */
        if field.fixedLineHeight {
            layout.bottom = textBottom + field.textHeight
            layout.baseLineY = textBottom + field.textHeight - (layout.leading + layout.descent) * field.textHeight / (layout.ascent + layout.descent + layout.leading)
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
    
    override public func draw(in drawing: Drawing) {
        
        guard field.visible else {
            return
        }
        
        /* Get the visual properties as they are now */
        let richText = self.richText
        let lineLayouts = self.lineLayouts
        
        /* Draw the frame */
        drawFieldFrame(in: drawing, lineLayouts: lineLayouts)
        
        /* Draw the text */
        drawText(in: drawing, content: richText, lineLayouts: lineLayouts)
        
    }
    
    private func drawFieldFrame(in drawing: Drawing, lineLayouts: [LineLayout]) {
        
        switch field.style {
            
        case .opaque:
            drawing.drawRectangle(field.rectangle, composition: Drawing.MaskComposition)
            
        case .rectangle:
            drawing.drawBorderedRectangle(field.rectangle)
            
        case .shadow:
            drawing.drawShadowedRectangle(field.rectangle, thickness: FieldShadowThickness, shift: FieldShadowShift)
            
        case .scrolling:
            FieldView.drawScrollFrame(in: drawing, rectangle: field.rectangle)
            
            /* Draw active scroll if necessary */
            let lastLineLayout = lineLayouts[lineLayouts.count-1]
            let contentHeight = field.rectangle.height - 2
            let totalTextHeight = lastLineLayout.baseLineY + lastLineLayout.descent
            if totalTextHeight > contentHeight {
                let scrollFactor: Double = Double(field.scroll) / Double(totalTextHeight - contentHeight)
                FieldView.drawActiveScroll(in: drawing, rectangle: field.rectangle, scrollFactor: scrollFactor)
            }
            
        default:
            break
            
        }
        
    }
    
    private static func drawScrollFrame(in drawing: Drawing, rectangle: Rectangle) {
        
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
    
    private static func drawActiveScroll(in drawing: Drawing, rectangle: Rectangle, scrollFactor: Double) {
        
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
    
    private func drawText(in drawing: Drawing, content: RichText, lineLayouts: [LineLayout]) {
        
        let textRectangle = FieldView.computeTextRectangle(of: field)
        let contentRectangle = FieldView.computeContentRectangle(of: field)
        
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
                baseLineY = textRectangle.top + layout.baseLineY - field.scroll
                ascent = layout.ascent
                descent = field.showLines ? max(layout.descent, 2) : layout.descent
            }
            else if field.showLines {
                baseLineY += field.textHeight
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
            if field.showLines {
                drawing.drawRectangle(Rectangle(top: baseLineY + 1, left: contentRectangle.left, bottom: baseLineY+2, right: contentRectangle.right), clipRectangle: contentRectangle, composition: FieldLineComposition)
            }
            
            /* Draw the line */
            if lineIndex < lineLayouts.count {
                drawLine(atIndex: lineIndex, atLineBaseY: baseLineY, in: drawing, lineLayouts: lineLayouts, contentRectangle: contentRectangle, textRectangle: textRectangle, content: content)
                lineIndex += 1
            }
            
        }
        
    }
    
    private func drawLine(atIndex lineIndex: Int, atLineBaseY lineY: Int, in drawing: Drawing, lineLayouts: [LineLayout], contentRectangle: Rectangle, textRectangle: Rectangle, content: RichText) {
        
        /* Get the layout for that line */
        let layout = lineLayouts[lineIndex]
        
        /* Apply alignment */
        let lineX = computeLineStartX(lineWidth: layout.width, textRectangle: textRectangle)
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
    
    private func computeLineStartX(lineWidth: Int, textRectangle: Rectangle) -> Int {
        
        switch field.textAlign {
        case .left:
            return textRectangle.left
        case .center:
            return textRectangle.left + textRectangle.width/2 - lineWidth/2
        case .right:
            return textRectangle.right - lineWidth
        }
        
    }
    
}



