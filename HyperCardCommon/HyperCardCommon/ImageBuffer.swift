//
//  ImageBuffer.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 10/09/2019.
//  Copyright © 2019 Pierre Lorenzi. All rights reserved.
//


public struct ImageBuffer {
    
    public var pixels: UnsafeMutableBufferPointer<UInt32>
    public var width: Int
    public var height: Int
    public var countPerRow: Int
    public var computePixelValue: (Double) -> UInt32
    public var context: CGContext
}

public extension ImageBuffer {
    
    private static let bitmapInfo:CGBitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)
    
    init(width: Int, height: Int) {
        
        let pixels = UnsafeMutableBufferPointer<UInt32>.allocate(capacity: width * height)
        let computePixelValue = { (green: Double) -> UInt32 in
            let green256 = 0xFF - Int(round(green * 0xFF))
            let pixelValue: Int = 0xFF << 24 | green256 << 16 | green256 << 8 | green256
            return UInt32(pixelValue)
        }
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: UnsafeMutableRawPointer(pixels.baseAddress!),
                                width: width,
                                height: height,
                                bitsPerComponent: 8,
                                bytesPerRow: width * MemoryLayout<UInt32>.size,
                                space: colorSpace,
                                bitmapInfo: ImageBuffer.bitmapInfo.rawValue)!
        
        self.pixels = pixels
        self.width = width
        self.height = height
        self.countPerRow = width
        self.computePixelValue = computePixelValue
        self.context = context
    }
}

public extension ImageBuffer {
    
    func drawImage(_ image: Image, onlyRectangle possibleRectangle: Rectangle? = nil) {
        
        let rectangle = possibleRectangle ?? Rectangle(x: 0, y: 0, width: image.width, height: image.height)
        
        let horizontalSampleLength = Double(image.width) / Double(self.width)
        let verticalSampleLength = Double(image.height) / Double(self.height)
        let firstHorizontalSampleIndex = Int(floor(Double(rectangle.left) / horizontalSampleLength))
        let firstVerticalSampleIndex = Int(floor(Double(rectangle.top) / verticalSampleLength))
        var horizontalSample = Sample(sampleLength: horizontalSampleLength)
        var verticalSample = Sample(sampleLength: verticalSampleLength)
        
        verticalSample.move(to: firstVerticalSampleIndex)
        
        while verticalSample.lastPixelIndex < rectangle.bottom {
            
            horizontalSample.move(to: firstHorizontalSampleIndex)
            
            while horizontalSample.lastPixelIndex < rectangle.right {
                
                /* Gather the pixels in the sample */
                var value = 0.0
                
                /* Top Left pixel */
                if image[horizontalSample.firstPixelIndex, verticalSample.firstPixelIndex] {
                    value += horizontalSample.firstPixelWeigh * verticalSample.firstPixelWeigh
                }
                
                /* Top Right pixel */
                if horizontalSample.lastExists &&
                    image[horizontalSample.lastPixelIndex, verticalSample.firstPixelIndex] {
                    value += horizontalSample.lastPixelWeigh * verticalSample.firstPixelWeigh
                }
                
                /* Bottom Left pixel */
                if verticalSample.lastExists &&
                    image[horizontalSample.firstPixelIndex, verticalSample.lastPixelIndex] {
                    value += horizontalSample.firstPixelWeigh * verticalSample.lastPixelWeigh
                }
                
                /* Bottom Right pixel */
                if horizontalSample.lastExists && verticalSample.lastExists &&
                    image[horizontalSample.lastPixelIndex, verticalSample.lastPixelIndex] {
                    value += horizontalSample.lastPixelWeigh * verticalSample.lastPixelWeigh
                }
                
                /* Top & Bottom pixels */
                if horizontalSample.middleExists {
                    for x in horizontalSample.firstPixelIndex+1 ... horizontalSample.lastPixelIndex-1 {
                        if image[x, verticalSample.firstPixelIndex] {
                            value += horizontalSample.middlePixelWeigh * verticalSample.firstPixelWeigh
                        }
                        if verticalSample.lastExists && image[x, verticalSample.lastPixelIndex] {
                            value += horizontalSample.middlePixelWeigh * verticalSample.lastPixelWeigh
                        }
                    }
                }
                
                /* Left & Right pixels */
                if verticalSample.middleExists {
                    for y in verticalSample.firstPixelIndex+1 ... verticalSample.lastPixelIndex-1 {
                        if image[horizontalSample.firstPixelIndex, y] {
                            value += horizontalSample.firstPixelWeigh * verticalSample.middlePixelWeigh
                        }
                        if horizontalSample.lastExists && image[horizontalSample.lastPixelIndex, y] {
                            value += horizontalSample.lastPixelWeigh * verticalSample.middlePixelWeigh
                        }
                    }
                }
                
                /* Center pixels */
                if horizontalSample.middleExists && verticalSample.middleExists {
                    let weigh = horizontalSample.middlePixelWeigh * verticalSample.middlePixelWeigh
                    for x in horizontalSample.firstPixelIndex+1 ... horizontalSample.lastPixelIndex-1 {
                        for y in verticalSample.firstPixelIndex+1 ... verticalSample.lastPixelIndex-1 {
                            if image[x,y] {
                                value += weigh
                            }
                        }
                    }
                }
                
                let pixelValue = self.computePixelValue(value)
                self.pixels[horizontalSample.index + verticalSample.index * self.countPerRow] = pixelValue
                
                horizontalSample.step()
            }
            
            verticalSample.step()
        }
    }
    
    private struct Sample {
        
        var index: Int
        var firstPixelIndex: Int
        var lastPixelIndex: Int
        var firstPixelWeigh: Double
        var lastPixelWeigh: Double
        let middlePixelWeigh: Double
        let sampleLength: Double
        
        init(sampleLength: Double) {
            self.index = 0
            self.firstPixelIndex = 0
            self.lastPixelIndex = 0
            self.firstPixelWeigh = 0.0
            self.lastPixelWeigh = 0.0
            self.middlePixelWeigh = 1.0 / sampleLength
            self.sampleLength = sampleLength
        }
        
        mutating func step() {
            
            self.move(to: self.index+1)
        }
        
        mutating func move(to index: Int) {
            
            let startOffset = Double(index) * sampleLength
            let endOffset = startOffset + sampleLength
            
            let firstPixelIndex = floor(startOffset)
            var lastPixelIndex = floor(endOffset)
            var firstPixelWeigh = (1.0 - (startOffset - firstPixelIndex)) / sampleLength
            
            if endOffset == lastPixelIndex {
                lastPixelIndex -= 1
            }
            if firstPixelIndex == lastPixelIndex {
                firstPixelWeigh = 1.0
            }
            
            self.index = index
            self.firstPixelIndex = Int(firstPixelIndex)
            self.lastPixelIndex = Int(lastPixelIndex)
            self.firstPixelWeigh = firstPixelWeigh
            self.lastPixelWeigh = (endOffset - lastPixelIndex) / sampleLength
        }
        
        var lastExists: Bool {
            return self.lastPixelIndex > self.firstPixelIndex
        }
        
        var middleExists: Bool {
            return self.lastPixelIndex > self.firstPixelIndex + 1
        }
    }
}
