//
//  MAXContentMap.cpp
//  MAX
//
//  Created by Anton Katekov on 26.12.12.
//  Copyright (c) 2012 AntonKatekov. All rights reserved.
//

#include "MAXContentMap.h"
#include "MAXContentUtils.h"
#include "BinaryReader.h"
#include "BinaryWriterMemory.hpp"
#include "BinaryPack.hpp"
#include "BinaryPackUtilities.hpp"
#include "ByteBuffer.h"
#include "ZipWrapper.h"



using namespace std;

const int pal_size = 0x300;


#define ITEM_HEADER         "HEADER"
#define ITEM_BLENDMAP       "BLENDMAP"
#define ITEM_WATERCOLORMAP  "WATERCOLORMAP"
#define ITEM_MINIMAP        "MINIMAP"
#define ITEM_GROUNDS        "GROUNDS"



using namespace std;



void ContentMapTextureSetColor(MAXContentMapTexture* texture, Color color)
{
    int w = texture->GetWidth();
    int h = texture->GetHeigth();
    Color* pixels = (Color*)texture->GetData();
    for (int x = 0; x < w; x++) {
        for (int y = 0; y < h; y++) {
            pixels[y * w + x] = color;
        }
    }
}

MAXContentMapTexture* ContentMapTextureFromSizeAndColor(const GSize2D& size, Color color)
{
    int w = size.width;
    int h = size.height;
    MAXContentMapTexture* result = new MAXContentMapTexture();
    result->InitializeNew(w, h);
    ContentMapTextureSetColor(result, color);
    return result;
}



MAXContentMapHeader::MAXContentMapHeader()
:_width(0)
,_height(0)
,_defaultTextures(false)
{}

void MAXContentMapHeader::Read(const Json::Value &value)
{
    _version = value["_version"].asInt();
    _width = value["_width"].asInt();
    _height = value["_heigth"].asInt();
    _defaultTextures = value["_defaultTextures"].asBool();
    _minimapWidth = _width * 10;
    _minimapHeight = _height * 10;
    if (value["_mmw"] != Json::nullValue) {
        _minimapWidth = value["_mmw"].asInt();
    }
    if (value["_mmh"] != Json::nullValue) {
        _minimapHeight = value["_mmh"].asInt();
    }
}

void MAXContentMapHeader::Save(Json::Value &value)
{
    value["_version"] = _version;
    value["_width"] = _width;
    value["_heigth"] = _height;
    value["_mmw"] = _minimapWidth;
    value["_mmh"] = _minimapHeight;
    value["_defaultTextures"] = _defaultTextures;
}



MAXContentMapTexture::MAXContentMapTexture()
:_width(0)
,_heigth(0)
,_pixels(nullptr)
{
    
}

MAXContentMapTexture::~MAXContentMapTexture()
{
    if (_pixels != nullptr) {
        delete _pixels;
        _pixels = nullptr;
    }
}

void MAXContentMapTexture::Read(std::shared_ptr<IBinaryReader> reader)
{
    _width = reader->ReaderReadInt();
    _heigth = reader->ReaderReadInt();
    InitializeNew(_width, _heigth);
    int compressedSize = reader->ReaderReadInt();
    ByteBuffer compressedData(compressedSize);
    compressedData.increaseBufferBy(1);
    reader->ReaderReadBuffer(compressedSize, reinterpret_cast<char *>(compressedData.getPointer()));
    zip_decompress(reinterpret_cast<char *>(compressedData.getPointer()), compressedSize, _pixels);
}

void MAXContentMapTexture::Write(std::shared_ptr<IBinaryWriter> writer)
{
    writer->WriterWriteInt(_width);
    writer->WriterWriteInt(_heigth);
    ByteBuffer compressed;
    zip_compress(reinterpret_cast<char *>(_pixels->getPointer()), _pixels->getDataSize(), &compressed);
    writer->WriterWriteInt(compressed.getDataSize());
    writer->WriterWriteBuffer(&compressed);
}

void MAXContentMapTexture::InitializeNew(int width, int heigth)
{
    _width = width;
    _heigth = heigth;
    _pixels = new ByteBuffer(width * heigth * sizeof(Color));
    _pixels->increaseBufferBy(1);
    memset(_pixels->getPointer(), 0, _pixels->getFullSize());
    _pixels->dataAppended(_pixels->getFullSize());
}

Color MAXContentMapTexture::GetColor(int x, int y) const
{
    unsigned int offset = y * _width + x;
    Color c;
    c.r = *(_pixels->getPointer() + offset * 4);
    c.g = *(_pixels->getPointer() + offset * 4 + 1);
    c.b = *(_pixels->getPointer() + offset * 4 + 2);
    c.a = *(_pixels->getPointer() + offset * 4 + 3);
    return c;
}

