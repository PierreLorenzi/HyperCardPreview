//
//  main.swift
//  ExtractImage
//
//  Created by Pierre Lorenzi on 28/09/2015.
//  Copyright © 2015 Pierre Lorenzi. All rights reserved.
//


/// Subclass for V1 stacks
public class StackBlockV1: StackBlock {

    /* Checksum is moved */
    public override func readCheckSum() -> Int {
        return data.readUInt32(at: 0xC)
    }
    
    /* Window size is absent */
    public override func readWindowRectangle() -> Rectangle {
        return Rectangle(top: 0, left: 0, bottom: 0, right: 0)
    }
    public override func readScreenRectangle() -> Rectangle {
        return Rectangle(top: 0, left: 0, bottom: 0, right: 0)
    }
    public override func readScrollPoint() -> Point {
        return Point(x: 0, y: 0)
    }
    
    /* Size is always default */
    public override func readSize() -> Size {
        return Size(width: StackBlock.defaultWidth, height: StackBlock.defaultHeight)
    }
    
    /* Text fonts and styles are absent */
    public override func readFontBlockIdentifier() -> Int? {
        return nil
    }
    public override func readStyleBlockIdentifier() -> Int? {
        return nil
    }
    
}


