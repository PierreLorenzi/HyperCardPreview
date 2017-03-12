//
//  InfoPanel.swift
//  HyperCardPreview
//
//  Created by Pierre Lorenzi on 10/03/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//

import AppKit
import HyperCardCommon


class InfoPanelController {
    
    @IBOutlet var window: NSWindow!
    @IBOutlet weak var infoView: NSTextView!
    @IBOutlet weak var contentView: NSTextView!
    @IBOutlet weak var scriptView: NSTextView!
    @IBOutlet weak var tabView: NSTabView!
    
    func setup() {
        
        /* Don't wrap in script */
        scriptView.enclosingScrollView!.hasHorizontalScroller = true
        scriptView.isHorizontallyResizable = true
        scriptView.autoresizingMask = NSAutoresizingMaskOptions(rawValue: NSAutoresizingMaskOptions.viewWidthSizable.rawValue | NSAutoresizingMaskOptions.viewHeightSizable.rawValue)
        scriptView.textContainer?.containerSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        scriptView.textContainer?.widthTracksTextView = false
        
        /* Monaco */
        scriptView.font = NSFont(name: "Monaco", size: 10)
        
    }
    
    func displayStack(_ stack: Stack) {
        window.title = "Stack Info"
        displayScript(stack.script)
        tabView.removeTabViewItem(tabView.tabViewItem(at: 1))
        
        let version: String = stack.versionAtLastModification?.description ?? "unknown"
        
        infoView.string = "Number of Cards: \(stack.cards.count)\n" +
            "Number of Backgrounds: \(stack.backgrounds.count)\n" +
            "Resources: \(stack.resources != nil)\n\n" +
            "Password: \(stack.passwordHash != nil)\n" +
            "User Level: \(stack.userLevel.rawValue)\n" +
            "Can't Abort: \(stack.cantAbort)\n" +
            "Can't Delete: \(stack.cantDelete)\n" +
            "Can't Modify: \(stack.cantModify)\n" +
            "Can't Peek: \(stack.cantPeek)\n" +
            "Private Access: \(stack.privateAccess)\n\n" +
            "HyperCard Version: \(version)\n\n" +
            "Size: \(stack.size.width) x \(stack.size.height)"
    }
    
    func displayBackground(_ background: Background) {
        window.title = "Background ID \(background.identifier)"
        displayScript(background.script)
        tabView.removeTabViewItem(tabView.tabViewItem(at: 1))
        
        infoView.string = "Name: \"\(background.name)\"\n" +
            "Number of parts: \(background.parts.count)\n\n" +
            "Show Pict: \(background.showPict)\n\n" +
            "Don't Search: \(background.dontSearch)\n" +
            "Can't Delete: \(background.cantDelete)"
    }
    
    func displayCard(_ card: Card) {
        window.title = "Card ID \(card.identifier)"
        displayScript(card.script)
        tabView.removeTabViewItem(tabView.tabViewItem(at: 1))
        
        infoView.string = "Name: \"\(card.name)\"\n" +
            "Number of parts: \(card.parts.count)\n\n" +
            "Marked: \(card.marked)\n" +
            "Show Pict: \(card.showPict)\n\n" +
            "Don't Search: \(card.dontSearch)\n" +
            "Can't Delete: \(card.cantDelete)"
    }
    
    func displayButton(_ button: Button, withContent content: HString) {
        window.title = "Button ID \(button.identifier)"
        displayScript(button.script)
        contentView.string = content.description
        
        infoView.string = "Name: \"\(button.name)\"\n" +
            "Style: \(button.style)\n\n" +
            "Visible: \(button.visible)\n" +
            "Enabled: \(button.enabled)\n" +
            "Hilite: \(button.hilite)\n" +
            "Auto Hilite: \(button.autoHilite)\n" +
            "Shared Hilite: \(button.sharedHilite)\n" +
            "Show Name: \(button.showName)\n\n" +
            "Family: \(button.family)\n\n" +
            "Title Width: \(button.titleWidth)"        
    }
    
    func displayField(_ field: Field, withContent content: HString) {
        window.title = "Field ID \(field.identifier)"
        displayScript(field.script)
        contentView.string = content.description
        
        infoView.string = "Name: \"\(field.name)\"\n" +
            "Style: \(field.style)\n\n" +
            "Visible: \(field.visible)\n" +
            "Lock Text: \(field.lockText)\n" +
            "Auto Tab: \(field.autoTab)\n" +
            "Fixed Line Height: \(field.fixedLineHeight)\n" +
            "Shared Text: \(field.sharedText)\n" +
            "Don't Search: \(field.dontSearch)\n" +
            "Don't Wrap: \(field.dontWrap)\n" +
            "Multiple Lines: \(field.multipleLines)\n" +
            "Wide Margins: \(field.wideMargins)\n" +
            "Show Lines: \(field.showLines)\n" +
            "Auto Select: \(field.autoSelect)"
        
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
        
        func endLine(atIndex index: Int) {
            /* Replace the carriage returns by new lines */
            indentedData.append(script[lineStart..<index].data)
            lineStart = index + 1
            indentedData.append(10)
            
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
            
            /* Do not reset the state if the line continues */
            if !isWordBeforeIndex(index, "¬") {
                lineStartsWithIfOrThen = false
            }
        }
        
        startLine(atIndex: -1)
        
        for (index, char): (Int, UInt8) in script.data.enumerated() {
            
            if char == 45 && commentStart == nil && index+1 < script.length && script[index+1] == 45 {
                commentStart = index
            }
            
            if char == 13 {
                
                endLine(atIndex: index)
                startLine(atIndex: index)
                continue
            }
            
        }
        
        endLine(atIndex: script.length)
        if indentation.count != 0 {
            NSLog("Script parsing issue")
        }
        
        return HString(data: indentedData)
    }
    
}
