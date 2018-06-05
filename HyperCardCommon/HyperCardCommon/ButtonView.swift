//
//  ButtonView.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 21/08/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


private let buttonMargin = 9
private let iconNameButtonMargin = 1

private let defaultMargin = 4

private struct CornerImage {
    var topLeft: MaskedImage
    var topRight: MaskedImage
    var bottomLeft: MaskedImage
    var bottomRight: MaskedImage
}
private let cornerSize = 8
private let topLeftCornerName = "top left"
private let topRightCornerName = "top right"
private let bottomLeftCornerName = "bottom left"
private let bottomRightCornerName = "bottom right"
private let roundRectCornerImage = loadCornerImage(name: "roundrect")
private let standardCornerImage = loadCornerImage(name: "standard")
private let defaultCornerImage = loadCornerImage(name: "default")
private func loadCornerImage(name: String) -> CornerImage {
    
    /* Load the images */
    let topLeftImage = MaskedImage(named: "\(name) \(topLeftCornerName)")!
    let topRightImage = MaskedImage(named: "\(name) \(topRightCornerName)")!
    let bottomLeftImage = MaskedImage(named: "\(name) \(bottomLeftCornerName)")!
    let bottomRightImage = MaskedImage(named: "\(name) \(bottomRightCornerName)")!
    
    
    /* Build the result */
    return CornerImage(topLeft: topLeftImage, topRight: topRightImage, bottomLeft: bottomLeftImage, bottomRight: bottomRightImage)
}

private let iconButtonFontIdentifier = FontIdentifiers.geneva
private let iconButtonFontSize = 9
private let iconButtonFontStyle = PlainTextStyle


private struct BorderThickness {
    var top: Int
    var left: Int
    var bottom: Int
    var right: Int
}
private let roundRectBorderThickness = BorderThickness(top: 1, left: 1, bottom: 2, right: 2)
private let standardBorderThickness = BorderThickness(top: 1, left: 1, bottom: 1, right: 1)
private let defaultBorderThickness = BorderThickness(top: 3, left: 3, bottom: 3, right: 3)

private let checkBoxFrame = MaskedImage(named: "checkbox frame")!
private let checkBoxHilite = MaskedImage(named: "checkbox hilite")!
private let checkBoxClick = MaskedImage(named: "checkbox click")!

private let radioFrame = MaskedImage(named: "radio frame")!
private let radioHilite = MaskedImage(named: "radio hilite")!
private let radioClick = MaskedImage(named: "radio click")!

private let popupTextLeftMargin = 18
private let popupTextRightMargin = 20
private let popupEllipsis: HString = "…"
private let popupArrowImage = MaskedImage(named: "popup arrow")!
private let popupArrowDistanceFromBorder = 18
private let popupArrowHeight = 6

/// The composition applied to a part image to make it look disabled
private let disabledComposition: ImageComposition = { (a: inout Image.Integer, b: Image.Integer, integerIndex: Int, y: Int) in
    
    let gray = grays[y % 2]
    let inverseGray = grays[1 - y % 2]
    a |= (b & gray)
    a &= ~(b & inverseGray)
    
}

/// The composition applied to a hilited part image to make it look disabled
private let blackToGrayComposition: ImageComposition = { (a: inout Image.Integer, b: Image.Integer, integerIndex: Int, y: Int) in
    
    let inverseGray = grays[1 - y % 2]
    a &= ~(b & inverseGray)
    
}

/// Shift between buttons and their shadows, in pixels
private let buttonShadowShift = 2

/// Thickness of the shadows of the buttons, in pixels
private let buttonShadowThickness = 1

/// Ints representing an gray image
private let gray1: UInt = 0xAAAA_AAAA_AAAA_AAAA
private let gray2: UInt = 0x5555_5555_5555_5555
private let grays = [ Image.Integer(truncatingIfNeeded: gray1), Image.Integer(truncatingIfNeeded: gray2) ]








public class ButtonView: View, MouseResponder {
    
    private let button: Button
    
    private let hiliteComputation: Computation<Bool>
    
    /// the font for the texts
    private var font: BitmapFont {
        return fontComputation.value
    }
    private let fontComputation: Computation<BitmapFont>
    
    /// the image of the icon
    private var icon: MaskedImage? {
        return iconComputation.value
    }
    private let iconComputation: Computation<MaskedImage?>
    
