//
//  AssimpScene.m
//  maxtouchTool
//
//  Created by Katekov Anton on 5/19/19.
//  Copyright © 2019 katekovanton. All rights reserved.
//

#import "AssimpScene.h"
#import <assimp/Importer.hpp>
#import <assimp/scene.h>
#import <assimp/postprocess.h>



AssimpMeshVertex AssimpMeshVertexMake() {
    AssimpMeshVertex result;
    memset(&result, 0, sizeof(result));
    return result;
}



@implementation AssimpMesh

- (id)init
{
    if (self = [super init]) {
        
    }
    return self;
}

- (void)dealloc
{
    if (_vertices != nullptr) {
        free(_vertices);
    }
    if (_indices != nullptr) {
        free(_indices);
    }
}

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
        self.transform = GLKMatrix4Identity;
        self.childs = [NSMutableArray new];
    }
    return self;
}

@end



@interface AssimpScene() {
    NSMutableArray *_meshes;
}

@end



@implementation AssimpScene

- (id)initWithPath:(NSString *)path
{
    if (self = [super init]) {
        _meshes = [NSMutableArray array];
        
        ///Users/katekovanton/Desktop/MAX materials/Menu/Mars_Photorealistic_2K/Mars 2K.obj
        Assimp::Importer importer;
        const aiScene* aScene = NULL;
        
        {
            const char* pFile = [path UTF8String];
            
            aScene = importer.ReadFile(pFile,
                                       aiProcess_CalcTangentSpace |
                                       aiProcess_Triangulate |
                                       aiProcess_JoinIdenticalVertices |
                                       aiProcess_SortByPType);
            
            if (!aScene) {
                return nil;
            }
            [self loadMeshesFromScene:aScene];
            self.root = [AssimpNode new];
            self.root.name = [NSString stringWithFormat:@"root_%@", path.lastPathComponent];
            [self loadNodeRecurse:aScene srcNode:aScene->mRootNode destNode:self.root];
            int a = 0;
            a++;
        }
        
    }
    return self;
}

- (NSString*)toStr:(aiString)aStr
{
    return [[NSString alloc] initWithCString:aStr.C_Str() encoding:NSUTF8StringEncoding];
}

- (GLKMatrix4)toMatrix:(aiMatrix4x4)srcMtx
{
    GLKMatrix4 res;
    
    res.m00 = srcMtx[0][0];  res.m01 = srcMtx[1][0];  res.m02 = srcMtx[2][0];  res.m03 = srcMtx[3][0];
    res.m10 = srcMtx[0][1];  res.m11 = srcMtx[1][1];  res.m12 = srcMtx[2][1];  res.m13 = srcMtx[3][1];
    res.m20 = srcMtx[0][2];  res.m21 = srcMtx[1][2];  res.m22 = srcMtx[2][2];  res.m23 = srcMtx[3][2];
    res.m30 = srcMtx[0][3];  res.m31 = srcMtx[1][3];  res.m32 = srcMtx[2][3];  res.m33 = srcMtx[3][3];
    
    return res;
}

