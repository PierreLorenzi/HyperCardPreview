//
//  Stack Encoding.swift
//  HyperCardPreview
//
//  Created by Pierre Lorenzi on 18/09/2018.
//  Copyright © 2018 Pierre Lorenzi. All rights reserved.
//

import HyperCardCommon


extension Stack: Encodable {
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.cards, forKey: .cards)
        try container.encode(self.backgrounds, forKey: .backgrounds)
        try container.encode(self.passwordHash , forKey: .passwordHash)
        try container.encode(self.userLevel.rawValue , forKey: .userLevel)
        try container.encode(self.cantAbort, forKey: .cantAbort)
        try container.encode(self.cantDelete, forKey: .cantDelete)
        try container.encode(self.cantModify, forKey: .cantModify)
        try container.encode(self.cantPeek, forKey: .cantPeek)
        try container.encode(self.privateAccess, forKey: .privateAccess)
        try container.encode(self.versionAtCreation, forKey: .versionAtCreation)
        try container.encode(self.versionAtLastCompacting, forKey: .versionAtLastCompacting)
        try container.encode(self.versionAtLastModificationSinceLastCompacting, forKey: .versionAtLastModificationSinceLastCompacting)
        try container.encode(self.versionAtLastModification, forKey: .versionAtLastModification)
        try container.encode(self.size, forKey: .size)
        try container.encode(self.windowRectangle, forKey: .windowRectangle)
        try container.encode(self.screenRectangle, forKey: .screenRectangle)
        try container.encode(self.scrollPoint, forKey: .scrollPoint)
        try container.encode(self.script, forKey: .script)
        try container.encode(self.fontNameReferences, forKey: .fontNameReferences)
    }
    
    enum CodingKeys: String, CodingKey {
        case cards
        case backgrounds
        case passwordHash
        case userLevel
        case cantAbort
        case cantDelete
        case cantModify
        case cantPeek
        case privateAccess
        case versionAtCreation
        case versionAtLastCompacting
        case versionAtLastModificationSinceLastCompacting
        case versionAtLastModification
        case size
        case windowRectangle
        case screenRectangle
        case scrollPoint
        case script
        case fontNameReferences
    }
}

extension Card: Encodable {
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.identifier, forKey: .identifier)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.showPict, forKey: .showPict)
        try container.encode(self.dontSearch, forKey: .dontSearch)
        try container.encode(self.cantDelete, forKey: .cantDelete)
        try container.encode(self.parts, forKey: .parts)
        try container.encode(self.nextAvailablePartIdentifier, forKey: .nextAvailablePartIdentifier)
        try container.encode(self.script, forKey: .script)
        
        try container.encode(self.background.identifier, forKey: .backgroundIdentifier)
        try container.encode(self.marked, forKey: .marked)
        try container.encode(self.backgroundPartContents, forKey: .backgroundPartContents)
    }
    
    enum CodingKeys: String, CodingKey {
        case identifier
        case name
        case showPict
        case dontSearch
        case cantDelete
        case parts
        case nextAvailablePartIdentifier
        case script
        
        case backgroundIdentifier
        case marked
        case backgroundPartContents
    }
}

extension HString: Encodable {
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.singleValueContainer()
        try container.encode(self.description)
    }
}

extension Card.BackgroundPartContent: Encodable {
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.partIdentifier, forKey: .partIdentifier)
        try container.encode(self.partContent, forKey: .partContent)
    }
    
    enum CodingKeys: String, CodingKey {
        case partIdentifier
        case partContent
    }
}

extension PartContent: Encodable {
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
            
        case .string(let string):
            try container.encode(string, forKey: .string)
            
        case .formattedString(let text):
            try container.encode(text, forKey: .text)
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case string
        case text
    }
}

extension Text: Encodable {
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(self.string, forKey: .string)
        try container.encode(self.attributes, forKey: .attributes)
    }
    
    enum CodingKeys: String, CodingKey {
        case string
        case attributes
    }
}

extension Text.FormattingAssociation: Encodable {
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.offset, forKey: .offset)
        try container.encode(self.formatting, forKey: .formatting)
    }
    
    enum CodingKeys: String, CodingKey {
        case offset
        case formatting
    }
}

