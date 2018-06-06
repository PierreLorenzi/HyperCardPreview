//
//  HyperCardFileLayer.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 26/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


struct ContentMap {
    var cardContents: [Int: ContentBlockReader]
    var backgroundContents: [Int: ContentBlockReader]
}


extension Layer {
    
    func initLayerProperties(layerReader: LayerBlockReader, version: FileVersion, layerType: LayerType, loadBitmap: @escaping (Int) -> MaskedImage, styles: [IndexedStyle]) -> Property<ContentMap> {
        
        /* Read now the scalar fields */
        self.cantDelete = layerReader.readCantDelete()
        self.showPict = layerReader.readShowPict()
        self.dontSearch = layerReader.readDontSearch()
        self.nextAvailablePartIdentifier = layerReader.readNextAvailableIdentifier()
        
        /* Make a map of the contents, useful for some properties */
        let contentsProperty = Property<ContentMap> { () -> ContentMap in
            return Layer.mapContents(layerReader: layerReader, version: version)
        }
        
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
            return Layer.loadParts(layerReader: layerReader, layerType: layerType, contentsProperty: contentsProperty, styles: styles)
        }
        
        return contentsProperty
    }
    
    private static func mapContents(layerReader: LayerBlockReader, version: FileVersion) -> ContentMap {
        
        let contentBlocks = layerReader.extractContentBlocks()
        let contents = contentBlocks.map({ ContentBlockReader(data: $0, version: version) })
        
        let cardContents = contents.filter({ $0.readLayerType() == LayerType.card })
        let backgroundContents = contents.filter({ $0.readLayerType() == LayerType.background })
        
        let cardContentMap = Layer.index(cardContents, by: { $0.readIdentifier() })
        let backgroundContentMap = Layer.index(backgroundContents, by: { $0.readIdentifier() })
        
        return ContentMap(cardContents: cardContentMap, backgroundContents: backgroundContentMap)
    }
    
    static func index<T, Index: Hashable>(_ elements: [T], by closure: (T) -> Index) -> [Index: T] {
        var map: [Index: T] = [:]
        for element in elements {
            let index = closure(element)
            map[index] = element
        }
        return map
    }
    
    static func loadParts(layerReader: LayerBlockReader, layerType: LayerType, contentsProperty: Property<ContentMap>, styles: [IndexedStyle]) -> [LayerPart] {
        
        var parts = [LayerPart]()
        
        /* Load the part blocks */
        let partBlocks = layerReader.extractPartBlocks()
        
        /* Convert them to parts */
        for partBlock in partBlocks {
            
            /* Read the part type */
            let partReader = PartBlockReader(data: partBlock)
            let partType = partReader.readType()
            
            /* Check if the part is a field or a button */
            switch partType {
            case .button:
                let loadContent = { () -> HString in
                    return Layer.loadContent(identifier: partReader.readIdentifier(), layerType: layerType, contentsProperty: contentsProperty, styles: styles).string
                }
                let button = Button(loadFromData: partBlock, loadContent: loadContent)
                parts.append(LayerPart.button(button))
            case .field:
                let loadContent = { () -> PartContent in
                    return Layer.loadContent(identifier: partReader.readIdentifier(), layerType: layerType, contentsProperty: contentsProperty, styles: styles)
                }
                let field = Field(loadFromData: partBlock, loadContent: loadContent)
                parts.append(LayerPart.field(field))
            }
            
        }
        
        return parts
    }
    
    static func loadContent(identifier: Int, layerType: LayerType, contentsProperty: Property<ContentMap>, styles: [IndexedStyle]) -> PartContent {
        
        /* Look for the content block */
        let contentMap = contentsProperty.value
        let layerContentMap = (layerType == LayerType.card ? contentMap.cardContents : contentMap.backgroundContents)
        guard let contentReader = layerContentMap[identifier] else {
            return PartContent.string("")
        }
        
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

