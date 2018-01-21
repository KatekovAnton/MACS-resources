//
//  CPPTextureImplNSBitmapImageRep.h
//  maxtouchTool
//
//  Created by Katekov Anton on 1/5/17.
//  Copyright © 2017 katekovanton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#include "Texture.h"



class CPPTextureImplNSBitmapImageRep : public CPPITexture {
public:
    
    NSBitmapImageRep *_imageRep;
    int _width;
    int _heigth;
    
    CPPTextureImplNSBitmapImageRep(NSImage *image);
    virtual ~CPPTextureImplNSBitmapImageRep();
    
    virtual int GetWidth() override;
    virtual int GetHeight() override;
    virtual Color GetColorAtPoint(GPoint2D point) override;
    virtual unsigned char *GetBitmapData() override;
    
};
