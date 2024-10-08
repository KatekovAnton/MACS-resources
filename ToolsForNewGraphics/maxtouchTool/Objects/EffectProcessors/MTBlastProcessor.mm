//
//  MTBlastProcessor.m
//  maxtouchTool
//
//  Created by Katekov Anton on 11/16/16.
//  Copyright © 2016 katekovanton. All rights reserved.
//

#import "MTBlastProcessor.h"
#import "NSImage+Utils.h"
#include "CPPTextureImplNSBitmapImageRep.h"
#include <vector>
#include "ToolPrefix.h"



@implementation MTEffectProcessorTask

@end



@interface MTEffectProcessorTaskImage : NSObject

@property (nonatomic) NSString *inputPath;
@property (nonatomic) NSString *outputPath;
@property (nonatomic) NSImage *image;

@end

@implementation MTEffectProcessorTaskImage

@end


@implementation MTEffectProcessorStep

- (NSArray *)doWork:(NSArray *)images
{
    return images;
}

@end

@implementation MTEffectProcessorStep_Resample

- (NSArray *)doWork:(NSArray *)images
{
    NSMutableArray *newImages = [NSMutableArray array];
    for (MTEffectProcessorTaskImage *item in images)
    {
        @autoreleasepool {
            NSImage *image = [[NSImage alloc] initWithContentsOfFile:item.inputPath];
            image = [NSImage resizeImage:image byScalingItToSize:NSMakeSize(1920 / self.decrease * [NSScreen mainScreen].backingScaleFactor, 1080 / self.decrease * [NSScreen mainScreen].backingScaleFactor)];
            
            MTEffectProcessorTaskImage *newItem = [MTEffectProcessorTaskImage new];
            newItem.image = image;
            newItem.outputPath = item.outputPath;
            [newImages addObject:newItem];
        }
        
    }
    return newImages;
}

@end

@implementation MTEffectProcessorStep_Resize

- (NSArray *)doWork:(NSArray *)images
{
    NSMutableArray *newImages = [NSMutableArray array];
    for (MTEffectProcessorTaskImage *item in images)
    {
        @autoreleasepool {
            NSImage *image = item.image;
            image = [NSImage resizeImage:image byScalingItToSize:NSMakeSize(_targetSize.width, _targetSize.height)];
            
            MTEffectProcessorTaskImage *newItem = [MTEffectProcessorTaskImage new];
            newItem.image = image;
            newItem.outputPath = item.outputPath;
            [newImages addObject:newItem];
        }
        
    }
    return newImages;
}

@end

@implementation MTEffectProcessorStep_CalculateCropRectangle

- (NSArray *)doWork:(NSArray *)images
{
    std::vector<CPPITexture *> textures;
 
    for (MTEffectProcessorTaskImage *item in images)
    {
        NSImage *image = item.image;
        if (image == nil) {
            image = [[NSImage alloc] initWithContentsOfFile:item.inputPath];
        }
        textures.push_back(new CPPTextureImplNSBitmapImageRep(image));
    }
    CPPTextureClippingArray *clipping = new CPPTextureClippingArray(textures, true);

    float scale = [NSScreen mainScreen].backingScaleFactor;
    self.onRectCalculated(CGRectMake(clipping->_inclusiveRect.origin.x / scale, clipping->_inclusiveRect.origin.y / scale, clipping->_inclusiveRect.size.width / scale, clipping->_inclusiveRect.size.height / scale));
    
    delete clipping;
    return images;
}

@end



@implementation MTEffectProcessorStep_CropImages