    /// the menu items, used by pop-up buttons
    private var menuItems: [HString] {
        return menuItemsComputation.value
    }
    private let menuItemsComputation: Computation<[HString]>
    
    /// the condensed version of the font, used by pop-up buttons
    private var condensedFont: BitmapFont {
        return condensedFontComputation.value
    }
    private let condensedFontComputation: Computation<BitmapFont>
    
    public init(button: Button, hiliteComputation: Computation<Bool>, fontManager: FontManager, resources: ResourceSystem) {
        
        self.button = button
        self.hiliteComputation = hiliteComputation
        
        /* font */
        fontComputation = Computation<BitmapFont> {
            
            let hasIcon = ButtonView.hasButtonIcon(button)
            
            let fontIdentifier = hasIcon ? iconButtonFontIdentifier : button.textFontIdentifier
            let fontSize = hasIcon ? iconButtonFontSize : button.textFontSize
            let fontStyle = hasIcon ? iconButtonFontStyle : button.textStyle
            return fontManager.findFont(withIdentifier: fontIdentifier, size: fontSize, style: fontStyle)
        }
        
        /* condensedFont */
        condensedFontComputation = Computation<BitmapFont> {
            
            var consensedStyle = button.textStyle
            consensedStyle.condense = true
            return fontManager.findFont(withIdentifier: button.textFontIdentifier, size: button.textFontSize, style: consensedStyle)
        }
        
        /* icon */
        let iconIdentifier = button.iconIdentifier
        iconComputation = Computation<MaskedImage?> {
            
            guard iconIdentifier != 0 else {
                return nil
            }
            
            if let iconResource = resources.findResource(ofType: \ResourceRepository.icons, withIdentifier: iconIdentifier) {
                return maskIcon(iconResource.content)
            }
            
            return nil
        }
        
        /* menuItems */
        menuItemsComputation = Computation<[HString]> {
        
            return ButtonView.separateStringLines(in: button.content)
        }
        
        super.init()
        
        /* font dependencies */
        fontComputation.dependsOn(button.iconIdentifierProperty)
        fontComputation.dependsOn(button.textFontIdentifierProperty)
        fontComputation.dependsOn(button.textFontSizeProperty)
        fontComputation.dependsOn(button.textStyleProperty)
        
        /* condensedFont dependencies */
        condensedFontComputation.dependsOn(button.textFontIdentifierProperty)
        condensedFontComputation.dependsOn(button.textFontSizeProperty)
        condensedFontComputation.dependsOn(button.textStyleProperty)
        
        /* drawing dependencies */
        hiliteComputation.valueProperty.startNotifications(for: self, by: {
            [unowned self] in self.refreshNeedProperty.value = (self.button.style == .transparent || self.button.style == .oval) ? .refreshWithNewShape : .refresh
        })
        button.selectedItemProperty.startNotifications(for: self, by: {
            [unowned self] in self.refreshNeedProperty.value = .refresh
        })
        
    }
    
    private static func hasButtonIcon(_ button: Button) -> Bool {
        
        switch button.style {
            
        case .transparent, .opaque, .rectangle, .shadow, .roundRect, .standard, .`default`, .oval:
            return button.iconIdentifier != 0
            
        default:
            return false
        }
        
    }
    
    private static func separateStringLines(in string: HString) -> [HString] {
        
        guard string.length > 0 else {
            return []
        }
        
        var lines = [HString]()
        
        var lineStart = 0
        let carriageReturn = HChar(13)
        
        for i in 0..<string.length {
            if string[i] == carriageReturn {
                let line = string[lineStart..<i]
                lines.append(line)
                lineStart = i+1
            }
        }
        
        /* Add the last line (except if it is empty, to stick to HyperCard behavior) */
        if lineStart != string.length {
            let lastLine = string[lineStart..<string.length]
            lines.append(lastLine)
        }
        
        return lines
    }
    
    public override func draw(in drawing: Drawing) {
        
        guard button.visible else {
            return
        }
        
        switch button.style {
            
        case .transparent, .opaque, .rectangle, .shadow, .roundRect, .standard, .`default`, .oval:
            drawRegularButton(in: drawing)
        
        case .checkBox, .radio:
            drawCheckBoxButton(in: drawing)
        
        case .popup:
            drawPopupButton(in: drawing)
            
        default:
            break
        }
        
    }
    
