//
//  LibpngWrapper.cpp
//  grvi
//
//  Created by admin on 01/12/14.
//  Copyright (c) 2014 sfcd. All rights reserved.
//

#include "LibpngWrapper.h"

#include "libpng/png.h"
//PNG_CONSOLE_IO_SUPPORTED comments
#include "ByteBuffer.h"
#include "BitmapTexture.h"
#include <vector>


#define PNGSIGSIZE 8

//Png buffer struct
struct PngBuffer
{
    unsigned char *data;
    long length;
    long offset;
};

//Callback function for load png from buffer
void pngReadFromBuffer(png_structrp png_ptr, png_bytep data, png_size_t length)
{
    PngBuffer *buffer = reinterpret_cast<PngBuffer *>(png_get_io_ptr(png_ptr));
    memcpy(data, buffer->data + buffer->offset, length);
    buffer->offset += length;
}

int LibpngWrapper::ValidatePngFile(ByteBuffer *buffer)
{
    return png_sig_cmp(buffer->getPointer(), 0, 8);
}

BitmapTexture* LibpngWrapper::BitmapTextureFromByteBuffer(ByteBuffer *buffer)
{

    BitmapTexture *bitmap = new BitmapTexture();
    
    PngBuffer currentBuffer = {buffer->getPointer(), static_cast<long>(buffer->getFullSize()), 0};
    
    if (png_sig_cmp(currentBuffer.data, 0, 8))
    {
//        ULog("Read png error. File is not recognized as PNG!");
    }
    currentBuffer.offset += 8;
    
    /* initialize stuff */
    png_structp png_ptr = png_create_read_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
    
    if (!png_ptr)
    {
//        ULog("Read png error png_create_read_strruct");
    }
    
    png_infop info_ptr = png_create_info_struct(png_ptr);
    if (!info_ptr)
    {
//        ULog("Read png error png_create_info_struct");
    }
    
    if (setjmp(png_jmpbuf(png_ptr)))
    {
//        ULog("Error read png file");
    }
    
    png_set_read_fn(png_ptr, static_cast<png_voidp>(&currentBuffer), pngReadFromBuffer);
    png_set_sig_bytes(png_ptr, 8);
    
    png_read_info(png_ptr, info_ptr);
    
    png_uint_32 width;
    png_uint_32 height;
    int color_type;
    int bit_depth;
    
    png_get_IHDR(png_ptr, info_ptr,
                 &width, &height,
                 &bit_depth, &color_type, NULL, NULL, NULL);
    
    switch (color_type)
    {
        case PNG_COLOR_TYPE_PALETTE:
            png_set_palette_to_rgb(png_ptr);
            break;
            
        case PNG_COLOR_TYPE_GRAY:
        case PNG_COLOR_TYPE_GRAY_ALPHA:
            if (bit_depth < 8) {
                png_set_expand_gray_1_2_4_to_8(png_ptr);
            }
            png_set_gray_to_rgb(png_ptr);
            break;
    }
    
    /*if the image has a transperancy set.. convert it to a full Alpha channel..*/
    if (png_get_valid(png_ptr, info_ptr, PNG_INFO_tRNS))
    {
        png_set_tRNS_to_alpha(png_ptr);
    }
    
    //We don't support 16 bit precision.. so if the image Has 16 bits per channel
    //precision... round it down to 8.
    if (bit_depth == 16)
    {
        png_set_strip_16(png_ptr);
    }
    
    png_set_add_alpha(png_ptr, 0xff, PNG_FILLER_AFTER);
    
    png_read_update_info(png_ptr, info_ptr);
    
    png_get_IHDR(png_ptr, info_ptr,
                 &width, &height,
                 &bit_depth, &color_type, NULL, NULL, NULL);


    bitmap->_info._chanels = color_type & PNG_COLOR_MASK_ALPHA ? 4 : 3;
    bitmap->_info._textureSize = GSize2DMake(width, height);
    
    png_bytep *rowPtrs = new png_bytep[height];
    
    unsigned int rowbytes = png_get_rowbytes(png_ptr, info_ptr);
    rowbytes += 3 - ((rowbytes-1) % 4);
    
    bitmap->MakeBufferWithSize(rowbytes * height);
    ByteBuffer *bitmapByteBuffer = bitmap->GetBuffer();
    
    for (size_t i = 0; i < height; i++)
    {
        png_uint_32 q = (height - i - 1) * rowbytes;
        rowPtrs[i] = bitmapByteBuffer->getPointer() + q;
    }
    
    png_read_image(png_ptr, rowPtrs);
   
    delete[] (png_bytep)rowPtrs;
    //And don't forget to clean up the read and info structs !
    png_destroy_read_struct(&png_ptr, &info_ptr,(png_infopp)0);
    bitmapByteBuffer->dataAppended(rowbytes * height);
    
    return bitmap;
}



typedef unsigned char ui8;
#define ASSERT_EX(cond, error_message) do { if (!(cond)) { std::cerr << error_message; exit(1);} } while(0)

struct TPngDestructor {
    png_struct *p;
    TPngDestructor(png_struct *p) : p(p)  {}
    ~TPngDestructor() { if (p) {  png_destroy_write_struct(&p, NULL); } }
};

static void PngWriteCallback(png_structp  png_ptr, png_bytep data, png_size_t length)
{
    ByteBuffer *p = (ByteBuffer*)png_get_io_ptr(png_ptr);
    p->appendData(data, length, 1);
}

void LibpngWrapper::BitmapTextureToByteBuffer(const BitmapTexture *texture, ByteBuffer *buffer)
{
    float w = texture->_info._textureSize.width;
    float h = texture->_info._textureSize.height;
    BitmapTexture *notconsttexture = const_cast<BitmapTexture*>(texture);
    const ui8 *dataRGBA = notconsttexture->GetBuffer()->getPointer();
    void *out = buffer;
    
    png_structp p = png_create_write_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
//        ASSERT_EX(p, "png_create_write_struct() failed");
    TPngDestructor destroyPng(p);
    png_infop info_ptr = png_create_info_struct(p);
//    ASSERT_EX(info_ptr, "png_create_info_struct() failed");
//    ASSERT_EX(0 == setjmp(png_jmpbuf(p)), "setjmp(png_jmpbuf(p) failed");
    png_set_IHDR(p, info_ptr, w, h, 8,
                 PNG_COLOR_TYPE_RGBA,
                 PNG_INTERLACE_NONE,
                 PNG_COMPRESSION_TYPE_DEFAULT,
                 PNG_FILTER_TYPE_DEFAULT);
//    png_set_compression_level(p, 0);
    std::vector<ui8*> rows(h);
    for (size_t y = 0; y < h; ++y)
        rows[y] = (ui8*)dataRGBA + y * (int)w * 4;
    png_set_rows(p, info_ptr, &rows[0]);
    png_set_write_fn(p, out, PngWriteCallback, NULL);
    png_write_png(p, info_ptr, PNG_TRANSFORM_IDENTITY, NULL);
    

    
}
