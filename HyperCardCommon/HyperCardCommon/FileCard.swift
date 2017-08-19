//
//  HyperCardFileCard.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 26/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


/// Subclass of Card with lazy loading from a file
/// <p>
/// Lazy loading is implemented by hand because an inherited property can't be made
/// lazy in swift.
public class FileCard: Card {
    
    private let cardBlock: CardBlock
    private let fileContent: HyperCardFileData
    
    public init(cardBlock: CardBlock, fileContent: HyperCardFileData, background: Background) {
        self.cardBlock = cardBlock
        self.fileContent = fileContent
        
        super.init(background: background)
    }
    
    private var identifierLoaded = false
    public override var identifier: Int {
        get {
            if !identifierLoaded {
                super.identifier = cardBlock.identifier
                identifierLoaded = true
            }
            return super.identifier
        }
        set {
            identifierLoaded = true
            super.identifier = newValue
        }
    }
    
    private var nameLoaded = false
    public override var name: HString {
        get {
            if !nameLoaded {
                super.name = cardBlock.name
                nameLoaded = true
            }
            return super.name
        }
        set {
            nameLoaded = true
            super.name = newValue
        }
    }
    
    private var cantDeleteLoaded = false
    public override var cantDelete: Bool {
        get {
            if !cantDeleteLoaded {
                super.cantDelete = cardBlock.cantDelete
                cantDeleteLoaded = true
            }
            return super.cantDelete
        }
        set {
            cantDeleteLoaded = true
            super.cantDelete = newValue
        }
    }
    
    private var showPictLoaded = false
    public override var showPict: Bool {
        get {
            if !showPictLoaded {
                super.showPict = cardBlock.showPict
                showPictLoaded = true
            }
            return super.showPict
        }
        set {
            showPictLoaded = true
            super.showPict = newValue
        }
    }
    
    private var dontSearchLoaded = false
    public override var dontSearch: Bool {
        get {
            if !dontSearchLoaded {
                super.dontSearch = cardBlock.dontSearch
                dontSearchLoaded = true
            }
            return super.dontSearch
        }
        set {
            dontSearchLoaded = true
            super.dontSearch = newValue
        }
    }
    
    private var markedLoaded = false
    public override var marked: Bool {
        get {
            if !markedLoaded {
                super.marked = cardBlock.marked
                markedLoaded = true
            }
            return super.marked
        }
        set {
            markedLoaded = true
            super.marked = newValue
        }
    }
    
    private var searchHashLoaded = false
    public override var searchHash: SearchHash? {
        get {
            if !searchHashLoaded {
                super.searchHash = cardBlock.searchHash
                searchHashLoaded = true
            }
            return super.searchHash
        }
        set {
            searchHashLoaded = true
            super.searchHash = newValue
        }
    }
    
    private var backgroundPartContentsLoaded = false
    public override var backgroundPartContents: [BackgroundPartContent] {
        get {
            if !backgroundPartContentsLoaded {
                super.backgroundPartContents = loadBackgroundPartContents()
                backgroundPartContentsLoaded = true
            }
            return super.backgroundPartContents
        }
        set {
            backgroundPartContentsLoaded = true
            super.backgroundPartContents = newValue
        }
    }
    
    private func loadBackgroundPartContents() -> [BackgroundPartContent] {
        
        /* Get the contents */
        let contents = cardBlock.contents
        
        /* Keep only the background ones */
        let backgroundContents = contents.filter({$0.layerType == .background})
        
        /* Load them */
        let result = backgroundContents.map({
            (block: ContentBlock) -> Card.BackgroundPartContent in
            let identifier = block.identifier
            let content = FileLayer.loadContentFromBlock(content: block, layerBlock: cardBlock, fileContent: fileContent)
            return BackgroundPartContent(partIdentifier: identifier, partContent: content)
        })
        
        return result
        
    }
    
    private var scriptLoaded = false
    public override var script: HString {
        get {
            if !scriptLoaded {
                super.script = cardBlock.script
                scriptLoaded = true
            }
            return super.script
        }
        set {
            scriptLoaded = true
            super.script = newValue
        }
    }
    
    private var imageLoaded = false
    public override var image: MaskedImage? {
        get {
            if !imageLoaded {
                super.image = FileLayer.loadImage(layerBlock: cardBlock, fileContent: fileContent)
                imageLoaded = true
            }
            return super.image
        }
        set {
            imageLoaded = true
            super.image = newValue
        }
    }
    
    private var partsLoaded = false
    public override var parts: [LayerPart] {
        get {
            if !partsLoaded {
                super.parts = FileLayer.loadParts(layerBlock: cardBlock, fileContent: fileContent)
                partsLoaded = true
            }
            return super.parts
        }
        set {
            partsLoaded = true
            super.parts = newValue
        }
    }
    
    private var nextAvailablePartIdentifierLoaded = false
    public override var nextAvailablePartIdentifier: Int {
        get {
            if !nextAvailablePartIdentifierLoaded {
                super.nextAvailablePartIdentifier = cardBlock.nextAvailableIdentifier
                nextAvailablePartIdentifierLoaded = true
            }
            return super.nextAvailablePartIdentifier
        }
        set {
            nextAvailablePartIdentifierLoaded = true
            super.nextAvailablePartIdentifier = newValue
        }
    }
    
}
