//
//  MainWindow.m
//  maxtouchTool
//
//  Created by Katekov Anton on 8/3/16.
//  Copyright © 2016 katekovanton. All rights reserved.
//

#import "MainWindow.h"
#import "MTVisualObject.h"
#import "MTVisualObjectController.h"
#import "MTBlastProcessor.h"
#import "MTSequenceFrameSubstractor.h"

#include "CPPTextureImplNSBitmapImageRep.h"
#include "BitmapComposer.hpp"
#include "MTVisualObject.h"
#include "LibpngWrapper.h"
#include "ByteBuffer.h"
#include "MTProcessSettings.h"
#import "MTVisualObject.h"
#include "MCImage.hpp"



@implementation MainWindow

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    MTVisualObject *object = [[MTVisualObject alloc] initWithDiffuseName:@"SCBase_s0.diffuse"
                                                        duffuseAlphaName:@"SCBase_s0.Alpha"
                                                               lightName:@"SCBase_s0"
                                                             stripesName:@"TankBase_p0.ARMY"
                                                                  aoName:@"SCBase_s0.extraTex_VRayDirt2"];
    
//    MTVisualObject *object = [[MTVisualObject alloc] initWithDiffuseName:@"Turret_p0.diffuse"
//                                                        duffuseAlphaName:@"Turret_s0.Alpha"
//                                                               lightName:@"Turret_ALL_s0"
//                                                             stripesName:@"TankBase_p0.ARMY"
//                                                                  aoName:@"TankTurret_p0.extraTex_VRayDirt2"];
    [object buildResultImageWithAoK:1.0 shadowK:1.0 diffuseK:1.0];
    [self presentObject:object];
    
    NSString *str = [[NSBundle mainBundle] pathForResource:@"SCBase_s0" ofType:@"png"];
    str = str;
    
    MCImage image(str.UTF8String);
    int a = image._heigth;
}

- (void)presentObject:(MTVisualObject*)object
{
    _imageDiffuse.image = object.resultDiffuseImage;
    _imageShadow.image = object.resultShadowImage;
    _imageResult.image = object.resultImage;
}

//- (IBAction)onProcessVideo:(id)sender {
//    NSString *path = @"/Users/katekovanton/Desktop/untitled folder 4/frame14.png";
//    NSString *substractingPath = @"/Users/katekovanton/Desktop/untitled folder 4/frame170.png";
//
//    MTSequenceFrameSubstractor *substractor = [[MTSequenceFrameSubstractor alloc] initWithFramePath:path substractingFramePath:substractingPath];
//    [substractor dowork];
//}

// test composing 2 textures in one atlas and save it to png
- (IBAction)onTest:(id)sender
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSString *path = @"/Users/katekovanton/Documents/Projects/maxtouchresources/EffectsInput/explosion_large/body/10.png";
        NSImage *image = [[NSImage alloc] initWithContentsOfFile:path];
        CPPITexture *t = new CPPTextureImplNSBitmapImageRep(image);
        CPPTextureClipping *c = new CPPTextureClipping(t, true);
        BitmapComposer *comp = new BitmapComposer(GSize2D(c->_payloadFrame.size.width * 2, c->_payloadFrame.size.height * 2));
        comp->insertTexture(c, GPoint2D(0, 0));
        comp->insertTexture(c, GPoint2D(c->_payloadFrame.size.width, c->_payloadFrame.size.height));

        ByteBuffer b;
        LibpngWrapper::BitmapTextureToByteBuffer(comp->GetBitmapTexture(), &b);
        NSData *imageData = [NSData dataWithBytes:b.getPointer() length:b.getDataSize()];
        [imageData writeToFile:@"/Users/katekovanton/Desktop/test.png" atomically:NO];        
        
        
        delete t;
        delete c;
        delete comp;
        
    });
}

