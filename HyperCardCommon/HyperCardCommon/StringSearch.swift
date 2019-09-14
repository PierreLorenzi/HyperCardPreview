//
//  StringSearch.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 12/09/2019.
//  Copyright © 2019 Pierre Lorenzi. All rights reserved.
//


public extension HString {
    
    func find(_ string: HString, from index: Int) -> Int? {
        
        guard string.length > 0 else {
            return nil
        }
        
        let pattern = SearchPattern(string)
        return self.find(pattern, from: index)
    }
    
    func find(_ pattern: SearchPattern, from index: Int) -> Int? {
        
        let patternLength = pattern.string.length
        var patternEndIndex = index + patternLength - 1
        let length = self.length
        
        while patternEndIndex < length {
            
            var index = 0

            while index < patternLength && pattern.string[patternLength-index-1] == HChar.lowercaseNoAccentTable[Int(self[patternEndIndex-index])] {
                index += 1
            }
            
            if index == patternLength {
                return patternEndIndex - patternLength + 1
            }
            
            let character = HChar.lowercaseNoAccentTable[Int(self[patternEndIndex-index])]
            let previousIndex = pattern.previousIndexes[Int(character)][patternLength-index-1]
            patternEndIndex += patternLength - previousIndex - index - 1
        }
        
        return nil
    }
    
    struct SearchPattern {
        public var string: HString
        public var previousIndexes: [[Int]]
        
        public init(_ string: HString) {
            
            let patternString = SearchPattern.buildPatternString(string)
            
            self.string = patternString
            self.previousIndexes = SearchPattern.buildPreviousIndexes(patternString)
        }
        
        private static func buildPatternString(_ string: HString) -> HString {
            
            var patternString = string
            
            for i in 0..<patternString.length {
                patternString[i] = HChar.lowercaseNoAccentTable[Int(patternString[i])]
            }
            
            return patternString
        }
    
        private static func buildPreviousIndexes(_ string: HString) -> [[Int]] {
            
            var previousIndexes = [[Int]](repeating: [Int](repeating: -1, count: string.length), count: 0x100)
            
            for character in HChar(0x00) ... HChar(0xFF) {
                
                var previousIndex = -1
                
                for i in 0..<string.length {
                    
                    if previousIndex != -1 {
                        previousIndexes[Int(character)][i] = previousIndex
                    }
                    if string[i] == character {
                        previousIndex = i
                    }
                }
            }
            return previousIndexes
        }
    }
}
