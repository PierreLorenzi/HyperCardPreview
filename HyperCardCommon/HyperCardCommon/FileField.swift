//
//  HyperCardFileField.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 26/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


/// Subclass of Field with lazy loading from a file
/// <p>
/// Lazy loading is implemented by hand because an inherited property can't be made
/// lazy in swift.
public class FileField: Field {
    
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
    public override var content: PartContent {
        get {
            if !contentLoaded {
                super.content = Layer.loadContent(identifier: partBlock.identifier, layerBlock: layerBlock, fileContent: fileContent)
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
    
    private var lockTextLoaded = false
    public override var lockText: Bool {
        get {
            if !lockTextLoaded {
                super.lockText = partBlock.lockText
                lockTextLoaded = true
            }
            return super.lockText
        }
        set {
            lockTextLoaded = true
            super.lockText = newValue
        }
    }
    
    private var autoTabLoaded = false
    public override var autoTab: Bool {
        get {
            if !autoTabLoaded {
                super.autoTab = partBlock.autoTab
                autoTabLoaded = true
            }
            return super.autoTab
        }
        set {
            autoTabLoaded = true
            super.autoTab = newValue
        }
    }
    
    private var fixedLineHeightLoaded = false
    public override var fixedLineHeight: Bool {
        get {
            if !fixedLineHeightLoaded {
                super.fixedLineHeight = partBlock.fixedLineHeight
                fixedLineHeightLoaded = true
            }
            return super.fixedLineHeight
        }
        set {
            fixedLineHeightLoaded = true
            super.fixedLineHeight = newValue
        }
    }
    
    private var sharedTextLoaded = false
    public override var sharedText: Bool {
        get {
            if !sharedTextLoaded {
                super.sharedText = partBlock.sharedText
                sharedTextLoaded = true
            }
            return super.sharedText
        }
        set {
            sharedTextLoaded = true
            super.sharedText = newValue
        }
    }
    
    private var dontSearchLoaded = false
    public override var dontSearch: Bool {
        get {
            if !dontSearchLoaded {
                super.dontSearch = partBlock.dontSearch
                dontSearchLoaded = true
            }
            return super.dontSearch
        }
        set {
            dontSearchLoaded = true
            super.dontSearch = newValue
        }
    }
    
    private var dontWrapLoaded = false
    public override var dontWrap: Bool {
        get {
            if !dontWrapLoaded {
                super.dontWrap = partBlock.dontWrap
                dontWrapLoaded = true
            }
            return super.dontWrap
        }
        set {
            dontWrapLoaded = true
            super.dontWrap = newValue
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
    
    private var multipleLinesLoaded = false
    public override var multipleLines: Bool {
        get {
            if !multipleLinesLoaded {
                super.multipleLines = partBlock.multipleLines
                multipleLinesLoaded = true
            }
            return super.multipleLines
        }
        set {
            multipleLinesLoaded = true
            super.multipleLines = newValue
        }
    }
    
    private var wideMarginsLoaded = false
    public override var wideMargins: Bool {
        get {
            if !wideMarginsLoaded {
                super.wideMargins = partBlock.wideMargins
                wideMarginsLoaded = true
            }
            return super.wideMargins
        }
        set {
            wideMarginsLoaded = true
            super.wideMargins = newValue
        }
    }
    
    private var showLinesLoaded = false
    public override var showLines: Bool {
        get {
            if !showLinesLoaded {
                super.showLines = partBlock.showLines
                showLinesLoaded = true
            }
            return super.showLines
        }
        set {
            showLinesLoaded = true
            super.showLines = newValue
        }
    }
    
    private var autoSelectLoaded = false
    public override var autoSelect: Bool {
        get {
            if !autoSelectLoaded {
                super.autoSelect = partBlock.autoSelect
                autoSelectLoaded = true
            }
            return super.autoSelect
        }
        set {
            autoSelectLoaded = true
            super.autoSelect = newValue
        }
    }
    
    private var selectedLineLoaded = false
    public override var selectedLine: Int {
        get {
            if !selectedLineLoaded {
                super.selectedLine = partBlock.selectedLine
                selectedLineLoaded = true
            }
            return super.selectedLine
        }
        set {
            selectedLineLoaded = true
            super.selectedLine = newValue
        }
    }
    
    private var lastSelectedLineLoaded = false
    public override var lastSelectedLine: Int {
        get {
            if !lastSelectedLineLoaded {
                super.lastSelectedLine = partBlock.lastSelectedLine
                lastSelectedLineLoaded = true
            }
            return super.lastSelectedLine
        }
        set {
            lastSelectedLineLoaded = true
            super.lastSelectedLine = newValue
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

