//
//  MCImage.hpp
//  maxtouchTool
//
//  Created by Anton Katekov on 2023/07/25.
//  Copyright © 2023 katekovanton. All rights reserved.
//

#ifndef MCImage_hpp
#define MCImage_hpp

#include <stdio.h>
#include <string>



class MCImage {
public:
    
    int _width = 0;
    int _heigth = 0;
    int _components = 0;
    unsigned char *_data = nullptr;
    
    MCImage(const std::string &filepath);
    ~MCImage();
};


#endif /* MCImage_hpp */
