//
//  BinaryPackUtilities.hpp
//  MAX
//
//  Created by Katekov Anton on 3/26/16.
//  Copyright © 2016 AntonKatekov. All rights reserved.
//

#ifndef BinaryPackUtilities_hpp
#define BinaryPackUtilities_hpp

#include <stdio.h>
#include <string>
#include "json/json.h"



enum BinaryPackFlags
{
    None            = 0,
    Compressed      = 1 << 0,
//    onemore       = 1 << 1,
//    twomore       = 1 << 2,
    
    
};

inline unsigned int operator|(BinaryPackFlags a, BinaryPackFlags b)
{
    return static_cast<BinaryPackFlags>(static_cast<unsigned int>(a) | static_cast<unsigned int>(b));
}

inline unsigned int operator|=(BinaryPackFlags a, BinaryPackFlags b )
{
    unsigned int result = a | b;
    return result;
}



struct __BinaryPackItemHeader;
typedef __BinaryPackItemHeader BinaryPackItemHeader;



class ByteBuffer;
class BinaryPack;
class BinaryPackReader;
class BinaryPackWriter;



class BinaryPackUtilities {
    
public:
    
    static std::string ReadItemString(BinaryPackReader *reader, const std::string &name, bool *exist);
    static void ReadItemJson(BinaryPackReader *reader, const std::string &name, Json::Value &destination, bool *exist);
    static void ReadItemBuffer(BinaryPackReader *reader, const std::string &name, ByteBuffer *destination, bool *exist);
    
    static BinaryPackItemHeader WriteItemString(BinaryPackWriter *writer, const std::string &name, bool compress, const std::string &str);
    static BinaryPackItemHeader WriteItemString(BinaryPackWriter *writer, const std::string &name, bool compress, std::string &str, bool memorySaving);
    static BinaryPackItemHeader WriteItemJson(BinaryPackWriter *writer, const std::string &name, bool compress, const Json::Value &root);
    static BinaryPackItemHeader WriteItemJson(BinaryPackWriter *writer, const std::string &name, bool compress, Json::Value &root, bool memorySaving);
    static BinaryPackItemHeader WriteItemBuffer(BinaryPackWriter *writer, const std::string &name, ByteBuffer &buffer);
    
    static void WriteItemStringToBuffer(ByteBuffer *destination, const std::string &name, bool compress, std::string &str, bool memorySaving);
    static void WriteItemJsonToBuffer(ByteBuffer *destination, const std::string &name, bool compress, Json::Value &root, bool memorySaving);
    
};

#endif /* BinaryPackUtilities_hpp */
