//
//  ResourceRepository.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 27/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//



/// A resource fork, not as a raw data but as a typed data
public struct ResourceRepository {
    
    public var icons: [IconResource]
    public var fontFamilies: [FontFamilyResource]
    public var cardColors: [CardColorResource]
    public var backgroundColors: [BackgroundColorResource]
    public var pictures: [PictureResource]
}

