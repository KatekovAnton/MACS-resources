//
//  Structures.cpp
//  maxtouchTool
//
//  Created by Anton Katekov on 2023/12/06.
//  Copyright © 2023 katekovanton. All rights reserved.
//

#include "Structures.h"

unsigned char CharSubstract(unsigned char c1, unsigned char c2)
{
    if (c1 > c2)
        return c1 - c2;
    else
        return 0;
}

Color ColorSubstract(Color c1, Color c2) {
    
    Color result;
    result.r = CharSubstract(c1.r, c2.r);
    result.g = CharSubstract(c1.g, c2.g);
    result.b = CharSubstract(c1.b, c2.b);
    result.a = CharSubstract(c1.a, c2.a);
    return result;
}

unsigned char CharAdd(unsigned char c1, unsigned char c2)
{
    unsigned char result = c1 + c2;
    if (result >= c1 && result >= c2)
        return result;
    else
        return 255;
}

Color ColorAdd(Color c1, Color c2) {
    
    Color result;
    result.r = CharAdd(c1.r, c2.r);
    result.g = CharAdd(c1.g, c2.g);
    result.b = CharAdd(c1.b, c2.b);
    result.a = CharAdd(c1.a, c2.a);
    return result;
}

ColorF ColorFSubstract(ColorF c1, ColorF c2) {
    
    ColorF result;
    result.r = c1.r - c2.r;
    result.g = c1.g - c2.g;
    result.b = c1.b - c2.b;
    result.a = c1.a - c2.a;
    return result;
}

ColorF ColorFAdd(ColorF c1, ColorF c2) {
    
    ColorF result;
    result.r = c1.r + c2.r;
    result.g = c1.g + c2.g;
    result.b = c1.b + c2.b;
    result.a = c1.a + c2.a;
    return result;
}

ColorF ColorFMultScalar(ColorF c1, float c2)
{
    
    ColorF result;
    result.r = c1.r * c2;
    result.g = c1.g * c2;
    result.b = c1.b * c2;
    result.a = c1.a * c2;
    return result;
}

ColorF ColorFAddScalar(ColorF c1, float c2)
{
    
    ColorF result;
    result.r = c1.r + c2;
    result.g = c1.g + c2;
    result.b = c1.b + c2;
//    result.a = c1.a + c2;
   
    return result;
}

ColorF ColorFClamp(ColorF c1)
{
    ColorF result = c1;
    if (result.r < 0) {
        result.r = 0;
    }
    if (result.r > 1) {
        result.r = 1;
    }
    if (result.g < 0) {
        result.g = 0;
    }
    if (result.g > 1) {
        result.g = 1;
    }
    if (result.a < 0) {
        result.a = 0;
    }
    if (result.a > 1) {
        result.a = 1;
    }
    return result;
}

ColorHSV ColorF_To_ColorHSV(const ColorF &color)
{
    ColorHSV   result;
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

ColorF ColorHSV_To_ColorF(const ColorHSV &hsv) 
{
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
