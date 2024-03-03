//
//  MTVisualObject.m
//  maxtouchTool
//
//  Created by Katekov Anton on 8/3/16.
//  Copyright © 2016 katekovanton. All rights reserved.
//

#import "MTVisualObject.h"
#include "Texture.h"
#import "Utils.h"
#include "BitmapComposer.hpp"
#include "BitmapTexture.h"
#include "CPPTextureImplNSBitmapImageRep.h"



@implementation MTVisualObject

- (instancetype)initWithDiffuseName:(NSString*)diffuseName
                   duffuseAlphaName:(NSString*)diffuseAlphaName
                          lightName:(NSString*)lightName
                        stripesName:(NSString*)stripesName
                             aoName:(NSString*)aoName
{
    if (self = [super init]) {
        
//        _diffuseAlphaTexture = [[Texture alloc] initWithImage:[NSImage imageNamed:diffuseAlphaName]];
//        _diffuseTexture = [[Texture alloc] initWithImage:[NSImage imageNamed:diffuseName]];
//        _lightTexture = [[Texture alloc] initWithImage:[NSImage imageNamed:lightName]];
//        if (stripesName != nil) {
//            _stripesTexture = [[Texture alloc] initWithImage:[NSImage imageNamed:stripesName]];
//        }
//        _aoTexture = [[Texture alloc] initWithImage:[NSImage imageNamed:aoName]];

        _diffuseAlphaTexture = new CPPTextureImplNSBitmapImageRep([NSImage imageNamed:diffuseAlphaName]);
        _diffuseTexture = new CPPTextureImplNSBitmapImageRep([NSImage imageNamed:diffuseName]);
        _lightTexture = new CPPTextureImplNSBitmapImageRep([NSImage imageNamed:lightName]);
        if (stripesName != nil) {
            _stripesTexture = new CPPTextureImplNSBitmapImageRep([NSImage imageNamed:stripesName]);
        }
        _aoTexture = new CPPTextureImplNSBitmapImageRep([NSImage imageNamed:aoName]);

        
        
        [self buildResultImageWithAoK:1.0 shadowK:1.0 diffuseK:1.0];
    }
    return self;
}

- (void)dealloc
{
    if (_dealloc) {
        delete _diffuseAlphaTexture;
        delete _diffuseTexture;
        delete _lightTexture;
        if (_stripesTexture != NULL) {
            delete _stripesTexture;
            _stripesTexture = NULL;
        }
        delete _aoTexture;
    }
    
}


- (instancetype)initWithDiffuseFilePath:(NSString*)diffusePath
                   duffuseAlphaFilePath:(NSString*)diffuseAlphaPath
                          lightFilePath:(NSString*)lightPath
                             aoFilePath:(NSString*)aoPath
{
    if (self = [super init]) {
        assert([[NSFileManager defaultManager] fileExistsAtPath:diffuseAlphaPath]);
        assert([[NSFileManager defaultManager] fileExistsAtPath:diffusePath]);
        assert([[NSFileManager defaultManager] fileExistsAtPath:lightPath]);
        assert([[NSFileManager defaultManager] fileExistsAtPath:aoPath]);
//        _diffuseAlphaTexture = [[Texture alloc] initWithImage:[[NSImage alloc] initWithContentsOfFile:diffuseAlphaPath]];
//        _diffuseTexture = [[Texture alloc] initWithImage:[[NSImage alloc] initWithContentsOfFile:diffusePath]];
//        _lightTexture = [[Texture alloc] initWithImage:[[NSImage alloc] initWithContentsOfFile:lightPath]];
//        _aoTexture = [[Texture alloc] initWithImage:[[NSImage alloc] initWithContentsOfFile:aoPath]];
        
        _dealloc = YES;
        _diffuseAlphaTexture = new CPPTextureImplNSBitmapImageRep([[NSImage alloc] initWithContentsOfFile:diffuseAlphaPath]);
        _diffuseTexture = new CPPTextureImplNSBitmapImageRep([[NSImage alloc] initWithContentsOfFile:diffusePath]);
        _lightTexture = new CPPTextureImplNSBitmapImageRep([[NSImage alloc] initWithContentsOfFile:lightPath]);
        _aoTexture = new CPPTextureImplNSBitmapImageRep([[NSImage alloc] initWithContentsOfFile:aoPath]);
        
    }
    return self;
}