- (void)loadMeshesFromScene:(const aiScene *)aScene
{
    for (int meshIndex = 0; meshIndex < aScene->mNumMeshes; meshIndex++)
    {
        aiMesh *aMesh = aScene->mMeshes[meshIndex];
        NSString *name = [self toStr:aMesh->mName];
        if (name.length < 1) {
            [_meshes addObject:[NSNull null]];
            continue;
        }
        if (aMesh->mNumFaces <= 2) {
            [_meshes addObject:[NSNull null]];
            continue;
        }
        if (aMesh->mNumVertices <= 2) {
            [_meshes addObject:[NSNull null]];
            continue;
        }

        AssimpMeshVertex *pVertices = (AssimpMeshVertex*)calloc(aMesh->mNumVertices, sizeof(AssimpMeshVertex));
        
        BOOL hasPositions = NO;
        BOOL hasUV = NO;
        BOOL hasNormals = NO;
        BOOL hasTangents = NO;
        BOOL hasBitangents = NO;
        BOOL hasColors = NO;
        BOOL hasSkinAttributes = NO;
        
        if (aMesh->GetNumUVChannels() >0 &&
            aMesh->mNumUVComponents[0] == 2) { // загружаем только один канал текстурных координат
            hasUV = YES;
        }
        
        hasColors = aMesh->GetNumColorChannels() > 0;
        if (hasColors) {
            //hasUV = NO;// temporary
        }
        hasPositions = aMesh->HasPositions();
        hasNormals = aMesh->HasNormals();
        hasTangents = aMesh->HasTangentsAndBitangents();
        hasBitangents = aMesh->HasTangentsAndBitangents(); // Если есть касательные, то есть и бикасательные
        hasSkinAttributes = aMesh->HasBones();
        
        for (NSInteger i = 0; i < aMesh->mNumVertices; i++)
        {
            pVertices[i] = AssimpMeshVertexMake();
            
            if (hasPositions)
            {
                pVertices[i].position = GLKVector3Make(aMesh->mVertices[i].x,
                                                       aMesh->mVertices[i].y,
                                                       aMesh->mVertices[i].z);
            }
            
            if (hasNormals)
            {
                pVertices[i].normal = GLKVector3Make(aMesh->mNormals[i].x,
                                                     aMesh->mNormals[i].y,
                                                     aMesh->mNormals[i].z);
            }
            
            if (hasUV)
            {
                pVertices[i].tcoord = GLKVector2Make(aMesh->mTextureCoords[0][i].x,
                                                     aMesh->mTextureCoords[0][i].y);
            }
            
            if (hasTangents)
            {
                pVertices[i].tangent = GLKVector3Make(aMesh->mTangents[i].x,
                                                      aMesh->mTangents[i].y,
                                                      aMesh->mTangents[i].z);
            }
            
            if (hasColors)
            {
                pVertices[i].color = GLKVector3Make(aMesh->mColors[0][i].r,
                                                    aMesh->mColors[0][i].g,
                                                    aMesh->mColors[0][i].b);
                
                // TODO
//                if (convertTosRGB) {
//                    pVerticesPatch[i].color = [MLoader sRGBColorWithRGBColor:pVerticesPatch[i].color];
//                }
            }
        }
        
        if (hasSkinAttributes)
        {
            for (NSInteger i = 0; i<aMesh->mNumBones; i++)
            {
                aiBone *aBone = aMesh->mBones[i];
                for (NSInteger j = 0; j < aBone->mNumWeights; j++)
                {
                    aiVertexWeight aWeights = aBone->mWeights[j];
                    
                    NSInteger k = 0;
                    for(; k < MAX_VERTEX_BONE_RELATIONS; k++) {
//                        if(pVertices[aWeights.mVertexId].boneWeights[k] == 0.0f) {
//                            pVertices[aWeights.mVertexId].boneIndices[k] = i;
//                            pVertices[aWeights.mVertexId].boneWeights[k] = aWeights.mWeight;
//                            break;
//                        }
                    }
                    
                    if (k == MAX_VERTEX_BONE_RELATIONS) { // все слоты заняты. заменим слот с наименьшим весом
//                        for (k = 0; k < MAX_VERTEX_BONE_RELATIONS; k++) {
//                            if (pVertices[aWeights.mVertexId].boneWeights[k] < aWeights.mWeight) {
//                                pVertices[aWeights.mVertexId].boneIndices[k] = i;
//                                pVertices[aWeights.mVertexId].boneWeights[k] = aWeights.mWeight;
//                                break;
//                            }
//                        }
                    }
                }
            }
        }
        
        // загрузка индексов меша
        //newMesh.numIndices = @(3 * aMesh->mNumFaces);  // ограниченно только треугольниками пока
        NSInteger numIndices = 3 * aMesh->mNumFaces;
        size_t idxSZ = sizeof(uint) * numIndices;
        uint *pIndices = (uint*)malloc(idxSZ);
        
        uint *dest = pIndices;
        for(int i=0; i<aMesh->mNumFaces; i++) {
            *dest = aMesh->mFaces[i].mIndices[0]; dest++;
            *dest = aMesh->mFaces[i].mIndices[1]; dest++;
            *dest = aMesh->mFaces[i].mIndices[2]; dest++;
        }
        
        if (hasNormals == NO) {
            [self computeVertexNormalsWithVertices:pVertices verticesCount:aMesh->mNumVertices indices:pIndices indicesCount:numIndices];
            hasNormals = YES;
        }
        
        if (!hasColors && !hasUV) {
            hasUV = YES;
        }
        
        AssimpMesh *m = [AssimpMesh new];
        m.name = name;
        m.verticesCount = aMesh->mNumVertices;
        m.vertices = pVertices;
        m.indicesCount = numIndices;
        m.indices = pIndices;
        
        [_meshes addObject:m];
    }
}

