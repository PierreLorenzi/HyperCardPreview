//
//  main.swift
//  ExtractImage
//
//  Created by Pierre Lorenzi on 28/09/2015.
//  Copyright © 2015 Pierre Lorenzi. All rights reserved.
//


public class StackBlockV1: StackBlock {

    /* Checksum is moved */
    public override var checkSum: Int {
        return data.readUInt32(at: 0xC)
    }
    
    /* Window size is absent */
    public override var windowRectangle: Rectangle {
        return Rectangle(top: 0, left: 0, bottom: 0, right: 0)
    }
    public override var screenRectangle: Rectangle {
        return Rectangle(top: 0, left: 0, bottom: 0, right: 0)
    }
    public override var scrollPoint: Point {
        return Point(x: 0, y: 0)
    }
    
    /* Size is always default */
    public override var size: Size {
        return Size(width: StackBlock.defaultWidth, height: StackBlock.defaultHeight)
    }
    
    /* Text fonts and styles are absent */
    public override var fontBlockIdentifier: Int? {
        return nil
    }
    public override var styleBlockIdentifier: Int? {
        return nil
    }
    
}


