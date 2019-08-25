//
//  FileResourceRepository.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 05/06/2018.
//  Copyright © 2018 Pierre Lorenzi. All rights reserved.
//


public extension ResourceRepository {
    
    private static let iconTypeName = NumericName(string: "ICON")!
    private static let fontFamilyTypeName = NumericName(string: "FOND")!
    private static let bitmapFontTypeName = NumericName(string: "NFNT")!
    private static let bitmapFontOldTypeName = NumericName(string: "FONT")!
    private static let vectorFontTypeName = NumericName(string: "sfnt")!
    private static let cardColorTypeName = NumericName(string: "HCcd")!
    private static let backgroundColorTypeName = NumericName(string: "HCbg")!
    private static let pictureTypeName = NumericName(string: "PICT")!
    
    private static let mapHeaderLength = 30
    private static let mapTypeLength = 8
    private static let mapReferenceLength = 12
    
    /// Loads a resource repository from the content of a resource fork
    init(loadFromData resourceData: Data) {
        
        let data = DataRange(wholeData: resourceData)
        
        /* Extract the resource map */
        let mapOffset = data.readUInt32(at: 0x4)
        let mapLength = data.readUInt32(at: 0xC)
        let mapData = DataRange(fromData: data, offset: mapOffset, length: mapLength)
        
        /* List the resource references */
        let references = ResourceRepository.readReferences(in: mapData)
        
        /* Load the offset of the resource data table */
        let globalDataOffset = data.readUInt32(at: 0x0)
        
        /* List the icons */
        let icons = ResourceRepository.listResources(references: references, data: data, globalDataOffset: globalDataOffset, withType: IconResourceType.self, typeName: ResourceRepository.iconTypeName, parse: { (data: DataRange) -> Icon in
            return Icon(loadFromData: data)
        })
        
        /* List the bitmap fonts */
        let bitmapFontsNew = ResourceRepository.listResources(references: references, data: data, globalDataOffset: globalDataOffset, withType: BitmapFontResourceType.self, typeName: ResourceRepository.bitmapFontTypeName, parse: { (data: DataRange) -> BitmapFont in
            return BitmapFont(loadFromData: data)
        })
        
        /* List the bitmap fonts from old format */
        let bitmapFontsOld = ResourceRepository.listResources(references: references, data: data, globalDataOffset: globalDataOffset, withType: BitmapFontResourceType.self, typeName: ResourceRepository.bitmapFontOldTypeName, parse: { (data: DataRange) -> BitmapFont in
            return BitmapFont(loadFromData: data)
        })
        
        /* List all the bitmap fonts */
        let bitmapFonts: [BitmapFontResource] = bitmapFontsNew + bitmapFontsOld
        
        /* List the vector fonts */
        let vectorFonts = ResourceRepository.listResources(references: references, data: data, globalDataOffset: globalDataOffset, withType: VectorFontResourceType.self, typeName: ResourceRepository.vectorFontTypeName, parse: { (data: DataRange) -> VectorFont in
            return VectorFont(loadFromData: data)
        })
        
        /* List the font familes */
        let fontFamilies = ResourceRepository.listResources(references: references, data: data, globalDataOffset: globalDataOffset, withType: FontFamilyResourceType.self, typeName: ResourceRepository.fontFamilyTypeName, parse: { (data: DataRange) -> FontFamily in
            return FontFamily(loadFromData: data, bitmapFonts: bitmapFonts, vectorFonts: vectorFonts)
        })
        
        /* List the card colors */
        let cardColors = ResourceRepository.listResources(references: references, data: data, globalDataOffset: globalDataOffset, withType: CardColorResourceType.self, typeName: ResourceRepository.cardColorTypeName, parse: { (data: DataRange) -> LayerColor in
            return LayerColor(loadFromData: data)
        })
        
        /* List the background colors */
        let backgroundColors = ResourceRepository.listResources(references: references, data: data, globalDataOffset: globalDataOffset, withType: BackgroundColorResourceType.self, typeName: ResourceRepository.backgroundColorTypeName, parse: { (data: DataRange) -> LayerColor in
            return LayerColor(loadFromData: data)
        })
        
        /* List the background colors */
        let pictures = ResourceRepository.listResources(references: references, data: data, globalDataOffset: globalDataOffset, withType: PictureResourceType.self, typeName: ResourceRepository.pictureTypeName, parse: { (data: DataRange) -> Picture in
            return Picture(loadFromData: data)
        })
        
        /* Init */
        self.init(icons: icons, fontFamilies: fontFamilies, cardColors: cardColors, backgroundColors: backgroundColors, pictures: pictures)
    }
    
