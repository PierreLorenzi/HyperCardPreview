//
//  HyperCardFileLayer.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 26/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//




public extension Card {
    
    convenience init(loadFromData data: DataRange, version: FileVersion, marked: Bool, loadBitmap: @escaping (Int) -> MaskedImage, styles: [IndexedStyle], background: Background) {
        
        self.init(background: background)
        
        /* Load the layer properties */
        super.adjustFromData(data, layerType: LayerType.card, version: version, styles: styles, loadBitmap: loadBitmap)
        
        /* Load the card properties */
        self.marked = marked
        
        /* Lazy load the background contents */
        self.backgroundPartContentsProperty.lazyCompute { () -> [Card.BackgroundPartContent] in
            
            return Layer.loadBackgroundPartContents(in: data, fileVersion: version, styles: styles)
        }
    }
}

public extension Background {
    
    convenience init(loadFromData data: DataRange, version: FileVersion, loadBitmap: @escaping (Int) -> MaskedImage, styles: [IndexedStyle]) {
        
        self.init()
        
        /* Load the layer properties */
        super.adjustFromData(data, layerType: LayerType.background, version: version, styles: styles, loadBitmap: loadBitmap)
    }
}

private extension Layer {
    
    func adjustFromData(_ data: DataRange, layerType: LayerType, version: FileVersion, styles: [IndexedStyle], loadBitmap: @escaping (Int) -> MaskedImage) {
        
        let block = Layer.buildLayerBlock(for: data, layerType: layerType, fileVersion: version)
        
        /* Read now the scalar fields */
        self.identifier = data.readUInt32(at: 0x8)
        self.cantDelete = data.readFlag(at: 0x14 + block.versionShift, bitOffset: 14)
        self.showPict = !data.readFlag(at: 0x14 + block.versionShift, bitOffset: 13)
        self.dontSearch =  data.readFlag(at: 0x14 + block.versionShift, bitOffset: 11)
        self.nextAvailablePartIdentifier = data.readUInt16(at: block.partOffset - 0xC)
        
        /* Lazy load name */
        self.nameProperty.lazyCompute { () -> HString in
            
            return Layer.loadName(in: block)
        }
        
        /* Lazy load image */
        self.imageProperty.lazyCompute {
            
            /* Get the identifier of the bitmap in the file */
            let bitmapIdentifier = data.readUInt32(at: 0x10 + block.versionShift)
            guard bitmapIdentifier != 0 else {
                return nil
            }
            
            return loadBitmap(bitmapIdentifier)
        }
        
        /* Lazy load parts */
        self.partsProperty.lazyCompute { () -> [LayerPart] in
            
            return Layer.loadParts(in: block, styles: styles)
        }
        
        /* Lazy load script */
        self.scriptProperty.lazyCompute { () -> HString in
            
            return Layer.loadScript(in: block)
        }
    }
    
    private struct LayerBlock {
        
        var data: DataRange
        var layerType: LayerType
        var fileVersion: FileVersion
        
        var versionShift: Int
        
        var partOffset: Int
        var contentOffset: Int
        var nameOffset: Int
    }
    
    private static func buildLayerBlock(for data: DataRange, layerType: LayerType, fileVersion: FileVersion) -> LayerBlock {
        
        let versionShift = getVersionShift(of: fileVersion)
        let partOffset = (layerType == LayerType.card ? 0x36 : 0x32) + versionShift
        
        let partSize = data.readUInt32(at: partOffset - 0xA)
        let contentOffset = partOffset + partSize
        
        let contentSize = data.readUInt32(at: partOffset - 0x4)
        let nameOffset = contentOffset + contentSize
        
        return LayerBlock(data: data, layerType: layerType, fileVersion: fileVersion, versionShift: versionShift, partOffset: partOffset, contentOffset: contentOffset, nameOffset: nameOffset)
    }
    
    private static func getVersionShift(of fileVersion: FileVersion) -> Int {
        
        switch fileVersion {
            
        case .v1:
            return -4
            
        case .v2:
            return 0
        }
    }
    
    private static func loadName(in block: LayerBlock) -> HString {
        
        let offset = block.nameOffset
        
        return block.data.readString(at: offset)
    }
    
