#include <iostream>
#include <anyoption.h>
#include <ByteBuffer.h>
#include <BinaryPack.hpp>
#include <BinaryPackUtilities.hpp>
#include <MAXContentMap.h>

int main() {
    std::cout << "Hello tools" << std::endl;;

    std::ifstream file("Resources/1559135259.map", std::ifstream::binary);
    file.seekg(0, std::ifstream::end);
    size_t fsize = file.tellg();
    file.seekg(0, std::ifstream::beg);

    ByteBuffer b(fsize);
    b.increaseBuffer();
    file.read(reinterpret_cast<char *>(b.getPointer()), fsize);
    b.dataAppended(fsize);
    file.close();

    BinaryPack p;
    BinaryPackReader pr(&p, &b);

    MAXContentMap map;
    map.Read(pr, false);

    std::cout << "read map " << map.w << "x" << map.h << std::endl;
    std::cout << "map blendmap is " << map._blendMap->GetWidth() << "x" << map._blendMap->GetHeigth() << std::endl;
    std::cout << "(editor just set it 10 times bigger)" << std::endl;
    return 0;
}
