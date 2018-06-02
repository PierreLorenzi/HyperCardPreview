//
//  HyperCardFileContent.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 22/03/2016.
//  Copyright © 2016 Pierre Lorenzi. All rights reserved.
//



/// Subclass for V1 stacks
public class HyperCardFileDataV1: HyperCardFileData {
    
    /* Stack */
    public override func extractStack() -> StackBlock {
        let length = data.readUInt32(at: 0x0)
        let dataRange = DataRange(sharedData: data.sharedData, offset: data.offset, length: length)
        return StackBlockV1(data: dataRange, decodedHeader: self.decodedHeader)
    }
    
    
    /* List */
    public override func extractList() -> ListBlock {
        let stack = self.extractStack()
        let identifier = stack.readListIdentifier()
        return self.loadBlock(identifier: identifier, initializer: ListBlockV1.init)
    }
    
    /* Style Block */
    public override func extractStyleBlock() -> StyleBlock? {
        return nil
    }
    
    /* Font Block */
    public override func extractFontBlock() -> FontBlock? {
        return nil
    }
    
    public override func extractPages() -> [PageBlock] {
        
        var pages = [PageBlock]()
        
        let list = self.extractList()
        
        /* Get the identifier list from the list */
        let pageReferences = list.readPageReferences()
        
        /* Get info shared among the pages */
        let cardReferenceSize = list.readCardReferenceSize()
        let hashValueCount = list.readHashValueCount()
        
        /* Add all the pages */
        for pageReference in pageReferences {
            
            /* Build the page (the page must have some info in order to work) */
            let initializer: (DataRange) -> PageBlock = {
                (data: DataRange) in
                return PageBlockV1(data: data,
                                 cardCount: pageReference.cardCount,
                                 cardReferenceSize: cardReferenceSize,
                                 hashValueCount: hashValueCount)
            }
            let page = self.loadBlock(identifier: pageReference.identifier, initializer: initializer)
            
            pages.append(page)
        }
        
        return pages
    }
    
    public override func extractCards() -> [CardBlock] {
        
        var cards = [CardBlock]()
        
        let pages = self.extractPages()

        /* Loop on the pages, that are the sections of the card list */
        for page in pages {
            
            /* Every page has card references */
            let cardReferences: [CardReference] = page.readCardReferences()
            
            for reference in cardReferences {
                
                /* Build the card */
                let initializer = { (data: DataRange) -> CardBlock in
                    return CardBlockV1(data: data,
                                     marked: reference.marked,
                                     hasTextContent: reference.hasTextContent,
                                     isStartOfBackground: reference.isStartOfBackground,
                                     hasName: reference.hasName,
                                     searchHash: reference.searchHash)
                }
                let card = self.loadBlock(identifier: reference.identifier, initializer: initializer)
                
                cards.append(card)
            }
            
        }
        
        return cards
    }
    
    /* Access to backgrounds, BEWARE: they are not ordered, use the fields nextBackgroundIdentifier and previousBackgroundIdentifier */
    public override func extractBackgrounds() -> [BackgroundBlock] {
        return self.listBlocks(BackgroundBlockV1.init)
    }
    
    /* Access to bitmaps */
    public override func extractBitmaps() -> [BitmapBlock] {
        return self.listBlocks(BitmapBlockV1.init)
    }
    
}
