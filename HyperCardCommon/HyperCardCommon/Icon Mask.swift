//
//  Icon Mask.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 24/03/2016.
//  Copyright © 2016 Pierre Lorenzi. All rights reserved.
//




/// A utility for HyperCard icons: automatically builds a mask for an image by
/// making black the black pixels, white the white pixels enclosed by black pixels,
/// and transparent the white pixels not enclosed by black pixels.
public func maskIcon(_ image: Image) -> MaskedImage {
    
    /* Build the mask */
    var mask = Image(width: image.width, height: image.height)
    
    /* Make the mask as a rectangle */
    for i in 0..<mask.data.count {
        mask.data[i] = UInt32.max
    }
    
    /* Top and bottom */
    for x in 0..<image.width {
        makeBordersPixelsTransparents(x, 0, image: image, mask: &mask)
        makeBordersPixelsTransparents(x, image.height-1, image: image, mask: &mask)
    }
    
    /* Left and right */
    for y in 0..<image.height {
        makeBordersPixelsTransparents(0, y, image: image, mask: &mask)
        makeBordersPixelsTransparents(image.width-1, y, image: image, mask: &mask)
    }
    
    /* Build the masked image */
    let rectangle = Rectangle(x: 0, y: 0, width: image.width, height: image.height)
    let imageLayer: MaskedImage.Layer = MaskedImage.Layer.bitmap(image: image, imageRectangle: rectangle, realRectangleInImage: rectangle)
    let maskLayer: MaskedImage.Layer = MaskedImage.Layer.bitmap(image: mask, imageRectangle: rectangle, realRectangleInImage: rectangle)
    return MaskedImage(width: image.width, height: image.height, image: imageLayer, mask: maskLayer)
    
}

private func makeBordersPixelsTransparents(_ x: Int, _ y: Int, image: Image, mask: inout Image) {
    
    var points = [Point]()
    points.append(Point(x: x, y: y))
    
    while let point = points.popLast() {
    
        /* The pixel must be removed if it is white */
        guard !image[point.x, point.y] && mask[point.x, point.y] else {
            continue
        }
        
        /* Remove the pixel */
        mask[point.x, point.y] = false
        
        /* Check the nearby positions */
        if point.x > 0 {
            points.append(Point(x: point.x-1, y: point.y))
        }
        if point.x < image.width-1 {
            points.append(Point(x: point.x+1, y: point.y))
        }
        if point.y > 0 {
            points.append(Point(x: point.x, y: point.y-1))
        }
        if point.y < image.height - 1 {
            points.append(Point(x: point.x, y: point.y+1))
        }
        
    }
    
}

