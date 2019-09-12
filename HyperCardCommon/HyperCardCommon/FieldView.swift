//
//  RegularFieldView.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 03/03/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


private let fieldShadowShift = 3
private let fieldShadowThickness = 2

private let carriageReturn = HChar(13)
private let space = HChar(32)

/// Ints representing an gray image
private let gray1: UInt = 0xAAAA_AAAA_AAAA_AAAA
private let gray2: UInt = 0x5555_5555_5555_5555
private let grays = [ Image.Integer(truncatingIfNeeded: gray1), Image.Integer(truncatingIfNeeded: gray2) ]

private let fieldLineComposition: ImageComposition = { (a: inout Image.Integer, b: Image.Integer, integerIndex: Int, y: Int) in
    
    let gray = grays[0]
    let inverseGray = grays[1]
    a |= (b & gray)
    a &= ~(b & inverseGray)
    
}

private let scrollWidth = 17
private let scrollButtonHeight = 16
private let scrollKnobHeight = 16

private let scrollUpButtonImage = MaskedImage(named: "scroll up arrow")!
private let scrollDownButtonImage = MaskedImage(named: "scroll down arrow")!

private let scrollUpButtonClickedImage = MaskedImage(named: "scroll up arrow clicked")!
private let scrollDownButtonClickedImage = MaskedImage(named: "scroll down arrow clicked")!

private let scrollPatternImage = Image(named: "scroll pattern")!

private enum DraggingState {
    case none
    case selectionDrag(characterIndex: Int)
    case wordSelectionDrag(wordRange: Range<Int>)
    case scrollKnob(mousePosition: Point, knobOffset: Int, knobRange: Int)
}

let arrowScrollDelta = 16
let arrowTimeInterval = 0.05
let barScrollDelta = 80
let barTimeInterval = 0.25



/// The view of a field.
public class FieldView: View, MouseResponder {
    
    private let field: Field
    
    private var richText: RichText {
        get { return self.richTextComputation.value }
    }
    private let richTextComputation: Computation<RichText>
    
    private var textLayout: TextLayout {
        get { return self.textLayoutComputation.value }
    }
    private let textLayoutComputation: Computation<TextLayout>
    
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
    
    var selectedRange: Range<Int>? {
        get { return self.selectedRangeProperty.value }
        set { self.selectedRangeProperty.value = newValue }
    }
    var selectedRangeProperty = Property<Range<Int>?>(nil)
    
    /// The timer sending scroll updates while the user is clicking on an scroll arrow
    private var scrollingTimer: Timer? = nil
    private var scrollingDirection: Direction? = nil
    
    private var draggingState = DraggingState.none
    
    var cursorRectangle: Rectangle {
        return FieldView.computeContentRectangle(of: self.field)
    }
    
