//
//  AssimpScene.h
//  maxtouchTool
//
//  Created by Katekov Anton on 5/19/19.
//  Copyright © 2019 katekovanton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>



NS_ASSUME_NONNULL_BEGIN

#define MAX_VERTEX_BONE_RELATIONS 4
const float fThreshold = 0.000001f;
const float fThresholdPow2 = fThreshold*fThreshold;
const float dThreshold = 0.000000000001;

typedef struct __AssimpMeshVertex {
    GLKVector3 position;
    GLKVector3 normal;
    GLKVector2 tcoord;
    GLKVector3 color;
    
    GLKVector3 tangent;
    
} AssimpMeshVertex;

AssimpMeshVertex AssimpMeshVertexMake();

@interface AssimpMesh : NSObject

@property (nonatomic) NSString *name;
@property (nonatomic) int verticesCount;
@property (nonatomic) AssimpMeshVertex *vertices;
@property (nonatomic) int indicesCount;
@property (nonatomic) uint *indices;

@end



@interface AssimpMaterial : NSObject

@property (nonatomic) NSString *diffuse;

@end



@interface AssimpNode : NSObject

@property (nonatomic) NSString *name;
@property (nonatomic) GLKMatrix4 transform;
@property (nonatomic) NSMutableArray *childs;

@property (nonatomic) AssimpMesh *mesh;
@property (nonatomic) AssimpMaterial *material;

@end

@interface AssimpScene : NSObject

@property (nonatomic) AssimpNode *root;

- (id)initWithPath:(NSString *)path;

@end

NS_ASSUME_NONNULL_END
