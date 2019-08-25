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
        
        let partReader = PartBlockReader(data: data)
        
        self.init()
        
        /* Read now the scalar fields */
        self.lockText = partReader.readLockText()
        self.autoTab = partReader.readAutoTab()
        self.fixedLineHeight = partReader.readFixedLineHeight()
        self.sharedText = partReader.readSharedText()
        self.dontSearch = partReader.readDontSearch()
        self.dontWrap = partReader.readDontWrap()
        self.multipleLines = partReader.readMultipleLines()
        self.wideMargins = partReader.readWideMargins()
        self.showLines = partReader.readShowLines()
        self.autoSelect = partReader.readAutoSelect()
        self.selectedLine = partReader.readSelectedLine()
        self.lastSelectedLine = partReader.readLastSelectedLine()
        
        /* Enable lazy initialization */
        self.initPartProperties(partReader: partReader)
        
        
        /* content */
        self.contentProperty.lazyCompute(loadContent)
        
    }
    
}

public extension Button {
    
    /// Loads a button from a part data block inside the stack file data fork.
    convenience init(loadFromData data: DataRange, loadContent: @escaping () -> HString) {
        
        let partReader = PartBlockReader(data: data)
        
        self.init()
        
        /* Read now the scalar fields */
        self.enabled = partReader.readEnabled()
        self.hilite = partReader.readHilite()
        self.autoHilite = partReader.readAutoHilite()
        self.sharedHilite = partReader.readSharedHilite()
        self.showName = partReader.readShowName()
        self.iconIdentifier = partReader.readIconIdentifier()
        self.selectedItem = partReader.readSelectedLine()
        self.family = partReader.readFamily()
        self.titleWidth = partReader.readTitleWidth()
        
        /* Enable lazy initialization */
        self.initPartProperties(partReader: partReader)
        
        /* content */
        self.contentProperty.lazyCompute(loadContent)
        
    }
    
}

private extension Part {
    
    func initPartProperties(partReader: PartBlockReader) {
        
        /* Read now the scalar fields */
        self.identifier = partReader.readIdentifier()
        self.style = partReader.readStyle()
        self.visible = partReader.readVisible()
        self.rectangle = partReader.readRectangle()
        self.textAlign = partReader.readTextAlign()
        self.textFontIdentifier = partReader.readTextFontIdentifier()
        self.textFontSize = partReader.readTextFontSize()
        self.textStyle = partReader.readTextStyle()
        self.textHeight = partReader.readTextHeight()
        
        /* name */
        self.nameProperty.lazyCompute {
            return partReader.readName()
        }
        
        /* script */
        self.scriptProperty.lazyCompute {
            return partReader.readScript()
        }
        
    }
    
}
