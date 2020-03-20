#/****************************************************************************
# Copyright (c) 2013-2014 cocos2d-x.org
#
# http://www.cocos2d-x.org
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
# ****************************************************************************/
cmake_minimum_required(VERSION 3.6)

set(APP_NAME PA_Client)

project(${APP_NAME})

set(RUNTIME_SRC_ROOT ${CMAKE_CURRENT_SOURCE_DIR}/frameworks/runtime-src)
set(COCOS2DX_ROOT_PATH ${CMAKE_CURRENT_SOURCE_DIR}/frameworks/cocos2d-x)
set(CMAKE_MODULE_PATH ${COCOS2DX_ROOT_PATH}/cmake/Modules/)

include(CocosBuildSet)
set(BUILD_LUA_LIBS ON)
add_subdirectory(${COCOS2DX_ROOT_PATH}/cocos ${ENGINE_BINARY_PATH}/cocos/core)

# script and source files info, not need to compile
set(res_res_folders
    "${CMAKE_CURRENT_SOURCE_DIR}/res"
    )
set(res_src_folders
    "${CMAKE_CURRENT_SOURCE_DIR}/src"
    )
if(APPLE OR VS)
    cocos_mark_multi_resources(res_res RES_TO "Resources/res" FOLDERS ${res_res_folders})
    cocos_mark_multi_resources(res_src RES_TO "Resources/src" FOLDERS ${res_src_folders})
    set(cc_common_res ${res_res} ${res_src} ${res_script})
endif()

