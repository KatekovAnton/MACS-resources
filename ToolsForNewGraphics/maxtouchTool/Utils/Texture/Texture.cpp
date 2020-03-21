//
//  Texture.cpp
//  maxtouchTool
//
//  Created by Katekov Anton on 8/3/16.
//  Copyright © 2016 katekovanton. All rights reserved.
//

#include "Texture.h"
#include "BitmapTexture.h"
#include "ByteBuffer.h"


//@implementation Texture
//
//- (instancetype)initWithImage:(NSImage*)image
//{
//    if (self = [super init]) {
//        
//        _imageRep = [[NSBitmapImageRep alloc] initWithData:[image TIFFRepresentation]];
//        _width = [_imageRep pixelsWide];
//        _heigth = [_imageRep pixelsHigh];
//    }
//    return self;
//}
//
//- (Color)colorAtPointX:(int)x y:(int)y
//{
//    NSUInteger values[4];
//    [_imageRep getPixel:values atX:x y:y];
//    return Color(values[0],values[1],values[2],values[3]);
//}
//
//@end



CPPITexture::~CPPITexture()
{}



CPPTextureImplPNGRep::CPPTextureImplPNGRep(const std::string &path)
{}

CPPTextureImplPNGRep::~CPPTextureImplPNGRep()
{}

int CPPTextureImplPNGRep::GetWidth()
{
    return _bitmap->_info._textureSize.width;
}

int CPPTextureImplPNGRep::GetHeight()
{
    return _bitmap->_info._textureSize.height;
}

Color CPPTextureImplPNGRep::GetColorAtPoint(GPoint2D point)
{
    int colorIndex = point.y * _width + point.x;
    int byteIndex = colorIndex * 4;
    if (GetBitmapData()[byteIndex + 3] > 1) {
        int a = 0;
        a++;
    }
    return Color(GetBitmapData()[byteIndex], GetBitmapData()[byteIndex + 1], GetBitmapData()[byteIndex + 2], GetBitmapData()[byteIndex + 3]);
}

unsigned char *CPPTextureImplPNGRep::GetBitmapData()
{
    return _bitmap->GetBuffer()->getPointer();
}


//@implementation TextureClipping
//
//- (instancetype)initWithTexture:(Texture*)texture
//{
//    if (self = [super init]) {
//        
//        _texture = texture;
//        _payloadFrame = GRect2DMake(0, 0, _texture.width, _texture.heigth);
//        
////        for (int y = 0; y < _texture.heigth; y++)
////        {
////            BOOL isLineTransparent = YES;
////            for (int x = 0; x < _texture.width; x++)
////            {
////                if ([_texture colorAtPointX:x y:y].a != 0) {
////                    isLineTransparent = NO;
////                    break;
////                }
////            }
////            if (!isLineTransparent) {
////                _payloadFrame.origin.y = y;
////                _payloadFrame.size.height = _texture.heigth - y;
////                break;
////            }
////        }
//
//    }
//    return self;
//}
//
//@end


inline bool __isTranparentForClipping(const Color &c) {
    return c.a > 1;
}

CPPTextureClipping::CPPTextureClipping(CPPITexture *texture, bool clip)
:_texture(texture)
{
    _payloadFrame = GRect2DMake(0, 0, _texture->GetWidth(), _texture->GetHeight());
    _fullFrame = _payloadFrame;
    if (clip) {
        CalculateClipping();
    }
}

