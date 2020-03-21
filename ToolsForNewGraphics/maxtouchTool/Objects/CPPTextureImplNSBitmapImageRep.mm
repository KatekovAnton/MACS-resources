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
    _width = static_cast<int>(_imageRep.pixelsWide);
    _heigth = static_cast<int>(_imageRep.pixelsHigh);
}

CPPTextureImplNSBitmapImageRep::~CPPTextureImplNSBitmapImageRep()
{

}

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
    CGFloat components[4];
    NSColor *color = [_imageRep colorAtX:point.x y:point.y];
    [color getRed:components green:components + 1 blue:components + 2 alpha:components + 3];
    return Color(components[0] * 255.0, components[1] * 255.0, components[2] * 255.0, components[3] * 255.0);
}

unsigned char *CPPTextureImplNSBitmapImageRep::GetBitmapData()
{
    return _imageRep.bitmapData;
}
