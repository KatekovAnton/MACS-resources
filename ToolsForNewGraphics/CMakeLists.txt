cmake_minimum_required(VERSION 3.20.0...3.31.0)
set(CMAKE_CXX_STANDARD 20)

project(MACS_TOOL
    VERSION 18.1.0
    LANGUAGES C CXX)

include(FetchContent)
include(CTest)

set(PROJECT_DIR "${CMAKE_CURRENT_SOURCE_DIR}/maxtouchTool")
set(CMAKE_XCODE_GENERATE_TOP_LEVEL_PROJECT_ONLY ON)

if(APPLE)
    SET(PROJECT_OS_MACOS TRUE BOOL INTERNAL)
elseif(WIN32)
    SET(PROJECT_OS_WIN32 TRUE BOOL INTERNAL)
elseif(UNIX AND NOT APPLE)
    SET(PROJECT_OS_LINUX TRUE BOOL INTERNAL)
endif()

if(PROJECT_OS_MACOS)
    set(BUILD_PLATFORM MAC)
    set(ENABLE_BUILD_TEST true)
    set(ENABLE_data_copy true)
elseif(PROJECT_OS_WIN32)
    set(BUILD_PLATFORM WIN)
    set(ENABLE_BUILD_TEST true)
    set(ENABLE_data_copy true)

    add_definitions(-D_USE_MATH_DEFINES)
    add_definitions(-D_USRDLL)
    add_definitions(-DUNICODE -D_UNICODE)
    add_definitions(-DHAVE_STRUCT_TIMESPEC)
elseif(PROJECT_OS_LINUX)
    set(BUILD_PLATFORM LINUX)
    set(ENABLE_BUILD_TEST true)
    set(ENABLE_data_copy true)

    add_definitions (-DLUA_USE_LINUX )
endif()

add_definitions (-DMAX_TARGET_OS_${BUILD_PLATFORM} )
add_definitions (-D${BUILD_PLATFORM} )

set(BUILD_SHARED_LIBS OFF CACHE BOOL "" FORCE)


#add_definitions (-DCOCOS2D_DEBUG=2)
if (CMAKE_BUILD_TYPE STREQUAL "Debug")
    add_definitions(-DDEBUG)
endif()

###############################################################################
# Common libs

# any option
add_subdirectory(Vendors/AnyOption)

# zlib
add_subdirectory(Vendors/zlib)

# freetype
set(FT_WITH_HARFBUZZ OFF CACHE BOOL "Improve auto-hinting of OpenType fonts." FORCE)
set(FT_DISABLE_HARFBUZZ TRUE CACHE BOOL "Improve auto-hinting of OpenType fonts." FORCE)

# pmp
set(PMP_BUILD_VIS OFF CACHE BOOL "Build the PMP visualization tools." FORCE)

# png
set(PNG_SHARED OFF CACHE BOOL "Build shared lib" FORCE)
set(PNG_TESTS OFF CACHE BOOL "Build libpng tests" FORCE)
set(PNG_ARM_NEON off CACHE BOOL "Enable ARM NEON optimizations" FORCE)
set(SKIP_INSTALL_ALL 1)
set(ZLIB_INCLUDE_DIR ${zlib_SOURCE_DIR} ${zlib_BINARY_DIR})
set(ZLIB_LIBRARY zlibstatic)
if(NOT TARGET ZLIB::ZLIB)
    add_library(ZLIB::ZLIB ALIAS ${ZLIB_LIBRARY})
endif()
add_subdirectory(Vendors/png)



if (PROJECT_OS_WIN32 OR PROJECT_OS_LINUX)
    FetchContent_Declare(
        glfw
        GIT_REPOSITORY https://github.com/glfw/glfw.git
        GIT_TAG        b0796109629931b6fa6e449c15a177845256a407 # 3.3
    )
    FetchContent_MakeAvailable(glfw)

    FetchContent_Declare(
        glew
        GIT_REPOSITORY https://github.com/Perlmint/glew-cmake.git
        GIT_TAG        f456deace7b408655109aaeff71421ef2d3858c6 # 2.2.0
    )
    FetchContent_MakeAvailable(glew)

    FetchContent_Declare(
        libfreetype
        GIT_REPOSITORY https://github.com/freetype/freetype.git
        GIT_TAG        VER-2-13-2
    )
    FetchContent_MakeAvailable(libfreetype)
    include_directories(${libfreetype_SOURCE_DIR}/include)
endif()