MAXContentMapTexture *MAXContentMapTexture::Squeeze(int times)
{
    MAXContentMapTexture *result = new MAXContentMapTexture();
    result->InitializeNew(_width/times, _heigth/times);
    Color *pixels = (Color *)result->_pixels->getPointer();
    Color *existingPixels = (Color *)_pixels->getPointer();
    for (int x = 0; x < _width; x += times) {
        int x1 = x / times;
        if (x1 == result->_width) {
            continue;
        }
        for (int y = 0; y < _heigth; y += times) {
            int y1 = y / times;
            if (y1 == result->_heigth) {
                continue;
            }
            Color c = existingPixels[y * _width + x];
            pixels[y1 * result->GetWidth() + x1] = c;
        }
    }
    return result;
}



MAXContentMap::MAXContentMap()
:
groundType(NULL)
,w(0)
,h(0)
,_miniMap(nullptr)
,_blendMap(nullptr)
,_waterColorMap(nullptr)
,_channel1(nullptr)
,_channel2(nullptr)
,_channel3(nullptr)
,_channel4(nullptr)
{}

MAXContentMap::~MAXContentMap()
{
    if (groundType != NULL) {
        delete []groundType;
        groundType = nullptr;
    }
    if (_miniMap) {
        delete _miniMap;
        _miniMap = nullptr;
    }
    if (_blendMap) {
        delete _blendMap;
        _blendMap = nullptr;
    }
    if (_waterColorMap) {
        delete _waterColorMap;
        _waterColorMap = nullptr;
    }
    if (_channel1) {
        delete _channel1;
        _channel1 = nullptr;
    }
    if (_channel2) {
        delete _channel2;
        _channel2 = nullptr;
    }
    if (_channel3) {
        delete _channel3;
        _channel3 = nullptr;
    }
    if (_channel4) {
        delete _channel4;
        _channel4 = nullptr;
    }
}

void MAXContentMap::UpdateContentTextures(MAXContentMapTexture *newBlendMap, MAXContentMapTexture *newWaterColorMap, MAXContentMapTexture *newMinimap)
{
    if (_blendMap) {
        delete _blendMap;
        _blendMap = nullptr;
    }
    
    _blendMap = newBlendMap;
    
    
    if (_waterColorMap) {
        delete _waterColorMap;
        _waterColorMap = nullptr;
    }
    
    _waterColorMap = newWaterColorMap;
    
    if (_miniMap) {
        delete _miniMap;
        _miniMap = nullptr;
    }
    
    _miniMap = newMinimap;
}

void MAXContentMap::InitializeNew(int width, int heigth, bool loadDefaultMaps, bool loadShort)
{
    {
        w = width;
        h = heigth;
    }
    
    {//minimap
        if (_miniMap) {
            delete _miniMap;
            _miniMap = nullptr;
        }
    }
    
    {
        if (groundType != NULL) {
            delete []groundType;
            groundType = nullptr;
        }
        groundType = new char[width * heigth];
        for (int i = 0; i < width * heigth; i++) {
            groundType[i] = 0;
        }
    }
    Color c(255, 0, 0, 0);
    _blendMap = ContentMapTextureFromSizeAndColor(GSize2D(width * 10, heigth * 10), c);
    Color cw(128, 0, 0, 0);
    _waterColorMap = ContentMapTextureFromSizeAndColor(GSize2D(width * 10, heigth * 10), cw);
    
    if (!loadShort) {
        LoadSharedData();
    }
}

void MAXContentMap::LoadSharedData()
{
    /*
    _channel1 = ContentMapTextureFromFile("Maps/DefaultTextures/sand1.png");
    _channel2 = ContentMapTextureFromFile("Maps/DefaultTextures/sand2.png");
    _channel3 = ContentMapTextureFromFile("Maps/DefaultTextures/sand3c.png", "Maps/DefaultTextures/sand3h.png");
    _channel4 = ContentMapTextureFromFile("Maps/DefaultTextures/sand4.png");
    */
}

