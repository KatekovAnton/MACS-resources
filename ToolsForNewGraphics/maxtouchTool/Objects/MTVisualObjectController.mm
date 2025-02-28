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
#define TEX_OUTPUT_SETTINGS   @"settings.json"
#define TEX_OUTPUT_SHADOW     @"shadow.bin"

#define TEX_OUTPUT_LIGHT      @"light_%d.bin"
#define TEX_PREVIEW_INDEX     0
#define TEX_PREVIEW_SIZE      256

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
        if (shadowPattern.length > 0) {
            _inputShadow = [inputPath stringByAppendingString:[NSString stringWithFormat:shadowPattern, baseName, rotation * 45]];
        }
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
        _objectType = MTVisualObjectType_DefaultUnit;
        _method = 0;
        if ([settings valueForKey:@"method"] != nil) {
            _method = [[settings valueForKey:@"method"] intValue];
        }
        
//        if ([settings valueForKey:@"type"] != nil) {
//            NSString *type = [[settings valueForKey:@"type"] stringValue];
//            
//        }
        
        _singleDirection = NO;
        _singleDirectionFrame = 0;
        if ([settings valueForKey:@"singleDirection"] != nil) {
            _singleDirection = [[settings valueForKey:@"singleDirection"] boolValue];
            _singleDirectionFrame = [[settings valueForKey:@"singleDirectionFrame"] integerValue];
            if (_singleDirection) {
                int a = 0;
                a++;
            }
        }
        
        
        _inputDiffuseAlpha = [inputPath stringByAppendingString:[NSString stringWithFormat:TEX_INPUT_ALPHA, baseName]];
        if (settings[@"alphaPattern"] != nil) {
            _inputDiffuseAlpha = settings[@"basename"];
            _inputDiffuseAlpha = [inputPath stringByAppendingString:[_inputDiffuseAlpha stringByAppendingString:settings[@"alphaPattern"]]];
        }
        
        _inputDiffuse = [inputPath stringByAppendingString:[NSString stringWithFormat:TEX_INPUT_DIFFUSE, baseName]];
        if (settings[@"diffusePattern"] != nil) {
            _inputDiffuse = settings[@"basename"];
            _inputDiffuse = [inputPath stringByAppendingString:[_inputDiffuse stringByAppendingString:settings[@"diffusePattern"]]];
        }
        
        _inputAO = [inputPath stringByAppendingString:[NSString stringWithFormat:TEX_INPUT_AO, baseName]];
        if (settings[@"aoPattern"] != nil) {
            _inputAO = settings[@"basename"];
            _inputAO = [inputPath stringByAppendingString:[_inputAO stringByAppendingString:settings[@"aoPattern"]]];
        }
        _inputNormals = [inputPath stringByAppendingString:[NSString stringWithFormat:TEX_INPUT_NORMALS, baseName]];
        if (settings[@"normalsPattern"] != nil) {
            _inputNormals = settings[@"basename"];
            _inputNormals = [inputPath stringByAppendingString:[_inputNormals stringByAppendingString:settings[@"normalsPattern"]]];
        }
        
        _scale = 1.0f;
        if (settings[@"scale"] != nil) {
            _scale = [settings[@"scale"] floatValue];
        }
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
            NSString *shadow = settings[@"shadowPattern"];
            if (![shadow isEqualToString:@"NONE"]) {
                shadowPattern = [@"%@" stringByAppendingString:shadow];
            }
            else {
                shadowPattern = @"";
            }
        }
        
        int startFrame = 0;
        int endFrame = 8;
        if (_singleDirection) {
            startFrame = _singleDirectionFrame;
            endFrame = _singleDirectionFrame + 1; 
        }
        NSMutableArray *rotatedSpritesData = [NSMutableArray array];
        for (int i = startFrame; i < endFrame; i++)
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

- (NSString *)outputDiffusePNG {
    return [self.outputDiffuse stringByAppendingString:@".png"];
}

@end



@interface MTVisualObjectController () {
    NSString *_inputDirectoryPath;
    NSString *_baseName;
    int _cells;
    bool _cutShadow;
    float _cutShadowThreshold;
    float _shadowDisplacement;
    NSString *_outputFolderName;
    NSString *_outputFolderPath;
    
