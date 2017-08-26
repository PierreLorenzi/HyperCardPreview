//
//  AddColorResourceBlock.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 26/08/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


public struct AddColor {
    public var red: Double
    public var green: Double
    public var blue: Double
}

public enum AddColorElement {
    
    case button(identifier: Int, bevel: Int, color: AddColor)
    case field(identifier: Int, bevel: Int, color: AddColor)
    case rectangle(rectangle: Rectangle, bevel: Int, color: AddColor)
    case pictResource(rectangle: Rectangle, transparent: Bool, name: HString)
    case pictFile(rectangle: Rectangle, transparent: Bool, name: HString)
}



public class AddColorResourceBlock: ResourceBlock {
    
    public var elements: [AddColorElement] {
        
        var offset = 0
        var elements: [AddColorElement] = []
        
        while offset < data.length {
            
            let element = self.readElement(at: &offset)
            elements.append(element)
        }
        
        return elements
    }
    
    private func readElement(at offset: inout Int) -> AddColorElement {
        
        let type = data.readUInt8(at: offset)
        
        switch type {
        
        case 1:
            let identifier = data.readUInt16(at: offset + 0x1)
            let bevel = data.readUInt16(at: offset + 0x3)
            let color = self.readColor(at: offset + 0x5)
            offset += 11
            return AddColorElement.button(identifier: identifier, bevel: bevel, color: color)
            
        case 2:
            let identifier = data.readUInt16(at: offset + 0x1)
            let bevel = data.readUInt16(at: offset + 0x3)
            let color = self.readColor(at: offset + 0x5)
            offset += 11
            return AddColorElement.field(identifier: identifier, bevel: bevel, color: color)
            
        case 3:
            let rectangle = data.readRectangle(at: offset + 0x1)
            let bevel = data.readUInt16(at: offset + 0x9)
            let color = self.readColor(at: offset + 0xB)
            offset += 17
            return AddColorElement.rectangle(rectangle: rectangle, bevel: bevel, color: color)
            
        case 4:
            let rectangle = data.readRectangle(at: offset + 0x1)
            let transparentValue = data.readUInt8(at: offset + 0x9)
            let nameLength = data.readUInt8(at: offset + 0xA)
            let name = data.readString(at: offset + 0xB, length: nameLength)
            offset += 11 + name.length
            
            let transparent = (transparentValue != 0)
            return AddColorElement.pictResource(rectangle: rectangle, transparent: transparent, name: name)
            
        case 5:
            let rectangle = data.readRectangle(at: offset + 0x1)
            let transparentValue = data.readUInt8(at: offset + 0x9)
            let nameLength = data.readUInt8(at: offset + 0xA)
            let name = data.readString(at: offset + 0xB, length: nameLength)
            offset += 11 + name.length
            
            let transparent = (transparentValue != 0)
            return AddColorElement.pictFile(rectangle: rectangle, transparent: transparent, name: name)
            
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

public class AddColorResourceBlockCard: AddColorResourceBlock {
    
    public override class var Name: NumericName {
        return NumericName(string: "HCcd")!
    }
    
}

public class AddColorResourceBlockBackground: AddColorResourceBlock {
    
    public override class var Name: NumericName {
        return NumericName(string: "HCbg")!
    }
    
}

