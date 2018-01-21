//
//  BitmapComposer.cpp
//  maxtouchTool
//
//  Created by Katekov Anton on 8/11/16.
//  Copyright © 2016 katekovanton. All rights reserved.
//

#include "BitmapComposer.hpp"
#include "BitmapTexture.h"
#include "ByteBuffer.h"
#include "Texture.h"



BitmapComposer::BitmapComposer(GSize2D size)
{
    _resultBitmap = new BitmapTexture();
    _resultBitmap->_info._chanels = 4;
    _resultBitmap->_info._textureSize = size;
    
    size_t bufferSize = (size_t)size.width * (size_t)size.height * _resultBitmap->_info._chanels;
    _resultBitmap->MakeBufferWithSize(bufferSize);
}

BitmapComposer::~BitmapComposer()
{
    delete _resultBitmap;
}

BitmapTexture *BitmapComposer::getTexture() const
{
    return _resultBitmap;
}

void BitmapComposer::setColor(Color color, int x, int y)
{
    Color *buffer = getColorBuffer();
    buffer[y * (int)_resultBitmap->_info._textureSize.width + x] = color;
}

GSize2D BitmapComposer::getSize()
{
    return _resultBitmap->_info._textureSize;
}

Color *BitmapComposer::getColorBuffer()
{
    return reinterpret_cast<Color*>(_resultBitmap->GetBuffer()->getPointer());;
}

void BitmapComposer::insertTexture(CPPTextureClipping *clipping, GPoint2D location)
{
//    size_t pixelsize = sizeof(unsigned char) * 4;
//    size_t copySize = pixelsize * clipping->_payloadFrame.size.width;
//    size_t sourceLineSize = pixelsize * clipping->_texture->GetWidth();
//    size_t destinationLineSize = pixelsize * _resultBitmap->_info._textureSize.width;
//    
//    unsigned char *readFrom = clipping->_texture->GetBitmapData() +
//    (size_t)(clipping->_payloadFrame.origin.y * sourceLineSize) +
//    (size_t)(clipping->_payloadFrame.origin.x * pixelsize);
//    
//    unsigned char *copyTo = _resultBitmap->GetBuffer()->getPointer() +
//    (size_t)(location.y * _resultBitmap->_info._textureSize.width * pixelsize) +
//    (size_t)(location.x * pixelsize);
    
//    for (int y = 0; y < clipping->_payloadFrame.size.height; y++) {
//        memcpy(copyTo, readFrom, copySize);
//        readFrom += sourceLineSize;
//        copyTo += destinationLineSize;
//    }
    
    for (int y = 0; y < clipping->_payloadFrame.size.height; y++) {
        for (int x = 0; x < clipping->_payloadFrame.size.width; x++) {
            Color c = clipping->_texture->GetColorAtPoint(GPoint2D(x + clipping->_payloadFrame.origin.x,
                                                                   y + clipping->_payloadFrame.origin.y));
//            ColorF c1 = ColorF(c);
//            c1 = ColorFMultScalar(c1, c1.a);
//            c = c1.getColor();
            setColor(c, x + location.x, y + location.y);
        }
    }

}

#include <stdio.h>
#include <math.h>
#include <sys/types.h>

// a[oldw, oldh]->b[neww, newh]

void resample(void *a, void *b, int oldw, int oldh, int neww,  int newh)
{
    int i;
    int j;
    int l;
    int c;
    float t;
    float u;
    float tmp;
    float d1, d2, d3, d4;
    u_int p1, p2, p3, p4; /* nearby pixels */
    u_char red, green, blue;
    
    for (i = 0; i < newh; i++) {
        for (j = 0; j < neww; j++) {
            
            tmp = (float) (i) / (float) (newh - 1) * (oldh - 1);
            l = (int) floor(tmp);
            if (l < 0) {
                l = 0;
            } else {
                if (l >= oldh - 1) {
                    l = oldh - 2;
                }
            }
            
            u = tmp - l;
            tmp = (float) (j) / (float) (neww - 1) * (oldw - 1);
            c = (int) floor(tmp);
            if (c < 0) {
                c = 0;
            } else {
                if (c >= oldw - 1) {
                    c = oldw - 2;
                }
            }
            t = tmp - c;
            
            /* coefficients */
            d1 = (1 - t) * (1 - u);
            d2 = t * (1 - u);
            d3 = t * u;
            d4 = (1 - t) * u;
            
            /* nearby pixels: a[i][j] */
            p1 = *((u_int*)a + (l * oldw) + c);
            p2 = *((u_int*)a + (l * oldw) + c + 1);
            p3 = *((u_int*)a + ((l + 1)* oldw) + c + 1);
            p4 = *((u_int*)a + ((l + 1)* oldw) + c);
            
            /* color components */
            blue = (u_char)p1 * d1 + (u_char)p2 * d2 + (u_char)p3 * d3 + (u_char)p4 * d4;
            green = (u_char)(p1 >> 8) * d1 + (u_char)(p2 >> 8) * d2 + (u_char)(p3 >> 8) * d3 + (u_char)(p4 >> 8) * d4;
            red = (u_char)(p1 >> 16) * d1 + (u_char)(p2 >> 16) * d2 + (u_char)(p3 >> 16) * d3 + (u_char)(p4 >> 16) * d4;
            
            /* new pixel R G B  */
            *((u_int*)b + (i * neww) + j) = (red << 16) | (green << 8) | (blue);       
        }
    }
}

