#include "lua-bindings/lua_pomelo_auto.hpp"
#include "CCPomelo.h"
#include "scripting/lua-bindings/manual/tolua_fix.h"
#include "scripting/lua-bindings/manual/LuaBasicConversions.h"

int lua_pomelo_CCPomelo_getState(lua_State* tolua_S)
{
    int argc = 0;
    CCPomelo* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"CCPomelo",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (CCPomelo*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_pomelo_CCPomelo_getState'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_pomelo_CCPomelo_getState'", nullptr);
            return 0;
        }
        int ret = cobj->getState();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "CCPomelo:getState",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_pomelo_CCPomelo_getState'.",&tolua_err);
#endif

    return 0;
}
int lua_pomelo_CCPomelo_disconnect(lua_State* tolua_S)
{
    int argc = 0;
    CCPomelo* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"CCPomelo",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (CCPomelo*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_pomelo_CCPomelo_disconnect'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_pomelo_CCPomelo_disconnect'", nullptr);
            return 0;
        }
        cobj->disconnect();
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "CCPomelo:disconnect",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_pomelo_CCPomelo_disconnect'.",&tolua_err);
#endif

    return 0;
}
int lua_pomelo_CCPomelo_request(lua_State* tolua_S)
{
    int argc = 0;
    CCPomelo* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"CCPomelo",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (CCPomelo*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_pomelo_CCPomelo_request'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 3) 
    {
        int arg0;
        const char* arg1;
        const char* arg2;

        ok &= luaval_to_int32(tolua_S, 2,(int *)&arg0, "CCPomelo:request");

        std::string arg1_tmp; ok &= luaval_to_std_string(tolua_S, 3, &arg1_tmp, "CCPomelo:request"); arg1 = arg1_tmp.c_str();

        std::string arg2_tmp; ok &= luaval_to_std_string(tolua_S, 4, &arg2_tmp, "CCPomelo:request"); arg2 = arg2_tmp.c_str();
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_pomelo_CCPomelo_request'", nullptr);
            return 0;
        }
        cobj->request(arg0, arg1, arg2);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "CCPomelo:request",argc, 3);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_pomelo_CCPomelo_request'.",&tolua_err);
#endif

    return 0;
}
int lua_pomelo_CCPomelo_cleanup(lua_State* tolua_S)
{
    int argc = 0;
    CCPomelo* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"CCPomelo",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (CCPomelo*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_pomelo_CCPomelo_cleanup'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_pomelo_CCPomelo_cleanup'", nullptr);
            return 0;
        }
        cobj->cleanup();
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "CCPomelo:cleanup",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_pomelo_CCPomelo_cleanup'.",&tolua_err);
#endif

    return 0;
}
int lua_pomelo_CCPomelo_getArray(lua_State* tolua_S)
{
    int argc = 0;
    CCPomelo* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"CCPomelo",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (CCPomelo*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_pomelo_CCPomelo_getArray'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        std::vector<std::string> arg0;

        ok &= luaval_to_std_vector_string(tolua_S, 2, &arg0, "CCPomelo:getArray");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_pomelo_CCPomelo_getArray'", nullptr);
            return 0;
        }
        std::vector<std::string> ret = cobj->getArray(arg0);
        ccvector_std_string_to_luaval(tolua_S, ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "CCPomelo:getArray",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_pomelo_CCPomelo_getArray'.",&tolua_err);
#endif

    return 0;
}
int lua_pomelo_CCPomelo_connect(lua_State* tolua_S)
{
    int argc = 0;
    CCPomelo* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"CCPomelo",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (CCPomelo*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_pomelo_CCPomelo_connect'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 2) 
    {
        const char* arg0;
        int arg1;

        std::string arg0_tmp; ok &= luaval_to_std_string(tolua_S, 2, &arg0_tmp, "CCPomelo:connect"); arg0 = arg0_tmp.c_str();

        ok &= luaval_to_int32(tolua_S, 3,(int *)&arg1, "CCPomelo:connect");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_pomelo_CCPomelo_connect'", nullptr);
            return 0;
        }
        cobj->connect(arg0, arg1);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "CCPomelo:connect",argc, 2);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_pomelo_CCPomelo_connect'.",&tolua_err);
#endif

    return 0;
}
int lua_pomelo_CCPomelo_getTable(lua_State* tolua_S)
{
    int argc = 0;
    CCPomelo* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"CCPomelo",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (CCPomelo*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_pomelo_CCPomelo_getTable'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        std::map<std::string, std::string> arg0;

        ok &= luaval_to_std_map_string_string(tolua_S, 2, &arg0, "CCPomelo:getTable");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_pomelo_CCPomelo_getTable'", nullptr);
            return 0;
        }
        std::map<std::string, std::string> ret = cobj->getTable(arg0);
        std_map_string_string_to_luaval(tolua_S, ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "CCPomelo:getTable",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_pomelo_CCPomelo_getTable'.",&tolua_err);
#endif

    return 0;
}
int lua_pomelo_CCPomelo_requestCallBack(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"CCPomelo",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 3)
    {
        const pc_request_s* arg0;
        int arg1;
        const char* arg2;
        #pragma warning NO CONVERSION TO NATIVE FOR pc_request_s*
		ok = false;
        ok &= luaval_to_int32(tolua_S, 3,(int *)&arg1, "CCPomelo:requestCallBack");
        std::string arg2_tmp; ok &= luaval_to_std_string(tolua_S, 4, &arg2_tmp, "CCPomelo:requestCallBack"); arg2 = arg2_tmp.c_str();
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_pomelo_CCPomelo_requestCallBack'", nullptr);
            return 0;
        }
        CCPomelo::requestCallBack(arg0, arg1, arg2);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "CCPomelo:requestCallBack",argc, 3);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_pomelo_CCPomelo_requestCallBack'.",&tolua_err);
#endif
    return 0;
}
int lua_pomelo_CCPomelo_eventCallBack(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"CCPomelo",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 5)
    {
        pc_client_s* arg0;
        int arg1;
        void* arg2;
        const char* arg3;
        const char* arg4;
        #pragma warning NO CONVERSION TO NATIVE FOR pc_client_s*
		ok = false;
        ok &= luaval_to_int32(tolua_S, 3,(int *)&arg1, "CCPomelo:eventCallBack");
        #pragma warning NO CONVERSION TO NATIVE FOR void*
		ok = false;
        std::string arg3_tmp; ok &= luaval_to_std_string(tolua_S, 5, &arg3_tmp, "CCPomelo:eventCallBack"); arg3 = arg3_tmp.c_str();
        std::string arg4_tmp; ok &= luaval_to_std_string(tolua_S, 6, &arg4_tmp, "CCPomelo:eventCallBack"); arg4 = arg4_tmp.c_str();
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_pomelo_CCPomelo_eventCallBack'", nullptr);
            return 0;
        }
        CCPomelo::eventCallBack(arg0, arg1, arg2, arg3, arg4);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "CCPomelo:eventCallBack",argc, 5);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_pomelo_CCPomelo_eventCallBack'.",&tolua_err);
