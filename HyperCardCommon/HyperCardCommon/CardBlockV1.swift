//
//  CardBlock.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 26/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


public class CardBlockV1: CardBlock {
    
    /* We can't inherit, so we compose */
    let layerV1: LayerBlockV1

    public init(data: DataRange, marked: Bool, hasTextContent: Bool, isStartOfBackground: Bool, hasName: Bool, searchHash: SearchHash) {
        layerV1 = LayerBlockV1(data: data)
        
        super.init(data: data, marked: marked, hasTextContent: hasTextContent, isStartOfBackground: isStartOfBackground, hasName: hasName, searchHash: searchHash, partOffset: 0x32)
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
    
    /* CARD VALUES */
    
    /* The values are shifted */
    public override var pageIdentifier: Int {
        return data.readUInt32(at: 0x1C)
    }
    
    public override var backgroundIdentifier: Int {
        return data.readUInt32(at: 0x20)
    }
    
}