- (IBAction)onButchProcess:(id)sender
{
    MTProcessSettings *settings = [MTProcessSettings requestSettingsForType:@"units"];
    if (settings == nil) {
        return;
    }
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *fileList = [manager contentsOfDirectoryAtPath:settings.inputPath error:nil];
    NSMutableArray *directories = [NSMutableArray array];
    for (NSString *s in fileList)
    {
        BOOL isDirectory = NO;
        NSString *fullPath = [settings.inputPath stringByAppendingString:s];
        [[NSFileManager defaultManager] fileExistsAtPath:fullPath isDirectory:&isDirectory];
        if (isDirectory) {
            [directories addObject:[fullPath stringByAppendingString:@"/"]];
        }
    }
    
    MTOptions options;
    options.storeAdditionalPNG = (_checkboxExportAdditionalPNGs.state == 1);
    [self processDirectories:directories toOutputDirectory:settings.outputPath options:options];
}

- (void)processDirectories:(NSArray*)directories toOutputDirectory:(NSString*)outputDirectory options:(MTOptions)options
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        for (NSString *path in directories) {
            MTVisualObjectController *controller = [[MTVisualObjectController alloc] initWithInputPath:path outputPath:outputDirectory];
            [controller dowork:options];
        }
        
//        NSURL *url = [NSURL URLWithString:@"outputDirectory"];
//        [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[ url ]];
    });
}

- (IBAction)onButchProcessEffects:(id)sender
{
    MTProcessSettings *settings = [MTProcessSettings requestSettingsForType:@"effects"];
    if (settings == nil) {
        return;
    }
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *fileList = [manager contentsOfDirectoryAtPath:settings.inputPath error:nil];
    NSMutableArray *directories = [NSMutableArray array];
    for (NSString *s in fileList)
    {
        BOOL isDirectory = NO;
        NSString *fullPath = [settings.inputPath stringByAppendingString:s];
        [[NSFileManager defaultManager] fileExistsAtPath:fullPath isDirectory:&isDirectory];
        if (isDirectory) {
            [directories addObject:[fullPath stringByAppendingString:@"/"]];
        }
    }
    
    [self processEffectDirectories:directories toOutputDirectory:settings.outputPath];
}

- (IBAction)onProcessVideo:(id)sender {
    
    MTProcessSettings *settings = [MTProcessSettings requestSettingsForType:@"sequence"];
    if (settings == nil) {
        return;
    }
    NSMutableArray *directories = [NSMutableArray array];
    [directories addObject:settings.inputPath];
    
    [self processEffectDirectories:directories toOutputDirectory:settings.outputPath];
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
    NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:0.7] forKey:NSImageCompressionFactor];
    NSData *imageData = [imageRep representationUsingType:NSJPEGFileType properties:imageProps];
    [imageData writeToFile:path atomically:NO];
}



- (void)processEffectDirectories:(NSArray*)directories toOutputDirectory:(NSString*)outputDirectory
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        for (NSString *path in directories) {
            MTBlastProcessor *processor = [[MTBlastProcessor alloc] initWithInputPath:path outputPath:outputDirectory];
            [processor dowork];
        }
    });
}

- (IBAction)OnTestCodeGeneration:(id)sender
{
    NSString *inputPath = nil;
    @autoreleasepool {
        {
            
            NSOpenPanel *panel = [[NSOpenPanel alloc] init];
            [panel setCanChooseFiles:NO];
            [panel setCanChooseDirectories:YES];
            [panel setAllowsMultipleSelection:NO];
            
            NSInteger clicked = [panel runModal];
            
            if (clicked != NSFileHandlingPanelOKButton)
                return;
            
            inputPath = panel.URL.absoluteString;
            inputPath = [inputPath substringFromIndex:7];
        }
    }
    
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *fileList = [manager contentsOfDirectoryAtPath:inputPath error:nil];
    
    
    NSString *basePath = [inputPath stringByReplacingOccurrencesOfString:@"/Users/katekovanton/Documents/Projects/MWRender/data/" withString:@""];
    NSString *formatString = @"[testUtils addCard: -1 Type: CARDTYPE_GUIDE Tex: @\"%@\"\n\
                                Gloss: @\"assets/textures/common/cards/bankgloss.png\"\n\
                                Embo: @\"FFB74AFF\" Bg: nil];";
    for (NSString *string in fileList) {
        NSString *path = [basePath stringByAppendingString:string];
        NSString *resultString = [NSString stringWithFormat:formatString, path];
        printf("%s\n", [resultString UTF8String]);
    }
    
}

@end







