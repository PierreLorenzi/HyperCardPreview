//
//  HyperCardFileButton.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 26/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//




public extension Button {
    
    public convenience init(partReader: PartBlockReader, layerReader: LayerBlockReader, styles: [IndexedStyle]) {
        
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
        self.textAlign = partReader.readTextAlign()
        self.textFontIdentifier = partReader.readTextFontIdentifier()
        self.textFontSize = partReader.readTextFontSize()
        self.textStyle = partReader.readTextStyle()
        self.textHeight = partReader.readTextHeight()
        
        /* Enable lazy initialization */
        self.initPartProperties(partReader: partReader)
        
        /* content */
        self.contentProperty.lazyCompute = {
            let partContent = Layer.loadContent(identifier: partReader.readIdentifier(), layerReader: layerReader, styles: styles)
            return partContent.string
        }
        
        
    }
    
}

public extension Button {
    
    public convenience init(partBlock: PartBlock, layerBlock: LayerBlock, styles: [StyleBlock.Style]) {
        
        self.init()
        
        /* Read now the scalar fields */
        self.enabled = partBlock.readEnabled()
        self.hilite = partBlock.readHilite()
        self.autoHilite = partBlock.readAutoHilite()
        self.sharedHilite = partBlock.readSharedHilite()
        self.showName = partBlock.readShowName()
        self.iconIdentifier = partBlock.readIconIdentifier()
        self.selectedItem = partBlock.readSelectedLine()
        self.family = partBlock.readFamily()
        self.titleWidth = partBlock.readTitleWidth()
        self.textAlign = partBlock.readTextAlign()
        self.textFontIdentifier = partBlock.readTextFontIdentifier()
        self.textFontSize = partBlock.readTextFontSize()
        self.textStyle = partBlock.readTextStyle()
        self.textHeight = partBlock.readTextHeight()
        
        /* Enable lazy initialization */
        super.setupLazyInitialization(partBlock: partBlock)
        
        /* content */
        self.contentProperty.lazyCompute = {
            let partContent = Layer.loadContent(identifier: partBlock.readIdentifier(), layerBlock: layerBlock, styles: styles)
            return partContent.string
        }
        
        
    }
    
}
