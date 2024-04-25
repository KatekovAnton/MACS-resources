//
//  MAXContentMap.h
//  MAX
//
//  Created by Anton Katekov on 26.12.12.
//  Copyright (c) 2012 AntonKatekov. All rights reserved.
//

#ifndef __MAX__MAXContentMap__
#define __MAX__MAXContentMap__

#include <iostream>
#include <assert.h>
#include "json/json.h"
#include "Geometry.h"
#include "Colors.h"
#include "ByteBuffer.h"



class BinaryReader;
class IBinaryReader;
class IBinaryWriter;
class Texture;



class MAXContentMapHeader {
public:
    int _version = 0;
    int _width;
    int _height;
    bool _defaultTextures;
    int _minimapWidth;
    int _minimapHeight;
    
    MAXContentMapHeader();
    
    void Read(const Json::Value &value);
    void Save(Json::Value &value);
};



class MAXContentMapTexture {
    
    int _width;
    int _heigth;
    ByteBuffer *_pixels;
    
public:
    MAXContentMapTexture();
    ~MAXContentMapTexture();
    
    unsigned char *GetData() { return _pixels->getPointer(); };
    int GetWidth() const { return _width; };
    int GetHeigth() const { return _heigth; };
    
    void Read(std::shared_ptr<IBinaryReader> reader);
    void Write(std::shared_ptr<IBinaryWriter> writer);
    
    void InitializeNew(int width, int heigth);
    
    Color GetColor(int x, int y) const;
    
    MAXContentMapTexture *Squeeze(int times);
    
};

class MAXContentMap {
    
    void LoadSharedData();
    
public:
    
    std::string filename;
    std::string name;
    
    int w;
    int h;
    
    char* groundType;//0-ground 1-water 2-coast 3-unpassable
    
    
    MAXContentMapTexture *_miniMap;
    MAXContentMapTexture *_blendMap;
    MAXContentMapTexture *_waterColorMap;
    MAXContentMapTexture *_channel1;
    MAXContentMapTexture *_channel2;
    MAXContentMapTexture *_channel3;
    MAXContentMapTexture *_channel4;
    
    MAXContentMap();
    ~MAXContentMap();
    
    static int MinimapTimes() { return 5; }
    void UpdateContentTextures(MAXContentMapTexture *newBlendMap, MAXContentMapTexture *newWaterColorMap, MAXContentMapTexture *newMinimap);
    
    void InitializeNew(int w, int h, bool loadDefaultMaps, bool loadShort);
    
    void Read(std::shared_ptr<IBinaryReader> reader, bool loadShort);
    void Write(const std::string &file);
    
    void GetGroundType(char *destination) const;
    void SetGroundType(char *ground);

    std::string GetMapId()
    {
        return filename;
    }
};

#endif /* defined(__MAX__MAXContentMap__) */
