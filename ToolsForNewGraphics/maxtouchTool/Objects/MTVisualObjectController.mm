//
//  MTVisualObjectController.m
//  maxtouchTool
//
//  Created by Katekov Anton on 8/8/16.
//  Copyright © 2016 katekovanton. All rights reserved.
//

#import "MTVisualObjectController.h"
#import "MTVisualObject.h"
#import <AppKit/AppKit.h>
#import "Texture.h"
#import "ToolSettings.h"
#import <CoreImage/CoreImage.h>
#import "MTDiffuseComposer.h"
#import "MTShadowComposer.h"
#import "MTLightComposer.h"
#import "NSImage+Utils.h"
#include "CPPTextureImplNSBitmapImageRep.h"



#define TEX_INPUT_ALPHA       @"%@_s0.Alpha.png"
#define TEX_INPUT_DIFFUSE     @"%@_s0.diffuse.png"
#define TEX_INPUT_AO          @"%@_s0.extraTex_VRayDirt2.png"
#define TEX_INPUT_NORMALS     @"%@_s0.normals.png"
#define TEX_INPUT_STRIPES     @"COLOR_ARMY.diffuse.png"

#define TEX_INPUT_LIGHTING    @"%@_All_s%d.png"
#define TEX_INPUT_SHADOW      @"%@_s%d.matteShadow.matteShadow.png"


#define TEX_OUTPUT_DIFFUSE    @"diffuse.png"
#define TEX_OUTPUT_DIFFUSE_BIN    @"diffuse.bin"
#define TEX_OUTPUT_NORMALS    @"normals.png"
#define TEX_OUTPUT_STRIPES    @"stripes.png"
#define TEX_OUTPUT_SETTINGS    @"settings.json"
#define TEX_OUTPUT_SHADOW     @"shadow.bin"

#define TEX_OUTPUT_LIGHT      @"light_%d.bin"
//#define TEX_OUTPUT_SHADOW     @"shadow_%d.png"




@implementation MTVisualObjectSpriteData

- (instancetype)initWithInputPath:(NSString*)inputPath
                       outputPath:(NSString*)outputPath
                         baseName:(NSString*)baseName
                  lightingPattern:(NSString*)lightingPattern
                    shadowPattern:(NSString*)shadowPattern
                         rotation:(int)rotation
{
    if (self = [super init]) {
        _inputLighting = [inputPath stringByAppendingString:[NSString stringWithFormat:lightingPattern, baseName, rotation * 45]];
        _inputShadow = [inputPath stringByAppendingString:[NSString stringWithFormat:shadowPattern, baseName, rotation * 45]];
    }
    return self;
}

@end



@implementation MTVisualObjectData

- (instancetype)initWithInputPath:(NSString*)inputPath
                       outputPath:(NSString*)outputPath
                         baseName:(NSString*)baseName
                         settings:(NSDictionary*)settings
{
    if (self = [super init]) {
        _inputDiffuseAlpha = [inputPath stringByAppendingString:[NSString stringWithFormat:TEX_INPUT_ALPHA, baseName]];
        _inputDiffuse = [inputPath stringByAppendingString:[NSString stringWithFormat:TEX_INPUT_DIFFUSE, baseName]];
        _inputAO = [inputPath stringByAppendingString:[NSString stringWithFormat:TEX_INPUT_AO, baseName]];
        if (settings[@"aoPattern"] != nil) {
            _inputAO = settings[@"basename"];
            _inputAO = [inputPath stringByAppendingString:[_inputAO stringByAppendingString:settings[@"aoPattern"]]];
        }
        _inputNormals = [inputPath stringByAppendingString:[NSString stringWithFormat:TEX_INPUT_NORMALS, baseName]];
        _inputStripes = [inputPath stringByAppendingString:TEX_INPUT_STRIPES];
        
        _outputDiffuse = [outputPath stringByAppendingString:TEX_OUTPUT_DIFFUSE_BIN];
        _outputNormals = [outputPath stringByAppendingString:TEX_OUTPUT_NORMALS];
        _outputStripes = [outputPath stringByAppendingString:TEX_OUTPUT_STRIPES];
        _outputSettings = [outputPath stringByAppendingString:TEX_OUTPUT_SETTINGS];
        _outputShadow = [outputPath stringByAppendingString:TEX_OUTPUT_SHADOW];
        
        _outputLight = [outputPath stringByAppendingString:TEX_OUTPUT_LIGHT];
        
        NSString *lightingPattern = TEX_INPUT_LIGHTING;
        NSString *shadowPattern = TEX_INPUT_SHADOW;
        if (settings[@"colorPattern"] != nil) {
            lightingPattern = [@"%@" stringByAppendingString:settings[@"colorPattern"]];
        }
        if (settings[@"shadowPattern"] != nil) {
            shadowPattern = [@"%@" stringByAppendingString:settings[@"shadowPattern"]];
        }
        
        NSMutableArray *rotatedSpritesData = [NSMutableArray array];
        for (int i = 0; i < 8; i++)
        {
            MTVisualObjectSpriteData *spriteData =
            [[MTVisualObjectSpriteData alloc] initWithInputPath:inputPath
                                                     outputPath:outputPath
                                                       baseName:baseName
                                                lightingPattern:lightingPattern
                                                  shadowPattern:shadowPattern
                                                       rotation:i];
            
            [rotatedSpritesData addObject:spriteData];
            
        }
        _rotatedSpritesData = rotatedSpritesData;
        
    }
    return self;
}

