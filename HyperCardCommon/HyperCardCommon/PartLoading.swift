//
//  FilePart.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 19/08/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


public extension Field {
    
    /// Loads a field from a part data block inside the stack file data fork.
    convenience init(loadFromData data: DataRange, loadContent: @escaping () -> PartContent) {
                
        self.init()
        
        /* Read now the scalar fields */
        self.lockText = data.readFlag(at: 0x4, bitOffset: 0)
        self.autoTab = data.readFlag(at: 0x4, bitOffset: 1)
        self.fixedLineHeight = !data.readFlag(at: 0x4, bitOffset: 2)
        self.sharedText = data.readFlag(at: 0x4, bitOffset: 3)
        self.dontSearch = data.readFlag(at: 0x4, bitOffset: 4)
        self.dontWrap = data.readFlag(at: 0x4, bitOffset: 5)
        self.multipleLines = data.readFlag(at: 0xE, bitOffset: 12)
        self.wideMargins = data.readFlag(at: 0xE, bitOffset: 13)
        self.showLines = data.readFlag(at: 0xE, bitOffset: 14)
        self.autoSelect = data.readFlag(at: 0xE, bitOffset: 15)
        self.selectedLine = data.readUInt16(at: 0x12) - 1
        self.lastSelectedLine = data.readUInt16(at: 0x10) - 1
        
        /* Enable lazy initialization */
        self.initPartProperties(data: data)
        
        
        /* content */
        self.contentProperty.lazyCompute(loadContent)
        
    }
    
}

public extension Button {
    
    /// Loads a button from a part data block inside the stack file data fork.
    convenience init(loadFromData data: DataRange, loadContent: @escaping () -> HString) {
        
        self.init()
        
        /* Read now the scalar fields */
        self.enabled = !data.readFlag(at: 0x4, bitOffset: 0)
        self.hilite = data.readFlag(at: 0xE, bitOffset: 14)
        self.autoHilite = data.readFlag(at: 0xE, bitOffset: 13)
        self.sharedHilite = !data.readFlag(at: 0xE, bitOffset: 12)
        self.showName = data.readFlag(at: 0xE, bitOffset: 15)
        self.iconIdentifier = data.readSInt16(at: 0x12)
        self.selectedItem = data.readUInt16(at: 0x12) - 1
        self.family = 0b1111 & data.readUInt8(at: 0xE)
        self.titleWidth = data.readUInt16(at: 0x10)
        
        /* Enable lazy initialization */
        self.initPartProperties(data: data)
        
        /* content */
        self.contentProperty.lazyCompute(loadContent)
        
    }
    
}

private extension Part {
    
    func initPartProperties(data: DataRange) {
        
        /* Read now the scalar fields */
        self.identifier = data.readUInt16(at: 0x2)
        self.style = data.readPartStyle(at: 0xF)
        self.visible = !data.readFlag(at: 0x4, bitOffset: 7)
        self.rectangle = data.readRectangle(at: 0x6)
        self.textAlign = data.readTextAlign(at: 0x14)
        self.textFontIdentifier = data.readFontIdentifier(at: 0x16)
        self.textFontSize = data.readUInt16(at: 0x18)
        self.textStyle = data.readTextStyle(at: 0x1A)
        self.textHeight = data.readUInt16(at: 0x1C)
        
        /* name */
        self.nameProperty.lazyCompute {
            return data.readString(at: 0x1E)
        }
        
        /* script */
        self.scriptProperty.lazyCompute {
            
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
    
}

private extension DataRange {
    
    func readPartStyle(at offset: Int) -> PartStyle {
        
        let styleIndex = self.readUInt8(at: offset)
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
    
    func readTextAlign(at offset: Int) -> TextAlign {
        
        let textAlignIndex = self.readSInt16(at: offset)
        
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
    
    func readFontIdentifier(at offset: Int) -> Int {
        /* For unknown reasons, the identifier may be negative */
        let identifier = self.readSInt16(at: offset)
        return ((identifier >= 0) ? identifier : -identifier-1)
    }
    
    func readTextStyle(at offset: Int) -> TextStyle {
        let flags = self.readUInt8(at: offset)
        return TextStyle(flags: flags)
    }
}
