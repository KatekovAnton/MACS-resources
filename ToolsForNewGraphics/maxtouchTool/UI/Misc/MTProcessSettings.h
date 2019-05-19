//
//  MTProcessSettings.h
//  maxtouchTool
//
//  Created by Katekov Anton on 5/19/19.
//  Copyright © 2019 katekovanton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MTProcessOpenOptions : NSObject

@property (nonatomic) BOOL canChooseFiles;
@property (nonatomic) BOOL canChooseDirectories;
@property (nonatomic) BOOL allowsMultipleSelection;
@property (nonatomic) NSArray<NSString *> *allowedFileTypes;
@property (nonatomic, weak) NSWindow *window;

@end


@interface MTProcessSettings : NSObject

@property (nonatomic) NSString *inputPath;
@property (nonatomic) NSString *outputPath;

+ (MTProcessSettings*)requestSettingsForType:(NSString*)type;

+ (MTProcessSettings*)requestLoadForType:(NSString*)type;
+ (MTProcessSettings*)requestLoadForType:(NSString*)type options:(MTProcessOpenOptions * _Nullable)options;
+ (MTProcessSettings*)requestSaveForType:(NSString*)type;

- (NSString *)inputPathWithoutPercentIncapsulation;
- (NSString *)outputPathWithoutPercentIncapsulation;

@end

NS_ASSUME_NONNULL_END
