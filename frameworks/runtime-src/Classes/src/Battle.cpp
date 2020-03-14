#include "Battle.h"

bool copyFile(const string& filename)
{
    cocos2d::FileUtils* fileUtils = FileUtils::getInstance();
    string destPath = fileUtils->getSearchPaths()[0] + filename;
    
    int nPos = destPath.find_last_of('/');
    if(nPos > 0)
    {
        string strFolder = destPath.substr(0, nPos+1);
        if (false == fileUtils->isDirectoryExist(strFolder))
        {
            fileUtils->createDirectory(strFolder.c_str());
        }
    }
    
    Data data = fileUtils->getDataFromFile(fileUtils->fullPathForFilename(filename));
    FILE *fp = fopen(destPath.c_str(), "w+");
    if (fp)
    {
        size_t size = fwrite(data.getBytes(), sizeof(unsigned char), data.getSize(), fp);
        fclose(fp);
        
        if (size > 0)
        {
            return true;
        }
    }
    return false;
}

void readLuaMulRowTable(lua_State* L, const char* szFile, map<int, map<char*, char*>>& mapData)
{
    if (luaL_dofile(L, szFile))
    {
        CCLOG("run script:%s failed\n", szFile);
    }
    else
    {
        int it_idx;
        
        //lua_getglobal(L,"stage");
        
        int t_idx = lua_gettop(L);
        lua_pushnil(L);
        while(lua_next(L,t_idx))
        {
            it_idx = lua_gettop(L);
            lua_pushnil(L);
            
            int nTableKey = lua_tonumber(L,-3);
            
            map<char*, char*> tmpData;
            while(lua_next(L,it_idx))
            {
                char* strKey = (char*)lua_tostring(L,-2);
                tmpData.insert(map<char*, char*>::value_type(strKey, CTool::getCopyStr(lua_tostring(L,-1))));
                lua_pop(L,1);
            }
            mapData.insert(map<int, map<char*, char*>>::value_type(nTableKey, tmpData));
            
            lua_pop(L,1);
            //break;
        }
    }
    
    //lua_close(L);
}

map<int, map<char*, char*>> CBattle::m_mapArmsConfigData;
map<int, map<char*, char*>> CBattle::m_mapShipConfigData;

CBattle::CBattle()
{
	m_nBattleType = EBattleType::NORMAL_BATTLE;
	m_dDeltaTime = 0.0;
	m_dBattleTime = 0;
	m_isGameStop = false;
	m_isGamePause = true;
	init();
}

CBattle::~CBattle()
{
	delete(m_pPlayerSelf);
	m_pPlayerSelf = nullptr;
	delete(m_pPlayerHost);
	m_pPlayerHost = nullptr;
    
    for(map<int,map<char*,char*>>::iterator it = m_mapArmsConfigData.begin();it!=m_mapArmsConfigData.end();it++)
    {
        for(map<char*,char*>::iterator it2 = (it->second).begin();it2!=(it->second).end();it2++)
        {
            delete((*it2).second);
            (*it2).second = nullptr;
        }
    }
    m_mapArmsConfigData.clear();
    
    for(map<int,map<char*,char*>>::iterator it = m_mapShipConfigData.begin();it!=m_mapShipConfigData.end();it++)
    {
        for(map<char*,char*>::iterator it2 = (it->second).begin();it2!=(it->second).end();it2++)
        {
            delete((*it2).second);
            (*it2).second = nullptr;
        }
    }
    m_mapShipConfigData.clear();
}

