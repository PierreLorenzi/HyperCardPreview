//
//  File.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 27/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


public extension Stack {
    
    /// Loads a stack from the data fork of a stack file. If the stack is private access,
    /// so encrypted, a password can be provided or a hack can be made.
    convenience init(loadFromData fileData: Data, password possiblePassword: HString? = nil, hackEncryption: Bool = true) throws {
        
        self.init()
        
        let data = DataRange(wholeData: fileData)
        
        /* Decode the data if necessary */
        let decodedData = try Stack.decodeData(data, password: possiblePassword, hackEncryption: hackEncryption)
        
        /* Checksum */
        guard Stack.checkStackChecksum(in: data, decodedData: decodedData) else {
            throw OpeningError.corrupted
        }
        
        /* Load now the scalar fields of the stack */
        self.loadScalarFields(in: data, decodedData: decodedData)
        
        /* Lazy-load the stack structure */
        self.loadStructureFields(in: data, decodedData: decodedData)
    }
    
    private struct CardList {
        
        var cardReferenceSize: Int
        var pageReferences: [PageReference]
    }
    
    private static func decodeData(_ data: DataRange, password possiblePassword: HString?, hackEncryption: Bool) throws -> DataRange {
        
        /* Check if the stack is encoded */
        let isPrivateAccess = data.readFlag(at: 0x4C, bitOffset: 13)
        guard isPrivateAccess else {
            return data
        }
        
        let decrypter = StackBlockDecrypter(stackBlockData: data)
        
        /* Ensure the encoded data has the same indexes as the original one */
        let decodedDataOffset = -StackBlockDecrypter.encodedDataOffset
        let decodedDataLength = StackBlockDecrypter.encodedDataOffset + StackBlockDecrypter.encodedDataLength
        
        /* If hack is requested */
        if hackEncryption, let decodedData = decrypter.hack() {
            return DataRange(sharedData: decodedData, offset: decodedDataOffset, length: decodedDataLength)
        }
        
        /* Use the password if given */
        guard let password = possiblePassword else {
            throw OpeningError.missingPassword
        }
        guard let decodedData = decrypter.decrypt(withPassword: password) else {
            throw OpeningError.wrongPassword
        }
        
        return DataRange(sharedData: decodedData, offset: decodedDataOffset, length: decodedDataLength)
    }
    
    private static func checkStackChecksum(in data: DataRange, decodedData: DataRange) -> Bool {
        
        var sum: UInt32 = 0
        for i in stride(from: 0, to: 0x600, by: 4) {
            sum = sum &+ UInt32(data.readUInt32(at: i))
        }
        
        /* The checksum is done with the decoded data, so subtract the encoded data and
         add the decoded one. */
        let startOffset = StackBlockDecrypter.encodedDataOffset
        let endOffset = startOffset + StackBlockDecrypter.encodedDataLength
        
        for i in stride(from: startOffset, to: endOffset-2, by: 4) {
            sum = sum &+ UInt32(decodedData.readUInt32(at: i))
            sum = sum &- UInt32(data.readUInt32(at: i))
        }
        
        /* The last integer is half encoded half clear */
        sum = sum &+ UInt32(decodedData.readUInt16(at: endOffset-2) << 16 | data.readUInt16(at: endOffset))
        sum = sum &- UInt32(data.readUInt32(at: endOffset-2))
        
        return sum == 0
    }
    
    private func loadScalarFields(in data: DataRange, decodedData: DataRange) {
        
        self.passwordHash = decodedData.readOptionalUInt32(at: 0x44)
        self.userLevel = decodedData.readUserLevel(at: 0x48)
        self.cantAbort = data.readFlag(at: 0x4C, bitOffset: 11)
        self.cantDelete = data.readFlag(at: 0x4C, bitOffset: 14)
        self.cantModify = data.readFlag(at: 0x4C, bitOffset: 15)
        self.cantPeek = data.readFlag(at: 0x4C, bitOffset: 10)
        self.privateAccess = data.readFlag(at: 0x4C, bitOffset: 13)
        self.versionAtCreation = data.readApplicationVersion(at: 0x60)
        self.versionAtLastCompacting = data.readApplicationVersion(at: 0x64)
        self.versionAtLastModificationSinceLastCompacting = data.readApplicationVersion(at: 0x68)
        self.versionAtLastModification = data.readApplicationVersion(at: 0x6C)
        self.size = data.readHyperCardWindowSize(at: 0x1B8)
        self.windowRectangle = data.readRectangle(at: 0x78)
        self.screenRectangle = data.readRectangle(at: 0x80)
        self.scrollPoint = data.readPoint(at: 0x88)
        
        /* Lazy-load script */
        self.scriptProperty.lazyCompute { () -> HString in
            
            let stackDataLength = data.readUInt32(at: 0)
            guard stackDataLength > 0x600 else {
                return ""
            }
            return data.readString(at: 0x600)
        }
        
        /* Lazy-load patterns */
        self.patternsProperty.lazyCompute { () -> [Image] in
            
            return data.readPatterns(at: 0x2C0)
        }
        
    }
    