void MAXContentMap::Read(std::shared_ptr<IBinaryReader> binaryReader, bool loadShort)
{
    BinaryPack p;
    BinaryPackReader reader(&p, binaryReader);
    
    
    {
        bool exists = false;
        Json::Value value;
        BinaryPackUtilities::ReadItemJson(&reader, ITEM_HEADER, value, &exists);
        
        if (!exists) {
            InitializeNew(150, 150, true, loadShort);
            return;
        }
     
        MAXContentMapHeader header;
        header.Read(value);
        header._defaultTextures = true;
        InitializeNew(header._width, header._height, header._defaultTextures, loadShort);
        
        _miniMap = new MAXContentMapTexture();
        _miniMap->InitializeNew(header._minimapWidth, header._minimapHeight);
    }
    {
        bool exists = false;
        ByteBuffer image;
        BinaryPackUtilities::ReadItemBuffer(&reader, ITEM_MINIMAP, &image, &exists);
        if (exists) {
            std::shared_ptr<IBinaryReader> r = std::shared_ptr<IBinaryReader>(new BinaryReader(reinterpret_cast<char*>(image.getPointer()), image.getDataSize()));
            _miniMap->Read(r);
        }
        else {
            Color cw(128, 128, 128, 255);
            ContentMapTextureSetColor(_miniMap, cw);
        }
    }
    if (loadShort) {
        return;
    }
    {
        bool exists = false;
        ByteBuffer image;
        BinaryPackUtilities::ReadItemBuffer(&reader, ITEM_BLENDMAP, &image, &exists);
        std::shared_ptr<IBinaryReader> r =  std::shared_ptr<IBinaryReader>(new BinaryReader(reinterpret_cast<char *>(image.getPointer()), image.getDataSize()));
        _blendMap->Read(r);
    }
    {
        bool exists = false;
        ByteBuffer image;
        BinaryPackUtilities::ReadItemBuffer(&reader, ITEM_WATERCOLORMAP, &image, &exists);
        if (exists) {
            std::shared_ptr<IBinaryReader> r =  std::shared_ptr<IBinaryReader>(new BinaryReader(reinterpret_cast<char *>(image.getPointer()), image.getDataSize()));
            _waterColorMap->Read(r);
        }
    }
    
    {
        bool exists = false;
        ByteBuffer ground;
        BinaryPackUtilities::ReadItemBuffer(&reader, ITEM_GROUNDS, &ground, &exists);
        memcpy(groundType, ground.getPointer(), w * h);
    }
}

void MAXContentMap::Write(const std::string &file)
{
    BinaryPack p(file);
    BinaryPackWriter writer(&p);
    
    // header
    {
        Json::Value value;
        MAXContentMapHeader header;
        header._width = w;
        header._height = h;
        header._minimapWidth = w * MAXContentMap::MinimapTimes();
        header._minimapHeight = h * MAXContentMap::MinimapTimes();
        header._defaultTextures = true;
        header.Save(value);
        BinaryPackUtilities::WriteItemJson(&writer, ITEM_HEADER, false, value);
    }
    
    // blendmap
    {
        ByteBuffer destination;
        {
            std::shared_ptr<IBinaryWriter> w =  std::shared_ptr<IBinaryWriter>(new BinaryWriterMemory(&destination));
            _blendMap->Write(w);
        }
        BinaryPackUtilities::WriteItemBuffer(&writer, ITEM_BLENDMAP, destination);
    }
    
    // watermap
    {
        ByteBuffer destination;
        {
            std::shared_ptr<IBinaryWriter> w =  std::shared_ptr<IBinaryWriter>(new BinaryWriterMemory(&destination));
            _waterColorMap->Write(w);
        }
        BinaryPackUtilities::WriteItemBuffer(&writer, ITEM_WATERCOLORMAP, destination);
    }
    
    // grounds
    {
        unsigned int flags = BinaryPackFlags::None;
        writer.Write(ITEM_GROUNDS, flags, groundType, w * h);
    }
    
    // minimap
    if (_miniMap != nullptr)
    {
        ByteBuffer destination;
        {
            std::shared_ptr<IBinaryWriter> w =  std::shared_ptr<IBinaryWriter>(new BinaryWriterMemory(&destination));
            _miniMap->Write(w);
        }
        BinaryPackUtilities::WriteItemBuffer(&writer, ITEM_MINIMAP, destination);
        
        MAXTextureData data;
        data.w = _miniMap->GetWidth();
        data.h = _miniMap->GetHeigth();
        data.comp_num = 4;
        data.data = reinterpret_cast<uint8_t*>(_miniMap->GetData());
        save_png_file_by_full_path(filename + ".png", data);
    }
}

void MAXContentMap::GetGroundType(char *destination) const
{
    memcpy(destination, groundType, w * h * sizeof(char));
}

void MAXContentMap::SetGroundType(char *ground)
{
    memcpy(groundType, ground, w * h * sizeof(char));
}
