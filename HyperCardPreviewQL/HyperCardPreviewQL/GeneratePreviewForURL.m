#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <QuickLook/QuickLook.h>
#import "conversions.h"

@import HyperCardCommon;

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options);
void CancelPreviewGeneration(void *thisInterface, QLPreviewRequestRef preview);

/* -----------------------------------------------------------------------------
   Generate a preview for file

   This function's job is to create preview for designated file
 ----------------------------------------------------------------------------- */

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options)
{
    @autoreleasepool{
        
        StackPreviewer *previewer = [[StackPreviewer alloc] initWithUrl:(__bridge NSURL * _Nonnull)(url)];
        CGSize size = CGSizeMake(previewer.width, previewer.height);
        
        // Preview will be drawn in a vectorized context
        CGContextRef cgContext = QLPreviewRequestCreateContext(preview, size, true, NULL);
        if(cgContext) {
            
            void *bytes = CGBitmapContextGetData(cgContext);
            
            [previewer moveToCard:0];
            
//            convert1BitToRGB(previewer.imageData, previewer.width, previewer.height, previewer.integerCountInRows, bytes, CGBitmapContextGetBytesPerRow(cgContext));
            scaleImage(previewer.imageData, previewer.width, previewer.height, previewer.integerCountInRows, bytes, CGBitmapContextGetWidth(cgContext), CGBitmapContextGetHeight(cgContext), CGBitmapContextGetBytesPerRow(cgContext));
            
            QLPreviewRequestFlushContext(preview, cgContext);
            CFRelease(cgContext);
        }
    }
    
    return noErr;
}

void CancelPreviewGeneration(void *thisInterface, QLPreviewRequestRef preview)
{
    // Implement only if supported
}
