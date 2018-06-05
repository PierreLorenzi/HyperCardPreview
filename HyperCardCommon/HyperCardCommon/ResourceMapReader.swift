//
//  ResourceMapReader.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 05/06/2018.
//  Copyright © 2018 Pierre Lorenzi. All rights reserved.
//


public struct ResourceMapReader {
    
    private let data: DataRange
    
    private static let headerLength = 30
    private static let typeLength = 8
    private static let referenceLength = 12
    
    public init(data: DataRange) {
        self.data = data
    }
    
    /// Offset from beginning of resource map to resource name list
    public func readNameListOffset() -> Int {
        return data.readUInt16(at: 0x1A)
    }
    
    /// Number of resource types in the map
    public func readTypeCount() -> Int {
        let countMinusOne = data.readSInt16(at: 0x1C)
        return countMinusOne + 1
    }
    
    /// The resource records in the map
    public func readReferences() -> [ResourceReference] {
        
        /* Define the list to return */
        var references = [ResourceReference]()
        
        /* Define the offset in the type list */
        var typeOffset = ResourceMapReader.headerLength
        
        let typeCount = self.readTypeCount()
        let nameListOffset = self.readNameListOffset()
        
        /* Loop on the types */
        for _ in 0..<typeCount {
            
            /* Read the type */
            let type = data.readUInt32(at: typeOffset)
            let referenceCountMinusOne = data.readUInt16(at: typeOffset+0x4)
            let referenceListOffset = data.readUInt16(at: typeOffset+0x6)
            
            /* Define the offset in the reference list, to read the references for this type */
            var referenceOffset = referenceListOffset + ResourceMapReader.headerLength - 2
            
            /* Read the references */
            for _ in 0...referenceCountMinusOne {
                
                /* Read the reference */
                let identifier = data.readSInt16(at: referenceOffset)
                let nameOffsetInList = data.readSInt16(at: referenceOffset + 0x2)
                let dataOffsetWithFlags = data.readUInt32(at: referenceOffset + 0x4)
                let dataOffset = dataOffsetWithFlags & 0xFF_FFFF
                
                /* Read the name */
                let name = (nameOffsetInList == -1) ? "" : self.readName(nameListOffset: nameListOffset, nameOffsetInList: nameOffsetInList)
                
                /* Build the reference */
                let reference = ResourceReference(type: NumericName(value: type), identifier: identifier, name: name, dataOffset: dataOffset)
                references.append(reference)
                
                /* Increment */
                referenceOffset += ResourceMapReader.referenceLength
                
            }
            
            /* Increment the type */
            typeOffset += ResourceMapReader.typeLength
            
        }
        
        return references
    }
    
    private func readName(nameListOffset: Int, nameOffsetInList: Int) -> HString {
        
        /* Locate the name */
        let offset = nameListOffset + nameOffsetInList
        
        /* Read the length */
        let length = data.readUInt8(at: offset)
        
        /* Read the string */
        return data.readString(at: offset+1, length: length)
        
    }
}


