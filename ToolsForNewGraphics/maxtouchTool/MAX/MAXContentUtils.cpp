//
//  MAXContentUtils.cpp
//  MAX
//
//  Created by Anton Katekov on 19.04.13.
//  Copyright (c) 2013 AntonKatekov. All rights reserved.
//

#include "MAXContentUtils.h"
#include <iostream>
#include "BinaryReader.h"
#include "ByteBuffer.h"
#include "ZipWrapper.h"
#define STB_IMAGE_IMPLEMENTATION
#include "stb_image.h"
#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb_image_write.h"
#define STB_IMAGE_RESIZE_IMPLEMENTATION
#include "stb_image_resize2.h"

#include "transcoder/basisu_transcoder.h"




void stbi_write_to_file(void *context, void *data, int size)
{
    ByteBuffer *dest = reinterpret_cast<ByteBuffer *>(context);
    dest->appendData(data, size, 1);
}

void save_png_file_by_full_path(const std::string &filename, const MAXTextureData &image)
{
    ByteBuffer dest;
    stbi_write_png_to_func(stbi_write_to_file, &dest, image.w, image.h, image.comp_num, image.data, 0);
    /*
    std::shared_ptr<IFile> filePtr = FileManager::SharedManager()->CreateNewFile(filename, true);
    filePtr->SaveBuffer(reinterpret_cast<const char *>(dest.getPointer()), dest.getDataSize());
    */
}

static uint32_t calculate_mips_count(int w, int h) {
    return static_cast<uint32_t>(std::floor(std::log2(std::max(w, h)))) + 1;
}

