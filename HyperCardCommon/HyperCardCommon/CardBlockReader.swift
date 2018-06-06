//
//  CardBlockReader.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 03/06/2018.
//  Copyright © 2018 Pierre Lorenzi. All rights reserved.
//


/// A card block contains the properties of a card
public struct CardBlockReader: LayerBlockReader {
    
    private let data: DataRange
    
    private let versionOffset: Int
    
    private let layerReader: LayerBlockCommonReader
    
    private static let version1Offset = -4
    
    public init(data: DataRange, version: FileVersion) {
        self.data = data
        let versionOffset = version.isTwo() ? 0 : CardBlockReader.version1Offset
        self.versionOffset = versionOffset
        self.layerReader = LayerBlockCommonReader(data: data, version: version, partOffset: 0x36 + versionOffset)
    }
    
    /// Identifier of the page referencing the card
    public func readPageIdentifier() -> Int {
        return data.readUInt32(at: 0x20 + self.versionOffset)
    }
    
    /// Identifier of the background of the card
    public func readBackgroundIdentifier() -> Int {
        return data.readUInt32(at: 0x24 + self.versionOffset)
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