void CBattle::init()
{
	srand((unsigned)time(NULL));
	m_nFortEventHandler = -1;
	m_nBulletEventHandler = -1;
//	std::vector<int> vec;
//	for (int i = 0; i < 10; ++i)
//	{
//		vec.push_back(i);
//	}

//	vec.push_back(1);
//	vec.push_back(1);
//	vec.push_back(1);
/*	vec.push_back(1);

	for (auto it = vec.begin(); it != vec.end();)
	{
		if (1 == *it) {
			it = vec.erase(it);
		}
		else {
			++it;
		}
	}
	*/
	//tan atan ���������β���
	//tan ������ǻ���      atan�������tan��ֵ����ֵ����������ǻ���
/*	double a = tan(45 * PI / 180);     1
	double a1 = tan(45.5 * PI / 180);   1.0176
	double a4 = tan(45.1 * PI / 180);   1.0034
	double a2 = atan(1.0f) * 180 / PI;  45.000
	double a3 = atan(0.999) * 180 / PI; 44.9713
	*/
/*	lua_State *L = luaL_newstate();

	int a = luaL_loadfile(L, "app\constants\arms.lua");
	lua_gettable(L, 1);
	lua_getfield(L, -1, "id");
	int nID = lua_tonumber(L, -1);
	lua_pop(L, 2);
	*/
}

void CBattle::createPlayer(int nSelfShipID, int nSelfShipLv, int nHostShipID, int nHostShipLv)
{
	m_pPlayerSelf = new CPlayer(1);
	m_pPlayerSelf->setBattlePoint(this);
	m_pPlayerSelf->init(nSelfShipID, nSelfShipLv);   // ����ս��id
	m_pPlayerHost = new CPlayer(2);
	m_pPlayerHost->setBattlePoint(this);
	m_pPlayerHost->init(nHostShipID, nHostShipLv);
}

void CBattle::update(double dDelta)
{
	if (m_isGameStop)
	{
		return;
	}
	if (m_isGamePause)
	{
		return;
	}
	m_dBattleTime += dDelta;
	m_pPlayerSelf->update(dDelta);
	m_pPlayerHost->update(dDelta);
	if (m_dBattleTime >= BATTLE_TIME)
	{
		m_isGameStop = true;
	}
}

void CBattle::setJsonDataPath(string strArmDataPath, string strShipDataPath)
{
	m_strArmDataPath = strArmDataPath;
	m_strShipDataPath = strShipDataPath;
}

void CBattle::setPlayerInitData(int nSelfShipID, int nSelfShipLv, int nHostShipID, int nHostShipLv)
{
	createPlayer(nSelfShipID, nSelfShipLv, nHostShipID, nHostShipLv);
}

double CBattle::createFort(int nSide, int nFortID, int nFortLv, int nPosY, int nArmyPoint)
{
	double dPosX = 0;
	if (nSide == EPlayerKind::SELF)
	{
		dPosX = m_pPlayerSelf->getFortMgr()->createFort(nFortID, nFortLv, nPosY, nArmyPoint);
	}
	else if (nSide == EPlayerKind::ENEMY)
	{
		dPosX = m_pPlayerHost->getFortMgr()->createFort(nFortID, nFortLv, nPosY, nArmyPoint);
	}
	return dPosX;
}

void CBattle::gameOver()
{
	m_isGameStop = true;
}

map<int, CFort*> CBattle::getPlayerSelfForts()
{
	return m_pPlayerSelf->getFortMgr()->getFortsMap();
}

map<int, CFort*> CBattle::getPlayerHostForts()
{
	return m_pPlayerHost->getFortMgr()->getFortsMap();
}

string CBattle::getArmDataPath()
{
	return m_strArmDataPath;
}

string CBattle::getShipDataPath()
{
	return m_strShipDataPath;
}

void CBattle::insertEventHandlerMap(int nIndex, int nHandler)
{
	m_mapFortHandler.insert(map<int, int>::value_type(nIndex, nHandler));
}

int CBattle::getHandlerByIndex(int nIndex)
{
	return m_mapFortHandler[nIndex];
}


