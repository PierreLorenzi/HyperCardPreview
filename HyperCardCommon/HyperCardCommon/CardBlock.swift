//
//  CardBlock.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 26/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


/// A card block contains the properties of a card
public class CardBlock: LayerBlock {
    
    override public class var Name: NumericName {
        return NumericName(string: "CARD")!
    }
    
    /// Is card marked
    /// <p>
    /// This parameter must be provided because it is only present in the page referencing the card
    public let marked: Bool
    
    /// Has the card text content in the fields
    /// <p>
    /// This parameter must be provided because it is only present in the page referencing the card
    public let hasTextContent: Bool
    
    /// Is the card at the beginning of a background
    /// <p>
    /// This parameter must be provided because it is only present in the page referencing the card
    public let isStartOfBackground: Bool
    
    /// Has the card a name
    /// <p>
    /// This parameter must be provided because it is only present in the page referencing the card
    public let hasName: Bool
    
    /// The search hash of the card
    /// <p>
    /// This parameter must be provided because it is only present in the page referencing the card
    public let searchHash: SearchHash
    
    /// Main constructor
    public convenience init(data: DataRange, marked: Bool, hasTextContent: Bool, isStartOfBackground: Bool, hasName: Bool, searchHash: SearchHash) {
        
        self.init(data: data, marked: marked, hasTextContent: hasTextContent, isStartOfBackground: isStartOfBackground, hasName: hasName, searchHash: searchHash, partOffset: 0x36)
    }
    
    /// Constructor used to handle stack in V1 format
    init(data: DataRange, marked: Bool, hasTextContent: Bool, isStartOfBackground: Bool, hasName: Bool, searchHash: SearchHash, partOffset: Int) {
        self.marked = marked
        self.hasTextContent = hasTextContent
        self.isStartOfBackground = isStartOfBackground
        self.hasName = hasName
        self.searchHash = searchHash
        super.init(data: data, partOffset: partOffset)
    }
    
    /// Identifier of the page referencing the card
    public func readPageIdentifier() -> Int {
        return data.readUInt32(at: 0x20)
    }
    
    /// Identifier of the background of the card
    public func readBackgroundIdentifier() -> Int {
        return data.readUInt32(at: 0x24)
    }
    
}
