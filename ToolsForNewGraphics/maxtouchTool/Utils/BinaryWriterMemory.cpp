//
//  BinaryWriterMemory.cpp
//  MAX
//
//  Created by Katekov Anton on 2/5/17.
//  Copyright © 2017 AntonKatekov. All rights reserved.
//

#include "BinaryWriterMemory.hpp"



BinaryWriterMemory::BinaryWriterMemory(ByteBuffer *destinationBuffer)
:_destinationBuffer(destinationBuffer)
,_position(static_cast<unsigned int>(destinationBuffer->getDataSize()))
{}

BinaryWriterMemory::~BinaryWriterMemory()
{}

unsigned int BinaryWriterMemory::WriterGetPosition()
{
    return _position;
}

void BinaryWriterMemory::WriterSetPosition(unsigned int position)
{
    _position = position;
}

unsigned int BinaryWriterMemory::WriterGetSize()
{
    return static_cast<unsigned int>(_destinationBuffer->getDataSize());
}

void BinaryWriterMemory::WriterWriteInt(int value)
{
    WriterWriteBuffer(reinterpret_cast<const char *>(&value), sizeof(value));
}

void BinaryWriterMemory::WriterWriteUInt(unsigned int value)
{
    WriterWriteBuffer(reinterpret_cast<const char *>(&value), sizeof(value));
}

void BinaryWriterMemory::WriterWriteBuffer(ByteBuffer *buffer)
{
    WriterWriteBuffer(reinterpret_cast<const char *>(buffer->getPointer()), static_cast<unsigned int>(buffer->getDataSize()));
}

void BinaryWriterMemory::WriterWriteBuffer(const char *buffer, unsigned int length)
{
    _destinationBuffer->appendData(reinterpret_cast<unsigned char *>(const_cast<char *>(buffer)), length, 1);
}

void BinaryWriterMemory::WriterWriteTile(char tile, unsigned int count)
{
    for (int i = 0; i < count; i++) {
        WriterWriteBuffer(reinterpret_cast<const char *>(&tile), sizeof(tile));
    }
}

void BinaryWriterMemory::WriterFlush()
{}
