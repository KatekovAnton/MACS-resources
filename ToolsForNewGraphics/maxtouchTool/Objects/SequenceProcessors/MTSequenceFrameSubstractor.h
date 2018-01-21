//
//  MTSequenceFrameSubstractor.h
//  maxtouchTool
//
//  Created by Katekov Anton on 1/15/17.
//  Copyright © 2017 katekovanton. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface MTSequenceFrameSubstractor : NSObject

- (id)initWithFramePath:(NSString*)framePath substractingFramePath:(NSString*)substractingFramePath;
- (void)dowork;

@end
