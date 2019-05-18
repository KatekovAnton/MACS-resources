//
//  StringUtils.h
//  MAX
//
//  Created by  Developer on 16.02.13.
//  Copyright (c) 2013 AntonKatekov. All rights reserved.
//

#ifndef __MAX__StringUtils__
#define __MAX__StringUtils__

#include <iostream>
#include <map>
#include <vector>

std::vector<std::string> splitTest ( std::string input , std::string split_id );

std::vector<std::string> &split(const std::string &s, char delim, std::vector<std::string> &elems);

std::vector<std::string> splitString(const std::string &s, char delim);

std::vector<std::string> splitString(const std::string &s, std::string delim);

std::vector<std::string> getElements(std::string value);

std::vector<std::string> removeCommentsAndEmptyStrings(std::vector<std::string> lines);

std::string intToString(int value);
std::string longToString(long value);

std::string floatToString(float value);
float stringToFloat(std::string value);

void removeBadCharacters(std::string &param);

std::string toLower(std::string value);

std::string base64_encode(unsigned char const* , unsigned int len);
std::string base64_decode(std::string const& s);

void pushBackIfNotExists(std::vector<std::string> &vector, std::string &value);
void pushBackIfNotExists(std::vector<std::string> &vector, const char *value);

std::string formattedTimeAgoString(unsigned long long time);

template <typename objectType>
void removeObjectsFromVertor(std::vector<objectType> &vector, std::function<bool(const objectType&)> compare)
{
    bool found = true;
    size_t scanned = 0;
    while (found)
    {
        found = false;
        for (auto i = vector.begin() + scanned; i != vector.end(); i++)
        {
            if (compare(*i)) {
                vector.erase(i);
                found = true;
                break;
            }
            scanned ++;
        }
    }
}

template <typename objectKey, typename objectType>
void removeObjectsFromMap(std::map<objectKey, objectType> &map, std::function<bool(const objectType&)> compare)
{
    bool found = true;
    while (found)
    {
        found = false;
        for (auto i = map.begin(); i != map.end(); i++)
        {
            if (compare(i->second)) {
                map.erase(i);
                found = true;
                break;
            }
        }
    }
}

template <typename objectType>
void removeObjectsFromVertor1(std::vector<objectType> &vector, std::function<bool(const objectType&)> compare)
{
    bool found = true;
    size_t scanned = 0;
    while (found)
    {
        found = false;
        for (auto i = vector.begin() + scanned; i != vector.end(); i++)
        {
            if (compare(*i)) {
                vector.erase(i);
                found = true;
                break;
            }
            scanned ++;
        }
    }
}

template <typename objectType>
void removeObjectsFromVertor(std::vector<objectType> &vector, std::function<bool(objectType&)> compare)
{
    bool found = true;
    size_t scanned = 0;
    while (found)
    {
        found = false;
        for (auto i = vector.begin() + scanned; i != vector.end(); i++)
        {
            if (compare(*i)) {
                vector.erase(i);
                found = true;
                break;
            }
            scanned ++;
        }
    }
    
}

#endif /* defined(__MAX__StringUtils__) */
