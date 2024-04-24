#ifndef __testBase_h
#define __testBase_h

#include <gtest/gtest.h>


#define  TESTLOGD(...)  printf(__VA_ARGS__)


class ToolBaseTest : public ::testing::Test
{
protected:


	void SetUp() override
	{
		
	}

	void TearDown() override
	{
		
	}

};

#endif
