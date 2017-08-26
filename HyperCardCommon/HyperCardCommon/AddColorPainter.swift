//
//  AddColorPainter.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 26/08/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


import CoreGraphics


/// Paints AddColor resources on the RGB image of a card.
/// Does not support bevel and images
public class AddColorPainter {
    
    /// Alpha applied to transparent fields and buttons
    private static let transparentPartAlpha = 0.63
    
    public static func paintAddColor(ofStack stack: Stack, atCardIndex cardIndex: Int, excludeCardParts: Bool, onContext context: CGContext) {
        
        /* Check if there are resources */
        guard let resources = stack.resources?.resources else {
            return
        }
        
        /* Check if there are AddColor resources */
        guard let _ = resources.first(where: { $0 is Resource<[AddColorElement]> }) else {
            return
        }
        
        /* Do not antialias */
        context.setShouldAntialias(false)
        
        /* Get card and background */
        let card = stack.cards[cardIndex]
        let background = card.background
        
        /* Background */
        let backgroundElements = findAddColorResource(withType: ResourceTypes.backgroundColor, identifier: background.identifier, among: resources)
        if let elements = backgroundElements {
            AddColorPainter.paintAddColorElements(elements, ofLayer: background, onContext: context, resources: resources)
        }
        
        /* Card */
        if !excludeCardParts {
            let cardElements = findAddColorResource(withType: ResourceTypes.cardColor, identifier: card.identifier, among: resources)
            if let elements = cardElements {
                AddColorPainter.paintAddColorElements(elements, ofLayer: card, onContext: context, resources: resources)
            }
        }
        
    }
    
    private static func findAddColorResource(withType type: ResourceType<[AddColorElement]>, identifier: Int, among resources: [Any]) -> [AddColorElement]? {
        
        for resource in resources {
            
            /* Check that's an AddColor Resource */
            guard let addColorResource = resource as? Resource<[AddColorElement]> else {
                continue
            }
            
            /* Check that's the one requested */
            guard addColorResource.type === type && addColorResource.identifier == identifier else {
                continue
            }
            
            return addColorResource.content
        }
        
        return nil
    }
    
    private static func paintAddColorElements(_ elements: [AddColorElement], ofLayer layer: Layer, onContext context: CGContext, resources: [Any]) {
        
        for element in elements {
            
            switch element {
                
            case .button(let element):
                
                /* Do not display the element if it is disabled */
                guard element.enabled else {
                    break
                }
                
                /* Find the button */
                guard let button = layer.buttons.first(where: { $0.identifier == element.buttonIdentifier }) else {
                    break
                }
                
                /* Paint the button */
                paintButton(button, withBevel: element.bevel, color: element.color, onContext: context)
                
            case .field(let element):
                
                /* Do not display the element if it is disabled */
                guard element.enabled else {
                    break
                }
                
                /* Find the button */
                guard let field = layer.fields.first(where: { $0.identifier == element.fieldIdentifier }) else {
                    break
                }
                
                /* Paint the button */
                paintField(field, withBevel: element.bevel, color: element.color, onContext: context)
                
            case .rectangle(let element):
                
                /* Do not display the element if it is disabled */
                guard element.enabled else {
                    break
                }
                
                paintRectangle(element.rectangle, withBevel: element.bevel, color: element.color, alpha: 1.0, onContext: context)
                
            case .pictureResource(let element):
                
                /* Do not display the element if it is disabled */
                guard element.enabled else {
                    break
                }
                
                paintPicture(name: element.resourceName, rectangle: element.rectangle, transparent: element.transparent, onContext: context, resources: resources)
                
            default:
                break
            }
        }
    }
    
