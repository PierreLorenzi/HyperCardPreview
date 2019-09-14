//
//  InfoPanel.swift
//  HyperCardPreview
//
//  Created by Pierre Lorenzi on 10/03/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//

import AppKit
import HyperCardCommon


class InfoPanelController: NSWindowController, NSTableViewDataSource {
    
    private var infos: [(String, String)] = []
    
    @IBOutlet weak var infoTable: NSTableView!
    @IBOutlet weak var contentView: NSTextView!
    @IBOutlet weak var scriptView: NSTextView!
    @IBOutlet weak var tabView: NSTabView!
    @IBOutlet weak var pictureView: NSImageView!
    @IBOutlet weak var noImageLabel: NSTextField!
    
    private static let textStyleNames: [(KeyPath<TextStyle,Bool>,String)] = [
        (\TextStyle.bold, "bold"),
        (\TextStyle.italic, "italic"),
        (\TextStyle.underline, "underline"),
        (\TextStyle.outline, "outline"),
        (\TextStyle.shadow, "shadow"),
        (\TextStyle.condense, "condense"),
        (\TextStyle.extend, "extend"),
        (\TextStyle.group, "group"),
    ]
    
    private static let partStyleNames: [PartStyle: String] = [
        PartStyle.transparent: "transparent",
        PartStyle.opaque: "opaque",
        PartStyle.rectangle: "rectangle",
        PartStyle.shadow: "shadow",
        PartStyle.scrolling: "scrolling",
        PartStyle.checkBox: "check box",
        PartStyle.radio: "radio",
        PartStyle.standard: "standard",
        PartStyle.`default`: "default",
        PartStyle.oval: "oval",
        PartStyle.popup: "pop-up",
        PartStyle.roundRect: "round rect",
    ]
    
    func setup() {
        
        /* Don't wrap in script */
        scriptView.enclosingScrollView!.hasHorizontalScroller = true
        scriptView.isHorizontallyResizable = true
        scriptView.autoresizingMask = NSView.AutoresizingMask(rawValue: NSView.AutoresizingMask.width.rawValue | NSView.AutoresizingMask.height.rawValue)
        scriptView.textContainer?.containerSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        scriptView.textContainer?.widthTracksTextView = false
        
        /* Monaco */
        scriptView.font = NSFont(name: "Monaco", size: 10)
        
    }
    
    func displayStack(_ hyperCardFile: HyperCardFile) {
        self.window!.title = "Stack"
        let stack = hyperCardFile.stack
        displayScript(stack.script)
        self.deleteContentTab()
        self.deletePictureTab()
        
        let versionAtCreation: String = stack.versionAtCreation?.description ?? "unknown"
        let version: String = stack.versionAtLastModification?.description ?? "unknown"
        
        self.infos = [("Number of Cards", "\(stack.cards.count)"),
            ("Number of Backgrounds", "\(stack.backgrounds.count)"),
            ("Resource Fork", "\(hyperCardFile.resources != nil ? "yes (\(hyperCardFile.resources!.resources.count) resources)" : "no")"),
            ("Password", "\(stack.passwordHash != nil ? "yes" : "no")"),
            ("User Level", "\(stack.userLevel.rawValue) (\(stack.userLevel))"),
            ("Can't Abort", "\(stack.cantAbort ? "yes" : "no")"),
            ("Can't Delete", "\(stack.cantDelete ? "yes" : "no")"),
            ("Can't Modify", "\(stack.cantModify ? "yes" : "no")"),
            ("Can't Peek", "\(stack.cantPeek ? "yes" : "no")"),
            ("Private Access", "\(stack.privateAccess ? "yes" : "no")"),
            ("Stack Format", (stack.fileVersion == .v1) ? "version 1.x.x" : "version 2.x.x"),
            ("Version when created", "\(versionAtCreation)"),
            ("Version when last edited", "\(version)"),
            ("Size", "\(stack.size.width) x \(stack.size.height)")]
        
        self.infoTable.reloadData()
    }
    
    private func deleteContentTab() {
        
        let tabIndex = tabView.indexOfTabViewItem(withIdentifier: "content")
        let tab = tabView.tabViewItem(at: tabIndex)
        tabView.removeTabViewItem(tab)
    }
    
    private func deletePictureTab() {
        
        let tabIndex = tabView.indexOfTabViewItem(withIdentifier: "picture")
        let tab = tabView.tabViewItem(at: tabIndex)
        tabView.removeTabViewItem(tab)
    }
    
