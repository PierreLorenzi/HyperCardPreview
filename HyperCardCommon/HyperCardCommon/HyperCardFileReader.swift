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
    
    private let masterRecords: [MasterRecord]
    
    private static let listName = NumericName(string: "LIST")!
    private static let pageName = NumericName(string: "PAGE")!
    private static let cardName = NumericName(string: "CARD")!
    private static let backgroundName = NumericName(string: "BKGD")!
    private static let bitmapName = NumericName(string: "BMAP")!
    private static let styleBlockName = NumericName(string: "STBL")!
    private static let fontBlockName = NumericName(string: "FTBL")!
    
    public init(data: DataRange) {
        self.data = data
        self.masterRecords = HyperCardFileReader.readMasterRecords(in: data)
    }
    
    private static func readMasterRecords(in data: DataRange) -> [MasterRecord] {
        
        let stackLength = data.readUInt32(at: 0x0)
        
        /* In the "Stack Templates" stack in 2.4.1, there is a flag in the 2nd higher bit */
        let masterLength = data.readUInt32(at: stackLength) & 0x0FFF_FFFF
        let masterData = DataRange(sharedData: data.sharedData, offset: data.offset + stackLength, length: masterLength)
        
        let masterReader = MasterBlockReader(data: masterData)
        return masterReader.readRecords()
    }
    
    public func extractStackBlock() -> DataRange {
        let stackLength = data.readUInt32(at: 0x0)
        return DataRange(sharedData: self.data.sharedData, offset: self.data.offset, length: stackLength)
    }
    
    public func extractListBlock(withIdentifier identifier: Int) -> DataRange {
        return self.findBlock(name: HyperCardFileReader.listName, identifier: identifier)
    }
    
    private func findBlock(name: NumericName, identifier: Int) -> DataRange {
        
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
        
        fatalError()
        
    }
    
    public func extractPageBlock(withIdentifier identifier: Int) -> DataRange {
        return self.findBlock(name: HyperCardFileReader.pageName, identifier: identifier)
    }
    
    public func extractCardBlock(withIdentifier identifier: Int) -> DataRange {
        return self.findBlock(name: HyperCardFileReader.cardName, identifier: identifier)
    }
    
    public func extractBackgroundBlock(withIdentifier identifier: Int) -> DataRange {
        return self.findBlock(name: HyperCardFileReader.backgroundName, identifier: identifier)
    }
    
    public func extractBitmapBlock(withIdentifier identifier: Int) -> DataRange {
        return self.findBlock(name: HyperCardFileReader.bitmapName, identifier: identifier)
    }
    
    public func extractStyleBlock(withIdentifier identifier: Int) -> DataRange {
        return self.findBlock(name: HyperCardFileReader.styleBlockName, identifier: identifier)
    }
    
    public func extractFontBlock(withIdentifier identifier: Int) -> DataRange {
        return self.findBlock(name: HyperCardFileReader.fontBlockName, identifier: identifier)
    }
    
}
