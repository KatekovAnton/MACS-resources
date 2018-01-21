//
//  MTSequenceFrameSubstractor.m
//  maxtouchTool
//
//  Created by Katekov Anton on 1/15/17.
//  Copyright © 2017 katekovanton. All rights reserved.
//

#import "MTSequenceFrameSubstractor.h"
#import <AppKit/AppKit.h>
#import "Texture.h"
#import "ToolSettings.h"
#import <CoreImage/CoreImage.h>
#import "MTDiffuseComposer.h"
#import "MTShadowComposer.h"
#import "MTLightComposer.h"
#import "NSImage+Utils.h"
#include "CPPTextureImplNSBitmapImageRep.h"
#include "BitmapComposer.hpp"



Color ColorInTexture(CPPITexture *texture, float x, float y, Color baseColor)
{
    if (x < 0) {
        return baseColor;
    }
    if (y < 0) {
        return baseColor;
    }
    if (x >= texture->GetWidth()) {
        return baseColor;
    }
    if (y >= texture->GetHeight()) {
        return baseColor;
    }
    return texture->GetColorAtPoint(GPoint2D(x, y));
}



@interface MTSequenceFrameSubstractor () {
    
}

@property (nonatomic) NSString *framePath;
@property (nonatomic) NSString *substractingFramePath;

@end



@implementation MTSequenceFrameSubstractor

- (id)initWithFramePath:(NSString*)framePath substractingFramePath:(NSString*)substractingFramePath
{
    if (self = [super init]) {
        self.framePath = framePath;
        self.substractingFramePath = substractingFramePath;
    }
    return self;
}

- (void)dowork
{
    CPPITexture *frame = NULL;
    CPPITexture *substractingFrame = NULL;
    
    @autoreleasepool {
        NSImage *frameImage = [[NSImage alloc] initWithContentsOfFile:self.framePath];
//        frameImage = [NSImage resizeImage:frameImage size:NSMakeSize(1024, 1024)];
        NSImage *substractingFrameImage = [[NSImage alloc] initWithContentsOfFile:self.substractingFramePath];
//        substractingFrameImage = [NSImage resizeImage:substractingFrameImage size:NSMakeSize(1024, 1024)];
        frame = new CPPTextureImplNSBitmapImageRep(frameImage);
        substractingFrame = new CPPTextureImplNSBitmapImageRep(substractingFrameImage);
    }
    
    assert(frame->GetWidth() == substractingFrame->GetWidth());
    assert(frame->GetHeight() == substractingFrame->GetHeight());
    
    const float alphaTreshold = 0.05;
    
    BitmapComposer composer = BitmapComposer(GSize2D(frame->GetWidth(), frame->GetHeight()));
    
    double difference = 0;
    double count = 0;
    for (float x = 0; x < frame->GetWidth(); x++) {
        for (float y = 0; y < frame->GetHeight(); y++) {
            Color frameColor = frame->GetColorAtPoint(GPoint2D(x, y));
            Color substractingFrameColor = substractingFrame->GetColorAtPoint(GPoint2D(x, y));
            
            ColorF cf = ColorF(frameColor);
            ColorF cs = ColorF(substractingFrameColor);
            if (cf.a < alphaTreshold &&
                cs.a < alphaTreshold) {
                continue;
            }
            
            double pixelDifference = ____max(____abs(cf.r - cs.r),
                                     ____max(____abs(cf.g - cs.g),
                                     ____max(____abs(cf.b - cs.b),
                                     ____abs(cf.a - cs.a))));
            
            difference += pixelDifference;
            count ++;
        }
    }
    
    difference = difference / count;
    
    for (float x = 0; x < frame->GetWidth(); x++) {
        for (float y = 0; y < frame->GetHeight(); y++) {
            Color frameColor = frame->GetColorAtPoint(GPoint2D(x, y));
            Color substractingFrameColor = substractingFrame->GetColorAtPoint(GPoint2D(x, y));
            
            ColorF cf = ColorF(frameColor);
            ColorF cs = ColorF(substractingFrameColor);
            
            Color resultColor;
            
            // add some magic
            
            // color = (1.0 - cf.a - cs.a) * bc.rgb + (1.0 - cf.a) * substractedcolor.rgb
            // color = (1.0 - cf.a) * cs.rgb + cf.a * framecolor.rgb
            
            composer.setColor(resultColor, x, y);
        }
    }
    
}

@end
