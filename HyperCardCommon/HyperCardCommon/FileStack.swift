//
//  File.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 27/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


public extension Stack {
    
    public convenience init(file: ClassicFile, password possiblePassword: HString? = nil, hackEncryption: Bool = true) throws {
        
        /* Decrypt the header if necessary */
        let dataFork = file.dataFork!
        let decodedHeader: Data? = try Stack.computeDecodedHeader(in: dataFork, possiblePassword: possiblePassword, hackEncryption: hackEncryption)
        
        /* Check the checksum (must be after decryption) */
        let dataRange = DataRange(sharedData: dataFork, offset: 0, length: dataFork.count)
        let fileReader = HyperCardFileReader(data: dataRange, decodedHeader: decodedHeader)
        guard fileReader.extractStackReader().isChecksumValid() else {
            throw OpeningError.corrupted
        }
        
        /* Build the stack */
        self.init(fileReader: fileReader, resourceFork: file.resourceFork)
        
    }
    
    private static func computeDecodedHeader(in dataFork: Data, possiblePassword: HString?, hackEncryption: Bool) throws -> Data? {
        
        /* Check if the stack header is encrypted by making a fake header reader */
        let dataRange = DataRange(sharedData: dataFork, offset: 0, length: dataFork.count)
        let stackReader = StackBlockReader(data: dataRange, decodedHeader: nil)
        guard stackReader.readPrivateAccess() else {
            return nil
        }
        
        /* We must have a password to decrypt the header */
        if hackEncryption, let decodedHeader = Stack.hackEncryptedHeader(in: dataFork) {
            return decodedHeader
        }
        
        /* We must have a password to decrypt the header */
        guard let password = possiblePassword else {
            throw OpeningError.missingPassword
        }
        
        /* Ignore case and accents in the password */
        let lowerCaseNoAccentPassword = convertStringToLowerCaseWithoutAccent(password)
        
        /* Decrypt the header with the password */
        guard let decodedHeader = Stack.decryptHeader(withPassword: lowerCaseNoAccentPassword, in: dataFork) else {
            throw OpeningError.wrongPassword
        }
        
        /* Register the decoded data */
        return decodedHeader
    }
    
    private static func hackEncryptedHeader(in dataFork: Data) -> Data? {
        
        /* Find the first integer used to XOR the header */
        guard var x = hackFirstXor(in: dataFork) else {
            return nil
        }
        
        /* Constants */
        let encodedDataOffset = 0x18
        let encodedDataLength = 0x32
        
        /* Get the encoded data */
        let dataSlice = dataFork[encodedDataOffset..<(encodedDataOffset + encodedDataLength)]
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
    
    private static func hackFirstXor(in dataFork: Data) -> Int? {
        
        /* Get the first XORed integer */
        let xoredInteger = dataFork.readUInt32(at: 0x18)
        
        /* The initial value of the integer is the STAK size. XOR it with the STAK size so we have
         the value used to XOR the integer */
        let stackBlockSize = dataFork.readUInt32(at: 0x0)
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
            if transformedValue == xor && isFirstXorGood(value, in: dataFork) {
                return value
            }
            
        }
        
        return nil
    }
    
    private static func isFirstXorGood(_ value: Int, in dataFork: Data) -> Bool {
        
        /* We have to check one field in the decrypted header to see if it is "expected". The
         most restricted value in the decrypted header is the userLevel. */
        
        var hash = value
        
        /* Apply the hash as many times as it would be applied for a decryption of the user level */
        for _ in 0..<23 {
            hash = hashNumber(hash)
        }
        
        /* Check the user level */
        let xoredUserLevel = dataFork.readUInt16(at: 0x48)
        let userLevel = xoredUserLevel ^ (hash & 0xFFFF)
        
        return (userLevel >= 0 && userLevel <= 5)
    }
    
