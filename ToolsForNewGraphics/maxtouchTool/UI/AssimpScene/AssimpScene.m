//
//  AssimpScene.m
//  maxtouchTool
//
//  Created by Katekov Anton on 5/19/19.
//  Copyright © 2019 katekovanton. All rights reserved.
//

#import "AssimpScene.h"



AssimpMeshVertex AssimpMeshVertexMake() {
    AssimpMeshVertex result;
    memset(&result, 0, sizeof(result));
    return result;
}



@implementation AssimpMesh

- (id)init {
    if (self = [super init]) {
        
    }
    return self;
}

//@property (nonatomic) int vertexCount;
//@property (nonatomic) AssimpMeshVertex *vertices;
//@property (nonatomic) int indexCount;
//@property (nonatomic) int *indices;

@end



@implementation AssimpMaterial

- (id)init {
    if (self = [super init]) {
        
    }
    return self;
}

@end



@implementation AssimpNode

- (id)init {
    if (self = [super init]) {
        self.childs = [NSMutableArray new];
    }
    return self;
}

@end



@implementation AssimpScene

@end
