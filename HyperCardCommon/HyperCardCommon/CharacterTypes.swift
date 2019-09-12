//
//  CharacterTypes.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 10/06/2018.
//  Copyright © 2018 Pierre Lorenzi. All rights reserved.
//


public extension HChar {
    
    static let lineContinuation = HChar(0xC2)
    static let zero = HChar(0x30)
    static let nine = HChar(0x39)
    static let space = HChar(0x20)
    static let tabulation = HChar(0x9)
    static let point = HChar(0x2E)
    static let carriageReturn = HChar(0xD)
    static let quote = HChar(0x22)
    
    /// A symbol is a character not considered as a word in HyperTalk. For example "@" is a symbol,
    /// so the statement "put @" raises an error, whereas "$" is not a symbol, so "put $" prints "$".
    func isSymbol() -> Bool {
        return HChar.isSymbol[Int(self)]
    }
    
    func isDigit() -> Bool {
        return self >= HChar.zero && self <= HChar.nine
    }
    
    func digitValue() -> Int {
        return Int(self - HChar.zero)
    }
    
    /// Letters. HyperTalk doesn't consider all the letters with diacritics as letters, for example "Â"
    func isLetter() -> Bool {
        return HChar.isLetter[Int(self)]
    }
    
    func isAlphaNumeric() -> Bool {
        return self.isLetter() || self.isDigit()
    }
    
    /// Whitespace characters. HyperCard accepts space and tabulation as whitespace.
    func isWhiteSpace() -> Bool {
        return self == HChar.space || self == HChar.tabulation
    }
    
    /// Related to word selection, nothing to do with scripts.
    func isWordElement() -> Bool {
        return self.isAlphaNumeric() || HChar.isWordElement[Int(self)]
    }
    
    private static let isSymbol: [Bool] = buildTable(with: "!&()*+,-/:<=>@[]^{|}≠≤≥")
    
    private static let isLetter: [Bool] = buildTable(with: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyzÄÅÇÉÑÖÜáàâäãåçéèêëíìîïñóòôöõúùûüßÆØæøÀÃÕŒœ")
    
    private static let isWordElement: [Bool] = buildTable(with: "$%'¢£¥ªº ÿ")
    
    private static func buildTable(with string: HString) -> [Bool] {
        
        var table = [Bool](repeating: false, count: 256)
        
        for i in 0..<string.length {
            
            table[Int(string[i])] = true
        }
        
        return table
    }
    
}
