//
//  HyperCardFileField.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 26/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//



public extension Field {
    
    public convenience init(partReader: PartBlockReader, layerReader: LayerBlockReader, styles: [IndexedStyle]) {
        
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
        self.contentProperty.lazyCompute = {
            return Layer.loadContent(identifier: partReader.readIdentifier(), layerReader: layerReader, styles: styles)
        }
        
    }
    
}

public extension Field {
    
    public convenience init(partBlock: PartBlock, layerBlock: LayerBlock, styles: [StyleBlock.Style]) {
        
        self.init()
        
        /* Read now the scalar fields */
        self.lockText = partBlock.readLockText()
        self.autoTab = partBlock.readAutoTab()
        self.fixedLineHeight = partBlock.readFixedLineHeight()
        self.sharedText = partBlock.readSharedText()
        self.dontSearch = partBlock.readDontSearch()
        self.dontWrap = partBlock.readDontWrap()
        self.multipleLines = partBlock.readMultipleLines()
        self.wideMargins = partBlock.readWideMargins()
        self.showLines = partBlock.readShowLines()
        self.autoSelect = partBlock.readAutoSelect()
        self.selectedLine = partBlock.readSelectedLine()
        self.lastSelectedLine = partBlock.readLastSelectedLine()
        self.textAlign = partBlock.readTextAlign()
        self.textFontIdentifier = partBlock.readTextFontIdentifier()
        self.textFontSize = partBlock.readTextFontSize()
        self.textStyle = partBlock.readTextStyle()
        self.textHeight = partBlock.readTextHeight()
        
        /* Enable lazy initialization */
        super.setupLazyInitialization(partBlock: partBlock)
        
        
        /* content */
        self.contentProperty.lazyCompute = {
            return Layer.loadContent(identifier: partBlock.readIdentifier(), layerBlock: layerBlock, styles: styles)
        }
        
    }
    
}

