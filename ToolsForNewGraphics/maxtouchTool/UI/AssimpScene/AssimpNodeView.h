//
//  AssimpNodeView.h
//  maxtouchTool
//
//  Created by Katekov Anton on 5/19/19.
//  Copyright © 2019 katekovanton. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AssimpNode;

NS_ASSUME_NONNULL_BEGIN

@interface AssimpNodeView : NSView {
    
    IBOutlet NSTextField *_labelName;
}

@property (nonatomic) AssimpNode *data;

+ (AssimpNodeView *)create;

@end

NS_ASSUME_NONNULL_END