    private static func paintButton(_ button: Button, withBevel bevel: Int, color: AddColor, onContext context: CGContext) {
        
        switch button.style {
            
        case .transparent:
            paintRectangle(button.rectangle, withBevel: bevel, color: color, alpha: transparentPartAlpha, onContext: context)
            
        case .opaque, .rectangle, .checkBox, .radio:
            paintRectangle(button.rectangle, withBevel: bevel, color: color, alpha: 1.0, onContext: context)
            
        case .shadow, .popup:
            let rectangle = button.rectangle
            let rectangleWithoutShadow = Rectangle(top: rectangle.top, left: rectangle.left, bottom: rectangle.bottom - 1, right: rectangle.right - 1)
            paintRectangle(rectangleWithoutShadow, withBevel: bevel, color: color, alpha: 1.0, onContext: context)
            
        case .standard, .`default`:
            let rectangle = (button.style == .standard) ? button.rectangle : Rectangle(top: button.rectangle.top+4, left: button.rectangle.left + 4, bottom: button.rectangle.bottom - 4, right: button.rectangle.right - 4)
            let rectangleTop0 = Rectangle(top: rectangle.top + 1, left: rectangle.left + 3, bottom: rectangle.top + 2, right: rectangle.right - 3)
            let rectangleTop1 = Rectangle(top: rectangle.top + 2, left: rectangle.left + 2, bottom: rectangle.top + 3, right: rectangle.right - 2)
            let rectangleCenter = Rectangle(top: rectangle.top + 3, left: rectangle.left + 1, bottom: rectangle.bottom - 3, right: rectangle.right - 1)
            let rectangleBottom1 = Rectangle(top: rectangle.bottom - 3, left: rectangle.left + 2, bottom: rectangle.bottom - 2, right: rectangle.right - 2)
            let rectangleBottom0 = Rectangle(top: rectangle.bottom - 2, left: rectangle.left + 3, bottom: rectangle.bottom - 1, right: rectangle.right - 3)
            paintRectangle(rectangleTop0, withBevel: bevel, color: color, alpha: 1.0, onContext: context)
            paintRectangle(rectangleTop1, withBevel: bevel, color: color, alpha: 1.0, onContext: context)
            paintRectangle(rectangleCenter, withBevel: bevel, color: color, alpha: 1.0, onContext: context)
            paintRectangle(rectangleBottom1, withBevel: bevel, color: color, alpha: 1.0, onContext: context)
            paintRectangle(rectangleBottom0, withBevel: bevel, color: color, alpha: 1.0, onContext: context)
            
        case .roundRect:
            let rectangle = button.rectangle
            let rectangleTop0 = Rectangle(top: rectangle.top + 1, left: rectangle.left + 5, bottom: rectangle.top + 2, right: rectangle.right - 5)
            let rectangleTop1 = Rectangle(top: rectangle.top + 2, left: rectangle.left + 3, bottom: rectangle.top + 3, right: rectangle.right - 3)
            let rectangleTop2 = Rectangle(top: rectangle.top + 3, left: rectangle.left + 2, bottom: rectangle.top + 5, right: rectangle.right - 2)
            let rectangleCenter = Rectangle(top: rectangle.top + 5, left: rectangle.left + 1, bottom: rectangle.bottom - 5, right: rectangle.right - 1)
            let rectangleBottom2 = Rectangle(top: rectangle.bottom - 5, left: rectangle.left + 2, bottom: rectangle.bottom - 3, right: rectangle.right - 2)
            let rectangleBottom1 = Rectangle(top: rectangle.bottom - 3, left: rectangle.left + 3, bottom: rectangle.bottom - 2, right: rectangle.right - 3)
            let rectangleBottom0 = Rectangle(top: rectangle.bottom - 2, left: rectangle.left + 5, bottom: rectangle.bottom - 1, right: rectangle.right - 5)
            paintRectangle(rectangleTop0, withBevel: bevel, color: color, alpha: 1.0, onContext: context)
            paintRectangle(rectangleTop1, withBevel: bevel, color: color, alpha: 1.0, onContext: context)
            paintRectangle(rectangleTop2, withBevel: bevel, color: color, alpha: 1.0, onContext: context)
            paintRectangle(rectangleCenter, withBevel: bevel, color: color, alpha: 1.0, onContext: context)
            paintRectangle(rectangleBottom2, withBevel: bevel, color: color, alpha: 1.0, onContext: context)
            paintRectangle(rectangleBottom1, withBevel: bevel, color: color, alpha: 1.0, onContext: context)
            paintRectangle(rectangleBottom0, withBevel: bevel, color: color, alpha: 1.0, onContext: context)
            
        case .oval:
            paintCircle(button.rectangle, withBevel: bevel, color: color, alpha: 1.0, onContext: context)
            
        default:
            break
            
        }
    }
    
