//
//  VisualEffects.swift
//  HyperCardPreview
//
//  Created by Pierre Lorenzi on 18/08/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//

import HyperCardCommon



struct VisualEffects {
    
    static let duration: TimeInterval = 0.3
    
    static let dissolveStepCount = 12
    
    /// Draws an increment of the dissolve visual effect. The step is between 0 and 11
    static func dissolve(_ image: Image, on drawing: Drawing, at step: Int) {
        
        func buildPattern(`for` points: [Point]) -> [UInt32] {
            var pattern: [UInt32] = [0, 0, 0, 0]
            
            for point in points {
                let mask: UInt32 = UInt32(0x8888_8888) >> UInt32(point.x)
                pattern[point.y] |= mask
            }
            
            return pattern
        }
        
        func buildComposition(with pattern: [UInt32]) -> ImageComposition {
            return { ( a: inout UInt32, b: UInt32, integerIndex: Int, y: Int) in
                let patternIndex = y % 4
                let mask = pattern[patternIndex]
                var result = a
                result &= ~mask
                result |= (mask & b)
                a = result
            }
        }
        
        let points: [[Point]] = [
            [   Point(x: 0, y: 0)   ],
            [   Point(x: 2, y: 2)   ],
            [   Point(x: 2, y: 0)   ],
            [   Point(x: 0, y: 2)   ],
            [   Point(x: 1, y: 1)   ],
            [   Point(x: 3, y: 3)   ],
            [   Point(x: 3, y: 1)   ],
            [   Point(x: 1, y: 3)   ],
            [   Point(x: 0, y: 1), Point(x: 0, y: 3)   ],
            [   Point(x: 2, y: 1), Point(x: 2, y: 3)   ],
            [   Point(x: 1, y: 0), Point(x: 1, y: 2)   ],
            [   Point(x: 3, y: 0), Point(x: 3, y: 2)   ]
        ]
        
        let patterns: [[UInt32]] = points.map(buildPattern)
        let compositions: [ImageComposition] = patterns.map(buildComposition)
        
        let composition = compositions[step]
        drawing.drawImage(image, position: Point(x: 0, y: 0), rectangleToDraw: nil, clipRectangle: nil, composition: composition)
        
    }
    
    enum Direction {
        case left
        case right
        case top
        case bottom
    }
    
    /* Define a composition where both white and black pixels are drawn */
    static let totalComposition: ImageComposition = { ( a: inout UInt32, b: UInt32, integerIndex: Int, y: Int) in
        a = b
    }
    
    /// Draws an increment of the dissolve visual effect. The step is between 0 and 1
    static func wipe(_ image: Image, on drawing: Drawing, to direction: Direction, step: Double) {
        
        switch direction {
            
        case .left:
            let length = Int( Double(image.width) * step )
            let position = Point(x: image.width - length, y: 0)
            let rectangleToDraw = Rectangle(top: 0, left: image.width - length, bottom: image.height, right: image.width)
            drawing.drawImage(image, position: position, rectangleToDraw: rectangleToDraw, composition: totalComposition)
            
        case .right:
            let length = Int( Double(image.width) * step )
            let position = Point(x: 0, y: 0)
            let rectangleToDraw = Rectangle(top: 0, left: 0, bottom: image.height, right: length)
            drawing.drawImage(image, position: position, rectangleToDraw: rectangleToDraw, composition: totalComposition)
            
        case .top:
            let length = Int( Double(image.height) * step )
            let position = Point(x: 0, y: image.height - length)
            let rectangleToDraw = Rectangle(top: image.height - length, left: 0, bottom: image.height, right: image.width)
            drawing.drawImage(image, position: position, rectangleToDraw: rectangleToDraw, composition: totalComposition)
            
        case .bottom:
            let length = Int( Double(image.height) * step )
            let position = Point(x: 0, y: 0)
            let rectangleToDraw = Rectangle(top: 0, left: 0, bottom: length, right: image.width)
            drawing.drawImage(image, position: position, rectangleToDraw: rectangleToDraw, composition: totalComposition)
            
        }
        
    }
    
    /// Draws an increment of the dissolve visual effect. The step is between 0 and 1
    static func scroll(_ image: Image, on drawing: Drawing, to direction: Direction, step: Double) {
        
        switch direction {
            
        case .left:
            let length = Int( Double(image.width) * step )
            drawing.drawImage(image, position: Point(x: image.width - length, y: 0), composition: totalComposition)
            
        case .right:
            let length = Int( Double(image.width) * step )
            drawing.drawImage(image, position: Point(x: length - image.width, y: 0), composition: totalComposition)
            
        case .top:
            let length = Int( Double(image.height) * step )
            drawing.drawImage(image, position: Point(x: 0, y: image.height - length), composition: totalComposition)
            
        case .bottom:
            let length = Int( Double(image.height) * step )
            drawing.drawImage(image, position: Point(x: 0, y: length - image.height), composition: totalComposition)
            
        }
        
    }
    
}

