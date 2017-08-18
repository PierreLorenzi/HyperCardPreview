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
    
}

