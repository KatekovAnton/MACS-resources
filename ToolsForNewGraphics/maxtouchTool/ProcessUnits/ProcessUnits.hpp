//
//  ProcessUnits.hpp
//  MAX
//
//  Created by Katekov Anton on 27/09/25.
//  Copyright © 2016 AntonKatekov. All rights reserved.
//

#ifndef ProcessUnits_hpp
#define ProcessUnits_hpp

#include <stdio.h>
#include <memory>
#include <map>
#include <string>
#include <sstream>
#include "json/json.h"
#include "ProcessOptions.hpp"



class ProcessUnit;



class ProcessUnits {
	
	std::string _inputPath;
	std::string _outputPath;
	ProcessOptions _options;

	std::vector<std::shared_ptr<ProcessUnit>> _units;

public:
	
	ProcessUnits(const ProcessOptions &options, const std::string &inputPath, const std::string &outputPath);

	void process();
};



struct ProcessUnitInputSettings {

	struct SpriteSettings {

		std::string _inputLighting;
		std::string _inputShadow;

		/*
	-(instancetype)initWithInputPath:(NSString*)inputPath
	outputPath : (NSString*)outputPath
	baseName : (NSString*)baseName
	rotation : (int)rotation;
	*/


		SpriteSettings(const Json::Value& value);
	};

	Json::Value _raw;

	int _method = 0;
	bool _singleDirection = false;
	int _singleDirectionFrame = 0;
	float _scale = 1;

	std::string _inputDiffuseAlpha;
	std::string _inputDiffuse;
	std::string _inputAO;
	std::string _inputNormals;
	std::string _inputStripes;

	std::string _outputDiffuse;
	std::string _outputDiffusePNG;
	std::string _outputNormals;
	std::string _outputStripes;
	std::string _outputSettings;
	std::string _outputShadow;
	std::string _outputLight;

	std::vector<SpriteSettings> _rotatedSpritesData;
	/*
	-(instancetype)initWithInputPath:(NSString*)inputPath
	outputPath : (NSString*)outputPath
	baseName : (NSString*)baseName
	settings : (NSDictionary*)settings;
	*/

	ProcessUnitInputSettings(const std::string& inputPath);
};

class ProcessUnit {

	std::string _inputPath;
	std::string _outputPath;
	ProcessOptions _options;

	ProcessUnitInputSettings _inputSettings;
	Json::Value _outputSettingsRaw;

public:

	ProcessUnit(const ProcessOptions& options, const std::string& inputPath, const std::string& outputPath);

	void process();
};

#endif