    func displayBackground(_ background: Background, number: Int) {
        self.window!.title = self.describeLayer(background, layerType: .background, number: number)
        displayScript(background.script)
        self.deleteContentTab()
        self.displayLayerImage(of: background)
        
        self.infos = [("Name", "\"\(background.name)\""),
            ("Number","\(number)"),
            ("ID","\(background.identifier)"),
            ("Number of parts", "\(background.parts.count)"),
            ("Show Pict", "\(background.showPict ? "yes" : "no")"),
            ("Don't Search", "\(background.dontSearch ? "yes" : "no")"),
            ("Can't Delete", "\(background.cantDelete ? "yes" : "no")")]
        
        self.infoTable.reloadData()
    }
    
    private func describeLayer(_ layer: Layer, layerType: LayerType, number: Int) -> String {
        
        let layerTypeName: String = (layerType == .background) ? "Background" : "Card"
        
        if layer.name.length > 0 {
            return "\(layerTypeName) \"\(layer.name)\""
        }
        return "\(layerTypeName) \(number)"
    }
    
    func displayCard(_ card: Card, number: Int) {
        self.window!.title = self.describeLayer(card, layerType: .card, number: number)
        displayScript(card.script)
        self.deleteContentTab()
        self.displayLayerImage(of: card)
        
        self.infos = [("Name", "\"\(card.name)\""),
            ("Number","\(number)"),
            ("ID","\(card.identifier)"),
            ("Number of parts", "\(card.parts.count)"),
            ("Marked", "\(card.marked ? "yes" : "no")"),
            ("Show Pict", "\(card.showPict ? "yes" : "no")"),
            ("Don't Search", "\(card.dontSearch ? "yes" : "no")"),
            ("Can't Delete", "\(card.cantDelete ? "yes" : "no")")]
        
        self.infoTable.reloadData()
    }
    
    func displayLayerImage(of layer: Layer) {
        
        guard let image = layer.image else {
            self.noImageLabel.stringValue = "No Picture"
            return
        }
        
        let cgImage = RgbConverter.convertMaskedImage(image)
        self.pictureView.image = NSImage(cgImage: cgImage, size: NSZeroSize)
        
        /* Set-up the image view. We make it editable because it is the only way
         the image can be copied */
        self.pictureView.isEditable = true
        self.pictureView.allowsCutCopyPaste = true
    }
    
    func displayButton(_ button: Button, withContent content: HString, layerType: LayerType, number: Int, partNumber: Int, stack: Stack) {
        self.window!.title = self.describePart(part: button, type: .button, layer: layerType, number: number)
        displayScript(button.script)
        contentView.string = content.description.replacingOccurrences(of: "\r", with: "\n")
        self.deletePictureTab()
        
        self.infos = [("Name", "\"\(button.name)\""),
            ("Number", "\(number)"),
            ("Part Number", "\(partNumber)"),
            ("ID", "\(button.identifier)"),
            ("Style", "\(InfoPanelController.partStyleNames[button.style]!)"),
            ("Rectangle", "\(button.rectangle.left),\(button.rectangle.top),\(button.rectangle.right),\(button.rectangle.bottom)"),
            ("Visible", "\(button.visible ? "yes" : "no")"),
            ("Show Name", "\(button.showName ? "yes" : "no")"),
            ("Enabled", "\(button.enabled ? "yes" : "no")"),
            ("Hilite", "\(button.hilite ? "yes" : "no")"),
            ("Auto Hilite", "\(button.autoHilite ? "yes" : "no")"),
            ("Shared Hilite", "\(button.sharedHilite ? "yes" : "no")"),
            ("Icon ID", "\(button.iconIdentifier)"),
            ("Family", "\(button.family)"),
            ("Title Width", "\(button.titleWidth)"),
            ("Text Font", describeTextFont(button.textFontIdentifier, stack: stack)),
            ("Text Size", "\(button.textFontSize)"),
            ("Text Style", "\(self.describeTextStyle(button.textStyle))"),
            ("Text Alignment", "\(button.textAlign)")]
        
        self.infoTable.reloadData()
    }
    
    private func describeTextFont(_ identifier: Int, stack: Stack) -> String {
        
        switch stack.fileVersion {
            
        case .v1:
            /* If the stack is v1, and so doesn't have a font name table, guess the name */
            if let standardName = self.getStandardFontName(identifier) {
                return standardName
            }
            
        case .v2:
            /* Look the name in the font name table */
            if let fontReference = stack.fontNameReferences.first(where: { $0.identifier == identifier }) {
                return fontReference.name.description
            }
        }
        
        /* Last resort */
        return "ID \(identifier)"
    }
    
