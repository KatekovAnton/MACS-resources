//
//  BitmapComposer.hpp
//  maxtouchTool
//
//  Created by Katekov Anton on 8/11/16.
//  Copyright © 2016 katekovanton. All rights reserved.
//

#ifndef BitmapComposer_hpp
#define BitmapComposer_hpp

#include <stdio.h>
#include "Structures.h"



class BitmapTexture;
class CPPTextureClipping;



class BitmapComposer {
    
    BitmapTexture *_resultBitmap;
    
public:
    
    BitmapComposer(GSize2D size);
    ~BitmapComposer();
    
    void setColor(Color color, int x, int y);
    BitmapTexture *GetBitmapTexture() { return _resultBitmap; }
    
    BitmapTexture *getTexture() const;
    GSize2D getSize();
    Color *getColorBuffer();
    
    void insertTexture(CPPTextureClipping *clipping, GPoint2D location);
    
};

#endif /* PBitmapComposer_hpp */
