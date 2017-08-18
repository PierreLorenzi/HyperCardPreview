//
//  PartView.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 02/03/2017.
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


private struct BorderThickness {
    var top: Int
    var left: Int
    var bottom: Int
    var right: Int
}
private let RoundRectBorderThickness = BorderThickness(top: 1, left: 1, bottom: 2, right: 2)
private let StandardBorderThickness = BorderThickness(top: 1, left: 1, bottom: 1, right: 1)
private let DefaultBorderThickness = BorderThickness(top: 3, left: 3, bottom: 3, right: 3)




/// A view of a regular button: transparent, opaque, rectangle, shadow, standard, default, round rect,
/// oval.
public class RegularButtonView: View {
    
    /// The 2D position of the view
    public var rectangle: Rectangle     = Rectangle(top: 0, left: 0, bottom: 0, right: 0)
    
    /// The name being displayed
    public var name: HString            = ""
    
    /// Whether the name is visible or not
    public var showName: Bool           = true
    
    /// The visual style of the view
    public var style: PartStyle         = .transparent

    /// The icon to display next to the name
    public var icon: MaskedImage?       = nil
    
    /// Whether the view is hilited. A hilited button has inverted colors.
    public var hilite: Bool             = false
    
    /// Whether the view is enabled. A disabled button is drawn gray.
    public var enabled: Bool            = true
    
    /// Whether the view is visible
    public var visible: Bool            = true
    
    /// The alignment of the name
    public var alignment: TextAlign     = .center
    
    /// The font of the name
    public var font: BitmapFont         = BitmapFont()
    
    public override func draw(in drawing: Drawing) {
        
        guard visible else {
            return
        }
        
        /* Define some usual compositions */
        let isTransparent = style == .transparent || style == .oval
        let titleComposition = findTitleComposition()
        let backgroundComposition = findBackgroundComposition()
        
        /* Draw the frame */
        drawButtonFrame(drawing: drawing)
        
        /* Special case: default button */
        if style == .`default` {
            let standardRectangle = Rectangle(top: rectangle.top + DefaultMargin, left: rectangle.left + DefaultMargin, bottom: rectangle.bottom - DefaultMargin, right: rectangle.right - DefaultMargin)
            let initialRectangle = self.rectangle
            style = .standard
            rectangle = standardRectangle
            draw(in: drawing)
            style = .`default`
            rectangle = initialRectangle
            return
        }
        
        /* Draw title & icon */
        if showName && icon == nil {
            let nameWidth = font.computeSizeOfString(name)
            let nameX = computeNameX(nameWidth: nameWidth)
            let nameY = rectangle.y + (rectangle.height - 1) / 2 + font.maximumAscent / 2 - 1
            drawing.drawString(name, position: Point(x: nameX, y: nameY), font: font, clip: rectangle, composition: titleComposition)
            if !enabled {
                drawing.drawRectangle(Rectangle(top: nameY - font.maximumAscent, left: nameX - 2, bottom: nameY + font.maximumDescent, right: nameX + nameWidth + 2), clipRectangle: rectangle, composition: BlackToGrayComposition)
            }
        }
        else if let icon = icon {
            let iconAndTitleHeight = (showName) ? IconSize + IconNameButtonMargin + font.maximumAscent + font.maximumDescent + 1 : IconSize + 2
            let iconAndTitleOrigin = rectangle.height / 2 - iconAndTitleHeight / 2 + 1
            if showName {
                let nameWidth = font.computeSizeOfString(name)
                let nameX = computeNameX(nameWidth: nameWidth)
                let nameY = rectangle.y + iconAndTitleOrigin + IconSize + IconNameButtonMargin + font.maximumAscent - 1
                if isTransparent {
                    drawing.drawRectangle(Rectangle(top: nameY - font.maximumAscent, left: nameX - 2, bottom: nameY + font.maximumDescent, right: nameX + nameWidth + 2), clipRectangle: rectangle, composition: backgroundComposition)
                }
                drawing.drawString(name, position: Point(x: nameX, y: nameY), font: font, clip: rectangle, composition: titleComposition)
                if !enabled {
                    drawing.drawRectangle(Rectangle(top: nameY - font.maximumAscent, left: nameX - 2, bottom: nameY + font.maximumDescent, right: nameX + nameWidth + 2), clipRectangle: rectangle, composition: BlackToGrayComposition)
                }
            }
            let iconX = rectangle.width / 2 - IconSize / 2
            let (imageComposition, maskComposition) = findIconComposition()
            drawing.drawMaskedImage(icon, position: Point(x: rectangle.x + iconX, y: rectangle.y + iconAndTitleOrigin), clipRectangle: rectangle, imageComposition: imageComposition, maskComposition: maskComposition)
        }
        
    }
    
    private func findTitleComposition() -> ImageComposition {
        
        let transparent = style == .transparent || style == .oval
        
        if hilite && transparent {
            return Drawing.XorComposition
        }
        
        /* Special case: hilited
         Even if the button is disabled, the text must be drawn in white on the gray background */
        if hilite {
            return Drawing.MaskComposition
        }
        
        /* Normal composition */
        return Drawing.DirectComposition
        
    }
    
    private func findBackgroundComposition() -> ImageComposition {
        
        /* Special case: disabled */
        if !enabled && hilite {
            return DisabledComposition
        }
        
        /* Second special case: hilited */
        if hilite {
            return Drawing.DirectComposition
        }
        
        /* Normal composition */
        return Drawing.MaskComposition
        
    }
    
    private func drawButtonFrame(drawing: Drawing) {
        
        let backgroundComposition = findBackgroundComposition()
        
        switch style {
        case .transparent:
            if icon == nil {
                if hilite {
                    drawing.drawRectangle(rectangle, composition: Drawing.XorComposition)
                }
                if !enabled {
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
            let borderComposition = (enabled) ? Drawing.DirectComposition : DisabledComposition
            drawCornerImage(DefaultCornerImage, rectangle: rectangle, drawing: drawing, borderThickness: DefaultBorderThickness, borderComposition: borderComposition, composition:Drawing.MaskComposition)
        case .oval:
            if hilite && icon == nil && rectangle.width > 0 && rectangle.height > 0 {
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
                    if !enabled {
                        drawing.drawRectangle(rowRectangle, composition: BlackToGrayComposition)
                    }
                }
            }
            
        default:
            break
        }
        
    }
    
    private func findIconComposition() -> (ImageComposition?, ImageComposition?) {
        
        let transparent = style == .transparent || style == .oval
        
        if transparent {
            if hilite {
                return (enabled ? Drawing.MaskComposition : DisabledComposition, Drawing.DirectComposition)
            }
            else {
                return (enabled ? Drawing.DirectComposition : DisabledComposition, Drawing.MaskComposition)
            }
        }
        else {
            return (enabled ? Drawing.XorComposition : DisabledComposition, nil)
        }
        
    }
    
    private func computeNameX(nameWidth: Int) -> Int {
        
        switch alignment {
            
        case .left:
            return rectangle.x + ButtonMargin
            
        case .center:
            return rectangle.x + rectangle.width / 2 - nameWidth / 2
            
        case .right:
            return rectangle.right - ButtonMargin - nameWidth
            
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
    
}
