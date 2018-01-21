//
//  MTLightComposer.h
//  maxtouchTool
//
//  Created by Katekov Anton on 8/18/16.
//  Copyright © 2016 katekovanton. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <vector>



class CPPITexture;




@interface MTLightTextureChannelInfo : NSObject

@property (nonatomic) int offsetX;
@property (nonatomic) int offsetY;
@property (nonatomic) int sizeW;
@property (nonatomic) int sizeH;
@property (nonatomic) int anchorX;
@property (nonatomic) int anchorY;

- (NSDictionary*)serialize;

@end



@interface MTLightTextureInfo : NSObject

@property (nonatomic) NSMutableArray<MTLightTextureChannelInfo*> *channelInfo;
@property (nonatomic) int sizeW;
@property (nonatomic) int sizeH;

- (NSDictionary*)serialize;

@end



@interface MTLightComposer : NSObject

@property (nonatomic, readonly) NSMutableArray<MTLightTextureInfo*> *textureInfo;
@property (nonatomic, readonly) NSData *resultImage1Data;
@property (nonatomic, readonly) NSData *resultImage2Data;

- (instancetype)initWithTextures:(const std::vector<CPPITexture *> &)textures;

- (void)build;

@end
