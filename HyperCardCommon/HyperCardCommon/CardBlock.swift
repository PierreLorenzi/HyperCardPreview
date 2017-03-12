//
//  CardBlock.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 26/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


public class CardBlock: LayerBlock {
    
    override public class var Name: NumericName {
        return NumericName(string: "CARD")!
    }
    
    public let marked: Bool
    public let hasTextContent: Bool
    public let isStartOfBackground: Bool
    public let hasName: Bool
    public let searchHash: SearchHash
    
    public convenience init(data: DataRange, marked: Bool, hasTextContent: Bool, isStartOfBackground: Bool, hasName: Bool, searchHash: SearchHash) {
        
        self.init(data: data, marked: marked, hasTextContent: hasTextContent, isStartOfBackground: isStartOfBackground, hasName: hasName, searchHash: searchHash, partOffset: 0x36)
    }
    
    /* Initializer for card v1 */
    init(data: DataRange, marked: Bool, hasTextContent: Bool, isStartOfBackground: Bool, hasName: Bool, searchHash: SearchHash, partOffset: Int) {
        self.marked = marked
        self.hasTextContent = hasTextContent
        self.isStartOfBackground = isStartOfBackground
        self.hasName = hasName
        self.searchHash = searchHash
        super.init(data: data, partOffset: partOffset)
    }
    
    public var pageIdentifier: Int {
        return data.readUInt32(at: 0x20)
    }
    
    public var backgroundIdentifier: Int {
        return data.readUInt32(at: 0x24)
    }
    
}
