//
//  NSImage+Utils.m
//  maxtouchTool
//
//  Created by Katekov Anton on 11/17/16.
//  Copyright © 2016 katekovanton. All rights reserved.
//

#import "NSImage+Utils.h"



@implementation NSImage (Utils)

+ (NSImage*)resizeImage:(NSImage*)sourceImage size:(NSSize)size
{
    NSRect targetFrame = [[NSScreen mainScreen] convertRectFromBacking:NSMakeRect(0, 0, size.width, size.height)];
    NSImage*  targetImage = [[NSImage alloc] initWithSize:targetFrame.size];
    
    [targetImage lockFocus];
    
    [sourceImage drawInRect:targetFrame
                   fromRect:NSZeroRect       //portion of source image to draw
                  operation:NSCompositeCopy  //compositing operation
                   fraction:1.0              //alpha (transparency) value
             respectFlipped:YES              //coordinate system
                      hints:@{NSImageHintInterpolation:
                                  [NSNumber numberWithInt:NSImageInterpolationHigh]}];
    
    [targetImage unlockFocus];
    
    return targetImage;
}

+ (NSImage*)copyImage:(NSImage*)image withSize:(NSSize)size
{
    NSRect frame = NSMakeRect(0, 0, size.width, size.height);
    
    NSImageRep* rep = [image bestRepresentationForRect:frame context:nil hints:nil];
    NSImage* img = [[NSImage alloc] initWithSize:size];
    
    [img lockFocus];
    [rep drawInRect:frame];
    [img unlockFocus];
    return img;
}

+ (NSImage*)resizeImage:(NSImage*)source whileMaintainingAspectRatioToSize:(NSSize)size {
    NSSize newSize;
    
    float widthRatio  = size.width / source.size.width;
    float heightRatio = size.height / source.size.height;
    
    if (widthRatio > heightRatio) {
        newSize = NSMakeSize(floor(source.size.width * widthRatio), floor(source.size.height * widthRatio));
    }
    else {
        newSize = NSMakeSize(floor(source.size.width * heightRatio), floor(source.size.height * heightRatio));
    }
    
    return [self copyImage:source withSize:newSize];
}

+ (NSImage*)cropImage:(NSImage*)sourceImage toRect:(NSRect)rect
{
    NSImageRep *rep = [sourceImage bestRepresentationForRect:rect context:nil hints:nil];
    NSImage* img = [[NSImage alloc] initWithSize:rect.size];
    
    [img lockFocus];
    
    [rep drawInRect:NSMakeRect(0, 0, rect.size.width, rect.size.height)
           fromRect:rect
          operation:NSCompositingOperationCopy
           fraction:1.0
     respectFlipped:NO
              hints:nil];
    
    [img unlockFocus];
    
    NSSize sz = img.size;
//    sz.width /= [NSScreen mainScreen].backingScaleFactor;
//    sz.height /= [NSScreen mainScreen].backingScaleFactor;
    img = [self resizeImage:img size:sz];
    
    return img;
    
}

+ (void)saveImage:(NSImage*)image toPath:(NSString*)path
{
    @autoreleasepool {
        NSData *imageData = [image TIFFRepresentation];
        NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
        
        [self saveImageRep:imageRep toPath:path];
    }
}

+ (void)saveImageRep:(NSBitmapImageRep*)imageRep toPath:(NSString*)path
{
    NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:1.0] forKey:NSImageCompressionFactor];
    NSData *imageData = [imageRep representationUsingType:NSPNGFileType properties:imageProps];
    [imageData writeToFile:path atomically:NO];
}

@end