- (NSArray *)doWork:(NSArray *)images
{
    NSString *outputPath = nil;
    for (MTEffectProcessorTaskImage *item in images)
    {
        NSImage *image = item.image;
        if (image == nil) {
            image = [[NSImage alloc] initWithContentsOfFile:item.inputPath];
        }
        NSImage *cropped = [NSImage cropImage:image toRect:self.rectInside];
        [NSImage saveImage:cropped toPath:item.outputPath];
        item.image = cropped;
        outputPath = item.outputPath;
        
    }
    
    {
        #define TEX_OUTPUT_SETTINGS    @"settings.json"
        outputPath = [outputPath stringByDeletingLastPathComponent];
        NSString *outputSettingsPath = [outputPath stringByAppendingPathComponent:TEX_OUTPUT_SETTINGS];
        NSMutableDictionary *outputSettings = [NSMutableDictionary dictionary];
        
        outputSettings[@"cellSize"] = @(64);
        outputSettings[@"frameCount"] = @(images.count);
        if (self.tasks.count > 0) {
            MTEffectProcessorTask *task = self.tasks[0];
            NSMutableDictionary *d = [NSMutableDictionary new];
            d[@"premultiplied"] = @(true);
            d[@"sizeW"] = @(task.rectInside.size.width);
            d[@"sizeH"] = @(task.rectInside.size.height);
            d[@"offsetX"] = @(0);
            d[@"offsetY"] = @(0);
            d[@"anchorX"] = @(task.rectInside.size.width / 2);
            d[@"anchorY"] = @(task.rectInside.size.height / 2);
            outputSettings[@"diffuseTexture"] = d;
        }
        NSData *outputSettingsData = [NSJSONSerialization dataWithJSONObject:outputSettings options:NSJSONWritingPrettyPrinted error:nil];
        [outputSettingsData writeToFile:outputSettingsPath atomically:YES];
    }
    
    return images;
}

@end



@implementation MTEffectProcessorStep_SaveImages

- (NSArray *)doWork:(NSArray *)images
{
    NSString *outputPath = nil;
    for (MTEffectProcessorTaskImage *item in images)
    {
        NSImage *image = item.image;
        [NSImage saveImage:image toPath:item.outputPath];
        outputPath = item.outputPath;
    }
    
    {
        #define TEX_OUTPUT_SETTINGS    @"settings.json"
        outputPath = [outputPath stringByDeletingLastPathComponent];
        NSString *outputSettingsPath = [outputPath stringByAppendingPathComponent:TEX_OUTPUT_SETTINGS];
        NSMutableDictionary *outputSettings = [NSMutableDictionary dictionary];
        
        outputSettings[@"cellSize"] = @(64);
        outputSettings[@"frameCount"] = @(images.count);
        if (self.tasks.count > 0) {
            MTEffectProcessorTask *task = self.tasks[0];
            NSMutableDictionary *d = [NSMutableDictionary new];
            d[@"premultiplied"] = @(true);
            d[@"sizeW"] = @(task.rectInside.size.width);
            d[@"sizeH"] = @(task.rectInside.size.height);
            d[@"offsetX"] = @(0);
            d[@"offsetY"] = @(0);
            d[@"anchorX"] = @(task.rectInside.size.width / 2);
            d[@"anchorY"] = @(task.rectInside.size.height / 2);
            outputSettings[@"diffuseTexture"] = d;
        }
        NSData *outputSettingsData = [NSJSONSerialization dataWithJSONObject:outputSettings options:NSJSONWritingPrettyPrinted error:nil];
        [outputSettingsData writeToFile:outputSettingsPath atomically:YES];
    }
    
    return images;
}

@end



@implementation MTBlastProcessor

- (id)initWithInputPath:(NSString*)inputPath outputPath:(NSString*)outputPath
{
    if (self = [super init]) {
        _inputDirectoryPath = inputPath;
        _outputDirectoryPath = outputPath;
    }
    return self;
}

