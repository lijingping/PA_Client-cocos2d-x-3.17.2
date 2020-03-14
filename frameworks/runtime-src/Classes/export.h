#pragma once

#include "stdafx.h"

#include <vector>
#include <string.h>


extern "C"
{
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"
}


using namespace std;

class CExport
{
public:
	CExport();
	~CExport();
};