extension TextFormatting: Encodable {
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.fontFamilyIdentifier, forKey: .fontFamilyIdentifier)
        try container.encode(self.size, forKey: .size)
        try container.encode(self.style, forKey: .style)
    }
    
    enum CodingKeys: String, CodingKey {
        case fontFamilyIdentifier
        case size
        case style
    }
}

extension TextStyle: Encodable {
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.bold, forKey: .bold)
        try container.encode(self.italic, forKey: .italic)
        try container.encode(self.underline, forKey: .underline)
        try container.encode(self.outline, forKey: .outline)
        try container.encode(self.shadow, forKey: .shadow)
        try container.encode(self.condense, forKey: .condense)
        try container.encode(self.extend, forKey: .extend)
        try container.encode(self.group, forKey: .group)
    }
    
    enum CodingKeys: String, CodingKey {
        case bold
        case italic
        case underline
        case outline
        case shadow
        case condense
        case extend
        case group
    }
}

extension LayerPart: Encodable {
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
            
        case .button(let button):
            try container.encode(button, forKey: .button)
            
        case .field(let field):
            try container.encode(field, forKey: .field)
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case button
        case field
    }
}

extension Button: Encodable {
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.identifier, forKey: .identifier)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.style, forKey: .style)
        try container.encode(self.rectangle, forKey: .rectangle)
        try container.encode(self.visible, forKey: .visible)
        try container.encode(self.textAlign, forKey: .textAlign)
        try container.encode(self.textFontIdentifier, forKey: .textFontIdentifier)
        try container.encode(self.textFontSize, forKey: .textFontSize)
        try container.encode(self.textStyle, forKey: .textStyle)
        try container.encode(self.textHeight, forKey: .textHeight)
        try container.encode(self.script, forKey: .script)
        
        try container.encode(self.content, forKey: .content)
        try container.encode(self.enabled, forKey: .enabled)
        try container.encode(self.hilite, forKey: .hilite)
        try container.encode(self.autoHilite, forKey: .autoHilite)
        try container.encode(self.sharedHilite, forKey: .sharedHilite)
        try container.encode(self.showName, forKey: .showName)
        try container.encode(self.iconIdentifier, forKey: .iconIdentifier)
        try container.encode(self.family, forKey: .family)
        try container.encode(self.titleWidth, forKey: .titleWidth)
        try container.encode(self.selectedItem, forKey: .selectedItem)
    }
    
    enum CodingKeys: String, CodingKey {
        case identifier
        case name
        case style
        case rectangle
        case visible
        case textAlign
        case textFontIdentifier
        case textFontSize
        case textStyle
        case textHeight
        case script
        
        case content
        case enabled
        case hilite
        case autoHilite
        case sharedHilite
        case showName
        case iconIdentifier
        case family
        case titleWidth
        case selectedItem
    }
}

extension PartStyle: Encodable {
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.singleValueContainer()
        
        switch self {
        case .transparent:
            try container.encode("transparent")
            
        case .opaque:
            try container.encode("opaque")
            
        case .rectangle:
            try container.encode("rectangle")
            
        case .roundRect:
            try container.encode("round_rect")
            
        case .shadow:
            try container.encode("shadow")
            
        case .checkBox:
            try container.encode("check_box")
            
        case .radio:
            try container.encode("radio")
            
        case .scrolling:
            try container.encode("scrolling")
            
        case .standard:
            try container.encode("standard")
            
        case .`default`:
            try container.encode("default")
            
        case .oval:
            try container.encode("oval")
            
        case .popup:
            try container.encode("popup")
        }
    }
}

extension Rectangle: Encodable {
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.top, forKey: .top)
        try container.encode(self.left, forKey: .left)
        try container.encode(self.bottom, forKey: .bottom)
        try container.encode(self.right, forKey: .right)
    }
    
    enum CodingKeys: String, CodingKey {
        case top
        case left
        case bottom
        case right
    }
}

