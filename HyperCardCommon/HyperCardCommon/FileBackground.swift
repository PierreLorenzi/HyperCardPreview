//
//  HyperCardFileBackground.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 26/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//

/// Subclass of Background with lazy loading from a file
/// <p>
/// Lazy loading is implemented by hand because an inherited property can't be made
/// lazy in swift.
public class FileBackground: Background {
    
    private let backgroundBlock: BackgroundBlock
    private let fileContent: HyperCardFileData
    
    public init(backgroundBlock: BackgroundBlock, fileContent: HyperCardFileData) {
        self.backgroundBlock = backgroundBlock
        self.fileContent = fileContent
    }
    
    private var identifierLoaded = false
    public override var identifier: Int {
        get {
            if !identifierLoaded {
                super.identifier = backgroundBlock.identifier
                identifierLoaded = true
            }
            return super.identifier
        }
        set {
            super.identifier = newValue
        }
    }
    
    private var nameLoaded = false
    public override var name: HString {
        get {
            if !nameLoaded {
                super.name = backgroundBlock.name
                nameLoaded = true
            }
            return super.name
        }
        set {
            super.name = newValue
        }
    }
    
    private var cantDeleteLoaded = false
    public override var cantDelete: Bool {
        get {
            if !cantDeleteLoaded {
                super.cantDelete = backgroundBlock.cantDelete
                cantDeleteLoaded = true
            }
            return super.cantDelete
        }
        set {
            super.cantDelete = newValue
        }
    }
    
    private var showPictLoaded = false
    public override var showPict: Bool {
        get {
            if !showPictLoaded {
                super.showPict = backgroundBlock.showPict
                showPictLoaded = true
            }
            return super.showPict
        }
        set {
            super.showPict = newValue
        }
    }
    
    private var dontSearchLoaded = false
    public override var dontSearch: Bool {
        get {
            if !dontSearchLoaded {
                super.dontSearch = backgroundBlock.dontSearch
                dontSearchLoaded = true
            }
            return super.dontSearch
        }
        set {
            super.dontSearch = newValue
        }
    }
    
    private var scriptLoaded = false
    public override var script: HString {
        get {
            if !scriptLoaded {
                super.script = backgroundBlock.script
                scriptLoaded = true
            }
            return super.script
        }
        set {
            super.script = newValue
        }
    }
    
    private var imageLoaded = false
    public override var image: MaskedImage? {
        get {
            if !imageLoaded {
                super.image = FileLayer.loadImage(layerBlock: backgroundBlock, fileContent: fileContent)
                imageLoaded = true
            }
            return super.image
        }
        set {
            super.image = newValue
        }
    }
    
    private var partsLoaded = false
    public override var parts: [LayerPart] {
        get {
            if !partsLoaded {
                super.parts = FileLayer.loadParts(layerBlock: backgroundBlock, fileContent: fileContent)
                partsLoaded = true
            }
            return super.parts
        }
        set {
            super.parts = newValue
        }
    }
    
    private var nextAvailablePartIdentifierLoaded = false
    public override var nextAvailablePartIdentifier: Int {
        get {
            if !nextAvailablePartIdentifierLoaded {
                super.nextAvailablePartIdentifier = backgroundBlock.nextAvailableIdentifier
                nextAvailablePartIdentifierLoaded = true
            }
            return super.nextAvailablePartIdentifier
        }
        set {
            super.nextAvailablePartIdentifier = newValue
        }
    }
    
}