- (instancetype)initWithDiffuseTextre:(CPPITexture*)diffuseTexture
                  duffuseAlphaTexture:(CPPITexture*)diffuseAlphaTexture
                         lightTexture:(CPPITexture*)lightTexture
                             aoTextre:(CPPITexture*)aoTexture
{
    if (self = [super init]) {
        
        _diffuseAlphaTexture = diffuseAlphaTexture;
        _diffuseTexture = diffuseTexture;
        if (_diffuseTexture == nullptr) {
            int a=  0;
            a++;
        }
        _lightTexture = lightTexture;
        _aoTexture = aoTexture;
        
    }
    return self;
}

- (void)buildResultImageWithAoK:(float)aoK shadowK:(float)shadowK diffuseK:(float)diffuseK
{
    BitmapComposer *composerDiffuse = new BitmapComposer(GSize2D(_diffuseTexture->GetWidth(), _diffuseTexture->GetHeight()));
    BitmapComposer *composerShadow = new BitmapComposer(GSize2D(_diffuseTexture->GetWidth(), _diffuseTexture->GetHeight()));
    BitmapComposer *composerResult = new BitmapComposer(GSize2D(_diffuseTexture->GetWidth(), _diffuseTexture->GetHeight()));

    
    ColorF armyColor = ColorF(0, 191, 255, 255.0);
    for (int x = 0; x < _diffuseTexture->GetWidth(); x++)
    {
        for (int y = 0; y < _diffuseTexture->GetHeight(); y++)
        {
            GPoint2D p(x, y);
            ColorF diffuse = ColorF(_diffuseTexture->GetColorAtPoint(p));
            ColorF light = ColorF(_lightTexture->GetColorAtPoint(p));
            ColorF stripe;
            if (_stripesTexture != NULL) {
                stripe = ColorF(_stripesTexture->GetColorAtPoint(p));
            }
            ColorF ao = ColorF(_aoTexture->GetColorAtPoint(p));
            
            ColorF pureLight = ColorFSubstract(light, diffuse);
            
            
//            ColorF diffuseWithAO = ColorFMultScalar(diffuse, (1.0 - (1.0 - ao.r) * aoK));
//            float diffuseLum = (diffuse.r + diffuse.g + diffuse.b) / 3.0;
//            float diffuseAOLum = (diffuseWithAO.r + diffuseWithAO.g + diffuseWithAO.b) / 3.0;
            pureLight = ColorFAddScalar(pureLight, (ao.r - 1) * 0.3);
            pureLight = ColorFMultScalar(pureLight, 0.5);
            pureLight = ColorFAddScalar(pureLight, 0.5);
            
//            pureLight.g = pureLight.r;
//            pureLight.b = pureLight.r;
            
            composerDiffuse->setColor(_diffuseTexture->GetColorAtPoint(p), x, y);
            
            ColorF resultShadow = pureLight;
            resultShadow.a = diffuse.a;// * light.a * ao.a;
            float value = (resultShadow.r + resultShadow.g + resultShadow.b) / 3.0;
            resultShadow.r = value;
            resultShadow.g = value;
            resultShadow.b = value;
            composerShadow->setColor(resultShadow.getColor(), x, y);
            
            ColorF resultDiffuse1 = ColorFMultScalar(diffuse, 1.0 - stripe.r);
            ColorF resultDiffuse2 = ColorFMultScalar(armyColor, stripe.r);
            ColorF resultDiffuseTotal = ColorFAdd(resultDiffuse1, resultDiffuse2);
            ColorF result = resultDiffuseTotal;//ColorFMultScalar(resultDiffuseTotal, diffuseK);
            ColorF shadow = resultShadow;
            shadow = ColorFAddScalar(shadow, -0.5);
            shadow = ColorFMultScalar(shadow, 2);
            shadow = ColorFAddScalar(shadow, -0.05);
//            shadow = ColorFMultScalar(shadow, 2);
            
            shadow = ColorFMultScalar(shadow, shadowK);
            result = ColorFAddScalar(result, shadow.r);
            result = ColorFMultScalar(result, 0.8);
//            result = ColorFMultScalar(result, 1.0 / diffuse.a);
            result = ColorFAdd(result, ColorFMultScalar(__ColorF(244, 223, 0, 255), 0.1));
            result.a = diffuse.a;// * light.a * ao.a;
            
            composerResult->setColor(result.getColor(), x, y);
        }
    }
    
    _resultDiffuseImage = [MTVisualObject resultImageWithBitmapComposer:composerDiffuse];
    _resultShadowImage = [MTVisualObject resultImageWithBitmapComposer:composerShadow];
    _resultImage = [MTVisualObject resultImageWithBitmapComposer:composerResult];
    delete composerDiffuse;
    delete composerShadow;
    delete composerResult;
}