add_library(basis_universal STATIC
Vendors/basis_universal/zstd/zstddeclib.c
Vendors/basis_universal/transcoder/basisu_transcoder.cpp
)



###############################################################################
# Prepare targets

set(SRC_DIR "${CMAKE_CURRENT_SOURCE_DIR}/src")

set(SOURCE_DIRS
Packing
Utils
Utils/libJSON
Utils/MathKit
Utils/Texture
MAX
ProcessUnits
)

foreach(DIR ${SOURCE_DIRS})

    include_directories(${PROJECT_DIR}/${DIR})
    list(APPEND ALL_INCLUDES ${PROJECT_DIR}/${DIR})
    
	file(GLOB HEADERS_H ${PROJECT_DIR}/${DIR}/*.h )
	file(GLOB HEADERS_HPP ${PROJECT_DIR}/${DIR}/*.hpp )
	
    file(GLOB SOURCES_C ${PROJECT_DIR}/${DIR}/*.c )
    file(GLOB SOURCES_CPP ${PROJECT_DIR}/${DIR}/*.cpp )
    
    if (APPLE)
        file(GLOB SOURCES_MM ${PROJECT_DIR}/${DIR}/*.mm )
        file(GLOB SOURCES_M ${PROJECT_DIR}/${DIR}/*.m)
    endif()
    
	list(APPEND ALL_HEADERS ${HEADERS_H} ${HEADERS_HPP})
	list(APPEND ALL_SOURCES ${SOURCES_C} ${SOURCES_CPP} ${SOURCES_M} ${SOURCES_MM})
	
endforeach(DIR)


file(GLOB_RECURSE RESOURCE_FILES
    ${PROJECT_DIR}/Resources/*
)


if (PROJECT_OS_WIN32 OR PROJECT_OS_LINUX OR PROJECT_OS_MACOS) 
    list(APPEND ALL_SOURCES
    ${PROJECT_DIR}/main.cpp
    )
endif()


if (PROJECT_OS_WIN32)
    add_executable(${PROJECT_NAME} ${ALL_HEADERS} ${ALL_SOURCES} ${RESOURCE_FILES})
    target_compile_definitions(${PROJECT_NAME} PRIVATE WIN32CONSOLE)
else()
    add_executable(${PROJECT_NAME} ${ALL_HEADERS} ${ALL_SOURCES} ${RESOURCE_FILES})
endif()


include_directories(${PROJECT_NAME} PRIVATE ${ZLIB_INCLUDE_DIR})
include_directories(${PROJECT_NAME} PRIVATE Vendors/AnyOption)
include_directories(${PROJECT_NAME} PRIVATE Vendors/basis_universal)
target_include_directories(${PROJECT_NAME}
PRIVATE
    ${zlib_SOURCE_DIR} ${zlib_BINARY_DIR}
    ${libpng_SOURCE_DIR} ${libpng_BINARY_DIR}
)


set(MAX_LIBRARIES 
    zlibstatic
    png_static
    anyoption
    basis_universal
)
target_link_libraries (${PROJECT_NAME} ${MAX_LIBRARIES})


if (PROJECT_OS_MACOS)
    list(APPEND MAX_LIBRARIES
            xml2
            pthread
        )

    set(CMAKE_XCODE_ATTRIBUTE_ONLY_ACTIVE_ARCH[variant=Debug] "YES")
    set_target_properties(${PROJECT_NAME} PROPERTIES 
        # MACOSX_BUNDLE_INFO_PLIST ${CMAKE_CURRENT_SOURCE_DIR}/MAXNewOSX/MAXNewOSX-Info.plist
        # XCODE_ATTRIBUTE_ASSETCATALOG_COMPILER_APPICON_NAME "AppIcon"
        XCODE_ATTRIBUTE_SKIP_INSTALL NO
        XCODE_ATTRIBUTE_INSTALL_PATH "$(LOCAL_APPS_DIR)"
        XCODE_ATTRIBUTE_ONLY_ACTIVE_ARCH[variant=Debug] "YES"
        XCODE_GENERATE_SCHEME ON
    )
elseif (PROJECT_OS_LINUX)
    list(APPEND MAX_LIBRARIES
        glfw libglew_static
        alut
        openal
        freetype
        vorbis
        vorbisfile
        )

    target_link_libraries (${PROJECT_NAME} ${MAX_LIBRARIES} ${CMAKE_DL_LIBS})

elseif (PROJECT_OS_WIN32)
    list(APPEND MAX_LIBRARIES
        glfw libglew_static
    )

    target_include_directories(${PROJECT_NAME} PRIVATE ${glew_SOURCE_DIR}/include)

    target_link_libraries (${PROJECT_NAME} ${LIBS} ${CMAKE_DL_LIBS})

    target_link_libraries (${PROJECT_NAME}
        legacy_stdio_definitions.lib
        opengl32.lib
        freetype
        ${MAX_LIBRARIES}
    )

    # add_compile_options(/wd4068)
    if(MSVC)
        target_compile_options(${PROJECT_NAME} 
            PRIVATE
                "/wd4068;" # disable "unknown pragma 'mark'" warnings
        )
    endif()

    macro(copy_dlls TARGET_NAME SRC_DIR DST_DIR)
        file(GLOB_RECURSE RESOURCE_FILES
            ${SRC_DIR}/*.dll
        )

        unset(OUT_RESOURCE_FILES)
        foreach(RES_FILE ${RESOURCE_FILES})
            file(RELATIVE_PATH RES_FILE_RELPATH ${SRC_DIR} ${RES_FILE})
            set(OUT_RES_FILE ${DST_DIR}/${RES_FILE_RELPATH})
            add_custom_command( OUTPUT ${OUT_RES_FILE}
                                COMMAND ${CMAKE_COMMAND} -E copy ${RES_FILE} ${OUT_RES_FILE}
                                DEPENDS ${RES_FILE})
            list(APPEND OUT_RESOURCE_FILES ${OUT_RES_FILE})
        endforeach()

        add_custom_target(${TARGET_NAME} ALL DEPENDS ${OUT_RESOURCE_FILES})
    endmacro()

    #copy_dlls(${PROJECT_NAME}_copy_dlls_audio ${AUDIO_LIBS_PATH} ${CMAKE_BINARY_DIR})
    #add_dependencies(${PROJECT_NAME} ${PROJECT_NAME}_copy_dlls_audio)
endif()


macro(copy_files TARGET_NAME SRC_DIR DST_DIR)
    file(GLOB_RECURSE RESOURCE_FILES ${SRC_DIR}/* )

    unset(OUT_RESOURCE_FILES)
    foreach(RES_FILE ${RESOURCE_FILES})
        file(RELATIVE_PATH RES_FILE_RELPATH ${SRC_DIR} ${RES_FILE})
        set(OUT_RES_FILE ${DST_DIR}/${RES_FILE_RELPATH})
        add_custom_command( OUTPUT ${OUT_RES_FILE}
                            COMMAND ${CMAKE_COMMAND} -E copy ${RES_FILE} ${OUT_RES_FILE}
                            DEPENDS ${RES_FILE})
        list(APPEND OUT_RESOURCE_FILES ${OUT_RES_FILE})
    endforeach()

    add_custom_target(${TARGET_NAME} ALL DEPENDS ${OUT_RESOURCE_FILES})
    
endmacro()


if (ENABLE_data_copy)
    copy_files(${PROJECT_NAME}_copy_data ${CMAKE_CURRENT_SOURCE_DIR}/maxtouchTool/Resources ${CMAKE_BINARY_DIR}/Resources)
    add_dependencies(${PROJECT_NAME} ${PROJECT_NAME}_copy_data)
endif()


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# Tests
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 

if (ENABLE_BUILD_TEST)
    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    # Configure Tests
    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

    FetchContent_Declare(
            googletest
            GIT_REPOSITORY https://github.com/google/googletest.git
            GIT_TAG        e2239ee6043f73722e7aa812a459f54a28552929 # release-1.11.0
    )
    set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
    FetchContent_MakeAvailable(googletest)

    file(GLOB_RECURSE PROJECT_TEST_SOURCES
    ${PROJECT_SOURCE_DIR}/maxtouchToolTests/*.*
    )

    list(REMOVE_ITEM ALL_SOURCES "${PROJECT_DIR}/main.cpp")
    list(APPEND PROJECT_TEST_SOURCES ${ALL_HEADERS} ${ALL_SOURCES})

    add_executable(${PROJECT_NAME}Tests ${PROJECT_TEST_SOURCES})
    add_dependencies(${PROJECT_NAME}Tests gtest)
    add_dependencies(${PROJECT_NAME}Tests ${PROJECT_NAME}_copy_data)
    #add_dependencies(${PROJECT_NAME}Tests ${PROJECT_NAME}_copy_shaders)


    target_include_directories(${PROJECT_NAME}Tests PRIVATE maxtouchTool)
    target_include_directories(${PROJECT_NAME}Tests PRIVATE maxtouchToolTests)
    target_include_directories(${PROJECT_NAME}Tests PRIVATE ${ALL_INCLUDES})
    target_compile_definitions(${PROJECT_NAME}Tests PRIVATE MAX_TESTS)
    target_compile_definitions(${PROJECT_NAME}Tests PRIVATE MAX_TARGET_OS_${BUILD_PLATFORM} )
    target_compile_definitions(${PROJECT_NAME}Tests PRIVATE ${BUILD_PLATFORM} )

    include_directories(${CMAKE_CURRENT_BINARY_DIR}/../googletest-src/googletest/include)
    include_directories(${CMAKE_CURRENT_BINARY_DIR}/../googletest-src/googlemock/include)

    target_link_libraries(${PROJECT_NAME}Tests gtest_main gmock_main)

    if (ENABLE_data_copy)
        copy_files(${PROJECT_NAME}_copy_test_data ${CMAKE_CURRENT_SOURCE_DIR}/Tests/Resources ${CMAKE_BINARY_DIR}/Resources)
        add_dependencies(${PROJECT_NAME}Tests ${PROJECT_NAME}_copy_test_data)
    endif()

    if (PROJECT_OS_MACOS)
        target_link_libraries(${PROJECT_NAME}Tests ${MAX_LIBRARIES})
        set_target_properties(${PROJECT_NAME}Tests PROPERTIES 
            # MACOSX_BUNDLE_INFO_PLIST ${CMAKE_CURRENT_SOURCE_DIR}/MAXNewOSX/MAXNewOSX-Info.plist
            # XCODE_ATTRIBUTE_ASSETCATALOG_COMPILER_APPICON_NAME "AppIcon"
            XCODE_ATTRIBUTE_SKIP_INSTALL NO
            XCODE_ATTRIBUTE_INSTALL_PATH "$(LOCAL_APPS_DIR)"
            XCODE_ATTRIBUTE_ONLY_ACTIVE_ARCH[variant=Debug] "YES"
            XCODE_GENERATE_SCHEME ON
        )
    endif()
    if (PROJECT_OS_LINUX)
        target_link_libraries(${PROJECT_NAME}Tests ${LIBS} ${MAX_LIBRARIES} ${CMAKE_DL_LIBS})
    endif()
    if (PROJECT_OS_WIN32)
        target_link_libraries(${PROJECT_NAME}Tests ${LIBS} ${MAX_LIBRARIES})
        target_link_libraries(${PROJECT_NAME}Tests dbghelp)
        target_link_libraries(${PROJECT_NAME}Tests
            legacy_stdio_definitions.lib
            winmm.lib
            Ws2_32.lib
            opengl32.lib
            freetype
            ${MAX_LIBRARIES}
        )
    endif()
    if (PROJECT_OS_MACOS)

        target_compile_definitions(${PROJECT_NAME}Tests PRIVATE USE_FILE32API)
        # target_compile_options(${PROJECT_NAME}Tests PUBLIC "-fobjc-arc")

        list(APPEND SRE_INCLUDE_DIRS /System/Library/Frameworks)

        target_link_libraries(${PROJECT_NAME}Tests "-framework Cocoa")
        target_link_libraries(${PROJECT_NAME}Tests "-framework CoreVideo")
        target_link_libraries(${PROJECT_NAME}Tests "-framework AppKit")
        target_link_libraries(${PROJECT_NAME}Tests "-framework Carbon")
        target_link_libraries(${PROJECT_NAME}Tests "-framework ForceFeedback")
        target_link_libraries(${PROJECT_NAME}Tests "-framework SystemConfiguration")
        target_link_libraries(${PROJECT_NAME}Tests "-framework IOKit")
        target_link_libraries(${PROJECT_NAME}Tests "-framework GLKit")
        target_link_libraries(${PROJECT_NAME}Tests "-framework OpenGL")
        target_link_libraries(${PROJECT_NAME}Tests "-framework Security")
        target_link_libraries(${PROJECT_NAME}Tests "-framework AudioToolbox")
        target_link_libraries(${PROJECT_NAME}Tests "-framework CoreAudio")
        target_link_libraries(${PROJECT_NAME}Tests "-framework OpenAL")
        target_link_libraries(${PROJECT_NAME}Tests "-lbsm")
        target_link_libraries(${PROJECT_NAME}Tests "-lc")
        target_link_libraries(${PROJECT_NAME}Tests libiconv.dylib)
        target_link_libraries(${PROJECT_NAME}Tests libxml2.dylib)

    endif()

endif()
