//
//  BackgroundBlockReader.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 03/06/2018.
//  Copyright © 2018 Pierre Lorenzi. All rights reserved.
//


/// A background block contains the properties of a background
public struct BackgroundBlockReader: LayerBlockReader {
    
    private let data: DataRange
    
    private let versionOffset: Int
    
    private let layerReader: LayerBlockCommonReader
    
    private static let version1Offset = -4
    
    public init(data: DataRange, version: FileVersion) {
        self.data = data
        let versionOffset = version.isTwo() ? 0 : BackgroundBlockReader.version1Offset
        self.versionOffset = versionOffset
        self.layerReader = LayerBlockCommonReader(data: data, version: version, partOffset: 0x32 + versionOffset)
    }
    
    /// Number of cards in the background
    public func readCardCount() -> Int {
        return data.readUInt32(at: 0x18 + self.versionOffset)
    }
    
    /// ID of next background
    public func readNextBackgroundIdentifier() -> Int {
        return data.readSInt32(at: 0x1C + self.versionOffset)
    }
    
    /// ID of previous background
    public func readPreviousBackgroundIdentifier() -> Int {
        return data.readSInt32(at: 0x20 + self.versionOffset)
    }
    
    public func readIdentifier() -> Int {
        return layerReader.readIdentifier()
    }
    
    public func readBitmapIdentifier() -> Int? {
        return layerReader.readBitmapIdentifier()
    }
    
    public func readCantDelete() -> Bool {
        return layerReader.readCantDelete()
    }
    
    public func readShowPict() -> Bool {
        return layerReader.readShowPict()
    }
    
    public func readDontSearch() -> Bool {
        return layerReader.readDontSearch()
    }
    
    public func readPartCount() -> Int {
        return layerReader.readPartCount()
    }
    
    public func readNextAvailableIdentifier() -> Int {
        return layerReader.readNextAvailableIdentifier()
    }
    
    public func readPartSize() -> Int {
        return layerReader.readPartSize()
    }
    
    public func readContentCount() -> Int {
        return layerReader.readContentCount()
    }
    
    public func readContentSize() -> Int {
        return layerReader.readContentSize()
    }
    
    public func extractPartBlocks() -> [DataRange] {
        return layerReader.extractPartBlocks()
    }
    
    public func extractContentBlocks() -> [DataRange] {
        return layerReader.extractContentBlocks()
    }
    
    public func readName() -> HString {
        return layerReader.readName()
    }
    
    public func readScript() -> HString {
        return layerReader.readScript()
    }
    
}
