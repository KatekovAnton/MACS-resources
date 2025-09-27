#include <iostream>
#include <anyoption.h>
#include <ByteBuffer.h>
#include <BinaryPack.hpp>
#include <BinaryPackUtilities.hpp>
#include <MAXContentMap.h>
#include <MAXContentUtils.h>
#include <ProcessUnits.hpp>



int main(const int argc, char** argv) {
    
	AnyOption opt;

	// usage
	// -a=[units, maps] - action to perform
	// -i="..\..\DataInputShort" - input folder with units or map file path
	// -o="..\..\..\_max_files\res_output" - folder for output files
	// together
	// -a=units -i="..\DataInputShort" -o="..\..\_max_files\res_output"
    // mac:
    // -a=units -i="../../../DataInputShort" -o="-a=units -i="../../../DataInputShort" -o="../../../../_MAXFiles/_resOutput"
	opt.autoUsagePrint(true);
	opt.setOption('a');
	opt.setOption('i');
	opt.setOption('o');

	opt.processCommandArgs(argc, argv);

    char *flagAC = opt.getValue('a');
    if (!flagAC) {
        std::cerr << "Action is not specified" << std::endl;
        return 1;
    }
    std::string_view flagA = flagAC;
	if (flagA.empty()) {
		std::cerr << "Action is not specified" << std::endl;
		return 1;
	}
    
    char *flagIC = opt.getValue('i');
    if (!flagIC) {
        std::cerr << "Input folder -i=\"...\" is not specified" << std::endl;
        return 1;
    }
	std::string_view flagI = flagIC;
	if (flagI.empty()) {
		std::cerr << "Input folder -i=\"...\" is not specified" << std::endl;
		return 1;
	}

    char *flagOC = opt.getValue('o');
    if (!flagOC) {
        std::cerr << "Output folder -o=\"...\" is not specified" << std::endl;
        return 1;
    }
	std::string_view flagO = opt.getValue('o');
	if (flagO.empty()) {
		std::cerr << "Output folder -o=\"...\" is not specified" << std::endl;
		return 1;
	}
	
	if (flagA == "units") {

		std::cout << "Read units " << flagI << std::endl;
		try {
			ProcessUnits processUnits = ProcessUnits(ProcessOptions(), std::string(flagI), std::string(flagO));
			processUnits.process();
		}
		catch (const std::exception& e) {
			std::cerr << "Error: " << e.what() << std::endl;
			return 1;
		}
		
		return 0;
	}

	if (flagA == "maps") {
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
	std::cerr << "Unknown action -a is specified" << std::endl;
    return 1;
}
