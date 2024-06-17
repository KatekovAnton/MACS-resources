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
    
    inline unsigned char &operator[] (int index) {
        if (index == 0) {
            return r;
        }
        if (index == 1) {
            return g;
        }
        if (index == 2) {
            return b;
        }
        return a;
    }
    
} typedef Color;

unsigned char CharSubstract(unsigned char c1, unsigned char c2);
Color ColorSubstract(Color c1, Color c2);
unsigned char CharAdd(unsigned char c1, unsigned char c2);
Color ColorAdd(Color c1, Color c2);

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
    
    __ColorF (double _r, double _g, double _b)
    :r((float)_r), g((float)_g), b((float)_b), a(1.0f)
    {}
    
    __ColorF (float _r, float _g, float _b)
    :r(_r), g(_g), b(_b), a(1.0f)
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

struct ColorHSV {
    float h;        /* Hue degree between 0.0 and 360.0 */
    float s;        /* Saturation between 0.0 (gray) and 1.0 */
    float v;        /* Value between 0.0 (black) and 1.0 */
    
    ColorHSV ()
    :h(0), s(0), v(0)
    {}
    
    ColorHSV (float _h, float _s, float _v)
    :h(_h), s(_s), v(_v)
    {}
};

ColorF ColorFSubstract(ColorF c1, ColorF c2);
ColorF ColorFAdd(ColorF c1, ColorF c2);
ColorF ColorFMultScalar(ColorF c1, float c2);
ColorF ColorFAddScalar(ColorF c1, float c2);
ColorF ColorFClamp(ColorF c1);
ColorHSV ColorF_To_ColorHSV(const ColorF &color);
ColorF ColorHSV_To_ColorF(const ColorHSV &hsv);

#endif /* Structures_h */
