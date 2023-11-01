//
//  MCShadowComposer.hpp
//  maxtouchTool
//
//  Created by Anton Katekov on 2023/07/25.
//  Copyright © 2023 katekovanton. All rights reserved.
//

#ifndef MCShadowComposer_hpp
#define MCShadowComposer_hpp

#include <stdio.h>
#include <vector>
#include "Geometry.h"
#include "json.h"



class CPPITexture;
class ByteBuffer;



class MCShadowTextureInfo {
public:

    int offsetX;
    int offsetY;
    int sizeW;
    int sizeH;
    int anchorX;
    int anchorY;
    
    void serialize(Json::Value &v);
};



class MCShadowComposer {
public:
    std::vector<MCShadowTextureInfo> _textureInfo;
    ByteBuffer *_resultImageData = nullptr; // compressed
    GISize2D _resultImageSize;
    
    MCShadowComposer(const std::vector<CPPITexture *> &shadowTextures);
    
    void buildShadowImage();
};

#endif /* MCShadowComposer_hpp */
