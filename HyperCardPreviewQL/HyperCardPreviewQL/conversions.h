//
//  conversions.h
//  HyperCardPreviewQL
//
//  Created by Pierre Lorenzi on 12/03/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//

#import <CoreFoundation/CoreFoundation.h>
#import <CoreServices/CoreServices.h>
#import <CoreGraphics/CoreGraphics.h>

void scaleImage(const uint32_t *bits, NSInteger width, NSInteger height, NSInteger integersPerRow, uint32_t *rgb, NSInteger rgbWidth, NSInteger rgbHeight, NSInteger rgbBytesPerRow);

void convert1BitToRGB(const uint32_t *bits, NSInteger width, NSInteger height, NSInteger integersPerRow, uint64_t *rgb, NSInteger rgbBytesPerRow);
