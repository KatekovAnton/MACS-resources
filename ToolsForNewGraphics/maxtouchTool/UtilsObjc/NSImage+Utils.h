//
//  NSImage+Utils.h
//  maxtouchTool
//
//  Created by Katekov Anton on 11/17/16.
//  Copyright © 2016 katekovanton. All rights reserved.
//

#import <AppKit/AppKit.h>



@interface NSImage (Utils)

+ (NSImage*)resizeImage:(NSImage*)sourceImage size:(NSSize)size;
+ (NSImage*)offsetImage:(NSImage*)sourceImage delta:(NSPoint)delta backgroundColor:(NSColor *)color;

+ (NSImage*)cropImage:(NSImage*)sourceImage toRect:(NSRect)rect;

+ (void)saveImage:(NSImage*)image toPath:(NSString*)path;
+ (void)saveImageRep:(NSBitmapImageRep*)imageRep toPath:(NSString*)path;

@end
