#include <iostream>
#include <anyoption.h>
#include <ByteBuffer.h>
#include <BinaryPack.hpp>
#include <BinaryPackUtilities.hpp>

int main() {
    std::cout << "Hello tools";

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


    return 0;
}
