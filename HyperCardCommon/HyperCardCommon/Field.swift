//
//  Field.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 26/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


public class Field: Part {
    
    public var content: PartContent     = .string("")
    
    public var lockText: Bool           = false
    public var autoTab: Bool            = false
    public var fixedLineHeight: Bool    = false
    public var sharedText: Bool         = false
    public var dontSearch: Bool         = false
    public var dontWrap: Bool           = false
    public var multipleLines: Bool      = false
    public var wideMargins: Bool        = false
    public var showLines: Bool          = false
    public var autoSelect: Bool         = false
    
    public var selectedLine: Int        = 0
    public var lastSelectedLine: Int    = 0
    public var scroll: Int              = 0
    
    public var textAlign: TextAlign     = .left
    public var textFontIdentifier: Int  = 3
    public var textFontSize: Int        = 12
    public var textStyle: TextStyle     = PlainTextStyle
    public var textHeight: Int          = 16
    
}