void CBattle::runFortEventHandler(int nSide, int nEventID, int nFortID, int nFortIndex, double dEventNumber, double dReserveNumber)
{
	lua_State* L = LuaEngine::getInstance()->getLuaStack()->getLuaState();
	toluafix_get_function_by_refid(L, m_nFortEventHandler);
	if (lua_isfunction(L, -1))
	{
		lua_pushinteger(L, nSide);
		lua_pushinteger(L, nEventID);
		lua_pushinteger(L, nFortID);
		lua_pushinteger(L, nFortIndex);
		lua_pushnumber(L, dEventNumber);
		lua_pushnumber(L, dReserveNumber);

		int result = LuaEngine::getInstance()->getLuaStack()->executeFunctionByHandler(m_nFortEventHandler, 6) != 0;
	}
	else {
		CCLOG("OnBattle.cpp-fortevent-luacallback-handler-false:%d", m_nFortEventHandler);
	}
}

void CBattle::runBulletEventHandler(int nSide, int nEventID, int nBulletID, int nBulletIndex, double dEventNumber)
{
	lua_State* L = LuaEngine::getInstance()->getLuaStack()->getLuaState();
	toluafix_get_function_by_refid(L, m_nBulletEventHandler);
	if (lua_isfunction(L, -1))
	{
		lua_pushinteger(L, nSide);
		lua_pushinteger(L, nEventID);
		lua_pushinteger(L, nBulletID);
		lua_pushinteger(L, nBulletIndex);
		lua_pushnumber(L, dEventNumber);

		int result = LuaEngine::getInstance()->getLuaStack()->executeFunctionByHandler(m_nBulletEventHandler, 5) != 0;
	}
	else {
		CCLOG("OnBattle.cpp-bulletevent-luacallback-handler-false:%d", m_nBulletEventHandler);
	}
}

void CBattle::loadingConfigData()
{
    cocos2d::FileUtils* fileUtils = FileUtils::getInstance();
    
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    if (m_mapArmsConfigData.size() <= 0)
    {
        string strPath = fileUtils->getSearchPaths()[0] + m_strArmDataPath;
        if(!fileUtils->isFileExist(strPath))
        {
            ::copyFile(m_strArmDataPath);
        }

        ::readLuaMulRowTable(LuaEngine::getInstance()->getLuaStack()->getLuaState(), strPath.c_str(), m_mapArmsConfigData);
    }
    
    if (m_mapShipConfigData.size() <= 0)
    {
        string strPath = fileUtils->getSearchPaths()[0] + m_strShipDataPath;
        if(!fileUtils->isFileExist(strPath))
        {
            ::copyFile(m_strShipDataPath);
        }
        
        ::readLuaMulRowTable(LuaEngine::getInstance()->getLuaStack()->getLuaState(), strPath.c_str(), m_mapShipConfigData);
    }
#else
    if (m_mapArmsConfigData.size() <= 0)
    {
        m_strArmDataPath = fileUtils->fullPathForFilename(m_strArmDataPath);
        ::readLuaMulRowTable(LuaEngine::getInstance()->getLuaStack()->getLuaState(), m_strArmDataPath.c_str(), m_mapArmsConfigData);
    }
    
    if (m_mapShipConfigData.size() <= 0)
    {
        m_strShipDataPath = fileUtils->fullPathForFilename(m_strShipDataPath);
        ::readLuaMulRowTable(LuaEngine::getInstance()->getLuaStack()->getLuaState(), m_strShipDataPath.c_str(), m_mapShipConfigData);
    }
#endif
}

const char* CBattle::getArmsConfigDataValueByKey(int id, const char* key)
{
    map<char*, char*>::iterator iter = m_mapArmsConfigData[id].begin();
    for (; iter != m_mapArmsConfigData[id].end(); iter++)
    {
        if (strcmp((*iter).first, key) == 0)
        {
            return (*iter).second;
        }
    }
    return nullptr;
}

const char* CBattle::getShipConfigDataValueByKey(int id, const char* key)
{
    map<char*, char*>::iterator iter = m_mapShipConfigData[id].begin();
    for (; iter != m_mapShipConfigData[id].end(); iter++)
    {
        if (strcmp((*iter).first, key) == 0)
        {
            return (*iter).second;
        }
    }
    return nullptr;
}


