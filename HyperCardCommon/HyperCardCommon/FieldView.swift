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
    
    /// The timer sending scroll updates while the user is clicking on an scroll arrow
    private var scrollingTimer: Timer? = nil
    
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
            let textWidth: Int? = field.dontWrap ? nil : FieldView.computeTextRectangle(of: field).width
            let lineHeight: Int? = field.fixedLineHeight ? field.textHeight : nil
            return TextLayout(text: text, width: textWidth, lineHeight: lineHeight)
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
        
        let lastLineLayout = self.textLayout.lines.last!
        let contentHeight = field.rectangle.height - 2
        let totalTextHeight = textRectangle.top - field.rectangle.top + lastLineLayout.bottom
        
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
        textLayout.draw(in: drawing, at: Point(x: textRectangle.left, y: textRectangle.top - field.scroll), width: textRectangle.width, alignment: field.textAlign, clipRectangle: contentRectangle)
        
    }
    
    private func drawLines(drawing: Drawing, layout: TextLayout, textRectangle: Rectangle, contentRectangle: Rectangle, scroll: Int) {
        
        var baseLineY = 0
        var lineIndex = 0
        
        while true {
            
            /* While there is text, stick to the baselines, elsewhere, continue till the bottom of the field */
            if lineIndex < layout.lines.count {
                let layout = layout.lines[lineIndex]
                baseLineY = textRectangle.top + layout.baseLineY - field.scroll
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
        guard position.x > field.rectangle.right - scrollWidth else {
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
            
            let knobOffset = knobRectangle.top - field.rectangle.top - scrollButtonHeight
            let knobRange = scrollBarRectangle.height - scrollKnobHeight
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
            let knobRange = scrollBarRectangle.height - scrollKnobHeight
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



