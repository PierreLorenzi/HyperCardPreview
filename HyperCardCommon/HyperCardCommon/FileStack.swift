//
//  HyperCardFileStack.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 26/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


/// Subclass of Stack with lazy loading from a file
/// <p>
/// Lazy loading is implemented by hand because an inherited property can't be made
/// lazy in swift.
public class FileStack: Stack {
    
    private let fileContent: HyperCardFileData
    private let stackBlock: StackBlock
    
    public init(fileContent: HyperCardFileData, resources: ResourceRepository?) {
        self.fileContent = fileContent
        self.stackBlock = fileContent.stack
        
        super.init()
        
        self.resources = resources
    }
    
    private var cardsLoaded = false
    public override var cards: [Card] {
        get {
            if !cardsLoaded {
                
                /* Build card wrappers around the card blocks */
                let cardBlocks = fileContent.cards
                let cards = cardBlocks.map(wrapCardBlock)
                
                super.cards = cards
                cardsLoaded = true
            }
            return super.cards
        }
        set {
            cardsLoaded = true
            super.cards = newValue
        }
    }
    
    private func wrapCardBlock(cardBlock: CardBlock) -> FileCard {
        
        /* Find the card background */
        let backgroundIdentifer = cardBlock.backgroundIdentifier
        let backgroundIndex = self.backgrounds.index(where: {$0.identifier == backgroundIdentifer})!
        let background = self.backgrounds[backgroundIndex]
        
        /* Build the card */
        return FileCard(cardBlock: cardBlock, fileContent: fileContent, background: background)
    }
    
    private var backgroundsLoaded = false
    public override var backgrounds: [Background] {
        get {
            if !backgroundsLoaded {
                
                /* Build background wrappers around the background blocks */
                let backgroundBlocks = fileContent.backgrounds
                let backgrounds = backgroundBlocks.map({ (block: BackgroundBlock) -> Background in
                    return FileBackground(backgroundBlock: block, fileContent: fileContent)
                })
                
                super.backgrounds = backgrounds
                backgroundsLoaded = true
            }
            return super.backgrounds
        }
        set {
            backgroundsLoaded = true
            super.backgrounds = newValue
        }
    }
    
    private var passwordHashLoaded = false
    public override var passwordHash: Int? {
        get {
            if !passwordHashLoaded {
                super.passwordHash = stackBlock.passwordHash
                passwordHashLoaded = true
            }
            return super.passwordHash
        }
        set {
            passwordHashLoaded = true
            super.passwordHash = newValue
        }
    }
    
    private var userLevelLoaded = false
    public override var userLevel: UserLevel {
        get {
            if !userLevelLoaded {
                super.userLevel = stackBlock.userLevel
                userLevelLoaded = true
            }
            return super.userLevel
        }
        set {
            userLevelLoaded = true
            super.userLevel = newValue
        }
    }
    
    private var cantAbortLoaded = false
    public override var cantAbort: Bool {
        get {
            if !cantAbortLoaded {
                super.cantAbort = stackBlock.cantAbort
                cantAbortLoaded = true
            }
            return super.cantAbort
        }
        set {
            cantAbortLoaded = true
            super.cantAbort = newValue
        }
    }
    
    private var cantDeleteLoaded = false
    public override var cantDelete: Bool {
        get {
            if !cantDeleteLoaded {
                super.cantDelete = stackBlock.cantDelete
                cantDeleteLoaded = true
            }
            return super.cantDelete
        }
        set {
            cantDeleteLoaded = true
            super.cantDelete = newValue
        }
    }
    
    private var cantModifyLoaded = false
    public override var cantModify: Bool {
        get {
            if !cantModifyLoaded {
                super.cantModify = stackBlock.cantModify
                cantModifyLoaded = true
            }
            return super.cantModify
        }
        set {
            cantModifyLoaded = true
            super.cantModify = newValue
        }
    }
    
    private var cantPeekLoaded = false
    public override var cantPeek: Bool {
        get {
            if !cantPeekLoaded {
                super.cantPeek = stackBlock.cantPeek
                cantPeekLoaded = true
            }
            return super.cantPeek
        }
        set {
            cantPeekLoaded = true
            super.cantPeek = newValue
        }
    }
    
