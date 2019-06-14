//
//  MTProcessSettings.m
//  maxtouchTool
//
//  Created by Katekov Anton on 5/19/19.
//  Copyright © 2019 katekovanton. All rights reserved.
//

#import "MTProcessSettings.h"
#import <AppKit/AppKit.h>


@implementation MTProcessOpenOptions

@end


@implementation MTProcessSettings

+ (MTProcessSettings*)requestSettingsForType:(NSString*)type
{
    MTProcessSettings *result1 = [self requestLoadForType:type];
    if (result1 == nil) {
        return nil;
    }
    MTProcessSettings *result2 = [self requestSaveForType:type];
    if (result2 == nil) {
        return nil;
    }
    MTProcessSettings *s = [MTProcessSettings new];
    s.inputPath = result1.inputPath;
    s.outputPath = result2.outputPath;
    return s;
}

+ (MTProcessSettings*)requestLoadForType:(NSString*)type
{
    return [self requestLoadForType:type options:nil];
}

+ (MTProcessSettings*)requestLoadForType:(NSString*)type options:(MTProcessOpenOptions * _Nullable)options
{
    MTProcessSettings *result = [MTProcessSettings new];
    
    @autoreleasepool {
        {
            
            NSOpenPanel *panel = [[NSOpenPanel alloc] init];
            [panel setCanChooseFiles:NO];
            [panel setCanChooseDirectories:YES];
            [panel setAllowsMultipleSelection:NO];
            if (options != nil) {
                [panel setCanChooseFiles:options.canChooseFiles];
                [panel setCanChooseDirectories:options.canChooseDirectories];
                [panel setAllowsMultipleSelection:options.allowsMultipleSelection];
                [panel setAllowedFileTypes:options.allowedFileTypes];
            }
            
            NSString *key = [@"inputDir" stringByAppendingString:type];
            {
                NSString *url = [[NSUserDefaults standardUserDefaults] objectForKey:key];
                if (url)
                    [panel setDirectoryURL:[NSURL URLWithString:url]];
                
            }
            
//            if (options.window != nil)
//            {
//                [panel beginSheetModalForWindow:options.window completionHandler:^(NSModalResponse result) {
//                    
//                }];
//                return nil;
//            }
            
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
    return result;
}

+ (MTProcessSettings*)requestSaveForType:(NSString*)type
{
    MTProcessSettings *result = [MTProcessSettings new];
    
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

- (NSString *)inputPathWithoutPercentIncapsulation
{
    return [self.inputPath stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)outputPathWithoutPercentIncapsulation
{
    return [self.outputPath stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

@end