    private func loadStructureFields(in data: DataRange, decodedData: DataRange) {
        
        /* To find the blocks in the file, make a function */
        let loadBlockAction = self.makeLoadBlockAction(in: data, decodedData: decodedData)
        let fileVersion = data.readFileVersion(at: 0x10)
        
        /* Load the styles, the cards and backgrounds need it */
        let styleBlockIdentifier = data.readOptionalUInt32(at: 0x1B4)
        let styles = Stack.retrieveStyles(styleBlockIdentifier: styleBlockIdentifier, loadBlockAction: loadBlockAction)
        
        /* Lazy load the cards */
        self.cardsProperty.lazyCompute { () -> [Card] in
            
            let listIdentifier = decodedData.readUInt32(at: 0x34)
            
            return Stack.listCards(listIdentifier: listIdentifier, styles: styles, fileVersion: fileVersion, stack: self, loadBlockAction: loadBlockAction)
        }
        
        /* Lazy load the backgrounds */
        self.backgroundsProperty.lazyCompute { () -> [Background] in
            
            let firstBackgroundIdentifier = decodedData.readUInt32(at: 0x28)
            
            return Stack.listBackgrounds(firstBackgroundIdentifier: firstBackgroundIdentifier, styles: styles, fileVersion: fileVersion, loadBlockAction: loadBlockAction)
        }
        
        /* Lazy-load the font names */
        self.fontNameReferencesProperty.lazyCompute { () -> [FontNameReference] in
            
            let fontBlockIdentifier = data.readOptionalUInt32(at: 0x1B0)
            
            return Stack.loadFontNames(fontBlockIdentifier: fontBlockIdentifier, loadBlockAction: loadBlockAction)
        }
        
    }
    
    private func makeLoadBlockAction(in fileData: DataRange, decodedData: DataRange) -> ((Int, Int) -> DataRange) {
        
        /* Retrieve the master data */
        let masterOffset = decodedData.readUInt32(at: 0x18)
        let tableCount = 1 + decodedData.readUInt32(at: 0x20)
        let masterData = DataRange(fromData: fileData, offset: masterOffset)
        
        /* Build the action */
        return { (type: Int, identifier: Int) in
            
            return Stack.findBlock(type: type, identifier: identifier, fileData: fileData, masterData: masterData, tableCount: tableCount)
        }
    }
    
    private static func findBlock(type: Int, identifier: Int, fileData: DataRange, masterData: DataRange, tableCount: Int) -> DataRange {
        
        /* Extract the fields from the block ID */
        let lastByte = identifier & 0xFF
        let slotIndex = (identifier >> 8) & 0x7F
        let tableIndex = identifier >> 15
        
        /* Check table index bounds */
        guard tableIndex >= 0 && tableIndex < tableCount else {
            fatalError()
        }
        
        /* Read the corresponding slot in the master */
        let tableLength = 0x200
        let slotLength = 4
        let slotOffset = tableIndex * tableLength + slotIndex * slotLength
        let slot = masterData.readUInt32(at: slotOffset)
        
        /* Extract the fields from the slot value */
        let slotLastByte = slot & 0xFF
        let blockOffset = (slot >> 8) * 0x20
        
        /* Check that last byte matches */
        guard lastByte == slotLastByte else {
            fatalError()
        }
        
        /* Retrieve the block data */
        let blockLength = fileData.readUInt32(at: blockOffset)
        let blockData = DataRange(fromData: fileData, offset: blockOffset, length: blockLength)
        
        /* Check type and identifier */
        guard type == blockData.readUInt32(at: 0x4) else {
            fatalError()
        }
        guard identifier == blockData.readUInt32(at: 0x8) else {
            fatalError()
        }
        
        return blockData
    }
    
