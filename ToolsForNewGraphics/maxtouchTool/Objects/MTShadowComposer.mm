//
//  MTShadowComposer.m
//  maxtouchTool
//
//  Created by Katekov Anton on 8/13/16.
//  Copyright © 2016 katekovanton. All rights reserved.
//

#import "MTShadowComposer.h"
#import "Texture.h"
#import "Utils.h"
#include "BitmapComposer.hpp"
#include "BitmapTexture.h"
#include "ByteBuffer.h"
#include "LibpngWrapper.h"
#include "ZipWrapper.h"



@implementation MTShadowTextureInfo

- (NSDictionary*)serialize
{
    return @{@"offsetX" : @(_offsetX),
             @"offsetY" : @(_offsetY),
             @"sizeW" : @(_sizeW),
             @"sizeH" : @(_sizeH),
             @"anchorX" : @(_anchorX),
             @"anchorY" : @(_anchorY)};
}

@end



@interface MTShadowComposer () {
//    NSArray *_shadowTextures;
    std::vector<CPPITexture *> _shadowTextures;
}

@end



@implementation MTShadowComposer

- (instancetype)initWithShadowTextures:(const std::vector<CPPITexture *> &)shadowTextures
{
    if (self = [super init]) {
        assert(shadowTextures.size() == 8);
        _shadowTextures = shadowTextures;
    }
    return self;
}

- (void)buildShadowImage
{
    CPPTextureClippingArray *clippings = new CPPTextureClippingArray(_shadowTextures);
    BitmapComposer *composer = new BitmapComposer(clippings->_inclusiveRect.size);
    _resultImageSize = CGSizeMake(composer->getSize().width, composer->getSize().height);
    
    _textureInfo = [NSMutableArray array];
    for (int i = 0; i < clippings->_textureClippings.size(); i++) {
        
        CPPTextureClipping *clipping = clippings->_textureClippings[i];
        
        MTShadowTextureInfo *info = [MTShadowTextureInfo new];
        info.offsetX = clipping->_payloadFrame.origin.x;
        info.offsetY = clipping->_payloadFrame.origin.y;
        info.sizeW = clipping->_payloadFrame.size.width;
        info.sizeH = clipping->_payloadFrame.size.height;
        info.anchorX = clipping->_texture->GetWidth() / 2 - clipping->_payloadFrame.origin.x;
        info.anchorY = clipping->_texture->GetHeight() / 2 - clipping->_payloadFrame.origin.y;
        // anchorX anchorY is center of initial image in coordinates of payload frame
        [_textureInfo addObject:info];
    }
    
    
    for (int x = 0; x < clippings->_inclusiveRect.size.width; x++) {
        for (int y = 0; y < clippings->_inclusiveRect.size.height; y++) {
            
            Color resultColor = Color(0,0,0,0);
            
            {
                CPPTextureClipping *c1 = clippings->_textureClippings[0];
                CPPTextureClipping *c2 = clippings->_textureClippings[1];
                
                unsigned char result = [self compressValue1:c1->_texture->GetColorAtPoint(GPoint2D(x+c1->_payloadFrame.origin.x,
                                                                                                   y+c1->_payloadFrame.origin.y)).r
                                                     value2:c2->_texture->GetColorAtPoint(GPoint2D(x+c2->_payloadFrame.origin.x,
                                                                                                   y+c2->_payloadFrame.origin.y)).r];
                resultColor.r = result;
            }
            {
                CPPTextureClipping *c1 = clippings->_textureClippings[2];
                CPPTextureClipping *c2 = clippings->_textureClippings[3];
                
                unsigned char result = [self compressValue1:c1->_texture->GetColorAtPoint(GPoint2D(x+c1->_payloadFrame.origin.x,
                                                                                                   y+c1->_payloadFrame.origin.y)).r
                                                     value2:c2->_texture->GetColorAtPoint(GPoint2D(x+c2->_payloadFrame.origin.x,
                                                                                                   y+c2->_payloadFrame.origin.y)).r];
                resultColor.g = result;
            }
            {
                CPPTextureClipping *c1 = clippings->_textureClippings[4];
                CPPTextureClipping *c2 = clippings->_textureClippings[5];
                
                unsigned char result = [self compressValue1:c1->_texture->GetColorAtPoint(GPoint2D(x+c1->_payloadFrame.origin.x,
                                                                                                   y+c1->_payloadFrame.origin.y)).r
                                                     value2:c2->_texture->GetColorAtPoint(GPoint2D(x+c2->_payloadFrame.origin.x,
                                                                                                   y+c2->_payloadFrame.origin.y)).r];
                resultColor.b = result;
            }
            {
                CPPTextureClipping *c1 = clippings->_textureClippings[6];
                CPPTextureClipping *c2 = clippings->_textureClippings[7];
                
                unsigned char result = [self compressValue1:c1->_texture->GetColorAtPoint(GPoint2D(x+c1->_payloadFrame.origin.x,
                                                                                                   y+c1->_payloadFrame.origin.y)).r
                                                     value2:c2->_texture->GetColorAtPoint(GPoint2D(x+c2->_payloadFrame.origin.x,
                                                                                                   y+c2->_payloadFrame.origin.y)).r];
                resultColor.a = result;
            }
            composer->setColor(resultColor, x, y);
        }
    }
//    int frame = 5;//0...7
//    int color = frame / 2;//0...3
//    int shader = frame % 2;//0,1
    
    
    int size = composer->getSize().width * composer->getSize().height * 4;
//    _resultImageData = [[NSData alloc] initWithBytes:composer->getColorBuffer() length:size];
    
    ByteBuffer testbuffer;
    zip_compress((char *)composer->getColorBuffer(), size, &testbuffer);
    delete composer;
    _resultImageData = [[NSData alloc] initWithBytes:testbuffer.getPointer() length:testbuffer.getDataSize()];
    
    
}

- (unsigned char)compressValue1:(unsigned char)value1 value2:(unsigned char)value2
{
    if (value1 < 128 && value2 < 128)
        return 0;
    if (value1 > 128 && value2 < 128)
        return 77;
    if (value1 < 128 && value2 > 128)
        return 153;
    if (value1 > 128 && value2 > 128)
        return 255;
    
    return 0;
}


//- (void)testDecode {
//    
//    // reading first texture value
//    printf("reading 1st texture:\n");
//    float coef = 1;
//    [self decodeValue:0 coef:coef];
//    printf(" no \n");
//    [self decodeValue:0.3 coef:coef];
//    printf(" yes \n");
//    [self decodeValue:0.6 coef:coef];
//    printf(" no \n");
//    [self decodeValue:1.0 coef:coef];
//    printf(" yes \n");
//    
//    printf("\n\nreading 2nd texture:\n");
//    
//    coef = 0;
//    [self decodeValue:0 coef:coef];
//    printf(" no \n");
//    [self decodeValue:0.3 coef:coef];
//    printf(" no \n");
//    [self decodeValue:0.6 coef:coef];
//    printf(" yes \n");
//    [self decodeValue:1.0 coef:coef];
//    printf(" yes \n");
//}
//
//- (void)decodeValue:(float)value coef:(float)coef
//{
//    float value1 = (0.6 - value) * value;
//    value1 = value1 * value1;
//    value1 = value1 * 255;
//    value1 = value1 * coef;
//
//    float value2 = (value - 0.5)*10. * (1.0 - coef);
//    
//    float result = value1 + value2;
//    printf("%f", result);
//    
//}

@end