# record sources, headers
set(GAME_HEADER 
    ${RUNTIME_SRC_ROOT}/Classes/AppDelegate.h
    ${RUNTIME_SRC_ROOT}/Classes/CCPomelo.h
    ${RUNTIME_SRC_ROOT}/Classes/export.h
    ${RUNTIME_SRC_ROOT}/Classes/lua-bindings/lua_pomelo_auto.hpp
    ${RUNTIME_SRC_ROOT}/Classes/include/BaseClass.h
    ${RUNTIME_SRC_ROOT}/Classes/include/Battle.h
    ${RUNTIME_SRC_ROOT}/Classes/include/Boss.h
    ${RUNTIME_SRC_ROOT}/Classes/include/Buff.h
    ${RUNTIME_SRC_ROOT}/Classes/include/BuffMgr.h
    ${RUNTIME_SRC_ROOT}/Classes/include/Bullet.h
    ${RUNTIME_SRC_ROOT}/Classes/include/BulletMgr.h
    ${RUNTIME_SRC_ROOT}/Classes/include/ClientKernel.h
    ${RUNTIME_SRC_ROOT}/Classes/include/Define.h
    ${RUNTIME_SRC_ROOT}/Classes/include/DownAsset.h
    ${RUNTIME_SRC_ROOT}/Classes/include/Enemy.h
    ${RUNTIME_SRC_ROOT}/Classes/include/EnergyBody.h
    ${RUNTIME_SRC_ROOT}/Classes/include/Event.h
    ${RUNTIME_SRC_ROOT}/Classes/include/Fort.h
    ${RUNTIME_SRC_ROOT}/Classes/include/FortMgr.h
    ${RUNTIME_SRC_ROOT}/Classes/include/FortSkill.h
    ${RUNTIME_SRC_ROOT}/Classes/include/InitialData.h
    ${RUNTIME_SRC_ROOT}/Classes/include/json_batchallocator.h
    ${RUNTIME_SRC_ROOT}/Classes/include/KeyFrame.h
    ${RUNTIME_SRC_ROOT}/Classes/include/MCKernel.h
    ${RUNTIME_SRC_ROOT}/Classes/include/MobileClientKernel.h
    ${RUNTIME_SRC_ROOT}/Classes/include/Player.h
    ${RUNTIME_SRC_ROOT}/Classes/include/Props.h
    ${RUNTIME_SRC_ROOT}/Classes/include/PropsMgr.h
    ${RUNTIME_SRC_ROOT}/Classes/include/Shape.h
    ${RUNTIME_SRC_ROOT}/Classes/include/Ship.h
    ${RUNTIME_SRC_ROOT}/Classes/include/ShipSkill.h
    ${RUNTIME_SRC_ROOT}/Classes/include/stdafx.h
    ${RUNTIME_SRC_ROOT}/Classes/include/TimeTool.h
    ${RUNTIME_SRC_ROOT}/Classes/include/UnZipAsset.h
    ${RUNTIME_SRC_ROOT}/Classes/include/json/writer.h
    ${RUNTIME_SRC_ROOT}/Classes/include/json/value.h
    ${RUNTIME_SRC_ROOT}/Classes/include/json/reader.h
    ${RUNTIME_SRC_ROOT}/Classes/include/json/json.h
    ${RUNTIME_SRC_ROOT}/Classes/include/json/forwards.h
    ${RUNTIME_SRC_ROOT}/Classes/include/json/features.h
    ${RUNTIME_SRC_ROOT}/Classes/include/json/config.h
    ${RUNTIME_SRC_ROOT}/Classes/include/json/autolink.h
)
set(GAME_SOURCE
    ${RUNTIME_SRC_ROOT}/Classes/AppDelegate.cpp
    ${RUNTIME_SRC_ROOT}/Classes/CCPomelo.cpp
    ${RUNTIME_SRC_ROOT}/Classes/export.cpp
    ${RUNTIME_SRC_ROOT}/Classes/lua-bindings/lua_pomelo_auto.cpp

    ${RUNTIME_SRC_ROOT}/Classes/src/BaseClass.cpp
    ${RUNTIME_SRC_ROOT}/Classes/src/Battle.cpp
    ${RUNTIME_SRC_ROOT}/Classes/src/Boss.cpp
    ${RUNTIME_SRC_ROOT}/Classes/src/Buff.cpp
    ${RUNTIME_SRC_ROOT}/Classes/src/BuffMgr.cpp
    ${RUNTIME_SRC_ROOT}/Classes/src/Bullet.cpp
    ${RUNTIME_SRC_ROOT}/Classes/src/BulletMgr.cpp
    ${RUNTIME_SRC_ROOT}/Classes/src/ClientKernel.cpp
    ${RUNTIME_SRC_ROOT}/Classes/src/DownAsset.cpp
    ${RUNTIME_SRC_ROOT}/Classes/src/Enemy.cpp
    ${RUNTIME_SRC_ROOT}/Classes/src/EnergyBody.cpp
    ${RUNTIME_SRC_ROOT}/Classes/src/Fort.cpp
    ${RUNTIME_SRC_ROOT}/Classes/src/FortMgr.cpp
    ${RUNTIME_SRC_ROOT}/Classes/src/FortSkill.cpp
    ${RUNTIME_SRC_ROOT}/Classes/src/json_reader.cpp
    ${RUNTIME_SRC_ROOT}/Classes/src/json_value.cpp
    ${RUNTIME_SRC_ROOT}/Classes/src/json_writer.cpp
    ${RUNTIME_SRC_ROOT}/Classes/src/KeyFrame.cpp
    ${RUNTIME_SRC_ROOT}/Classes/src/MCKernel.cpp
    ${RUNTIME_SRC_ROOT}/Classes/src/MobileClientKernel.cpp
    ${RUNTIME_SRC_ROOT}/Classes/src/Player.cpp
    ${RUNTIME_SRC_ROOT}/Classes/src/Props.cpp
    ${RUNTIME_SRC_ROOT}/Classes/src/PropsMgr.cpp
    ${RUNTIME_SRC_ROOT}/Classes/src/Shape.cpp
    ${RUNTIME_SRC_ROOT}/Classes/src/Ship.cpp
    ${RUNTIME_SRC_ROOT}/Classes/src/ShipSkill.cpp
    ${RUNTIME_SRC_ROOT}/Classes/src/stdafx.cpp
    ${RUNTIME_SRC_ROOT}/Classes/src/TimeTool.cpp
    ${RUNTIME_SRC_ROOT}/Classes/src/UnZipAsset.cpp
    ${RUNTIME_SRC_ROOT}/Classes/src/json_internalarray.inl
    ${RUNTIME_SRC_ROOT}/Classes/src/json_internalmap.inl
    ${RUNTIME_SRC_ROOT}/Classes/src/json_valueiterator.inl
)

