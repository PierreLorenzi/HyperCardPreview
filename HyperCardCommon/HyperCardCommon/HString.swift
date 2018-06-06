//
//  HString.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 26/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


/// A Mac OS Roman character, in a single byte
public typealias HChar = UInt8


/// A Mac OS Roman string
/// <p>
/// It is not equatable because string comparisons in old Mac OS are always
/// case-insensitive or even diacritics-insensitive, so the byte-to-byte comparison
/// it not an option.
public struct HString: ExpressibleByStringLiteral, CustomStringConvertible {
    
    /// The bytes of the string, without null terminator
    public private(set) var data: Data
    
    /// Main constructor
    public init(data: Data) {
        self.data = data
    }
    
    /// Conversion from Swift string
    public init?(converting string: String) {
        
        guard let data = string.data(using: .macOSRoman) else {
            return nil
        }
        
        self.data = data
    }
    
    public init(stringLiteral: String) {
        
        /* If the HString is assigned with a string literal, assume it is Mac OS Roman */
        self.init(converting: stringLiteral)!
    }
    
    public init(extendedGraphemeClusterLiteral: String) {
        self.init(stringLiteral: extendedGraphemeClusterLiteral)
    }
    
    public init(unicodeScalarLiteral: String) {
        self.init(stringLiteral: unicodeScalarLiteral)
    }
    
    /// Get or set a single character
    public subscript(index: Int) -> HChar {
        get {
            return data[index]
        }
        set {
            data[index] = newValue
        }
    }
    
    public subscript(range: CountableClosedRange<Int>) -> HString {
        get {
            let extractedData = Data(data[range])
            return HString(data: extractedData)
        }
        set {
            data.replaceSubrange(range, with: newValue.data)
        }
    }
    
    public subscript(range: CountableRange<Int>) -> HString {
        get {
            let extractedData = Data(data[range])
            return HString(data: extractedData)
        }
        set {
            data.replaceSubrange(range, with: newValue.data)
        }
    }
    
    /// The number of characters in the string
    public var length: Int {
        return data.count
    }
    
    public var description: String {
        let string = String(data: data, encoding: .macOSRoman)
        return string!
    }
    
    public var hashValue: Int {
        var hashValue = 0
        for byte in data {
            hashValue += Int(byte)
            hashValue *= 31
        }
        return hashValue
    }
    
    public static func ==(hstring: HString, string: String) -> Bool {
        return hstring.description == string
    }
    
    public static func !=(hstring: HString, string: String) -> Bool {
        return hstring.description != string
    }
    
}
