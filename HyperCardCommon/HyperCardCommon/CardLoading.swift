//
//  HyperCardFileCard.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 26/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


public extension Card {
    
    /// Loads a card from a CARD data block inside the stack file data fork.
    convenience init(loadFromData data: DataRange, version: FileVersion, cardReference: CardReference, loadBitmap: @escaping (Int) -> MaskedImage, styles: [IndexedStyle], background: Background) {
        
        let cardReader = CardBlockReader(data: data, version: version)
        
        self.init(background: background)
        
        /* Read now the scalar fields */
        self.identifier = cardReader.readIdentifier()
        self.marked = cardReference.marked
        self.searchHash = cardReference.searchHash
        
        /* Enable lazy initialization */
        let contentMapProperty = self.initLayerProperties(layerReader: cardReader, version: version, layerType: LayerType.card, loadBitmap: loadBitmap, styles: styles)
        
        /* name */
        self.nameProperty.lazyCompute {
            return cardReader.readName()
        }
        
        /* backgroundPartContents */
        self.backgroundPartContentsProperty.lazyCompute {
            return Card.loadBackgroundPartContents(contentMap: contentMapProperty.value, styles: styles)
        }
        
        /* script */
        self.scriptProperty.lazyCompute {
            return cardReader.readScript()
        }
        
    }
    
    private static func loadBackgroundPartContents(contentMap: ContentMap, styles: [IndexedStyle]) -> [BackgroundPartContent] {
        
        /* Load them */
        let result = contentMap.backgroundContents.map({
            (identifier: Int, contentReader: ContentBlockReader) -> Card.BackgroundPartContent in
            
            let content = Layer.loadContentFromReader(contentReader: contentReader, styles: styles)
            return BackgroundPartContent(partIdentifier: identifier, partContent: content)
        })
        
        return result
        
    }
    
}

