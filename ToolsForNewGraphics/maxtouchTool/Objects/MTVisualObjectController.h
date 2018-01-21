//
//  MTVisualObjectController.h
//  maxtouchTool
//
//  Created by Katekov Anton on 8/8/16.
//  Copyright © 2016 katekovanton. All rights reserved.
//

#import <Foundation/Foundation.h>    
#import "MTOptions.h"


@interface MTVisualObjectSpriteData : NSObject {
    
}

@property (nonatomic, readonly) NSString *inputLighting;
@property (nonatomic, readonly) NSString *inputShadow;

- (instancetype)initWithInputPath:(NSString*)inputPath
                       outputPath:(NSString*)outputPath
                         baseName:(NSString*)baseName
                         rotation:(int)rotation;

@end;



@interface MTVisualObjectData : NSObject {
    
}
@property (nonatomic, readonly) NSString *inputDiffuseAlpha;
@property (nonatomic, readonly) NSString *inputDiffuse;
@property (nonatomic, readonly) NSString *inputAO;
@property (nonatomic, readonly) NSString *inputNormals;
@property (nonatomic, readonly) NSString *inputStripes;

@property (nonatomic, readonly) NSString *outputDiffuse;
@property (nonatomic, readonly) NSString *outputNormals;
@property (nonatomic, readonly) NSString *outputStripes;
@property (nonatomic, readonly) NSString *outputSettings;
@property (nonatomic, readonly) NSString *outputShadow;

@property (nonatomic, readonly) NSString *outputLight;

@property (nonatomic, readonly) NSArray<MTVisualObjectSpriteData*> *rotatedSpritesData;

- (instancetype)initWithInputPath:(NSString*)inputPath
                       outputPath:(NSString*)outputPath
                         baseName:(NSString*)baseName;

@end



@interface MTVisualObjectController : NSObject {
    MTVisualObjectData *_data;
    
    NSMutableDictionary *_textureCache;
}

- (instancetype)initWithInputPath:(NSString*)inputPath outputPath:(NSString*)outputPath;

- (void)dowork:(MTOptions)options;

@end
