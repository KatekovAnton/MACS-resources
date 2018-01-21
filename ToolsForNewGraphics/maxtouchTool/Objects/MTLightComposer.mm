//
//  MTLightComposer.m
//  maxtouchTool
//
//  Created by Katekov Anton on 8/18/16.
//  Copyright © 2016 katekovanton. All rights reserved.
//

#import "MTLightComposer.h"
#import "Texture.h"
#import "Utils.h"
#include "BitmapComposer.hpp"
#include "BitmapTexture.h"
#include "ByteBuffer.h"
#include "LibpngWrapper.h"
#include "ZipWrapper.h"



@implementation MTLightTextureChannelInfo

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



@implementation MTLightTextureInfo

- (NSDictionary*)serialize
{
    NSMutableArray *channels = [NSMutableArray array];
    for (int i = 0; i < _channelInfo.count; i++) {
        [channels addObject:[_channelInfo[i] serialize]];
    }
    
    return @{@"sizeW" : @(_sizeW),
             @"sizeH" : @(_sizeH),
             @"channels" : channels};
}

@end



@interface MTLightComposer () {
    std::vector<CPPITexture *> _textures;
}

@end



@implementation MTLightComposer

- (instancetype)initWithTextures:(const std::vector<CPPITexture *> &)textures;
{
    if (self = [super init]) {
        assert(textures.size() == 8);
        _textures = textures;
    }
    return self;
}

- (void)build
{
    BitmapComposer *composers[2] = {NULL, NULL};
    
    std::vector<CPPTextureClippingArray*> clippingArrays;
    {
        std::vector<CPPITexture *> textures = {_textures[0], _textures[1], _textures[2], _textures[3]};
        
        CPPTextureClippingArray *clipping = new CPPTextureClippingArray(textures);
        clippingArrays.push_back(clipping);
        composers[0] = new BitmapComposer(clippingArrays[0]->_inclusiveSize);
    }
    {
        std::vector<CPPITexture *> textures = {_textures[4], _textures[5], _textures[6], _textures[7]};
        
        CPPTextureClippingArray *clipping = new CPPTextureClippingArray(textures);
        clippingArrays.push_back(clipping);
        composers[1] = new BitmapComposer(clippingArrays[1]->_inclusiveSize);
    }
    
    _textureInfo = [NSMutableArray array];
    for (int i = 0; i < clippingArrays.size(); i++)
    {
        CPPTextureClippingArray *clippingArray = clippingArrays[i];
        MTLightTextureInfo *info = [MTLightTextureInfo new];
        info.sizeW = clippingArray->_inclusiveSize.width;
        info.sizeH = clippingArray->_inclusiveSize.height;
        
        info.channelInfo = [NSMutableArray array];
        for (int channel = 0; channel < clippingArray->_textureClippings.size(); channel++)
        {
            CPPTextureClipping *clipping = clippingArray->_textureClippings[channel];
            MTLightTextureChannelInfo *channelInfo = [MTLightTextureChannelInfo new];
            channelInfo.offsetX = clipping->_payloadFrame.origin.x;
            channelInfo.offsetY = clipping->_payloadFrame.origin.y;
            channelInfo.sizeW = clipping->_payloadFrame.size.width;
            channelInfo.sizeH = clipping->_payloadFrame.size.height;
            channelInfo.anchorX = clipping->_texture->GetWidth() / 2 - clipping->_payloadFrame.origin.x;
            channelInfo.anchorY = clipping->_texture->GetHeight() / 2 - clipping->_payloadFrame.origin.y;
            // anchorX anchorY is center of initial image in coordinates of payload frame
            [info.channelInfo addObject:channelInfo];
        }
        [_textureInfo addObject:info];
    }
    
    for (int j = 0; j < clippingArrays.size(); j++)
    {
        CPPTextureClippingArray *clippingArray = clippingArrays[j];
        
        for (int x = 0; x < clippingArray->_inclusiveSize.width; x++) {
            for (int y = 0; y < clippingArray->_inclusiveSize.height; y++) {
                
                Color resultColor = Color(0, 0, 0, 0);
                for (int i = 0; i < clippingArray->_textureClippings.size(); i++) {
                    
                    CPPTextureClipping *clipping = clippingArray->_textureClippings[i];
                    Color color = clipping->_texture->GetColorAtPoint(GPoint2D(x + clipping->_payloadFrame.origin.x,
                                                                               y + clipping->_payloadFrame.origin.y));
                    
                    if (i == 0)
                        resultColor.r = color.r;
                    else if (i == 1)
                        resultColor.g = color.r;
                    else if (i == 2)
                        resultColor.b = color.r;
                    else if (i == 3)
                        resultColor.a = color.r;
                }
                
                composers[j]->setColor(resultColor, x, y);
            }
        }
    }
    
    for (int i = 0; i < 2; i++)
    {
        int size = composers[i]->getSize().width * composers[i]->getSize().height * 4;
        ByteBuffer buffer;
        zip_compress((char *)composers[i]->getColorBuffer(), size, &buffer);
        delete composers[i];
        if (i == 0)
            _resultImage1Data = [[NSData alloc] initWithBytes:buffer.getPointer() length:buffer.getDataSize()];
        else
            _resultImage2Data = [[NSData alloc] initWithBytes:buffer.getPointer() length:buffer.getDataSize()];
    }
}

@end
