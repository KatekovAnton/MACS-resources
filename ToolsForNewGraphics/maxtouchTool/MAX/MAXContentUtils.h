//
//  MAXContentUtils.h
//  MAX
//
//  Created by Anton Katekov on 19.04.13.
//  Copyright (c) 2013 AntonKatekov. All rights reserved.
//

#ifndef __MAX__MAXContentUtils__
#define __MAX__MAXContentUtils__

#include <string>
#include <assert.h>
#include "Colors.h"



class ByteBuffer;



struct MAXTextureData
{
    enum class format_e : uint8_t {
        RGBA,
        BC7, // directx (desktop)
    };

    uint8_t* data = nullptr;
    short    w;
    short    h;
    uint8_t  comp_num;
    format_e format;
    uint8_t mips_num = 1;

    void FreeBuffer() {
        free(data);
        data = nullptr;
    }

    Color* DataAsColors() {
        assert(comp_num == 4);
        return (Color*)data;
    }
};



void save_png_file_by_full_path(const std::string &filename, const MAXTextureData&image);
MAXTextureData create_texture_data_from_image_file(const std::string& file, bool generate_mipmaps);



class MAXContentUtils {
public:
    static void ReadFileToBuffer(const std::string& fileName, ByteBuffer* buffer);
    static void RemovePremultiplication(MAXTextureData&textureData);
};


#endif /* defined(__MAX__MAXContentUtils__) */
