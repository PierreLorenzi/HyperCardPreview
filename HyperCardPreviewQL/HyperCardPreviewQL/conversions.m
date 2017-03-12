//
//  conversions.c
//  HyperCardPreviewQL
//
//  Created by Pierre Lorenzi on 12/03/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//

#import "conversions.h"
#import <Foundation/Foundation.h>

double computeBlack(const uint32_t *bits, NSInteger width, NSInteger height, NSInteger integersPerRow, CGRect rect);


void scaleImage(const uint32_t *bits, NSInteger width, NSInteger height, NSInteger integersPerRow, uint32_t *rgb, NSInteger rgbWidth, NSInteger rgbHeight, NSInteger rgbBytesPerRow) {
    
    double rgbPixelWidth = (double) width / rgbWidth;
    double rgbPixelHeight = (double) height / rgbHeight;
    
    /* Loop on the rows */
    for (NSInteger rgbY = 0 ; rgbY < rgbHeight ; rgbY++) {
        
        /* Compute the position of the row in the bits */
        double rgbStartY = (double) height * rgbY / rgbHeight;
        
        /* Loop on the pixels */
        for (NSInteger rgbX = 0 ; rgbX < rgbWidth ; rgbX++) {
            
            /* Compute the position of the pixel in the bits */
            double rgbStartX = (double) width * rgbX / rgbWidth;
            
            /* Compute the black rate */
            CGRect rgbRect = CGRectMake(rgbStartX, rgbStartY, rgbPixelWidth, rgbPixelHeight);
            double black = computeBlack(bits, width, height, integersPerRow, rgbRect);
            
            /* Compute the RGB color */
            double white = 1.0 - black;
            uint32_t integerWhite = (uint32_t)(white * 0xFF);
            uint32_t rgbValue = (0xFF << 24) | (integerWhite << 16) | (integerWhite << 8) | integerWhite;
            
            /* Apply the RGB color */
            rgb[rgbY * rgbBytesPerRow/4 + rgbX] = rgbValue;
            
        }
    }
}

double computeBlack(const uint32_t *bits, NSInteger width, NSInteger height, NSInteger integersPerRow, CGRect rect) {
    
    double black = 0;
    
    /* Compute the involved pixels */
    NSInteger startX = (NSInteger) floor(rect.origin.x);
    NSInteger endX = (NSInteger) ceil(rect.origin.x + rect.size.width);
    NSInteger startY = (NSInteger) floor(rect.origin.y);
    NSInteger endY = (NSInteger) ceil(rect.origin.y + rect.size.height);
    
    double rectArea = rect.size.width * rect.size.height;
    
    /* Loop on the pixels */
    for (NSInteger x = startX ; x < endX ; x++) {
        for (NSInteger y = startY ; y < endY ; y++) {
            
            /* Get the value of the pixel */
            NSInteger integerIndexInRow = x / 32;
            NSInteger indexInInteger = 31 - x & 31;
            NSInteger integer = bits[ y * integersPerRow + integerIndexInRow ];
            NSInteger bit = (integer >> indexInInteger) & 1;
            if (! bit) {
                continue;
            }
            
            /* Compute the intersection of the pixel with the rectangle */
            CGRect pixelRect = CGRectMake(x, y, 1, 1);
            CGRect pixelIntersection = CGRectIntersection(rect, pixelRect);
            
            /* Compute the influence of the pixel */
            double pixelIntersectionArea = pixelIntersection.size.width * pixelIntersection.size.height;
            double pixelInfluence = pixelIntersectionArea / rectArea;
            
            black += pixelInfluence;
        }
    }
    
    return black;
}


void convert1BitToRGB(const uint32_t *bits, NSInteger width, NSInteger height, NSInteger integersPerRow, uint64_t *rgb, NSInteger rgbBytesPerRow) {
    
    uint32_t white = 0xffffffff;
    uint32_t black = 0xff000000;
    
    NSInteger integerCount = height * integersPerRow;
    NSInteger rgbIndex = 0;
    NSInteger x = 0;
    NSInteger y = 0;
    
    for (NSInteger integerIndex = 0 ; integerIndex < integerCount ; integerIndex++) {
        uint32_t integer = bits[integerIndex];
        
        NSInteger minIndex = (32 + x - width)/2;
        if (minIndex < 0) {
            minIndex = 0;
        }
        
        for (NSInteger index = minIndex ; index < 32 ; index += 2) {
            
            uint64_t twoRgb = (integer & 1) ? black : white;
            twoRgb <<= 32;
            twoRgb |= (integer & 2) ? black : white;
            rgb[rgbIndex + (31-index)/2] = twoRgb;
            
            integer >>= 2;
            
        }
        rgbIndex += 16;
        x += 32;
        if (x >= width) {
            x = 0;
            y++;
            rgbIndex = y * rgbBytesPerRow/8;
        }
    }
}