    private static func listCards(listIdentifier: Int, styles: [IndexedStyle], fileVersion: FileVersion, stack: Stack, loadBlockAction: @escaping (Int,Int) -> DataRange) -> [Card] {
        
        var cards: [Card] = []
        
        /* Load the card list */
        let listType = Int(classicType: "LIST")
        let listData = loadBlockAction(listType, listIdentifier)
        let list = readList(inList: listData, fileVersion: fileVersion)
        
        /* Prepare some values to create the cards */
        let loadBitmap = makeLoadBitmap(fileVersion: fileVersion, loadBlockAction: loadBlockAction)
        
        /* Load the pages */
        for pageReference in list.pageReferences {
            
            /* Find the page */
            let pageType = Int(classicType: "PAGE")
            let pageData = loadBlockAction(pageType, pageReference.identifier)
            
            /* Read the cards in the page */
            let cardReferences = readCardReferences(inPage: pageData, cardCount: pageReference.cardCount, cardReferenceSize: list.cardReferenceSize, fileVersion: fileVersion)
            
            /* Load the cards */
            for cardReference in cardReferences {
                
                /* Retrieve the card data */
                let cardType = Int(classicType: "CARD")
                let cardData = loadBlockAction(cardType, cardReference.identifier)
                
                /* Find the background */
                let backgroundIdentifier = cardData.readUInt32(at: 0x24 + (fileVersion.isTwo() ? 0 : -4))
                let background = stack.backgrounds.first(where: { $0.identifier == backgroundIdentifier })!
                
                /* Load the card */
                let card = Card(loadFromData: cardData, version: fileVersion, cardReference: cardReference, loadBitmap: loadBitmap, styles: styles, background: background)
                
                cards.append(card)
            }
        }
        
        return cards
    }
    
    private static func makeLoadBitmap(fileVersion: FileVersion, loadBlockAction: @escaping (Int,Int) -> DataRange) -> ((Int) -> MaskedImage) {
        
        return { (identifier: Int) -> MaskedImage in
            
            let bitmapType = Int(classicType: "BMAP")
            let bitmapBlock = loadBlockAction(bitmapType, identifier)
            let bitmapBlockReader = BitmapBlockReader(data: bitmapBlock, version: fileVersion)
            return bitmapBlockReader.readImage()
        }
    }
    
    private static func readList(inList data: DataRange, fileVersion: FileVersion) -> CardList {
        
        let versionOffset = fileVersion.isTwo() ? 0 : -4
        let referenceCount = data.readUInt32(at: 0x10 + versionOffset)
        let expectedChecksum = data.readUInt32(at: 0x24 + versionOffset)
        let cardReferenceSize = data.readUInt16(at: 0x1C + versionOffset)
        
        var references = [PageReference]()
        var offset = 0x30
        var checksum: UInt32 = 0
        
        for _ in 0..<referenceCount {
            
            /* Add reference */
            let pageIdentifier = data.readUInt32(at: offset)
            let cardCount = data.readUInt16(at: offset + 4)
            references.append(PageReference(identifier: pageIdentifier, cardCount: cardCount))
            
            /* Update checksum */
            checksum = rotateRight3Bits(checksum + UInt32(pageIdentifier)) + UInt32(cardCount)
            
            offset += 6
        }
        
        /* Check checksum */
        guard checksum == expectedChecksum else {
            fatalError()
        }
        
        return CardList(cardReferenceSize: cardReferenceSize, pageReferences: references)
    }
    
