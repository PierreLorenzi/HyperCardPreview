//
//  IncrementalSearch.swift
//  HyperCardPreview
//
//  Created by Pierre Lorenzi on 13/09/2019.
//  Copyright © 2019 Pierre Lorenzi. All rights reserved.
//

import HyperCardCommon


extension Stack {
    
    struct SearchPosition {
        var cardIndex: Int
        var partLayer: LayerType
        var partIndex: Int?
        var characterRange: Range<Int>?
    }
    
    enum SearchDirection {
        case forward
        case backward
    }
    
    func find(_ string: HString, direction: SearchDirection, fromCardIndex cardIndex: Int, field possibleField: Field?, range possibleRange: Range<Int>?) -> SearchPosition? {
        
        let pattern = HString.SearchPattern(string)
        
        let position: SearchPosition
        if let field = possibleField, let range = possibleRange {
            position = self.buildOffsetPosition(cardIndex: cardIndex, field: field, range: range)
        }
        else {
            position = self.buildCardPosition(cardIndex: cardIndex)
        }
        
        return self.find(pattern, direction: direction, after: position)
    }
    
    private func buildOffsetPosition(cardIndex: Int, field: Field, range: Range<Int>) -> SearchPosition {
        
        /* Look for the field index */
        let card = self.cards[cardIndex]
        let background = card.background
        
        /* Look for a background field */
        if let partIndex = background.parts.firstIndex(where: { $0.part === field }) {
            
            return SearchPosition(cardIndex: cardIndex, partLayer: LayerType.background, partIndex: partIndex, characterRange: range)
        }
        
        /* Look for a card field */
        if let partIndex = card.parts.firstIndex(where: { $0.part === field }) {
            
            return SearchPosition(cardIndex: cardIndex, partLayer: LayerType.card, partIndex: partIndex, characterRange: range)
        }
        
        fatalError()
    }
    
    private func buildCardPosition(cardIndex: Int) -> SearchPosition {
        
        return SearchPosition(cardIndex: cardIndex, partLayer: LayerType.background, partIndex: nil, characterRange: nil)
    }
    
    private func find(_ pattern: HString.SearchPattern, direction: SearchDirection, after initialPosition: SearchPosition) -> SearchPosition? {
        
        var position = initialPosition
        var hasRestarted = false
        
        let incrementInt = self.makeIncrementInt(direction: direction)
        let incrementLayer = self.makeIncrementLayer(direction: direction)
        let findInString = self.makeFindInString(direction: direction)
        
        /* Card loop */
        while true {
            
            let card = self.cards[position.cardIndex]
            
            /* Layer loop */
            while true {
                
                let layer: Layer = (position.partLayer == .background) ? card.background : card
                
                /* Part loop */
                while true {
                    
                    if position.partIndex == nil {
                        if layer.parts.isEmpty {
                            break
                        }
                        position.partIndex = (direction == .forward) ? 0 : layer.parts.count-1
                    }
                    
                    /* Character loop. The increments are not well defined,
                     so we must check the consistenty now */
                    if let content = self.retrieveContent(card: card, layerType: position.partLayer, partIndex: position.partIndex!) {
                        
                        if position.characterRange == nil {
                            position.characterRange = (direction == .forward) ? (0..<0) : (content.length..<content.length)
                        }
                        
                        /* Find the next occurrence */
                        if let characterRange = findInString(pattern, content, position.characterRange!) {
                            
                            return SearchPosition(cardIndex: position.cardIndex, partLayer: position.partLayer, partIndex: position.partIndex, characterRange: characterRange)
                        }
                    }
                    
                    position.characterRange = nil
                    
                    /* Increment part */
                    if !incrementInt(&position.partIndex!, layer.parts.count) {
                        position.partIndex = nil
                        break
                    }
                }
                
                /* Increment layer */
                if !incrementLayer(&position.partLayer) {
                    break
                }
            }
            
            let restarts = !incrementInt(&position.cardIndex, self.cards.count)
            if hasRestarted && restarts {
                break
            }
            hasRestarted = restarts || hasRestarted
            if self.cards.count > 1 && hasRestarted && ((direction == .forward && position.cardIndex > initialPosition.cardIndex) || (direction == .backward && position.cardIndex < initialPosition.cardIndex)) {
                break
            }
        }
        
        return nil
    }
    
    private func makeIncrementInt(direction: SearchDirection) -> (inout Int, Int) -> Bool {
        
        switch direction {
            
        case .forward:
            return { (index: inout Int, count: Int) -> Bool in
                index += 1
                if index >= count {
                    index = 0
                    return false
                }
                return true
            }
            
        case .backward:
            return { (index: inout Int, count: Int) -> Bool in
                if index == 0 {
                    index = count-1
                    return false
                }
                index -= 1
                return true
            }
        }
    }
    
    private func makeIncrementLayer(direction: SearchDirection)  -> (inout LayerType) -> Bool {
        
        return { (layerType: inout LayerType) -> Bool in
            switch layerType {
                
            case .background:
                layerType = .card
                return direction != .backward
                
            case .card:
                layerType = .background
                return direction != .forward
            }
        }
    }
    
    private func retrieveContent(card: Card, layerType: LayerType, partIndex: Int) -> HString? {
        
        /* Ensure the part is a field */
        let layer: Layer = (layerType == .background) ? card.background : card
        let layerPart = layer.parts[partIndex]
        guard case LayerPart.field(let field) = layerPart else {
            return nil
        }
        
        switch layerType {
            
        case .background:
            let backgroundPartContent = card.backgroundPartContents.first(where: { $0.partIdentifier == field.identifier })
            return backgroundPartContent?.partContent.string
            
        case .card:
            return field.content.string
        }
    }
    
    private func makeFindInString(direction: SearchDirection) -> (HString.SearchPattern, HString, Range<Int>) -> Range<Int>? {
        
        switch direction {
            
        case .forward:
            return { (pattern: HString.SearchPattern, string: HString, initialRange: Range<Int>) -> Range<Int>? in
                
                guard initialRange.endIndex < string.length else {
                    return nil
                }
                guard let nextIndex = string.find(pattern, from: initialRange.endIndex) else {
                    return nil
                }
                return nextIndex ..< (nextIndex + pattern.string.length)
            }
            
        case .backward:
            return { (pattern: HString.SearchPattern, string: HString, initialRange: Range<Int>) -> Range<Int>? in
                
                guard initialRange.startIndex > 0 else {
                    return nil
                }
                
                var previousRange: Range<Int>? = nil
                while let newIndex = string.find(pattern, from: previousRange?.endIndex ?? 0) {
                    
                    guard newIndex < initialRange.startIndex else {
                        break
                    }
                    
                    let newRange = newIndex ..< (newIndex + pattern.string.length)
                    previousRange = newRange
                    
                    guard newRange.endIndex < string.length else {
                        break
                    }
                }
                
                return previousRange
            }
        }
    }
}
