//
//  PartBlock.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 26/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//

public class PartBlock: DataBlock {
    
    public var identifier: Int {
        return data.readUInt16(at: 0x2)
    }
    
    public var type: PartType {
        let flagTrue = data.readFlag(at: 0x4, bitOffset: 8)
        return flagTrue ? PartType.button : PartType.field
    }
    
    public var enabled: Bool {
        return !data.readFlag(at: 0x4, bitOffset: 0)
    }
    
    public var lockText: Bool {
        return data.readFlag(at: 0x4, bitOffset: 0)
    }
    
    public var autoTab: Bool {
        return data.readFlag(at: 0x4, bitOffset: 1)
    }
    
    public var fixedLineHeight: Bool {
        return !data.readFlag(at: 0x4, bitOffset: 2)
    }
    
    public var sharedText: Bool {
        return data.readFlag(at: 0x4, bitOffset: 3)
    }
    
    public var dontSearch: Bool {
        return data.readFlag(at: 0x4, bitOffset: 4)
    }
    
    public var dontWrap: Bool {
        return data.readFlag(at: 0x4, bitOffset: 5)
    }
    
    public var visible: Bool {
        return !data.readFlag(at: 0x4, bitOffset: 7)
    }
    
    public var rectangle: Rectangle {
        return data.readRectangle(at: 0x6)
    }
    
    public var family: Int {
        let flags = data.readUInt8(at: 0xE)
        let value = flags & 0b1111
        return value
    }
    
    public var sharedHilite: Bool {
        return !data.readFlag(at: 0xE, bitOffset: 12)
    }
    
    public var multipleLines: Bool {
        return data.readFlag(at: 0xE, bitOffset: 12)
    }
    
    public var autoHilite: Bool {
        return data.readFlag(at: 0xE, bitOffset: 13)
    }
    
    public var wideMargins: Bool {
        return data.readFlag(at: 0xE, bitOffset: 13)
    }
    
    public var hilite: Bool {
        return data.readFlag(at: 0xE, bitOffset: 14)
    }
    
    public var showLines: Bool {
        return data.readFlag(at: 0xE, bitOffset: 14)
    }
    
    public var showName: Bool {
        return data.readFlag(at: 0xE, bitOffset: 15)
    }
    
    public var autoSelect: Bool {
        return data.readFlag(at: 0xE, bitOffset: 15)
    }
    
    public var style: PartStyle {
        let styleIndex = data.readUInt8(at: 0xF)
        switch styleIndex {
        case 0:
            return PartStyle.transparent
        case 1:
            return PartStyle.opaque
        case 2:
            return PartStyle.rectangle
        case 3:
            return PartStyle.roundRect
        case 4:
            return PartStyle.shadow
        case 5:
            return PartStyle.checkBox
        case 6:
            return PartStyle.radio
        case 7:
            return PartStyle.scrolling
        case 8:
            return PartStyle.standard
        case 9:
            return PartStyle.`default`
        case 10:
            return PartStyle.oval
        case 11:
            return PartStyle.popup
        default:
            return PartStyle.transparent
        }
    }
    
    public var lastSelectedLine: Int {
        return data.readUInt16(at: 0x10)
    }
    
    public var titleWidth: Int {
        return data.readUInt16(at: 0x10)
    }
    
    public var selectedLine: Int {
        return data.readUInt16(at: 0x12)
    }
    
    public var icon: Int {
        let value = data.readSInt16(at: 0x12)
        return value
    }
    
    public var textAlign: TextAlign {
        let textAlignIndex = data.readSInt16(at: 0x14)
        switch textAlignIndex {
        case 0:
            return TextAlign.left
        case 1:
            return TextAlign.center
        case -1:
            return TextAlign.right
        default:
            return TextAlign.left
        }
    }
    
    public var textFontIdentifier: Int {
        /* For unknown reasons, the identifier may be negative */
        let identifier = data.readSInt16(at: 0x16)
        return ((identifier >= 0) ? identifier : -identifier-1)
    }
    
    public var textFontSize: Int {
        return data.readUInt16(at: 0x18)
    }
    
    public var textStyle: TextStyle {
        let flags = data.readUInt8(at: 0x1A)
        return TextStyle(flags: flags)
    }
    
    public var textHeight: Int {
        return data.readUInt16(at: 0x1C)
    }
    
    public var name: HString {
        return data.readString(at: 0x1E)
    }
    
    public var script: HString {
        /* Look for the null-termination of the name */
        var offset = 0x1E
        while data.readUInt8(at: offset) != 0 && offset < data.length {
            offset += 1;
        }
        guard offset < data.length else {
            return ""
        }
        return data.readString(at: offset + 2)
    }
    
}
