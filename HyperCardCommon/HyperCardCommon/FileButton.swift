//
//  HyperCardFileButton.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 26/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//




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
