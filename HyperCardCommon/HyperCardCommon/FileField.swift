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
        
        /* Enable lazy initialization */
        
        /* identifier */
        self.identifierProperty.observers.append(LazyInitializer(property: self.identifierProperty, initialization: {
            return partBlock.identifier
        }))
        
        /* name */
        self.nameProperty.observers.append(LazyInitializer(property: self.nameProperty, initialization: {
            return partBlock.name
        }))
        
        /* style */
        self.styleProperty.observers.append(LazyInitializer(property: self.styleProperty, initialization: {
            return partBlock.style
        }))
        
        /* content */
        self.contentProperty.observers.append(LazyInitializer(property: self.contentProperty, initialization: {
            return Layer.loadContent(identifier: partBlock.identifier, layerBlock: layerBlock, fileContent: fileContent)
        }))
        
        /* rectangle */
        self.rectangleProperty.observers.append(LazyInitializer(property: self.rectangleProperty, initialization: {
            return partBlock.rectangle
        }))
        
        /* script */
        self.scriptProperty.observers.append(LazyInitializer(property: self.scriptProperty, initialization: {
            return partBlock.script
        }))
        
        /* lockText */
        self.lockTextProperty.observers.append(LazyInitializer(property: self.lockTextProperty, initialization: {
            return partBlock.lockText
        }))
        
        /* autoTab */
        self.autoTabProperty.observers.append(LazyInitializer(property: self.autoTabProperty, initialization: {
            return partBlock.autoTab
        }))
        
        /* fixedLineHeight */
        self.fixedLineHeightProperty.observers.append(LazyInitializer(property: self.fixedLineHeightProperty, initialization: {
            return partBlock.fixedLineHeight
        }))
        
        /* sharedText */
        self.sharedTextProperty.observers.append(LazyInitializer(property: self.sharedTextProperty, initialization: {
            return partBlock.sharedText
        }))
        
        /* dontSearch */
        self.dontSearchProperty.observers.append(LazyInitializer(property: self.dontSearchProperty, initialization: {
            return partBlock.dontSearch
        }))
        
        /* dontWrap */
        self.dontWrapProperty.observers.append(LazyInitializer(property: self.dontWrapProperty, initialization: {
            return partBlock.dontWrap
        }))
        
        /* visible */
        self.visibleProperty.observers.append(LazyInitializer(property: self.visibleProperty, initialization: {
            return partBlock.visible
        }))
        
        /* multipleLines */
        self.multipleLinesProperty.observers.append(LazyInitializer(property: self.multipleLinesProperty, initialization: {
            return partBlock.multipleLines
        }))
        
        /* wideMargins */
        self.wideMarginsProperty.observers.append(LazyInitializer(property: self.wideMarginsProperty, initialization: {
            return partBlock.wideMargins
        }))
        
        /* showLines */
        self.showLinesProperty.observers.append(LazyInitializer(property: self.showLinesProperty, initialization: {
            return partBlock.showLines
        }))
        
        /* autoSelect */
        self.autoSelectProperty.observers.append(LazyInitializer(property: self.autoSelectProperty, initialization: {
            return partBlock.autoSelect
        }))
        
        /* selectedLine */
        self.selectedLineProperty.observers.append(LazyInitializer(property: self.selectedLineProperty, initialization: {
            return partBlock.selectedLine
        }))
        
        /* lastSelectedLine */
        self.lastSelectedLineProperty.observers.append(LazyInitializer(property: self.lastSelectedLineProperty, initialization: {
            return partBlock.lastSelectedLine
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

