//
//  VocabularySchemas.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 30/08/2019.
//  Copyright © 2019 Pierre Lorenzi. All rights reserved.
//


public enum Vocabulary {
    
    public static let stack = Schema<Void>("stack")
    
    public static let background = Schema<Void>("\(either: "background", "bkgnd", "bg")")
    
    public static let backgrounds = Schema<Void>("\(either: "backgrounds", "bkgnds", "bgs")")
    
    public static let card = Schema<Void>("\(either: "card", "cd")")
    
    public static let cards = Schema<Void>("\(either: "cards", "cds")")
    
    public static let markedCards = Schema<Void>("marked \(cards)")
    
    public static let part = Schema<Void>("part")
    
    public static let parts = Schema<Void>("parts")
    
    public static let cardPart = Schema<Void>("\(maybe: card) \(part)")
    
    public static let cardParts = Schema<Void>("\(maybe: card) \(parts)")
    
    public static let backgroundPart = Schema<Void>("\(background) \(part)")
    
    public static let backgroundParts = Schema<Void>("\(background) \(parts)")
    
    public static let button = Schema<Void>("\(either: "button", "btn")")
    
    public static let buttons = Schema<Void>("\(either: "buttons", "btns")")
    
    public static let cardButton = Schema<Void>("\(maybe: card) \(button)")
    
    public static let cardButtons = Schema<Void>("\(maybe: card) \(buttons)")
    
    public static let backgroundButton = Schema<Void>("\(background) \(button)")
    
    public static let backgroundButtons = Schema<Void>("\(background) \(buttons)")
    
    public static let field = Schema<Void>("\(either: "field", "fld")")
    
    public static let fields = Schema<Void>("\(either: "fields", "flds")")
    
    public static let cardField = Schema<Void>("\(card) \(field)")
    
    public static let cardFields = Schema<Void>("\(card) \(fields)")
    
    public static let backgroundField = Schema<Void>("\(maybe: background) \(field)")
    
    public static let backgroundFields = Schema<Void>("\(maybe: background) \(fields)")
    
    public static let line = Schema<Void>("line")
    
    public static let lines = Schema<Void>("lines")
    
    public static let item = Schema<Void>("item")
    
    public static let items = Schema<Void>("items")
    
    public static let word = Schema<Void>("word")
    
    public static let words = Schema<Void>("words")
    
    public static let character = Schema<Void>("\(either: "character", "char")")
    
    public static let characters = Schema<Void>("\(either: "characters", "chars")")
    
    public static let window = Schema<Void>("window")
    
    public static let windows = Schema<Void>("windows")
    
    public static let menu = Schema<Void>("menu")
    
    public static let menus = Schema<Void>("menus")
    
    public static let menuItem = Schema<Void>("menuItem")
    
    public static let menuItems = Schema<Void>("menuItems")
    
    public static let program = Schema<Void>("program")
    
    /* Used for 'card 2 of this bg' / 'card 2 in this bg' */
    public static let of = Schema<Void>("\(either: "of", "in")")
}
