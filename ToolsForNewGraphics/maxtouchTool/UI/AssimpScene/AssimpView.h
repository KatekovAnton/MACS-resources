//
//  AssimpView.h
//  maxtouchTool
//
//  Created by Katekov Anton on 5/19/19.
//  Copyright © 2019 katekovanton. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AppKit/AppKit.h>

@class AssimpScene;

NS_ASSUME_NONNULL_BEGIN

@interface AssimpView : NSView {
    
    AssimpScene *_scene;
    
    IBOutlet NSOutlineView *_table;
}

@end

NS_ASSUME_NONNULL_END