- (void)dowork
{
    NSDictionary *settings = ({
        
        NSData *settingsData = [NSData dataWithContentsOfFile:[_inputDirectoryPath stringByAppendingString:@"/settings.json"]];
        NSDictionary *settings = [NSJSONSerialization JSONObjectWithData:settingsData options:0 error:nil];
        
        settings;
    });
    
    settings = settings;
    
    NSMutableArray *steps = [NSMutableArray array];
    
    {
        NSString *cutType = settings[@"cutType"];
        if (cutType.length > 0)
        {
            if ([cutType isEqualToString:@"fromCenter"])
            {
                NSMutableArray *tasks = [NSMutableArray array];
                CGRect cutRectangle = ({
                    CGRect result;
                    NSDictionary *cutRectangleDict = settings[@"cutRectangle"];
                    result.origin.x = [cutRectangleDict[@"x"] floatValue];
                    result.origin.y = [cutRectangleDict[@"y"] floatValue];
                    result.size.width = [cutRectangleDict[@"w"] floatValue];
                    result.size.height = [cutRectangleDict[@"h"] floatValue];
                    result;
                });
                
                MTEffectProcessorTask *task = [MTEffectProcessorTask new];
                CGFloat imageW = [settings[@"imageSizeW"] floatValue];
                CGFloat imageH = [settings[@"imageSizeH"] floatValue];
                task.rectInside = CGRectMake((imageW - cutRectangle.size.width) / 2,
                                             (imageH - cutRectangle.size.height) / 2,
                                             cutRectangle.size.width,
                                             cutRectangle.size.height);
                [tasks addObject:task];
                
                MTEffectProcessorStep *step = [MTEffectProcessorStep_CropImages new];
                step.tasks = tasks;
            }
            else if ([cutType isEqualToString:@"frame"])
            {
                CGRect cutRectangle = ({
                    CGRect result;
                    NSDictionary *cutRectangleDict = settings[@"cutRectangle"];
                    result.origin.x = [cutRectangleDict[@"x"] floatValue];
                    result.origin.y = [cutRectangleDict[@"y"] floatValue];
                    result.size.width = [cutRectangleDict[@"w"] floatValue];
                    result.size.height = [cutRectangleDict[@"h"] floatValue];
                    result;
                });
                
                {
                    MTEffectProcessorStep_CropImages *step = [MTEffectProcessorStep_CropImages new];
                    step.rectInside = cutRectangle;   
                    [steps addObject:step];
                }
                
            }
            else if ([cutType isEqualToString:@"contents"])
            {
                {
                    NSMutableArray *tasks = [NSMutableArray array];
                    MTEffectProcessorTask *task = [MTEffectProcessorTask new];
                    task.type = MTEffectProcessorTaskType_None;
                    [tasks addObject:task];
                    
                    MTEffectProcessorStep_Resample *step = [MTEffectProcessorStep_Resample new];
                    step.decrease = 6;
                    step.tasks = tasks;
                    [steps addObject:step];
                }
                
                NSMutableArray *tasks1 = [NSMutableArray array];
                MTEffectProcessorTask *task1 = [MTEffectProcessorTask new];
                task1.type = MTEffectProcessorTaskType_None;
                [tasks1 addObject:task1];
                
                MTEffectProcessorStep_CalculateCropRectangle *step1 = [MTEffectProcessorStep_CalculateCropRectangle new];
                step1.tasks = tasks1;
                
                
                NSMutableArray *tasks2 = [NSMutableArray array];
                MTEffectProcessorTask *task2 = [MTEffectProcessorTask new];
                task2.type = MTEffectProcessorTaskType_CutRectangle;
                [tasks2 addObject:task2];
                
                MTEffectProcessorStep_CropImages *step2 = [MTEffectProcessorStep_CropImages new];
                step2.tasks = tasks2;
                
                WEAK(task2);
                step1.onRectCalculated = ^(CGRect rect) {
                    task2_weak_.rectInside = CGRectMake((int)(rect.origin.x + 0.5),
                                                        (int)(rect.origin.y + 0.5),
                                                        (int)rect.size.width,
                                                        (int)rect.size.height);
                };
                
                [steps addObject:step1];
                [steps addObject:step2];
            }
        }
        
        if ([settings valueForKey:@"targetSizeW"] != nil && [settings valueForKey:@"targetSizeH"] != nil)
        {
            int targetSizeW = [settings[@"targetSizeW"] intValue];
            int targetSizeH = [settings[@"targetSizeH"] intValue];
            
            MTEffectProcessorStep_Resize *taskResize = [MTEffectProcessorStep_Resize new];
            taskResize.targetSize = CGSizeMake(targetSizeW, targetSizeH);
            [steps addObject:taskResize];
        }
        
        {
            MTEffectProcessorStep_SaveImages *step = [MTEffectProcessorStep_SaveImages new];
            [steps addObject:step];
        }
    }
    
    NSMutableArray *images = [NSMutableArray array];
    {
        
        if ([settings[@"type"] isEqualToString:@"animatedFrames"]) {
            
            NSString *output = settings[@"outputFolder"];
            output = [output stringByAppendingString:@"/"];
            NSString *pattern = settings[@"framePattern"];
            pattern = [@"body/" stringByAppendingString:pattern];
            int start = [settings[@"frameIndexStart"] intValue];
            int count = [settings[@"frameCount"] intValue];
            int stride = [settings[@"frameStride"] intValue];
            NSString *outputPattern = settings[@"frameOutputPattern"];
            for (int i = 0; i < count; i++) {
                NSString *imagePath = [NSString stringWithFormat:pattern, i * stride + start];
                NSString *imageOutputPath = [NSString stringWithFormat:outputPattern, i];
                
                NSString *fullImagePath = [_inputDirectoryPath stringByAppendingString:imagePath];
                {
                    NSURL *url1 = [NSURL fileURLWithPath: fullImagePath];
                    NSURL *url2 = [url1 URLByResolvingSymlinksInPath];
                    fullImagePath = [[url2 absoluteString] substringFromIndex:7];
                }
                
                MTEffectProcessorTaskImage *item = [MTEffectProcessorTaskImage new];
                item.inputPath = fullImagePath;
                item.outputPath = [[[_outputDirectoryPath stringByAppendingString:output] stringByAppendingPathComponent:@"body"] stringByAppendingPathComponent:imageOutputPath];
                [images addObject:item];
            }
            if (images.count != 0) {
                MTEffectProcessorTaskImage *task = images[0];
                NSString *fullPath = task.outputPath;
                fullPath = [fullPath stringByDeletingLastPathComponent];
                fullPath = [fullPath stringByAppendingString:@"/"];
                if ([[NSFileManager defaultManager] fileExistsAtPath:fullPath]) {
                    [[NSFileManager defaultManager] removeItemAtPath:fullPath error:nil];
                }
                
                [[NSFileManager defaultManager] createDirectoryAtPath:fullPath
                                          withIntermediateDirectories:YES
                                                           attributes:nil
                                                                error:nil];
            }
        }
    }
    
    #define TEX_OUTPUT_SETTINGS    @"settings.json"
    NSString *outputPath = [_outputDirectoryPath stringByAppendingPathComponent:settings[@"outputFolder"]];
    NSString *outputSettingsPath = [outputPath stringByAppendingPathComponent:TEX_OUTPUT_SETTINGS];
    NSMutableDictionary *outputSettings = [NSMutableDictionary dictionary];
    
    NSArray *currentImagesArray = images;
    for (MTEffectProcessorStep *step in steps)
    {
        currentImagesArray = [step doWork:currentImagesArray];
    }
    
    outputSettings[@"_renderType"] = @(1);
    outputSettings[@"_frameCount"] = settings[@"frameCount"];
    
    NSArray *array = @[@"idle"];
    outputSettings[@"_body"] = @{ @"_states" : array };
    
    NSData *outputSettingsData = [NSJSONSerialization dataWithJSONObject:outputSettings options:NSJSONWritingPrettyPrinted error:nil];
    [outputSettingsData writeToFile:outputSettingsPath atomically:YES];
    
}

@end