    private static func readReferences(in data: DataRange) -> [ResourceReference] {
        
        /* Define the list to return */
        var references = [ResourceReference]()
        
        /* Define the offset in the type list */
        var typeOffset = ResourceRepository.mapHeaderLength
        
        let typeCount = 1 + data.readSInt16(at: 0x1C)
        let nameListOffset = data.readUInt16(at: 0x1A)
        
        /* Loop on the types */
        for _ in 0..<typeCount {
            
            /* Read the type */
            let type = data.readUInt32(at: typeOffset)
            let referenceCountMinusOne = data.readUInt16(at: typeOffset+0x4)
            let referenceListOffset = data.readUInt16(at: typeOffset+0x6)
            
            /* Define the offset in the reference list, to read the references for this type */
            var referenceOffset = referenceListOffset + ResourceRepository.mapHeaderLength - 2
            
            /* Read the references */
            for _ in 0...referenceCountMinusOne {
                
                /* Read the reference */
                let identifier = data.readSInt16(at: referenceOffset)
                let nameOffsetInList = data.readSInt16(at: referenceOffset + 0x2)
                let dataOffsetWithFlags = data.readUInt32(at: referenceOffset + 0x4)
                let dataOffset = dataOffsetWithFlags & 0xFF_FFFF
                
                /* Read the name */
                let name = (nameOffsetInList == -1) ? "" : readName(data: data, nameListOffset: nameListOffset, nameOffsetInList: nameOffsetInList)
                
                /* Build the reference */
                let reference = ResourceReference(type: NumericName(value: type), identifier: identifier, name: name, dataOffset: dataOffset)
                references.append(reference)
                
                /* Increment */
                referenceOffset += ResourceRepository.mapReferenceLength
                
            }
            
            /* Increment the type */
            typeOffset += ResourceRepository.mapTypeLength
            
        }
        
        return references
    }
    
    private static func readName(data: DataRange, nameListOffset: Int, nameOffsetInList: Int) -> HString {
        
        /* Locate the name */
        let offset = nameListOffset + nameOffsetInList
        
        /* Read the length */
        let length = data.readUInt8(at: offset)
        
        /* Read the string */
        return data.readString(at: offset+1, length: length)
        
    }
    
    private static func listResources<T: ResourceType>(references: [ResourceReference], data: DataRange, globalDataOffset: Int, withType type: T.Type, typeName: NumericName, parse: @escaping (DataRange) -> T.ContentType) -> [Resource<T>] {
        
        let typeReferences = references.filter({ $0.type == typeName })
        
        return typeReferences.map({ (reference: ResourceReference) -> Resource<T> in
            
            let resourceData = extractResourceData(at: reference.dataOffset, globalDataOffset: globalDataOffset, data: data)
            let contentProperty = Property<T.ContentType>(lazy: { () -> T.ContentType in
                return parse(resourceData)
            })
            return Resource<T>(identifier: reference.identifier, name: reference.name, contentProperty: contentProperty)
        })
    }
    
    private static func extractResourceData(at dataOffset: Int, globalDataOffset: Int, data: DataRange) -> DataRange {
        
        let offset = dataOffset + globalDataOffset
        let length = data.readUInt32(at: offset)
        return DataRange(fromData: data, offset: offset + 4, length: length)
    }
    
}

