#include <iostream>
#include <anyoption.h>
#include <ByteBuffer.h>
#include <BinaryPack.hpp>
#include <BinaryPackUtilities.hpp>
#include <MAXContentMap.h>
#include <MAXContentUtils.h>

int main() {
    std::cout << "Hello tools" << std::endl;;

    ByteBuffer b;
    MAXContentUtils::ReadFileToBuffer("Resources/1559135259.map", &b);

    BinaryPack p;
    BinaryPackReader pr(&p, &b);

    MAXContentMap map;
    map.Read(pr, false);

    std::cout << "read map " << map.w << "x" << map.h << std::endl;
    std::cout << "map blendmap is " << map._blendMap->GetWidth() << "x" << map._blendMap->GetHeigth() << std::endl;
    std::cout << "(editor just set it 10 times bigger)" << std::endl;
    return 0;
}
