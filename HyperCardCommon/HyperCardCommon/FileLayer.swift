//
//  HyperCardFileLayer.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 26/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


public extension Layer {
    
    func initLayerProperties(layerReader: LayerBlockReader, loadBitmap: @escaping (Int) -> BitmapBlockReader, styles: [IndexedStyle]) {
        
        /* Read now the scalar fields */
        self.cantDelete = layerReader.readCantDelete()
        self.showPict = layerReader.readShowPict()
        self.dontSearch = layerReader.readDontSearch()
        self.nextAvailablePartIdentifier = layerReader.readNextAvailableIdentifier()
        
        /* Enable lazy initialization */
        
        /* image */
        self.imageProperty.lazyCompute = {
            return Layer.loadImage(layerReader: layerReader, loadBitmap: loadBitmap)
        }
        
        /* parts */
        self.partsProperty.lazyCompute = {
            return Layer.loadParts(layerReader: layerReader, styles: styles)
        }
        
    }
    
    static func loadImage(layerReader: LayerBlockReader, loadBitmap: (Int) -> BitmapBlockReader) -> MaskedImage? {
        
        /* Get the identifier of the bitmap in the file */
        guard let bitmapIdentifier = layerReader.readBitmapIdentifier() else {
            return nil
        }
        
        /* Look for the bitmap */
        let bitmap = loadBitmap(bitmapIdentifier)
        
        return bitmap.readImage()
    }
    
    static func loadParts(layerReader: LayerBlockReader, styles: [IndexedStyle]) -> [LayerPart] {
        
        var parts = [LayerPart]()
        
        /* Load the part blocks */
        let partReaders = layerReader.extractPartReaders()
        
        /* Convert them to parts */
        for partReader in partReaders {
            
            /* Check if the part is a field or a button */
            switch partReader.readType() {
            case .button:
                let button = Button(partReader: partReader, layerReader: layerReader, styles: styles)
                parts.append(LayerPart.button(button))
            case .field:
                let field = Field(partReader: partReader, layerReader: layerReader, styles: styles)
                parts.append(LayerPart.field(field))
            }
            
        }
        
        return parts
    }
    
    static func loadContent(identifier: Int, layerReader: LayerBlockReader, styles: [IndexedStyle]) -> PartContent {
        
        /* Look for the content block */
        let contentReaders = layerReader.extractContentReaders()
        let layerType: LayerType = (layerReader is CardBlockReader) ? .card : .background
        guard let contentIndex = contentReaders.index(where: {$0.readIdentifier() == identifier && $0.readLayerType() == layerType}) else {
            return PartContent.string("")
        }
        
        let contentReader = contentReaders[contentIndex]
        
        return loadContentFromReader(contentReader: contentReader, styles: styles)
        
    }
    
    static func loadContentFromReader(contentReader: ContentBlockReader, styles: [IndexedStyle]) -> PartContent {
        
        /* Extract the string */
        let string = contentReader.readString()
        
        /* Check if it is a raw string */
        guard let formattingChanges = contentReader.readFormattingChanges() else {
            return PartContent.string(string)
        }
        
        /* Load the attributes */
        var attributes = Array<Text.FormattingAssociation>()
        for formattingChange in formattingChanges {
            let style = styles.first(where: { $0.number == formattingChange.styleIdentifier })!
            let format = style.textAttribute
            let attribute = Text.FormattingAssociation(offset: formattingChange.offset, formatting: format);
            attributes.append(attribute)
        }
        
        let text = Text(string: string, attributes: attributes)
        return PartContent.formattedString(text)
        
    }
    
}



public extension Layer {
    
    func setupLazyInitialization(layerBlock: LayerBlock, bitmapsByIdentifiers: [Int: BitmapBlock], styles: [StyleBlock.Style]) {
        
        /* Read now the scalar fields */
        self.cantDelete = layerBlock.readCantDelete()
        self.showPict = layerBlock.readShowPict()
        self.dontSearch = layerBlock.readDontSearch()
        self.nextAvailablePartIdentifier = layerBlock.readNextAvailableIdentifier()
        
        /* Enable lazy initialization */
        
        /* image */
        self.imageProperty.lazyCompute = {
            return Layer.loadImage(layerBlock: layerBlock, bitmapsByIdentifiers: bitmapsByIdentifiers)
        }
        
        /* parts */
        self.partsProperty.lazyCompute = {
            return Layer.loadParts(layerBlock: layerBlock, styles: styles)
        }
        
    }
    
    static func loadImage(layerBlock: LayerBlock, bitmapsByIdentifiers: [Int: BitmapBlock]) -> MaskedImage? {
        
        /* Get the identifier of the bitmap in the file */
        guard let bitmapIdentifier = layerBlock.readBitmapIdentifier() else {
            return nil
        }
        
        /* Look for the bitmap */
        let bitmap = bitmapsByIdentifiers[bitmapIdentifier]!
        
        return bitmap.readImage()
    }
    
    static func loadParts(layerBlock: LayerBlock, styles: [StyleBlock.Style]) -> [LayerPart] {
        
        var parts = [LayerPart]()
        
        /* Load the part blocks */
        let partBlocks = layerBlock.extractParts()
        
        /* Convert them to parts */
        for partBlock in partBlocks {
            
            /* Check if the part is a field or a button */
            switch (partBlock.readType()) {
            case .button:
                let button = Button(partBlock: partBlock, layerBlock: layerBlock, styles: styles)
                parts.append(LayerPart.button(button))
            case .field:
                let field = Field(partBlock: partBlock, layerBlock: layerBlock, styles: styles)
                parts.append(LayerPart.field(field))
            }
            
        }
        
        return parts
    }
    
    static func loadContent(identifier: Int, layerBlock: LayerBlock, styles: [StyleBlock.Style]) -> PartContent {
        
        /* Look for the content block */
        let contents = layerBlock.extractContents()
        let layerType: LayerType = (layerBlock is CardBlock) ? .card : .background
        guard let contentIndex = contents.index(where: {$0.identifier == identifier && $0.layerType == layerType}) else {
            return PartContent.string("")
        }
        
        let content = contents[contentIndex]
        
        return loadContentFromBlock(content: content, layerBlock: layerBlock, styles: styles)
        
    }
    
    static func loadContentFromBlock(content: ContentBlock, layerBlock: LayerBlock, styles: [StyleBlock.Style]) -> PartContent {
        
        /* Extract the string */
        let string = content.readString()
        
        /* Check if it is a raw string */
        guard let formattingChanges = content.readFormattingChanges() else {
            return PartContent.string(string)
        }
        
        /* Load the attributes */
        var attributes = Array<Text.FormattingAssociation>()
        for formattingChange in formattingChanges {
            let style = styles.first(where: { $0.number == formattingChange.styleIdentifier })!
            let format = style.textAttribute
            let attribute = Text.FormattingAssociation(offset: formattingChange.offset, formatting: format);
            attributes.append(attribute)
        }
        
        let text = Text(string: string, attributes: attributes)
        return PartContent.formattedString(text)
        
    }
    
}

