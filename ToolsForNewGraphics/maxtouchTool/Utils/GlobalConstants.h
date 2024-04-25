
#ifndef _GlobalConstants_h
#define _GlobalConstants_h

#include <cstddef>

#if defined MAX_TARGET_OS_MAC
#include <OpenGL/gl.h>
#endif
#if defined MAX_TARGET_OS_WIN
    #define NOMINMAX
	#include <windows.h>
	
	#include "wchar.h"
	#include <GL/gl.h>
	#include <GL/glu.h>
#endif

#define GCCHECK_GL_ERROR_DEBUG() \
        {GLenum __error = glGetError(); \
        if(__error)  \
		printf("OpenGL error 0x%04X in %s %s %d\n", __error, __FILE__, __FUNCTION__, __LINE__); }
#if defined TARGET_OS_MAC
#include <OpenGL/OpenGL.h>
#endif

typedef struct _vertexStruct
{
    GLfloat position[3];
    GLfloat tcoord[2];
    GLfloat color[4];
    
    enum
    {
        ATTRIB_POSITION,
        ATTRIB_TCOORD,
        ATTRIB_COLOR,
        ATTRIB_COUNT
    };
    
} vertexStruct;

static const int vertexStructSize = sizeof(vertexStruct);
static const size_t vertexStructOffsets[vertexStruct::ATTRIB_COUNT] = {
    offsetof(vertexStruct, position),
    offsetof(vertexStruct, tcoord),
    offsetof(vertexStruct, color)
};



typedef struct _vertexBatchObjectStruct
{
    GLfloat position[3];
    GLfloat tcoord[2];
    GLfloat color[4];
    GLfloat alpha;
    
    enum
    {
        ATTRIB_POSITION,
        ATTRIB_TCOORD,
        ATTRIB_COLOR,
        ATTRIB_ALPHA,
        ATTRIB_COUNT
    };
    
} vertexBatchObjectStruct;

static const int vertexBatchObjectStructSize = sizeof(vertexBatchObjectStruct);
static const size_t vertexBatchObjectStructOffsets[vertexBatchObjectStruct::ATTRIB_COUNT] = {
    offsetof(vertexBatchObjectStruct, position),
    offsetof(vertexBatchObjectStruct, tcoord),
    
    offsetof(vertexBatchObjectStruct, color),
    offsetof(vertexBatchObjectStruct, alpha)
};



typedef struct _vertexParticleStruct
{
    GLfloat positionTcoord[4];
    GLfloat particleBornTimeLifeTimeAlphaAngle[4];
    GLfloat particleColorRandom[4];
    GLfloat particleScale[2];
    
    GLfloat emitterPositionDirection[4]; //direction is normalized vector * particle speed
    
    enum
    {
        ATTRIB_POSITION_TCOORD,
        
        ATTRIB_PARTICLE_BORNTIME_LIFETIME_ALPHA_ANGLE,//particleBornTimeLifeTimeAlphaAngle
        ATTRIB_PARTICLE_COLOR_RANDOM,
        ATTRIB_PARTICLE_SCALE,
        
        ATTRIB_EMITTER_POSITION_DIRECTION,
        ATTRIB_COUNT
    };
    
} vertexParticleStruct;

static const int vertexParticleStructSize = sizeof(vertexParticleStruct);
static const size_t vertexParticleStructOffsets[vertexParticleStruct::ATTRIB_COUNT] = {
    offsetof(vertexParticleStruct, positionTcoord),
    
    offsetof(vertexParticleStruct, particleBornTimeLifeTimeAlphaAngle),
    offsetof(vertexParticleStruct, particleColorRandom),
    offsetof(vertexParticleStruct, particleScale),
    
    offsetof(vertexParticleStruct, emitterPositionDirection)
};


// Uniform index.
enum
{
    UNIFORM_MODEL_MATRIX        = 0,
    UNIFORM_VIEW_MATRIX         = 1,
    UNIFORM_PROJECTION_MATRIX   = 2,
    UNIFORM_NORMAL_MATRIX       = 3,
    UNIFORM_COLOR_TEXTURE       = 4,
    UNIFORM_ALPHA               = 5,
    UNIFORM_VECTOR1             = 6,
    UNIFORM_VECTOR2             = 7,
    UNIFORM_COLOR_TEXTURE1      = 8,
    UNIFORM_LIGHTPOSITION       = 9,
    UNIFORM_COLOR_TEXTURE2      = 10,
    UNIFORM_COLOR_TEXTURE3      = 11,
    UNIFORM_FLOATPARAM1         = 12,
    UNIFORM_FLOATPARAM2         = 13,
    UNIFORM_FLOATPARAM3         = 14,
    UNIFORM_FLOATPARAM4         = 15,
    UNIFORM_FLOATPARAM5         = 16,
    UNIFORM_INTPARAM1         = 17,
    UNIFORM_INTPARAM2         = 18,
    UNIFORM_INTPARAM3         = 19,
    UNIFORM_INTPARAM4         = 20,
    NUM_UNIFORMS
};

#endif
