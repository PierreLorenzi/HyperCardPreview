//
//  HyperCardFileStack.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 26/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


public extension Stack {
    
    public convenience init(fileContent: HyperCardFileData, resources: ResourceRepository?) {
        
        self.init()
        
        /* Register the resources */
        self.resources = resources
        
        /* Enable lazy initialization */
        let stackBlock = fileContent.extractStack()
        
        /* Read now the scalar fields */
        self.passwordHash = stackBlock.readPasswordHash()
        self.userLevel = stackBlock.readUserLevel()
        self.cantAbort = stackBlock.readCantAbort()
        self.cantDelete = stackBlock.readCantDelete()
        self.cantModify = stackBlock.readCantModify()
        self.cantPeek = stackBlock.readCantPeek()
        self.privateAccess = stackBlock.readPrivateAccess()
        self.versionAtCreation = stackBlock.readVersionAtCreation()
        self.versionAtLastCompacting = stackBlock.readVersionAtLastCompacting()
        self.versionAtLastModificationSinceLastCompacting = stackBlock.readVersionAtLastModificationSinceLastCompacting()
        self.versionAtLastModification = stackBlock.readVersionAtLastModification()
        self.size = stackBlock.readSize()
        self.windowRectangle = stackBlock.readWindowRectangle()
        self.screenRectangle = stackBlock.readScreenRectangle()
        self.scrollPoint = stackBlock.readScrollPoint()
        
        /* Cards */
        self.cardsProperty.lazyCompute = {
            let cardBlocks = fileContent.extractCards()
            return cardBlocks.map({ [unowned self] in return self.wrapCardBlock(cardBlock: $0, fileContent: fileContent) })
        }
        
        /* Backgrounds */
        self.backgroundsProperty.lazyCompute = {
            let backgroundBlocks = fileContent.extractBackgrounds()
            return backgroundBlocks.map({ (block: BackgroundBlock) -> Background in
                return Background(backgroundBlock: block, fileContent: fileContent)
            })
        }
        
        /* patterns */
        self.patternsProperty.lazyCompute = {
            return stackBlock.readPatterns()
        }
        
        /* script */
        self.scriptProperty.lazyCompute = {
            return stackBlock.readScript()
        }
        
        /* font names */
        self.fontNameReferencesProperty.lazyCompute = {
            return fileContent.extractFontBlock()?.fontReferences ?? []
        }

        
    }
    
    private func wrapCardBlock(cardBlock: CardBlock, fileContent: HyperCardFileData) -> Card {
        
        /* Find the card background */
        let backgroundIdentifer = cardBlock.readBackgroundIdentifier()
        let backgroundIndex = self.backgrounds.index(where: {$0.identifier == backgroundIdentifer})!
        let background = self.backgrounds[backgroundIndex]
        
        /* Build the card */
        return Card(cardBlock: cardBlock, fileContent: fileContent, background: background)
    }
    
}