    private var privateAccessLoaded = false
    public override var privateAccess: Bool {
        get {
            if !privateAccessLoaded {
                super.privateAccess = stackBlock.privateAccess
                privateAccessLoaded = true
            }
            return super.privateAccess
        }
        set {
            privateAccessLoaded = true
            super.privateAccess = newValue
        }
    }
    
    private var versionAtCreationLoaded = false
    public override var versionAtCreation: Version? {
        get {
            if !versionAtCreationLoaded {
                super.versionAtCreation = stackBlock.versionAtCreation
                versionAtCreationLoaded = true
            }
            return super.versionAtCreation
        }
        set {
            versionAtCreationLoaded = true
            super.versionAtCreation = newValue
        }
    }
    
    private var versionAtLastCompactingLoaded = false
    public override var versionAtLastCompacting: Version? {
        get {
            if !versionAtLastCompactingLoaded {
                super.versionAtLastCompacting = stackBlock.versionAtLastCompacting
                versionAtLastCompactingLoaded = true
            }
            return super.versionAtLastCompacting
        }
        set {
            versionAtLastCompactingLoaded = true
            super.versionAtLastCompacting = newValue
        }
    }
    
    private var versionAtLastModificationSinceLastCompactingLoaded = false
    public override var versionAtLastModificationSinceLastCompacting: Version? {
        get {
            if !versionAtLastModificationSinceLastCompactingLoaded {
                super.versionAtLastModificationSinceLastCompacting = stackBlock.versionAtLastModificationSinceLastCompacting
                versionAtLastModificationSinceLastCompactingLoaded = true
            }
            return super.versionAtLastModificationSinceLastCompacting
        }
        set {
            versionAtLastModificationSinceLastCompactingLoaded = true
            super.versionAtLastModificationSinceLastCompacting = newValue
        }
    }
    
    private var versionAtLastModificationLoaded = false
    public override var versionAtLastModification: Version? {
        get {
            if !versionAtLastModificationLoaded {
                super.versionAtLastModification = stackBlock.versionAtLastModification
                versionAtLastModificationLoaded = true
            }
            return super.versionAtLastModification
        }
        set {
            versionAtLastModificationLoaded = true
            super.versionAtLastModification = newValue
        }
    }
    
    private var sizeLoaded = false
    public override var size: Size {
        get {
            if !sizeLoaded {
                super.size = stackBlock.size
                sizeLoaded = true
            }
            return super.size
        }
        set {
            sizeLoaded = true
            super.size = newValue
        }
    }
    
    private var windowRectangleLoaded = false
    public override var windowRectangle: Rectangle? {
        get {
            if !windowRectangleLoaded {
                super.windowRectangle = stackBlock.windowRectangle
                windowRectangleLoaded = true
            }
            return super.windowRectangle
        }
        set {
            windowRectangleLoaded = true
            super.windowRectangle = newValue
        }
    }
    
    private var screenRectangleLoaded = false
    public override var screenRectangle: Rectangle? {
        get {
            if !screenRectangleLoaded {
                super.screenRectangle = stackBlock.screenRectangle
                screenRectangleLoaded = true
            }
            return super.screenRectangle
        }
        set {
            screenRectangleLoaded = true
            super.screenRectangle = newValue
        }
    }
    
    private var scrollPointLoaded = false
    public override var scrollPoint: Point? {
        get {
            if !scrollPointLoaded {
                super.scrollPoint = stackBlock.scrollPoint
                scrollPointLoaded = true
            }
            return super.scrollPoint
        }
        set {
            scrollPointLoaded = true
            super.scrollPoint = newValue
        }
    }
    
    private var patternsLoaded = false
    public override var patterns: [Image] {
        get {
            if !patternsLoaded {
                super.patterns = stackBlock.patterns
                patternsLoaded = true
            }
            return super.patterns
        }
        set {
            patternsLoaded = true
            super.patterns = newValue
        }
    }
    
    private var scriptLoaded = false
    public override var script: HString {
        get {
            if !scriptLoaded {
                super.script = stackBlock.script
                scriptLoaded = true
            }
            return super.script
        }
        set {
            scriptLoaded = true
            super.script = newValue
        }
    }
    
}

