//
//  MTDiffuseComposer.h
//  maxtouchTool
//
//  Created by Katekov Anton on 11/7/16.
//  Copyright © 2016 katekovanton. All rights reserved.
//

#import <Foundation/Foundation.h>



class CPPITexture;



@interface MTDiffuseComposer : NSObject 

@property (nonatomic, readonly) NSData *resultImageData;

- (id)initWithDiffuseTexture:(CPPITexture *)diffuseTexture diffuseAlphaTexture:(CPPITexture *)diffuseAlphaTexture;

- (void)buildDiffuseImageWithDarkenMultiplier:(float)multiplier;

@end
