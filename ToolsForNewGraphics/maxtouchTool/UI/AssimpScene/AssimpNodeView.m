//
//  AssimpNodeView.m
//  maxtouchTool
//
//  Created by Katekov Anton on 5/19/19.
//  Copyright © 2019 katekovanton. All rights reserved.
//

#import "AssimpNodeView.h"

@implementation AssimpNodeView

+ (AssimpNodeView *)create {
    NSArray *object = nil;
    [[NSBundle mainBundle] loadNibNamed:@"AssimpNodeView" owner:nil topLevelObjects:&object];
    AssimpNodeView *result =  object[0];
    return result;
}

@end
