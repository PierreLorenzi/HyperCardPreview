//
//  HyperCardFileButton.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 26/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//




public extension Button {
    
    public convenience init(partBlock: PartBlock, layerBlock: LayerBlock, fileContent: HyperCardFileData) {
        
        self.init()
        
        /* Read now the scalar fields */
        self.enabled = partBlock.enabled
        self.hilite = partBlock.hilite
        self.autoHilite = partBlock.autoHilite
        self.sharedHilite = partBlock.sharedHilite
        self.showName = partBlock.showName
        self.iconIdentifier = partBlock.icon
        self.selectedItem = partBlock.selectedLine
        self.family = partBlock.family
        self.titleWidth = partBlock.titleWidth
        self.textAlign = partBlock.textAlign
        self.textFontIdentifier = partBlock.textFontIdentifier
        self.textFontSize = partBlock.textFontSize
        self.textStyle = partBlock.textStyle
        self.textHeight = partBlock.textHeight
        
        /* Enable lazy initialization */
        super.setupLazyInitialization(partBlock: partBlock)
        
        /* content */
        self.contentProperty.compute = {
            let partContent = Layer.loadContent(identifier: partBlock.identifier, layerBlock: layerBlock, fileContent: fileContent)
            return partContent.string
        }
        
        
    }
    
}