@end



@interface MTVisualObjectController () {
    NSString *_inputDirectoryPath;
    NSString *_baseName;
    int _cells;
    float _shadowDisplacement;
    NSString *_outputFolderName;
    NSString *_outputFolderPath;
    
    NSDictionary *_settings;
}

@end



@implementation MTVisualObjectController

- (instancetype)initWithInputPath:(NSString*)inputPath
                       outputPath:(NSString*)outputPath
{
    if (self = [super init]) {
        
        _textureCache = [NSMutableDictionary dictionary];
        _inputDirectoryPath = inputPath;
        
        NSData *settingsData = [NSData dataWithContentsOfFile:[_inputDirectoryPath stringByAppendingString:@"/settings.json"]];
        _settings = [NSJSONSerialization JSONObjectWithData:settingsData options:0 error:nil];
        
        _baseName = _settings[@"basename"];
        _outputFolderName = _settings[@"outputFolder"];
        _cells = [_settings[@"cells"] intValue];
        _shadowDisplacement = [_settings[@"shadowDisplacement"] floatValue];
        _outputFolderPath = [outputPath stringByAppendingString:_outputFolderName];
        _outputFolderPath = [_outputFolderPath stringByAppendingString:@"/"];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:_outputFolderPath]) {
            [[NSFileManager defaultManager] removeItemAtPath:_outputFolderPath error:nil];
        }
        
        [[NSFileManager defaultManager] createDirectoryAtPath:_outputFolderPath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
        
        _data = [[MTVisualObjectData alloc] initWithInputPath:_inputDirectoryPath
                                                   outputPath:_outputFolderPath
                                                     baseName:_baseName
                                                     settings:_settings];
        
    }
    return self;
}

