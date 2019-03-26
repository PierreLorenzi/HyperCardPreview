//
//  File.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 27/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


public extension Stack {
    
    /// Loads a stack from the data fork of a stack file. If the stack is private access,
    /// so encrypted, a password can be provided or a hack can be made.
    convenience init(loadFromData data: Data, password possiblePassword: HString? = nil, hackEncryption: Bool = true) throws {
        
        let dataRange = DataRange(sharedData: data, offset: 0, length: data.count)
        let fileReader = StackReader(data: dataRange)
        
        self.init()
        
        /* Get a reader for the stack informations */
        let stackBlock = fileReader.extractStackBlock()
        let stackReader = try StackBlockReader(data: stackBlock, password: possiblePassword, hackEncryption: hackEncryption)
        
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
        let version = stackReader.readVersion()
        let styles = Stack.loadStyles(fileReader: fileReader, stackReader: stackReader)
        let loadBitmap = { (identifier: Int) -> MaskedImage in
            let bitmapBlock = fileReader.extractBitmapBlock(withIdentifier: identifier)
            let bitmapBlockReader = BitmapBlockReader(data: bitmapBlock, version: version)
            return bitmapBlockReader.readImage()
        }
        let loadBackgrounds = { [unowned self] () -> [Background] in
            return self.backgrounds
        }
        
        /* Cards */
        self.cardsProperty.lazyCompute { () -> [Card] in
            return Stack.listCards(fileReader: fileReader, stackReader: stackReader, version: version, loadBitmap: loadBitmap, styles: styles, loadBackgrounds: loadBackgrounds)
        }
        
        /* Backgrounds */
        self.backgroundsProperty.lazyCompute { () -> [Background] in
            return Stack.listBackgrounds(fileReader: fileReader, stackReader: stackReader, version: version, loadBitmap: loadBitmap, styles: styles)
        }
        
        /* patterns */
        self.patternsProperty.lazyCompute {
            return stackReader.readPatterns()
        }
        
        /* script */
        self.scriptProperty.lazyCompute {
            return stackReader.readScript()
        }
        
        /* font names */
        self.fontNameReferencesProperty.lazyCompute {
            return Stack.loadFonts(fileReader: fileReader, stackReader: stackReader)
        }
        
    }
    
    private static func loadStyles(fileReader: StackReader, stackReader: StackBlockReader) -> [IndexedStyle] {
        
        /* Check if there is a style block */
        guard let styleBlockIdentifier = stackReader.readStyleBlockIdentifier() else {
            return []
        }
        
        /* Load the styles */
        let styleBlock = fileReader.extractStyleBlock(withIdentifier: styleBlockIdentifier)
        let styleBlockReader = StyleBlockReader(data: styleBlock)
        return styleBlockReader.readStyles()
    }
    
    private static func loadFonts(fileReader: StackReader, stackReader: StackBlockReader) -> [FontNameReference] {
        
        /* Check if there is a font block */
        guard let fontBlockIdentifier = stackReader.readFontBlockIdentifier() else {
            return []
        }
        
        /* Load the styles */
        let fontBlock = fileReader.extractFontBlock(withIdentifier: fontBlockIdentifier)
        let fontBlockReader = FontBlockReader(data: fontBlock)
        return fontBlockReader.readFontReferences()
    }
    
    private static func listCards(fileReader: StackReader, stackReader: StackBlockReader, version: FileVersion, loadBitmap: @escaping (Int) -> MaskedImage, styles: [IndexedStyle], loadBackgrounds: () -> [Background]) -> [Card] {
        
        var cards: [Card] = []
        
        /* Get the pages in the list */
        let listIdentifier = stackReader.readListIdentifier()
        let listBlock = fileReader.extractListBlock(withIdentifier: listIdentifier)
        let listReader = ListBlockReader(data: listBlock, version: version)
        let pageReferences = listReader.readPageReferences()
        
        /* Get some properties of the list that the pages need */
        let cardReferenceSize = listReader.readCardReferenceSize()
        let hashValueCount = listReader.readHashValueCount()
        
        for pageReference in pageReferences {
            
            /* Get the cards in the page */
            let pageBlock = fileReader.extractPageBlock(withIdentifier: pageReference.identifier)
            let pageReader = PageBlockReader(data: pageBlock, version: version, cardCount: pageReference.cardCount, cardReferenceSize: cardReferenceSize, hashValueCount: hashValueCount)
            let cardReferences = pageReader.readCardReferences()
            
            for cardReference in cardReferences {
                
                /* Find the card data */
                let cardBlock = fileReader.extractCardBlock(withIdentifier: cardReference.identifier)
                let cardReader = CardBlockReader(data: cardBlock, version: version)
                
                /* Find the background */
                let backgroundIdentifier = cardReader.readBackgroundIdentifier()
                let backgrounds = loadBackgrounds()
                let background = backgrounds.first(where: { $0.identifier == backgroundIdentifier })!
                
                /* Build the card */
                let card = Card(loadFromData: cardBlock, version : version, cardReference: cardReference, loadBitmap: loadBitmap, styles: styles, background: background)
                cards.append(card)
            }
        }
        
        return cards
    }
    
    private static func listBackgrounds(fileReader: StackReader, stackReader: StackBlockReader, version: FileVersion, loadBitmap: @escaping (Int) -> MaskedImage, styles: [IndexedStyle]) -> [Background] {
        
        var backgrounds: [Background] = []
        
        /* Get the identifier of the first background of the stack */
        let firstBackgroundIdentifier = stackReader.readFirstBackgroundIdentifier()
        
        var currentIdentifier = firstBackgroundIdentifier
        
        repeat {
            
            /* Add the background with the current identifier */
            let backgroundBlock = fileReader.extractBackgroundBlock(withIdentifier: currentIdentifier)
            let background = Background(loadFromData: backgroundBlock, version: version, loadBitmap: loadBitmap, styles: styles)
            backgrounds.append(background)
            
            /* Move to the next identifier */
            let backgroundReader = BackgroundBlockReader(data: backgroundBlock, version: version)
            currentIdentifier = backgroundReader.readNextBackgroundIdentifier()
            
        } while currentIdentifier != firstBackgroundIdentifier
        
        return backgrounds
    }
    
}
