//
//  HyperCardFileStack.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 26/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


public extension Stack {
    
    public convenience init(fileReader: HyperCardFileReader, resources: ResourceRepository?) {
        
        self.init()
        
        /* Register the resources */
        self.resources = resources
        
        /* Get the stack */
        let stackReader = fileReader.extractStackReader()
        
        /* Read now the scalar fields */
        self.passwordHash = stackReader.readPasswordHash()
        self.userLevel = stackReader.readUserLevel()
        self.cantAbort = stackReader.readCantAbort()
        self.cantDelete = stackReader.readCantDelete()
        self.cantModify = stackReader.readCantModify()
        self.cantPeek = stackReader.readCantPeek()
        self.privateAccess = stackReader.readPrivateAccess()
        self.versionAtCreation = stackReader.readVersionAtCreation()
        self.versionAtLastCompacting = stackReader.readVersionAtLastCompacting()
        self.versionAtLastModificationSinceLastCompacting = stackReader.readVersionAtLastModificationSinceLastCompacting()
        self.versionAtLastModification = stackReader.readVersionAtLastModification()
        self.size = stackReader.readSize()
        self.windowRectangle = stackReader.readWindowRectangle()
        self.screenRectangle = stackReader.readScreenRectangle()
        self.scrollPoint = stackReader.readScrollPoint()
        
        /* Load some data to load the cards and backgrounds */
        let styleReader = fileReader.extractStyleBlockReader()
        let styles = styleReader?.readStyles() ?? []
        let loadBitmap = { (identifier: Int) -> BitmapBlockReader in
            return fileReader.extractBitmapReader(withIdentifier: identifier) }
        
        /* Cards */
        self.cardsProperty.lazyCompute = { () -> [Card] in
            return Stack.listCards(fileReader: fileReader, loadBitmap: loadBitmap, styles: styles, backgroundsProperty: self.backgroundsProperty)
        }
        
        /* Backgrounds */
        self.backgroundsProperty.lazyCompute = { () -> [Background] in
            return Stack.listBackgrounds(fileReader: fileReader, stackReader: stackReader, loadBitmap: loadBitmap, styles: styles)
        }
        
        /* patterns */
        self.patternsProperty.lazyCompute = {
            return stackReader.readPatterns()
        }
        
        /* script */
        self.scriptProperty.lazyCompute = {
            return stackReader.readScript()
        }
        
        /* font names */
        self.fontNameReferencesProperty.lazyCompute = {
            return fileReader.extractFontBlockReader()?.readFontReferences() ?? []
        }
        
        
    }
    
    private static func listCards(fileReader: HyperCardFileReader, loadBitmap: @escaping (Int) -> BitmapBlockReader, styles: [IndexedStyle], backgroundsProperty: Property<[Background]>) -> [Card] {
        
        var cards: [Card] = []
        
        /* Get the pages in the list */
        let listReader = fileReader.extractListReader()
        let pageReferences = listReader.readPageReferences()
        
        for pageReference in pageReferences {
            
            /* Get the cards in the page */
            let pageReader = fileReader.extractPageReader(from: pageReference)
            let cardReferences = pageReader.readCardReferences()
            
            for cardReference in cardReferences {
                
                /* Find the card data */
                let cardReader = fileReader.extractCardReader(withIdentifier: cardReference.identifier)
                
                /* Find the background */
                let backgroundIdentifier = cardReader.readBackgroundIdentifier()
                let backgrounds = backgroundsProperty.value
                let background = backgrounds.first(where: { $0.identifier == backgroundIdentifier })!
                
                /* Build the card */
                let card = Card(cardReader: cardReader, cardReference: cardReference, loadBitmap: loadBitmap, styles: styles, background: background)
                cards.append(card)
            }
        }
        
        return cards
    }
    
    private static func listBackgrounds(fileReader: HyperCardFileReader, stackReader: StackBlockReader, loadBitmap: @escaping (Int) -> BitmapBlockReader, styles: [IndexedStyle]) -> [Background] {
        
        var backgrounds: [Background] = []
        
        /* Get the identifier of the first background of the stack */
        let firstBackgroundIdentifier = stackReader.readFirstBackgroundIdentifier()
        
        var currentIdentifier = firstBackgroundIdentifier
        
        repeat {
            
            /* Add the background with the current identifier */
            let backgroundReader = fileReader.extractBackgroundReader(withIdentifier: currentIdentifier)
            let background = Background(backgroundReader: backgroundReader, loadBitmap: loadBitmap, styles: styles)
            backgrounds.append(background)
            
            /* Move to the next identifier */
            currentIdentifier = backgroundReader.readNextBackgroundIdentifier()
            
        } while currentIdentifier != firstBackgroundIdentifier
        
        return backgrounds
    }
    
}
