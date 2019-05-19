//
//  AssimpView.m
//  maxtouchTool
//
//  Created by Katekov Anton on 5/19/19.
//  Copyright © 2019 katekovanton. All rights reserved.
//

#import "AssimpView.h"
#import "AssimpScene.h"
#import "AssimpNodeView.h"
#import "MTProcessSettings.h"



@interface AssimpView() <NSOutlineViewDelegate, NSOutlineViewDataSource>
@end

@implementation AssimpView

- (IBAction)onOpen:(id)sender
{
    MTProcessOpenOptions *o = [MTProcessOpenOptions new];
    o.canChooseFiles = YES;
    o.canChooseDirectories = NO;
    o.allowsMultipleSelection = NO;
    o.allowedFileTypes = @[@"obj"];
    MTProcessSettings *s = [MTProcessSettings requestLoadForType:@"3dassimp" options:o];
    if (s == nil) {
        return;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _scene = [[AssimpScene alloc] initWithPath:[s inputPathWithoutPercentIncapsulation]];
        [self update];
    });
}

- (void)update
{
    [_table reloadData];
}

- (IBAction)onExport:(id)sender
{}

#pragma mark - NSOutlineViewDelegate

- (nullable NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(nullable NSTableColumn *)tableColumn item:(id)item
{
    AssimpNodeView * view = [AssimpNodeView create];
    view.data = item;
    return view;
}

#pragma mark - NSOutlineViewDataSource

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(nullable id)item
{
    if (item == nil) {
        return 1;
    }
    AssimpNode *n = item;
    return n.childs.count;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(nullable id)item
{
    if (item == nil) {
        return _scene.root;
    }
    AssimpNode *n = item;
    return n.childs[index];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    AssimpNode *n = item;
    return n.childs.count > 0;
}

/* NOTE: this method is optional for the View Based OutlineView.
 */
- (nullable id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(nullable NSTableColumn *)tableColumn byItem:(nullable id)item
{
    
    return nil;
}

@end