    private static func readCardReferences(inPage data: DataRange, cardCount: Int, cardReferenceSize: Int, fileVersion: FileVersion) -> [CardReference] {
        
        let versionOffset = fileVersion.isTwo() ? 0 : -4
        let expectedChecksum = data.readUInt32(at: 0x14 + versionOffset)
        
        var references = [CardReference]()
        var checksum: UInt32 = 0
        
        var offset = 0x18
        
        for _ in 0..<cardCount {
            
            /* Read the fields */
            let cardIdentifier = data.readUInt32(at: offset)
            let marked = data.readFlag(at: offset + 4, bitOffset: 12)
            
            /* Make the reference */
            let reference = CardReference(identifier: cardIdentifier, marked: marked)
            references.append(reference)
            
            /* Update checksum */
            checksum = rotateRight3Bits(checksum &+ UInt32(cardIdentifier))
            
            offset += cardReferenceSize
        }
        
        guard checksum == expectedChecksum else {
            fatalError()
        }
        
        return references
    }
    
    private static func retrieveStyles(styleBlockIdentifier possibleIdentifier: Int?, loadBlockAction: @escaping (Int,Int) -> DataRange) -> [IndexedStyle] {
        
        /* If there is no style block, the list is empty */
        guard let blockIdentifier = possibleIdentifier else {
            return []
        }
        
        /* Load the block and read it */
        let styleType = Int(classicType: "STBL")
        let blockData = loadBlockAction(styleType, blockIdentifier)
        
        return readStyles(in: blockData)
    }
    
    private static func readStyles(in data: DataRange) -> [IndexedStyle] {
        
        let styleCount = data.readUInt32(at: 0x10)
        
        var offset = 0x18
        var styles: [IndexedStyle] = []
        
        for _ in 0..<styleCount {
            
            let number = data.readUInt32(at: offset)
            let runCount = data.readUInt16(at: offset + 0x6)
            let fontFamilyIdentifierValue = data.readSInt16(at: offset + 0xC)
            let styleFlagsValue = data.readSInt16(at: offset + 0xE)
            let sizeValue = data.readSInt16(at: offset + 0x10)
            let fontFamilyIdentifier: Int? = (fontFamilyIdentifierValue == -1) ? nil : fontFamilyIdentifierValue
            let style: TextStyle? = (styleFlagsValue == -1) ? nil : TextStyle(flags: styleFlagsValue >> 8)
            let size: Int? = (sizeValue == -1) ? nil : sizeValue
            let attribute = TextFormatting(fontFamilyIdentifier: fontFamilyIdentifier, size: size, style: style)
            styles.append(IndexedStyle(number: number, runCount: runCount, textAttribute: attribute))
            offset += 0x18
        }
        return styles
    }
    
    private static func listBackgrounds(firstBackgroundIdentifier: Int, styles: [IndexedStyle], fileVersion: FileVersion, loadBlockAction: @escaping (Int,Int) -> DataRange) -> [Background] {
        
        var backgrounds: [Background] = []
        
        var currentIdentifier = firstBackgroundIdentifier
        
        /* Prepare some values to create the background */
        let loadBitmap = makeLoadBitmap(fileVersion: fileVersion, loadBlockAction: loadBlockAction)
        
        repeat {
            
            /* Add the background with the current identifier */
            let backgroundType = Int(classicType: "BKGD")
            let backgroundData = loadBlockAction(backgroundType, currentIdentifier)
            let background = Background(loadFromData: backgroundData, version: fileVersion, loadBitmap: loadBitmap, styles: styles)
            backgrounds.append(background)
            
            /* Move to the next identifier */
            currentIdentifier = backgroundData.readUInt32(at: 0x1C + (fileVersion.isTwo() ? 0 : -4))
            
        } while currentIdentifier != firstBackgroundIdentifier
        
        return backgrounds
    }
    
    private static func loadFontNames(fontBlockIdentifier possibleIdentifier: Int?, loadBlockAction: (Int,Int) -> DataRange) -> [FontNameReference] {
        
        /* If there is no block, the list is empty */
        guard let fontBlockIdentifier = possibleIdentifier else {
            return []
        }
        
        /* Retrieve the data */
        let fontBlockType = Int(classicType: "FTBL")
        let fontBlockData = loadBlockAction(fontBlockType, fontBlockIdentifier)
        
        /* Read the data */
        return readFontNames(in: fontBlockData)
    }
    
