//
//  BinaryWriter.cpp
//  MAX
//
//  Created by  Developer on 14.10.13.
//  Copyright (c) 2013 AntonKatekov. All rights reserved.
//

#include "BinaryWriter.h"
#include <memory>
#include <string>
#include <iostream>
#include "ByteBuffer.h"



using namespace std;

BinaryWriter::BinaryWriter(const std::string &filename)
:_filename(filename)
,_position(0)
,_file(NULL)
{
    _file = fopen(_filename.c_str(), "r+b");
    if (!_file) {
//        ULog("attempt to write into not existing file!");
    }
}

BinaryWriter::~ BinaryWriter()
{
    if (_file) {
        fclose(_file);
        _file = NULL;
    }
}

#pragma mark - IBinaryWriter

unsigned int BinaryWriter::WriterGetPosition()
{
    return _position;
}

void BinaryWriter::WriterSetPosition(unsigned int position)
{
    _position = position;
    int result = fseek(_file, _position, SEEK_SET);
    result = result;
}

unsigned int BinaryWriter::WriterGetSize()
{
    unsigned int position = WriterGetPosition();
    
    fseek(_file, 0, SEEK_END);
    unsigned int result = ftell(_file);
    fseek(_file, position, SEEK_SET);
    return result;
}

void BinaryWriter::WriterWriteInt(int value)
{
    fwrite(&value, sizeof(value), 1, _file);
    _position += sizeof(value);
}

void BinaryWriter::WriterWriteFloat(float value)
{
    fwrite(&value, sizeof(value), 1, _file);
    _position += sizeof(value);
}

void BinaryWriter::WriterWriteUInt(unsigned int value)
{
    fwrite(&value, sizeof(value), 1, _file);
    _position += sizeof(value);
}

void BinaryWriter::WriterWriteBuffer(ByteBuffer *buffer)
{
    size_t result = fwrite(buffer->getPointer(), buffer->getDataSize(), 1, _file);
    result = result;
    _position += buffer->getDataSize();
}

void BinaryWriter::WriterWriteBuffer(const char *buffer, unsigned int length)
{
    size_t result = fwrite(buffer, length, 1, _file);
    result = result;
    _position += length;
}

void BinaryWriter::WriterWriteTile(char tile, unsigned int count)
{
    const int BUFFER_SIZE = 256;
    char data[BUFFER_SIZE];
    memset(data, tile, BUFFER_SIZE);
    size_t written = 0;
    while (written + BUFFER_SIZE < count) {
        fwrite(&data, BUFFER_SIZE, 1, _file);
        written += BUFFER_SIZE;
    }
    fwrite(&data, count - written, 1, _file);

    _position += count;
}

void BinaryWriter::WriterFlush()
{
    fflush(_file);
}

