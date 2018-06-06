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
    
    /// Makes a list of the resources by reading in a resource fork data
    public init(fromResourceFork resourceData: Data) {
        
        /* Build a resource extractor */
        let dataRange = DataRange(sharedData: resourceData, offset: 0, length: resourceData.count)
        let forkReader = ResourceForkReader(data: dataRange)
        let extractor = ResourceExtractor(resourceForkReader: forkReader)
        
        /* List the icons */
        let icons = extractor.listResources(withType: IconResourceType.self, typeName: ResourceRepository.iconTypeName, parse: { (data: DataRange) -> Icon in
            let reader = IconResourceReader(data: data)
            return Icon(image: reader.readImage())
            })
        
        /* List the bitmap fonts */
        let bitmapFontsNew = extractor.listResources(withType: BitmapFontResourceType.self, typeName: ResourceRepository.bitmapFontTypeName, parse: { (data: DataRange) -> BitmapFont in
            let reader = BitmapFontResourceReader(data: data)
            return BitmapFont(reader: reader)
        })
        
        /* List the bitmap fonts from old format */
        let bitmapFontsOld = extractor.listResources(withType: BitmapFontResourceType.self, typeName: ResourceRepository.bitmapFontOldTypeName, parse: { (data: DataRange) -> BitmapFont in
            let reader = BitmapFontResourceReader(data: data)
            return BitmapFont(reader: reader)
        })
        
        /* List all the bitmap fonts */
        let bitmapFonts: [BitmapFontResource] = bitmapFontsNew + bitmapFontsOld
        
        /* List the vector fonts */
        let vectorFonts = extractor.listResources(withType: VectorFontResourceType.self, typeName: ResourceRepository.vectorFontTypeName, parse: { (data: DataRange) -> VectorFont in
            let reader = VectorFontResourceReader(data: data)
            let cgfont = reader.readCGFont()
            return VectorFont(cgfont: cgfont)
        })
        
        /* List the font familes */
        let fontFamilies = extractor.listResources(withType: FontFamilyResourceType.self, typeName: ResourceRepository.fontFamilyTypeName, parse: { (data: DataRange) -> FontFamily in
            let reader = FontFamilyResourceReader(data: data)
            return FontFamily(reader: reader, bitmapFonts: bitmapFonts, vectorFonts: vectorFonts)
        })
        
        /* List the card colors */
        let cardColors = extractor.listResources(withType: CardColorResourceType.self, typeName: ResourceRepository.cardColorTypeName, parse: { (data: DataRange) -> LayerColor in
            let reader = ColorResourceReader(data: data)
            let elements = reader.readElements()
            return LayerColor(elements: elements)
        })
        
        /* List the background colors */
        let backgroundColors = extractor.listResources(withType: BackgroundColorResourceType.self, typeName: ResourceRepository.backgroundColorTypeName, parse: { (data: DataRange) -> LayerColor in
            let reader = ColorResourceReader(data: data)
            let elements = reader.readElements()
            return LayerColor(elements: elements)
        })
        
        /* List the background colors */
        let pictures = extractor.listResources(withType: PictureResourceType.self, typeName: ResourceRepository.pictureTypeName, parse: { (data: DataRange) -> NSImage in
            let reader = PictureResourceReader(data: data)
            return reader.readImage()
        })
        
        /* Init */
        self.init(icons: icons, fontFamilies: fontFamilies, cardColors: cardColors, backgroundColors: backgroundColors, pictures: pictures)
    }
    
}

