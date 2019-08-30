//
//  VocabularySchemas.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 30/08/2019.
//  Copyright © 2019 Pierre Lorenzi. All rights reserved.
//


public enum Vocabulary {
    
    static let stack = Schema<Void>("stack")
        .returns(())
    
    static let background = Schema<Void>("\(either: "background", "bkgnd", "bg")")
        .returns(())
    
    static let backgrounds = Schema<Void>("\(either: "backgrounds", "bkgnds", "bgs")")
        .returns(())
    
    static let card = Schema<Void>("\(either: "card", "cd")")
        .returns(())
    
    static let cards = Schema<Void>("\(either: "cards", "cds")")
        .returns(())
    
    static let markedCards = Schema<Void>("marked \(cards)")
        .returns(())
    
    static let part = Schema<Void>("part")
        .returns(())
    
    static let parts = Schema<Void>("parts")
        .returns(())
    
    static let cardPart = Schema<Void>("\(maybe: card) \(part)")
        .returns(())
    
    static let cardParts = Schema<Void>("\(maybe: card) \(parts)")
        .returns(())
    
    static let backgroundPart = Schema<Void>("\(background) \(part)")
        .returns(())
    
    static let backgroundParts = Schema<Void>("\(background) \(parts)")
        .returns(())
    
    static let button = Schema<Void>("\(either: "button", "btn")")
        .returns(())
    
    static let buttons = Schema<Void>("\(either: "buttons", "btns")")
        .returns(())
    
    static let cardButton = Schema<Void>("\(maybe: card) \(button)")
        .returns(())
    
    static let cardButtons = Schema<Void>("\(maybe: card) \(buttons)")
        .returns(())
    
    static let backgroundButton = Schema<Void>("\(background) \(button)")
        .returns(())
    
    static let backgroundButtons = Schema<Void>("\(background) \(buttons)")
        .returns(())
    
    static let field = Schema<Void>("\(either: "field", "fld")")
        .returns(())
    
    static let fields = Schema<Void>("\(either: "fields", "flds")")
        .returns(())
    
    static let cardField = Schema<Void>("\(card) \(field)")
        .returns(())
    
    static let cardFields = Schema<Void>("\(card) \(fields)")
        .returns(())
    
    static let backgroundField = Schema<Void>("\(maybe: background) \(field)")
        .returns(())
    
    static let backgroundFields = Schema<Void>("\(maybe: background) \(fields)")
        .returns(())
    
    static let line = Schema<Void>("line")
        .returns(())
    
    static let lines = Schema<Void>("lines")
        .returns(())
    
    static let item = Schema<Void>("item")
        .returns(())
    
    static let items = Schema<Void>("items")
        .returns(())
    
    static let word = Schema<Void>("word")
        .returns(())
    
    static let words = Schema<Void>("words")
        .returns(())
    
    static let character = Schema<Void>("\(either: "character", "char")")
        .returns(())
    
    static let characters = Schema<Void>("\(either: "characters", "chars")")
        .returns(())
    
    static let window = Schema<Void>("window")
        .returns(())
    
    static let windows = Schema<Void>("windows")
        .returns(())
    
    static let menu = Schema<Void>("menu")
        .returns(())
    
    static let menus = Schema<Void>("menus")
        .returns(())
    
    static let menuItem = Schema<Void>("menuItem")
        .returns(())
    
    static let menuItems = Schema<Void>("menuItems")
        .returns(())
    
    static let program = Schema<Void>("program")
        .returns(())
    
    /* Used for 'card 2 of this bg' / 'card 2 in this bg' */
    static let of = Schema<Void>("\(either: "of", "in")")
        .returns(())
}
