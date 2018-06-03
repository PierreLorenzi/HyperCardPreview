//
//  BitmapBlockReader.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 03/06/2018.
//  Copyright © 2018 Pierre Lorenzi. All rights reserved.
//


/// A bitmap stores the picture of a card or a background.
/// <p>
/// It has two layers with one bit per pixel: an image, to tell where the black pixels are, and a mask, to tell where the white pixels are. This is not the classical notion of mask: the mask is not about transparency, it just tells where the blank pixels are. If a pixel is activated in the image and not in the mask, it is black. It it is activated only in the mask, it is blank. If it is activated in both, it is black. The pixels neither activated in the image and in the mask are transparent.
/// <p>
/// The mask and the image both have rectangles where they are enclosed, relative to the card coordinates. Outside the rectangles, the pixels are transparent. The mask and image rectangles are not necessarily in the same place.
public struct BitmapBlockReader {
    
    private let data: DataRange
    
    private let versionOffset: Int
    
    public init(data: DataRange, version: FileVersion) {
        self.data = data
        self.versionOffset = version.isTwo() ? 0 : BitmapBlockReader.version1Offset
    }
    
    private static let ZeroRectangle = Rectangle(top: 0, left: 0, bottom: 0, right: 0)
    private static let version1Offset = -4
    
    /// Identifier
    public func readIdentifier() -> Int {
        return data.readUInt32(at: 0x8)
    }
    
    /// The size of the card, as a rectangle
    public func readCardRectangle() -> Rectangle {
        return data.readRectangle(at: 0x18 + self.versionOffset)
    }
    
    /// The position of the mask
    public func readMaskRectangle() -> Rectangle {
        return data.readRectangle(at: 0x20 + self.versionOffset)
    }
    
    /// The position of the image
    public func readImageRectangle() -> Rectangle {
        return data.readRectangle(at: 0x28 + self.versionOffset)
    }
    
    /// Size of the mask data
    public func readMaskLength() -> Int {
        return data.readUInt32(at: 0x38 + self.versionOffset)
    }
    
    /// Size of the image data
    public func readImageLength() -> Int {
        return data.readUInt32(at: 0x3C + self.versionOffset)
    }
    
    /// Offset of the mask data in the block
    private func computeDataOffset() -> Int {
        return 0x40 + self.versionOffset
    }
    
    /// The decoded image
    public func readImage() -> MaskedImage {
        let dataOffset = self.computeDataOffset()
        guard data.length > dataOffset else {
            let cardRectangle = self.readCardRectangle()
            let maskRectangle = self.readMaskRectangle()
            let imageRectangle = self.readImageRectangle()
            return MaskedImage(width: cardRectangle.width, height: cardRectangle.height, image: .rectangular(rectangle: imageRectangle), mask: .rectangular(rectangle: maskRectangle))
        }
        return self.decodeImage()
    }
    
    private func decodeImage() -> MaskedImage {
        
        /* Get the rectangles */
        let cardRectangle = self.readCardRectangle()
        let maskRectangle = self.readMaskRectangle()
        let imageRectangle = self.readImageRectangle()
        let maskLength = self.readMaskLength()
        let imageLength = self.readImageLength()
        let dataOffset = self.computeDataOffset()
        
        /* The data rectangle is 32-bit aligned */
        let maskRectangle32 = aligned32Bits(maskRectangle)
        let imageRectangle32 = aligned32Bits(imageRectangle)
        
        /* Decode mask */
        var mask: Image? = nil
        if maskLength > 0 {
            mask = Image(width: maskRectangle32.width, height: maskRectangle32.height)
            self.decodeLayer(dataOffset, dataLength: maskLength, pixels: &mask!.data, rectangle: maskRectangle32)
        }
        
        /* Decode image */
        var image: Image? = nil
        if imageLength > 0 {
            image = Image(width: imageRectangle32.width, height: imageRectangle32.height)
            self.decodeLayer(dataOffset + maskLength, dataLength: imageLength, pixels: &image!.data, rectangle: imageRectangle32)
        }
        
        /* Create the masked image */
        let maskLayer = buildImageLayer(mask, rectangle: maskRectangle, rectangle32: maskRectangle32)
        let imageLayer = buildImageLayer(image, rectangle: imageRectangle, rectangle32: imageRectangle32)
        return MaskedImage(width: cardRectangle.width, height: cardRectangle.height, image: imageLayer, mask: maskLayer)
        
    }
    