void CPPTextureClipping::CalculateClipping()
{
    for (int y = 0; y < _texture->GetHeight(); y++)
    {
        bool isLineTransparent = true;
        for (int x = 0; x < _texture->GetWidth(); x++)
        {
            if (__isTranparentForClipping(_texture->GetColorAtPoint(GPoint2D(x, y)))) {
                isLineTransparent = false;
                break;
            }
        }
        if (!isLineTransparent) {
            _payloadFrame.origin.y = y;
            _payloadFrame.size.height = _texture->GetHeight() - y;
            break;
        }
    }
    int yToCut = 0;
    for (int y = _texture->GetHeight() - 1; y > _payloadFrame.origin.y; y--)
    {
        bool isLineTransparent = true;
        for (int x = 0; x < _texture->GetWidth(); x++)
        {
            if (__isTranparentForClipping(_texture->GetColorAtPoint(GPoint2D(x, y)))) {
                isLineTransparent = false;
                break;
            }
        }
        if (!isLineTransparent) {
            _payloadFrame.size.height -= yToCut;
            break;
        }
        yToCut ++;
    }
    
    for (int x = 0; x < _texture->GetWidth(); x++)
    {
        bool isLineTransparent = true;
        for (int y = _payloadFrame.origin.y; y < _payloadFrame.origin.y + _payloadFrame.size.height; y++)
        {
            if (__isTranparentForClipping(_texture->GetColorAtPoint(GPoint2D(x, y)))) {
                isLineTransparent = false;
                break;
            }
        }
        if (!isLineTransparent) {
            _payloadFrame.origin.x = x;
            _payloadFrame.size.width = _texture->GetWidth() - x;
            break;
        }
    }
    int xToCut = 0;
    for (int x = _texture->GetWidth() - 1; x > _payloadFrame.origin.x; x--)
    {
        bool isLineTransparent = true;
        for (int y = _payloadFrame.origin.y; y < _payloadFrame.origin.y + _payloadFrame.size.height; y++)
        {
            if (__isTranparentForClipping(_texture->GetColorAtPoint(GPoint2D(x, y)))) {
                isLineTransparent = false;
                break;
            }
        }
        if (!isLineTransparent) {
            _payloadFrame.size.width -= xToCut;
            break;
        }
        xToCut ++;
    }

}



//@implementation TextureClippingArray
//
//- (instancetype)initWithTextyreArray:(NSArray<Texture*>*)textures
//{
//    if (self = [super init]) {
//        NSMutableArray *textureClippings = [NSMutableArray array];
//        
//        for (int i = 0; i < textures.count; i++) {
//            TextureClipping *clipping = [[TextureClipping alloc] initWithTexture:textures[i]];
//            [textureClippings addObject:clipping];
//        }
//        
//        _textureClippings = textureClippings;
//        
//        GSize2D maxSize = GSize2DMake(0, 0);
//        for (int i = 0; i < _textureClippings.count; i++)
//        {
//            TextureClipping *clipping = _textureClippings[i];
//            if (maxSize.width < clipping.payloadFrame.size.width) {
//                maxSize.width = clipping.payloadFrame.size.width;
//            }
//            if (maxSize.height < clipping.payloadFrame.size.height) {
//                maxSize.height = clipping.payloadFrame.size.height;
//            }
//        }
//        _inclusiveSize = maxSize;
//        
//    }
//    return self;
//}
//
//- (GPoint2D)offsetForTexture:(int)texture;
//{
//    TextureClipping *clipping = _textureClippings[texture];
//    return clipping.payloadFrame.origin;
//}
//
//@end



CPPTextureClippingArray::CPPTextureClippingArray(const std::vector<CPPITexture *> &textures, bool clip)
{
    for (int i = 0; i < textures.size(); i++) {
        if (i == 49) {
            int a = 0;
            a++;
        }
        CPPTextureClipping *clipping = new CPPTextureClipping(textures[i], clip);
        _textureClippings.push_back(clipping);
    }
    
    BoundingBox bb;
    bb.min.x = textures[0]->GetWidth();
    bb.min.y = textures[0]->GetHeight();
    bb.max.x = 0;
    bb.max.y = 0;
    
    for (int i = 0; i < _textureClippings.size(); i++)
    {
        CPPTextureClipping *clipping = _textureClippings[i];
        BoundingBox payload = BoundingBoxMake(clipping->_payloadFrame);
        
        if (bb.max.x < payload.max.x) {
            bb.max.x = payload.max.x;
        }
        if (bb.max.y < payload.max.y) {
            bb.max.y = payload.max.y;
        }
        if (bb.min.x > payload.min.x) {
            bb.min.x = payload.min.x;
        }
        if (bb.min.y > payload.min.y) {
            bb.min.y = payload.min.y;
        }
    }
    
    _inclusiveBox = bb;
    _inclusiveRect = GRect2DMake(_inclusiveBox.min.x, _inclusiveBox.min.y, _inclusiveBox.max.x - _inclusiveBox.min.x, _inclusiveBox.max.y - _inclusiveBox.min.y);
}

CPPTextureClippingArray::~CPPTextureClippingArray()
{
    for (int i = 0; i < _textureClippings.size(); i++) {
        delete _textureClippings[i];
    }
}

GPoint2D CPPTextureClippingArray::GetOffsetForTexture(int texture)
{
    CPPTextureClipping *clipping = _textureClippings[texture];
    return clipping->_payloadFrame.origin;
}


