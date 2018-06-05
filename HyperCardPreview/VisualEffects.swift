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
        
        func buildPattern(`for` points: [Point]) -> [Image.Integer] {
            var pattern: [Image.Integer] = [0, 0, 0, 0]
            
            for point in points {
                let maskInteger: UInt = 0x8888_8888_8888_8888
                let mask: Image.Integer = Image.Integer(truncatingIfNeeded: maskInteger) >> Image.Integer(point.x)
                pattern[point.y] |= mask
            }
            
            return pattern
        }
        
        func buildComposition(with pattern: [Image.Integer]) -> ImageComposition {
            return { ( a: inout Image.Integer, b: Image.Integer, integerIndex: Int, y: Int) in
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
        
        let patterns: [[Image.Integer]] = points.map(buildPattern)
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
    private static let totalComposition: ImageComposition = { ( a: inout Image.Integer, b: Image.Integer, integerIndex: Int, y: Int) in
        a = b
    }

    class ContinuousVisualEffect {
        
        func draw(_ image: Image, on drawing: Drawing, step: Double) {
            
        }
        
    }

    class Wipe: ContinuousVisualEffect {
        
        private let direction: Direction
        
        init(to direction: Direction) {
            self.direction = direction
        }
        
        override func draw(_ image: Image, on drawing: Drawing, step: Double) {
            
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
        
    }

    class Scroll: ContinuousVisualEffect {
        
        private let direction: Direction
        
        init(to direction: Direction) {
            self.direction = direction
        }
        
        override func draw(_ image: Image, on drawing: Drawing, step: Double) {
            
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
    
    enum OpeningDirection {
        case open
        case close
    }
    
    class BarnDoor: ContinuousVisualEffect {
        
        private let direction: OpeningDirection
        
        init(_ direction: OpeningDirection) {
            self.direction = direction
        }
        
        override func draw(_ image: Image, on drawing: Drawing, step: Double) {
            
            switch direction {
                
            case .open:
                let length = Int( Double(image.width) * step )
                let position = Point(x: (image.width - length) / 2, y: 0)
                let rectangleToDraw = Rectangle(x: position.x, y: 0, width: length, height: image.height)
                drawing.drawImage(image, position: position, rectangleToDraw: rectangleToDraw, composition: totalComposition)
                
            case .close:
                let length = Int( Double(image.width) / 2 * step )
                
                /* Left Side */
                let positionLeft = Point(x: 0, y: 0)
                let rectangleToDrawLeft = Rectangle(x: positionLeft.x, y: 0, width: length, height: image.height)
                drawing.drawImage(image, position: positionLeft, rectangleToDraw: rectangleToDrawLeft, composition: totalComposition)
                
                /* Right Side */
                let positionRight = Point(x: image.width - length, y: 0)
                let rectangleToDrawRight = Rectangle(x: positionRight.x, y: 0, width: length, height: image.height)
                drawing.drawImage(image, position: positionRight, rectangleToDraw: rectangleToDrawRight, composition: totalComposition)
                
            }
            
        }
        
    }
    
    class Iris: ContinuousVisualEffect {
        
        private let direction: OpeningDirection
        
        init(_ direction: OpeningDirection) {
            self.direction = direction
        }
        
        override func draw(_ image: Image, on drawing: Drawing, step: Double) {
            
            switch direction {
                
            case .open:
                let width = Int( Double(image.width) * step )
                let height = Int( Double(image.height) * step )
                let position = Point(x: (image.width - width) / 2, y: (image.height - height) / 2)
                let rectangleToDraw = Rectangle(x: position.x, y: position.y, width: width, height: height)
                drawing.drawImage(image, position: position, rectangleToDraw: rectangleToDraw, composition: totalComposition)
                
            case .close:
                let width = Int( Double(image.width) / 2 * step )
                let height = Int( Double(image.height) / 2 * step )
                
                /* Left Side */
                let positionLeft = Point(x: 0, y: 0)
                let rectangleToDrawLeft = Rectangle(x: positionLeft.x, y: 0, width: width, height: image.height)
                drawing.drawImage(image, position: positionLeft, rectangleToDraw: rectangleToDrawLeft, composition: totalComposition)
                
                /* Right Side */
                let positionRight = Point(x: image.width - width, y: 0)
                let rectangleToDrawRight = Rectangle(x: positionRight.x, y: 0, width: width, height: image.height)
                drawing.drawImage(image, position: positionRight, rectangleToDraw: rectangleToDrawRight, composition: totalComposition)
                
                /* Top */
                let positionTop = Point(x: width, y: 0)
                let rectangleToDrawTop = Rectangle(x: positionTop.x, y: 0, width: image.width - width, height: height)
                drawing.drawImage(image, position: positionTop, rectangleToDraw: rectangleToDrawTop, composition: totalComposition)
                
                /* Bottom */
                let positionBottom = Point(x: width, y: image.height - height)
                let rectangleToDrawBottom = Rectangle(x: positionBottom.x, y: positionBottom.y, width: image.width - width, height: height)
                drawing.drawImage(image, position: positionBottom, rectangleToDraw: rectangleToDrawBottom, composition: totalComposition)
                
            }
            
        }
        
    }
    
    class VenetianBlinds: ContinuousVisualEffect {
        
        private static let blindHeight = 38
        
        override func draw(_ image: Image, on drawing: Drawing, step: Double) {
            
            let length = Int( Double(VenetianBlinds.blindHeight) * step )
            let count = Int(ceil(Double(image.height / VenetianBlinds.blindHeight)))
            
            for i in 0..<count {
                
                let position = Point(x: 0, y: VenetianBlinds.blindHeight * i)
                let rectangleToDraw = Rectangle(x: position.x, y: position.y, width: image.width, height: length)
                drawing.drawImage(image, position: position, rectangleToDraw: rectangleToDraw, composition: totalComposition)
            }
            
        }
        
    }
    
    class CheckerBoard: ContinuousVisualEffect {
        
        private static let width = 32
        private static let height = 38
        
        private var firstStepFinalized = false
        
        override func draw(_ image: Image, on drawing: Drawing, step: Double) {
            
            if step < 0.5 {
                
                /* First step */
                self.drawSquares(image, on: drawing, step: step * 2, filter: 0)
            }
            else {
                
                /* Ensure first step is completed */
                if !firstStepFinalized {
                    self.drawSquares(image, on: drawing, step: 1.0, filter: 0)
                    firstStepFinalized = true
                }
                
                /* Second step */
                self.drawSquares(image, on: drawing, step: (step - 0.5) * 2, filter: 1)
            }
            
            
        }
        
        private func drawSquares(_ image: Image, on drawing: Drawing, step: Double, filter: Int) {
            
            let length = Int( Double(CheckerBoard.height) * step )
            let countX = Int(ceil(Double(image.width / CheckerBoard.width)))
            let countY = Int(ceil(Double(image.height / CheckerBoard.height)))
            
            
            for x in 0..<countX {
                for y in 0..<countY {
                    
                    guard (x + y) % 2 == filter else {
                        continue
                    }
                    
                    let position = Point(x: x * CheckerBoard.width, y: y * CheckerBoard.height)
                    let rectangleToDraw = Rectangle(x: position.x, y: position.y, width: CheckerBoard.width, height: length)
                    drawing.drawImage(image, position: position, rectangleToDraw: rectangleToDraw, composition: totalComposition)
                }
            }
            
        }
        
    }

}




