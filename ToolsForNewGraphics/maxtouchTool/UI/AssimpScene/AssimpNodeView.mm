//
//  AssimpNodeView.m
//  maxtouchTool
//
//  Created by Katekov Anton on 5/19/19.
//  Copyright © 2019 katekovanton. All rights reserved.
//

#import "AssimpNodeView.h"
#import "AssimpScene.h"



@implementation AssimpNodeView

+ (AssimpNodeView *)create
{
    NSArray *object = nil;
    [[NSBundle mainBundle] loadNibNamed:@"AssimpNodeView" owner:nil topLevelObjects:&object];
    for (int i = 0; i < object.count; i++)
    {
        if ([object[i] isKindOfClass:[AssimpNodeView class]])
        {
            return object[i];
        }
    }
    return nil;
}

- (void)setData:(AssimpNode *)data
{
    _data = data;
    _labelName.stringValue = _data.name;
}

@end
