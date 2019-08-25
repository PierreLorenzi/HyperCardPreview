//
//  NumericName.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 22/03/2016.
//  Copyright © 2016 Pierre Lorenzi. All rights reserved.
//


public extension Int {
    
    init(classicType: String) {var shift = 24
        
        var identifier = 0
        
        for code in classicType.unicodeScalars {
            
            /* There must not be more than 4 chars */
            if shift < 0 {
                fatalError()
            }
            
            /* The code must be ASCII */
            if !code.isASCII {
                fatalError()
            }
            
            /* Append the code to the identifier */
            let codeValue = Int(code.value)
            identifier |= codeValue << shift
            
            /* Move to the next bits */
            shift -= 8
            
        }
        
        /* There must not be less that 4 chars */
        if shift != -8 {
            fatalError()
        }
        
        self = identifier
    }
}

/// A 4-byte identifier, printed as a 4-char string. It was commonly used in old Mac OS.
public struct NumericName: Equatable, CustomStringConvertible {
    public let value: Int
    
    public init(value: Int) {
        self.value = value
    }
    
    public init?(string: String) {
        var shift = 24
        var identifier = 0
        
        for code in string.unicodeScalars {
            
            /* There must not be more than 4 chars */
            if shift < 0 {
                return nil
            }
            
            /* The code must be ASCII */
            if !code.isASCII {
                return nil
            }
            
            /* Append the code to the identifier */
            let codeValue = Int(code.value)
            identifier |= codeValue << shift
            
            /* Move to the next bits */
            shift -= 8
            
        }
        
        /* There must not be less that 4 chars */
        if shift != -8 {
            return nil
        }
        
        self.value = identifier
    }
    
    public var description: String {
        
        /* Build the string char per char */
        var string = ""
        
        for i in 0..<4 {
            
            let value = (self.value >> ((3-i) * 8)) & 0xFF
            
            /* Append the character to the string */
            let scalar = UnicodeScalar(value)
            let character = Character(scalar!)
            string.append(character)
        }
        
        return string
    }
}


public func ==(i1: NumericName, i2: NumericName) -> Bool {
    return i1.value == i2.value
}
