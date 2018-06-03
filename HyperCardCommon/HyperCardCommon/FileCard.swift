//
//  HyperCardFileCard.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 26/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//





public extension Card {
    
    public convenience init(cardBlock: CardBlock, bitmaps: [BitmapBlock], styles: [StyleBlock.Style], background: Background) {
        
        self.init(background: background)
        
        /* Read now the scalar fields */
        self.identifier = cardBlock.readIdentifier()
        self.marked = cardBlock.marked
        self.searchHash = cardBlock.searchHash
        
        /* Enable lazy initialization */
        super.setupLazyInitialization(layerBlock: cardBlock, bitmaps: bitmaps, styles: styles)
        
        /* name */
        self.nameProperty.lazyCompute = {
            return cardBlock.readName()
        }
        
        /* backgroundPartContents */
        self.backgroundPartContentsProperty.lazyCompute = {
            return Card.loadBackgroundPartContents(cardBlock: cardBlock, styles: styles)
        }
        
        /* script */
        self.scriptProperty.lazyCompute = {
            return cardBlock.readScript()
        }
        
    }
    
    private static func loadBackgroundPartContents(cardBlock: CardBlock, styles: [StyleBlock.Style]) -> [BackgroundPartContent] {
        
        /* Get the contents */
        let contents = cardBlock.extractContents()
        
        /* Keep only the background ones */
        let backgroundContents = contents.filter({$0.layerType == .background})
        
        /* Load them */
        let result = backgroundContents.map({
            (block: ContentBlock) -> Card.BackgroundPartContent in
            let identifier = block.identifier
            let content = Layer.loadContentFromBlock(content: block, layerBlock: cardBlock, styles: styles)
            return BackgroundPartContent(partIdentifier: identifier, partContent: content)
        })
        
        return result
        
    }
    
}

