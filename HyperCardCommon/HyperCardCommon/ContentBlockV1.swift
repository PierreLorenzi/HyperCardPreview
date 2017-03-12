//
//  ContentBlock.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 26/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//




public class ContentBlockV1: ContentBlock {
    
    /* All contents are raw strings */
    public override var string: HString {
        return data.readString(at: 2, length: data.length - 3)
    }
    
    public override var formattingChanges: [TextFormatting]? {
        return nil
    }
    
}
