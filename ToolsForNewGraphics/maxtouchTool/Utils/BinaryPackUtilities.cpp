//
//  BinaryPackUtilities.cpp
//  MAX
//
//  Created by Katekov Anton on 3/26/16.
//  Copyright © 2016 AntonKatekov. All rights reserved.
//

#include "BinaryPackUtilities.hpp"
#include "BinaryWriterMemory.hpp"
#include "BinaryPack.hpp"
#include "ByteBuffer.h"
#include "ZipWrapper.h"



using namespace std;



string BinaryPackUtilities::ReadItemString(BinaryPackReader *reader, const string &name, bool *exist)
{
    BinaryPackItemHeader *item = reader->_binaryPack->Item(name);
    *exist = item != NULL;
    if (item)
    {
        string content = "";
        BinaryPackFlags flags = static_cast<BinaryPackFlags>(item->_flags);
        if (flags & BinaryPackFlags::Compressed)
        {
            ByteBuffer *buffer = new ByteBuffer();
            reader->ReadItemContent(item, buffer);
            ByteBuffer uncompressedBuffer;
            zip_decompress(reinterpret_cast<char*>(buffer->getPointer()), buffer->getDataSize(), &uncompressedBuffer);
            delete buffer;
            content = string(reinterpret_cast<char*>(uncompressedBuffer.getPointer()), uncompressedBuffer.getDataSize());
        }
        else
        {
            ByteBuffer buffer;
            reader->ReadItemContent(item, &buffer);
            content = string(reinterpret_cast<char*>(buffer.getPointer()), buffer.getDataSize());
        }
        return content;
    }
    
    return "";
}

void BinaryPackUtilities::ReadItemJson(BinaryPackReader *reader, const std::string &name, Json::Value &destination, bool *exist)
{
    string content = ReadItemString(reader, name, exist);
    
    if (*exist)
    {
        Json::Reader reader;
        reader.parse(content, destination);
        auto e = reader.getFormatedErrorMessages();
        if (e.size() > 0) {
            FileManager::SharedManager()->SaveFile("error_content.json", content.c_str(), content.length(), true);
            if (FileManager::SharedManager()->StorageSupported(FileManagerStorageType::FileManagerStorageType_External)) {
                FileManager::SharedManager()->SaveFile("error_content.json", content.c_str(), content.length(), true, FileManagerStorageType::FileManagerStorageType_External);
            }
        }
    }
}

void BinaryPackUtilities::ReadItemBuffer(BinaryPackReader *reader, const std::string &name, ByteBuffer *destination, bool *exist)
{
    BinaryPackItemHeader *item = reader->_binaryPack->Item(name);
    *exist = item != nullptr;
    if (item != nullptr)
    {
        reader->ReadItemContent(item, destination);
    }
}

BinaryPackItemHeader BinaryPackUtilities::WriteItemString(BinaryPackWriter *writer, const std::string &name, bool compress, const std::string &str)
{
    unsigned int flags = BinaryPackFlags::None;
    compress = false;
    if (compress)
    {
        flags |= BinaryPackFlags::Compressed;
        ByteBuffer buffer;
        zip_compress(const_cast<char*>(str.c_str()), str.length(), &buffer);
        return writer->Write(name, flags, buffer);
    }
    else
    {
        return writer->Write(name, flags, str.c_str(), static_cast<unsigned int>(str.length()));
    }
}

BinaryPackItemHeader BinaryPackUtilities::WriteItemString(BinaryPackWriter *writer, const std::string &name, bool compress, std::string &str, bool memorySaving)
{
    unsigned int flags = BinaryPackFlags::None;
    compress = false;
    if (compress)
    {
        flags |= BinaryPackFlags::Compressed;
        
        ByteBuffer buffer;
        zip_compress(const_cast<char*>(str.c_str()), str.length(), &buffer);
        if (memorySaving)
        {
            str.clear();
        }
        return writer->Write(name, flags, buffer);
    }
    else
    {
        return writer->Write(name, flags, str.c_str(), static_cast<unsigned int>(str.length()));
    }
}

BinaryPackItemHeader BinaryPackUtilities::WriteItemJson(BinaryPackWriter *writer, const std::string &name, bool compress, const Json::Value &root)
{
    string str;
    {
        Json::FastWriter jsonwriter;
        str = jsonwriter.write(root);
    }
    return WriteItemString(writer, name, compress, str, true);
}

BinaryPackItemHeader BinaryPackUtilities::WriteItemJson(BinaryPackWriter *writer, const std::string &name, bool compress, Json::Value &root, bool memorySaving)
{
    string str;
    {
        Json::FastWriter jsonwriter;
        str = jsonwriter.write(root);
    }
    if (memorySaving)
    {
        root.clear();
    }
    return WriteItemString(writer, name, compress, str, memorySaving);
}

BinaryPackItemHeader BinaryPackUtilities::WriteItemBuffer(BinaryPackWriter *writer, const std::string &name, ByteBuffer &buffer)
{
    unsigned int flags = BinaryPackFlags::None;
    return writer->Write(name, flags, buffer);
}

void BinaryPackUtilities::WriteItemStringToBuffer(ByteBuffer *destination, const std::string &name, bool compress, std::string &str, bool memorySaving)
{
    BinaryWriterMemory writer(destination);
    unsigned int flags = BinaryPackFlags::None;
    if (compress)
    {
        flags |= BinaryPackFlags::Compressed;
        
        ByteBuffer buffer;
        zip_compress(const_cast<char*>(str.c_str()), str.length(), &buffer);
        if (memorySaving)
        {
            str.clear();
        }
        BinaryPackWriter::Write(&writer, name, flags, reinterpret_cast<const char *>(buffer.getPointer()), static_cast<unsigned int>(buffer.getDataSize()));
    }
    else
    {
        BinaryPackWriter::Write(&writer, name, flags, str.c_str(), static_cast<unsigned int>(str.length()));
    }
}

void BinaryPackUtilities::WriteItemJsonToBuffer(ByteBuffer *destination, const std::string &name, bool compress, Json::Value &root, bool memorySaving)
{
    string str;
    {
        Json::FastWriter jsonwriter;
        str = jsonwriter.write(root);
    }
    if (memorySaving)
    {
        root.clear();
    }
    WriteItemStringToBuffer(destination, name, compress, str, memorySaving);
}
