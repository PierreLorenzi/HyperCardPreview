//
//  Card.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 26/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


/// A card, as a HyperCard object
public class Card: Layer {
    
    /// The background behind the card. It is the "owner" property in HyperTalk.
    public var background: Background {
        get { return self.backgroundProperty.value }
        set { self.backgroundProperty.value = newValue }
    }
    public var backgroundProperty: Property<Background>
    
    /// Whether the card is marked. This property is used in HyperCard to filter cards,
    /// for example in "print marked cards"
    public var marked: Bool {
        get { return self.markedProperty.value }
        set { self.markedProperty.value = newValue }
    }
    public var markedProperty = Property<Bool>(false)
    
    /// The texts displayed in the fields of the background, and the hilites of the background buttons
    public var backgroundPartContents: [BackgroundPartContent] {
        get { return self.backgroundPartContentsProperty.value }
        set { self.backgroundPartContentsProperty.value = newValue }
    }
    public var backgroundPartContentsProperty = Property<[BackgroundPartContent]>([])
    
    
    /// To create a card, the background must be provided.
    public init(background: Background) {
        self.backgroundProperty = Property<Background>(background)
    }
    
    
    /// A content inside a background part
    public struct BackgroundPartContent {
        public var partIdentifier: Int
        public var partContent: PartContent
    }
    
}
