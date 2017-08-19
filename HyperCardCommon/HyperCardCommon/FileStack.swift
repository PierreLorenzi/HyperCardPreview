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
        let stackBlock = fileContent.stack
        
        /* Cards */
        let cardsInitializer = LazyInitializer(property: self.cardsProperty, initialization: {
            let cardBlocks = fileContent.cards
            return cardBlocks.map({ return self.wrapCardBlock(cardBlock: $0, fileContent: fileContent) })
        })
        self.cardsProperty.observers.append(cardsInitializer)
        
        /* Backgrounds */
        let backgroundsInitializer = LazyInitializer(property: self.backgroundsProperty, initialization: {
            let backgroundBlocks = fileContent.backgrounds
            return backgroundBlocks.map({ (block: BackgroundBlock) -> Background in
                return Background(backgroundBlock: block, fileContent: fileContent)
            })
        })
        self.backgroundsProperty.observers.append(backgroundsInitializer)
        
        /* passwordHash */
        self.passwordHashProperty.observers.append(LazyInitializer(property: self.passwordHashProperty, initialization: {
            return stackBlock.passwordHash
        }))
        
        /* userLevel */
        self.userLevelProperty.observers.append(LazyInitializer(property: self.userLevelProperty, initialization: {
            return stackBlock.userLevel
        }))
        
        /* cantAbort */
        self.cantAbortProperty.observers.append(LazyInitializer(property: self.cantAbortProperty, initialization: {
            return stackBlock.cantAbort
        }))
        
        /* cantDelete */
        self.cantDeleteProperty.observers.append(LazyInitializer(property: self.cantDeleteProperty, initialization: {
            return stackBlock.cantDelete
        }))
        
        /* cantModify */
        self.cantModifyProperty.observers.append(LazyInitializer(property: self.cantModifyProperty, initialization: {
            return stackBlock.cantModify
        }))
        
        /* cantPeek */
        self.cantPeekProperty.observers.append(LazyInitializer(property: self.cantPeekProperty, initialization: {
            return stackBlock.cantPeek
        }))
        
        /* privateAccess */
        self.privateAccessProperty.observers.append(LazyInitializer(property: self.privateAccessProperty, initialization: {
            return stackBlock.privateAccess
        }))
        
        /* versionAtCreation */
        self.versionAtCreationProperty.observers.append(LazyInitializer(property: self.versionAtCreationProperty, initialization: {
            return stackBlock.versionAtCreation
        }))
        
        /* versionAtLastCompacting */
        self.versionAtLastCompactingProperty.observers.append(LazyInitializer(property: self.versionAtLastCompactingProperty, initialization: {
            return stackBlock.versionAtLastCompacting
        }))
        
        /* versionAtLastModificationSinceLastCompacting */
        self.versionAtLastModificationSinceLastCompactingProperty.observers.append(LazyInitializer(property: self.versionAtLastModificationSinceLastCompactingProperty, initialization: {
            return stackBlock.versionAtLastModificationSinceLastCompacting
        }))
        
        /* versionAtLastModification */
        self.versionAtLastModificationProperty.observers.append(LazyInitializer(property: self.versionAtLastModificationProperty, initialization: {
            return stackBlock.versionAtLastModification
        }))
        
        /* size */
        self.sizeProperty.observers.append(LazyInitializer(property: self.sizeProperty, initialization: {
            return stackBlock.size
        }))
        
        /* windowRectangle */
        self.windowRectangleProperty.observers.append(LazyInitializer(property: self.windowRectangleProperty, initialization: {
            return stackBlock.windowRectangle
        }))
        
        /* screenRectangle */
        self.screenRectangleProperty.observers.append(LazyInitializer(property: self.screenRectangleProperty, initialization: {
            return stackBlock.screenRectangle
        }))
        
        /* scrollPoint */
        self.scrollPointProperty.observers.append(LazyInitializer(property: self.scrollPointProperty, initialization: {
            return stackBlock.scrollPoint
        }))
        
        /* patterns */
        self.patternsProperty.observers.append(LazyInitializer(property: self.patternsProperty, initialization: {
            return stackBlock.patterns
        }))
        
        /* script */
        self.scriptProperty.observers.append(LazyInitializer(property: self.scriptProperty, initialization: {
            return stackBlock.script
        }))

        
    }
    
    private func wrapCardBlock(cardBlock: CardBlock, fileContent: HyperCardFileData) -> Card {
        
        /* Find the card background */
        let backgroundIdentifer = cardBlock.backgroundIdentifier
        let backgroundIndex = self.backgrounds.index(where: {$0.identifier == backgroundIdentifer})!
        let background = self.backgrounds[backgroundIndex]
        
        /* Build the card */
        return Card(cardBlock: cardBlock, fileContent: fileContent, background: background)
    }
    
}

