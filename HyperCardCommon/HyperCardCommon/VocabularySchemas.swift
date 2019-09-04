//
//  VocabularySchemas.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 30/08/2019.
//  Copyright © 2019 Pierre Lorenzi. All rights reserved.
//


public enum Vocabulary {
    
    public static let stack = Schema<Void>("stack")
        .returns(())
    
    public static let background = Schema<Void>("\(either: "background", "bkgnd", "bg")")
        .returns(())
    
    public static let backgrounds = Schema<Void>("\(either: "backgrounds", "bkgnds", "bgs")")
        .returns(())
    
    public static let card = Schema<Void>("\(either: "card", "cd")")
        .returns(())
    
    public static let cards = Schema<Void>("\(either: "cards", "cds")")
        .returns(())
    
    public static let markedCards = Schema<Void>("marked \(cards)")
        .returns(())
    
    public static let part = Schema<Void>("part")
        .returns(())
    
    public static let parts = Schema<Void>("parts")
        .returns(())
    
    public static let cardPart = Schema<Void>("\(maybe: card) \(part)")
        .returns(())
    
    public static let cardParts = Schema<Void>("\(maybe: card) \(parts)")
        .returns(())
    
    public static let backgroundPart = Schema<Void>("\(background) \(part)")
        .returns(())
    
    public static let backgroundParts = Schema<Void>("\(background) \(parts)")
        .returns(())
    
    public static let button = Schema<Void>("\(either: "button", "btn")")
        .returns(())
    
    public static let buttons = Schema<Void>("\(either: "buttons", "btns")")
        .returns(())
    
    public static let cardButton = Schema<Void>("\(maybe: card) \(button)")
        .returns(())
    
    public static let cardButtons = Schema<Void>("\(maybe: card) \(buttons)")
        .returns(())
    
    public static let backgroundButton = Schema<Void>("\(background) \(button)")
        .returns(())
    
    public static let backgroundButtons = Schema<Void>("\(background) \(buttons)")
        .returns(())
    
    public static let field = Schema<Void>("\(either: "field", "fld")")
        .returns(())
    
    public static let fields = Schema<Void>("\(either: "fields", "flds")")
        .returns(())
    
    public static let cardField = Schema<Void>("\(card) \(field)")
        .returns(())
    
    public static let cardFields = Schema<Void>("\(card) \(fields)")
        .returns(())
    
    public static let backgroundField = Schema<Void>("\(maybe: background) \(field)")
        .returns(())
    
    public static let backgroundFields = Schema<Void>("\(maybe: background) \(fields)")
        .returns(())
    
    public static let line = Schema<Void>("line")
        .returns(())
    
    public static let lines = Schema<Void>("lines")
        .returns(())
    
    public static let item = Schema<Void>("item")
        .returns(())
    
    public static let items = Schema<Void>("items")
        .returns(())
    
    public static let word = Schema<Void>("word")
        .returns(())
    
    public static let words = Schema<Void>("words")
        .returns(())
    
    public static let character = Schema<Void>("\(either: "character", "char")")
        .returns(())
    
    public static let characters = Schema<Void>("\(either: "characters", "chars")")
        .returns(())
    
    public static let window = Schema<Void>("window")
        .returns(())
    
    public static let windows = Schema<Void>("windows")
        .returns(())
    
    public static let menu = Schema<Void>("menu")
        .returns(())
    
    public static let menus = Schema<Void>("menus")
        .returns(())
    
    public static let menuItem = Schema<Void>("menuItem")
        .returns(())
    
    public static let menuItems = Schema<Void>("menuItems")
        .returns(())
    
    public static let program = Schema<Void>("program")
        .returns(())
    
    /* Used for 'card 2 of this bg' / 'card 2 in this bg' */
    public static let of = Schema<Void>("\(either: "of", "in")")
        .returns(())
}
