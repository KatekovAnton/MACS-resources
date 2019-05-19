//
//  MTProcessSettings.h
//  maxtouchTool
//
//  Created by Katekov Anton on 5/19/19.
//  Copyright © 2019 katekovanton. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@interface MTProcessSettings : NSObject

@property (nonatomic) NSString *inputPath;
@property (nonatomic) NSString *outputPath;

+ (MTProcessSettings*)requestSettingsForType:(NSString*)type;

@end

NS_ASSUME_NONNULL_END