- (void)computeVertexNormalsWithVertices:(AssimpMeshVertex *)pVertex verticesCount:(NSInteger)pNumVertices indices:(uint *)pIndices indicesCount:(NSInteger)pNumIndices {
    
    for (NSInteger i = 0; i < pNumIndices; i += 3) {
        
        //Получить нормаль треугольного фэйса
        
        GLKVector3 vectorA = pVertex[pIndices[i]].position;
        GLKVector3 vectorB = pVertex[pIndices[i+1]].position;
        GLKVector3 vectorC = pVertex[pIndices[i+2]].position;
        
        GLKVector3 vectorCB = GLKVector3Subtract(vectorC, vectorB);
        GLKVector3 vectorAB = GLKVector3Subtract(vectorA, vectorB);
        
        GLKVector3 normal = GLKVector3CrossProduct(vectorCB, vectorAB);
        
        //прибавить нормаль к нормалям соответствующих вершин
        pVertex[pIndices[i]].normal = GLKVector3Add(pVertex[pIndices[i]].normal, normal);
        pVertex[pIndices[i+1]].normal = GLKVector3Add(pVertex[pIndices[i+1]].normal, normal);
        pVertex[pIndices[i+2]].normal = GLKVector3Add(pVertex[pIndices[i+2]].normal, normal);
    }
    
    //нормализовать нормали
    for (NSInteger i = 0; i < pNumVertices; i++) {
        if (fabsf(pVertex[i].normal.x) > fThreshold ||
            fabsf(pVertex[i].normal.y) > fThreshold ||
            fabsf(pVertex[i].normal.z) > fThreshold) {
            pVertex[i].normal = GLKVector3Normalize(pVertex[i].normal);
        }
        else {
            pVertex[i].normal = GLKVector3Make(0, 0, 0);
        }
    }
}

- (void)loadNodeRecurse:(const aiScene *)aScene srcNode:(aiNode *)srcNode destNode:(AssimpNode *)destNode
{
    for (int i = 0; i < srcNode->mNumChildren; i++)
    {
        aiNode *assimpNode = srcNode->mChildren[i];
        NSString *assimpNodeName = [self toStr:assimpNode->mName];
        if (assimpNode->mNumMeshes > 0)
        {
            NSString *info = @"meshes: ";
            for (int j = 0; j < assimpNode->mNumMeshes; j++) {
                int idxMesh = assimpNode->mMeshes[j];
                info = [info stringByAppendingFormat:@"%d ", idxMesh];
            }
            NSLog(@"Node: %@ %@", assimpNodeName, info);
            
            for (int j = 0; j < assimpNode->mNumMeshes; j++) { // перебрать все меши в узле
                
                int idxMesh = assimpNode->mMeshes[j];
                
                AssimpNode *newNode = [AssimpNode new];
                [destNode.childs addObject:newNode];
                if (_meshes[idxMesh] != [NSNull null]) {
                    AssimpMesh *m = _meshes[idxMesh];
                    newNode.mesh = m;
                }
                
                newNode.transform = [self toMatrix:assimpNode->mTransformation];
                newNode.name = [self toStr:assimpNode->mName];
                if (j == 0) {
                    [self loadNodeRecurse:aScene srcNode:assimpNode destNode:newNode ];
                }
                else { // последующие меши в узле. дать ноду специализированное название
                    
//                    NSString *name = [self toStr:assimpNode->mName];
//                    NSString *suitableName = [NSString stringWithFormat:@"%@_%d", name, j];
//                    newNode.name = suitableName;
                    // ???
                }
            }
        }
        else { // empty nodes
            
            AssimpNode *newNode = [AssimpNode new];
            [destNode.childs addObject:newNode];
            newNode.name = [self toStr:assimpNode->mName];
            newNode.transform = [self toMatrix:assimpNode->mTransformation];
            [self loadNodeRecurse:aScene srcNode:assimpNode destNode:newNode];
        }
    }
}

@end
