//
//  HyperCardFileField.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 26/02/2017.
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
        self.textAlign = partReader.readTextAlign()
        self.textFontIdentifier = partReader.readTextFontIdentifier()
        self.textFontSize = partReader.readTextFontSize()
        self.textStyle = partReader.readTextStyle()
        self.textHeight = partReader.readTextHeight()
        
        /* Enable lazy initialization */
        self.initPartProperties(partReader: partReader)
        
        
        /* content */
        self.contentProperty.lazyCompute(loadContent)
        
    }
    
}

