//
//  export.h
//  newBattleObj
//
//  Created by Lin on 2017/11/9.
//  Copyright © 2017年 admin. All rights reserved.
//

#ifndef export_h
#define export_h

#include <iostream>
#include <string.h>
#include <stdio.h>
#include <vector>
using namespace std;

extern "C"
{
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"
}

#include "Battle.h"

class newBattleObj{
public:
    newBattleObj();
    ~newBattleObj();

	//static void set_field_number(lua_State *L, const char *key, double value);
	//static void set_field_int(lua_State *L, const char *key, int value);
	//static void set_field_string(lua_State *L, const char *key, const char *value);
	//static void set_field_bool(lua_State *L, const char *key, const bool value);

	//static int query_bullets(lua_State *m_pStack);

    lua_State *m_pStack;
private:
    
};


#endif
