//
//  MTBlastProcessor.h
//  maxtouchTool
//
//  Created by Katekov Anton on 11/16/16.
//  Copyright © 2016 katekovanton. All rights reserved.
//

#import <Foundation/Foundation.h>



typedef NS_ENUM(NSUInteger, MTEffectProcessorTaskType) {
    MTEffectProcessorTaskType_None,
    MTEffectProcessorTaskType_CutRectangle,
};



@interface MTEffectProcessorTask : NSObject

@property (nonatomic) MTEffectProcessorTaskType type;
@property (nonatomic) CGRect rectInside;

@end



// Base class
@interface MTEffectProcessorStep : NSObject

@property (nonatomic) NSArray<__kindof MTEffectProcessorTask *> *tasks;

- (NSArray *)doWork:(NSArray *)images;

@end

// Resampling all images to "decrease" times smaller
@interface MTEffectProcessorStep_Resample : MTEffectProcessorStep

@property (nonatomic) float decrease;

@end

// Resampling all images to "decrease" times smaller
@interface MTEffectProcessorStep_Resize : MTEffectProcessorStep

@property (nonatomic) CGSize targetSize;

@end

// Calculating shared crop rectangle
@interface MTEffectProcessorStep_CalculateCropRectangle : MTEffectProcessorStep

@property (nonatomic, copy) void (^onRectCalculated)(CGRect rect);

@end

// Crop images
@interface MTEffectProcessorStep_CropImages : MTEffectProcessorStep

@property (nonatomic) CGRect rectInside;

@end

// Save
@interface MTEffectProcessorStep_SaveImages : MTEffectProcessorStep

@end




@interface MTBlastProcessor : NSObject {
    NSString *_inputDirectoryPath;
    NSString *_outputDirectoryPath;
    NSArray *_tasks;
}

- (id)initWithInputPath:(NSString*)inputPath outputPath:(NSString*)outputPath;

- (void)dowork;

@end
