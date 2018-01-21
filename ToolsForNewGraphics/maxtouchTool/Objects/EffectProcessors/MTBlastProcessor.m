//
//  MTBlastProcessor.m
//  maxtouchTool
//
//  Created by Katekov Anton on 11/16/16.
//  Copyright © 2016 katekovanton. All rights reserved.
//

#import "MTBlastProcessor.h"
#import "NSImage+Utils.h"



@implementation MTEffectProcessorTask

@end



@interface MTEffectProcessorTaskImage : NSObject

@property (nonatomic) NSString *inputPath;
@property (nonatomic) NSString *outputPath;

@end

@implementation MTEffectProcessorTaskImage

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
        
        NSData *settingsData = [NSData dataWithContentsOfFile:[_inputDirectoryPath stringByAppendingString:@"/settings"]];
        NSDictionary *settings = [NSJSONSerialization JSONObjectWithData:settingsData options:0 error:nil];
        
        settings;
    });
    
    settings = settings;
    
    NSMutableArray *tasks = [NSMutableArray array];
    {
        NSString *cutType = settings[@"cutType"];
        if (cutType) {
            CGRect cutRectangle = ({
                CGRect result;
                NSDictionary *cutRectangleDict = settings[@"cutRectangle"];
                result.origin.x = [cutRectangleDict[@"x"] floatValue];
                result.origin.y = [cutRectangleDict[@"x"] floatValue];
                result.size.width = [cutRectangleDict[@"w"] floatValue];
                result.size.height = [cutRectangleDict[@"h"] floatValue];
                result;
            });
            
            if ([cutType isEqualToString:@"fromCenter"]) {
                MTEffectProcessorTask *task = [MTEffectProcessorTask new];
                CGFloat imageW = [settings[@"imageSizeW"] floatValue];
                CGFloat imageH = [settings[@"imageSizeH"] floatValue];
                task.rectInside = CGRectMake((imageW - cutRectangle.size.width) / 2,
                                             (imageH - cutRectangle.size.height) / 2,
                                             cutRectangle.size.width,
                                             cutRectangle.size.height);
                [tasks addObject:task];
            }
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
            for (int i = 0; i < count; i++) {
                NSString *imagePath = [NSString stringWithFormat:pattern, i + start];
                
                MTEffectProcessorTaskImage *item = [MTEffectProcessorTaskImage new];
                item.inputPath = [_inputDirectoryPath stringByAppendingString:imagePath];
                item.outputPath = [[_outputDirectoryPath stringByAppendingString:output] stringByAppendingString:imagePath];
                [images addObject:item];
            }
            if (images.count != 0) {
                MTEffectProcessorTaskImage *task = images[0];
                NSString *fullPath = task.outputPath;
                fullPath = [fullPath stringByDeletingLastPathComponent];
                
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
    
    for (MTEffectProcessorTaskImage *item in images) {
        for (MTEffectProcessorTask *task in tasks) {
            
            NSImage *image = [[NSImage alloc] initWithContentsOfFile:item.inputPath];
            NSImage *cropped = [NSImage cropImage:image toRect:task.rectInside];
            [NSImage saveImage:cropped toPath:item.outputPath];
        }
    }
    
    
    
    
}

@end
