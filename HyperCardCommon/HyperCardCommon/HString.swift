//
//  HString.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 26/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


public typealias HChar = UInt8


/// A Mac OS Roman string
public struct HString: Equatable, Hashable, Comparable, ExpressibleByStringLiteral, CustomStringConvertible {
    
    public private(set) var data: Data
    
    public init(data: Data) {
        self.data = data
    }
    
    public init(stringLiteral: String) {
        let data = stringLiteral.data(using: .macOSRoman)
        self.data = data!
    }
    
    public init(extendedGraphemeClusterLiteral: String) {
        self.init(stringLiteral: extendedGraphemeClusterLiteral)
    }
    
    public init(unicodeScalarLiteral: String) {
        self.init(stringLiteral: unicodeScalarLiteral)
    }
    
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
    
    public static func ==(s1: HString, s2: HString) -> Bool {
        return s1.data == s2.data
    }
    
    public static func <(s1: HString, s2: HString) -> Bool {
        return s1.data.lexicographicallyPrecedes(s2.data)
    }
    
    public static func <=(s1: HString, s2: HString) -> Bool {
        return !s2.data.lexicographicallyPrecedes(s1.data)
    }
    
    public static func >(s1: HString, s2: HString) -> Bool {
        return s2.data.lexicographicallyPrecedes(s1.data)
    }
    
    public static func >=(s1: HString, s2: HString) -> Bool {
        return !s1.data.lexicographicallyPrecedes(s2.data)
    }
    
    public static func ==(hstring: HString, string: String) -> Bool {
        return hstring.description == string
    }
    
    public static func ==(string: String, hstring: HString) -> Bool {
        return hstring.description == string
    }
    
}

