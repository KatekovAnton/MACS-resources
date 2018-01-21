//
//  BitmapTexture.h
//  MAX
//
//  Created by Katekov Anton on 8/10/16.
//  Copyright © 2016 AntonKatekov. All rights reserved.
//

#ifndef __grvi__BitmapTexture__
#define __grvi__BitmapTexture__

#include <stdio.h>
#include "Geometry.h"



class ByteBuffer;



struct BitmapTextureInfo
{
    GSize2D _textureSize;
    int _chanels;
};



class BitmapTexture
{
    
    ByteBuffer *_internalBuffer;
    
public:
    
    ByteBuffer *GetBuffer(){return _internalBuffer;}
    BitmapTextureInfo _info;
    
    BitmapTexture();
    ~BitmapTexture();
    
    void MakeBufferWithSize(size_t size);
    
};


#endif /* defined(__grvi__BitmapTexture__) */