    private static func readFontNames(in data: DataRange) -> [FontNameReference] {
        
        let count = data.readUInt32(at: 0x10)
        
        var offset = 0x18
        var fonts: [FontNameReference] = []
        
        for _ in 0..<count {
            
            /* Read the fields */
            let fontIdentifier = data.readUInt16(at: offset)
            let fontName = data.readString(at: offset + 0x2)
            
            /* Build the reference */
            let reference = FontNameReference(identifier: fontIdentifier, name: fontName)
            fonts.append(reference)
            
            /* Advance after the name, 16-bit aligned */
            offset += 2 + fontName.length + 1
            if offset & 1 != 0 {
                offset += 1
            }
        }
        return fonts
    }
    
    /// Loads a stack from the data fork of a stack file. If the stack is private access,
    /// so encrypted, a password can be provided or a hack can be made.
    convenience init(loadFromDataOld data: Data, password possiblePassword: HString? = nil, hackEncryption: Bool = true) throws {
        
        let dataRange = DataRange(sharedData: data, offset: 0, length: data.count)
        let fileReader = StackReader(data: dataRange)
        
        self.init()
        
        /* Get a reader for the stack informations */
        let stackBlock = fileReader.extractStackBlock()
        let stackReader = try StackBlockReader(data: stackBlock, password: possiblePassword, hackEncryption: hackEncryption)
        
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
        let version = stackReader.readVersion()
        let styles = Stack.loadStyles(fileReader: fileReader, stackReader: stackReader)
        let loadBitmap = { (identifier: Int) -> MaskedImage in
            let bitmapBlock = fileReader.extractBitmapBlock(withIdentifier: identifier)
            let bitmapBlockReader = BitmapBlockReader(data: bitmapBlock, version: version)
            return bitmapBlockReader.readImage()
        }
        let loadBackgrounds = { [unowned self] () -> [Background] in
            return self.backgrounds
        }
        
        /* Cards */
        self.cardsProperty.lazyCompute { () -> [Card] in
            return Stack.listCards(fileReader: fileReader, stackReader: stackReader, version: version, loadBitmap: loadBitmap, styles: styles, loadBackgrounds: loadBackgrounds)
        }
        
        /* Backgrounds */
        self.backgroundsProperty.lazyCompute { () -> [Background] in
            return Stack.listBackgrounds(fileReader: fileReader, stackReader: stackReader, version: version, loadBitmap: loadBitmap, styles: styles)
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
            return Stack.loadFonts(fileReader: fileReader, stackReader: stackReader)
        }
        
    }
    
    private static func loadStyles(fileReader: StackReader, stackReader: StackBlockReader) -> [IndexedStyle] {
        
        /* Check if there is a style block */
        guard let styleBlockIdentifier = stackReader.readStyleBlockIdentifier() else {
            return []
        }
        
        /* Load the styles */
        let styleBlock = fileReader.extractStyleBlock(withIdentifier: styleBlockIdentifier)
        let styleBlockReader = StyleBlockReader(data: styleBlock)
        return styleBlockReader.readStyles()
    }
    
    private static func loadFonts(fileReader: StackReader, stackReader: StackBlockReader) -> [FontNameReference] {
        
        /* Check if there is a font block */
        guard let fontBlockIdentifier = stackReader.readFontBlockIdentifier() else {
            return []
        }
        
        /* Load the styles */
        let fontBlock = fileReader.extractFontBlock(withIdentifier: fontBlockIdentifier)
        let fontBlockReader = FontBlockReader(data: fontBlock)
        return fontBlockReader.readFontReferences()
    }
    
    private static func listCards(fileReader: StackReader, stackReader: StackBlockReader, version: FileVersion, loadBitmap: @escaping (Int) -> MaskedImage, styles: [IndexedStyle], loadBackgrounds: () -> [Background]) -> [Card] {
        
        var cards: [Card] = []
        
        /* Get the pages in the list */
        let listIdentifier = stackReader.readListIdentifier()
        let listBlock = fileReader.extractListBlock(withIdentifier: listIdentifier)
        let listReader = ListBlockReader(data: listBlock, version: version)
        let pageReferences = listReader.readPageReferences()
        
        /* Get some properties of the list that the pages need */
        let cardReferenceSize = listReader.readCardReferenceSize()
        let hashValueCount = listReader.readHashValueCount()
        
        for pageReference in pageReferences {
            
            /* Get the cards in the page */
            let pageBlock = fileReader.extractPageBlock(withIdentifier: pageReference.identifier)
            let pageReader = PageBlockReader(data: pageBlock, version: version, cardCount: pageReference.cardCount, cardReferenceSize: cardReferenceSize, hashValueCount: hashValueCount)
            let cardReferences = pageReader.readCardReferences()
            
            for cardReference in cardReferences {
                
                /* Find the card data */
                let cardBlock = fileReader.extractCardBlock(withIdentifier: cardReference.identifier)
                let cardReader = CardBlockReader(data: cardBlock, version: version)
                
                /* Find the background */
                let backgroundIdentifier = cardReader.readBackgroundIdentifier()
                let backgrounds = loadBackgrounds()
                let background = backgrounds.first(where: { $0.identifier == backgroundIdentifier })!
                
                /* Build the card */
                let card = Card(loadFromData: cardBlock, version : version, cardReference: cardReference, loadBitmap: loadBitmap, styles: styles, background: background)
                cards.append(card)
            }
        }
        
        return cards
    }
    
