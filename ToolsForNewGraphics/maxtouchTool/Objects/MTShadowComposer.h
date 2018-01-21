//
//  MTShadowComposer.h
//  maxtouchTool
//
//  Created by Katekov Anton on 8/13/16.
//  Copyright © 2016 katekovanton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#include <vector>



class CPPITexture;



@interface MTShadowTextureInfo : NSObject

@property (nonatomic) int offsetX;
@property (nonatomic) int offsetY;
@property (nonatomic) int sizeW;
@property (nonatomic) int sizeH;
@property (nonatomic) int anchorX;
@property (nonatomic) int anchorY;

- (NSDictionary*)serialize;

@end



@interface MTShadowComposer : NSObject

@property (nonatomic, readonly) NSMutableArray<MTShadowTextureInfo*> *textureInfo;
@property (nonatomic, readonly) NSData *resultImageData;
@property (nonatomic, readonly) CGSize resultImageSize;

- (instancetype)initWithShadowTextures:(const std::vector<CPPITexture *> &)shadowTextures;

- (void)buildShadowImage;

@end
