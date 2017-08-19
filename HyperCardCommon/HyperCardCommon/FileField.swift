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
        self.lockText = partBlock.lockText
        self.autoTab = partBlock.autoTab
        self.fixedLineHeight = partBlock.fixedLineHeight
        self.sharedText = partBlock.sharedText
        self.dontSearch = partBlock.dontSearch
        self.dontWrap = partBlock.dontWrap
        self.multipleLines = partBlock.multipleLines
        self.wideMargins = partBlock.wideMargins
        self.showLines = partBlock.showLines
        self.autoSelect = partBlock.autoSelect
        self.selectedLine = partBlock.selectedLine
        self.lastSelectedLine = partBlock.lastSelectedLine
        self.textAlign = partBlock.textAlign
        self.textFontIdentifier = partBlock.textFontIdentifier
        self.textFontSize = partBlock.textFontSize
        self.textStyle = partBlock.textStyle
        self.textHeight = partBlock.textHeight
        
        /* Enable lazy initialization */
        super.setupLazyInitialization(partBlock: partBlock)
        
        
        /* content */
        self.contentProperty.observers.append(LazyInitializer(property: self.contentProperty, initialization: {
            return Layer.loadContent(identifier: partBlock.identifier, layerBlock: layerBlock, fileContent: fileContent)
        }))
        
    }
    
}