    private static func listBackgrounds(fileReader: StackReader, stackReader: StackBlockReader, version: FileVersion, loadBitmap: @escaping (Int) -> MaskedImage, styles: [IndexedStyle]) -> [Background] {
        
        var backgrounds: [Background] = []
        
        /* Get the identifier of the first background of the stack */
        let firstBackgroundIdentifier = stackReader.readFirstBackgroundIdentifier()
        
        var currentIdentifier = firstBackgroundIdentifier
        
        repeat {
            
            /* Add the background with the current identifier */
            let backgroundBlock = fileReader.extractBackgroundBlock(withIdentifier: currentIdentifier)
            let background = Background(loadFromData: backgroundBlock, version: version, loadBitmap: loadBitmap, styles: styles)
            backgrounds.append(background)
            
            /* Move to the next identifier */
            let backgroundReader = BackgroundBlockReader(data: backgroundBlock, version: version)
            currentIdentifier = backgroundReader.readNextBackgroundIdentifier()
            
        } while currentIdentifier != firstBackgroundIdentifier
        
        return backgrounds
    }
    
}

private extension DataRange {
    
    func readOptionalUInt32(at offset: Int) -> Int? {
        let value = self.readUInt32(at: offset)
        guard value != 0 else {
            return nil
        }
        return value
    }
    
    func readUserLevel(at offset: Int) -> UserLevel {
        let userLevelIndex = self.readUInt16(at: offset)
        if userLevelIndex == 0 {
            return UserLevel.script
        }
        return UserLevel(rawValue: userLevelIndex)!
    }
    
    func readApplicationVersion(at offset: Int) -> Version? {
        let code = self.readUInt32(at: offset)
        guard code != 0 else {
            return nil
        }
        return Version(code: code)
    }
    
    private static let defaultHyperCardWindowWidth = 512
    private static let defaultHyperCardWindowHeight = 342
    
    /// 2D size of the cards in this stack
    func readHyperCardWindowSize(at offset: Int) -> Size {
        let dataWidth = self.readUInt16(at: offset+2)
        let dataHeight = self.readUInt16(at: offset)
        let width = (dataWidth == 0) ? DataRange.defaultHyperCardWindowWidth : dataWidth
        let height = (dataHeight == 0) ? DataRange.defaultHyperCardWindowHeight : dataHeight
        return Size(width: width, height: height)
    }
    
    func readPoint(at offset: Int) -> Point {
        let y = self.readUInt16(at: offset)
        let x = self.readUInt16(at: offset+2)
        return Point(x: x, y: y)
    }
    
    func readPatterns(at startOffset: Int) -> [Image] {
        var offset = startOffset
        var patterns = [Image]()
        for _ in 0..<40 {
            
            /* Read the pattern */
            let pattern = Image(data: self.sharedData, offset: self.offset + offset, width: 8, height: 8)
            patterns.append(pattern)
            
            /* Move to next pattern */
            offset += 8
        }
        
        return patterns
    }
    
    func readFileVersion(at offset: Int) -> FileVersion {
        let format = self.readUInt32(at: offset)
        switch format {
        case 1...7:
            /* Pre-release */
            return .v1
        case 8:
            return .v1
        case 9:
            /* Pre-release */
            return .v2
        case 10:
            return .v2
        default:
            fatalError()
        }
    }
}
