//
//  ButtonView.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 21/08/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


private let ButtonMargin = 9
private let IconNameButtonMargin = 1

private let DefaultExteriorBorderSize = 3
private let DefaultMargin = 4

private struct CornerImage {
    var topLeft: MaskedImage
    var topRight: MaskedImage
    var bottomLeft: MaskedImage
    var bottomRight: MaskedImage
}
private let CornerSize = 8
private let TopLeftCornerName = "top left"
private let TopRightCornerName = "top right"
private let BottomLeftCornerName = "bottom left"
private let BottomRightCornerName = "bottom right"
private let RoundRectCornerImage = loadCornerImage(name: "roundrect")
private let StandardCornerImage = loadCornerImage(name: "standard")
private let DefaultCornerImage = loadCornerImage(name: "default")
private func loadCornerImage(name: String) -> CornerImage {
    
    /* Load the images */
    let topLeftImage = MaskedImage(named: "\(name) \(TopLeftCornerName)")!
    let topRightImage = MaskedImage(named: "\(name) \(TopRightCornerName)")!
    let bottomLeftImage = MaskedImage(named: "\(name) \(BottomLeftCornerName)")!
    let bottomRightImage = MaskedImage(named: "\(name) \(BottomRightCornerName)")!
    
    
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
private let RoundRectBorderThickness = BorderThickness(top: 1, left: 1, bottom: 2, right: 2)
private let StandardBorderThickness = BorderThickness(top: 1, left: 1, bottom: 1, right: 1)
private let DefaultBorderThickness = BorderThickness(top: 3, left: 3, bottom: 3, right: 3)

private let CheckBoxFrame = MaskedImage(named: "checkbox frame")!
private let CheckBoxHilite = MaskedImage(named: "checkbox hilite")!
private let CheckBoxClick = MaskedImage(named: "checkbox click")!

private let RadioFrame = MaskedImage(named: "radio frame")!
private let RadioHilite = MaskedImage(named: "radio hilite")!
private let RadioClick = MaskedImage(named: "radio click")!

private let PopupTextLeftMargin = 18
private let PopupTextRightMargin = 20
private let PopupEllipsis: HString = "…"
private let PopupArrowImage = MaskedImage(named: "popup arrow")!
private let PopupArrowDistanceFromBorder = 18
private let PopupArrowHeight = 6








public class ButtonView: View, MouseResponder {
    
    private let button: Button
    
    private let hiliteProperty: Property<Bool>
    
    /// the font for the texts
    private var font: BitmapFont {
        return fontProperty.value
    }
    private let fontProperty: Property<BitmapFont>
    
    /// the image of the icon
    private var icon: MaskedImage? {
        return iconProperty.value
    }
    private let iconProperty: Property<MaskedImage?>
    
    /// the menu items, used by pop-up buttons
    private var menuItems: [HString] {
        return menuItemsProperty.value
    }
    private let menuItemsProperty: Property<[HString]>
    
    /// the condensed version of the font, used by pop-up buttons
    private var condensedFont: BitmapFont {
        return condensedFontProperty.value
    }
    private let condensedFontProperty: Property<BitmapFont>
    
    public init(button: Button, hiliteProperty: Property<Bool>, fontManager: FontManager, resources: ResourceSystem) {
        
        self.button = button
        self.hiliteProperty = hiliteProperty
        
        /* font */
        fontProperty = Property<BitmapFont>(compute: {
            
            let hasIcon = ButtonView.hasButtonIcon(button)
            
            let fontIdentifier = hasIcon ? iconButtonFontIdentifier : button.textFontIdentifier
            let fontSize = hasIcon ? iconButtonFontSize : button.textFontSize
            let fontStyle = hasIcon ? iconButtonFontStyle : button.textStyle
            return fontManager.findFont(withIdentifier: fontIdentifier, size: fontSize, style: fontStyle)
        })
        
        /* condensedFont */
        condensedFontProperty = Property<BitmapFont>(compute: {
            
            var consensedStyle = button.textStyle
            consensedStyle.condense = true
            return fontManager.findFont(withIdentifier: button.textFontIdentifier, size: button.textFontSize, style: consensedStyle)
        })
        
        /* icon */
        let iconIdentifier = button.iconIdentifier
        iconProperty = Property<MaskedImage?>(compute: {
            
            guard iconIdentifier != 0 else {
                return nil
            }
            
            if let iconResource = resources.findResource(ofType: ResourceTypes.icon, withIdentifier: iconIdentifier) {
                return maskIcon(iconResource.content)
            }
            
            return nil
        })
        
        /* menuItems */
        menuItemsProperty = Property<[HString]>(compute: {
        
            return ButtonView.separateStringLines(in: button.content)
        })
        
        super.init()
        
        /* font dependencies */
        fontProperty.dependsOn(button.iconIdentifierProperty)
        fontProperty.dependsOn(button.textFontIdentifierProperty)
        fontProperty.dependsOn(button.textFontSizeProperty)
        fontProperty.dependsOn(button.textStyleProperty)
        
        /* condensedFont dependencies */
        condensedFontProperty.dependsOn(button.textFontIdentifierProperty)
        condensedFontProperty.dependsOn(button.textFontSizeProperty)
        condensedFontProperty.dependsOn(button.textStyleProperty)
        
        /* drawing dependencies */
        hiliteProperty.startNotifications(for: self, by: {
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
        let rectangle = button.rectangle
        drawButtonFrame(drawing: drawing)
        
        /* Special case: default button */
        if button.style == .`default` {
            let standardRectangle = Rectangle(top: rectangle.top + DefaultMargin, left: rectangle.left + DefaultMargin, bottom: rectangle.bottom - DefaultMargin, right: rectangle.right - DefaultMargin)
            let initialRectangle = rectangle
            button.style = .standard
            button.rectangle = standardRectangle
            draw(in: drawing)
            button.style = .`default`
            button.rectangle = initialRectangle
            return
        }
        
        /* Draw title & icon (if an icon is set but not found, the button is layout as if had an icon) */
        if button.showName && button.iconIdentifier == 0 {
            let nameWidth = font.computeSizeOfString(button.name)
            let nameX = computeNameX(nameWidth: nameWidth)
            let nameY = rectangle.y + rectangle.height / 2 + font.maximumAscent / 2 - font.maximumAscent / 6
            drawing.drawString(button.name, position: Point(x: nameX, y: nameY), font: font, clip: rectangle, composition: titleComposition)
            if !button.enabled {
                drawing.drawRectangle(Rectangle(top: nameY - font.maximumAscent, left: nameX - 2, bottom: nameY + font.maximumDescent, right: nameX + nameWidth + 2), clipRectangle: rectangle, composition: BlackToGrayComposition)
            }
        }
        else {
            let iconAndTitleHeight = (button.showName) ? IconSize + IconNameButtonMargin + font.maximumAscent + font.maximumDescent + 1 : IconSize + 2
            let iconAndTitleOrigin = rectangle.height / 2 - iconAndTitleHeight / 2 + 1
            if button.showName {
                let nameWidth = font.computeSizeOfString(button.name)
                let nameX = computeNameX(nameWidth: nameWidth)
                let nameY = rectangle.y + iconAndTitleOrigin + IconSize + IconNameButtonMargin + font.maximumAscent - 1
                if isTransparent {
                    drawing.drawRectangle(Rectangle(top: nameY - font.maximumAscent, left: nameX - 2, bottom: nameY + font.maximumDescent, right: nameX + nameWidth + 2), clipRectangle: rectangle, composition: backgroundComposition)
                }
                drawing.drawString(button.name, position: Point(x: nameX, y: nameY), font: font, clip: rectangle, composition: titleComposition)
                if !button.enabled {
                    drawing.drawRectangle(Rectangle(top: nameY - font.maximumAscent, left: nameX - 2, bottom: nameY + font.maximumDescent, right: nameX + nameWidth + 2), clipRectangle: rectangle, composition: BlackToGrayComposition)
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
        
        if hiliteProperty.value && transparent {
            return Drawing.XorComposition
        }
        
        /* Special case: hilited
         Even if the button is disabled, the text must be drawn in white on the gray background */
        if hiliteProperty.value {
            return Drawing.MaskComposition
        }
        
        /* Normal composition */
        return Drawing.DirectComposition
        
    }
    
    private func findBackgroundComposition() -> ImageComposition {
        
        /* Special case: disabled */
        if !button.enabled && hiliteProperty.value {
            return DisabledComposition
        }
        
        /* Second special case: hilited */
        if hiliteProperty.value {
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
                if hiliteProperty.value {
                    drawing.drawRectangle(rectangle, composition: Drawing.XorComposition)
                }
                if !button.enabled {
                    drawing.drawRectangle(rectangle, composition: BlackToGrayComposition)
                }
            }
        case .opaque:
            drawing.drawRectangle(rectangle, composition: backgroundComposition)
        case .rectangle:
            drawing.drawBorderedRectangle(rectangle, composition: backgroundComposition)
        case .shadow:
            drawing.drawShadowedRectangle(rectangle, thickness: ButtonShadowThickness, shift: ButtonShadowShift, composition: backgroundComposition)
        case .roundRect:
            drawCornerImage(RoundRectCornerImage, rectangle: rectangle, drawing: drawing, borderThickness: RoundRectBorderThickness, composition: backgroundComposition)
        case .standard:
            drawCornerImage(StandardCornerImage, rectangle: rectangle, drawing: drawing, borderThickness: StandardBorderThickness, composition: backgroundComposition)
        case .`default`:
            
            /* Draw the external border only, without hilite */
            let borderComposition = button.enabled ? Drawing.DirectComposition : DisabledComposition
            drawCornerImage(DefaultCornerImage, rectangle: rectangle, drawing: drawing, borderThickness: DefaultBorderThickness, borderComposition: borderComposition, composition:Drawing.MaskComposition)
        case .oval:
            if hiliteProperty.value && icon == nil && rectangle.width > 0 && rectangle.height > 0 {
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
                        drawing.drawRectangle(rowRectangle, composition: BlackToGrayComposition)
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
            if hiliteProperty.value {
                return (button.enabled ? Drawing.MaskComposition : DisabledComposition, Drawing.DirectComposition)
            }
            else {
                return (button.enabled ? Drawing.DirectComposition : DisabledComposition, Drawing.MaskComposition)
            }
        }
        else {
            return (button.enabled ? Drawing.XorComposition : DisabledComposition, nil)
        }
        
    }
    
    private func computeNameX(nameWidth: Int) -> Int {
        
        switch button.textAlign {
            
        case .left:
            return button.rectangle.x + ButtonMargin
            
        case .center:
            return button.rectangle.x + button.rectangle.width / 2 - nameWidth / 2
            
        case .right:
            return button.rectangle.right - ButtonMargin - nameWidth
            
        }
        
    }
    
    private func drawCornerImage(_ cornerImage: CornerImage, rectangle: Rectangle, drawing: Drawing, borderThickness: BorderThickness, borderComposition: @escaping ImageComposition = Drawing.DirectComposition, composition: @escaping ImageComposition) {
        
        /* If the button is too small, the border images must be clipped */
        let cornerWidth = min(CornerSize, rectangle.width / 2)
        let cornerHeight = min(CornerSize, rectangle.height / 2)
        
        /* Draw the images */
        drawing.drawMaskedImage(cornerImage.topLeft, position: Point(x: rectangle.x, y: rectangle.y), rectangleToDraw: Rectangle(x: 0, y: 0, width: cornerWidth , height: cornerHeight), imageComposition: borderComposition, maskComposition: composition)
        drawing.drawMaskedImage(cornerImage.topRight, position: Point(x: rectangle.right - cornerWidth, y: rectangle.y), rectangleToDraw: Rectangle(x: CornerSize - cornerWidth, y: 0, width: cornerWidth , height: cornerHeight), imageComposition: borderComposition, maskComposition: composition)
        drawing.drawMaskedImage(cornerImage.bottomLeft, position: Point(x: rectangle.x, y: rectangle.bottom - cornerHeight), rectangleToDraw: Rectangle(x: 0, y: CornerSize - cornerHeight, width: cornerWidth , height: cornerHeight), imageComposition: borderComposition, maskComposition: composition)
        drawing.drawMaskedImage(cornerImage.bottomRight, position: Point(x: rectangle.right - cornerWidth, y: rectangle.bottom - cornerHeight), rectangleToDraw: Rectangle(x: CornerSize - cornerWidth, y: CornerSize - cornerHeight, width: cornerWidth , height: cornerHeight), imageComposition: borderComposition, maskComposition: composition)
        
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
        if hiliteProperty.value {
            let composition = (button.style == .radio && !button.enabled) ? DisabledComposition : Drawing.DirectComposition
            drawing.drawMaskedImage(hiliteImage, position: imagePosition, imageComposition: composition)
        }
        
        /* Draw the title */
        if button.showName {
            let nameX = rectangle.x + 19
            let nameY = rectangle.y + rectangle.height / 2 + font.maximumAscent / 2 - 1
            drawing.drawString(button.name, position: Point(x: nameX, y: nameY), font: font, clip: rectangle)
            if !button.enabled {
                let nameWidth = font.computeSizeOfString(button.name)
                drawing.drawRectangle(Rectangle(top: nameY - font.maximumAscent, left: nameX - 2, bottom: nameY + font.maximumDescent, right: nameX + nameWidth + 2), clipRectangle: rectangle, composition: BlackToGrayComposition)
            }
        }
        
    }
    
    private func findCheckBoxImages() -> (frame: MaskedImage, hilite: MaskedImage, click: MaskedImage) {
        
        switch button.style {
            
        case .checkBox:
            return (CheckBoxFrame, CheckBoxHilite, CheckBoxClick)
            
        case .radio:
            return (RadioFrame, RadioHilite, RadioClick)
            
        default:
            fatalError()
        }
        
    }
    
    private func drawPopupButton(in drawing: Drawing) {
        
        let rectangle = button.rectangle
        
        /* Draw the title */
        let baseLineY = rectangle.y + rectangle.height / 2 + font.maximumAscent / 2 - 2
        if button.showName {
            drawing.drawString(button.name, index: 0, length: nil, position: Point(x: rectangle.left + 4, y: baseLineY), font: font, clip: rectangle)
        }
        
        /* Get the size of the frame */
        let popupRectangle = Rectangle(top: rectangle.top, left: rectangle.left + button.titleWidth, bottom: rectangle.bottom, right: rectangle.right)
        if popupRectangle.width <= 0 {
            return
        }
        
        /* Draw the borders */
        drawing.drawShadowedRectangle(popupRectangle, thickness: ButtonShadowThickness, shift: ButtonShadowShift)
        
        /* Draw the arrow */
        let arrowX = (popupRectangle.width > 22) ? popupRectangle.right - PopupArrowDistanceFromBorder : popupRectangle.left + popupRectangle.width / 2 - PopupArrowImage.width / 2 - 1
        drawing.drawMaskedImage(PopupArrowImage, position: Point(x: arrowX, y: popupRectangle.top + (popupRectangle.height - PopupArrowHeight)/2), clipRectangle: popupRectangle)
        
        if menuItems.count > button.selectedItem && button.selectedItem >= 0 {
            /* Draw the text */
            
            /* Get the line */
            let text = menuItems[button.selectedItem]
            
            /* Fit it into the button margins */
            let (textToDraw, currentFont) = fitPopupText(text, buttonWidth: popupRectangle.width)
            
            /* Draw it */
            drawing.drawString(textToDraw, position: Point(x: popupRectangle.x + PopupTextLeftMargin, y: baseLineY), font: currentFont, clip: popupRectangle)
        }
        
        
        /* Enabled / disabled */
        if !button.enabled {
            drawing.drawRectangle(popupRectangle, composition: BlackToGrayComposition)
        }
        
    }
    
    private func fitPopupText(_ text: HString, buttonWidth: Int) -> (textToDraw: HString, font: BitmapFont) {
        
        /* Check if the text already fits */
        let size = font.computeSizeOfString(text)
        if size < buttonWidth - PopupTextLeftMargin - PopupTextRightMargin {
            return (text, font)
        }
        
        /* Check if it fits with condensed font */
        let condensedSize = condensedFont.computeSizeOfString(text)
        if condensedSize < buttonWidth - PopupTextLeftMargin - PopupTextRightMargin {
            return (text, condensedFont)
        }
        
        /* Truncate the text until it works */
        var truncatedText = text
        while truncatedText.length > 2 {
            
            /* Truncate */
            truncatedText[(truncatedText.length-2)...(truncatedText.length-1)] = PopupEllipsis
            
            /* Try to draw */
            let truncatedSize = condensedFont.computeSizeOfString(truncatedText)
            if truncatedSize < buttonWidth - PopupTextLeftMargin - PopupTextRightMargin {
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