    private func drawRegularButton(in drawing: Drawing) {
        
        /* Define some usual compositions */
        let isTransparent = button.style == .transparent || button.style == .oval
        let titleComposition = findTitleComposition()
        let backgroundComposition = findBackgroundComposition()
        
        /* Draw the frame */
        var rectangle = button.rectangle
        drawButtonFrame(drawing: drawing)
        
        /* Special case: default button */
        if button.style == .`default` {
            rectangle = Rectangle(top: rectangle.top + defaultMargin, left: rectangle.left + defaultMargin, bottom: rectangle.bottom - defaultMargin, right: rectangle.right - defaultMargin)
            drawCornerImage(standardCornerImage, rectangle: rectangle, drawing: drawing, borderThickness: standardBorderThickness, composition: backgroundComposition)
        }
        
        /* Draw title & icon (if an icon is set but not found, the button is layout as if had an icon) */
        if button.showName && button.iconIdentifier == 0 {
            let nameWidth = font.computeSizeOfString(button.name)
            let nameX = computeNameX(nameWidth: nameWidth)
            let nameY = rectangle.y + rectangle.height / 2 + font.maximumAscent / 2 - font.maximumAscent / 6
            drawing.drawString(button.name, position: Point(x: nameX, y: nameY), font: font, clip: rectangle, composition: titleComposition)
            if !button.enabled {
                drawing.drawRectangle(Rectangle(top: nameY - font.maximumAscent, left: nameX - 2, bottom: nameY + font.maximumDescent, right: nameX + nameWidth + 2), clipRectangle: rectangle, composition: blackToGrayComposition)
            }
        }
        else {
            let iconAndTitleHeight = (button.showName) ? IconSize + iconNameButtonMargin + font.maximumAscent + font.maximumDescent + 1 : IconSize + 2
            let iconAndTitleOrigin = rectangle.height / 2 - iconAndTitleHeight / 2 + 1
            if button.showName {
                let nameWidth = font.computeSizeOfString(button.name)
                let nameX = computeNameX(nameWidth: nameWidth)
                let nameY = rectangle.y + iconAndTitleOrigin + IconSize + iconNameButtonMargin + font.maximumAscent - 1
                if isTransparent {
                    drawing.drawRectangle(Rectangle(top: nameY - font.maximumAscent, left: nameX - 2, bottom: nameY + font.maximumDescent, right: nameX + nameWidth + 2), clipRectangle: rectangle, composition: backgroundComposition)
                }
                drawing.drawString(button.name, position: Point(x: nameX, y: nameY), font: font, clip: rectangle, composition: titleComposition)
                if !button.enabled {
                    drawing.drawRectangle(Rectangle(top: nameY - font.maximumAscent, left: nameX - 2, bottom: nameY + font.maximumDescent, right: nameX + nameWidth + 2), clipRectangle: rectangle, composition: blackToGrayComposition)
                }
            }
            let iconX = rectangle.width / 2 - IconSize / 2
            let (imageComposition, maskComposition) = findIconComposition()
            if let icon = icon {
                drawing.drawMaskedImage(icon, position: Point(x: rectangle.x + iconX, y: rectangle.y + iconAndTitleOrigin), clipRectangle: rectangle, imageComposition: imageComposition, maskComposition: maskComposition)
            }
        }
        
    }
    
    private func findTitleComposition() -> ImageComposition {
        
        let transparent = button.style == .transparent || button.style == .oval
        
        if hiliteComputation.value && transparent {
            return Drawing.XorComposition
        }
        
        /* Special case: hilited
         Even if the button is disabled, the text must be drawn in white on the gray background */
        if hiliteComputation.value {
            return Drawing.MaskComposition
        }
        
        /* Normal composition */
        return Drawing.DirectComposition
        
    }
    
    private func findBackgroundComposition() -> ImageComposition {
        
        /* Special case: disabled */
        if !button.enabled && hiliteComputation.value {
            return disabledComposition
        }
        
        /* Second special case: hilited */
        if hiliteComputation.value {
            return Drawing.DirectComposition
        }
        
        /* Normal composition */
        return Drawing.MaskComposition
        
    }
    
