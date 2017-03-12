//
//  ResourceFork.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 13/02/2016.
//  Copyright © 2016 Pierre Lorenzi. All rights reserved.
//

import Foundation


public class ResourceFork: DataBlock {
    
    public var dataOffset: Int {
        return data.readUInt32(at: 0x0)
    }
    
    public var mapOffset: Int {
        return data.readUInt32(at: 0x4)
    }
    
    public var dataLength: Int {
        return data.readUInt32(at: 0x8)
    }
    
    public var mapLength: Int {
        return data.readUInt32(at: 0xC)
    }
    
    public var resourceMap: ResourceMap {
        let dataRange = DataRange(sharedData: data.sharedData, offset: data.offset + self.mapOffset, length: self.mapLength)
        return ResourceMap(data: dataRange)
    }
    
    public var icons: [IconResourceBlock] {
        return self.listResources(withType: IconResourceBlock.self)
    }
    
    public var fontFamilies: [FontFamilyResourceBlock] {
        return self.listResources(withType: FontFamilyResourceBlock.self)
    }
    
    public var bitmapFonts: [BitmapFontResourceBlock] {
        return self.listResources(withType: BitmapFontResourceBlock.self)
    }
    
    public var vectorFonts: [VectorFontResourceBlock] {
        return self.listResources(withType: VectorFontResourceBlock.self)
    }
    
    private lazy var references: [ResourceReference] = {
        [unowned self] in
        return self.resourceMap.references
    }()
    
    public func listResources<T: ResourceBlock>(withType type: T.Type) -> [T] {
        
        var resources = [T]()
        
        /* Get the references for that type */
        let references = self.references.filter({$0.type == T.Name})
        
        /* Build the resource objets */
        for reference in references {
            
            /* Read the size of the data block */
            let offset = self.dataOffset + reference.dataOffset
            let length = data.readUInt32(at: offset)
            
            /* Create the resource */
            let dataRange = DataRange(sharedData: self.data.sharedData, offset: self.data.offset + offset + 4, length: length)
            let resource = T(data: dataRange, identifier: reference.identifier, name: reference.name)
            
            resources.append(resource)
        }
        
        return resources
    }
    
}

public class ResourceMap: DataBlock {
    
    private static let HeaderLength = 30
    private static let TypeLength = 8
    private static let ReferenceLength = 12
    
    public var nameListOffset: Int {
        return data.readUInt16(at: 0x1A)
    }
    
    public var typeCount: Int {
        let countMinusOne = data.readSInt16(at: 0x1C)
        return countMinusOne + 1
    }
    
    public var references: [ResourceReference] {
        
        /* Define the list to return */
        var references = [ResourceReference]()
        
        /* Define the offset in the type list */
        var typeOffset = ResourceMap.HeaderLength
        
        /* Loop on the types */
        for _ in 0..<self.typeCount {
            
            /* Read the type */
            let type = data.readUInt32(at: typeOffset)
            let referenceCountMinusOne = data.readUInt16(at: typeOffset+0x4)
            let referenceListOffset = data.readUInt16(at: typeOffset+0x6)
            
            /* Define the offset in the reference list, to read the references for this type */
            var referenceOffset = referenceListOffset + ResourceMap.HeaderLength - 2
            
            /* Read the references */
            for _ in 0...referenceCountMinusOne {
                
                /* Read the reference */
                let identifier = data.readSInt16(at: referenceOffset)
                let nameOffsetInList = data.readSInt16(at: referenceOffset + 0x2)
                let dataOffsetWithFlags = data.readUInt32(at: referenceOffset + 0x4)
                let dataOffset = dataOffsetWithFlags & 0xFF_FFFF
                
                /* Read the name */
                let name = (nameOffsetInList == -1) ? "" : self.readName(nameListOffset: self.nameListOffset, nameOffsetInList: nameOffsetInList)
                
                /* Build the reference */
                let reference = ResourceReference(type: NumericName(value: type), identifier: identifier, name: name, dataOffset: dataOffset)
                references.append(reference)
                
                /* Increment */
                referenceOffset += ResourceMap.ReferenceLength
                
            }
            
            /* Increment the type */
            typeOffset += ResourceMap.TypeLength
            
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

public struct ResourceReference {
    public var type: NumericName
    public var identifier: Int
    public var name: HString
    public var dataOffset: Int
}
