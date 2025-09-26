#include "ProcessUnits.hpp"
#include <filesystem>
#include <fstream>
#include <FileManager.h>
#include <ByteBuffer.h>
#include <MAXContentUtils.h>


void readBinary(const std::string& path, ByteBuffer& destination)
{
    std::filesystem::path fsPath(path);
    if (!std::filesystem::exists(fsPath)) {
        throw std::runtime_error("Input path does not exist: " + fsPath.string());
    }

    MAXContentUtils::ReadFileToBuffer(fsPath.string(), &destination);
}

void readJson(const std::string& path, Json::Value &destination)
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


std::string toAbsolutePath(const std::string& path)
{
    std::filesystem::path fsPath(path);
    if (fsPath.is_absolute())
        return fsPath.string();
    return std::filesystem::absolute(fsPath).string();
}

std::vector<std::string> getDirectoriesInPath(const std::string& inputPath)
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


ProcessUnits::ProcessUnits(const ProcessOptions& options, const std::string& inputPath, const std::string& outputPath)
    : _options(options), _inputPath(inputPath), _outputPath(outputPath)
{
    if (!std::filesystem::exists(_inputPath)) {
        throw std::runtime_error("Input path does not exist: " + _inputPath);
	}
    auto directories = getDirectoriesInPath(_inputPath);
    for (const auto& dir : directories) {
		_units.push_back(std::make_shared<ProcessUnit>(_options, dir, _outputPath));
    }
}

void ProcessUnits::process()
{
    if (_units.size() != 0) {
        _units[0]->process();
    }
}



ProcessUnitInputSettings::SpriteSettings::SpriteSettings(const Json::Value& value)
{

}

ProcessUnitInputSettings::ProcessUnitInputSettings(const std::string& inputPath)
{
    std::filesystem::path settingsPath = std::filesystem::absolute(inputPath + "/settings.json");
    readJson(settingsPath.string(), _raw);
}



ProcessUnit::ProcessUnit(const ProcessOptions& options, const std::string& inputPath, const std::string& outputPath)
	: _options(options), _inputPath(inputPath), _outputPath(outputPath), _inputSettings(inputPath)
{
    
}

void ProcessUnit::process()
{
	_outputSettingsRaw["cellSize"] = _options._singleCellSize;

	std::string outputFolder = _inputSettings._raw["outputFolder"].asString();
	std::filesystem::path outputUnitPath = std::filesystem::absolute(_outputPath + "/" + outputFolder + "/");
    if (std::filesystem::exists(outputUnitPath)) {
        std::filesystem::remove_all(outputUnitPath);
    }
    if (!std::filesystem::exists(outputUnitPath)) {
        std::filesystem::create_directories(outputUnitPath);
	}

	// TODO: process unit
    
    // Write output settings
    std::filesystem::path outputSettingsPath = outputUnitPath.append( "settings.json");
    std::ofstream outputSettingsFile = std::ofstream(outputSettingsPath.string());
    if (!outputSettingsFile.is_open()) {
        throw std::runtime_error("Failed to open output settings file: " + outputSettingsPath.string());
    }
    
    outputSettingsFile << _outputSettingsRaw.toStyledString();
	outputSettingsFile.close();

}
