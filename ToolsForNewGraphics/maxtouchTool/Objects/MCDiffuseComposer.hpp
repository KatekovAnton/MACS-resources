//
//  MCDiffuseComposer.hpp
//  maxtouchTool
//
//  Created by Anton Katekov on 2023/07/26.
//  Copyright © 2023 katekovanton. All rights reserved.
//

#ifndef MCDiffuseComposer_hpp
#define MCDiffuseComposer_hpp

#include <stdio.h>



class CPPITexture;
class ByteBuffer;
class BitmapComposer;



class MCDiffuseComposer {
public:
    
    ByteBuffer *resultImageData = nullptr;
    
    MCDiffuseComposer(CPPITexture *diffuseTexture, CPPITexture *diffuseAlphaTexture);
    
    BitmapComposer *buildDiffuseImage(float DarkenMultiplier, int method, bool save);  
};

#endif /* MCDiffuseComposer_hpp */
