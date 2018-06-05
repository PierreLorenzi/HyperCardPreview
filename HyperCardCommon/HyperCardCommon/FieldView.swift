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

private let FieldLineComposition: ImageComposition = { (a: inout Image.Integer, b: Image.Integer, integerIndex: Int, y: Int) in
    
    let gray = Grays[0]
    let inverseGray = Grays[1]
    a |= (b & gray)
    a &= ~(b & inverseGray)
    
}

private let ScrollWidth = 17
private let ScrollButtonHeight = 16
private let ScrollKnobHeight = 16

private let ScrollUpButtonImage = MaskedImage(named: "scroll up arrow")!
private let ScrollDownButtonImage = MaskedImage(named: "scroll down arrow")!

private let ScrollUpButtonClickedImage = MaskedImage(named: "scroll up arrow clicked")!
private let ScrollDownButtonClickedImage = MaskedImage(named: "scroll down arrow clicked")!

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



public class FieldView: View, MouseResponder {
    
    private let field: Field
    
    private var richText: RichText {
        get { return self.richTextComputation.value }
    }
    private let richTextComputation: Computation<RichText>
    
    private var lineLayouts: [LineLayout] {
        get { return self.lineLayoutsComputation.value }
    }
    private let lineLayoutsComputation: Computation<[LineLayout]>
    
    private var isUpArrowClicked: Bool {
        get { return self.isUpArrowClickedProperty.value }
        set { self.isUpArrowClickedProperty.value = newValue }
    }
    private var isUpArrowClickedProperty = Property<Bool>(false)
    
    private var isDownArrowClicked: Bool {
        get { return self.isDownArrowClickedProperty.value }
        set { self.isDownArrowClickedProperty.value = newValue }
    }
    private var isDownArrowClickedProperty = Property<Bool>(false)
    
    private var ghostKnobOffset: Int? {
        get { return self.ghostKnobOffsetProperty.value }
        set { self.ghostKnobOffsetProperty.value = newValue }
    }
    private var ghostKnobOffsetProperty = Property<Int?>(nil)
    
    /// The timer sending scroll updates while the user is clicking on an scroll arrow
    private var scrollingTimer: Timer? = nil
    