# sources need to compile info, include dirs and source files
include_directories(
        ${RUNTIME_SRC_ROOT}/Classes
        ${RUNTIME_SRC_ROOT}/Classes/include
        ${COCOS2DX_ROOT_PATH}/cocos/scripting/lua-bindings/auto
        ${COCOS2DX_ROOT_PATH}/cocos/scripting/lua-bindings/manual
        ${COCOS2DX_ROOT_PATH}/cocos/libpomelo2/include
        ${COCOS2DX_ROOT_PATH}/external/lua/luajit/include
        ${COCOS2DX_ROOT_PATH}/external/lua/tolua
        ${COCOS2DX_ROOT_PATH}/tools/simulator/libsimulator/lib
)

if(IOS)
  include_directories(
    ${COCOS2DX_ROOT_PATH}/external/curl/include/ios
  )
endif()

if(ANDROID)
    # change APP_NAME to the share library name for Android, it's value depend on AndroidManifest.xml
    set(APP_NAME cocos2dlua)
    list(APPEND GAME_SOURCE ${RUNTIME_SRC_ROOT}/proj.android/app/jni/hellolua/main.cpp)
elseif(LINUX)
    list(APPEND GAME_SOURCE ${RUNTIME_SRC_ROOT}/proj.linux/main.cpp)
elseif(WINDOWS)
    list(APPEND GAME_HEADER
         ${RUNTIME_SRC_ROOT}/proj.win32/main.h
         ${RUNTIME_SRC_ROOT}/proj.win32/stdafx.h
         ${RUNTIME_SRC_ROOT}/proj.win32/SimulatorWin.h
         ${RUNTIME_SRC_ROOT}/proj.win32/targetver.h
         ${RUNTIME_SRC_ROOT}/proj.win32/resource.h
         )
    list(APPEND GAME_SOURCE
         ${RUNTIME_SRC_ROOT}/proj.win32/game.rc
         ${RUNTIME_SRC_ROOT}/proj.win32/stdafx.cpp
         ${RUNTIME_SRC_ROOT}/proj.win32/main.cpp
         ${RUNTIME_SRC_ROOT}/proj.win32/SimulatorWin.cpp
         ${cc_common_res}
         )
elseif(APPLE)
    if(IOS)
        list(APPEND GAME_HEADER
             ${RUNTIME_SRC_ROOT}/proj.ios_mac/ios/AppController.h
             ${RUNTIME_SRC_ROOT}/proj.ios_mac/ios/RootViewController.h
             )
        set(APP_UI_RES
            ${RUNTIME_SRC_ROOT}/proj.ios_mac/ios/LaunchScreen.storyboard
            ${RUNTIME_SRC_ROOT}/proj.ios_mac/ios/LaunchScreenBackground.png
            ${RUNTIME_SRC_ROOT}/proj.ios_mac/ios/Images.xcassets
            )
        list(APPEND GAME_SOURCE
             ${RUNTIME_SRC_ROOT}/proj.ios_mac/ios/main.m
             ${RUNTIME_SRC_ROOT}/proj.ios_mac/ios/AppController.mm
             ${RUNTIME_SRC_ROOT}/proj.ios_mac/ios/RootViewController.mm
             ${RUNTIME_SRC_ROOT}/proj.ios_mac/ios/Prefix.pch
             ${RUNTIME_SRC_ROOT}/proj.ios_mac/ios/build-cfg.json
             ${APP_UI_RES}
             )
    elseif(MACOSX)
        list(APPEND GAME_HEADER
             ${RUNTIME_SRC_ROOT}/proj.ios_mac/mac/SimulatorApp.h
             ${RUNTIME_SRC_ROOT}/proj.ios_mac/mac/ConsoleWindowController.h
             )
        set(APP_UI_RES
            ${RUNTIME_SRC_ROOT}/proj.ios_mac/mac/Base.lproj/MainMenu.xib
            ${RUNTIME_SRC_ROOT}/proj.ios_mac/mac/en.lproj/MainMenu.xib
            ${RUNTIME_SRC_ROOT}/proj.ios_mac/mac/zh-Hans.lproj/MainMenu.xib
            ${RUNTIME_SRC_ROOT}/proj.ios_mac/mac/ConsoleWindow.xib
            ${RUNTIME_SRC_ROOT}/proj.ios_mac/mac/Icon.icns
            ${RUNTIME_SRC_ROOT}/proj.ios_mac/mac/Info.plist
            )
        list(APPEND GAME_SOURCE
             ${RUNTIME_SRC_ROOT}/proj.ios_mac/mac/main.m
             ${RUNTIME_SRC_ROOT}/proj.ios_mac/mac/SimulatorApp.mm
             ${RUNTIME_SRC_ROOT}/proj.ios_mac/mac/ConsoleWindowController.m
             ${RUNTIME_SRC_ROOT}/proj.ios_mac/mac/Prefix.pch
             ${APP_UI_RES}
             )
    endif()
    list(APPEND GAME_SOURCE ${cc_common_res})
