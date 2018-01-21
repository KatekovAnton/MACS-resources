//
//  MTVisualObject.h
//  maxtouchTool
//
//  Created by Katekov Anton on 8/3/16.
//  Copyright © 2016 katekovanton. All rights reserved.
//

#import <Foundation/Foundation.h>



class CPPITexture;
class BitmapComposer;



@interface MTVisualObject : NSObject {
    
    BOOL _dealloc;
    
    CPPITexture *_diffuseAlphaTexture;
    CPPITexture *_diffuseTexture;
    CPPITexture *_lightTexture;
    CPPITexture *_stripesTexture;
    CPPITexture *_aoTexture;
}

@property (nonatomic, readonly) NSImage *resultDiffuseImage;
@property (nonatomic, readonly) NSImage *resultShadowImage;
@property (nonatomic, readonly) NSImage *resultImage;

// for test previews
- (instancetype)initWithDiffuseName:(NSString *)diffuseName
                   duffuseAlphaName:(NSString *)diffuseAlphaName
                          lightName:(NSString *)lightName
                        stripesName:(NSString *)stripesName
                             aoName:(NSString *)aoName;

// for batch processing
- (instancetype)initWithDiffuseFilePath:(NSString *)diffusePath
                   duffuseAlphaFilePath:(NSString *)diffuseAlphaPath
                          lightFilePath:(NSString *)lightPath
                             aoFilePath:(NSString *)aoPath;

- (instancetype)initWithDiffuseTextre:(CPPITexture *)diffuseTexture
                  duffuseAlphaTexture:(CPPITexture *)diffuseAlphaTexture
                         lightTexture:(CPPITexture *)lightTexture
                             aoTextre:(CPPITexture *)aoTexture;


- (void)buildResultImageWithAoK:(float)aoK shadowK:(float)shadowK diffuseK:(float)diffuseK;
- (void)buildShadowImageWithAoK:(float)aoK shadowK:(float)shadowK diffuseK:(float)diffuseK;

+ (NSImage *)resultImageWithBitmapComposer:(BitmapComposer *)composer;

@end
