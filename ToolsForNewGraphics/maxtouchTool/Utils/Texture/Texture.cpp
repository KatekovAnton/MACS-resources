//
//  Texture.cpp
//  maxtouchTool
//
//  Created by Katekov Anton on 8/3/16.
//  Copyright © 2016 katekovanton. All rights reserved.
//

#import "Texture.h"



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




CPPTextureClipping::CPPTextureClipping(CPPITexture *texture, bool clip)
:_texture(texture)
{
    if (clip) {
        CalculateClipping();
    }
    else {
        _payloadFrame = GRect2DMake(0, 0, _texture->GetWidth(), _texture->GetHeight());
    }
    
}

void CPPTextureClipping::CalculateClipping()
{
    for (int y = 0; y < _texture->GetHeight(); y++)
    {
        bool isLineTransparent = true;
        for (int x = 0; x < _texture->GetWidth(); x++)
        {
            if (_texture->GetColorAtPoint(GPoint2D(x, y)).a != 0) {
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
    for (int y = _texture->GetHeight() - 1; y > _payloadFrame.origin.y; y--)
    {
        bool isLineTransparent = true;
        for (int x = 0; x < _texture->GetWidth(); x++)
        {
            if (_texture->GetColorAtPoint(GPoint2D(x, y)).a != 0) {
                isLineTransparent = false;
                break;
            }
        }
        if (!isLineTransparent) {
            _payloadFrame.size.height -= _texture->GetHeight() - 1 - y;
            break;
        }
    }
    
    for (int x = 0; x < _texture->GetWidth(); x++)
    {
        bool isLineTransparent = true;
        for (int y = _payloadFrame.origin.y; y < _payloadFrame.origin.y + _payloadFrame.size.height; y++)
        {
            if (_texture->GetColorAtPoint(GPoint2D(x, y)).a != 0) {
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
    for (int x = _texture->GetWidth() - 1; x > _payloadFrame.origin.x; x--)
    {
        bool isLineTransparent = true;
        for (int y = _payloadFrame.origin.y; y < _payloadFrame.origin.y + _payloadFrame.size.height; y++)
        {
            if (_texture->GetColorAtPoint(GPoint2D(x, y)).a != 0) {
                isLineTransparent = false;
                break;
            }
        }
        if (!isLineTransparent) {
            _payloadFrame.size.width -= _texture->GetWidth() - 1 - x;
            break;
        }
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



CPPTextureClippingArray::CPPTextureClippingArray(const std::vector<CPPITexture *> &textures)
{
    
    for (int i = 0; i < textures.size(); i++) {
        CPPTextureClipping *clipping = new CPPTextureClipping(textures[i], false);
        _textureClippings.push_back(clipping);
    }
    
    GSize2D maxSize = GSize2DMake(0, 0);
    for (int i = 0; i < _textureClippings.size(); i++)
    {
        CPPTextureClipping *clipping = _textureClippings[i];
        if (maxSize.width < clipping->_payloadFrame.size.width) {
            maxSize.width = clipping->_payloadFrame.size.width;
        }
        if (maxSize.height < clipping->_payloadFrame.size.height) {
            maxSize.height = clipping->_payloadFrame.size.height;
        }
    }
    _inclusiveSize = maxSize;
    

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


