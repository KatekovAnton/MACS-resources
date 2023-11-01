//
//  MCLightComposer.hpp
//  maxtouchTool
//
//  Created by Anton Katekov on 2023/07/26.
//  Copyright © 2023 katekovanton. All rights reserved.
//

#ifndef MCLightComposer_hpp
#define MCLightComposer_hpp

#include <stdio.h>
#include <vector>
#include "Geometry.h"
#include "json.h"



class CPPITexture;
class ByteBuffer;



class MCLightTextureChannelInfo {
public:
    int offsetX;
    int offsetY;
    int sizeW;
    int sizeH;
    int anchorX;
    int anchorY;
    
    void serialize(Json::Value &v);  
};



class MCLightTextureInfo {
public:
    std::vector<MCLightTextureChannelInfo> channelInfo;
    int sizeW;
    int sizeH;
    
    void serialize(Json::Value &v);
};



class MCLightComposer {
public:
    std::vector<MCLightTextureInfo*> textureInfo;
    ByteBuffer *resultImage1Data = nullptr;
    ByteBuffer *resultImage2Data = nullptr;
    
    MCLightComposer(const std::vector<CPPITexture *> &textures);
    
    void build();
}

#endif /* MCLightComposer_hpp */
