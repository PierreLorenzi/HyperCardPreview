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
}
