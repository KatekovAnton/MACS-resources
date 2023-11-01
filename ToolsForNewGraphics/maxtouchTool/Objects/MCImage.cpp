//
//  MCImage.cpp
//  maxtouchTool
//
//  Created by Anton Katekov on 2023/07/25.
//  Copyright © 2023 katekovanton. All rights reserved.
//

#include "MCImage.hpp"
#include <string>
#include "stb_image_defined.h"



MCImage::MCImage(const std::string &filepath)
{
 
    _data = stbi_load(filepath.c_str(), &_width, &_heigth, &_components, 4);
        
        
}

MCImage::~MCImage()
{
    stbi_image_free(_data);
}
