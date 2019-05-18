//
//  BinaryWriterMemory.hpp
//  MAX
//
//  Created by Katekov Anton on 2/5/17.
//  Copyright © 2017 AntonKatekov. All rights reserved.
//

#ifndef BinaryWriterMemory_hpp
#define BinaryWriterMemory_hpp

#include <stdio.h>
#include "FileManager.h"
#include "ByteBuffer.h"



class BinaryWriterMemory : public IBinaryWriter {
    
    ByteBuffer *_destinationBuffer;
    unsigned int    _position;
    
public:
    
    ByteBuffer *GetDestinationBuffer() { return _destinationBuffer; }
    
    BinaryWriterMemory(ByteBuffer *destinationBuffer);
    ~BinaryWriterMemory();
    
#pragma mark - IBinaryWriter
    
public:
    
    unsigned int WriterGetPosition() override;
    void WriterSetPosition(unsigned int position) override;
    unsigned int WriterGetSize() override;
    
    void WriterWriteInt(int value) override;
    void WriterWriteUInt(unsigned int value) override;
    void WriterWriteBuffer(ByteBuffer *buffer) override;
    void WriterWriteBuffer(const char *buffer, unsigned int length) override;
    void WriterWriteTile(char tile, unsigned int count) override;
    
    void WriterFlush() override;
    
};

#endif /* BinaryWriterMemory_hpp */