MAXTextureData create_texture_data_from_image_file(const std::string &file, bool generate_mipmaps) {
    ByteBuffer buffer;
    MAXContentUtils::ReadFileToBuffer(file, &buffer);

    MAXTextureData res = {};

    static bool transcoder_inited = false;
    if (!transcoder_inited) {
        transcoder_inited = true;
        basist::basisu_transcoder_init();
    }

    // ETC1S/UASTC only, replace with libktx for other formats
    basist::ktx2_transcoder dec;
    if (dec.init(buffer.getPointer(), buffer.getDataSize())) {
        if (!dec.start_transcoding()) return res;

        auto preferred_fmt = basist::transcoder_texture_format::cTFRGBA32; // todo: select based on current platform

        auto transcoder_tex_fmt = basist::transcoder_texture_format::cTFRGBA32;
        if (basist::basis_is_format_supported(preferred_fmt, dec.get_format())) {
            transcoder_tex_fmt = preferred_fmt;
        }

        auto block_size = basist::basis_get_bytes_per_block_or_pixel(transcoder_tex_fmt);
        uint32_t bw = 1u;
        uint32_t bh = 1u;
        if (!basist::basis_transcoder_format_is_uncompressed(transcoder_tex_fmt)) {
            bw = basist::basis_get_block_width(transcoder_tex_fmt);
            bh = basist::basis_get_block_height(transcoder_tex_fmt);
        }
        
        auto nmips = dec.get_levels();
        auto total_byte_size = 0;
        for (uint32_t mip_i = 0; mip_i < nmips; ++mip_i) {
            auto mip_w = dec.get_width() >> mip_i;
            mip_w = (mip_w < bw) ? bw : mip_w;
            auto mip_h = dec.get_height() >> mip_i;
            mip_h = (mip_h < bh) ? bh : mip_h;

            auto blocks_w = (mip_w + bw - 1) / bw;
            auto blocks_h = (mip_h + bh - 1) / bh;
            auto mip_byte_size = block_size * blocks_w * blocks_h;

            total_byte_size += mip_byte_size;
        }

        auto staging_buf = (uint8_t*)malloc(total_byte_size);

        auto staging_dst_ptr = staging_buf;
        const uint32_t total_layers = dec.get_layers() ? dec.get_layers() : 1;
        for (uint32_t level_index = 0; level_index < nmips; level_index++) {
			for (uint32_t layer_index = 0; layer_index < total_layers; layer_index++) { 
                for (uint32_t face_index = 0; face_index < dec.get_faces(); face_index++) {
                    auto mip_w = dec.get_width() >> level_index;
                    mip_w = (mip_w < bw) ? bw : mip_w;
                    auto mip_h = dec.get_height() >> level_index;
                    mip_h = (mip_h < bh) ? bh : mip_h;

                    auto blocks_w = (mip_w + bw - 1) / bw;
                    auto blocks_h = (mip_h + bh - 1) / bh;
                    auto total_blocks = blocks_w * blocks_h;

                    uint32_t decode_flags = 0;
                    if (!dec.transcode_image_level(level_index, layer_index, face_index, staging_dst_ptr, total_blocks, transcoder_tex_fmt, decode_flags))
                    {
                        printf("Failed transcoding image level (%u %u %u)!\n", layer_index, level_index, face_index);
                        free(staging_buf);
                        return res;
                    }

                    staging_dst_ptr += total_blocks * block_size;
                }
            }
        }
        
        res.data = staging_buf;
        res.w = dec.get_width();
        res.h = dec.get_height();
        res.comp_num = 4;
        res.mips_num = nmips;

        switch (transcoder_tex_fmt)
        {
        case basist::transcoder_texture_format::cTFRGBA32:
            res.format = MAXTextureData::format_e::RGBA;
            break;
        
        default:
            assert(false && "unsupported format");
            break;
        }


    } else {
        int w = 0, h = 0, comp_num = 0;
        res.data = stbi_load_from_memory(buffer.getPointer(), (int)buffer.getDataSize(), &w, &h, &comp_num, 0);
        res.w = (short)w;
        res.h = (short)h;
        res.comp_num = comp_num;

        if (generate_mipmaps) {
            auto nmips = calculate_mips_count(w, h);
            auto total_byte_size = 0;
            for (uint32_t mip_i = 0; mip_i < nmips; ++mip_i) {
                auto mip_w = w >> mip_i;
                mip_w = (mip_w < 1) ? 1 : mip_w;
                auto mip_h = h >> mip_i;
                mip_h = (mip_h < 1) ? 1 : mip_h;

                auto mip_byte_size = comp_num * mip_w * mip_h;

                total_byte_size += mip_byte_size;
            }

            auto data_with_mips = (uint8_t*)malloc(total_byte_size);

            auto dst_buf_it = data_with_mips;
            auto image_byte_size = w * h * comp_num;
            memcpy(dst_buf_it, res.data, image_byte_size);
            dst_buf_it += image_byte_size;

            const stbir_pixel_layout layouts[] = {
                STBIR_1CHANNEL,
                STBIR_2CHANNEL,
                STBIR_RGB,
                STBIR_4CHANNEL, // todo: use STBIR_RGBA to consider alpha (if alpha is transparency, alpha blending)
            };
            auto layout = layouts[comp_num - 1];
            
            bool finished = true;
            for (uint32_t mip_i = 1; mip_i < nmips; ++mip_i) {
                auto mip_w = w >> mip_i;
                mip_w = (mip_w < 1) ? 1 : mip_w;
                auto mip_h = h >> mip_i;
                mip_h = (mip_h < 1) ? 1 : mip_h;

                
                if (!stbir_resize_uint8_linear(res.data, w, h, comp_num * w,
                        dst_buf_it, mip_w, mip_h, comp_num * mip_w, 
                        layout)) {
                    finished = false;
                    break;
                }
                dst_buf_it += mip_w * mip_h * comp_num;
            }
            if (finished) {
                free(res.data);
                res.data = data_with_mips;
                res.mips_num = nmips;
            } else {
                free(data_with_mips);
            }
        }
    }

    return res;
}


void MAXContentUtils::ReadFileToBuffer(const std::string& fileName, ByteBuffer* buffer)
{
    buffer->clear();
    std::ifstream file(fileName, std::ifstream::binary);
    file.seekg(0, std::ifstream::end);
    size_t fsize = file.tellg();
    file.seekg(0, std::ifstream::beg);

    buffer->increaseBufferBy(fsize);
    
    file.read(reinterpret_cast<char*>(buffer->getPointer()), fsize);
    buffer->dataAppended(fsize);
    file.close();
}

void MAXContentUtils::RemovePremultiplication(MAXTextureData &textureData)
{
    auto td_data = textureData.DataAsColors();
    for (int i = 0; i < textureData.w * textureData.h; i++) {
        if (td_data[i].a == 0) {
            continue;
        }
        float a = td_data[i].a;
        a /= 255.0;
        float r = td_data[i].r;
        r /= a;
        float g = td_data[i].g;
        g /= a;
        float b = td_data[i].b;
        b /= a;
        td_data[i].r = r;
        td_data[i].g = g;
        td_data[i].b = b;
    }
}