    NSDictionary *_settings;
}

@end

// etank - 1.3
//#define TMPSCALE 1.0
@implementation MTVisualObjectController

- (instancetype)initWithInputPath:(NSString*)inputPath
                       outputPath:(NSString*)outputPath
{
    if (self = [super init]) {
        
        _cutShadow = false;
        _cutShadowThreshold = 0.4f;
        _textureCache = [NSMutableDictionary dictionary];
        _inputDirectoryPath = inputPath;
        
        NSData *settingsData = [NSData dataWithContentsOfFile:[_inputDirectoryPath stringByAppendingString:@"/settings.json"]];
        _settings = [NSJSONSerialization JSONObjectWithData:settingsData options:0 error:nil];
        
        _baseName = _settings[@"basename"];
        _outputFolderName = _settings[@"outputFolder"];
        _cells = [_settings[@"cells"] intValue];
        if ([_settings valueForKey:@"cutShadow"] != nil) {
            _cutShadow = [[_settings valueForKey:@"cutShadow"] boolValue];
        }
        if ([_settings valueForKey:@"cutShadowThreshold"] != nil) {
            _cutShadowThreshold = [[_settings valueForKey:@"cutShadowThreshold"] floatValue];
        }
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

- (NSImage *)imageWithPath:(NSString *)path scale:(float)scale
{
    NSImage *original = [[NSImage alloc] initWithContentsOfFile:path];
    NSImage *result = original;
    if (fabs(scale - 1.0) > 0.01) {        
        result = [NSImage scaleImageContent:original scale:scale];
    }
    return result;
}

- (void)dowork:(MTOptions)options
{
    CPPITexture *textureDiffuseAlpha = NULL;
    CPPITexture *textureDiffuse = NULL;
    CPPITexture *textureAO = NULL;
    
    
    CGFloat neededGraphicsSize = _cells * SINGLE_CELL_RESOLUTION;
    CGFloat graphicsCellSize = 0;
    bool rescale = false;
    
    int startFrame = 0;
    int endFrame = 8;
    if (_data.singleDirection) {
        startFrame = _data.singleDirectionFrame;
        endFrame = _data.singleDirectionFrame + 1; 
    }
    
    NSMutableDictionary *settings = [NSMutableDictionary dictionary];
    [settings setObject:@(SINGLE_CELL_RESOLUTION) forKey:@"cellSize"];
    [settings setObject:@(_data.singleDirection) forKey:@"singleDirection"];
    
    float darkenMultiplier = 1.0;
    if (_settings[@"darken"] != nil) {
        darkenMultiplier = [_settings[@"darken"] floatValue];
    }
    
    @autoreleasepool {
        
        // TODO:
        // work throught TextureClipping object to clip transparent zones
        
        assert([[NSFileManager defaultManager] fileExistsAtPath:_data.inputDiffuse]);
        assert([[NSFileManager defaultManager] fileExistsAtPath:_data.inputDiffuseAlpha]);
        
        NSImage *diffuseImage = [self imageWithPath:_data.inputDiffuse scale:_data.scale];
        NSImage *diffuseAlphaImage = [self imageWithPath:_data.inputDiffuseAlpha scale:_data.scale];
        
        graphicsCellSize = diffuseImage.size.width / _cells;
        rescale = graphicsCellSize != SINGLE_CELL_RESOLUTION;
        float multiplier = 1.0;
        if (rescale) {
            diffuseImage = [NSImage resizeImage:diffuseImage byScalingItToSize:NSMakeSize(neededGraphicsSize, neededGraphicsSize)];
            diffuseAlphaImage = [NSImage resizeImage:diffuseAlphaImage byScalingItToSize:NSMakeSize(neededGraphicsSize, neededGraphicsSize)];
            multiplier = graphicsCellSize / neededGraphicsSize;
        }
        textureDiffuse = new CPPTextureImplNSBitmapImageRep(diffuseImage);
        textureDiffuseAlpha = new CPPTextureImplNSBitmapImageRep(diffuseAlphaImage);
        
        // convert child slots
        {
            NSArray *childSlots = _settings[@"childSlots"];
            if (childSlots != nil)
            {
                NSMutableArray *newChildSlots = [NSMutableArray new];
                for (NSDictionary *childSlot in childSlots)
                {
                    NSMutableDictionary *newChildSlot = [NSMutableDictionary new];
                    float offsetX = [childSlot[@"offsetX"] floatValue];
                    float offsetY = [childSlot[@"offsetY"] floatValue];
                    offsetX /= multiplier;
                    offsetY /= multiplier;
                    newChildSlot[@"offsetX"] = [NSNumber numberWithInteger:offsetX];
                    newChildSlot[@"offsetY"] = [NSNumber numberWithInteger:offsetY];
                    newChildSlot[@"type"] = childSlot[@"type"];
                    [newChildSlots addObject:newChildSlot];
                }
                [settings setObject:newChildSlots forKey:@"childSlots"];
            }
        }
        // copy children to the output
        {
            NSArray *children = _settings[@"children"];
            if (children != nil)
            {
                NSMutableArray *newChildren = [NSMutableArray new];
                for (NSDictionary *child in children)
                {
                    NSMutableDictionary *newChild = [child mutableCopy];
                    [newChildren addObject:newChild];
                }
                [settings setObject:newChildren forKey:@"children"];
            }
        }
//        [self saveImage:diffuseImage toPath:_data.outputDiffuse];
        MTDiffuseComposer *composer = [[MTDiffuseComposer alloc] initWithDiffuseTexture:textureDiffuse
                                                                    diffuseAlphaTexture:textureDiffuseAlpha];
        NSImage *diffuse = [composer buildDiffuseImageWithDarkenMultiplier:darkenMultiplier method:_data.method save:YES];
        [self saveImage:diffuse toPath:_data.outputDiffusePNG];
        [composer.resultImageData writeToFile:_data.outputDiffuse atomically:NO];
        
        assert([[NSFileManager defaultManager] fileExistsAtPath:_data.inputDiffuse]);
        assert([[NSFileManager defaultManager] fileExistsAtPath:_data.inputDiffuseAlpha]);
        diffuseImage = [self imageWithPath:_data.inputDiffuse scale:_data.scale];
        diffuseAlphaImage = [self imageWithPath:_data.inputDiffuseAlpha scale:_data.scale];
        delete textureDiffuse;
        delete textureDiffuseAlpha;
        textureDiffuse = new CPPTextureImplNSBitmapImageRep(diffuseImage);
        textureDiffuseAlpha = new CPPTextureImplNSBitmapImageRep(diffuseAlphaImage);
        
        
        {
            NSDictionary *diffuseInfo = @{@"sizeW" : @(neededGraphicsSize),
                                          @"sizeH" : @(neededGraphicsSize),
                                          @"offsetX" : @(0),
                                          @"offsetY" : @(0),
                                          @"anchorX" : @(neededGraphicsSize/2),
                                          @"anchorY" : @(neededGraphicsSize/2),
                                          @"premultiplied" : @(NO)
                                          };
            [settings setObject:diffuseInfo forKey:@"diffuseTexture"];
        }
    }
    
    @autoreleasepool {
        assert([[NSFileManager defaultManager] fileExistsAtPath:_data.inputAO]);
        NSImage *aoImage = [self imageWithPath:_data.inputAO scale:_data.scale];
        textureAO = new CPPTextureImplNSBitmapImageRep(aoImage);
        
        if (rescale) {
            aoImage = [NSImage resizeImage:aoImage byScalingItToSize:NSMakeSize(neededGraphicsSize, neededGraphicsSize)];
        }
    }
    
    @autoreleasepool {
        assert([[NSFileManager defaultManager] fileExistsAtPath:_data.inputNormals]);
        NSImage *normalsImage = [self imageWithPath:_data.inputNormals scale:_data.scale];
        
        if (rescale) {
            normalsImage = [NSImage resizeImage:normalsImage byScalingItToSize:NSMakeSize(neededGraphicsSize, neededGraphicsSize)];
            [self saveImage:normalsImage toPath:_data.outputNormals];
        }
        else {
            [[NSFileManager defaultManager] copyItemAtPath:_data.inputNormals toPath:_data.outputNormals error:nil];
        }
    }
    
    @autoreleasepool {
        
        // TODO:
        // work throught TextureClipping object to clip transparent zones
        if ([[NSFileManager defaultManager] fileExistsAtPath:_data.inputStripes]) {
            NSImage *stripesImage = [self imageWithPath:_data.inputStripes scale:_data.scale];
            
            if (stripesImage != nil) {
                if (rescale) {
                    stripesImage = [NSImage resizeImage:stripesImage byScalingItToSize:NSMakeSize(neededGraphicsSize, neededGraphicsSize)];
                    [self saveImage:stripesImage toPath:_data.outputStripes];
                }
                else {
                    [[NSFileManager defaultManager] copyItemAtPath:_data.inputStripes toPath:_data.outputStripes error:nil];
                }
            }
        }
        NSDictionary *diffuseInfo = @{@"sizeW" : @(neededGraphicsSize),
                                      @"sizeH" : @(neededGraphicsSize),
                                      @"offsetX" : @(0),
                                      @"offsetY" : @(0)};
        [settings setObject:diffuseInfo forKey:@"stripesTexture"];
    }

    // compress shadows to 1 texture
    @autoreleasepool {
        std::vector<CPPITexture *> shadowTextures;
        bool shadowsCreated = true;
        for (int i = startFrame; i < endFrame; i++)
        {
            MTVisualObjectSpriteData *spriteData = _data.rotatedSpritesData[i - startFrame];
            if (spriteData.inputShadow == nil) {
                shadowsCreated = false;
                break;
            }
            @autoreleasepool {
                assert([[NSFileManager defaultManager] fileExistsAtPath:spriteData.inputShadow]);
                NSImage *shadowImage = [self imageWithPath:spriteData.inputShadow scale:_data.scale];
                if (_shadowDisplacement > 0)
                {
                    float angle = ((float)i * 45.0 + 20) * M_PI / 180.0;
                    NSPoint displacement = NSMakePoint(-sin(angle) * _shadowDisplacement, -cos(angle) * _shadowDisplacement);
                    shadowImage = [NSImage offsetImage:shadowImage delta:displacement backgroundColor:[NSColor blackColor]];
                }
                if (rescale) {
                    shadowImage = [NSImage resizeImage:shadowImage byScalingItToSize:NSMakeSize(neededGraphicsSize, neededGraphicsSize)];
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
        if (shadowsCreated)
        {
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
            
            for (int i = 0; i < shadowTextures.size(); i++) {
                delete shadowTextures[i];
            }
        }
        
    }
    
    // compress lightings to 2 textures
    @autoreleasepool {
        
        std::vector<CPPITexture *>textures;
        for (int i = startFrame; i < endFrame; i++)
        {
            MTVisualObjectSpriteData *spriteData = _data.rotatedSpritesData[i - startFrame];
            CPPITexture *textureLight = NULL;
            
            @autoreleasepool {
                assert([[NSFileManager defaultManager] fileExistsAtPath:spriteData.inputLighting]);
                NSImage *lightImage = [self imageWithPath:spriteData.inputLighting scale:_data.scale];
                textureLight = new CPPTextureImplNSBitmapImageRep(lightImage);
                if (rescale) {
                    lightImage = [NSImage resizeImage:lightImage byScalingItToSize:NSMakeSize(neededGraphicsSize, neededGraphicsSize)];
                }
                
            }
            
            @autoreleasepool {
                MTVisualObject *object = [[MTVisualObject alloc] initWithDiffuseTextre:textureDiffuse
                                                                   duffuseAlphaTexture:textureDiffuseAlpha
                                                                          lightTexture:textureLight
                                                                              aoTextre:textureAO];
                [object buildShadowImageWithAoK:1 shadowK:1 diffuseK:1 cutShadow:_cutShadow cutShadowThreshold:_cutShadowThreshold];
                
                if (i == TEX_PREVIEW_INDEX || _data.singleDirection) {
                    
                    NSImage *tmp_diffuseImage = [[NSImage alloc] initWithContentsOfFile:_data.outputDiffusePNG];
                    
                    NSImage *tmp_diffuseAlphaImage = [self imageWithPath:_data.inputDiffuseAlpha scale:_data.scale];
                    tmp_diffuseAlphaImage = [NSImage resizeImage:tmp_diffuseAlphaImage byScalingItToSize:NSMakeSize(neededGraphicsSize, neededGraphicsSize)];
                    
                    NSImage *tmp_lightImage = [self imageWithPath:spriteData.inputLighting scale:_data.scale];
                    tmp_lightImage = [NSImage resizeImage:tmp_lightImage byScalingItToSize:NSMakeSize(neededGraphicsSize, neededGraphicsSize)];
                    
                    NSImage *tmp_aoImage = [self imageWithPath:_data.inputAO scale:_data.scale];
                    tmp_aoImage = [NSImage resizeImage:tmp_aoImage byScalingItToSize:NSMakeSize(neededGraphicsSize, neededGraphicsSize)];
                    
                    CPPITexture *tmp_textureDiffuse = new CPPTextureImplNSBitmapImageRep(tmp_diffuseImage);
                    CPPITexture *tmp_textureDiffuseAlpha = new CPPTextureImplNSBitmapImageRep(tmp_diffuseAlphaImage);
                    CPPITexture *tmp_textureLight = new CPPTextureImplNSBitmapImageRep(tmp_lightImage);
                    CPPITexture *tmp_textureAO = new CPPTextureImplNSBitmapImageRep(tmp_aoImage);
                    
                    MTVisualObject *object = [[MTVisualObject alloc] initWithDiffuseTextre:tmp_textureDiffuse
                                                                       duffuseAlphaTexture:tmp_textureDiffuseAlpha
                                                                              lightTexture:tmp_textureLight
                                                                                  aoTextre:tmp_textureAO];
                    CPPITexture *tmp_shadowTexture = nullptr;
                    if (spriteData.inputShadow != nil) {
                        assert([[NSFileManager defaultManager] fileExistsAtPath:spriteData.inputShadow]);
                        NSImage *tmp_shadowImage = [self imageWithPath:spriteData.inputShadow scale:_data.scale];
                        tmp_shadowImage = [NSImage resizeImage:tmp_shadowImage byScalingItToSize:NSMakeSize(neededGraphicsSize, neededGraphicsSize)];
                        tmp_shadowTexture = new CPPTextureImplNSBitmapImageRep(tmp_shadowImage);
                    }
                    NSImage *previewImage = [object buildFullImageWithAoK:1.3 shadowK:1 diffuseK:darkenMultiplier shadow:tmp_shadowTexture];
                    previewImage = [NSImage resizeImage:previewImage byScalingItToSize:NSMakeSize(TEX_PREVIEW_SIZE, TEX_PREVIEW_SIZE)];
                    
                    NSString* filename = @"preview.png";
                    NSString* filepath = [[_data.outputLight stringByDeletingLastPathComponent] stringByAppendingPathComponent:filename];
                    [self saveImage:previewImage toPath:filepath];
                    
                    delete tmp_textureDiffuse;
                    delete tmp_textureDiffuseAlpha;
                    delete tmp_textureLight;
                    delete tmp_textureAO;
                    if (tmp_shadowTexture) {
                        delete tmp_shadowTexture;
                    }
                }
                
                NSImage *resultImage = object.resultShadowImage;
                if (rescale) {
                    resultImage = [NSImage resizeImage:resultImage byScalingItToSize:NSMakeSize(neededGraphicsSize, neededGraphicsSize)];
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
        
        if (lightComposer.resultImage1Data != nil) {
            [lightComposer.resultImage1Data writeToFile:[NSString stringWithFormat:_data.outputLight, 0] atomically:NO];
        }
        if (lightComposer.resultImage2Data != nil) {
            [lightComposer.resultImage2Data writeToFile:[NSString stringWithFormat:_data.outputLight, 1] atomically:NO];
        }
        
        for (int i = 0; i < textures.size(); i++) {
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
//        [image lockFocus];
//        NSBitmapImageRep *imageRep = [[NSBitmapImageRep alloc] initWithFocusedViewRect:NSMakeRect(0.0, 0.0, image.size.width, image.size.height)];
//        [image unlockFocus];
        
//        NSData *imageData = [image TIFFRepresentation];
//        NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
        
        CGImageRef cgRef = [image CGImageForProposedRect:NULL context:nil hints:nil];
        NSBitmapImageRep *imageRep = [[NSBitmapImageRep alloc] initWithCGImage:cgRef];
        
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