    private func getStandardFontName(_ identifier: Int) -> String? {
        
        switch identifier {
            
        case FontIdentifiers.chicago:
            return "Chicago"
        case FontIdentifiers.newYork:
            return "New York"
        case FontIdentifiers.geneva:
            return "Geneva"
        case FontIdentifiers.monaco:
            return "Monaco"
        case FontIdentifiers.venice:
            return "Venice"
        case FontIdentifiers.london:
            return "London"
        case FontIdentifiers.athens:
            return "Athens"
        case FontIdentifiers.sanFrancisco:
            return "San Francisco"
        case FontIdentifiers.toronto:
            return "Toronto"
        case FontIdentifiers.cairo:
            return "Cairo"
        case FontIdentifiers.losAngeles:
            return "Los Angeles"
        case FontIdentifiers.palatino:
            return "Palatino"
        case FontIdentifiers.times:
            return "Times"
        case FontIdentifiers.helvetica:
            return "Helvetica"
        case FontIdentifiers.courier:
            return "Courier"
        case FontIdentifiers.symbol:
            return "Symbol"
        case FontIdentifiers.taliesin:
            return "Taliesin"
        case FontIdentifiers.charcoal:
            return "Charcoal"
        default:
            return nil
        }
    }
    
    private func describeTextStyle(_ textStyle: TextStyle) -> String {
        
        var string = ""
        
        for textStyleName in InfoPanelController.textStyleNames {
            
            if textStyle[keyPath: textStyleName.0] {
                if string.isEmpty {
                    string = textStyleName.1
                }
                else {
                    string += ", \(textStyleName.1)"
                }
            }
        }
        if string.isEmpty {
            return "plain"
        }
        return string
    }
    
    private func describePart(part: Part, type: PartType, layer: LayerType, number: Int) -> String {
        
        let partTypeName = (type == .field) ? "Field" : "Button"
        let layerTypeName = (layer == .background) ? "Background" : "Card"
        let typeName = "\(layerTypeName) \(partTypeName)"
        
        if part.name.length > 0 {
            return "\(typeName) \"\(part.name)\""
        }
        
        return "\(typeName) \(number)"
    }
    
    func displayField(_ field: Field, withContent content: HString, layerType: LayerType, number: Int, partNumber: Int, stack: Stack) {
        self.window!.title = self.describePart(part: field, type: .field, layer: layerType, number: number)
        displayScript(field.script)
        contentView.string = content.description.replacingOccurrences(of: "\r", with: "\n")
        self.deletePictureTab()
        
        self.infos = [("Name", "\"\(field.name)\""),
            ("Number", "\(number)"),
            ("Part Number", "\(partNumber)"),
            ("ID", "\(field.identifier)"),
            ("Style", "\(InfoPanelController.partStyleNames[field.style]!)"),
            ("Rectangle", "\(field.rectangle.left),\(field.rectangle.top),\(field.rectangle.right),\(field.rectangle.bottom)"),
            ("Visible", "\(field.visible ? "yes" : "no")"),
            ("Lock Text", "\(field.lockText ? "yes" : "no")"),
            ("Auto Tab", "\(field.autoTab ? "yes" : "no")"),
            ("Fixed Line Height", "\(field.fixedLineHeight ? "yes" : "no")"),
            ("Shared Text", "\(field.sharedText ? "yes" : "no")"),
            ("Don't Search", "\(field.dontSearch ? "yes" : "no")"),
            ("Don't Wrap", "\(field.dontWrap ? "yes" : "no")"),
            ("Multiple Lines", "\(field.multipleLines ? "yes" : "no")"),
            ("Wide Margins", "\(field.wideMargins ? "yes" : "no")"),
            ("Show Lines", "\(field.showLines ? "yes" : "no")"),
            ("Auto Select", "\(field.autoSelect ? "yes" : "no")"),
            ("Text Font", describeTextFont(field.textFontIdentifier, stack: stack)),
            ("Text Size", "\(field.textFontSize)"),
            ("Text Style", "\(self.describeTextStyle(field.textStyle))"),
            ("Text Alignment", "\(field.textAlign)")]
        
        self.infoTable.reloadData()
    }
    
    func displayScript(_ script: HString) {
        
        scriptView.string = indent(script).description
        
    }
    