    private static func paintRectangle(_ rectangle: Rectangle, withBevel bevel: Int, color: AddColor, alpha: Double, onContext context: CGContext) {
        
        /* Convert values to CoreGraphics */
        let cgColor = CGColor(red: CGFloat(color.red), green: CGFloat(color.green), blue: CGFloat(color.blue), alpha: CGFloat(alpha))
        let cgRectangle = CGRect(x: Double(rectangle.left), y: Double(rectangle.top), width: Double(rectangle.width), height: Double(rectangle.height))
        
        /* Fill the resct */
        context.setFillColor(cgColor)
        context.fill(cgRectangle)
        
    }
    
    private static func paintCircle(_ rectangle: Rectangle, withBevel bevel: Int, color: AddColor, alpha: Double, onContext context: CGContext) {
        
        /* Convert values to CoreGraphics */
        let cgColor = CGColor(red: CGFloat(color.red), green: CGFloat(color.green), blue: CGFloat(color.blue), alpha: CGFloat(alpha))
        let cgRectangle = CGRect(x: Double(rectangle.left), y: Double(rectangle.top), width: Double(rectangle.width), height: Double(rectangle.height))
        
        /* Fill the resct */
        context.setFillColor(cgColor)
        context.fillEllipse(in: cgRectangle)
        
    }
    
    private static func paintField(_ field: Field, withBevel bevel: Int, color: AddColor, onContext context: CGContext) {
        
        switch field.style {
            
        case .transparent:
            paintRectangle(field.rectangle, withBevel: bevel, color: color, alpha: transparentPartAlpha, onContext: context)
            
        case .opaque, .rectangle, .scrolling:
            paintRectangle(field.rectangle, withBevel: bevel, color: color, alpha: 1.0, onContext: context)
            
        case .shadow:
            let rectangle = field.rectangle
            let rectangleWithoutShadow = Rectangle(top: rectangle.top, left: rectangle.left, bottom: rectangle.bottom - 2, right: rectangle.right - 2)
            paintRectangle(rectangleWithoutShadow, withBevel: bevel, color: color, alpha: 1.0, onContext: context)
            
        default:
            break
        }
    }
    
    private static func paintPicture(name: HString, rectangle: Rectangle, transparent: Bool, onContext context: CGContext, resources: [Any]) {
        
        /* Find the resource */
        guard let image = findPictureResource(withName: name, among: resources) else {
            return
        }
        
        /* Draw the image */
        let cocoaContext = NSGraphicsContext(cgContext: context, flipped: true)
        let currentContext = NSGraphicsContext.current()
        NSGraphicsContext.setCurrent(cocoaContext)
        image.draw(in: NSRect(x: rectangle.left, y: rectangle.top, width: rectangle.width, height: rectangle.height))
        NSGraphicsContext.setCurrent(currentContext)
        
    }
    
    private static func findPictureResource(withName name: HString, among resources: [Any]) -> NSImage? {
        
        for resource in resources {
            
            /* Check that's a picture resource */
            guard let pictureResource = resource as? Resource<NSImage> else {
                continue
            }
            
            /* Check that's the one requested */
            guard pictureResource.type === ResourceTypes.picture && pictureResource.name == name else {
                continue
            }
            
            return pictureResource.content
        }
        
        return nil
    }
    
}
