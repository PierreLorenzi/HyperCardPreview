//
//  PopupButtonView.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 03/03/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//

private let PopupTextLeftMargin = 18
private let PopupTextRightMargin = 20
private let PopupEllipsis: HString = "…"
private let PopupArrowImage = MaskedImage(named: "popup arrow")!
private let PopupArrowDistanceFromBorder = 18
private let PopupArrowHeight = 6


/// A view of a pop-up button
public class PopupButtonView: View {
    
    /// The 2D position of the view
    public var rectangle: Rectangle         = Rectangle(top: 0, left: 0, bottom: 0, right: 0)
    
    /// The item names in the pop-up menu
    public var items: [HString]             = [""]
    
    /// The index of the selected item, which is displayed on the button
    public var selectedIndex: Int           = 0
    
    /// The title of the button, displayed on the left
    public var title: HString               = ""
    
    /// The width let to the title on the left, in pixels
    public var titleWidth: Int              = 0
    
    /// Whether or not the view is enabled.
    public var enabled: Bool                = true
    
    /// Whether or not the view is visible
    public var visible: Bool                = true
    
    /// The font for the title and the selected item
    public var font: BitmapFont             = BitmapFont()
    
    /// The condensed variant of the font, which can be used if there is not enough room
    public var condensedFont: BitmapFont    = BitmapFont()
    
    public override init() {}
    
    public override func draw(in drawing: Drawing) {
        
        guard visible else {
            return
        }
        
        /* Draw the title */
        let baseLineY = rectangle.y + rectangle.height / 2 + font.maximumAscent / 2 - 2
        drawing.drawString(title, index: 0, length: nil, position: Point(x: rectangle.left + 4, y: baseLineY), font: font, clip: rectangle)
        let popupRectangle = Rectangle(top: rectangle.top, left: rectangle.left + titleWidth, bottom: rectangle.bottom, right: rectangle.right)
        if popupRectangle.width <= 0 {
            return
        }
        
        /* Draw the borders */
        drawing.drawShadowedRectangle(popupRectangle, thickness: ButtonShadowThickness, shift: ButtonShadowShift)
        
        /* Draw the arrow */
        let arrowX = (popupRectangle.width > 22) ? popupRectangle.right - PopupArrowDistanceFromBorder : popupRectangle.left + popupRectangle.width / 2 - PopupArrowImage.width / 2 - 1
        drawing.drawMaskedImage(PopupArrowImage, position: Point(x: arrowX, y: popupRectangle.top + (popupRectangle.height - PopupArrowHeight)/2), clipRectangle: popupRectangle)
        
        if items.count > selectedIndex && selectedIndex >= 0 {
            /* Draw the text */

            /* Get the line */
            let text = items[selectedIndex]

            /* Fit it into the button margins */
            let (textToDraw, currentFont) = fitPopupText(text, buttonWidth: popupRectangle.width)

            /* Draw it */
            drawing.drawString(textToDraw, position: Point(x: popupRectangle.x + PopupTextLeftMargin, y: baseLineY), font: currentFont, clip: popupRectangle)
        }

        
        /* Enabled / disabled */
        if !enabled {
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
    
}
