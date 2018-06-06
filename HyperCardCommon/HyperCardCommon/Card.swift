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
    
    /// The identifier
    public var identifier: Int {
        get { return self.identifierProperty.value }
        set { self.identifierProperty.value = newValue }
    }
    public var identifierProperty = Property<Int>(0)
    
    /// The name
    public var name: HString {
        get { return self.nameProperty.value }
        set { self.nameProperty.value = newValue }
    }
    public var nameProperty = Property<HString>("")
    
    /// Whether the card is marked. This property is used in HyperCard to filter cards,
    /// for example in "print marked cards"
    public var marked: Bool {
        get { return self.markedProperty.value }
        set { self.markedProperty.value = newValue }
    }
    public var markedProperty = Property<Bool>(false)
    
    /// The hash used to check if a word is present in a card
    public var searchHash: SearchHash? {
        get { return self.searchHashProperty.value }
        set { self.searchHashProperty.value = newValue }
    }
    public var searchHashProperty = Property<SearchHash?>(nil)
    
    /// The texts displayed in the fields of the background, and the hilites of the background buttons
    public var backgroundPartContents: [BackgroundPartContent] {
        get { return self.backgroundPartContentsProperty.value }
        set { self.backgroundPartContentsProperty.value = newValue }
    }
    public var backgroundPartContentsProperty = Property<[BackgroundPartContent]>([])
    
    /// The script
    public var script: HString {
        get { return self.scriptProperty.value }
        set { self.scriptProperty.value = newValue }
    }
    public var scriptProperty = Property<HString>("")
    
    
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