    private func drawButtonFrame(drawing: Drawing) {
        
        let backgroundComposition = findBackgroundComposition()
        let rectangle = button.rectangle
        
        switch button.style {
        case .transparent:
            if icon == nil {
                if hiliteComputation.value {
                    drawing.drawRectangle(rectangle, composition: Drawing.XorComposition)
                }
                if !button.enabled {
                    drawing.drawRectangle(rectangle, composition: blackToGrayComposition)
                }
            }
        case .opaque:
            drawing.drawRectangle(rectangle, composition: backgroundComposition)
        case .rectangle:
            drawing.drawBorderedRectangle(rectangle, composition: backgroundComposition)
        case .shadow:
            drawing.drawShadowedRectangle(rectangle, thickness: buttonShadowThickness, shift: buttonShadowShift, composition: backgroundComposition)
        case .roundRect:
            drawCornerImage(roundRectCornerImage, rectangle: rectangle, drawing: drawing, borderThickness: roundRectBorderThickness, composition: backgroundComposition)
        case .standard:
            drawCornerImage(standardCornerImage, rectangle: rectangle, drawing: drawing, borderThickness: standardBorderThickness, composition: backgroundComposition)
        case .`default`:
            
            /* Draw the external border only, without hilite */
            let borderComposition = button.enabled ? Drawing.DirectComposition : disabledComposition
            drawCornerImage(defaultCornerImage, rectangle: rectangle, drawing: drawing, borderThickness: defaultBorderThickness, borderComposition: borderComposition, composition:Drawing.MaskComposition)
        case .oval:
            if hiliteComputation.value && icon == nil && rectangle.width > 0 && rectangle.height > 0 {
                /* draw background oval */
                let radiusX2 = Double(rectangle.width * rectangle.width) / 4
                let factor2 = Double(rectangle.width * rectangle.width) / Double(rectangle.height * rectangle.height)
                let centerX = Double(rectangle.x) + Double(rectangle.width) / 2
                let centerY = Double(rectangle.y) + Double(rectangle.height) / 2
                for y in rectangle.top..<rectangle.bottom {
                    let realY = centerY - Double(y)
                    let boundX = sqrt(radiusX2 - factor2 * realY * realY)
                    
                    let xMin = Int(round(centerX - boundX))
                    let xMax = Int(round(centerX + boundX))
                    let rowRectangle = Rectangle(top: y, left: xMin, bottom: y+1, right: xMax)
                    
                    drawing.drawRectangle(rowRectangle, composition: Drawing.XorComposition)
                    if !button.enabled {
                        drawing.drawRectangle(rowRectangle, composition: blackToGrayComposition)
                    }
                }
            }
            
        default:
            break
        }
        
    }
    
    private func findIconComposition() -> (ImageComposition?, ImageComposition?) {
        
        let transparent = button.style == .transparent || button.style == .oval
        
        if transparent {
            if hiliteComputation.value {
                return (button.enabled ? Drawing.MaskComposition : disabledComposition, Drawing.DirectComposition)
            }
            else {
                return (button.enabled ? Drawing.DirectComposition : disabledComposition, Drawing.MaskComposition)
            }
        }
        else {
            return (button.enabled ? Drawing.XorComposition : disabledComposition, nil)
        }
        
    }
    
    private func computeNameX(nameWidth: Int) -> Int {
        
        switch button.textAlign {
            
        case .left:
            return button.rectangle.x + buttonMargin
            
        case .center:
            return button.rectangle.x + button.rectangle.width / 2 - nameWidth / 2
            
        case .right:
            return button.rectangle.right - buttonMargin - nameWidth
            
        }
        
    }
    
