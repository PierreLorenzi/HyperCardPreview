//
//  HyperCardFileLayer.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 26/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


public extension Layer {
    
    func setupLazyInitialization(layerBlock: LayerBlock, fileContent: HyperCardFileData) {
        
        /* Enable lazy initialization */
        
        /* cantDelete */
        self.cantDeleteProperty.observers.append(LazyInitializer(property: self.cantDeleteProperty, initialization: {
            return layerBlock.cantDelete
        }))
        
        /* showPict */
        self.showPictProperty.observers.append(LazyInitializer(property: self.showPictProperty, initialization: {
            return layerBlock.showPict
        }))
        
        /* dontSearch */
        self.dontSearchProperty.observers.append(LazyInitializer(property: self.dontSearchProperty, initialization: {
            return layerBlock.dontSearch
        }))
        
        /* image */
        self.imageProperty.observers.append(LazyInitializer(property: self.imageProperty, initialization: {
            return Layer.loadImage(layerBlock: layerBlock, fileContent: fileContent)
        }))
        
        /* parts */
        self.partsProperty.observers.append(LazyInitializer(property: self.partsProperty, initialization: {
            return Layer.loadParts(layerBlock: layerBlock, fileContent: fileContent)
        }))
        
        /* nextAvailablePartIdentifier */
        self.nextAvailablePartIdentifierProperty.observers.append(LazyInitializer(property: self.nextAvailablePartIdentifierProperty, initialization: {
            return layerBlock.nextAvailableIdentifier
        }))
        
    }
    
    static func loadImage(layerBlock: LayerBlock, fileContent: HyperCardFileData) -> MaskedImage? {
        
        /* Get the identifier of the bitmap in the file */
        guard let bitmapIdentifier = layerBlock.bitmapIdentifier else {
            return nil
        }
        
        /* Look for the bitmap */
        let bitmaps = fileContent.bitmaps
        let bitmapIndex = bitmaps.index(where: {$0.identifier == bitmapIdentifier})!
        let bitmap = bitmaps[bitmapIndex]
        
        return bitmap.image
    }
    
    static func loadParts(layerBlock: LayerBlock, fileContent: HyperCardFileData) -> [LayerPart] {
        
        var parts = [LayerPart]()
        
        /* Load the part blocks */
        let partBlocks = layerBlock.parts
        
        /* Convert them to parts */
        for partBlock in partBlocks {
            
            /* Check if the part is a field or a button */
            switch (partBlock.type) {
            case .button:
                let button = Button(partBlock: partBlock, layerBlock: layerBlock, fileContent: fileContent)
                parts.append(LayerPart.button(button))
            case .field:
                let field = Field(partBlock: partBlock, layerBlock: layerBlock, fileContent: fileContent)
                parts.append(LayerPart.field(field))
            }
            
        }
        
        return parts
    }
    
    static func loadContent(identifier: Int, layerBlock: LayerBlock, fileContent: HyperCardFileData) -> PartContent {
        
        /* Look for the content block */
        let contents = layerBlock.contents
        let layerType: LayerType = (layerBlock is CardBlock) ? .card : .background
        guard let contentIndex = contents.index(where: {$0.identifier == identifier && $0.layerType == layerType}) else {
            return PartContent.string("")
        }
        
        let content = contents[contentIndex]
        
        return loadContentFromBlock(content: content, layerBlock: layerBlock, fileContent: fileContent)
        
    }
    
    static func loadContentFromBlock(content: ContentBlock, layerBlock: LayerBlock, fileContent: HyperCardFileData) -> PartContent {
        
        /* Extract the string */
        let string = content.string
        
        /* Check if it is a raw string */
        guard let formattingChanges = content.formattingChanges else {
            return PartContent.string(string)
        }
        
        /* Get the text styles of the stack (there must be a style block) */
        let styleBlock = fileContent.styleBlock!
        let styles = styleBlock.styles
        
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

