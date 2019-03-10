//
//  Structures.h
//  maxtouchTool
//
//  Created by Katekov Anton on 8/3/16.
//  Copyright © 2016 katekovanton. All rights reserved.
//

#ifndef Structures_h
#define Structures_h
#include "Geometry.h"

struct __Color
{
    unsigned char r;
    unsigned char g;
    unsigned char b;
    unsigned char a;
    
    __Color ()
    :r(0), g(0), b(0), a(0)
    {}
    
    __Color (unsigned char _r, unsigned char _g, unsigned char _b, unsigned char _a)
    :r(_r), g(_g), b(_b), a(_a)
    {}
    
    bool IsNear(unsigned char a1, unsigned char a2) const
    {
        return ____max(a1, a2) - ____min(a1, a2)<3;
    }
    
    inline bool operator == (const __Color &color) const
    {
        return color.r == r && color.b == b && color.g == g && color.a == a; //IsNear(r, color.r) && IsNear(g, color.g) && IsNear(b, color.b) && IsNear(a, color.a);
    }
    
} typedef Color;

static unsigned char CharSubstract(unsigned char c1, unsigned char c2)
{
    if (c1 > c2)
        return c1 - c2;
    else
        return 0;
}

static Color ColorSubstract(Color c1, Color c2) {
    
    Color result;
    result.r = CharSubstract(c1.r, c2.r);
    result.g = CharSubstract(c1.g, c2.g);
    result.b = CharSubstract(c1.b, c2.b);
    result.a = CharSubstract(c1.a, c2.a);
    return result;
}

static unsigned char CharAdd(unsigned char c1, unsigned char c2)
{
    unsigned char result = c1 + c2;
    if (result >= c1 && result >= c2)
        return result;
    else
        return 255;
}

static Color ColorAdd(Color c1, Color c2) {
    
    Color result;
    result.r = CharAdd(c1.r, c2.r);
    result.g = CharAdd(c1.g, c2.g);
    result.b = CharAdd(c1.b, c2.b);
    result.a = CharAdd(c1.a, c2.a);
    return result;
}

struct __ColorRGB
{
    unsigned char r;
    unsigned char g;
    unsigned char b;
    
    bool IsNear(unsigned char a1, unsigned char a2) const
    {
        return ____max(a1, a2) - ____min(a1, a2)<3;
    }
    
    inline bool operator == (const __Color &color) const
    {
        return color.r == r && color.b == b && color.g == g;
    }
    
} typedef ColorRGB;

struct __ColorAlpha
{
    unsigned char a;
    
    bool IsNear(unsigned char a1, unsigned char a2) const
    {
        return ____max(a1, a2) - ____min(a1, a2)<3;
    }
    
    inline bool operator == (const __Color &color) const
    {
        return color.a == a;
    }
    
} typedef ColorAlpha;

static unsigned char ColorComponentFromFloat(float c)
{
    if (c < 0) {
        return 0;
    }
    if (c > 1) {
        return 255;
    }
    return  c * 255;
}

struct __ColorF
{
    float r;
    float g;
    float b;
    float a;
    
    __ColorF ()
    :r(0), g(0), b(0), a(0)
    {}
    
    __ColorF (unsigned char _r, unsigned char _g, unsigned char _b, unsigned char _a)
    :r((float)_r/255.0f), g((float)_g/255.0f), b((float)_b/255.0f), a((float)_a/255.0f)
    {}
    
    __ColorF (Color color)
//    :r((float)color.r/255.0f), g((float)color.g/255.0f), b((float)color.b/255.0f), a((float)color.a/255.0f)
    :__ColorF(color.r, color.g, color.b, color.a)
    {}
    
    Color getColor()
    {
        Color result;
        
        result.r = ColorComponentFromFloat(r);
        result.g = ColorComponentFromFloat(g);
        result.b = ColorComponentFromFloat(b);
        result.a = ColorComponentFromFloat(a);
        
        return result;
    }
    
} typedef ColorF;

static ColorF ColorFSubstract(ColorF c1, ColorF c2) {
    
    ColorF result;
    result.r = c1.r - c2.r;
    result.g = c1.g - c2.g;
    result.b = c1.b - c2.b;
    result.a = c1.a - c2.a;
    return result;
}

static ColorF ColorFAdd(ColorF c1, ColorF c2) {
    
    ColorF result;
    result.r = c1.r + c2.r;
    result.g = c1.g + c2.g;
    result.b = c1.b + c2.b;
    result.a = c1.a + c2.a;
    return result;
}

static ColorF ColorFMultScalar(ColorF c1, float c2) {
    
    ColorF result;
    result.r = c1.r * c2;
    result.g = c1.g * c2;
    result.b = c1.b * c2;
    result.a = c1.a * c2;
    return result;
}

static ColorF ColorFAddScalar(ColorF c1, float c2) {
    
    ColorF result;
    result.r = c1.r + c2;
    result.g = c1.g + c2;
    result.b = c1.b + c2;
//    result.a = c1.a + c2;
   
    return result;
}

static ColorF ColorFClamp(ColorF c1) {
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


#endif /* Structures_h */