#endif
    return 0;
}
int lua_pomelo_CCPomelo_getInstance(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"CCPomelo",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_pomelo_CCPomelo_getInstance'", nullptr);
            return 0;
        }
        CCPomelo* ret = CCPomelo::getInstance();
        object_to_luaval<CCPomelo>(tolua_S, "CCPomelo",(CCPomelo*)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "CCPomelo:getInstance",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_pomelo_CCPomelo_getInstance'.",&tolua_err);
#endif
    return 0;
}
static int lua_pomelo_CCPomelo_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (CCPomelo)");
    return 0;
}

int lua_register_pomelo_CCPomelo(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"CCPomelo");
    tolua_cclass(tolua_S,"CCPomelo","CCPomelo","cc.Ref",nullptr);

    tolua_beginmodule(tolua_S,"CCPomelo");
        tolua_function(tolua_S,"getState",lua_pomelo_CCPomelo_getState);
        tolua_function(tolua_S,"disconnect",lua_pomelo_CCPomelo_disconnect);
        tolua_function(tolua_S,"request",lua_pomelo_CCPomelo_request);
        tolua_function(tolua_S,"cleanup",lua_pomelo_CCPomelo_cleanup);
        tolua_function(tolua_S,"getArray",lua_pomelo_CCPomelo_getArray);
        tolua_function(tolua_S,"connect",lua_pomelo_CCPomelo_connect);
        tolua_function(tolua_S,"getTable",lua_pomelo_CCPomelo_getTable);
        tolua_function(tolua_S,"requestCallBack", lua_pomelo_CCPomelo_requestCallBack);
        tolua_function(tolua_S,"eventCallBack", lua_pomelo_CCPomelo_eventCallBack);
        tolua_function(tolua_S,"getInstance", lua_pomelo_CCPomelo_getInstance);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(CCPomelo).name();
    g_luaType[typeName] = "CCPomelo";
    g_typeCast["CCPomelo"] = "CCPomelo";
    return 1;
}
TOLUA_API int register_all_pomelo(lua_State* tolua_S)
{
    lua_getglobal(tolua_S, "_G");
    
    if (lua_istable(tolua_S,-1))//stack:...,_G,
    {
        tolua_open(tolua_S);
        
        tolua_module(tolua_S,"pomelo",0);
        tolua_beginmodule(tolua_S,"pomelo");

        lua_register_pomelo_CCPomelo(tolua_S);

        tolua_endmodule(tolua_S);
    }
    lua_pop(tolua_S, 1);
    
	return 1;
}