- (void)dowork:(MTOptions)options
{
    CPPITexture *textureDiffuseAlpha = NULL;
    CPPITexture *textureDiffuse = NULL;
    CPPITexture *textureAO = NULL;
    
    
    CGFloat gameCellSize = _cells * SINGLE_CELL_RESOLUTION;
    CGFloat graphicsCellSize = 0;
    
    NSMutableDictionary *settings = [NSMutableDictionary dictionary];
    [settings setObject:@(gameCellSize) forKey:@"cellSize"];
    
    
    @autoreleasepool {
        
        // TODO:
        // work throught TextureClipping object to clip transparent zones
        
        NSImage *diffuseImage = [[NSImage alloc] initWithContentsOfFile:_data.inputDiffuse];
        NSImage *diffuseAlphaImage = [[NSImage alloc] initWithContentsOfFile:_data.inputDiffuseAlpha];
        
        graphicsCellSize = diffuseImage.size.width / _cells;
        if (graphicsCellSize != gameCellSize) {
            diffuseImage = [NSImage resizeImage:diffuseImage size:NSMakeSize(gameCellSize, gameCellSize)];
            diffuseAlphaImage = [NSImage resizeImage:diffuseAlphaImage size:NSMakeSize(gameCellSize, gameCellSize)];
        }
        textureDiffuse = new CPPTextureImplNSBitmapImageRep(diffuseImage);
        textureDiffuseAlpha = new CPPTextureImplNSBitmapImageRep(diffuseAlphaImage);
        
        float darkenMultiplier = 1.0;
        if (_settings[@"darken"] != nil) {
            darkenMultiplier = [_settings[@"darken"] floatValue];
        }
//        [self saveImage:diffuseImage toPath:_data.outputDiffuse];
        MTDiffuseComposer *composer = [[MTDiffuseComposer alloc] initWithDiffuseTexture:textureDiffuse
                                                                    diffuseAlphaTexture:textureDiffuseAlpha];
        [composer buildDiffuseImageWithDarkenMultiplier:darkenMultiplier];
        [composer.resultImageData writeToFile:_data.outputDiffuse atomically:NO];
        
        
        diffuseImage = [[NSImage alloc] initWithContentsOfFile:_data.inputDiffuse];
        diffuseAlphaImage = [[NSImage alloc] initWithContentsOfFile:_data.inputDiffuseAlpha];
        delete textureDiffuse;
        delete textureDiffuseAlpha;
        textureDiffuse = new CPPTextureImplNSBitmapImageRep(diffuseImage);
        textureDiffuseAlpha = new CPPTextureImplNSBitmapImageRep(diffuseAlphaImage);
        
        
        {
            NSDictionary *diffuseInfo = @{@"sizeW" : @(gameCellSize),
                                          @"sizeH" : @(gameCellSize),
                                          @"offsetX" : @(0),
                                          @"offsetY" : @(0),
                                          @"anchorX" : @(gameCellSize/2),
                                          @"anchorY" : @(gameCellSize/2),
                                          @"premultiplied" : @(YES)
                                          };
            [settings setObject:diffuseInfo forKey:@"diffuseTexture"];
        }
    }
    
    @autoreleasepool {
        NSImage *aoImage = [[NSImage alloc] initWithContentsOfFile:_data.inputAO];
        textureAO = new CPPTextureImplNSBitmapImageRep(aoImage);
        
        if (graphicsCellSize != gameCellSize) {
            aoImage = [NSImage resizeImage:aoImage size:NSMakeSize(gameCellSize, gameCellSize)];
        }
    }
    
    @autoreleasepool {
        NSImage *normalsImage = [[NSImage alloc] initWithContentsOfFile:_data.inputNormals];
        
        if (normalsImage.size.width != gameCellSize) {
            normalsImage = [NSImage resizeImage:normalsImage size:NSMakeSize(gameCellSize, gameCellSize)];
            [self saveImage:normalsImage toPath:_data.outputNormals];
        }
        else {
            [[NSFileManager defaultManager] copyItemAtPath:_data.inputNormals toPath:_data.outputNormals error:nil];
        }
    }
    
    @autoreleasepool {
        
        // TODO:
        // work throught TextureClipping object to clip transparent zones
        
        NSImage *stripesImage = [[NSImage alloc] initWithContentsOfFile:_data.inputStripes];
        
        if (stripesImage != nil) {
            if (graphicsCellSize != gameCellSize) {
                stripesImage = [NSImage resizeImage:stripesImage size:NSMakeSize(gameCellSize, gameCellSize)];
                [self saveImage:stripesImage toPath:_data.outputStripes];
            }
            else {
                [[NSFileManager defaultManager] copyItemAtPath:_data.inputStripes toPath:_data.outputStripes error:nil];
            }
        }
        
        NSDictionary *diffuseInfo = @{@"sizeW" : @(gameCellSize),
                                      @"sizeH" : @(gameCellSize),
                                      @"offsetX" : @(0),
                                      @"offsetY" : @(0)};
        [settings setObject:diffuseInfo forKey:@"stripesTexture"];
    }
    
    
    // compress shadows to 1 texture
    @autoreleasepool {
        std::vector<CPPITexture *> shadowTextures;
        for (int i = 0; i < 8; i++)
        {
            MTVisualObjectSpriteData *spriteData = _data.rotatedSpritesData[i];
            @autoreleasepool {
                NSImage *shadowImage = [[NSImage alloc] initWithContentsOfFile:spriteData.inputShadow];
                if (_shadowDisplacement > 0)
                {
                    float angle = ((float)i * 45.0 + 20) * M_PI / 180.0;
                    NSPoint displacement = NSMakePoint(-sin(angle) * _shadowDisplacement, -cos(angle) * _shadowDisplacement);
                    shadowImage = [NSImage offsetImage:shadowImage delta:displacement backgroundColor:[NSColor blackColor]];
                }
                if (graphicsCellSize != gameCellSize) {
                    shadowImage = [NSImage resizeImage:shadowImage size:NSMakeSize(gameCellSize, gameCellSize)];
                }
                
                if (options.storeAdditionalPNG)
                {
                    NSString* shadowFilename = [NSString stringWithFormat:@"shadow_%i.png", i];
                    NSString* shadowFilepath = [[_data.outputShadow stringByDeletingLastPathComponent] stringByAppendingPathComponent:shadowFilename];
                    [self saveImage:shadowImage toPath:shadowFilepath];
                }
                
                CPPITexture *texture = new CPPTextureImplNSBitmapImageRep(shadowImage);
                shadowTextures.push_back(texture);
            }
            
        }
        MTShadowComposer *composer = [[MTShadowComposer alloc] initWithShadowTextures:shadowTextures];
        [composer buildShadowImage];
        [composer.resultImageData writeToFile:_data.outputShadow atomically:NO];
        
        
        NSMutableDictionary *shadowSettings = [NSMutableDictionary dictionary];
        [shadowSettings setObject:@(composer.resultImageSize.width) forKey:@"sizeW"];
        [shadowSettings setObject:@(composer.resultImageSize.height) forKey:@"sizeH"];
        
        NSMutableArray *offsets = [NSMutableArray array];
        for (int i = 0; i < composer.textureInfo.count; i++) {
            NSDictionary *data =  [composer.textureInfo[i] serialize];
            [offsets addObject:data];
        }
        [shadowSettings setObject:offsets forKey:@"channels"];
        [settings setObject:shadowSettings forKey:@"shadowTexture"];
        
        for (int i = 0; i < 8; i++) {
            delete shadowTextures[i];
        }
        
    }
    
    // compress lightings to 2 textures
    @autoreleasepool {
        
        std::vector<CPPITexture *>textures;
        for (int i = 0; i < 8; i++)
        {
            MTVisualObjectSpriteData *spriteData = _data.rotatedSpritesData[i];
            CPPITexture *textureLight = NULL;
            
            @autoreleasepool {
                NSImage *lightImage = [[NSImage alloc] initWithContentsOfFile:spriteData.inputLighting];
                textureLight = new CPPTextureImplNSBitmapImageRep(lightImage);
                if (graphicsCellSize != gameCellSize) {
                    lightImage = [NSImage resizeImage:lightImage size:NSMakeSize(gameCellSize, gameCellSize)];
                }
                
            }
            
            @autoreleasepool {
                MTVisualObject *object = [[MTVisualObject alloc] initWithDiffuseTextre:textureDiffuse
                                                                   duffuseAlphaTexture:textureDiffuseAlpha
                                                                          lightTexture:textureLight
                                                                              aoTextre:textureAO];
                [object buildShadowImageWithAoK:1 shadowK:1 diffuseK:1];
                
                
                NSImage *resultImage = object.resultShadowImage;
                if (graphicsCellSize != gameCellSize) {
                    resultImage = [NSImage resizeImage:resultImage size:NSMakeSize(gameCellSize, gameCellSize)];
                }
                
                if (options.storeAdditionalPNG)
                {
                    NSString* lightFilename = [NSString stringWithFormat:@"light_%i.png", i];
                    NSString* lightFilepath = [[_data.outputLight stringByDeletingLastPathComponent] stringByAppendingPathComponent:lightFilename];
                    [self saveImage:resultImage toPath:lightFilepath];
                }
                
                textures.push_back(new CPPTextureImplNSBitmapImageRep(resultImage));
            }
        }
        
        MTLightComposer *lightComposer = [[MTLightComposer alloc] initWithTextures:textures];
        
        
        NSMutableDictionary *lightTextureSettings = [NSMutableDictionary dictionary];
        
        @autoreleasepool {
            [lightComposer build];
            NSMutableArray *sources = [NSMutableArray array];
            for (int i = 0; i < lightComposer.textureInfo.count; i++) {
                [sources addObject:[lightComposer.textureInfo[i] serialize]];
            }
            [lightTextureSettings setObject:sources forKey:@"sources"];
        }
        
        [settings setObject:lightTextureSettings forKey:@"lightTexture"];
        
        [lightComposer.resultImage1Data writeToFile:[NSString stringWithFormat:_data.outputLight, 0] atomically:NO];
        [lightComposer.resultImage2Data writeToFile:[NSString stringWithFormat:_data.outputLight, 1] atomically:NO];
        
        for (int i = 0; i < 8; i++) {
            delete textures[i];
        }
        
    }
    
    if (textureDiffuseAlpha != NULL) {
        delete textureDiffuseAlpha;
    }
    if (textureDiffuse != NULL) {
        delete textureDiffuse;
    }
    if (textureAO != NULL) {
        delete textureAO;
    }
    
    NSData *settingsData = [NSJSONSerialization dataWithJSONObject:settings options:NSJSONWritingPrettyPrinted error:nil];
    [settingsData writeToFile:_data.outputSettings atomically:YES];
}

- (void)saveImage:(NSImage*)image toPath:(NSString*)path
{
    @autoreleasepool {
        NSData *imageData = [image TIFFRepresentation];
        NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
        
        [self saveImageRep:imageRep toPath:path];
    }
}

- (void)saveImageRep:(NSBitmapImageRep*)imageRep toPath:(NSString*)path
{
    NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:1.0] forKey:NSImageCompressionFactor];
    NSData *imageData = [imageRep representationUsingType:NSPNGFileType properties:imageProps];
    [imageData writeToFile:path atomically:NO];
}

@end
