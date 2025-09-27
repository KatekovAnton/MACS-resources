//
//  FileManager.h
//  maxtouchTool
//
//  Created by Katekov Anton on 5/18/19.
//  Copyright © 2019 katekovanton. All rights reserved.
//

#ifndef FileManager_h
#define FileManager_h

#include <json/json.h>
#include <string>
#include <vector>



class ByteBuffer;



class IBinaryReader {
    
public:
    
    virtual ~IBinaryReader();
    
    virtual void ReaderSetPosition(long position) = 0;
    virtual long ReaderGetPosition() = 0;
    virtual long ReaderGetSize() = 0;
    
    virtual int ReaderReadInt() = 0;
    virtual unsigned int ReaderReadUInt() = 0;
    virtual void ReaderReadBuffer(long length, char *buf) = 0;
    
};



class IBinaryWriter {
    
public:
    
    virtual ~IBinaryWriter();
    
    virtual unsigned int WriterGetPosition() = 0;
    virtual void WriterSetPosition(unsigned int position) = 0;
    virtual unsigned int WriterGetSize() = 0;
    
    virtual void WriterWriteInt(int value) = 0;
    virtual void WriterWriteFloat(float value) = 0;
    virtual void WriterWriteUInt(unsigned int value) = 0;
    virtual void WriterWriteBuffer(ByteBuffer *buffer) = 0;
    virtual void WriterWriteBuffer(const char *buffer, unsigned int length) = 0;
    virtual void WriterWriteTile(char tile, unsigned int count) = 0;
    
    virtual void WriterFlush() = 0;
    
};


class FileManager
{
public:


    static void readBinary(const std::string& path, ByteBuffer& destination);
    static void readJson(const std::string& path, Json::Value& destination);
    static std::string toAbsolutePath(const std::string& path);
    static std::vector<std::string> getDirectoriesInPath(const std::string& inputPath);
};


#endif /* FileManager_h */