    private func buildImageLayer(_ data: Image?, rectangle _rectangle: Rectangle, rectangle32: Rectangle) -> MaskedImage.Layer {
        
        /* The rectangle is nil if it is zero */
        let rectangle: Rectangle? = (_rectangle == BitmapBlockReader.ZeroRectangle) ? nil : _rectangle
        
        /* If we have a bitmap, it is a bitmap */
        if let data = data, let rectangle = rectangle {
            let realRectangleInImage = Rectangle(x: rectangle.x - rectangle32.x, y: rectangle.y - rectangle32.y, width: rectangle.width, height: rectangle.height)
            return .bitmap(image: data, imageRectangle: rectangle32, realRectangleInImage: realRectangleInImage)
        }
        
        /* If we have only a rectangle, it is a rectangle */
        if let rectangle = rectangle {
            return .rectangular(rectangle: rectangle)
        }
        
        return .clear
        
    }
    
    private func aligned32Bits(_ rectangle: Rectangle) -> Rectangle {
        return Rectangle(top: rectangle.top, left: downToMultiple(rectangle.left, 32), bottom: rectangle.bottom, right: upToMultiple(rectangle.right, 32))
    }
    
    private func decodeLayer(_ dataOffset: Int, dataLength: Int, pixels: inout [UInt32], rectangle: Rectangle) {
        
        var pixelIndex = 0
        let integerLength = rectangle.width / 32
        let rowWidth = integerLength * 32
        
        var offset = dataOffset
        var dx = 0
        var dy = 0
        
        var repeatedBytes = [0xAA, 0x55, 0xAA, 0x55, 0xAA, 0x55, 0xAA, 0x55]
        
        var y = rectangle.top
        
        rowLoop: while y < rectangle.bottom {
            
            var x = 0
            var repeatCount = 1
            
            /* Read the opcodes */
            while x < rowWidth {
                
                /* Read the opcode */
                let opcode = data.readUInt8(at: offset)
                offset += 1
                
                /* Execute opcode */
                switch opcode {
                    
                case 0x00...0x7F:
                    /* z zero bytes followed by d data bytes */
                    let zeroLength = opcode & 0xF
                    let dataLength = opcode >> 4
                    let totalLength = zeroLength + dataLength
                    for i in 0..<dataLength {
                        let value = data.readUInt8(at: offset)
                        offset += 1
                        for r in 0..<repeatCount {
                            writeByteInRow(value, row: &pixels, rowPixelIndex: pixelIndex, x: x + (zeroLength + i + r * totalLength) * 8)
                        }
                    }
                    x += totalLength * repeatCount * 8
                    repeatCount = 1
                    
                case 0x80:
                    /* One row of uncompressed data */
                    for i in 0..<integerLength {
                        let value = UInt32(data.readUInt32(at: offset + i*4))
                        for r in 0..<repeatCount {
                            pixels[i + pixelIndex + r * integerLength] = value
                        }
                    }
                    offset += integerLength * 4
                    pixelIndex += repeatCount * integerLength
                    y += repeatCount
                    repeatCount = 1
                    continue rowLoop
                    
                case 0x81:
                    /* One white row */
                    pixelIndex += repeatCount * integerLength
                    y += repeatCount
                    repeatCount = 1
                    continue rowLoop
                    
                case 0x82:
                    /* One black row */
                    for _ in 0..<repeatCount {
                        for i in 0..<integerLength {
                            pixels[i + pixelIndex] = 0xFFFF_FFFF
                        }
                        pixelIndex += integerLength
                        y += 1
                    }
                    repeatCount = 1
                    continue rowLoop
                    
                case 0x83:
                    /* One row of a repeated byte of data */
                    let v = data.readUInt8(at: offset)
                    offset += 1
                    let integer = UInt32(v | (v << 8) | (v << 16) | (v << 24))
                    repeatedBytes[y % 8] = v
                    for _ in 0..<repeatCount {
                        for i in 0..<integerLength {
                            pixels[i + pixelIndex] = integer
                        }
                        pixelIndex += integerLength
                        y += 1
                    }
                    repeatCount = 1
                    continue rowLoop
                    
                case 0x84:
                    /* One row of a repeated byte of data previously used */
                    for _ in 0..<repeatCount {
                        let v = repeatedBytes[y % 8]
                        let integer = UInt32(v | (v << 8) | (v << 16) | (v << 24))
                        for i in 0..<integerLength {
                            pixels[i + pixelIndex] = integer
                        }
                        pixelIndex += integerLength
                        y += 1
                    }
                    repeatCount = 1
                    continue rowLoop
                    
                case 0x85:
                    /* Copy the previous row */
                    for _ in 0..<repeatCount {
                        for i in 0..<integerLength {
                            pixels[i + pixelIndex] = pixels[i + pixelIndex - integerLength]
                        }
                        pixelIndex += integerLength
                        y += 1
                    }
                    repeatCount = 1
                    continue rowLoop
                    
                case 0x86:
                    /* Copy the row before the previous row */
                    for _ in 0..<repeatCount {
                        for i in 0..<integerLength {
                            pixels[i + pixelIndex] = pixels[i + pixelIndex - 2 * integerLength]
                        }
                        pixelIndex += integerLength
                        y += 1
                    }
                    repeatCount = 1
                    continue rowLoop
                    
                    /* dx, dy */
                case 0x88:
                    dx = 16
                    dy = 0
                case 0x89:
                    dx = 0
                    dy = 0
                case 0x8A:
                    dx = 0
                    dy = 1
                case 0x8B:
                    dx = 0
                    dy = 2
                case 0x8C:
                    dx = 1
                    dy = 0
                case 0x8D:
                    dx = 1
                    dy = 1
                case 0x8E:
                    dx = 2
                    dy = 2
                case 0x8F:
                    dx = 8
                    dy = 0
                    
                case 0xA0...0xBF:
                    /* Repeat */
                    repeatCount = opcode & 0b11111
                    
                case 0xC0...0xDF:
                    /* Bytes of data */
                    let dataLength = (opcode & 0b11111) * 8
                    for i in 0..<dataLength {
                        let value = data.readUInt8(at: offset)
                        offset += 1
                        for j in 0..<repeatCount {
                            writeByteInRow(value, row: &pixels, rowPixelIndex: pixelIndex, x: x + (i + j * dataLength) * 8)
                        }
                    }
                    x += dataLength * repeatCount * 8
                    repeatCount = 1
                    
                case 0xE0...0xFF:
                    /* Zeros */
                    let zeroCount = (opcode & 0b11111) * 128
                    x += zeroCount * repeatCount
                    repeatCount = 1
                    
                default:
                    /* If the instruction is unknown, that means the data is over */
                    break rowLoop
                    
                }
            }
            
            /* If we get here, we must apply the transformations to the row */
            if dx != 0 {
                applyDx(dx, row: &pixels, rowPixelIndex: pixelIndex, integerLength: integerLength)
            }
            if dy != 0 && dy <= y - rectangle.top {
                for i in 0..<integerLength {
                    pixels[i + pixelIndex] ^= pixels[i + pixelIndex - dy * integerLength]
                }
            }
            pixelIndex += integerLength
            y += 1
            
        }
        
    }
    
    private func applyDx(_ dx: Int, row: inout [UInt32], rowPixelIndex: Int, integerLength: Int) {
        
        /* dx can only be 1, 2, 4, 8, 16, 32 */
        
        var previousResult: UInt32 = 0
        var previousXorLeft: UInt32 = 0
        
        for i in 0..<integerLength {
            
            let value = row[i + rowPixelIndex]
            
            var xorLeft: UInt32 = value
            var xorRight: UInt32 = 0
            
            /* Apply dx on that window */
            for i in 0..<(32 / dx) {
                xorLeft ^= (value << UInt32(dx * i))
                xorRight ^= (value >> UInt32(dx * i))
            }
            
            let result = previousResult ^ previousXorLeft ^ xorRight
            row[i + rowPixelIndex] = result
            
            /* Update the state */
            previousResult = result
            previousXorLeft = xorLeft
            
        }
    }
    
    private func writeByteInRow(_ byte: Int, row: inout [UInt32], rowPixelIndex: Int, x: Int) {
        
        row[rowPixelIndex + x / 32] |= UInt32(byte << (24 - x % 32))
    }
    
}
