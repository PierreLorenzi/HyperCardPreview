//
//  CheckBoxButtonView.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 03/03/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//



private let CheckBoxFrame = MaskedImage(named: "checkbox frame")!
private let CheckBoxHilite = MaskedImage(named: "checkbox hilite")!
private let CheckBoxClick = MaskedImage(named: "checkbox click")!

private let RadioFrame = MaskedImage(named: "radio frame")!
private let RadioHilite = MaskedImage(named: "radio hilite")!
private let RadioClick = MaskedImage(named: "radio click")!



/// A view of a check-box or radio button
public class CheckBoxButtonView: View {
    
    /// The 2D position of the view
    public var rectangle: Rectangle     = Rectangle(top: 0, left: 0, bottom: 0, right: 0)
    
    /// The name to display
    public var name: HString            = ""
    
    /// The font of the name
    public var font: BitmapFont         = BitmapFont()
    
    /// Whether the name is visible or not
    public var showName: Bool           = true
    
    /// The visual style of the view
    public var style: PartStyle         = .checkBox
    
    /// Whether the button is checked or not
    public var hilite: Bool             = false
    
    /// Whether the view is enabled or not. A disabled view is drawn gray.
    public var enabled: Bool            = true
    
    /// Whether the view is visible
    public var visible: Bool            = true

    
    public override func draw(in drawing: Drawing) {
        
        guard visible else {
            return
        }
        
        /* Get the interface elements to draw the part */
        let (frameImage, hiliteImage, _) = findImages()
                
        /* Draw the image */
        let imagePosition = Point(x: rectangle.x + 3, y: rectangle.y + rectangle.height / 2 - frameImage.height / 2)
        drawing.drawMaskedImage(frameImage, position: imagePosition)
        if hilite {
            let composition = (style == .radio && !enabled) ? DisabledComposition : Drawing.DirectComposition
            drawing.drawMaskedImage(hiliteImage, position: imagePosition, imageComposition: composition)
        }
        
        /* Draw the title */
        if showName {
            let nameX = rectangle.x + 19
            let nameY = rectangle.y + rectangle.height / 2 + font.maximumAscent / 2 - 1
            drawing.drawString(name, position: Point(x: nameX, y: nameY), font: font, clip: rectangle)
            if !enabled {
                let nameWidth = font.computeSizeOfString(name)
                drawing.drawRectangle(Rectangle(top: nameY - font.maximumAscent, left: nameX - 2, bottom: nameY + font.maximumDescent, right: nameX + nameWidth + 2), clipRectangle: rectangle, composition: BlackToGrayComposition)
            }
        }
        
    }
    
    private func findImages() -> (frame: MaskedImage, hilite: MaskedImage, click: MaskedImage) {
        
        switch style {
            
        case .checkBox:
            return (CheckBoxFrame, CheckBoxHilite, CheckBoxClick)
            
        case .radio:
            return (RadioFrame, RadioHilite, RadioClick)
            
        default:
            fatalError()
        }
        
    }
    
}