- (void)buildShadowImageWithAoK:(float)aoK shadowK:(float)shadowK diffuseK:(float)diffuseK
{
    BitmapComposer *composerShadow = new BitmapComposer(GSize2D(_diffuseTexture->GetWidth(), _diffuseTexture->GetHeight()));
    
    for (int x = 0; x < _diffuseTexture->GetWidth(); x++)
    {
        for (int y = 0; y < _diffuseTexture->GetHeight(); y++)
        {
            GPoint2D p(x, y);
            ColorF diffuse = ColorF(_diffuseTexture->GetColorAtPoint(p));
            ColorF light = ColorF(_lightTexture->GetColorAtPoint(p));
            bool black = false;
            if (diffuse.r > 0.05 && light.r < 0.05) {
                black = true;
            }
            ColorF ao = ColorF(_aoTexture->GetColorAtPoint(p));
            
            diffuse = ColorFMultScalar(diffuse, diffuse.a);
            light = ColorFMultScalar(light, diffuse.a);
            ColorF pureLight = ColorFSubstract(light, diffuse);
            

//            ColorF diffuseWithAO = ColorFMultScalar(diffuse, (1.0 - (1.0 - ao.r) * aoK));
//            float diffuseLum = (diffuse.r + diffuse.g + diffuse.b) / 3.0;
//            float diffuseAOLum = (diffuseWithAO.r + diffuseWithAO.g + diffuseWithAO.b) / 3.0;
//            pureLight = ColorFAddScalar(pureLight, diffuseAOLum - diffuseLum);
            pureLight = ColorFAddScalar(pureLight, (ao.r - 1) * 0.3 * diffuse.a);
            pureLight = ColorFMultScalar(pureLight, 0.5);
            pureLight = ColorFAddScalar(pureLight, 0.5);
            
            pureLight.g = pureLight.r;
            pureLight.b = pureLight.r;
            
            ColorF resultShadow = pureLight;//ColorFMultScalar(pureLight, diffuse.a);
            resultShadow.a = 1.0;//diffuse.a * light.a;// * ao.a;
            float value = (resultShadow.r + resultShadow.g + resultShadow.b) / 3.0;
            if (black) {
                value += 0.19;
            }
            resultShadow.r = value;
            resultShadow.g = value;
            resultShadow.b = value;
            
            Color shadowColor = resultShadow.getColor();
            composerShadow->setColor(shadowColor, x, y);
        }
    }
    
    _resultShadowImage = [MTVisualObject resultImageWithBitmapComposer:composerShadow];
}

