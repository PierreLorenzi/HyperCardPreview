//
//  HyperCardFileButton.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 26/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//

/// Subclass of Button with lazy loading from a file
/// <p>
/// Lazy loading is implemented by hand because an inherited property can't be made
/// lazy in swift.
public class FileButton: Button {
    
    private let partBlock: PartBlock
    private let layerBlock: LayerBlock
    private let fileContent: HyperCardFileData
    
    public init(partBlock: PartBlock, layerBlock: LayerBlock, fileContent: HyperCardFileData) {
        self.partBlock = partBlock
        self.layerBlock = layerBlock
        self.fileContent = fileContent
        super.init()
    }
    
    private var identifierLoaded = false
    public override var identifier: Int {
        get {
            if !identifierLoaded {
                super.identifier = partBlock.identifier
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
                super.name = partBlock.name
                nameLoaded = true
            }
            return super.name
        }
        set {
            nameLoaded = true
            super.name = newValue
        }
    }
    
    private var styleLoaded = false
    public override var style: PartStyle {
        get {
            if !styleLoaded {
                super.style = partBlock.style
                styleLoaded = true
            }
            return super.style
        }
        set {
            styleLoaded = true
            super.style = newValue
        }
    }
    
    private var contentLoaded = false
    public override var content: HString {
        get {
            if !contentLoaded {
                let partContent = Layer.loadContent(identifier: partBlock.identifier, layerBlock: layerBlock, fileContent: fileContent)
                super.content = partContent.string
                contentLoaded = true
            }
            return super.content
        }
        set {
            contentLoaded = true
            super.content = newValue
        }
    }
    
    private var rectangleLoaded = false
    public override var rectangle: Rectangle {
        get {
            if !rectangleLoaded {
                super.rectangle = partBlock.rectangle
                rectangleLoaded = true
            }
            return super.rectangle
        }
        set {
            rectangleLoaded = true
            super.rectangle = newValue
        }
    }
    
    private var scriptLoaded = false
    public override var script: HString {
        get {
            if !scriptLoaded {
                super.script = partBlock.script
                scriptLoaded = true
            }
            return super.script
        }
        set {
            scriptLoaded = true
            super.script = newValue
        }
    }
    
    private var enabledLoaded = false
    public override var enabled: Bool {
        get {
            if !enabledLoaded {
                super.enabled = partBlock.enabled
                enabledLoaded = true
            }
            return super.enabled
        }
        set {
            enabledLoaded = true
            super.enabled = newValue
        }
    }
    
    private var visibleLoaded = false
    public override var visible: Bool {
        get {
            if !visibleLoaded {
                super.visible = partBlock.visible
                visibleLoaded = true
            }
            return super.visible
        }
        set {
            visibleLoaded = true
            super.visible = newValue
        }
    }
    
    private var hiliteLoaded = false
    public override var hilite: Bool {
        get {
            if !hiliteLoaded {
                super.hilite = partBlock.hilite
                hiliteLoaded = true
            }
            return super.hilite
        }
        set {
            hiliteLoaded = true
            super.hilite = newValue
        }
    }
    
    private var autoHiliteLoaded = false
    public override var autoHilite: Bool {
        get {
            if !autoHiliteLoaded {
                super.autoHilite = partBlock.autoHilite
                autoHiliteLoaded = true
            }
            return super.autoHilite
        }
        set {
            autoHiliteLoaded = true
            super.autoHilite = newValue
        }
    }
    
    private var sharedHiliteLoaded = false
    public override var sharedHilite: Bool {
        get {
            if !sharedHiliteLoaded {
                super.sharedHilite = partBlock.sharedHilite
                sharedHiliteLoaded = true
            }
            return super.sharedHilite
        }
        set {
            sharedHiliteLoaded = true
            super.sharedHilite = newValue
        }
    }
    
    private var showNameLoaded = false
    public override var showName: Bool {
        get {
            if !showNameLoaded {
                super.showName = partBlock.showName
                showNameLoaded = true
            }
            return super.showName
        }
        set {
            showNameLoaded = true
            super.showName = newValue
        }
    }
    
    private var iconIdentifierLoaded = false
    public override var iconIdentifier: Int {
        get {
            if !iconIdentifierLoaded {
                super.iconIdentifier = partBlock.icon
                iconIdentifierLoaded = true
            }
            return super.iconIdentifier
        }
        set {
            iconIdentifierLoaded = true
            super.iconIdentifier = newValue
        }
    }
    
    private var selectedItemLoaded = false
    public override var selectedItem: Int {
        get {
            if !selectedItemLoaded {
                super.selectedItem = partBlock.selectedLine
                selectedItemLoaded = true
            }
            return super.selectedItem
        }
        set {
            selectedItemLoaded = true
            super.selectedItem = newValue
        }
    }
    
    private var familyLoaded = false
    public override var family: Int {
        get {
            if !familyLoaded {
                super.family = partBlock.family
                familyLoaded = true
            }
            return super.family
        }
        set {
            familyLoaded = true
            super.family = newValue
        }
    }
    
    private var titleWidthLoaded = false
    public override var titleWidth: Int {
        get {
            if !titleWidthLoaded {
                super.titleWidth = partBlock.titleWidth
                titleWidthLoaded = true
            }
            return super.titleWidth
        }
        set {
            titleWidthLoaded = true
            super.titleWidth = newValue
        }
    }
    
    private var textAlignLoaded = false
    public override var textAlign: TextAlign {
        get {
            if !textAlignLoaded {
                super.textAlign = partBlock.textAlign
                textAlignLoaded = true
            }
            return super.textAlign
        }
        set {
            textAlignLoaded = true
            super.textAlign = newValue
        }
    }
    
    private var textFontIdentifierLoaded = false
    public override var textFontIdentifier: Int {
        get {
            if !textFontIdentifierLoaded {
                super.textFontIdentifier = partBlock.textFontIdentifier
                textFontIdentifierLoaded = true
            }
            return super.textFontIdentifier
        }
        set {
            textFontIdentifierLoaded = true
            super.textFontIdentifier = newValue
        }
    }
    
    private var textFontSizeLoaded = false
    public override var textFontSize: Int {
        get {
            if !textFontSizeLoaded {
                super.textFontSize = partBlock.textFontSize
                textFontSizeLoaded = true
            }
            return super.textFontSize
        }
        set {
            textFontSizeLoaded = true
            super.textFontSize = newValue
        }
    }
    
    private var textStyleLoaded = false
    public override var textStyle: TextStyle {
        get {
            if !textStyleLoaded {
                super.textStyle = partBlock.textStyle
                textStyleLoaded = true
            }
            return super.textStyle
        }
        set {
            textStyleLoaded = true
            super.textStyle = newValue
        }
    }
    
    private var textHeightLoaded = false
    public override var textHeight: Int {
        get {
            if !textHeightLoaded {
                super.textHeight = partBlock.textHeight
                textHeightLoaded = true
            }
            return super.textHeight
        }
        set {
            textHeightLoaded = true
            super.textHeight = newValue
        }
    }
    
}
