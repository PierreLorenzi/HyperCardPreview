//
//  HyperCardFileContent.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 22/03/2016.
//  Copyright © 2016 Pierre Lorenzi. All rights reserved.
//



public class HyperCardFileDataV1: HyperCardFileData {
    
    /* Stack */
    public override var stack: StackBlock {
        let length = data.readUInt32(at: 0x0)
        let dataRange = DataRange(sharedData: data.sharedData, offset: data.offset, length: length)
        return StackBlockV1(data: dataRange)
    }
    
    
    /* List */
    public override var list: ListBlock {
        let identifier = self.stack.listIdentifier
        return self.loadBlock(identifier: identifier, initializer: ListBlockV1.init)
    }
    
    /* Style Block */
    public override var styleBlock: StyleBlock? {
        return nil
    }
    
    /* Font Block */
    public override var fontBlock: FontBlock? {
        return nil
    }
    
    public override var pages: [PageBlock] {
        
        var pages = [PageBlock]()
        
        /* Get the identifier list from the list */
        let pageReferences = self.list.pageReferences
        
        /* Get info shared among the pages */
        let cardReferenceSize = list.cardReferenceSize
        let hashValueCount = list.hashValueCount
        
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
    
    public override var cards: [CardBlock] {
        
        var cards = [CardBlock]()

        /* Loop on the pages, that are the sections of the card list */
        for page in pages {
            
            /* Every page has card references */
            for reference in page.cardReferences {
                
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
    public override var backgrounds: [BackgroundBlock] {
        return self.buildElementList(BackgroundBlockV1.init)
    }
    
    /* Access to bitmaps */
    public override var bitmaps: [BitmapBlock] {
        return self.buildElementList(BitmapBlockV1.init)
    }
    
}
