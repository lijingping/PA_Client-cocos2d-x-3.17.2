/****************************************************************************
 Copyright (c) 2017-2018 Xiamen Yaji Software Co., Ltd.
 
 http://www.cocos2d-x.org
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ****************************************************************************/

#include "AppDelegate.h"
#include "scripting/lua-bindings/manual/CCLuaEngine.h"
#include "cocos2d.h"
#include "scripting/lua-bindings/manual/lua_module_register.h"
#include "scripting/lua-bindings/manual/network/lua_extensions.h"
#include "lua-bindings/lua_pomelo_auto.hpp"


#include <dirent.h>
#include <sys/stat.h>
#include <unistd.h>
#include "scripting/lua-bindings/manual/LuaBasicConversions.h"

// #define USE_AUDIO_ENGINE 1

#if USE_AUDIO_ENGINE
#include "audio/include/AudioEngine.h"
using namespace cocos2d::experimental;
#endif

USING_NS_CC;
using namespace std;

//extern "C" int luaopen_libpower(lua_State *L);

AppDelegate::AppDelegate()
{
}

AppDelegate::~AppDelegate()
{
#if USE_AUDIO_ENGINE
    AudioEngine::end();
#endif

#if (COCOS2D_DEBUG > 0) && (CC_CODE_IDE_DEBUG_SUPPORT > 0)
    // NOTE:Please don't remove this call if you want to debug with Cocos Code IDE
    RuntimeEngine::getInstance()->end();
#endif

}

// if you want a different context, modify the value of glContextAttrs
// it will affect all platforms
void AppDelegate::initGLContextAttrs()
{
    // set OpenGL context attributes: red,green,blue,alpha,depth,stencil,multisamplesCount
    GLContextAttrs glContextAttrs = {8, 8, 8, 8, 24, 8, 0 };

    GLView::setGLContextAttrs(glContextAttrs);
}

std::string toupperCase(const char* pString) {
    std::string copy(pString);
    std::transform(copy.begin(), copy.end(), copy.begin(), ::toupper);
    return copy;
}

//获取文件夹下所有文件名
std::vector<std::string> getAllFileNameByDirectory_android(std::string filePath)
{
    std::vector<std::string> path_vec;
    
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    std::string::size_type pos = filePath.find("assets/");
    std::string relativePath = filePath.substr(pos + strlen("assets/"));
    
    AAssetDir *dir = AAssetManager_openDir(FileUtilsAndroid::getAssetManager(), relativePath.c_str());
    if(dir == NULL)
    {
        CCLOG("getAllFileNameByDirectory_android cannot open %s",filePath.c_str());
        return path_vec;
    }
    
    const char *fileName = nullptr;
    while ((fileName = AAssetDir_getNextFileName(dir)) != nullptr)
    {
        path_vec.push_back(fileName);
    }
    
    AAssetDir_close(dir);
#endif
    return path_vec;
}

std::vector<std::string> getAllFileNameByDirectory(std::string filePath)
{
    filePath = FileUtils::getInstance()->fullPathForFilename(filePath);
    
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    std::string::size_type pos = filePath.find("assets/");
    if (pos != std::string::npos)
    {
        return getAllFileNameByDirectory_android(filePath);
    }
#endif
    
    std::vector<std::string> path_vec;
    DIR *dp;
    dirent *entry;
    struct stat statbuf;
    
    if((dp=opendir(filePath.c_str()))==NULL)
    {
        CCLOG("toLua_AppDelegate_getAllFileNameByDirectory cannot open %s",filePath.c_str());
        return path_vec;
    }
    chdir(filePath.c_str());
    
    while((entry=readdir(dp))!=NULL)
    {
        stat(entry->d_name,&statbuf);
        if(S_ISREG(statbuf.st_mode) || S_ISDIR(statbuf.st_mode))
        {
            string d_name = StringUtils::format("%s",entry->d_name);
            if (d_name == "."
                || d_name == ".."
                || toupperCase(d_name.c_str()) == ".DS_STORE"
                || toupperCase(d_name.c_str()) == "THUMBS.DB"
                || toupperCase(d_name.c_str()) == "DESKTOP.INI")
            {
                continue;
            }
            CCLOG("%s",filePath.c_str());
            path_vec.push_back(d_name);
        }
    }
    
    closedir(dp);
    
    return path_vec;
}

int toLua_AppDelegate_getAllFileNameByDirectory(lua_State* tolua_S)
{
    int argc = lua_gettop(tolua_S);
    if (argc == 1)
    {
        const char* path = lua_tostring(tolua_S, 1);
        if (path)
        {
            ccvector_std_string_to_luaval(tolua_S, getAllFileNameByDirectory(path));
            return 1;
        }
        else{
            CCLOG("toLua_AppDelegate_getAllFileNameByDirectory error path is null");
        }
    }
    else{
        CCLOG("toLua_AppDelegate_getAllFileNameByDirectory error argc is %d", argc);
    }
    return 0;
}

// if you want to use the package manager to install more packages, 
// don't modify or remove this function
static int register_all_packages()
{
    lua_State* tolua_S = LuaEngine::getInstance()->getLuaStack()->getLuaState();
    luaopen_lua_extensions(tolua_S);
    
    lua_register(tolua_S, "getAllFileNameByDirectory", toLua_AppDelegate_getAllFileNameByDirectory);
    
    return 0; //flag for packages manager
}

bool AppDelegate::applicationDidFinishLaunching()
{
    // set default FPS
    Director::getInstance()->setAnimationInterval(1.0 / 60.0f);

    // register lua module
    auto engine = LuaEngine::getInstance();
    ScriptEngineManager::getInstance()->setScriptEngine(engine);
    lua_State* L = engine->getLuaStack()->getLuaState();
    lua_module_register(L);

    register_all_packages();

    LuaStack* stack = engine->getLuaStack();
    stack->setXXTEAKeyAndSign("2dxLua", strlen("2dxLua"), "XXTEA", strlen("XXTEA"));

    //register custom function
    //LuaStack* stack = engine->getLuaStack();
    //register_custom_function(stack->getLuaState());

    register_all_pomelo(L);
    //luaopen_libpower(L);
    
#if CC_64BITS
    FileUtils::getInstance()->addSearchPath("src/64bit");
#endif
    FileUtils::getInstance()->addSearchPath("src");
    FileUtils::getInstance()->addSearchPath("res");
    if (engine->executeScriptFile("main.lua"))
    {
        return false;
    }

    return true;
}

// This function will be called when the app is inactive. Note, when receiving a phone call it is invoked.
void AppDelegate::applicationDidEnterBackground()
{
    Director::getInstance()->stopAnimation();

#if USE_AUDIO_ENGINE
    AudioEngine::pauseAll();
#endif
}

// this function will be called when the app is active again
void AppDelegate::applicationWillEnterForeground()
{
    Director::getInstance()->startAnimation();

#if USE_AUDIO_ENGINE
    AudioEngine::resumeAll();
#endif
}
