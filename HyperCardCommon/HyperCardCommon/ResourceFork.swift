//
//  ResourceFork.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 13/02/2016.
//  Copyright © 2016 Pierre Lorenzi. All rights reserved.
//


/// A parsed resource fork
public class ResourceFork: DataBlock {
    
    /// Offset from beginning of resource file to resource data
    public func readDataOffset() -> Int {
        return data.readUInt32(at: 0x0)
    }
    
    /// Offset from beginning of resource file to resource map
    public func readMapOffset() -> Int {
        return data.readUInt32(at: 0x4)
    }
    
    /// Length of resource data
    public func readDataLength() -> Int {
        return data.readUInt32(at: 0x8)
    }
    
    /// Length of resource map
    public func readMapLength() -> Int {
        return data.readUInt32(at: 0xC)
    }
    
    /// The resource map
    public func extractResourceMap() -> ResourceMap {
        let dataRange = DataRange(sharedData: data.sharedData, offset: data.offset + self.readMapOffset(), length: self.readMapLength())
        return ResourceMap(data: dataRange)
    }
    
    /// Quick access to the icon resource blocks
    public func extractIcons() -> [IconResourceBlock] {
        return self.extractResources(withType: IconResourceBlock.self)
    }
    
    /// Quick access to the font family resource blocks
    public func extractFontFamilies() -> [FontFamilyResourceBlock] {
        return self.extractResources(withType: FontFamilyResourceBlock.self)
    }
    
    /// Quick access to the bitmap font resource blocks
    public func extractBitmapFonts() -> [BitmapFontResourceBlock] {
        
        /* Append the 'NFNT' resources */
        var fonts = self.extractResources(withType: BitmapFontResourceBlock.self)
        
        /* Append the 'FONT' resources */
        let oldFonts = self.extractResources(withType: BitmapFontResourceBlockOld.self)
        for oldFont in oldFonts {
            fonts.append(oldFont)
        }
        
        return fonts
    }
    
    /// Quick access to the vector font resource blocks
    public func extractVectorFonts() -> [VectorFontResourceBlock] {
        return self.extractResources(withType: VectorFontResourceBlock.self)
    }
    
    /// Quick access to the AddColor card colors resource blocks
    public func extractCardColors() -> [AddColorResourceBlockCard] {
        return self.extractResources(withType: AddColorResourceBlockCard.self)
    }
    
    /// Quick access to the AddColor background colors resource blocks
    public func extractBackgroundColors() -> [AddColorResourceBlockBackground] {
        return self.extractResources(withType: AddColorResourceBlockBackground.self)
    }
    
    /// Quick access to the picture resource blocks
    public func extractPictures() -> [PictureResourceBlock] {
        return self.extractResources(withType: PictureResourceBlock.self)
    }
    
    private lazy var references: [ResourceReference] = {
        [unowned self] in
        return self.extractResourceMap().readReferences()
    }()
    
    /// Lists the resource blocks for a certain type
    public func extractResources<T: ResourceBlock>(withType type: T.Type) -> [T] {
        
        var resources = [T]()
        
        /* Get the references for that type */
        let references = self.references.filter({$0.type == T.Name})
        
        let dataOffset = self.readDataOffset()
        
        /* Build the resource objets */
        for reference in references {
            
            /* Read the size of the data block */
            let offset = dataOffset + reference.dataOffset
            let length = data.readUInt32(at: offset)
            
            /* Create the resource */
            let dataRange = DataRange(sharedData: self.data.sharedData, offset: self.data.offset + offset + 4, length: length)
            let resource = T(data: dataRange, identifier: reference.identifier, name: reference.name)
            
            resources.append(resource)
        }
        
        return resources
    }
    
}

/// A resource map of a resource fork, listing the resources present in the fork
public class ResourceMap: DataBlock {
    
    private static let HeaderLength = 30
    private static let TypeLength = 8
    private static let ReferenceLength = 12
    
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
        var typeOffset = ResourceMap.HeaderLength
        
        let typeCount = self.readTypeCount()
        let nameListOffset = self.readNameListOffset()
        
        /* Loop on the types */
        for _ in 0..<typeCount {
            
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
                let name = (nameOffsetInList == -1) ? "" : self.readName(nameListOffset: nameListOffset, nameOffsetInList: nameOffsetInList)
                
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

/// A resource record in the map
public struct ResourceReference {
    
    /// Type of the resource
    public var type: NumericName
    
    /// ID of the resource
    public var identifier: Int
    
    /// Name of the resource
    public var name: HString
    
    /// Offset of the resource in the data section of the resource fork
    public var dataOffset: Int
}