    public init(field: Field, contentComputation: Computation<PartContent>, fontManager: FontManager) {
        
        self.field = field
        
        /* rich text */
        self.richTextComputation = Computation<RichText> {
            return FieldView.buildRichText(from: contentComputation.value, withDefaultFontIdentifier: field.textFontIdentifier, defaultSize: field.textFontSize, defaultStyle: field.textStyle, fontManager: fontManager)
        }
        
        /* line layouts */
        let richTextComputation = self.richTextComputation
        self.lineLayoutsComputation = Computation<[LineLayout]> {
            return FieldView.layout(field: field, content: richTextComputation.value)
        }
        
        super.init()
        
        /* Listen to content change */
        richTextComputation.dependsOn(contentComputation, at: \Computation.valueProperty)
        lineLayoutsComputation.dependsOn(richTextComputation, at: \Computation.valueProperty)
        
        /* Listen to visual changes */
        field.scrollProperty.startNotifications(for: self, by: {
            [unowned self] in if self.field.style == .scrolling { self.refreshNeedProperty.value = .refresh }
        })
        richTextComputation.valueProperty.startNotifications(for: self, by: {
            [unowned self] in self.refreshNeedProperty.value = (self.field.style == .transparent) ? .refreshWithNewShape : .refresh
        })
        isUpArrowClickedProperty.startNotifications(for: self, by: {
            [unowned self] in self.refreshNeedProperty.value = .refresh
        })
        isDownArrowClickedProperty.startNotifications(for: self, by: {
            [unowned self] in self.refreshNeedProperty.value = .refresh
        })
        ghostKnobOffsetProperty.startNotifications(for: self, by: {
            [unowned self] in self.refreshNeedProperty.value = .refresh
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
            FieldView.drawScrollFrame(in: drawing, rectangle: field.rectangle, isUpArrowClicked: self.isUpArrowClicked, isDownArrowClicked: self.isDownArrowClicked)
            
            /* Draw active scroll if necessary */
            let scrollRange = self.scrollRange
            if scrollRange > 0 {
                FieldView.drawActiveScroll(in: drawing, rectangle: field.rectangle, scroll: field.scroll, scrollRange: scrollRange, ghostKnobOffset: self.ghostKnobOffset)
            }
            
        default:
            break
            
        }
        
    }
    
    private var scrollRange: Int {
        
        let textRectangle = FieldView.computeTextRectangle(of: field)
        
        let lastLineLayout = lineLayouts[lineLayouts.count-1]
        let contentHeight = field.rectangle.height - 2
        let totalTextHeight = textRectangle.top - field.rectangle.top + lastLineLayout.bottom
        
        return max(0, totalTextHeight - contentHeight)
        
    }
    
    private static func drawScrollFrame(in drawing: Drawing, rectangle: Rectangle, isUpArrowClicked: Bool, isDownArrowClicked: Bool) {
        
        /* Draw the main border */
        drawing.drawBorderedRectangle(rectangle)
        
        /* Draw the scroll borders */
        
        /* Left scroll border */
        drawing.drawRectangle(Rectangle(x: rectangle.right - ScrollWidth, y: rectangle.top, width: 1, height: rectangle.height))
        
        /* Don't draw the arrows if the field is too short (minus one because it is until the borders merge) */
        guard rectangle.height >= 2 * ScrollButtonHeight - 1 else {
            return
        }
        
        /* Up arrow scroll border */
        drawing.drawRectangle(Rectangle(x: rectangle.right - ScrollWidth, y: rectangle.top + ScrollButtonHeight - 1, width: ScrollWidth, height: 1))
        
        /* Down arrow scroll border */
        drawing.drawRectangle(Rectangle(x: rectangle.right - ScrollWidth, y: rectangle.bottom - ScrollButtonHeight, width: ScrollWidth, height: 1))
        
        /* Up arrow icon (draw inside the borders of the button) */
        let upArrowRectangle = computeUpArrowPosition(inFieldWithRectangle: rectangle)
        let upArrowImage = isUpArrowClicked ? ScrollUpButtonClickedImage : ScrollUpButtonImage
        drawing.drawMaskedImage(upArrowImage, position: Point(x: upArrowRectangle.x + 1, y: upArrowRectangle.y + 1))
        
        /* Down arrow icon (draw inside the borders of the button) */
        let downArrowRectangle = computeDownArrowPosition(inFieldWithRectangle: rectangle)
        let downArrowImage = isDownArrowClicked ? ScrollDownButtonClickedImage : ScrollDownButtonImage
        drawing.drawMaskedImage(downArrowImage, position: Point(x: downArrowRectangle.x + 1, y: downArrowRectangle.y + 1))
        
    }
    
    private static func computeUpArrowPosition(inFieldWithRectangle rectangle: Rectangle) -> Rectangle {
        
        /* If the field is too short to draw the arrows, it can still be clicked */
        guard rectangle.height >= 2 * ScrollButtonHeight else {
            return Rectangle(x: rectangle.right - ScrollWidth, y: rectangle.top, width: ScrollWidth, height: (rectangle.height + 1) / 2)
        }
        
        return Rectangle(x: rectangle.right - ScrollWidth, y: rectangle.top, width: ScrollWidth, height: ScrollButtonHeight)
    }
    
    private static func computeDownArrowPosition(inFieldWithRectangle rectangle: Rectangle) -> Rectangle {
        
        /* If the field is too short to draw the arrows, it can still be clicked */
        guard rectangle.height >= 2 * ScrollButtonHeight else {
            return Rectangle(x: rectangle.right - ScrollWidth, y: rectangle.bottom - ScrollButtonHeight, width: ScrollWidth, height: rectangle.height / 2)
        }
        
        return Rectangle(x: rectangle.right - ScrollWidth, y: rectangle.bottom - ScrollButtonHeight, width: ScrollWidth, height: ScrollButtonHeight)
    }
    
    private static func drawActiveScroll(in drawing: Drawing, rectangle: Rectangle, scroll: Int, scrollRange: Int, ghostKnobOffset: Int?) {
        
        /* Check if there is a background */
        let scrollBarRectangle = computeScrollBarRectangle(forRectangle: rectangle)
        guard scrollBarRectangle.height > 0 else {
            return
        }
        
        /* Draw the background */
        drawing.drawPattern(ScrollPatternImage, rectangle: scrollBarRectangle, offset: Point(x: -(scrollBarRectangle.x % 2), y: 0))
        
        /* Draw the knob */
        if let knobRectangle = computeKnobRectangle(forScrollBarRectangle: scrollBarRectangle, scroll: scroll, scrollRange: scrollRange) {
            drawing.drawBorderedRectangle(knobRectangle)
        }
        
        /* Draw the ghost knob if it exists */
        if let offset = ghostKnobOffset {
            let ghostKnobRectangle = Rectangle(x: scrollBarRectangle.left, y: scrollBarRectangle.top + offset, width: scrollBarRectangle.width, height: ScrollKnobHeight)
            drawing.drawBorderedRectangle(ghostKnobRectangle, composition: Drawing.NoComposition, borderComposition: Drawing.XorComposition)
        }
        
    }
    
    private static func computeScrollBarRectangle(forRectangle rectangle: Rectangle) -> Rectangle {
        
        return Rectangle(top: rectangle.top + ScrollButtonHeight, left: rectangle.right - ScrollWidth + 1, bottom: rectangle.bottom - ScrollButtonHeight, right: rectangle.right - 1)
    }
    
    private static func computeKnobRectangle(forScrollBarRectangle scrollBarRectangle: Rectangle, scroll: Int, scrollRange: Int) -> Rectangle? {
        
        /* If the knob doesn't fit in the scoll bar, it is not drawn */
        guard scrollBarRectangle.height >= ScrollKnobHeight else {
            return nil
        }
        
        /* Compute the position of the knob */
        let knobRange = scrollBarRectangle.height - ScrollKnobHeight
        let knobOffset = knobRange * scroll / scrollRange
        return Rectangle(x: scrollBarRectangle.x, y: scrollBarRectangle.y + knobOffset, width: scrollBarRectangle.width, height: ScrollKnobHeight)
    }
    
    private func drawText(in drawing: Drawing, content: RichText, lineLayouts: [LineLayout]) {
        
        let textRectangle = FieldView.computeTextRectangle(of: field)
        let contentRectangle = FieldView.computeContentRectangle(of: field)
        let showLines = field.showLines && field.style != .scrolling
        
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
                descent = showLines ? max(layout.descent, 2) : layout.descent
            }
            else if showLines {
                baseLineY += field.textHeight
                descent = 2
                ascent = 0
            }
            else {
                break
            }
            
            /* Check if the lines start being visible */
            if baseLineY + descent <= contentRectangle.top {
                lineIndex += 1
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
            let runFont = content.attributes[attributeIndex].font
            let runWidth = runFont.computeSizeOfString(content.string, index: characterIndex, length: runCharacterEndIndex - characterIndex)
            
            drawing.drawString(content.string, index: characterIndex, length: runCharacterEndIndex - characterIndex, position: point, font: runFont, clip: contentRectangle)
            
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
    
    public override var rectangle: Rectangle? {
        
        /* If the view is invisible, do not reserve a rectangle */
        guard field.visible else {
            return nil
        }
        
        return field.rectangle
    }
    
    public func doesRespondToMouseEvent(at position: Point) -> Bool {
        
        guard field.visible else {
            return false
        }
        
        return field.rectangle.containsPosition(position)
    }
    
    public func respondToMouseEvent(_ mouseEvent: MouseEvent, at position: Point) {
        
        switch mouseEvent {
            
        case .verticalScroll(delta: let delta):
            self.respondToScroll(at: position, delta: delta)
            
        case .mouseDown:
            self.respondToMouseDown(at: position)
            
        case .mouseUp:
            self.respondToMouseUp(at: position)
        }
    }
    
    private func respondToScroll(at position: Point, delta: Double) {
        
        /* Only for scroll fields */
        guard field.style == .scrolling else {
            return
        }
        
        /* The field must have an active scroll */
        let scrollRange = self.scrollRange
        guard scrollRange > 0 else {
            return
        }
        
        /* Apply the delta */
        var newScroll = field.scroll - Int(delta)
        newScroll = max(0, newScroll)
        newScroll = min(scrollRange, newScroll)
        
        field.scroll = newScroll
        
    }
    
    private func respondToMouseDown(at position: Point) {
        
        /* The field must be scrolling */
        guard field.style == .scrolling else {
            return
        }
        
        /* The position must be in the scroll area */
        guard position.x > field.rectangle.right - ScrollWidth else {
            return
        }
        
        /* The field must have an active scroll */
        let scrollRange = self.scrollRange
        guard scrollRange > 0 else {
            return
        }
        
        /* Check the mouse is clicking on the top scroll button */
        let upArrowRectangle = FieldView.computeUpArrowPosition(inFieldWithRectangle: field.rectangle)
        if upArrowRectangle.containsPosition(position) {
            self.isUpArrowClicked = true
            self.startScrolling(.up)
            return
        }
        
        /* Check the mouse is clicking on the bottom scroll button */
        let downArrowRectangle = FieldView.computeDownArrowPosition(inFieldWithRectangle: field.rectangle)
        if downArrowRectangle.containsPosition(position) {
            self.isDownArrowClicked = true
            self.startScrolling(.down)
            return
        }
        
        /* Check if the mouse is clicking on the knob */
        let scrollBarRectangle = FieldView.computeScrollBarRectangle(forRectangle: field.rectangle)
        let possibleKnobRectangle = FieldView.computeKnobRectangle(forScrollBarRectangle: scrollBarRectangle, scroll: field.scroll, scrollRange: self.scrollRange)
        if let knobRectangle = possibleKnobRectangle, knobRectangle.containsPosition(position) {
            
            let knobOffset = knobRectangle.top - field.rectangle.top - ScrollButtonHeight
            let knobRange = scrollBarRectangle.height - ScrollKnobHeight
            self.startMovingGhostKnob(fromOffset: knobOffset, knobRange: knobRange)
            return
        }
        
        let scrollBarClickDelta = 80
        
        /* Check if the mouse is clicking over the knob */
        if let knobRectangle = possibleKnobRectangle, position.y < knobRectangle.top, scrollBarRectangle.containsPosition(position) {
            
            field.scroll = max(0, field.scroll - scrollBarClickDelta)
        }
        
        /* Check if the mouse is clicking under the knob */
        if let knobRectangle = possibleKnobRectangle, position.y > knobRectangle.bottom, scrollBarRectangle.containsPosition(position) {
            
            field.scroll = min(scrollRange, field.scroll + scrollBarClickDelta)
        }
        
    }
    
    private func startMovingGhostKnob(fromOffset initialOffset: Int, knobRange: Int) {
        
        /* Display the knob */
        self.ghostKnobOffset = initialOffset
        
        /* Register some parameters */
        let initialMouseLocation = NSEvent.mouseLocation
        
        /* Build a timer to continuously move the ghost knob */
        let timer = Timer(timeInterval: 0.05, repeats: true, block: {
            [unowned self](timer: Timer) in
            
            /* Compute the vertical distance of the dragging */
            let mouseLocation = NSEvent.mouseLocation
            let offsetDelta = Int(initialMouseLocation.y - mouseLocation.y)
            
            /* Apply the vertical offset to the ghost knob, while respecting the bounds */
            self.ghostKnobOffset = max(0, min(knobRange, initialOffset + offsetDelta))
            
        })
        
        /* Save it */
        self.scrollingTimer = timer
        
        /* Schedule it */
        RunLoop.main.add(timer, forMode: .defaultRunLoopMode)
        
    }
    
    private enum Direction {
        case up
        case down
    }
    
    private func startScrolling(_ direction: Direction) {
        
        let scrollDelta = 16
        
        let scrollRange = self.scrollRange
        
        /* Build a timer to continuously scroll the field */
        let timer = Timer(timeInterval: 0.05, repeats: true, block: {
            [unowned self](timer: Timer) in
            
            /* Compute the new scroll */
            let scroll = self.field.scroll
            let newScroll = (direction == .up) ? max(0, scroll - scrollDelta) : min(scrollRange, scroll + scrollDelta)
            
            /* If the scroll is over, stop the timer */
            guard newScroll != scroll else {
                timer.invalidate()
                self.scrollingTimer = nil
                return
            }
            
            /* Update the scroll */
            self.field.scroll = newScroll
            
        })
        
        /* Save it */
        self.scrollingTimer = timer
        
        /* Schedule it */
        RunLoop.main.add(timer, forMode: .defaultRunLoopMode)
        
    }
    
    private func respondToMouseUp(at position: Point) {
        
        /* Un-click the scroll buttons if necessary */
        if self.isUpArrowClicked {
            self.isUpArrowClicked = false
        }
        if self.isDownArrowClicked {
            self.isDownArrowClicked = false
        }
        if let offset = self.ghostKnobOffset {
            
            /* Update the scroll */
            let scrollBarRectangle = FieldView.computeScrollBarRectangle(forRectangle: field.rectangle)
            let knobRange = scrollBarRectangle.height - ScrollKnobHeight
            let scrollRange = self.scrollRange
            field.scroll = scrollRange * offset / knobRange
            
            self.ghostKnobOffset = nil
        }
        if let timer = self.scrollingTimer {
            timer.invalidate()
            self.scrollingTimer = nil
        }
        
    }
    
}



