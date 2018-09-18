//
//  SeachHash.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 26/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


/// A hash used in HyperCard for word search in a card
public struct SearchHash {
    
    public var ints: [UInt32]
    
    private let size: Int
    
    public let valueCount: Int
    
    public init(ints: [UInt32], valueCount: Int) {
        self.ints = ints
        let bitCount = ints.count * 32 - 9
        let size = SearchHash.findGreatestPrimeUnder(bitCount)
        self.size = size
        self.valueCount = valueCount
    }
    
    private static func findGreatestPrimeUnder(_ n: Int) -> Int {
        
        if n < 3 {
            return n
        }
        
        for k in (2...n).reversed() {
            if isPrime(k) {
                return k
            }
        }
        
        return 1
    }
    
    private static func isPrime(_ n: Int) -> Bool {
        
        if n < 4 {
            return true
        }
        
        for k in 2...Int(sqrt(Double(n))) {
            if n % k == 0 {
                return false
            }
        }
        
        return true
        
    }
    
    /// Converts a word to an integer representation, that is used to check for the word.
    /// This method is made public so the conversion can be made once even if the word is
    /// checked on several search hashes.
    public static func encodeString(_ string: HString) -> [Int]? {
        
        var encodedString = [Int]()
        
        /* Encode every character */
        for i in 0..<string.length {
            
            /* The character may not have code */
            guard let encodedCharacter = encodeCharacter(string[i]) else {
                return nil
            }
            
            encodedString.append(encodedCharacter)
        }
        
        return encodedString
    }
    
    private static let DigitCodes = [27, 28, 29, 30, 31, 32, 17, 22, 24, 26]
    
    private static func encodeCharacter(_ index: UInt8) -> Int? {
        
        /* If character is uppercase letter */
        if index >= UInt8(65) && index < UInt8(91) {
            return Int(index - UInt8(64))
        }
        
        /* If character is lowercase letter */
        if index >= UInt8(97) && index < UInt8(123) {
            return Int(index - UInt8(96))
        }
        
        /* If character is digit */
        if index >= UInt8(48) && index < UInt8(58) {
            return DigitCodes[Int(index-UInt8(48))]
        }
        
        return nil
    }
    
    /// Checks if the word is detected present by the hash
    public func isStringSpotted(_ string: HString) -> Bool? {
        guard let code = SearchHash.encodeString(string) else {
            return nil
        }
        return self.isEncodedStringSpotted(code)
    }
    
    /// Checks if the encoded version of a word is detected present by the hash
    public func isEncodedStringSpotted(_ code: [Int]) -> Bool {
        
        /* Check the first values */
        guard isValuePresent(code[0]*4096 - (code[0]/16)*65535 + code[1]*128 + code[2]*4) else {
            return false
        }
        guard isValuePresent(code[0]*16384 - (code[0]/4)*65535 + code[1]*512 + code[2]*16) else {
            return false
        }
        guard isValuePresent(code[0] + code[1]*2048 + code[2]*64) else {
            return false
        }
        guard valueCount < 4 || isValuePresent(code[0]*4 + code[1]*8192 - (code[1]/8)*65535 + code[2]*256) else {
            return false
        }
        
        /* Check the following values */
        for i in 3..<code.count {
            
            guard isValuePresent(code[i] + code[i-1]*32 + code[i-2]*1024 + code[i-3]*32768) else {
                return false
            }
        }
        
        return true
        
    }
    
    private func isValuePresent(_ value: Int) -> Bool {
        
        /* When a value is present, that means the bit with the index <value> is activated */
        
        /* Get the value bit index */
        let bitIndexInHash = value % self.size
        let bitIndex = 9 + bitIndexInHash + ((bitIndexInHash < 0) ? size : 0)
        
        /* Locate it in the ints */
        let integerIndex = bitIndex / 32
        let indexInInteger = 31 - bitIndex % 32
        
        /* Check the value */
        let hash = UInt32(1) << UInt32(indexInInteger)
        let int = ints[integerIndex]
        return (hash & int) != 0
        
    }
    
    /// Tells if the word is excluded or not from the hash. For example words that are too short are excluded.
    public static func isWordIndexed(_ word: HString) -> Bool {
        
        /* Words less than 3 characters are not indexed */
        guard word.length >= 3 else {
            return false
        }
        
        /* 'the' is not indexed */
        if word.length == 3 && (word[0] == 84 || word[0] == 116) && (word[1] == 72 || word[1] == 104) && (word[2] == 69 || word[2] == 101) {
            return false
        }
        
        /* Digits are not always indexed */
        guard !isWordNumber(word) else {
            return false
        }
        
        return true
    }
    
    private static func isWordNumber(_ word: HString) -> Bool {
        
        for i in 0..<word.length {
            let char = word[i]
            guard char >= 48 && char < 58 else {
                return false
            }
        }
        
        return true
    }
    
}

