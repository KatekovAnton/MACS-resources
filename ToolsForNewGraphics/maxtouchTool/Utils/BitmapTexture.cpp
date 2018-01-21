//
//  BitmapTexture.cpp
//  MAX
//
//  Created by Katekov Anton on 8/10/16.
//  Copyright © 2016 AntonKatekov. All rights reserved.
//

#include "BitmapTexture.h"
#include "ByteBuffer.h"



BitmapTexture::BitmapTexture()
:
_internalBuffer(NULL)
{
    _info._textureSize = GSize2D(0, 0);
    _info._chanels = 0;
}

BitmapTexture::~BitmapTexture()
{
    delete _internalBuffer;
}

void BitmapTexture::MakeBufferWithSize(size_t size)
{
    delete _internalBuffer;
    _internalBuffer = new ByteBuffer(size);
    _internalBuffer->increaseBufferBy(size);
}
