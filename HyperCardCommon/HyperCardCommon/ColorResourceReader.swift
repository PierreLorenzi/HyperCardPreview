//
//  ColorResourceReader.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 05/06/2018.
//  Copyright © 2018 Pierre Lorenzi. All rights reserved.
//


/// Reads inside the data of an AddColor resource
public struct ColorResourceReader {
    
    private let data: DataRange
    
    public init(data: DataRange) {
        self.data = data
    }
    
    /// Reads the color declarations
    public func readElements() -> [AddColorElement] {
        
        var offset = 0
        var elements: [AddColorElement] = []
        
        while offset < data.length {
            
            let element = self.readElement(at: &offset)
            elements.append(element)
        }
        
        return elements
    }
    
    private func readElement(at offset: inout Int) -> AddColorElement {
        
        let typeAndFlags = data.readUInt8(at: offset)
        let type = typeAndFlags & 0x7F
        let enabled = ((typeAndFlags >> 7) & 1) == 0
        
        switch type {
            
        case 1: // button
            let identifier = data.readUInt16(at: offset + 0x1)
            let bevel = data.readUInt16(at: offset + 0x3)
            let color = self.readColor(at: offset + 0x5)
            offset += 11
            let element = AddColorButton(buttonIdentifier: identifier, bevel: bevel, color: color, enabled: enabled)
            return AddColorElement.button(element)
            
        case 2: // field
            let identifier = data.readUInt16(at: offset + 0x1)
            let bevel = data.readUInt16(at: offset + 0x3)
            let color = self.readColor(at: offset + 0x5)
            offset += 11
            let element = AddColorField(fieldIdentifier: identifier, bevel: bevel, color: color, enabled: enabled)
            return AddColorElement.field(element)
            
        case 3: // rectangle
            let rectangle = data.readRectangle(at: offset + 0x1)
            let bevel = data.readUInt16(at: offset + 0x9)
            let color = self.readColor(at: offset + 0xB)
            offset += 17
            let element = AddColorRectangle(rectangle: rectangle, bevel: bevel, color: color, enabled: enabled)
            return AddColorElement.rectangle(element)
            
        case 4: // picture resource
            let rectangle = data.readRectangle(at: offset + 0x1)
            let transparentValue = data.readUInt8(at: offset + 0x9)
            let nameLength = data.readUInt8(at: offset + 0xA)
            let name = data.readString(at: offset + 0xB, length: nameLength)
            offset += 11 + name.length
            
            let transparent = (transparentValue != 0)
            let element = AddColorPictureResource(rectangle: rectangle, transparent: transparent, resourceName: name, enabled: enabled)
            return AddColorElement.pictureResource(element)
            
        case 5:  // picture file
            let rectangle = data.readRectangle(at: offset + 0x1)
            let transparentValue = data.readUInt8(at: offset + 0x9)
            let nameLength = data.readUInt8(at: offset + 0xA)
            let name = data.readString(at: offset + 0xB, length: nameLength)
            offset += 11 + name.length
            
            let transparent = (transparentValue != 0)
            let element = AddColorPictureFile(rectangle: rectangle, transparent: transparent, fileName: name, enabled: enabled)
            return AddColorElement.pictureFile(element)
            
        default:
            fatalError()
        }
        
    }
    
    private func readColor(at offset: Int) -> AddColor {
        
        /* Read the values */
        let red16Bits = data.readUInt16(at: offset)
        let green16Bits = data.readUInt16(at: offset + 2)
        let blue16Bits = data.readUInt16(at: offset + 4)
        
        /* Convert to double */
        let factor = Double(UInt16.max)
        let red = Double(red16Bits) / factor
        let green = Double(green16Bits) / factor
        let blue = Double(blue16Bits) / factor
        
        return AddColor(red: red, green: green, blue: blue)
    }
    
}
