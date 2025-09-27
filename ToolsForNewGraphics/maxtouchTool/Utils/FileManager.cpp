//
//  FileManager.cpp
//  maxtouchTool
//
//  Created by Katekov Anton on 5/19/19.
//  Copyright © 2019 katekovanton. All rights reserved.
//

#include "FileManager.h"
#include <filesystem>
#include "MAXContentUtils.h"
#include "ByteBuffer.h"



IBinaryReader::~IBinaryReader()
{}

IBinaryWriter::~IBinaryWriter()
{}



void FileManager::readBinary(const std::string& path, ByteBuffer& destination)
{
    std::filesystem::path fsPath(path);
    if (!std::filesystem::exists(fsPath)) {
        throw std::runtime_error("Input path does not exist: " + fsPath.string());
    }

    MAXContentUtils::ReadFileToBuffer(fsPath.string(), &destination);
}

void FileManager::readJson(const std::string& path, Json::Value& destination)
{
    std::filesystem::path fsPath(path);
    if (!std::filesystem::exists(fsPath)) {
        throw std::runtime_error("Input path does not exist: " + fsPath.string());
    }
    ByteBuffer buffer;
    readBinary(path, buffer);
    std::string jsonStr((const char*)buffer.getPointer(), buffer.getDataSize());

    Json::Reader reader;
    if (!reader.parse(jsonStr, destination)) {
        throw std::runtime_error("Failed to parse json: " + fsPath.string() + " error: " + reader.getFormatedErrorMessages());
    }
}

std::string FileManager::toAbsolutePath(const std::string& path)
{
    std::filesystem::path fsPath(path);
    if (fsPath.is_absolute())
        return fsPath.string();
    return std::filesystem::absolute(fsPath).string();
}

std::vector<std::string> FileManager::getDirectoriesInPath(const std::string& inputPath)
{
    std::string absInputPath = inputPath;// toAbsolutePath(inputPath);
    std::vector<std::string> directories;
    for (const auto& entry : std::filesystem::directory_iterator(absInputPath))
    {
        if (entry.is_directory())
        {
            directories.push_back(entry.path().string());
        }
    }
    return directories;
}
