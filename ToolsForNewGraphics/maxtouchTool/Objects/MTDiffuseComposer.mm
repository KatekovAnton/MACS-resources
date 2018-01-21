//
//  MTDiffuseComposer.m
//  maxtouchTool
//
//  Created by Katekov Anton on 11/7/16.
//  Copyright © 2016 katekovanton. All rights reserved.
//

#import "MTDiffuseComposer.h"
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

- (void)buildDiffuseImage
{
    CPPTextureClipping *clipping = new CPPTextureClipping(_diffuseAlphaTexture, false);
    BitmapComposer *composer = new BitmapComposer(clipping->_payloadFrame.size);
    for (int x = 0; x < clipping->_payloadFrame.size.width; x++) {
        for (int y = 0; y < clipping->_payloadFrame.size.height; y++) {
            
            int cx = clipping->_payloadFrame.origin.x + x;
            int cy = clipping->_payloadFrame.origin.y + y;
            Color colorDiffuse = _diffuseTexture->GetColorAtPoint(GPoint2D(cx, cy));
            Color colorDiffuseAlpha = _diffuseAlphaTexture->GetColorAtPoint(GPoint2D(cx, cy));
            Color colorResult = Color(colorDiffuse.r,
                                      colorDiffuse.g,
                                      colorDiffuse.b,
                                      colorDiffuseAlpha.a);
            ColorF colorResultF(colorResult);
            float alpha = colorResultF.a;
            colorResultF = ColorFMultScalar(colorResultF, alpha);
            colorResult = colorResultF.getColor();
            composer->setColor(colorResult, cx, cy);
        }
    }
    
    int size = composer->getSize().width * composer->getSize().height * 4;
    ByteBuffer buffer;
    zip_compress((char *)composer->getColorBuffer(), size, &buffer);
    delete composer;
    _resultImageData = [[NSData alloc] initWithBytes:buffer.getPointer() length:buffer.getDataSize()];
}

@end
