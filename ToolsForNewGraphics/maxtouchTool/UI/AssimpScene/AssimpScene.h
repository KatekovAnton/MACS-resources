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


class IBinaryWriter;
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
    GLKVector3 binormal;
    
} AssimpMeshVertex;

AssimpMeshVertex AssimpMeshVertexMake();

@interface AssimpMesh : NSObject

@property (nonatomic) NSString *name;
@property (nonatomic) int verticesCount;
@property (nonatomic) AssimpMeshVertex *vertices;
@property (nonatomic) int indicesCount;
@property (nonatomic) uint *indices;

- (void)write:(IBinaryWriter *)writer;

@end



@interface AssimpMaterial : NSObject

@property (nonatomic) NSString *diffuse;
@property (nonatomic) NSString *specular;
@property (nonatomic) NSString *heigth;

@end



@interface AssimpNode : NSObject

@property (nonatomic, weak) AssimpNode *parent;
@property (nonatomic) NSString *name;
@property (nonatomic) GLKMatrix4 transform;
@property (nonatomic) NSMutableArray *childs;

@property (nonatomic) AssimpMesh *mesh;
@property (nonatomic) AssimpMaterial *material;

- (NSDictionary *)asData;

@end

@interface AssimpScene : NSObject

@property (nonatomic) AssimpNode *root;

- (id)initWithPath:(NSString *)path;

- (NSDictionary *)asData;

@end

NS_ASSUME_NONNULL_END
