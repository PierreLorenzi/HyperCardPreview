//
//  VectorFont.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 18/02/2016.
//  Copyright © 2016 Pierre Lorenzi. All rights reserved.
//

import Foundation


public class VectorFontResourceBlock: ResourceBlock {
    
    public override class var Name: NumericName {
        return NumericName(string: "sfnt")!
    }
    
    public var cgfont: CGFont {
        
        /* Copy the data */
        let slice = self.data.sharedData[self.data.offset..<self.data.offset + self.data.length]
        let data = Data(slice)
        
        /* Build a data provider */
        let nsdata = NSData(data: data)
        let dataProvider = CGDataProvider(data: nsdata)
        
        return CGFont(dataProvider!)
    }
    
}