    private func drawCornerImage(_ cornerImage: CornerImage, rectangle: Rectangle, drawing: Drawing, borderThickness: BorderThickness, borderComposition: @escaping ImageComposition = Drawing.DirectComposition, composition: @escaping ImageComposition) {
        
        /* If the button is too small, the border images must be clipped */
        let cornerWidth = min(cornerSize, rectangle.width / 2)
        let cornerHeight = min(cornerSize, rectangle.height / 2)
        
        /* Draw the images */
        drawing.drawMaskedImage(cornerImage.topLeft, position: Point(x: rectangle.x, y: rectangle.y), rectangleToDraw: Rectangle(x: 0, y: 0, width: cornerWidth , height: cornerHeight), imageComposition: borderComposition, maskComposition: composition)
        drawing.drawMaskedImage(cornerImage.topRight, position: Point(x: rectangle.right - cornerWidth, y: rectangle.y), rectangleToDraw: Rectangle(x: cornerSize - cornerWidth, y: 0, width: cornerWidth , height: cornerHeight), imageComposition: borderComposition, maskComposition: composition)
        drawing.drawMaskedImage(cornerImage.bottomLeft, position: Point(x: rectangle.x, y: rectangle.bottom - cornerHeight), rectangleToDraw: Rectangle(x: 0, y: cornerSize - cornerHeight, width: cornerWidth , height: cornerHeight), imageComposition: borderComposition, maskComposition: composition)
        drawing.drawMaskedImage(cornerImage.bottomRight, position: Point(x: rectangle.right - cornerWidth, y: rectangle.bottom - cornerHeight), rectangleToDraw: Rectangle(x: cornerSize - cornerWidth, y: cornerSize - cornerHeight, width: cornerWidth , height: cornerHeight), imageComposition: borderComposition, maskComposition: composition)
        
        /* Draw the background */
        
        /* From top to bottom */
        drawing.drawRectangle(Rectangle(top: rectangle.top, left: rectangle.left + cornerWidth, bottom: rectangle.bottom, right: rectangle.right - cornerWidth), composition: composition)
        
        /* Left Side */
        drawing.drawRectangle(Rectangle(top: rectangle.top + cornerHeight, left: rectangle.left, bottom: rectangle.bottom - cornerHeight, right: rectangle.left + cornerWidth), composition: composition)
        
        /* Right side */
        drawing.drawRectangle(Rectangle(top: rectangle.top + cornerHeight, left: rectangle.right - cornerWidth, bottom: rectangle.bottom - cornerHeight, right: rectangle.right), composition: composition)
        
        /* Draw the borders */
        
        /* Top */
        drawing.drawRectangle(Rectangle(top: rectangle.top, left: rectangle.left + cornerWidth, bottom: rectangle.top + borderThickness.top, right: rectangle.right - cornerWidth), composition: borderComposition)
        
        /* Left */
        drawing.drawRectangle(Rectangle(top: rectangle.top + cornerHeight, left: rectangle.left, bottom: rectangle.bottom - cornerHeight, right: rectangle.left + borderThickness.left), composition: borderComposition)
        
        /* Right */
        drawing.drawRectangle(Rectangle(top: rectangle.top + cornerHeight, left: rectangle.right - borderThickness.right, bottom: rectangle.bottom - cornerHeight, right: rectangle.right), composition: borderComposition)
        
        /* Bottom */
        drawing.drawRectangle(Rectangle(top: rectangle.bottom-borderThickness.bottom, left: rectangle.left + cornerWidth, bottom: rectangle.bottom, right: rectangle.right - cornerWidth), composition: borderComposition)
        
    }
    
    private func drawCheckBoxButton(in drawing: Drawing) {
        
        /* Get the interface elements to draw the part */
        let (frameImage, hiliteImage, _) = findCheckBoxImages()
        
        let rectangle = button.rectangle
        
        /* Draw the image */
        let imagePosition = Point(x: rectangle.x + 3, y: rectangle.y + rectangle.height / 2 - frameImage.height / 2)
        drawing.drawMaskedImage(frameImage, position: imagePosition)
        if hiliteComputation.value {
            let composition = (button.style == .radio && !button.enabled) ? disabledComposition : Drawing.DirectComposition
            drawing.drawMaskedImage(hiliteImage, position: imagePosition, imageComposition: composition)
        }
        
        /* Draw the title */
        if button.showName {
            let nameX = rectangle.x + 19
            let nameY = rectangle.y + rectangle.height / 2 + font.maximumAscent / 2 - 1
            drawing.drawString(button.name, position: Point(x: nameX, y: nameY), font: font, clip: rectangle)
            if !button.enabled {
                let nameWidth = font.computeSizeOfString(button.name)
                drawing.drawRectangle(Rectangle(top: nameY - font.maximumAscent, left: nameX - 2, bottom: nameY + font.maximumDescent, right: nameX + nameWidth + 2), clipRectangle: rectangle, composition: blackToGrayComposition)
            }
        }
        
    }
    
    private func findCheckBoxImages() -> (frame: MaskedImage, hilite: MaskedImage, click: MaskedImage) {
        
        switch button.style {
            
        case .checkBox:
            return (checkBoxFrame, checkBoxHilite, checkBoxClick)
            
        case .radio:
            return (radioFrame, radioHilite, radioClick)
            
        default:
            fatalError()
        }
        
    }
    
