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
        
        let versionAtCreation: String = stack.versionAtCreation?.description ?? "unknown"
        let version: String = stack.versionAtLastModification?.description ?? "unknown"
        
        infoView.string = ["Number of Cards: \(stack.cards.count)",
            "Number of Backgrounds: \(stack.backgrounds.count)",
            "Resources: \(stack.resources != nil)\n",
            "Password: \(stack.passwordHash != nil)",
            "User Level: \(stack.userLevel.rawValue)",
            "Can't Abort: \(stack.cantAbort)",
            "Can't Delete: \(stack.cantDelete)",
            "Can't Modify: \(stack.cantModify)",
            "Can't Peek: \(stack.cantPeek)",
            "Private Access: \(stack.privateAccess)\n",
            "HyperCard Version at creation: \(versionAtCreation)",
            "HyperCard Version at last edition: \(version)\n",
            "Size: \(stack.size.width) x \(stack.size.height)"].joined(separator: "\n")
    }
    
    func displayBackground(_ background: Background) {
        window.title = "Background ID \(background.identifier)"
        displayScript(background.script)
        tabView.removeTabViewItem(tabView.tabViewItem(at: 1))
        
        infoView.string = ["Name: \"\(background.name)\"",
            "Number of parts: \(background.parts.count)\n",
            "Show Pict: \(background.showPict)\n",
            "Don't Search: \(background.dontSearch)",
            "Can't Delete: \(background.cantDelete)"].joined(separator: "\n")
    }
    
    func displayCard(_ card: Card) {
        window.title = "Card ID \(card.identifier)"
        displayScript(card.script)
        tabView.removeTabViewItem(tabView.tabViewItem(at: 1))
        
        infoView.string = ["Name: \"\(card.name)\"",
            "Number of parts: \(card.parts.count)\n",
            "Marked: \(card.marked)",
            "Show Pict: \(card.showPict)\n",
            "Don't Search: \(card.dontSearch)",
            "Can't Delete: \(card.cantDelete)"].joined(separator: "\n")
    }
    
    func displayButton(_ button: Button, withContent content: HString) {
        window.title = "Button ID \(button.identifier)"
        displayScript(button.script)
        contentView.string = content.description
        
        infoView.string = ["Name: \"\(button.name)\"",
            "Style: \(button.style)\n",
            "Visible: \(button.visible)",
            "Enabled: \(button.enabled)",
            "Hilite: \(button.hilite)",
            "Auto Hilite: \(button.autoHilite)",
            "Shared Hilite: \(button.sharedHilite)",
            "Show Name: \(button.showName)\n",
            "Family: \(button.family)\n",
            "Title Width: \(button.titleWidth)"].joined(separator: "\n")
    }
    
    func displayField(_ field: Field, withContent content: HString) {
        window.title = "Field ID \(field.identifier)"
        displayScript(field.script)
        contentView.string = content.description
        
        infoView.string = ["Name: \"\(field.name)\"",
            "Style: \(field.style)\n",
            "Visible: \(field.visible)",
            "Lock Text: \(field.lockText)",
            "Auto Tab: \(field.autoTab)",
            "Fixed Line Height: \(field.fixedLineHeight)",
            "Shared Text: \(field.sharedText)",
            "Don't Search: \(field.dontSearch)",
            "Don't Wrap: \(field.dontWrap)",
            "Multiple Lines: \(field.multipleLines)",
            "Wide Margins: \(field.wideMargins)",
            "Show Lines: \(field.showLines)",
            "Auto Select: \(field.autoSelect)"].joined(separator: "\n")
        
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
    
}
