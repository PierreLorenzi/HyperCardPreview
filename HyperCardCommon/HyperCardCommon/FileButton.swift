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
        
        /* Enable lazy initialization */
        super.setupLazyInitialization(partBlock: partBlock)
        
        
        /* enabled */
        self.enabledProperty.observers.append(LazyInitializer(property: self.enabledProperty, initialization: {
            return partBlock.enabled
        }))
        
        /* hilite */
        self.hiliteProperty.observers.append(LazyInitializer(property: self.hiliteProperty, initialization: {
            return partBlock.hilite
        }))
        
        /* autoHilite */
        self.autoHiliteProperty.observers.append(LazyInitializer(property: self.autoHiliteProperty, initialization: {
            return partBlock.autoHilite
        }))
        
        /* sharedHilite */
        self.sharedHiliteProperty.observers.append(LazyInitializer(property: self.sharedHiliteProperty, initialization: {
            return partBlock.sharedHilite
        }))
        
        /* showName */
        self.showNameProperty.observers.append(LazyInitializer(property: self.showNameProperty, initialization: {
            return partBlock.showName
        }))
        
        /* iconIdentifier */
        self.iconIdentifierProperty.observers.append(LazyInitializer(property: self.iconIdentifierProperty, initialization: {
            return partBlock.icon
        }))
        
        /* selectedItem */
        self.selectedItemProperty.observers.append(LazyInitializer(property: self.selectedItemProperty, initialization: {
            return partBlock.selectedLine
        }))
        
        /* family */
        self.familyProperty.observers.append(LazyInitializer(property: self.familyProperty, initialization: {
            return partBlock.family
        }))
        
        /* titleWidth */
        self.titleWidthProperty.observers.append(LazyInitializer(property: self.titleWidthProperty, initialization: {
            return partBlock.titleWidth
        }))
        
        /* textAlign */
        self.textAlignProperty.observers.append(LazyInitializer(property: self.textAlignProperty, initialization: {
            return partBlock.textAlign
        }))
        
        /* textFontIdentifier */
        self.textFontIdentifierProperty.observers.append(LazyInitializer(property: self.textFontIdentifierProperty, initialization: {
            return partBlock.textFontIdentifier
        }))
        
        /* textFontSize */
        self.textFontSizeProperty.observers.append(LazyInitializer(property: self.textFontSizeProperty, initialization: {
            return partBlock.textFontSize
        }))
        
        /* textStyle */
        self.textStyleProperty.observers.append(LazyInitializer(property: self.textStyleProperty, initialization: {
            return partBlock.textStyle
        }))
        
        /* textHeight */
        self.textHeightProperty.observers.append(LazyInitializer(property: self.textHeightProperty, initialization: {
            return partBlock.textHeight
        }))
        
    }
    
}
