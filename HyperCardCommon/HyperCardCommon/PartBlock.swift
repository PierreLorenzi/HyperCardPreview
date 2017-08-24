//
//  PartBlock.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 26/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//

/// A part block contains the properties of a button or a field
public class PartBlock: DataBlock {
    
    /// ID of the part
    public var identifier: Int {
        return data.readUInt16(at: 0x2)
    }
    
    /// Whether the part is a button or a field
    public var type: PartType {
        let flagTrue = data.readFlag(at: 0x4, bitOffset: 8)
        return flagTrue ? PartType.button : PartType.field
    }
    
    /// Enabled, only for buttons
    public var enabled: Bool {
        return !data.readFlag(at: 0x4, bitOffset: 0)
    }
    
    /// Lock Text, only for fields
    public var lockText: Bool {
        return data.readFlag(at: 0x4, bitOffset: 0)
    }
    
    /// Auto Tab, only for fields
    public var autoTab: Bool {
        return data.readFlag(at: 0x4, bitOffset: 1)
    }
    
    /// Fixed Line Height
    public var fixedLineHeight: Bool {
        return !data.readFlag(at: 0x4, bitOffset: 2)
    }
    
    /// Shared Text, only for fields
    public var sharedText: Bool {
        return data.readFlag(at: 0x4, bitOffset: 3)
    }
    
    /// Don't Search, only for fields
    public var dontSearch: Bool {
        return data.readFlag(at: 0x4, bitOffset: 4)
    }
    
    /// Don't Wrap, only for fields
    public var dontWrap: Bool {
        return data.readFlag(at: 0x4, bitOffset: 5)
    }
    
    /// Visible
    public var visible: Bool {
        return !data.readFlag(at: 0x4, bitOffset: 7)
    }
    
    /// Rectangle
    public var rectangle: Rectangle {
        return data.readRectangle(at: 0x6)
    }
    
    /// Family, only for buttons
    public var family: Int {
        let flags = data.readUInt8(at: 0xE)
        let value = flags & 0b1111
        return value
    }
    
    /// Shared Hilite, only for buttons
    public var sharedHilite: Bool {
        return !data.readFlag(at: 0xE, bitOffset: 12)
    }
    
    /// Multiple Lines, only for fields
    public var multipleLines: Bool {
        return data.readFlag(at: 0xE, bitOffset: 12)
    }
    
    /// Auto Hilite, only for buttons
    public var autoHilite: Bool {
        return data.readFlag(at: 0xE, bitOffset: 13)
    }
    
    /// Wide Margins, only for fields
    public var wideMargins: Bool {
        return data.readFlag(at: 0xE, bitOffset: 13)
    }
    
    /// Hilite, only for buttons
    public var hilite: Bool {
        return data.readFlag(at: 0xE, bitOffset: 14)
    }
    
    /// Show Lines, only for fields
    public var showLines: Bool {
        return data.readFlag(at: 0xE, bitOffset: 14)
    }
    
    /// Show Name, only for buttons
    public var showName: Bool {
        return data.readFlag(at: 0xE, bitOffset: 15)
    }
    
    /// Auto Select, only for fields
    public var autoSelect: Bool {
        return data.readFlag(at: 0xE, bitOffset: 15)
    }
    
    /// Visual style of the part
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
    
    /// Line index of the end of the text selection, only for fields
    public var lastSelectedLine: Int {
        return data.readUInt16(at: 0x10) - 1
    }
    
    /// Title Width, only for pop-up buttons
    public var titleWidth: Int {
        return data.readUInt16(at: 0x10)
    }
    
    /// Line index of the start of the text selection, only for fields and pop-up buttons
    public var selectedLine: Int {
        return data.readUInt16(at: 0x12) - 1
    }
    
    /// Icon, only for buttons
    public var icon: Int {
        let value = data.readSInt16(at: 0x12)
        return value
    }
    
    /// Text Alignment
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
    
    /// Text Font
    public var textFontIdentifier: Int {
        /* For unknown reasons, the identifier may be negative */
        let identifier = data.readSInt16(at: 0x16)
        return ((identifier >= 0) ? identifier : -identifier-1)
    }
    
    /// Text Size
    public var textFontSize: Int {
        return data.readUInt16(at: 0x18)
    }
    
    /// Text Style
    public var textStyle: TextStyle {
        let flags = data.readUInt8(at: 0x1A)
        return TextStyle(flags: flags)
    }
    
    /// Line Height
    public var textHeight: Int {
        return data.readUInt16(at: 0x1C)
    }
    
    /// Name
    public var name: HString {
        return data.readString(at: 0x1E)
    }
    
    /// Script
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
