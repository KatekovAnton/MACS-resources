//
//  LibpngWrapper.h
//  grvi
//
//  Created by admin on 01/12/14.
//  Copyright (c) 2014 sfcd. All rights reserved.
//

#ifndef __grvi__LibpngWrapper__
#define __grvi__LibpngWrapper__

class ByteBuffer;
class BitmapTexture;



class LibpngWrapper
{
    
public:
    
    static BitmapTexture* BitmapTextureFromByteBuffer(ByteBuffer *buffer);
    static void BitmapTextureToByteBuffer(const BitmapTexture *texture, ByteBuffer *buffer);
    static int ValidatePngFile(ByteBuffer *buffer);
    
};


#endif /* defined(__grvi__LibpngWrapper__) */
