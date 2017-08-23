//
//  File.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 27/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


/// A HyperCard stack, as a parsed file, not as an HyperCard object
public class HyperCardFile: ClassicFile {
    
    public enum StackError: Error {
        case notStack
        case corrupted
        case missingPassword
        case wrongPassword
    }
    
    private var decodedHeader: Data? = nil
    
    public init(path: String, password possiblePassword: HString? = nil) throws {
        
        super.init(path: path)
        
        /* Check if the file is a stack */
        if self.version == .notHyperCardStack {
            throw StackError.notStack
        }
        
        /* Check if the stack header is encrypted */
        if self.parsedData.stack.privateAccess {
            
            /* We must have a password to decrypt the header */
            guard let password = possiblePassword else {
                throw StackError.missingPassword
            }
            
            /* Ignore case and accents in the password */
            let lowerCaseNoAccentPassword = convertStringToLowerCaseWithoutAccent(password)
            
            /* Decrypt the header with the password */
            guard let decodedHeader = decryptHeader(withPassword: lowerCaseNoAccentPassword) else {
                throw StackError.wrongPassword
            }
            
            /* Register the decoded data */
            self.decodedHeader = decodedHeader
        }
        
        /* Check the checksum (must be after decryption) */
        guard self.parsedData.stack.isChecksumValid() else {
            throw StackError.corrupted
        }
        
    }
    
    private func decryptHeader(withPassword password: HString) -> Data? {
        
        /* Hash the password a first time */
        let firstHash = hashPassword(password)
        
        /* Decode the header with that hash */
        let decodedHeader = decodeHeader(withHash: firstHash)
        
        /* To get the password, hash the first hash as is it was a 4-char string */
        let firstHashString = convertIntegerTo4CharString(firstHash)
        let passwordHash = hashPassword(firstHashString)
        
        /* The decoded header, if correct, contains the password hash */
        let decodedPasswordHash = decodedHeader.readUInt32(at: 0x2C)
        guard passwordHash == decodedPasswordHash else {
            return nil
        }
        
        return decodedHeader
    }
    
    private func decodeHeader(withHash hash: Int) -> Data {
        
        /* Constants */
        let encodedDataOffset = 0x18
        let encodedDataLength = 0x32
        
        /* Get the hash */
        var x = hash
        
        /* Hash it ten times */
        for _ in 0..<10 {
            x = hashNumber(x)
        }
        
        /* Get the encoded data */
        let dataSlice = self.dataFork![encodedDataOffset..<(encodedDataOffset + encodedDataLength)]
        var data = Data(dataSlice)
        
        /* XOR the encoded data */
        for i in stride(from: 0, through: encodedDataLength - 4, by: 2) {
            
            /* Rehash each time */
            x = hashNumber(x)
            
            /* XOR x with the data */
            data[i]   ^= UInt8(truncatingBitPattern: x >> 24)
            data[i+1] ^= UInt8(truncatingBitPattern: x >> 16)
            data[i+2] ^= UInt8(truncatingBitPattern: x >> 8)
            data[i+3] ^= UInt8(truncatingBitPattern: x)
        }
        
        return data
        
    }
    
    private func hashPassword(_ password: HString) -> Int {
        
            var x = 0
            
            let character0 = Int(password[0])
            
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
        string[0] = HChar(truncatingBitPattern: x >> 24)
        string[1] = HChar(truncatingBitPattern: x >> 16)
        string[2] = HChar(truncatingBitPattern: x >> 8)
        string[3] = HChar(truncatingBitPattern: x)
        
        return string
    }
    
    /// The stack object contained in the file
    public lazy var stack: Stack = { [unowned self] in
        return Stack(fileContent: self.parsedData, resources: self.resourceRepository)
    }()
    
    /// The data blocks contained in the file
    public var parsedData: HyperCardFileData {
        let data = self.dataFork!
        let dataRange = DataRange(sharedData: data, offset: 0, length: data.count)
        
        switch version {
        case .preReleaseV2, .v2:
            return HyperCardFileData(data: dataRange, decodedHeader: self.decodedHeader)
            
        case .preReleaseV1, .v1:
            return HyperCardFileDataV1(data: dataRange, decodedHeader: self.decodedHeader)
            
        case .notHyperCardStack:
            fatalError("the data is not a HyperCard Stack")
            
        }
        
    }
    
    /// The version of the stack format: V1 or V2. Parsed here because it must be read before
    /// parsing the file.
    public var version: Version {
        let format = self.dataFork![0x13]
        switch format {
        case 1...7:
            return .preReleaseV1
        case 8:
            return .v1
        case 9:
            return .preReleaseV2
        case 10:
            return .v2
        default:
            return .notHyperCardStack
        }
    }
    
    /// The possible versions of the stack format.
    public enum Version: Int {
        case notHyperCardStack
        case preReleaseV1
        case v1
        case preReleaseV2
        case v2
    }
    
}
