//
//  FileResourceRepository.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 05/06/2018.
//  Copyright © 2018 Pierre Lorenzi. All rights reserved.
//


public extension ResourceRepository {
    
    /// Makes a list of the resources by reading in a resource fork data
    public init(fromResourceFork resourceData: Data) {
        
        let dataRange = DataRange(sharedData: resourceData, offset: 0, length: resourceData.count)
        let fork = ResourceFork(data: dataRange)
        
        /* Add the icons */
        let iconResourceBlocks = fork.extractIcons()
        let icons = iconResourceBlocks.map { (block: IconResourceBlock) -> IconResource in
            let contentProperty = Property<Image> { () -> Image in
                return block.readImage()
            }
            return IconResource(identifier: block.identifier, name: block.name, contentProperty: contentProperty)
        }
        
        /* Add the bitmap fonts */
        let bitmapFontBlocks = fork.extractBitmapFonts()
        let bitmapFonts = bitmapFontBlocks.map { (block: BitmapFontResourceBlock) -> BitmapFontResource in
            let contentProperty = Property<BitmapFont> { () -> BitmapFont in
                return BitmapFont(block: block)
            }
            return BitmapFontResource(identifier: block.identifier, name: block.name, contentProperty: contentProperty)
        }
        
        /* Add the vector fonts */
        let vectorFontBlocks = fork.extractVectorFonts()
        let vectorFonts = vectorFontBlocks.map { (block: VectorFontResourceBlock) -> VectorFontResource in
            let contentProperty = Property<CGFont> { () -> CGFont in
                return block.readCGFont()
            }
            return VectorFontResource(identifier: block.identifier, name: block.name, contentProperty: contentProperty)
        }
        
        /* Add the font families */
        let fontFamilyBlocks = fork.extractFontFamilies()
        let fontFamilies = fontFamilyBlocks.map { (block: FontFamilyResourceBlock) -> FontFamilyResource in
            let contentProperty = Property<FontFamily> { () -> FontFamily in
                return FontFamily(resource: block, bitmapFonts: bitmapFonts, vectorFonts: vectorFonts)
            }
            return FontFamilyResource(identifier: block.identifier, name: block.name, contentProperty: contentProperty)
        }
        
        /* Add the AddColor elements in cards */
        let cardColorBlocks = fork.extractCardColors()
        let cardColors = cardColorBlocks.map { (block: AddColorResourceBlockCard) -> CardColorResource in
            let contentProperty = Property<[AddColorElement]> { () -> [AddColorElement] in
                return block.readElements()
            }
            return CardColorResource(identifier: block.identifier, name: block.name, contentProperty: contentProperty)
        }
        
        /* Add the AddColor elements in backgrounds */
        let backgroundColorBlocks = fork.extractBackgroundColors()
        let backgroundColors = backgroundColorBlocks.map { (block: AddColorResourceBlockBackground) -> BackgroundColorResource in
            let contentProperty = Property<[AddColorElement]> { () -> [AddColorElement] in
                return block.readElements()
            }
            return BackgroundColorResource(identifier: block.identifier, name: block.name, contentProperty: contentProperty)
        }
        
        /* Add the pictures */
        let pictureBlocks = fork.extractPictures()
        let pictures = pictureBlocks.map { (block: PictureResourceBlock) -> PictureResource in
            let contentProperty = Property<NSImage> { () -> NSImage in
                return block.readImage()
            }
            return PictureResource(identifier: block.identifier, name: block.name, contentProperty: contentProperty)
        }
        
        self.init(icons: icons, fontFamilies: fontFamilies, cardColors: cardColors, backgroundColors: backgroundColors, pictures: pictures)
    }
    
}

