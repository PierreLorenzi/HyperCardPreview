//
//  HdmxTableReader.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 02/09/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


/// Header of an hdmx table, mapping the records
public struct HdmxTableHeader {
    
    /// format version number
    var formatVersionNumber: Int    = 0
    
    /// number of device records
    var recordCount: Int            = 0
    
    /// size of a device record, long aligned
    var recordSize: Int             = 0
}

/// Record of an hdmx table, containing integer widths for a specific font size
public struct HdmxTableRecord {
    
    /// pixel size for following widths
    var fontSize: Int               = 0
    
    /// maximum width
    var maximumWidth: Int           = 0
    
    /// widths[number of glyphs]
    var widths: [Int]               = []
}

/// Reads a True-Type hdmx table, which contains integer widths for specific sizes. This table
/// is not read by Mac OS X so we have to do it by hand. Hdmx means horizontal device metrics
/// table.
public class HdmxTableReader {
    
    private static let headerLength = 8
    
    /// Reads the table header in a data containing the whole table
    public static func readHeader(inData data: Data) -> HdmxTableHeader {
        
        var header = HdmxTableHeader()
        
        header.formatVersionNumber = data.readUInt16(at: 0x0)
        header.recordCount = data.readUInt16(at: 0x2)
        header.recordSize = data.readUInt32(at: 0x4)
        
        return header
    }
    
    public static func listFontSizes(recordCount: Int, recordSize: Int, inData data: Data) -> [Int] {
        
        var fontSizes: [Int] = []
        
        for i in 0..<recordCount {
            let offset = headerLength + recordSize * i
            let fontSize = data.readUInt8(at: offset)
            fontSizes.append(fontSize)
        }
        
        return fontSizes
    }
    
    public static func readRecord(atIndex index: Int, size: Int, inData data: Data) -> HdmxTableRecord {
        
        /* Compute the location of the record in the data */
        let recordOffset = headerLength + size * index
        
        var record = HdmxTableRecord()
        
        record.fontSize = data.readUInt8(at: recordOffset + 0x0)
        record.maximumWidth = data.readUInt8(at: recordOffset + 0x1)
        
        for offset in 2..<size {
            let width = data.readUInt8(at: recordOffset + offset)
            record.widths.append(width)
        }
        
        return record
    }
    
}

