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


@interface AssimpView() <NSOutlineViewDelegate, NSOutlineViewDataSource>
@end

@implementation AssimpView

- (IBAction)onOpen:(id)sender
{}

- (IBAction)onExport:(id)sender
{}

#pragma mark - NSOutlineViewDelegate

- (nullable NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(nullable NSTableColumn *)tableColumn item:(id)item
{
    AssimpNodeView * view = [AssimpNodeView create];
    return view;
}

#pragma mark - NSOutlineViewDataSource

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(nullable id)item
{
    if (item == nil) {
        return _scene.root.childs.count;
    }
    AssimpNode *n = item;
    return n.childs.count;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(nullable id)item
{
    AssimpNode *n = item;
    return n.childs[index];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    return YES;
}

/* NOTE: this method is optional for the View Based OutlineView.
 */
- (nullable id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(nullable NSTableColumn *)tableColumn byItem:(nullable id)item
{
    
    return nil;
}

@end