extension Field: Encodable {
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.identifier, forKey: .identifier)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.style, forKey: .style)
        try container.encode(self.rectangle, forKey: .rectangle)
        try container.encode(self.visible, forKey: .visible)
        try container.encode(self.textAlign, forKey: .textAlign)
        try container.encode(self.textFontIdentifier, forKey: .textFontIdentifier)
        try container.encode(self.textFontSize, forKey: .textFontSize)
        try container.encode(self.textStyle, forKey: .textStyle)
        try container.encode(self.textHeight, forKey: .textHeight)
        try container.encode(self.script, forKey: .script)
        
        try container.encode(self.content, forKey: .content)
        try container.encode(self.lockText, forKey: .lockText)
        try container.encode(self.autoTab, forKey: .autoTab)
        try container.encode(self.fixedLineHeight, forKey: .fixedLineHeight)
        try container.encode(self.sharedText, forKey: .sharedText)
        try container.encode(self.dontSearch, forKey: .dontSearch)
        try container.encode(self.dontWrap, forKey: .dontWrap)
        try container.encode(self.multipleLines, forKey: .multipleLines)
        try container.encode(self.wideMargins, forKey: .wideMargins)
        try container.encode(self.showLines, forKey: .showLines)
        try container.encode(self.autoSelect, forKey: .autoSelect)
        try container.encode(self.selectedLine, forKey: .selectedLine)
        try container.encode(self.lastSelectedLine, forKey: .lastSelectedLine)
        try container.encode(self.scroll, forKey: .scroll)
    }
    
    enum CodingKeys: String, CodingKey {
        case identifier
        case name
        case style
        case rectangle
        case visible
        case textAlign
        case textFontIdentifier
        case textFontSize
        case textStyle
        case textHeight
        case script
        
        case content
        case lockText
        case autoTab
        case fixedLineHeight
        case sharedText
        case dontSearch
        case dontWrap
        case multipleLines
        case wideMargins
        case showLines
        case autoSelect
        case selectedLine
        case lastSelectedLine
        case scroll
    }
}

extension TextAlign: Encodable {
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.singleValueContainer()
        
        switch self {
        case .left:
            try container.encode("left")
            
        case .center:
            try container.encode("center")
            
        case .right:
            try container.encode("right")
        }
    }
}

extension Background: Encodable {
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.identifier, forKey: .identifier)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.showPict, forKey: .showPict)
        try container.encode(self.dontSearch, forKey: .dontSearch)
        try container.encode(self.cantDelete, forKey: .cantDelete)
        try container.encode(self.parts, forKey: .parts)
        try container.encode(self.nextAvailablePartIdentifier, forKey: .nextAvailablePartIdentifier)
        try container.encode(self.script, forKey: .script)
    }
    
    enum CodingKeys: String, CodingKey {
        case identifier
        case name
        case showPict
        case dontSearch
        case cantDelete
        case parts
        case nextAvailablePartIdentifier
        case script
    }
}

extension Version: Encodable {
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.major, forKey: .major)
        try container.encode(self.minor1, forKey: .minor1)
        try container.encode(self.minor2, forKey: .minor2)
        try container.encode(self.state, forKey: .state)
    }
    
    enum CodingKeys: String, CodingKey {
        case major
        case minor1
        case minor2
        case state
    }
}

extension Version.State: Encodable {
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.singleValueContainer()
        
        switch self {
        case .final:
            try container.encode("final")
            
        case .beta:
            try container.encode("beta")
            
        case .development:
            try container.encode("development")
            
        case .alpha:
            try container.encode("alpha")
        }
    }
}

extension Size: Encodable {
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.width, forKey: .width)
        try container.encode(self.height, forKey: .height)
    }
    
    enum CodingKeys: String, CodingKey {
        case width
        case height
    }
}

extension Point: Encodable {
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.x, forKey: .x)
        try container.encode(self.y, forKey: .y)
    }
    
    enum CodingKeys: String, CodingKey {
        case x
        case y
    }
}

extension FontNameReference: Encodable {
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.identifier, forKey: .identifier)
        try container.encode(self.name, forKey: .name)
    }
    
    enum CodingKeys: String, CodingKey {
        case identifier
        case name
    }
}