    private static func loadScript(in block: LayerBlock) -> HString {
        
        var offset = block.nameOffset
        
        /* Look for the final null of the name */
        while block.data.readUInt8(at: offset) != 0 {
            
            offset += 1
        }
        
        offset += 1
        
        return block.data.readString(at: offset)
    }
    
    private static func loadParts(in block: LayerBlock, styles: [IndexedStyle]) -> [LayerPart] {
        
        var parts = [LayerPart]()
        
        /* Load the part blocks */
        let partBlocks = extractPartBlocks(in: block)
        
        /* Load the content blocks */
        let contentBlocks = extractContentBlocks(in: block)
        let layerContentBlocks = contentBlocks.lazy.filter({ readContentLayerType(in: $0) == block.layerType })
        let contentPairs = layerContentBlocks.map({ (readContentIdentifier(in: $0), $0) })
        let contentMap = [Int: DataRange](uniqueKeysWithValues: contentPairs)
        
        /* Convert them to parts */
        for partBlock in partBlocks {
            
            /* Read the part type */
            let partType = partBlock.readPartType(at: 0x4, bitOffset: 8)
            let partIdentifier = partBlock.readUInt16(at: 0x2)
            
            /* Check if the part is a field or a button */
            switch partType {
                
            case .button:
                
                let loadContent = { () -> HString in
                    
                    guard let contentBlock = contentMap[partIdentifier] else {
                        return ""
                    }
                    
                    return readContentString(in: contentBlock, fileVersion: block.fileVersion)
                }
                
                let button = Button(loadFromData: partBlock, loadContent: loadContent)
                parts.append(LayerPart.button(button))
                
            case .field:
                
                let loadContent = { () -> PartContent in
                    
                    guard let contentBlock = contentMap[partIdentifier] else {
                        return PartContent.string("")
                    }
                    
                    return readContent(in: contentBlock, fileVersion: block.fileVersion, styles: styles)
                }
                
                let field = Field(loadFromData: partBlock, loadContent: loadContent)
                parts.append(LayerPart.field(field))
            }
            
        }
        
        return parts
    }
    
    private static func extractPartBlocks(in block: LayerBlock) -> [DataRange] {
        
        var parts = [DataRange]()
        var offset = block.partOffset
        let partCount = block.data.readUInt16(at: block.partOffset - 0xE)
        
        /* Read the parts */
        for _ in 0..<partCount {
            
            /* Read the size of the part block */
            let size = block.data.readUInt16(at: offset)
            
            /* Build the part block */
            let dataRange = DataRange(fromData: block.data, offset: offset, length: size)
            parts.append(dataRange)
            
            /* Move to the next part data */
            offset += size
        }
        
        return parts
    }
    
    private static func extractContentBlocks(in block: LayerBlock) -> [DataRange] {
        
        let contentCount = block.data.readUInt16(at: block.partOffset - 0x6)
        
        switch block.fileVersion {
            
        case .v1:
            return extractContentBlocksV1(in: block, contentCount: contentCount)
            
        case .v2:
            return extractContentBlocksV2(in: block, contentCount: contentCount)
        }
    }
    
    private static func extractContentBlocksV2(in block: LayerBlock, contentCount: Int) -> [DataRange] {
        
        var contents = [DataRange]()
        
        var offset = block.contentOffset
        
        for _ in 0..<contentCount {
            
            /* Read the identifier and size */
            let size = block.data.readUInt16(at: offset + 2)
            
            /* Build the content block */
            let dataRange = DataRange(fromData: block.data, offset: offset, length: size + 4)
            contents.append(dataRange)
            
            /* Skip the content */
            offset += size + 4
            /* Round to 32 bits */
            offset = upToMultiple(offset, 2)
        }
        
        return contents
    }
    
    /* The contents are all unformatted strings */
    private static func extractContentBlocksV1(in block: LayerBlock, contentCount: Int) -> [DataRange] {
        
        var contents = [DataRange]()
        
        var offset = block.contentOffset
        
        for _ in 0..<contentCount {
            
            /* Register the offset of the start of the content */
            let contentOffset = offset
            
            /* Skip the content */
            offset += 2
            while block.data.readUInt8(at: offset) != 0 {
                offset += 1
            }
            offset += 1
            
            /* Build the content block */
            let dataRange = DataRange(fromData: block.data, offset: contentOffset, length: offset - contentOffset)
            contents.append(dataRange)
        }
        
        return contents
    }
    
