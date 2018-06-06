//
//  HyperCardFileReader.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 03/06/2018.
//  Copyright © 2018 Pierre Lorenzi. All rights reserved.
//

/// The parsed data blocks in a stack file
public struct HyperCardFileReader {
    
    private let data: DataRange
    
    private let version: FileVersion
    
    private let stackReader: StackBlockReader
    
    private let masterRecords: [MasterRecord]
    
    private let listReader: ListBlockReader
    
    private static let listName = NumericName(string: "LIST")!
    private static let pageName = NumericName(string: "PAGE")!
    private static let cardName = NumericName(string: "CARD")!
    private static let backgroundName = NumericName(string: "BKGD")!
    private static let bitmapName = NumericName(string: "BMAP")!
    private static let styleBlockName = NumericName(string: "STBL")!
    private static let fontBlockName = NumericName(string: "FTBL")!
    
    public init(data: DataRange, password possiblePassword: HString? = nil, hackEncryption: Bool = true) throws {
        let stackReader = try HyperCardFileReader.extractStackReader(in: data, password: possiblePassword, hackEncryption: hackEncryption)
        let masterRecords = HyperCardFileReader.readMasterRecords(in: data)
        let version = stackReader.readVersion()
        
        self.data = data
        self.version = version
        self.stackReader = stackReader
        self.masterRecords = masterRecords
        self.listReader = HyperCardFileReader.extractListReader(in: data, stackReader: stackReader, masterRecords: masterRecords, version: version)
    }
    
    private static func extractStackReader(in data: DataRange, password possiblePassword: HString? = nil, hackEncryption: Bool = true) throws -> StackBlockReader {
        
        let stackLength = data.readUInt32(at: 0x0)
        let stackData = DataRange(sharedData: data.sharedData, offset: data.offset, length: stackLength)
        return try StackBlockReader(data: stackData, password: possiblePassword, hackEncryption: hackEncryption)
    }
    
    private static func readMasterRecords(in data: DataRange) -> [MasterRecord] {
        
        let stackLength = data.readUInt32(at: 0x0)
        
        /* In the "Stack Templates" stack in 2.4.1, there is a flag in the 2nd higher bit */
        let masterLength = data.readUInt32(at: stackLength) & 0x0FFF_FFFF
        let masterData = DataRange(sharedData: data.sharedData, offset: data.offset + stackLength, length: masterLength)
        
        let masterReader = MasterBlockReader(data: masterData)
        return masterReader.readRecords()
    }
    
    private static func extractListReader(in data: DataRange, stackReader: StackBlockReader, masterRecords: [MasterRecord], version: FileVersion) -> ListBlockReader {
        
        let identifier = stackReader.readListIdentifier()
        let listData = HyperCardFileReader.findBlock(name: HyperCardFileReader.listName, identifier: identifier, in: data, masterRecords: masterRecords)!
        return ListBlockReader(data: listData, version: version)
    }
    
    private static func findBlock(name: NumericName, identifier: Int, in data: DataRange, masterRecords: [MasterRecord]) -> DataRange? {
        
        let identifierLastByte = identifier & 0xFF
        
        /* Find a corresponding entry */
        for record in masterRecords {
            
            /* Ignore invalid entries */
            guard record.offset > 0 && record.offset < data.length else {
                continue
            }
            
            /* Check the identifier */
            guard record.identifierLastByte == identifierLastByte else {
                continue
            }
            
            /* Check the full name */
            let recordName = data.readUInt32(at: record.offset + 4)
            guard recordName == name.value else {
                continue
            }
            
            /* Check the full identifier */
            let recordIdentifier = data.readUInt32(at: record.offset + 8)
            guard recordIdentifier == identifier else {
                continue
            }
            
            /* Return the data range pointed by the record */
            let recordLength = data.readUInt32(at: record.offset)
            return DataRange(sharedData: data.sharedData, offset: data.offset + record.offset, length: recordLength)
        }
        
        return nil
        
    }
    
    public func extractStackReader() -> StackBlockReader {
        return self.stackReader
    }
    
    public func extractListReader() -> ListBlockReader {
        return self.listReader
    }
    
    public func extractPageReader(from reference: PageReference) -> PageBlockReader {
        
        let blockData = self.findBlock(name: HyperCardFileReader.pageName, identifier: reference.identifier)!
        let cardReferenceSize = listReader.readCardReferenceSize()
        let hashValueCount = listReader.readHashValueCount()
        return PageBlockReader(data: blockData, version: self.version, cardCount: reference.cardCount, cardReferenceSize: cardReferenceSize, hashValueCount: hashValueCount)
    }
    
    private func findBlock(name: NumericName, identifier: Int) -> DataRange? {
        
        return HyperCardFileReader.findBlock(name: name, identifier: identifier, in: self.data, masterRecords: self.masterRecords)
    }
    
    public func extractCardReader(withIdentifier identifier: Int) -> CardBlockReader {
        
        let blockData = self.findBlock(name: HyperCardFileReader.cardName, identifier: identifier)!
        return CardBlockReader(data: blockData, version: self.version)
    }
    
    public func extractBackgroundReader(withIdentifier identifier: Int) -> BackgroundBlockReader {
        
        let blockData = self.findBlock(name: HyperCardFileReader.backgroundName, identifier: identifier)!
        return BackgroundBlockReader(data: blockData, version: self.version)
    }
    
    public func extractBitmapReader(withIdentifier identifier: Int) -> BitmapBlockReader {
        
        let blockData = self.findBlock(name: HyperCardFileReader.bitmapName, identifier: identifier)!
        return BitmapBlockReader(data: blockData, version: self.version)
    }
    
    public func extractStyleBlockReader() -> StyleBlockReader? {
        
        guard let identifier = self.stackReader.readStyleBlockIdentifier() else {
            return nil
        }
        let blockData = self.findBlock(name: HyperCardFileReader.styleBlockName, identifier: identifier)!
        return StyleBlockReader(data: blockData)
    }
    
    public func extractFontBlockReader() -> FontBlockReader? {
        
        guard let identifier = self.stackReader.readFontBlockIdentifier() else {
            return nil
        }
        let blockData = self.findBlock(name: HyperCardFileReader.fontBlockName, identifier: identifier)!
        return FontBlockReader(data: blockData)
    }
    
}