- (NSImage *)buildFullImageWithAoK:(float)aoK shadowK:(float)shadowK diffuseK:(float)diffuseK shadow:(CPPITexture *)shadow
{
    BitmapComposer *composerResult = new BitmapComposer(GSize2D(_diffuseTexture->GetWidth(), _diffuseTexture->GetHeight()));

    float shadowOpacity = 0.5;
    ColorF armyColor = ColorF(0, 191, 255, 255.0);
    for (int x = 0; x < _diffuseTexture->GetWidth(); x++)
    {
        for (int y = 0; y < _diffuseTexture->GetHeight(); y++)
        {
            GPoint2D p(x, y);
            Color sss = Color(0,0,0,0);
            if (shadow) {
                sss = shadow->GetColorAtPoint(p);
                sss = Color(0, 0, 0, sss.r * shadowOpacity);
            }
            
            
            ColorF diffuse = ColorF(_diffuseTexture->GetColorAtPoint(p));
            ColorF light = ColorF(_lightTexture->GetColorAtPoint(p));
            ColorF stripe;
            if (_stripesTexture != NULL) {
                stripe = ColorF(_stripesTexture->GetColorAtPoint(p));
            }
            ColorF ao = ColorF(_aoTexture->GetColorAtPoint(p));
            
            ColorF pureLight = ColorFSubstract(light, diffuse);
            pureLight = ColorFAddScalar(pureLight, (ao.r - 1) * 0.7);
            pureLight = ColorFMultScalar(pureLight, 0.5);
            pureLight = ColorFAddScalar(pureLight, 0.5);
        
            
            ColorF resultShadow = pureLight;
            resultShadow.a = diffuse.a;// * light.a * ao.a;
            float value = (resultShadow.r + resultShadow.g + resultShadow.b) / 3.0;
            resultShadow.r = value;
            resultShadow.g = value;
            resultShadow.b = value;
            
            ColorF resultDiffuse1 = ColorFMultScalar(diffuse, 1.08 - stripe.r);
            resultDiffuse1 = ColorFMultScalar(resultDiffuse1, diffuseK);
            ColorF resultDiffuse2 = ColorFMultScalar(armyColor, stripe.r);
            ColorF resultDiffuseTotal = ColorFAdd(resultDiffuse1, resultDiffuse2);
            ColorF result = resultDiffuseTotal;//ColorFMultScalar(resultDiffuseTotal, diffuseK);
            ColorF shadow = resultShadow;
            shadow = ColorFAddScalar(shadow, -0.5);
            shadow = ColorFMultScalar(shadow, 2);
            shadow = ColorFAddScalar(shadow, -0.05);
            
            shadow = ColorFMultScalar(shadow, shadowK);
            result = ColorFAddScalar(result, shadow.r);
            result = ColorFMultScalar(result, 0.8);
            result = ColorFAdd(result, ColorFMultScalar(__ColorF(244, 223, 0, 0), 0.13 * diffuse.a));
            result.a = diffuse.a;// * light.a * ao.a;
            
            result = ColorFAdd(ColorFMultScalar(ColorF(sss), 1.0 - result.a), result);
            
            composerResult->setColor(result.getColor(), x, y);
        }
    }
    
    NSImage *result = [MTVisualObject resultImageWithBitmapComposer:composerResult];
    delete composerResult;
    return result;
}

+ (NSImage*)resultImageWithBitmapComposer:(BitmapComposer*)composer
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    CGContextRef context = CGBitmapContextCreate(composer->getColorBuffer(),
                                                 composer->getSize().width,
                                                 composer->getSize().height,
                                                 8,
                                                 composer->getSize().width * 4,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedLast| kCGBitmapByteOrder32Big);
    
    CGImageRef image = CGBitmapContextCreateImage(context);
    NSImage* resultImage = [[NSImage alloc] initWithCGImage:image
                                                       size:NSMakeSize(composer->getSize().width, composer->getSize().height)];
    return resultImage;
}


@end
