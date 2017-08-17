//
//  Card.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 26/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//

/// A card
public class Card: Layer {
    
    /// The background behind the card. It is the "owner" property in HyperTalk.
    public var background: Background
    
    /// The identifier
    public var identifier: Int          = 0
    
    /// The name
    public var name: HString            = ""
    
    /// Whether the card is marked. This property is used in HyperCard to filter cards,
    /// for example in "print marked cards"
    public var marked: Bool             = false
    
    /// The hash used to check if a word is present in a card
    public var searchHash: SearchHash?  = nil
    
    /// The texts displayed in the fields of the background, and the hilites of the background buttons
    public var backgroundPartContents: [BackgroundPartContent]  = []
    
    /// The script
    public var script: HString          = ""
    
    
    /// To create a card, the background must be provided.
    public init(background: Background) {
        self.background = background
    }
    
    
    /// A content inside a background part
    public struct BackgroundPartContent {
        public var partIdentifier: Int
        public var partContent: PartContent
    }
    
}
