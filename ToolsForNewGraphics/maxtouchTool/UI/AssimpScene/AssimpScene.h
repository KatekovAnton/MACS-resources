//
//  AssimpScene.h
//  maxtouchTool
//
//  Created by Katekov Anton on 5/19/19.
//  Copyright © 2019 katekovanton. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


typedef struct __AssimpMeshVertex {
    float position[4];
    float normal[3];
    float tcoord[2];
    float color[4];
} AssimpMeshVertex;

AssimpMeshVertex AssimpMeshVertexMake();

@interface AssimpMesh : NSObject

@property (nonatomic) int vertexCount;
@property (nonatomic) AssimpMeshVertex *vertices;
@property (nonatomic) int indexCount;
@property (nonatomic) int *indices;

@end



@interface AssimpMaterial : NSObject

@property (nonatomic) NSString *diffuse;

@end



@interface AssimpNode : NSObject

@property (nonatomic) NSString *name;
@property (nonatomic) NSMutableArray *childs;

@property (nonatomic) AssimpMesh *mesh;
@property (nonatomic) AssimpMaterial *material;

@end

@interface AssimpScene : NSObject

@property (nonatomic) AssimpNode *root;

@end

NS_ASSUME_NONNULL_END
