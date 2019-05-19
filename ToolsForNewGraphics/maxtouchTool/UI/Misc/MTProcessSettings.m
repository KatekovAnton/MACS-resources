//
//  MTProcessSettings.m
//  maxtouchTool
//
//  Created by Katekov Anton on 5/19/19.
//  Copyright © 2019 katekovanton. All rights reserved.
//

#import "MTProcessSettings.h"
#import <AppKit/AppKit.h>


@implementation MTProcessSettings

+ (MTProcessSettings*)requestSettingsForType:(NSString*)type
{
    MTProcessSettings *result = [MTProcessSettings new];
    
    
    @autoreleasepool {
        {
            
            NSOpenPanel *panel = [[NSOpenPanel alloc] init];
            [panel setCanChooseFiles:NO];
            [panel setCanChooseDirectories:YES];
            [panel setAllowsMultipleSelection:NO];
            
            NSString *key = [@"inputDir" stringByAppendingString:type];
            {
                NSString *url = [[NSUserDefaults standardUserDefaults] objectForKey:key];
                if (url)
                    [panel setDirectoryURL:[NSURL URLWithString:url]];
                
            }
            
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

@end
