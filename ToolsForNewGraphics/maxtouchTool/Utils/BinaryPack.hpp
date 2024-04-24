//
//  BinaryPack.hpp
//  MAX
//
//  Created by Katekov Anton on 3/18/16.
//  Copyright © 2016 AntonKatekov. All rights reserved.
//

#ifndef BinaryPack_hpp
#define BinaryPack_hpp

#include <stdio.h>
#include <memory>
#include <map>
#include <string>
#include <cstring>
#include "USimpleContainer.h"



class ByteBuffer;
class IBinaryReader;
class IBinaryWriter;
class BinaryPackReader;
class BinaryPackWriter;
class BinaryPackSource;



#define BINARY_PACK_HEADER_NAME_SIZE (32)
#define BINARY_PACK_HEADER_SIZE (BINARY_PACK_HEADER_NAME_SIZE + 4 + 4)



struct __BinaryPackItemHeader {
    char _name[BINARY_PACK_HEADER_NAME_SIZE];
    unsigned int _flags;
    unsigned int _size;
    
    long _offset;
    
    __BinaryPackItemHeader();
};
typedef __BinaryPackItemHeader BinaryPackItemHeader;



class BinaryPack {
    
    friend class BinaryPackReader;
    friend class BinaryPackWriter;
    
    std::string _filename;
    
    unsigned int _numberOfItems;
    Utils::USimpleContainer<BinaryPackItemHeader> _items;
    std::map<std::string, BinaryPackItemHeader*> _itemsHash;
    
    void ClearItems();
    void RefreshHash();
    
public:
    
    BinaryPack();
    BinaryPack(const std::string &filename);
    ~BinaryPack();
    
    std::string GetFileName() const { return _filename; }
    
    unsigned int NumberOfItems() const { return _numberOfItems; }
    void AddItem(const BinaryPackItemHeader &item);
    BinaryPackItemHeader *Item(const std::string &name);
    BinaryPackItemHeader *ItemAtIndex(unsigned int index);
    const BinaryPackItemHeader *ItemAtIndex(unsigned int index) const;
    
};



class BinaryPackReader {
    
    friend class BinaryPackUtilities;
    
    BinaryPack *_binaryPack;
    std::shared_ptr<IBinaryReader> _reader;

public:
    
    BinaryPackReader(BinaryPack *binaryPack);
    BinaryPackReader(BinaryPack *binaryPack, const ByteBuffer *source);
    BinaryPackReader(BinaryPack *binaryPack, std::shared_ptr<IBinaryReader> reader);
    
    BinaryPackItemHeader *Item(const std::string &name);
    void ReadItemContent(BinaryPackItemHeader *item, ByteBuffer *buffer);
    void Reload();
    
};



class BinaryPackWriter {
    
    BinaryPack *_binaryPack;
    std::shared_ptr<IBinaryWriter> _writer;
    
public:
    
    BinaryPackWriter(BinaryPack *binaryPack);
    BinaryPackWriter(BinaryPack *binaryPack, std::shared_ptr<IBinaryWriter> writer);
    
    void RemoveLastItems(unsigned int countToRemove);
    BinaryPackItemHeader Write(const std::string &name, unsigned int flags, ByteBuffer &body);
    BinaryPackItemHeader Write(const std::string &name, unsigned int flags, const char *body, unsigned int length);
    
    static BinaryPackItemHeader Write(IBinaryWriter *writer, const std::string &name, unsigned int flags, const char *body, unsigned int length);
    
};

#endif /* BinaryPack_hpp */
