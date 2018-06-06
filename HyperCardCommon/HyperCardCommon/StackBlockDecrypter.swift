//
//  Decrypter.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 06/06/2018.
//  Copyright © 2018 Pierre Lorenzi. All rights reserved.
//


public struct StackBlockDecrypter {
    
    private let stackBlockData: DataRange
    
    public static let encodedDataOffset = 0x18
    public static let encodedDataLength = 0x32
    
    public init(stackBlockData: DataRange) {
        self.stackBlockData = stackBlockData
    }
    
    public func decrypt(withPassword caseDiacriticsPassword: HString) -> Data? {
        
        /* Ignore case and accents in the password */
        let password = convertStringToLowerCaseWithoutAccent(caseDiacriticsPassword)
        
        /* Hash the password a first time */
        let firstHash = hashPassword(password)
        
        /* Decode the header with that hash */
        let decodedData = decode(withHash: firstHash)
        
        /* To get the password, hash the first hash as is it was a 4-char string */
        let firstHashString = convertIntegerTo4CharString(firstHash)
        let passwordHash = hashPassword(firstHashString)
        
        /* The decoded header, if correct, contains the password hash */
        let decodedPasswordHash = decodedData.readUInt32(at: 0x2C)
        guard passwordHash == decodedPasswordHash else {
            return nil
        }
        
        return decodedData
    }
    
    private func decode(withHash hash: Int) -> Data {
        
        /* Get the hash */
        var x = hash
        
        /* Hash it ten times */
        for _ in 0..<10 {
            x = hashNumber(x)
        }
        
        /* Get the encoded data */
        let dataSlice = self.stackBlockData.sharedData[StackBlockDecrypter.encodedDataOffset..<(StackBlockDecrypter.encodedDataOffset + StackBlockDecrypter.encodedDataLength)]
        var data = Data(dataSlice)
        
        /* XOR the encoded data */
        for i in stride(from: 0, through: StackBlockDecrypter.encodedDataLength - 4, by: 2) {
            
            /* Rehash each time */
            x = hashNumber(x)
            
            /* XOR x with the data */
            data[i]   ^= UInt8(truncatingIfNeeded: x >> 24)
            data[i+1] ^= UInt8(truncatingIfNeeded: x >> 16)
            data[i+2] ^= UInt8(truncatingIfNeeded: x >> 8)
            data[i+3] ^= UInt8(truncatingIfNeeded: x)
        }
        
        return data
        
    }
    
    private func hashPassword(_ password: HString) -> Int {
        
        var x = 0
        
        let character0 = password.length > 0 ? Int(password[0]) : 0
        
        var s = character0 + password.length
        if s > 0xff {
            s &= 0xff
        }
        else if character0 > 0x80 {
            s |= 0xffff_ff00
        }
        
        for i in 0..<password.length {
            
            let character = password[i]
            
            for i in 0..<8 {
                s = hashNumber(s)
                if (character >> UInt8(7-i)) & 1 != 0 {
                    x += s
                }
            }
        }
        
        if x == 0 {
            return 0x42696c6c // 'Bill'
        }
        
        return x & 0xFFFF_FFFF
    }
    
    private func hashNumber(_ x: Int) -> Int {
        
        /* This function replicates the Random function of old Mac OS. It was used to make hashes. */
        var result = x * 0x41A7
        result += result >> 31
        result &= 0x7fff_ffff
        return result
    }
    
    private func convertIntegerTo4CharString(_ x: Int) -> HString {
        
        /* Init a 4-char string */
        var string: HString = "    "
        
        /* Write the characters */
        string[0] = HChar(truncatingIfNeeded: x >> 24)
        string[1] = HChar(truncatingIfNeeded: x >> 16)
        string[2] = HChar(truncatingIfNeeded: x >> 8)
        string[3] = HChar(truncatingIfNeeded: x)
        
        return string
    }
    
    public func hack() -> Data? {
        
        /* Find the first integer used to XOR the header */
        guard var x = hackFirstXor() else {
            return nil
        }
        
        /* Constants */
        let encodedDataOffset = 0x18
        let encodedDataLength = 0x32
        
        /* Get the encoded data */
        let dataSlice = self.stackBlockData.sharedData[encodedDataOffset..<(encodedDataOffset + encodedDataLength)]
        var data = Data(dataSlice)
        
        /* XOR the encoded data */
        for i in stride(from: 0, through: encodedDataLength - 4, by: 2) {
            
            /* XOR x with the data */
            data[i]   ^= UInt8(truncatingIfNeeded: x >> 24)
            data[i+1] ^= UInt8(truncatingIfNeeded: x >> 16)
            data[i+2] ^= UInt8(truncatingIfNeeded: x >> 8)
            data[i+3] ^= UInt8(truncatingIfNeeded: x)
            
            /* Rehash each time */
            x = hashNumber(x)
        }
        
        return data
        
    }
    
    private func hackFirstXor() -> Int? {
        
        /* Get the first XORed integer */
        let xoredInteger = self.stackBlockData.readUInt32(at: 0x18)
        
        /* The initial value of the integer is the STAK size. XOR it with the STAK size so we have
         the value used to XOR the integer */
        let stackBlockSize = self.stackBlockData.readUInt32(at: 0x0)
        let xor = xoredInteger ^ stackBlockSize
        
        /* The XOR is equal to a result x = x ^ (hashNumber(x) >> 16). We have to find x. As the
         second part of the XOR is only on the last 16 bits, the first 16 bits of the integer
         are the first 16 bits of x. We have to try all possibilities for the last 16 bits. */
        let first16Bits = xor & 0xFFFF_0000
        
        for i in 0..<Int(UInt16.max) {
            
            /* Build x */
            let value = first16Bits | i
            
            /* Apply the transform to x */
            let transformedValue = value ^ (hashNumber(value) >> 16)
            
            /* Check if we have found the right value */
            if transformedValue == xor && isFirstXorGood(value) {
                return value
            }
            
        }
        
        return nil
    }
    
    private func isFirstXorGood(_ value: Int) -> Bool {
        
        /* We have to check one field in the decrypted header to see if it is "expected". The
         most restricted value in the decrypted header is the userLevel. */
        
        var hash = value
        
        /* Apply the hash as many times as it would be applied for a decryption of the user level */
        for _ in 0..<23 {
            hash = hashNumber(hash)
        }
        
        /* Check the user level */
        let xoredUserLevel = self.stackBlockData.readUInt16(at: 0x48)
        let userLevel = xoredUserLevel ^ (hash & 0xFFFF)
        
        return (userLevel >= 0 && userLevel <= 5)
    }
    
}
