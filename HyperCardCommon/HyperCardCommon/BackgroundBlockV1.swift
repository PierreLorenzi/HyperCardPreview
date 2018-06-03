//
//  BackgroundBlock.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 26/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


/// Subclass for V1 stacks
public class BackgroundBlockV1: BackgroundBlock {
    
    /* We can't inherit, so we compose */
    let layerV1: LayerBlockV1
    
    public required init(data: DataRange) {
        layerV1 = LayerBlockV1(data: data)
        
        super.init(data: data, partOffset: 0x2E)
    }
    
    /* LAYER V1 VALUES, we have to write them here to keep inheriting from Card */
    public override func readBitmapIdentifier() -> Int? {
        return layerV1.readBitmapIdentifier()
    }
    public override func readCantDelete() -> Bool {
        return layerV1.readCantDelete()
    }
    public override func readShowPict() -> Bool {
        return layerV1.readShowPict()
    }
    public override func readDontSearch() -> Bool {
        return layerV1.readDontSearch()
    }
    public override func extractContents() -> [ContentBlock] {
        return layerV1.listContents(partOffset: self.partOffset, partSize: self.readPartSize(), contentCount: self.readContentCount())
    }
    
    /* BACKGROUND VALUES */
    
    /* The values are shifted */
    public override func readCardCount() -> Int {
        return data.readUInt32(at: 0x14)
    }
    
    public override func readNextBackgroundIdentifier() -> Int {
        return data.readSInt32(at: 0x18)
    }
    
    public override func readPreviousBackgroundIdentifier() -> Int {
        return data.readSInt32(at: 0x1C)
    }
    
}
