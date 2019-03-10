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




@interface MTProcessSettings : NSObject

@property (nonatomic) NSString *inputPath;
@property (nonatomic) NSString *outputPath;

@end

@implementation MTProcessSettings

@end



@implementation MainWindow

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    MTVisualObject *object = [[MTVisualObject alloc] initWithDiffuseName:@"Turret_p0.diffuse"
                                                        duffuseAlphaName:@"Turret_s0.Alpha"
                                                               lightName:@"Turret_ALL_s0"
                                                             stripesName:@"TankBase_p0.ARMY"
                                                                  aoName:@"TankTurret_p0.extraTex_VRayDirt2"];
    [object buildResultImageWithAoK:1.0 shadowK:1.0 diffuseK:1.0];
    [self presentObject:object];
    
    
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

- (IBAction)onSave:(id)sender
{
    
    NSSavePanel *panel = [NSSavePanel savePanel];
    
    
    [panel setAllowedFileTypes:[NSArray arrayWithObject:@"png"]];
    NSInteger clicked = [panel runModal];
    
    if (clicked == NSFileHandlingPanelOKButton)
    {
        
        NSString *name = panel.URL.absoluteString;
        name = [name stringByReplacingOccurrencesOfString:@"file://" withString:@""];
        
        NSString *nameL = [name stringByReplacingOccurrencesOfString:@".png" withString:@"_light.png"];
        NSString *nameR = [name stringByReplacingOccurrencesOfString:@".png" withString:@"_result.png"];
        
        {
            NSData *imageData = [_imageShadow.image TIFFRepresentation];
            NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
            NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:1.0] forKey:NSImageCompressionFactor];
            imageData = [imageRep representationUsingType:NSPNGFileType properties:imageProps];
            [imageData writeToFile:nameL atomically:NO];
        }
        {
            NSData *imageData = [_imageResult.image TIFFRepresentation];
            NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
            NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:1.0] forKey:NSImageCompressionFactor];
            imageData = [imageRep representationUsingType:NSPNGFileType properties:imageProps];
            [imageData writeToFile:nameR atomically:NO];
        }
        
        
    }
}

- (MTProcessSettings*)requestSettingsForType:(NSString*)type
{
    MTProcessSettings *result = [MTProcessSettings new];
    
    
    @autoreleasepool {
        {
            
            NSOpenPanel *panel = [[NSOpenPanel alloc] init];
            [panel setCanChooseFiles:NO];
            [panel setCanChooseDirectories:YES];
            [panel setAllowsMultipleSelection:NO];
            
            NSString *key = [@"inputDir" stringByAppendingString:type];
            {
                NSString *url = [[NSUserDefaults standardUserDefaults] objectForKey:key];
                if (url)
                    [panel setDirectoryURL:[NSURL URLWithString:url]];
                
            }
            
            NSInteger clicked = [panel runModal];
            
            if (clicked != NSFileHandlingPanelOKButton)
                return nil;
            
            
            {
                [[NSUserDefaults standardUserDefaults] setObject:panel.URL.absoluteString
                                                          forKey:key];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            
            result.inputPath = panel.URL.absoluteString;
            result.inputPath = [result.inputPath substringFromIndex:7];
        }
    }
    
    @autoreleasepool {
        {
            NSOpenPanel *savePanel = [[NSOpenPanel alloc] init];
            [savePanel setCanCreateDirectories:YES];
            [savePanel setCanChooseDirectories:YES];
            [savePanel setCanChooseFiles:NO];
            [savePanel setAllowsMultipleSelection:NO];
            
            NSString *key = [@"outputDir" stringByAppendingString:type];
            {
                NSString *url = [[NSUserDefaults standardUserDefaults] objectForKey:key];
                if (url)
                    [savePanel setDirectoryURL:[NSURL URLWithString:url]];
                
            }
            
            NSInteger saveClicked = [savePanel runModal];
            if (saveClicked != NSFileHandlingPanelOKButton)
                return nil;
            
            {
                [[NSUserDefaults standardUserDefaults] setObject:savePanel.URL.absoluteString
                                                          forKey:key];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            
            result.outputPath = savePanel.URL.absoluteString;
            result.outputPath = [result.outputPath substringFromIndex:7];
        }
    }
    
    return result;
}

- (IBAction)onButchProcess:(id)sender
{
    MTProcessSettings *settings = [self requestSettingsForType:@"units"];
    
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
    });
}

- (IBAction)onButchProcessEffects:(id)sender
{
    MTProcessSettings *settings = [self requestSettingsForType:@"effects"];
    
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
    
    MTProcessSettings *settings = [self requestSettingsForType:@"sequence"];
    
    NSMutableArray *directories = [NSMutableArray array];
    [directories addObject:settings.inputPath];
    
    [self processEffectDirectories:directories toOutputDirectory:settings.outputPath];
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







