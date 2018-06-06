//
//  HyperCardFileLayer.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 26/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


public extension Layer {
    
    func initLayerProperties(layerReader: LayerBlockReader, loadBitmap: @escaping (Int) -> MaskedImage, styles: [IndexedStyle]) {
        
        /* Read now the scalar fields */
        self.cantDelete = layerReader.readCantDelete()
        self.showPict = layerReader.readShowPict()
        self.dontSearch = layerReader.readDontSearch()
        self.nextAvailablePartIdentifier = layerReader.readNextAvailableIdentifier()
        
        /* Enable lazy initialization */
        
        /* image */
        self.imageProperty.lazyCompute {
            
            /* Get the identifier of the bitmap in the file */
            guard let bitmapIdentifier = layerReader.readBitmapIdentifier() else {
                return nil
            }
            
            return loadBitmap(bitmapIdentifier)
        }
        
        /* parts */
        self.partsProperty.lazyCompute {
            return Layer.loadParts(layerReader: layerReader, styles: styles)
        }
        
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
                let loadContent = { () -> HString in
                    return Layer.loadContent(identifier: partReader.readIdentifier(), layerReader: layerReader, styles: styles).string
                }
                let button = Button(partReader: partReader, loadContent: loadContent)
                parts.append(LayerPart.button(button))
            case .field:
                let loadContent = { () -> PartContent in
                    return Layer.loadContent(identifier: partReader.readIdentifier(), layerReader: layerReader, styles: styles)
                }
                let field = Field(partReader: partReader, loadContent: loadContent)
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

