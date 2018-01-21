//
//  Texture.h
//  maxtouchTool
//
//  Created by Katekov Anton on 8/3/16.
//  Copyright © 2016 katekovanton. All rights reserved.
//

#include "Structures.h"
#include <vector>



//@interface Texture : NSObject 
//
//@property (nonatomic, readonly) NSBitmapImageRep *imageRep;
//@property (nonatomic, readonly) NSUInteger width;
//@property (nonatomic, readonly) NSUInteger heigth;
//
//- (instancetype)initWithImage:(NSImage*)image;
//
//- (Color)colorAtPointX:(int)x y:(int)y;
//
//@end



class CPPITexture {
    
public:
    virtual ~CPPITexture();
    
    virtual int GetWidth() = 0;
    virtual int GetHeight() = 0;
    virtual Color GetColorAtPoint(GPoint2D point) = 0;
    virtual unsigned char *GetBitmapData() = 0;
    
};



//@interface TextureClipping : NSObject
//
//@property (nonatomic, readonly) Texture *texture;
//@property (nonatomic, readonly) GRect2D payloadFrame;
//
//- (instancetype)initWithTexture:(Texture*)texture;
//
//@end



class CPPTextureClipping {
public:
    
    CPPITexture *_texture;
    GRect2D _payloadFrame;
    
    CPPTextureClipping(CPPITexture *texture, bool clip);
    
    void CalculateClipping();
};



//@interface TextureClippingArray : NSObject
//
//@property (nonatomic, readonly) NSArray<TextureClipping*> *textureClippings;
//@property (nonatomic, readonly) GSize2D inclusiveSize;
//
//- (instancetype)initWithTextyreArray:(NSArray<Texture*>*)textures;
//
//- (GPoint2D)offsetForTexture:(int)texture;
//
//@end



class CPPTextureClippingArray {
    
public:
    
    std::vector<CPPTextureClipping *> _textureClippings;
    GSize2D _inclusiveSize;
    
    CPPTextureClippingArray(const std::vector<CPPITexture *> &textures);
    ~CPPTextureClippingArray();
    
    GPoint2D GetOffsetForTexture(int texture);
};
