//
//  MTDiffuseComposer.m
//  maxtouchTool
//
//  Created by Katekov Anton on 11/7/16.
//  Copyright © 2016 katekovanton. All rights reserved.
//

#import "MTDiffuseComposer.h"
#import "MTVisualObject.h"
#include "Texture.h"
#import "Utils.h"
#include "BitmapComposer.hpp"
#include "BitmapTexture.h"
#include "ByteBuffer.h"
#include "LibpngWrapper.h"
#include "ZipWrapper.h"



@interface MTDiffuseComposer () {
    CPPITexture *_diffuseTexture;
    CPPITexture *_diffuseAlphaTexture;
}

@end



@implementation MTDiffuseComposer

- (id)initWithDiffuseTexture:(CPPITexture *)diffuseTexture
         diffuseAlphaTexture:(CPPITexture *)diffuseAlphaTexture
{
    if (self = [super init]) {
        _diffuseAlphaTexture = diffuseAlphaTexture;
        _diffuseTexture = diffuseTexture;
    }
    return self;
}

- (NSImage *)buildDiffuseImageWithDarkenMultiplier:(float)multiplier method:(int)method save:(BOOL)save
{
    CPPTextureClipping *clipping = new CPPTextureClipping(_diffuseAlphaTexture, false);
    BitmapComposer *composer = new BitmapComposer(clipping->_payloadFrame.size);
    for (int x = 0; x < clipping->_payloadFrame.size.width; x++) {
        for (int y = 0; y < clipping->_payloadFrame.size.height; y++) {
            
            int cx = clipping->_payloadFrame.origin.x + x;
            int cy = clipping->_payloadFrame.origin.y + y;
            Color colorDiffuse = _diffuseTexture->GetColorAtPoint(GPoint2D(cx, cy));
            {
                ColorF colorDiffuseF(colorDiffuse);
                if (method == 0) {
                    float min = 1.0 - multiplier;
                    colorDiffuseF = ColorFAddScalar(colorDiffuseF, -min);
                }
                else  {
                    float gray = (colorDiffuseF.r + colorDiffuseF.g + colorDiffuseF.b) / 3.0;
                    float notGray = fabs(gray - (fabsf(gray - colorDiffuseF.r) + fabsf(gray - colorDiffuseF.g) + fabsf(gray - colorDiffuseF.b)) / 3.0);
                    float treshold = 0.2;
                    if (notGray > treshold) {
                        
                        float diffr = (gray - colorDiffuseF.r);
                        colorDiffuseF.r = multiplier * (gray - diffr * multiplier) * colorDiffuseF.a;
                        
                        float diffg = (gray - colorDiffuseF.g);
                        colorDiffuseF.g = multiplier * (gray - diffg * multiplier) * colorDiffuseF.a;
                        
                        float diffb = (gray - colorDiffuseF.b);
                        colorDiffuseF.b = multiplier * (gray - diffb * multiplier) * colorDiffuseF.a;
                    }
                }
                colorDiffuse = colorDiffuseF.getColor();
            }
            Color colorDiffuseAlpha = _diffuseAlphaTexture->GetColorAtPoint(GPoint2D(cx, cy));
            Color colorResult = Color(colorDiffuse.r,
                                      colorDiffuse.g,
                                      colorDiffuse.b,
                                      colorDiffuseAlpha.a);
            
            
            if (colorResult.a != 0) {
                ColorF colorResultF(colorResult);
                float alpha = colorResultF.a;
                colorResultF = ColorFMultScalar(colorResultF, 1.0 / alpha);
                colorResultF.a = alpha;
                colorResultF = ColorFClamp(colorResultF);
                colorResult = colorResultF.getColor();
            }
            composer->setColor(colorResult, cx, cy);
        }
    }
    
    int size = composer->getSize().width * composer->getSize().height * 4;
    ByteBuffer buffer;
    zip_compress((char *)composer->getColorBuffer(), size, &buffer);
    
    NSImage *result = nil;
    if (save) {
        result = [MTVisualObject resultImageWithBitmapComposer:composer];
    }
    
    delete composer;
    _resultImageData = [[NSData alloc] initWithBytes:buffer.getPointer() length:buffer.getDataSize()];
    return result;
}

@end