    public init(field: Field, contentComputation: Computation<PartContent>, fontManager: FontManager) {
        
        self.field = field
        
        /* rich text */
        let richTextComputation = Computation<RichText> {
            return FieldView.buildRichText(from: contentComputation.value, withDefaultFontIdentifier: field.textFontIdentifier, defaultSize: field.textFontSize, defaultStyle: field.textStyle, fontManager: fontManager)
        }
        self.richTextComputation = richTextComputation
        
        /* line layouts */
        self.textLayoutComputation = Computation<TextLayout> {
            let text = richTextComputation.value
            let textWidth = FieldView.computeTextRectangle(of: field).width
            let lineHeight: Int? = field.fixedLineHeight ? field.textHeight : nil
            return TextLayout(for: text, textWidth: textWidth, alignment: field.textAlign, dontWrap: field.dontWrap, lineHeight: lineHeight)
        }
        
        super.init()
        
        /* Listen to content change */
        richTextComputation.dependsOn(contentComputation.valueProperty)
        textLayoutComputation.dependsOn(richTextComputation.valueProperty)
        
        /* Listen to visual changes */
        field.scrollProperty.startNotifications(for: self, by: {
            [unowned self] in if self.field.style == .scrolling { self.refreshNeedProperty.value = .refresh }
        })
        richTextComputation.valueProperty.startNotifications(for: self, by: {
            [unowned self] in
            self.refreshNeedProperty.value = (self.field.style == .transparent) ? .refreshWithNewShape : .refresh
            self.selectedRange = nil
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
        selectedRangeProperty.startNotifications(for: self, by: {
            [unowned self] in self.refreshNeedProperty.value = (self.field.style == .transparent) ? .refreshWithNewShape : .refresh
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
    
    private static func computeContentRectangle(of field: Field) -> Rectangle {
        
        let baseRectangle = Rectangle(top: field.rectangle.top + 1,
                                      left: field.rectangle.left + 1,
                                      bottom: field.rectangle.bottom - 1,
                                      right: field.rectangle.right - 1)
        
        switch field.style {
            
        case .shadow:
            return Rectangle(top: baseRectangle.top,
                             left: baseRectangle.left,
                             bottom: baseRectangle.bottom  - fieldShadowThickness,
                             right: baseRectangle.right - fieldShadowThickness)
            
        case .scrolling:
            return Rectangle(top: baseRectangle.top,
                             left: baseRectangle.left,
                             bottom: baseRectangle.bottom,
                             right: baseRectangle.right - scrollWidth + 1)
            
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
    
    override public func draw(in drawing: Drawing) {
        
        guard field.visible else {
            return
        }
        
        /* Get the visual properties as they are now */
        let richText = self.richText
        let textLayout = self.textLayout
        
        /* Draw the frame */
        drawFieldFrame(in: drawing)
        
        /* Draw the text */
        drawText(in: drawing, content: richText, textLayout: textLayout)
        
    }
    
    private func drawFieldFrame(in drawing: Drawing) {
        
        switch field.style {
            
        case .opaque:
            drawing.drawRectangle(field.rectangle, composition: Drawing.MaskComposition)
            
        case .rectangle:
            drawing.drawBorderedRectangle(field.rectangle)
            
        case .shadow:
            drawing.drawShadowedRectangle(field.rectangle, thickness: fieldShadowThickness, shift: fieldShadowShift)
            
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
        
        let contentHeight = field.rectangle.height - 2
        let totalTextHeight = textRectangle.top - field.rectangle.top + self.textLayout.size.height
        
        return max(0, totalTextHeight - contentHeight)
        
    }
    
    private static func drawScrollFrame(in drawing: Drawing, rectangle: Rectangle, isUpArrowClicked: Bool, isDownArrowClicked: Bool) {
        
        /* Draw the main border */
        drawing.drawBorderedRectangle(rectangle)
        
        /* Draw the scroll borders */
        
        /* Left scroll border */
        drawing.drawRectangle(Rectangle(x: rectangle.right - scrollWidth, y: rectangle.top, width: 1, height: rectangle.height))
        
        /* Don't draw the arrows if the field is too short (minus one because it is until the borders merge) */
        guard rectangle.height >= 2 * scrollButtonHeight - 1 else {
            return
        }
        
        /* Up arrow scroll border */
        drawing.drawRectangle(Rectangle(x: rectangle.right - scrollWidth, y: rectangle.top + scrollButtonHeight - 1, width: scrollWidth, height: 1))
        
        /* Down arrow scroll border */
        drawing.drawRectangle(Rectangle(x: rectangle.right - scrollWidth, y: rectangle.bottom - scrollButtonHeight, width: scrollWidth, height: 1))
        
        /* Up arrow icon (draw inside the borders of the button) */
        let upArrowRectangle = computeUpArrowPosition(inFieldWithRectangle: rectangle)
        let upArrowImage = isUpArrowClicked ? scrollUpButtonClickedImage : scrollUpButtonImage
        drawing.drawMaskedImage(upArrowImage, position: Point(x: upArrowRectangle.x + 1, y: upArrowRectangle.y + 1))
        
        /* Down arrow icon (draw inside the borders of the button) */
        let downArrowRectangle = computeDownArrowPosition(inFieldWithRectangle: rectangle)
        let downArrowImage = isDownArrowClicked ? scrollDownButtonClickedImage : scrollDownButtonImage
        drawing.drawMaskedImage(downArrowImage, position: Point(x: downArrowRectangle.x + 1, y: downArrowRectangle.y + 1))
        
    }
    
    private static func computeUpArrowPosition(inFieldWithRectangle rectangle: Rectangle) -> Rectangle {
        
        /* If the field is too short to draw the arrows, it can still be clicked */
        guard rectangle.height >= 2 * scrollButtonHeight else {
            return Rectangle(x: rectangle.right - scrollWidth, y: rectangle.top, width: scrollWidth, height: (rectangle.height + 1) / 2)
        }
        
        return Rectangle(x: rectangle.right - scrollWidth, y: rectangle.top, width: scrollWidth, height: scrollButtonHeight)
    }
    
    private static func computeDownArrowPosition(inFieldWithRectangle rectangle: Rectangle) -> Rectangle {
        
        /* If the field is too short to draw the arrows, it can still be clicked */
        guard rectangle.height >= 2 * scrollButtonHeight else {
            return Rectangle(x: rectangle.right - scrollWidth, y: rectangle.bottom - scrollButtonHeight, width: scrollWidth, height: rectangle.height / 2)
        }
        
        return Rectangle(x: rectangle.right - scrollWidth, y: rectangle.bottom - scrollButtonHeight, width: scrollWidth, height: scrollButtonHeight)
    }
    
    private static func drawActiveScroll(in drawing: Drawing, rectangle: Rectangle, scroll: Int, scrollRange: Int, ghostKnobOffset: Int?) {
        
        /* Check if there is a background */
        let scrollBarRectangle = computeScrollBarRectangle(forRectangle: rectangle)
        guard scrollBarRectangle.height > 0 else {
            return
        }
        
        /* Draw the background */
        drawing.drawPattern(scrollPatternImage, rectangle: scrollBarRectangle, offset: Point(x: -(scrollBarRectangle.x % 2), y: 0))
        
        /* Draw the knob */
        if let knobRectangle = computeKnobRectangle(forScrollBarRectangle: scrollBarRectangle, scroll: scroll, scrollRange: scrollRange) {
            drawing.drawBorderedRectangle(knobRectangle)
        }
        
        /* Draw the ghost knob if it exists */
        if let offset = ghostKnobOffset {
            let ghostKnobRectangle = Rectangle(x: scrollBarRectangle.left, y: scrollBarRectangle.top + offset, width: scrollBarRectangle.width, height: scrollKnobHeight)
            drawing.drawBorderedRectangle(ghostKnobRectangle, composition: Drawing.NoComposition, borderComposition: Drawing.XorComposition)
        }
        
    }
    
    private static func computeScrollBarRectangle(forRectangle rectangle: Rectangle) -> Rectangle {
        
        return Rectangle(top: rectangle.top + scrollButtonHeight, left: rectangle.right - scrollWidth + 1, bottom: rectangle.bottom - scrollButtonHeight, right: rectangle.right - 1)
    }
    
    private static func computeKnobRectangle(forScrollBarRectangle scrollBarRectangle: Rectangle, scroll: Int, scrollRange: Int) -> Rectangle? {
        
        /* If the knob doesn't fit in the scoll bar, it is not drawn */
        guard scrollBarRectangle.height >= scrollKnobHeight else {
            return nil
        }
        
        /* Compute the position of the knob */
        let knobRange = scrollBarRectangle.height - scrollKnobHeight
        let knobOffset = knobRange * scroll / scrollRange
        return Rectangle(x: scrollBarRectangle.x, y: scrollBarRectangle.y + knobOffset, width: scrollBarRectangle.width, height: scrollKnobHeight)
    }
    
    private func drawText(in drawing: Drawing, content: RichText, textLayout: TextLayout) {
        
        let textRectangle = FieldView.computeTextRectangle(of: field)
        let contentRectangle = FieldView.computeContentRectangle(of: field)
        
        if textRectangle.width == 0 || textRectangle.height == 0  {
            return
        }
        
        /* Draw the lines if necessary */
        let showLines = field.showLines && field.style != .scrolling
        if showLines {
            self.drawLines(drawing: drawing, layout: textLayout, textRectangle: textRectangle, contentRectangle: contentRectangle, scroll: field.scroll)
        }
        
        /* Draw the text */
        textLayout.draw(in: drawing, at: Point(x: textRectangle.left, y: textRectangle.top - field.scroll), clipRectangle: contentRectangle)
        
        /* Draw the selection */
        if let selectedRange = self.selectedRange {
            self.drawSelection(selectedRange, in: drawing, layout: textLayout, textRectangle: textRectangle, contentRectangle: contentRectangle, scroll: field.scroll)
        }
        
    }
    
    private func drawLines(drawing: Drawing, layout: TextLayout, textRectangle: Rectangle, contentRectangle: Rectangle, scroll: Int) {
        
        /* Init the baseline where it should be if there is no text */
        var baseLineY = textRectangle.top - field.scroll - field.textHeight/4
        var lineIndex = 0
        
        while true {
            
            /* While there is text, stick to the baselines, elsewhere, continue till the bottom of the field */
            if lineIndex < layout.lines.count {
                let layout = layout.lines[lineIndex]
                baseLineY = textRectangle.top + layout.origin.y - field.scroll
                lineIndex += 1
            }
            else {
                baseLineY += field.textHeight
            }
            
            /* Check if the lines start being visible */
            guard baseLineY + 1 >= contentRectangle.top else {
                continue
            }
            
            /* Check if the lines stop being visible */
            guard baseLineY + 2 <= contentRectangle.bottom else {
                break
            }
            
            /* Draw the line */
            let lineRectangle = Rectangle(top: baseLineY + 1, left: contentRectangle.left, bottom: baseLineY+2, right: contentRectangle.right)
            drawing.drawRectangle(lineRectangle, clipRectangle: contentRectangle, composition: fieldLineComposition)
            
        }
    }
    
    private func drawSelection(_ range: Range<Int>, in drawing: Drawing, layout: TextLayout, textRectangle: Rectangle, contentRectangle: Rectangle, scroll: Int) {
        
        /* Locate the range in the text */
        let startTextPosition = layout.findPosition(at: range.startIndex)
        let endTextPosition = layout.findPosition(at: range.endIndex)
        
        /* Special case if the selection is in one line */
        guard startTextPosition.lineIndex < endTextPosition.lineIndex else {
            drawSelectionInLine(lineIndex: startTextPosition.lineIndex, startOffset: startTextPosition.offset, endOffset: endTextPosition.offset, layout: layout, drawing: drawing, textRectangle: textRectangle, contentRectangle: contentRectangle, scroll: scroll)
            return
        }
        
        /* Draw the first line */
        drawSelectionInLine(lineIndex: startTextPosition.lineIndex, startOffset: startTextPosition.offset, endOffset: .endOfLine, layout: layout, drawing: drawing, textRectangle: textRectangle, contentRectangle: contentRectangle, scroll: scroll)
        
        /* Draw the last line */
        drawSelectionInLine(lineIndex: endTextPosition.lineIndex, startOffset: .value(0), endOffset: endTextPosition.offset, layout: layout, drawing: drawing, textRectangle: textRectangle, contentRectangle: contentRectangle, scroll: scroll)
        
        /* Draw the lines in-between */
        guard startTextPosition.lineIndex + 1 < endTextPosition.lineIndex else {
            return
        }
        
        for lineIndex in (startTextPosition.lineIndex+1) ... (endTextPosition.lineIndex-1) {
            
            drawSelectionInLine(lineIndex: lineIndex, startOffset: .value(0), endOffset: .endOfLine, layout: layout, drawing: drawing, textRectangle: textRectangle, contentRectangle: contentRectangle, scroll: scroll)
        }
    }
    
    private func drawSelectionInLine(lineIndex: Int, startOffset: TextLayout.TextPosition.Offset, endOffset: TextLayout.TextPosition.Offset, layout: TextLayout, drawing: Drawing, textRectangle: Rectangle, contentRectangle: Rectangle, scroll: Int) {
        
        guard startOffset != endOffset else {
            return
        }
        
        let line = layout.lines[lineIndex]
        let top = textRectangle.top - scroll + line.top
        let bottom = textRectangle.top - scroll + line.bottom
        
        let left = self.convertTextOffsetToX(startOffset, textRectangle: textRectangle, contentRectangle: contentRectangle)
        let right = self.convertTextOffsetToX(endOffset, textRectangle: textRectangle, contentRectangle: contentRectangle)
        
        let rectangle = Rectangle(top: top, left: left, bottom: bottom, right: right)
        drawing.drawRectangle(rectangle, clipRectangle: contentRectangle, composition: Drawing.XorComposition)
    }
    
    private func convertTextOffsetToX(_ offset: TextLayout.TextPosition.Offset, textRectangle: Rectangle, contentRectangle: Rectangle) -> Int {
        
        switch offset {
            
        case .value(0):
            return contentRectangle.left
            
        case .value(let value):
            return textRectangle.left + value
            
        case .endOfLine:
            return contentRectangle.right
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
            
        case .mouseDown(let clickCount):
            self.respondToMouseDown(at: position, clickCount: clickCount)
            
        case .mouseUp:
            self.respondToMouseUp(at: position)
            
        case .mouseDragged:
            self.respondToMouseDragged(at: position)
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
    
    private func respondToMouseDown(at position: Point, clickCount: Int) {
        
        /* Special case if the user clicks on a scroll */
        guard field.style != .scrolling || position.x <= field.rectangle.right - scrollWidth else {
            self.respondToMouseDownInScroll(at: position)
            return
        }
        
        /* Get the click position in the text */
        let characterIndex = computeCharacterIndexAtPosition(position)
        
        switch clickCount {
            
        case 1:
            /* Simple click */
            /* If we have a previous selection, remove it */
            self.selectedRange = nil
            
            /* Wait and see if the user drags */
            self.draggingState = .selectionDrag(characterIndex: characterIndex)
            
        case 2:
            /* Double click */
            let wordRange = self.findWordRange(at: characterIndex)
            self.selectedRange = wordRange
            
            /* Wait and see if the user drags */
            self.draggingState = .wordSelectionDrag(wordRange: wordRange)
            
        default:
            break
        }
        
    }
    
    private func computeCharacterIndexAtPosition(_ position: Point) -> Int {
        
        let textRectangle = FieldView.computeTextRectangle(of: self.field)
        let positionInText = Point(x: position.x - textRectangle.x, y: position.y - textRectangle.y + field.scroll)
        let characterIndex = self.textLayout.findCharacterIndex(at: positionInText)
        
        return characterIndex
    }
    
    private func findWordRange(at index: Int) -> Range<Int> {
        
        let string = self.richText.string
        
        var startIndex = index
        while startIndex > 0 && string[startIndex-1].isWordElement() {
            startIndex -= 1
        }
        
        var endIndex = index
        let length = string.length
        while endIndex < length && string[endIndex].isWordElement() {
            endIndex += 1
        }
        
        return startIndex ..< endIndex
    }
    
    private func respondToMouseDownInScroll(at position: Point) {
        
        /* The field must have an active scroll */
        let scrollRange = self.scrollRange
        guard scrollRange > 0 else {
            return
        }
        
        /* Check the mouse is clicking on the top scroll button */
        let upArrowRectangle = FieldView.computeUpArrowPosition(inFieldWithRectangle: field.rectangle)
        if upArrowRectangle.containsPosition(position) {
            self.isUpArrowClicked = true
            self.startScrolling(.up, scrollDelta: arrowScrollDelta, timeInterval: arrowTimeInterval, callback: nil)
            return
        }
        
        /* Check the mouse is clicking on the bottom scroll button */
        let downArrowRectangle = FieldView.computeDownArrowPosition(inFieldWithRectangle: field.rectangle)
        if downArrowRectangle.containsPosition(position) {
            self.isDownArrowClicked = true
            self.startScrolling(.down, scrollDelta: arrowScrollDelta, timeInterval: arrowTimeInterval, callback: nil)
            return
        }
        
        /* Check if the mouse is clicking on the knob */
        let scrollBarRectangle = FieldView.computeScrollBarRectangle(forRectangle: field.rectangle)
        let possibleKnobRectangle = FieldView.computeKnobRectangle(forScrollBarRectangle: scrollBarRectangle, scroll: field.scroll, scrollRange: self.scrollRange)
        if let knobRectangle = possibleKnobRectangle, knobRectangle.containsPosition(position) {
            
            let knobOffset = knobRectangle.top - field.rectangle.top - scrollButtonHeight
            let knobRange = scrollBarRectangle.height - scrollKnobHeight
            self.draggingState = DraggingState.scrollKnob(mousePosition: position, knobOffset: knobOffset, knobRange: knobRange)
            return
        }
        
        
        /* Check if the mouse is clicking over the knob */
        if let knobRectangle = possibleKnobRectangle, position.y < knobRectangle.top, scrollBarRectangle.containsPosition(position) {
            
            self.startScrolling(.up, scrollDelta: barScrollDelta, timeInterval: barTimeInterval, callback: nil)
        }
        
        /* Check if the mouse is clicking under the knob */
        if let knobRectangle = possibleKnobRectangle, position.y > knobRectangle.bottom, scrollBarRectangle.containsPosition(position) {
            
            self.startScrolling(.down, scrollDelta: barScrollDelta, timeInterval: barTimeInterval, callback: nil)
        }
        
    }
    
    private func startScrolling(_ direction: Direction, scrollDelta: Int, timeInterval: TimeInterval, callback: (() -> ())?) {
        
        
        let scrollRange = self.scrollRange
        
        /* Build a timer to continuously scroll the field */
        let timer = Timer(timeInterval: timeInterval, repeats: true, block: {
            [unowned self](timer: Timer) in
            
            /* Compute the new scroll */
            let scroll = self.field.scroll
            let newScroll = (direction == .up) ? max(0, scroll - scrollDelta) : min(scrollRange, scroll + scrollDelta)
            
            /* If the scroll is over, stop the timer */
            guard newScroll != scroll else {
                self.stopScrolling()
                return
            }
            
            /* Update the scroll */
            self.field.scroll = newScroll
            
            if let call = callback {
                call()
            }
            
        })
        
        /* Save it */
        self.scrollingTimer = timer
        self.scrollingDirection = direction
        
        /* Schedule it */
        RunLoop.main.add(timer, forMode: RunLoop.Mode.default)
        
    }
    
    private func stopScrolling() {
        
        if let timer = self.scrollingTimer {
            timer.invalidate()
            self.scrollingTimer = nil
            self.scrollingDirection = nil
        }
    }
    
    private func respondToMouseUp(at position: Point) {
        
        self.draggingState = .none
        
        guard field.style != .scrolling else {
            self.respondToMouseUpInScrollingField(at: position)
            return
        }
        
        /* End dragging */
        self.respondToMouseDragged(at: position)
    }
    
    private func respondToMouseDragged(at position: Point) {
        
        switch self.draggingState {
            
        case .selectionDrag(let initialCharacterIndex):
            self.respondToSelectionDragged(at: position, initialCharacterIndex: initialCharacterIndex)
            
        case .wordSelectionDrag(let wordRange):
            self.respondToWordSelectionDragged(at: position, initialWordRange: wordRange)
            
        case .scrollKnob(let initialMousePosition, let initialKnobOffset, let knobRange):
            self.respondToKnobDragged(mousePosition: position, initialMousePosition: initialMousePosition, initialKnobOffset: initialKnobOffset, knobRange: knobRange)
            
        default:
            break
        }
    }
    
    private func respondToKnobDragged(mousePosition: Point, initialMousePosition: Point, initialKnobOffset: Int, knobRange: Int) {
        
        /* Compute the vertical distance of the dragging */
        let offsetDelta = mousePosition.y - initialMousePosition.y
        
        /* Apply the vertical offset to the ghost knob, while respecting the bounds */
        self.ghostKnobOffset = max(0, min(knobRange, initialKnobOffset + offsetDelta))
    }
    
    // Used only for when the user drags a selection and scrolls without dragging
    private var lastDragPosition: Point? = nil
    
    private func respondToSelectionDragged(at position: Point, initialCharacterIndex: Int) {
            
        /* Compute the character index of the current position */
        let characterIndex = computeCharacterIndexAtPosition(position)
        
        /* Change the selection */
        let firstIndex = min(characterIndex, initialCharacterIndex)
        let lastIndex = max(characterIndex, initialCharacterIndex)
        self.selectedRange = (firstIndex == lastIndex) ? nil : (firstIndex ..< lastIndex)
        
        /* Special case: scolling fields scroll */
        if field.style == .scrolling {
            self.scrollDuringDrag(position: position) { [unowned self] in
                self.respondToSelectionDragged(at: position, initialCharacterIndex: initialCharacterIndex)
            }
        }
        
        /* Regiter the position */
        lastDragPosition = position
    }
    
    private func respondToWordSelectionDragged(at position: Point, initialWordRange: Range<Int>) {
        
        /* Compute the character index of the current position */
        let characterIndex = computeCharacterIndexAtPosition(position)
        let wordRange = self.findWordRange(at: characterIndex)
        
        /* Change the selection */
        let firstIndex = min(wordRange.startIndex, initialWordRange.startIndex)
        let lastIndex = max(wordRange.endIndex, initialWordRange.endIndex)
        self.selectedRange = firstIndex ..< lastIndex
        
        /* Special case: scolling fields scroll */
        if field.style == .scrolling {
            self.scrollDuringDrag(position: position) { [unowned self] in
                self.respondToWordSelectionDragged(at: position, initialWordRange: initialWordRange)
            }
        }
        
        /* Regiter the position */
        lastDragPosition = position
    }
    
    private func scrollDuringDrag(position: Point, scrollCallback: @escaping () -> ()) {
        
        /* Check where the mouse is pointing */
        let expectedDirection: Direction?
        if position.y < field.rectangle.top {
            expectedDirection = .up
        }
        else if position.y >= field.rectangle.bottom {
            expectedDirection = .down
        }
        else {
            expectedDirection = nil
        }
        
        /* Check if we're scrolling in the right direction */
        guard expectedDirection != self.scrollingDirection else {
            return
        }
        
        /* Check if we can still scroll in the direction */
        if expectedDirection == .up && field.scroll == 0 {
            return
        }
        if expectedDirection == .down && field.scroll == self.scrollRange {
            return
        }
        
        /* Start scrolling in the right direction */
        if self.scrollingDirection != nil {
            self.stopScrolling()
        }
        if let direction = expectedDirection {
            self.startScrolling(direction, scrollDelta: arrowScrollDelta, timeInterval: arrowTimeInterval, callback: scrollCallback)
        }
    }
    
    private func respondToMouseUpInScrollingField(at position: Point) {
        
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
            let knobRange = scrollBarRectangle.height - scrollKnobHeight
            let scrollRange = self.scrollRange
            field.scroll = scrollRange * offset / knobRange
            
            self.ghostKnobOffset = nil
        }
        self.stopScrolling()
    }
    
    func getSelection() -> HString? {
        
        guard let range = self.selectedRange else {
            return nil
        }
        
        return self.richText.string[range]
    }
    
    func selectAll() {
        
        self.selectedRange = 0..<self.richText.string.length
    }
    
}



