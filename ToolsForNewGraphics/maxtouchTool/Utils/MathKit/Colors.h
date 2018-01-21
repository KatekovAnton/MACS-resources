//
//  Colors.h
//  MAX
//
//  Created by Katekov Anton on 8/13/16.
//  Copyright © 2016 AntonKatekov. All rights reserved.
//

#ifndef Colors_h
#define Colors_h

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

#endif /* Colors_h */
