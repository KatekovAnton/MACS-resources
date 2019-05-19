//
//  BinaryWriter.h
//  MAX
//
//  Created by  Developer on 14.10.13.
//  Copyright (c) 2013 AntonKatekov. All rights reserved.
//

#ifndef __MAX__BinaryWriter__
#define __MAX__BinaryWriter__

#include <iostream>
#include <istream>
#include <fstream>
#include <iosfwd>
#include <stdio.h>
#include <cstdint>
#include "FileManager.h"



class BinaryWriter : public IBinaryWriter {
    
    FILE            *_file;
    std::string     _filename;
    unsigned int    _position;
    
public:
    
    BinaryWriter(const std::string &filename);
    ~BinaryWriter();
    bool isValid() const { return !(!_file); };
    
#pragma mark - IBinaryWriter
    
public:
    
    unsigned int WriterGetPosition() override;
    void WriterSetPosition(unsigned int position) override;
    unsigned int WriterGetSize() override;
    
    void WriterWriteInt(int value) override;
    void WriterWriteUInt(unsigned int value) override;
    void WriterWriteFloat(float value) override;
    void WriterWriteBuffer(ByteBuffer *buffer) override;
    void WriterWriteBuffer(const char *buffer, unsigned int length) override;
    void WriterWriteTile(char tile, unsigned int count) override;
    
    void WriterFlush() override;
    
};

#endif /* defined(__MAX__BinaryWriter__) */
