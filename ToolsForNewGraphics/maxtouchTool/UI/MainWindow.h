//
//  MainWindow.h
//  maxtouchTool
//
//  Created by Katekov Anton on 8/3/16.
//  Copyright © 2016 katekovanton. All rights reserved.
//

#import <Cocoa/Cocoa.h>



@class MTVisualObject;



@interface MainWindow : NSWindow {
    
    IBOutlet NSImageView *_imageDiffuse;
    IBOutlet NSImageView *_imageShadow;
    IBOutlet NSImageView *_imageResult;
    IBOutlet NSTextField *_labelState;
    IBOutlet NSButton *_checkboxExportAdditionalPNGs;
}

- (void)presentObject:(MTVisualObject*)object;

@end
