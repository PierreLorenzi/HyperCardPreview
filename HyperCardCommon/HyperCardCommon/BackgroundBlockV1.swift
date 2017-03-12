//
//  BackgroundBlock.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 26/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


public class BackgroundBlockV1: BackgroundBlock {
    
    /* We can't inherit, so we compose */
    let layerV1: LayerBlockV1
    
    public required init(data: DataRange) {
        layerV1 = LayerBlockV1(data: data)
        
        super.init(data: data, partOffset: 0x2E)
    }
    
    /* LAYER V1 VALUES, we have to write them here to keep inheriting from Card */
    public override var bitmapIdentifier: Int? {
        return layerV1.bitmapIdentifier
    }
    public override var cantDelete: Bool {
        return layerV1.cantDelete
    }
    public override var showPict: Bool {
        return layerV1.showPict
    }
    public override var dontSearch: Bool {
        return layerV1.dontSearch
    }
    public override var contents: [ContentBlock] {
        return layerV1.listContents(partOffset: self.partOffset, partSize: self.partSize, contentCount: self.contentCount)
    }
    
    /* BACKGROUND VALUES */
    
    /* The values are shifted */
    public override var cardCount: Int {
        return data.readUInt32(at: 0x14)
    }
    
    public override var nextBackgroundIdentifier: Int {
        return data.readSInt32(at: 0x18)
    }
    
    public override var previousBackgroundIdentifier: Int {
        return data.readSInt32(at: 0x1C)
    }
    
}
