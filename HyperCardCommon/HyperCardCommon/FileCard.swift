//
//  HyperCardFileCard.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 26/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//





public extension Card {
    
    public convenience init(cardBlock: CardBlock, fileContent: HyperCardFileData, background: Background) {
        
        self.init(background: background)
        
        /* Read now the scalar fields */
        self.identifier = cardBlock.identifier
        self.marked = cardBlock.marked
        self.searchHash = cardBlock.searchHash
        
        /* Enable lazy initialization */
        super.setupLazyInitialization(layerBlock: cardBlock, fileContent: fileContent)
        
        /* name */
        self.nameProperty.compute = {
            return cardBlock.name
        }
        
        /* backgroundPartContents */
        self.backgroundPartContentsProperty.compute = {
            return Card.loadBackgroundPartContents(cardBlock: cardBlock, fileContent: fileContent)
        }
        
        /* script */
        self.scriptProperty.compute = {
            return cardBlock.script
        }
        
    }
    
    private static func loadBackgroundPartContents(cardBlock: CardBlock, fileContent: HyperCardFileData) -> [BackgroundPartContent] {
        
        /* Get the contents */
        let contents = cardBlock.contents
        
        /* Keep only the background ones */
        let backgroundContents = contents.filter({$0.layerType == .background})
        
        /* Load them */
        let result = backgroundContents.map({
            (block: ContentBlock) -> Card.BackgroundPartContent in
            let identifier = block.identifier
            let content = Layer.loadContentFromBlock(content: block, layerBlock: cardBlock, fileContent: fileContent)
            return BackgroundPartContent(partIdentifier: identifier, partContent: content)
        })
        
        return result
        
    }
    
}

