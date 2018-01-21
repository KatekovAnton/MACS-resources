//
//  ZipWrapper.cpp
//  MAX
//
//  Created by Anton Katekov on 25.04.14.
//  Copyright (c) 2014 AntonKatekov. All rights reserved.
//

#include "ZipWrapper.h"
#include "ByteBuffer.h"
#include "zlib.h"




#define windowBits 15
#define GZIP_ENCODING 16

void zip_compress(char *bytes, size_t length, ByteBuffer *destination)
{
    if (length == 0) return;
    
    z_stream zStream;
    zStream.zalloc = Z_NULL;
    zStream.zfree = Z_NULL;
    zStream.opaque = Z_NULL;
    zStream.avail_in = 0;
    zStream.next_in = 0;
    int status = deflateInit(&zStream, Z_BEST_COMPRESSION);
    if (status != Z_OK)
        return;
    
    
    zStream.next_in = (unsigned char*)bytes;
    zStream.avail_in = (unsigned int)length;
    zStream.avail_out = 0;
    
    uLong bytesProcessedAlready = zStream.total_out;
    while (zStream.avail_out == 0) {
        
        if (zStream.total_out-bytesProcessedAlready >= destination->getFullSize())
            destination->increaseBufferBy(length/2);
        
        
        zStream.next_out = (Bytef*)destination->getPointer() + zStream.total_out-bytesProcessedAlready;
        zStream.avail_out = (unsigned int)(destination->getFullSize() - (zStream.total_out + bytesProcessedAlready));
        uLong totalOut=  zStream.total_out;
        status = deflate(&zStream, Z_FINISH);
        destination->dataAppended(zStream.total_out - totalOut);
        
        if (status == Z_STREAM_END)
            break;
        else if (status != Z_OK)
        {
            deflateEnd(&zStream);
            return;
        }
    }
    deflateEnd(&zStream);
}

void zip_decompress(char *bytes, size_t length, ByteBuffer *destination)
{
    if (length == 0)
        return;
    
    
    z_stream zStream;
    zStream.zalloc = Z_NULL;
    zStream.zfree = Z_NULL;
    zStream.opaque = Z_NULL;
    zStream.avail_in = 0;
    zStream.next_in = 0;
    int status = inflateInit2(&zStream, (15+32));
    if (status != Z_OK)
        return;
    
    
    zStream.next_in = reinterpret_cast<unsigned char*>(bytes);
    zStream.avail_in = static_cast<unsigned int>(length);
    zStream.avail_out = 0;
    
    while (zStream.avail_in != 0)
    {
        
        if (zStream.total_out >= destination->getFullSize())
            destination->increaseBufferBy(length/2);
        
        
        zStream.next_out = (Bytef*)destination->getPointer() + zStream.total_out;
        zStream.avail_out = static_cast<unsigned int>(destination->getFullSize() - (zStream.total_out));
        
        uLong totalOut = zStream.total_out;
        status = inflate(&zStream, Z_NO_FLUSH);
        destination->dataAppended(zStream.total_out - totalOut);
        
        if (status == Z_STREAM_END)
            break;
        else if (status != Z_OK)
        {
            inflateEnd(&zStream);
            return;
        }
    }
    inflateEnd(&zStream);
}
