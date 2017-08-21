#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <QuickLook/QuickLook.h>
#import "conversions.h"

@import HyperCardCommon;

OSStatus GenerateThumbnailForURL(void *thisInterface, QLThumbnailRequestRef thumbnail, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options, CGSize maxSize);
void CancelThumbnailGeneration(void *thisInterface, QLThumbnailRequestRef thumbnail);
double computeBlack(const uint32_t *bits, NSInteger width, NSInteger height, NSInteger integersPerRow, CGRect rect);

/* -----------------------------------------------------------------------------
    Generate a thumbnail for file

   This function's job is to create thumbnail for designated file as fast as possible
   ----------------------------------------------------------------------------- */

OSStatus GenerateThumbnailForURL(void *thisInterface, QLThumbnailRequestRef thumbnail, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options, CGSize maxSize)
{
    
    @autoreleasepool{
        
        StackPreviewer *previewer = [[StackPreviewer alloc] initWithUrl:(__bridge NSURL * _Nonnull)(url) error:nil];
        if (! previewer) {
            return 1;
        }
        
        CGSize requestedSize = QLThumbnailRequestGetMaximumSize(thumbnail);
        double stackRatio = (double)previewer.width / previewer.height;
        double requestedRatio = requestedSize.width / requestedSize.height;
        CGSize size = requestedSize;
        if (requestedRatio > stackRatio) {
            size.width = size.height * stackRatio;
        }
        else {
            size.height = size.width / stackRatio;
        }
        
        // Preview will be drawn in a vectorized context
        CGContextRef cgContext = QLThumbnailRequestCreateContext(thumbnail, size, true, NULL);
        if(cgContext) {
            
            [previewer moveToCard:0];
            void *bytes = CGBitmapContextGetData(cgContext);
            
            scaleImage(previewer.imageData, previewer.width, previewer.height, previewer.integerCountInRows, bytes, CGBitmapContextGetWidth(cgContext), CGBitmapContextGetHeight(cgContext), CGBitmapContextGetBytesPerRow(cgContext));
            
            QLThumbnailRequestFlushContext(thumbnail, cgContext);
            CFRelease(cgContext);
        }
    }
    
    // To complete your generator please implement the function GenerateThumbnailForURL in GenerateThumbnailForURL.c
    return noErr;
}

void CancelThumbnailGeneration(void *thisInterface, QLThumbnailRequestRef thumbnail)
{
    // Implement only if supported
}