    func indent(_ script: HString) -> HString {
        
        var indentedData = Data()
        indentedData.reserveCapacity(script.length)
        var indentation = Data()
        
        var commentStart: Int? = nil
        var lineStartsWithIfOrThen = false
        var lineStart = 0
        
        func isAlphaNum(char: HChar) -> Bool {
            return (char >= 65 && char < 91) || (char >= 97 && char < 123) || (char >= 48 && char < 58) || char == 95
        }
        
        func isWordBeforeIndex(_ index: Int, _ string: HString) -> Bool {
            var realIndex = index-1
            if let commentStartIndex = commentStart {
                realIndex = commentStartIndex-1
            }
            while realIndex >= 0 && script[realIndex] == 32 {
                realIndex -= 1
            }
            guard realIndex >= 0 else {
                return false
            }
            let indexBefore = realIndex - string.length + 1
            if indexBefore >= 0 && script[indexBefore..<(realIndex + 1)] == string {
                if indexBefore == 0 {
                    return true
                }
                let charBefore = script[indexBefore-1]
                if isAlphaNum(char: charBefore) {
                    return false
                }
                return true
            }
            return false
        }
        
        func isWordAfterIndex(_ index: Int, _ string: HString) -> Bool {
            let indexAfter = index + string.length + 1
            if indexAfter <= script.length && script[(index + 1)..<indexAfter] == string {
                if indexAfter == script.length {
                   return true
                }
                let charAfter = script[indexAfter]
                if isAlphaNum(char: charAfter) {
                    return false
                }
                return true
            }
            return false
        }
        
        func increment() {
            indentation.append(UInt8(32))
            indentation.append(UInt8(32))
        }
        
        func decrement() {
            guard indentation.count >= 2 else {
                NSLog("Script parsing issue")
                return
            }
            indentation.count -= 2
        }
        
        func startLine(atIndex index: Int) {
            
            /* Indentations for next line */
            
            /* Starting 'on' */
            if isWordAfterIndex(index, "on") {
                increment()
            }
            
            /* Starting 'function' */
            if isWordAfterIndex(index, "function") {
                increment()
            }
            
            /* Starting 'repeat' */
            if isWordAfterIndex(index, "repeat") {
                increment()
            }
            
            /* If/Then monitoring */
            if isWordAfterIndex(index, "if") || isWordAfterIndex(index, "then") || isWordAfterIndex(index, "else if") {
                lineStartsWithIfOrThen = true
            }
        }
        
        func endLine(atIndex index: Int, updateIndentation: Bool) {
            /* Replace the carriage returns by new lines */
            indentedData.append(script[lineStart..<index].data)
            lineStart = index + 1
            indentedData.append(10)
            
            /* Check if there is an ending ¬, in that case do not update increment
             and do not reset the state */
            if !updateIndentation {
                indentedData.append(indentation)
                return
            }
            
            /* Ending 'then' */
            var incrementedByThen = false
            if isWordBeforeIndex(index, "then") {
                increment()
                incrementedByThen = true
            }
            
            /* Starting 'end' */
            if isWordAfterIndex(index, "end") {
                decrement()
            }
            
            /* Starting 'else' */
            if isWordAfterIndex(index, "else") && (!lineStartsWithIfOrThen || incrementedByThen) {
                decrement()
            }
            
            /* Ending 'else' */
            if isWordBeforeIndex(index, "else") {
                increment()
            }
            
            /* Apply incrementation */
            indentedData.append(indentation)
            commentStart = nil
            
            /* Reset the state */
            lineStartsWithIfOrThen = false
        }
        
        startLine(atIndex: -1)
        
        for (index, char): (Int, UInt8) in script.data.enumerated() {
            
            if char == 45 && commentStart == nil && index+1 < script.length && script[index+1] == 45 {
                commentStart = index
            }
            
            if char == 13 {
                
                /* Check for cut line */
                let lineIsCut = (index > 0 && script[index-1] == 0xC2 && commentStart == nil)
                
                /* Fill the line separation and pdate indentation as for current line */
                endLine(atIndex: index, updateIndentation: !lineIsCut)
                
                /* Do not update indentation if it is a cut line */
                if lineIsCut {
                    continue
                }
                
                /* Update indentation as for next line */
                startLine(atIndex: index)
                continue
            }
            
        }
        
        endLine(atIndex: script.length, updateIndentation: false)
        if indentation.count != 0 {
            NSLog("Script parsing issue")
        }
        
        return HString(data: indentedData)
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.infos.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        
        let info = self.infos[row]
        if tableColumn?.identifier.rawValue == "name" {
            return info.0
        }
        else {
            return info.1
        }
    }
    
}