    static func loadBackgroundPartContents(in data: DataRange, fileVersion: FileVersion, styles: [IndexedStyle]) -> [Card.BackgroundPartContent] {
        
        let block = buildLayerBlock(for: data, layerType: LayerType.card, fileVersion: fileVersion)
        let contentBlocks = extractContentBlocks(in: block)
        
        let backgroundBlocks = contentBlocks.lazy.filter({ readContentLayerType(in: $0) == LayerType.background })
        let backgroundContents: [Card.BackgroundPartContent] = backgroundBlocks.map({
            
            let content = readContent(in: $0, fileVersion: fileVersion, styles: styles)
            let partIdentifier = readContentIdentifier(in: $0)
            
            return Card.BackgroundPartContent(partIdentifier: partIdentifier, partContent: content)
        })
        
        return backgroundContents
    }
    
    private static func readContentIdentifier(in data: DataRange) -> Int {
        
        let storedIdentifier = data.readSInt16(at: 0)
        return abs(storedIdentifier)
    }
    
    private static func readContentLayerType(in data: DataRange) -> LayerType {
        
        let storedIdentifier = data.readSInt16(at: 0)
        return (storedIdentifier < 0) ? .card : .background
    }
    
    private static func readContent(in data: DataRange, fileVersion: FileVersion, styles: [IndexedStyle]) -> PartContent {
        
        /* Extract the string */
        let string = readContentString(in: data, fileVersion: fileVersion)
        
        /* Check if it is a raw string */
        guard let formattingChanges = readContentFormattingChanges(in: data, fileVersion: fileVersion) else {
            return PartContent.string(string)
        }
        
        /* Load the attributes */
        var attributes = Array<Text.FormattingAssociation>()
        for formattingChange in formattingChanges {
            let style = styles.first(where: { $0.number == formattingChange.styleIdentifier })!
            let format = style.textAttribute
            let attribute = Text.FormattingAssociation(offset: formattingChange.offset, formatting: format);
            attributes.append(attribute)
        }
        
        let text = Text(string: string, attributes: attributes)
        return PartContent.formattedString(text)
        
    }
    
    private static func readContentString(in data: DataRange, fileVersion: FileVersion) -> HString {
        
        /* Handle version 1 */
        guard fileVersion.isTwo() else {
            return data.readString(at: 2, length: data.length - 3)
        }
        
        /* Check if we're a raw string or a formatted text */
        let plainTextMarker = data.readUInt8(at: 4)
        
        /* Plain text */
        if plainTextMarker == 0 {
            return data.readString(at: 5, length:data.length - 5)
        }
        else {
            let formattingLengthValue = data.readUInt16(at: 4)
            let formattingLength = formattingLengthValue - 0x8000
            let stringOffset = 4 + formattingLength
            return data.readString(at: stringOffset, length:data.length - 4 - formattingLength)
        }
    }
    
    private static func readContentFormattingChanges(in data: DataRange, fileVersion: FileVersion) -> [IndexedTextFormatting]? {
        
        /* Handle version 1 */
        guard fileVersion.isTwo() else {
            return nil
        }
        
        /* Check if we're a raw string or a formatted text */
        let plainTextMarker = data.readUInt8(at: 4)
        guard plainTextMarker != 0 else {
            return nil
        }
        
        /* Plain text */
        var changes: [IndexedTextFormatting] = []
        let formattingLengthValue = data.readUInt16(at: 4)
        let formattingLength = formattingLengthValue ^ 0x8000
        let formattingCount = (formattingLength - 2) / 4
        var offset = 6
        for _ in 0..<formattingCount {
            let changeOffset = data.readUInt16(at: offset)
            let styleIdentifier = data.readUInt16(at: offset + 2)
            changes.append(IndexedTextFormatting(offset: changeOffset, styleIdentifier: styleIdentifier))
            offset += 4
        }
        return changes
    }
}

private extension DataRange {
    
    func readPartType(at offset: Int, bitOffset: Int) -> PartType {
        
        let flagTrue = self.readFlag(at: offset, bitOffset: bitOffset)
        return flagTrue ? PartType.button : PartType.field
    }
}


