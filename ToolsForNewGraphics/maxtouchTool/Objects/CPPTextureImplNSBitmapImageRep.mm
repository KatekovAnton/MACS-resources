//
//  CPPTextureImplNSBitmapImageRep.m
//  maxtouchTool
//
//  Created by Katekov Anton on 1/5/17.
//  Copyright © 2017 katekovanton. All rights reserved.
//

#import "CPPTextureImplNSBitmapImageRep.h"



CPPTextureImplNSBitmapImageRep::CPPTextureImplNSBitmapImageRep(NSImage *image)
{
    _imageRep = [[NSBitmapImageRep alloc] initWithData:[image TIFFRepresentation]];
    _width = static_cast<int>([_imageRep pixelsWide]);
    _heigth = static_cast<int>([_imageRep pixelsHigh]);
}

CPPTextureImplNSBitmapImageRep::~CPPTextureImplNSBitmapImageRep()
{}

int CPPTextureImplNSBitmapImageRep::GetWidth()
{
    return static_cast<int>(_width);
}

int CPPTextureImplNSBitmapImageRep::GetHeight()
{
    return static_cast<int>(_heigth);
}

Color CPPTextureImplNSBitmapImageRep::GetColorAtPoint(GPoint2D point)
{
    NSUInteger values[4];
    [_imageRep getPixel:values atX:point.x y:point.y];
    return Color(static_cast<unsigned char>(values[0]),
                 static_cast<unsigned char>(values[1]),
                 static_cast<unsigned char>(values[2]),
                 static_cast<unsigned char>(values[3]));
}

unsigned char *CPPTextureImplNSBitmapImageRep::GetBitmapData()
{
    return _imageRep.bitmapData;
}
