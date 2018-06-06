//
//  HyperCardFileButton.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 26/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//




public extension Button {
    
    public convenience init(loadFromData data: DataRange, loadContent: @escaping () -> HString) {
        
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

