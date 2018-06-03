//
//  HyperCardFileField.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 26/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//



public extension Field {
    
    public convenience init(partBlock: PartBlock, layerBlock: LayerBlock, fileContent: HyperCardFileData) {
        
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
            return Layer.loadContent(identifier: partBlock.readIdentifier(), layerBlock: layerBlock, fileContent: fileContent)
        }
        
    }
    
}

