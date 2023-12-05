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



struct hsv_color {
    double h;        /* Hue degree between 0.0 and 360.0 */
    double s;        /* Saturation between 0.0 (gray) and 1.0 */
    double v;        /* Value between 0.0 (black) and 1.0 */
};

hsv_color rgb2hsv(ColorF color)
{
    hsv_color   result;
    double      min, max, delta;

    min = color.r < color.g ? color.r : color.g;
    min = min  < color.b ? min  : color.b;

    max = color.r > color.g ? color.r : color.g;
    max = max  > color.b ? max  : color.b;

    result.v = max;                                // v
    delta = max - min;
    if (delta < 0.00001)
    {
        result.s = 0;
        result.h = 0; // undefined, maybe nan?
        return result;
    }
    if( max > 0.0 ) { // NOTE: if Max is == 0, this divide would cause a crash
        result.s = (delta / max);                  // s
    } else {
        // if max is 0, then r = g = b = 0              
        // s = 0, h is undefined
        result.s = 0.0;
        result.h = NAN;                            // its now undefined
        return result;
    }
    if( color.r >= max )                           // > is bogus, just keeps compilor happy
        result.h = ( color.g - color.b ) / delta;        // between yellow & magenta
    else
    if( color.g >= max )
        result.h = 2.0 + ( color.b - color.r ) / delta;  // between cyan & yellow
    else
        result.h = 4.0 + ( color.r - color.g ) / delta;  // between magenta & cyan

    result.h *= 60.0;                              // degrees

    if( result.h < 0.0 )
        result.h += 360.0;

    return result;
}

ColorF hsv_to_rgb(struct hsv_color hsv) {
    ColorF rgb;
    rgb.a = 1.0;
    double c = 0.0, m = 0.0, x = 0.0;
 
    
    c = hsv.v * hsv.s;
    x = c * (1.0 - fabs(fmod(hsv.h / 60.0, 2) - 1.0));
    m = hsv.v - c;
    if (hsv.h >= 0.0 && hsv.h < 60.0)
    {
        rgb = ColorF(c + m, x + m, m);
    }
    else if (hsv.h >= 60.0 && hsv.h < 120.0)
    {
        rgb = ColorF(x + m, c + m, m);
    }
    else if (hsv.h >= 120.0 && hsv.h < 180.0)
    {
        rgb = ColorF(m, c + m, x + m);
    }
    else if (hsv.h >= 180.0 && hsv.h < 240.0)
    {
        rgb = ColorF(m, x + m, c + m);
    }
    else if (hsv.h >= 240.0 && hsv.h < 300.0)
    {
        rgb = ColorF(x + m, m, c + m);
    }
    else if (hsv.h >= 300.0 && hsv.h < 360.0)
    {
        rgb = ColorF(c + m, m, x + m);
    }
    else
    {
        rgb = ColorF(m, m, m);
    }
    return rgb;
}



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
                else if (method == 1) {
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
//                else if (method == 2)
//                {
//                    // minelayer
//                    // TODO: support hsv manipulations
//                    hsv_color color = rgb2hsv(colorDiffuseF);
//                    color.v *= multiplier;
//                    color.s *= 1.35;
//                    colorDiffuseF = hsv_to_rgb(color);
//                }
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