endif()

set(APP_SRC ${GAME_HEADER} ${GAME_SOURCE})

# mark app complie info and libs info
if(NOT ANDROID)
    add_executable(${APP_NAME} ${APP_SRC})
else()
    add_library(${APP_NAME} SHARED ${APP_SRC})
    add_subdirectory(${COCOS2DX_ROOT_PATH}/cocos/platform/android ${ENGINE_BINARY_PATH}/cocos/platform)
    target_link_libraries(${APP_NAME} -Wl,--whole-archive cpp_android_spec -Wl,--no-whole-archive)
    add_subdirectory(${COCOS2DX_ROOT_PATH}/cocos/scripting/lua-bindings/proj.android ${ENGINE_BINARY_PATH}/cocos/lua-android)
    target_link_libraries(${APP_NAME} -Wl,--whole-archive lua_android_spec -Wl,--no-whole-archive)
endif()

target_link_libraries(${APP_NAME} luacocos2d)
target_include_directories(${APP_NAME} PRIVATE ${RUNTIME_SRC_ROOT}/Classes)

if(WINDOWS OR MACOSX)
    add_subdirectory(${COCOS2DX_ROOT_PATH}/tools/simulator/libsimulator ${ENGINE_BINARY_PATH}/cocos/simulatorlib)
    target_link_libraries(${APP_NAME} simulatorlib)
endif()

# mark app resources, resource will be copy auto after mark
setup_cocos_app_config(${APP_NAME})
if(APPLE)
    set_target_properties(${APP_NAME} PROPERTIES RESOURCE "${APP_UI_RES}")
    if(MACOSX)
        set_target_properties(${APP_NAME} PROPERTIES
                              MACOSX_BUNDLE_INFO_PLIST "${RUNTIME_SRC_ROOT}/proj.ios_mac/mac/Info.plist"
                              )
    elseif(IOS)
        cocos_pak_xcode(${APP_NAME} INFO_PLIST "iOSBundleInfo.plist.in")
        set_xcode_property(${APP_NAME} ASSETCATALOG_COMPILER_APPICON_NAME "AppIcon")
        set_xcode_property(${APP_NAME} DEVELOPMENT_TEAM "")
        set_xcode_property(${APP_NAME} CODE_SIGN_IDENTITY "iPhone Developer")
    endif()
elseif(WINDOWS)
    cocos_copy_target_dll(${APP_NAME})
endif()
# copy resource on linux or WINDOWS
if(LINUX OR WINDOWS)
    set(APP_RES_DIR "$<TARGET_FILE_DIR:${APP_NAME}>/Resources")
    cocos_copy_target_res(${APP_NAME} COPY_TO ${APP_RES_DIR}/res FOLDERS ${res_res_folders})
    cocos_copy_target_res(${APP_NAME} COPY_TO ${APP_RES_DIR}/src FOLDERS ${res_src_folders})
endif()

if(ANDROID)
  add_library(curl STATIC IMPORTED GLOBAL)
  set_target_properties(curl
  PROPERTIES IMPORTED_LOCATION "${COCOS2DX_ROOT_PATH}/external/curl/prebuilt/android/${ANDROID_ABI}/libcurl.a"
  )
  target_link_libraries(${APP_NAME} curl)
elseif(IOS)
  add_library(curl STATIC IMPORTED GLOBAL)
  set_target_properties(curl
  PROPERTIES IMPORTED_LOCATION "${COCOS2DX_ROOT_PATH}/external/curl/prebuilt/ios/libcurl.a"
  )
  target_link_libraries(${APP_NAME} curl)
endif()
