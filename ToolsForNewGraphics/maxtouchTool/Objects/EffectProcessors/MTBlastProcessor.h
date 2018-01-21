//
//  MTBlastProcessor.h
//  maxtouchTool
//
//  Created by Katekov Anton on 11/16/16.
//  Copyright © 2016 katekovanton. All rights reserved.
//

#import <Foundation/Foundation.h>



typedef NS_ENUM(NSUInteger, MTEffectProcessorTaskType) {
    MTEffectProcessorTaskType_CutRectangle,
};



@interface MTEffectProcessorTask : NSObject

@property (nonatomic) MTEffectProcessorTaskType type;
@property (nonatomic) CGRect rectInside;

@end



@interface MTBlastProcessor : NSObject {
    NSString *_inputDirectoryPath;
    NSString *_outputDirectoryPath;
    NSArray *_tasks;
}

- (id)initWithInputPath:(NSString*)inputPath outputPath:(NSString*)outputPath;

- (void)dowork;

@end