    private func drawPopupButton(in drawing: Drawing) {
        
        let rectangle = button.rectangle
        
        /* Draw the title */
        let baseLineY = rectangle.y + rectangle.height / 2 + font.maximumAscent / 2 - 2
        let titleBackgroundRectangle = Rectangle(top: baseLineY - font.maximumAscent, left: rectangle.left, bottom: baseLineY + font.maximumDescent + 1, right: rectangle.left + button.titleWidth)
        if button.showName {
            drawing.drawRectangle(titleBackgroundRectangle, composition: Drawing.MaskComposition)
            drawing.drawString(button.name, index: 0, length: nil, position: Point(x: rectangle.left + 4, y: baseLineY), font: font, clip: rectangle)
        }
        
        /* Get the size of the frame */
        let popupRectangle = Rectangle(top: rectangle.top, left: rectangle.left + button.titleWidth, bottom: rectangle.bottom, right: rectangle.right)
        if popupRectangle.width <= 0 {
            return
        }
        
        /* Draw the borders */
        drawing.drawShadowedRectangle(popupRectangle, thickness: buttonShadowThickness, shift: buttonShadowShift)
        
        /* Draw the arrow */
        let arrowX = (popupRectangle.width > 22) ? popupRectangle.right - popupArrowDistanceFromBorder : popupRectangle.left + popupRectangle.width / 2 - popupArrowImage.width / 2 - 1
        drawing.drawMaskedImage(popupArrowImage, position: Point(x: arrowX, y: popupRectangle.top + (popupRectangle.height - popupArrowHeight)/2), clipRectangle: popupRectangle)
        
        if menuItems.count > button.selectedItem && button.selectedItem >= 0 {
            /* Draw the text */
            
            /* Get the line */
            let text = menuItems[button.selectedItem]
            
            /* Fit it into the button margins */
            let (textToDraw, currentFont) = fitPopupText(text, buttonWidth: popupRectangle.width)
            
            /* Draw it */
            drawing.drawString(textToDraw, position: Point(x: popupRectangle.x + popupTextLeftMargin, y: baseLineY), font: currentFont, clip: popupRectangle)
        }
        
        
        /* Enabled / disabled */
        if !button.enabled {
            if button.showName {
                drawing.drawRectangle(titleBackgroundRectangle, composition: blackToGrayComposition)
            }
            drawing.drawRectangle(popupRectangle, composition: blackToGrayComposition)
        }
        
    }
    
    private func fitPopupText(_ text: HString, buttonWidth: Int) -> (textToDraw: HString, font: BitmapFont) {
        
        /* Check if the text already fits */
        let size = font.computeSizeOfString(text)
        if size < buttonWidth - popupTextLeftMargin - popupTextRightMargin {
            return (text, font)
        }
        
        /* Check if it fits with condensed font */
        let condensedSize = condensedFont.computeSizeOfString(text)
        if condensedSize < buttonWidth - popupTextLeftMargin - popupTextRightMargin {
            return (text, condensedFont)
        }
        
        /* Truncate the text until it works */
        var truncatedText = text
        while truncatedText.length > 2 {
            
            /* Truncate */
            truncatedText[(truncatedText.length-2)...(truncatedText.length-1)] = popupEllipsis
            
            /* Try to draw */
            let truncatedSize = condensedFont.computeSizeOfString(truncatedText)
            if truncatedSize < buttonWidth - popupTextLeftMargin - popupTextRightMargin {
                return (truncatedText, condensedFont)
            }
            
        }
        
        /* At that point, the button is too short to draw any text */
        return ("", font)
        
    }
    
    public override var rectangle: Rectangle? {
        
        /* If the view is invisible, do not reserve a rectangle */
        guard button.visible else {
            return nil
        }
        
        return button.rectangle
    }
    
    public override var usesXorComposition: Bool {
        
        return (button.style == .transparent || button.style == .oval) &&
        button.iconIdentifier == 0 && button.hilite
        
    }
    
    public func doesRespondToMouseEvent(at position: Point) -> Bool {
        
        guard button.visible else {
            return false
        }
        
        return button.rectangle.containsPosition(position)
    }
    
    public func respondToMouseEvent(_ mouseEvent: MouseEvent, at position: Point) {
        
    }
    
    /// Little hack to allow the Cocoa view to display a contextual menu for us
    public var popupItems: [HString]? {
        if button.style == .popup {
            return self.menuItems
        }
        return nil
    }
    
    /// Little hack to allow the Cocoa view to display a contextual menu for us
    public var selectedIndex: Int {
        get {
            return self.button.selectedItem
        }
        set {
            self.button.selectedItem = newValue
        }
    }
    
}

