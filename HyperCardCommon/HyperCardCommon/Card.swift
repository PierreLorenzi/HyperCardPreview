//
//  Card.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 26/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//

public class Card: Layer {
    
    public var background: Background
    
    public var identifier: Int          = 0
    public var name: HString            = ""
    
    public var marked: Bool             = false
    
    public var searchHash: SearchHash?  = nil
    public var backgroundPartContents: [BackgroundPartContent]  = []
    
    public var script: HString      = ""
    
    
    public init(background: Background) {
        self.background = background
    }
    
    
    public struct BackgroundPartContent {
        public var partIdentifier: Int
        public var partContent: PartContent
    }
    
}