    private static func decryptHeader(withPassword password: HString, in dataFork: Data) -> Data? {
        
        /* Hash the password a first time */
        let firstHash = hashPassword(password)
        
        /* Decode the header with that hash */
        let decodedHeader = decodeHeader(withHash: firstHash, in: dataFork)
        
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
    
    private static func decodeHeader(withHash hash: Int, in dataFork: Data) -> Data {
        
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
        let dataSlice = dataFork[encodedDataOffset..<(encodedDataOffset + encodedDataLength)]
        var data = Data(dataSlice)
        
        /* XOR the encoded data */
        for i in stride(from: 0, through: encodedDataLength - 4, by: 2) {
            
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
    
    private static func hashPassword(_ password: HString) -> Int {
        
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
    
    private static func hashNumber(_ x: Int) -> Int {
        
        /* This function replicates the Random function of old Mac OS. It was used to make hashes. */
        var result = x * 0x41A7
        result += result >> 31
        result &= 0x7fff_ffff
        return result
    }
    
    private static func convertIntegerTo4CharString(_ x: Int) -> HString {
        
        /* Init a 4-char string */
        var string: HString = "    "
        
        /* Write the characters */
        string[0] = HChar(truncatingIfNeeded: x >> 24)
        string[1] = HChar(truncatingIfNeeded: x >> 16)
        string[2] = HChar(truncatingIfNeeded: x >> 8)
        string[3] = HChar(truncatingIfNeeded: x)
        
        return string
    }
    
    private convenience init(fileReader: HyperCardFileReader, resourceFork possibleResourceFork: Data?) {
        
        self.init()
        
        /* Register the resources */
        self.resourcesProperty.lazyCompute { () -> ResourceRepository? in
            guard let resourceFork = possibleResourceFork else {
                return nil
            }
            return ResourceRepository(fromResourceFork: resourceFork)
        }
        
        /* Get the stack */
        let stackReader = fileReader.extractStackReader()
        
        /* Read now the scalar fields */
        self.passwordHash = stackReader.readPasswordHash()
        self.userLevel = stackReader.readUserLevel()
        self.cantAbort = stackReader.readCantAbort()
        self.cantDelete = stackReader.readCantDelete()
        self.cantModify = stackReader.readCantModify()
        self.cantPeek = stackReader.readCantPeek()
        self.privateAccess = stackReader.readPrivateAccess()
        self.versionAtCreation = stackReader.readVersionAtCreation()
        self.versionAtLastCompacting = stackReader.readVersionAtLastCompacting()
        self.versionAtLastModificationSinceLastCompacting = stackReader.readVersionAtLastModificationSinceLastCompacting()
        self.versionAtLastModification = stackReader.readVersionAtLastModification()
        self.size = stackReader.readSize()
        self.windowRectangle = stackReader.readWindowRectangle()
        self.screenRectangle = stackReader.readScreenRectangle()
        self.scrollPoint = stackReader.readScrollPoint()
        
        /* Load some data to load the cards and backgrounds */
        let styleReader = fileReader.extractStyleBlockReader()
        let styles = styleReader?.readStyles() ?? []
        let loadBitmap = { (identifier: Int) -> BitmapBlockReader in
            return fileReader.extractBitmapReader(withIdentifier: identifier) }
        let loadBackgrounds = { [unowned self] () -> [Background] in
            return self.backgrounds
        }
        
        /* Cards */
        self.cardsProperty.lazyCompute { () -> [Card] in
            return Stack.listCards(fileReader: fileReader, loadBitmap: loadBitmap, styles: styles, loadBackgrounds: loadBackgrounds)
        }
        
        /* Backgrounds */
        self.backgroundsProperty.lazyCompute { () -> [Background] in
            return Stack.listBackgrounds(fileReader: fileReader, stackReader: stackReader, loadBitmap: loadBitmap, styles: styles)
        }
        
        /* patterns */
        self.patternsProperty.lazyCompute {
            return stackReader.readPatterns()
        }
        
        /* script */
        self.scriptProperty.lazyCompute {
            return stackReader.readScript()
        }
        
        /* font names */
        self.fontNameReferencesProperty.lazyCompute {
            return fileReader.extractFontBlockReader()?.readFontReferences() ?? []
        }
        
        
    }
    
    private static func listCards(fileReader: HyperCardFileReader, loadBitmap: @escaping (Int) -> BitmapBlockReader, styles: [IndexedStyle], loadBackgrounds: () -> [Background]) -> [Card] {
        
        var cards: [Card] = []
        
        /* Get the pages in the list */
        let listReader = fileReader.extractListReader()
        let pageReferences = listReader.readPageReferences()
        
        for pageReference in pageReferences {
            
            /* Get the cards in the page */
            let pageReader = fileReader.extractPageReader(from: pageReference)
            let cardReferences = pageReader.readCardReferences()
            
            for cardReference in cardReferences {
                
                /* Find the card data */
                let cardReader = fileReader.extractCardReader(withIdentifier: cardReference.identifier)
                
                /* Find the background */
                let backgroundIdentifier = cardReader.readBackgroundIdentifier()
                let backgrounds = loadBackgrounds()
                let background = backgrounds.first(where: { $0.identifier == backgroundIdentifier })!
                
                /* Build the card */
                let card = Card(cardReader: cardReader, cardReference: cardReference, loadBitmap: loadBitmap, styles: styles, background: background)
                cards.append(card)
            }
        }
        
        return cards
    }
    
    private static func listBackgrounds(fileReader: HyperCardFileReader, stackReader: StackBlockReader, loadBitmap: @escaping (Int) -> BitmapBlockReader, styles: [IndexedStyle]) -> [Background] {
        
        var backgrounds: [Background] = []
        
        /* Get the identifier of the first background of the stack */
        let firstBackgroundIdentifier = stackReader.readFirstBackgroundIdentifier()
        
        var currentIdentifier = firstBackgroundIdentifier
        
        repeat {
            
            /* Add the background with the current identifier */
            let backgroundReader = fileReader.extractBackgroundReader(withIdentifier: currentIdentifier)
            let background = Background(backgroundReader: backgroundReader, loadBitmap: loadBitmap, styles: styles)
            backgrounds.append(background)
            
            /* Move to the next identifier */
            currentIdentifier = backgroundReader.readNextBackgroundIdentifier()
            
        } while currentIdentifier != firstBackgroundIdentifier
        
        return backgrounds
    }
    
}
