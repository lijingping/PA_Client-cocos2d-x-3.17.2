#include "export.h"
#include "Battle.h"
#include "scripting/lua-bindings/manual/tolua_fix.h"

CBattle* g_pBattle;

CExport::CExport()
{
}


CExport::~CExport()
{
}

//制作成返回Lua的table
//压入number类型的数据     key 值  value 值
void set_field_stringNumber(lua_State *L, const char *key, double value)
{
	lua_pushstring(L, key);
	lua_pushnumber(L, value);
	lua_settable(L, -3);
}
//压入int类型的数据
void set_field_stringInt(lua_State *L, const char *key, int value)
{
	lua_pushstring(L, key);
	lua_pushinteger(L, value);
	lua_settable(L, -3);
}

//压入string
void set_field_stringString(lua_State *L, const char *key, const char *value)
{
	lua_pushstring(L, key);
	lua_pushstring(L, value);
	lua_settable(L, -3);
}
//bool类型
void set_field_stringBool(lua_State *L, const char *key, const bool value)
{
	lua_pushstring(L, key);
	lua_pushboolean(L, value);
	lua_settable(L, -3);
}

// key 为 integer
void set_field_intInt(lua_State *L, int key, int value)
{
	lua_pushinteger(L, key);
	lua_pushinteger(L, value);
	lua_settable(L, -3);
}

// key 为integer , double 值
void set_field_intDouble(lua_State *L, int key, double value)
{
	lua_pushinteger(L, key);
	lua_pushnumber(L, value);
	lua_settable(L, -3);
}

void set_field_intString(lua_State *L, int key, const char* value)
{
	lua_pushinteger(L, key);
	lua_pushstring(L, value);
	lua_settable(L, -3);
}

int enterBattle(lua_State *L)
{
	g_pBattle = new CBattle();
	int nBattleType = lua_tointeger(L, 1);
	g_pBattle->setBattleType(nBattleType);
	return 0;
}

int setJsonDataPath(lua_State *L)
{
	if (!g_pBattle)
	{
		return 0;
	}
	string strArmDataPath = lua_tostring(L, 1);
	string strShipDataPath = lua_tostring(L, 2);
	g_pBattle->setJsonDataPath(strArmDataPath, strShipDataPath);
    g_pBattle->loadingConfigData();
	return 0;
}

int setPlayerData(lua_State *L)
{
	if (!g_pBattle)
	{
		return 0;
	}
	int nSelfShipID = lua_tointeger(L, 1);
	int nSelfShipLv = lua_tointeger(L, 2);
	int nHostShipID = lua_tointeger(L, 3);
	int nHostShipLv = lua_tointeger(L, 4);
	g_pBattle->setPlayerInitData(nSelfShipID, nSelfShipLv, nHostShipID, nHostShipLv);
	return 0;
}

int start_battle(lua_State *L)
{
	if (!g_pBattle)
	{
		return 0;
	}
	g_pBattle->setGamePause(false);
	return 0;
}

int pause_battle(lua_State *L)
{
	if (!g_pBattle)
	{
		return 0;
	}
	g_pBattle->setGamePause(true);
	return 0;
}

int stop_battle(lua_State *L)
{
	if (!g_pBattle)
	{
		return 0;
	}
	g_pBattle->setGameStop(true);
	return 0;
}

int update(lua_State *L)
{
	if (!g_pBattle)
	{
		return 0;
	}
	double dDelta = lua_tonumber(L, 1);
	g_pBattle->update(dDelta);
	return 0;
}

int delete_battle(lua_State *L)
{
	if (!g_pBattle)
	{
		return 0;
	}
	delete(g_pBattle);
	g_pBattle = nullptr;
	return 0;
}

int getBattleTime(lua_State *L)
{
	if (!g_pBattle)
	{
		return 0;
	}
	lua_newtable(L);
	set_field_stringNumber(L, "time", g_pBattle->getBattleTime());
	return 1;
}

// 初始化信息（战场战力最大值、能量获取上限值   等等）
int getInitInformation(lua_State *L)
{
	if (!g_pBattle)
	{
		return 0;
	}
	lua_newtable(L);
	set_field_stringNumber(L, "energy_max", ENERGY_MAX);
	set_field_stringNumber(L, "army_max", MAX_ARMY_FORCE);

	return 1;
}

// 左玩家战场数据
int getPlayerSelfData(lua_State *L)
{
	if (!g_pBattle)
	{
		return 0;
	}
	lua_newtable(L);
	set_field_stringInt(L, "playerEnergy", g_pBattle->getPlayerSelf()->getPlayerEnergy());
	set_field_stringInt(L, "playerArmy", g_pBattle->getPlayerSelf()->getPlayerArmy());

	return 1;
}

// 右玩家战场数据
int getPlayerHostData(lua_State* L)
{
	if (!g_pBattle)
	{
		return 0;
	}
	lua_newtable(L);
	set_field_stringInt(L, "playerEnergy", g_pBattle->getPlayerHost()->getPlayerEnergy());
	set_field_stringInt(L, "playerArmy", g_pBattle->getPlayerHost()->getPlayerArmy());

	return 1;
}

int getSelfFortMgrData(lua_State *L)
{
	if (!g_pBattle)
	{
		return 0;
	}
	lua_newtable(L);
	set_field_stringInt(L, "fortCount", g_pBattle->getPlayerSelf()->getFortMgr()->getCountFort());
	return 1;
}

int getHostFortMgrData(lua_State* L)
{
	if (!g_pBattle)
	{
		return 0;
	}
	lua_newtable(L);
	set_field_stringInt(L, "fortCount", g_pBattle->getPlayerHost()->getFortMgr()->getCountFort());
	return 1;
}

int getSelfFortData(lua_State* L)
{
	if (!g_pBattle)
	{
		return 0;
	}
	lua_newtable(L);
	map<int, CFort*> mapForts = g_pBattle->getPlayerSelfForts();
	map<int, CFort*>::iterator iter = mapForts.begin();
	int nCountFort = 0;
	for (; iter != mapForts.end(); iter++)
	{
		nCountFort++;
		lua_newtable(L);
		set_field_stringInt(L, "id", (*iter).second->getID());
		set_field_stringInt(L, "fortIndex", (*iter).second->getFortIndex());
		set_field_stringNumber(L, "hp", (*iter).second->getHp());
		set_field_stringNumber(L, "maxHp", (*iter).second->getInitHp());
		set_field_stringNumber(L, "energy", (*iter).second->getEnergy());
		set_field_stringNumber(L, "x", (*iter).second->getPosX());
		set_field_stringNumber(L, "y", (*iter).second->getPosY());
		set_field_stringNumber(L, "radian", (*iter).second->getTurnRadian());
		set_field_stringInt(L, "bulletID", (*iter).second->getBulletID());
		set_field_stringNumber(L, "bornTime", (*iter).second->getFortBornTime());
		lua_pushinteger(L, nCountFort);
		lua_pushvalue(L, -2);
		lua_settable(L, -4);
		lua_pop(L, 1);
	}
	return 1;
}

int getHostFortData(lua_State* L)
{
	if (!g_pBattle)
	{
		return 0;
	}
	lua_newtable(L);
	map<int, CFort*> mapForts = g_pBattle->getPlayerHostForts();
	map<int, CFort*>::iterator iter = mapForts.begin();
	int nCountFort = 0;
	for (; iter != mapForts.end(); iter++)
	{
		nCountFort++;
		lua_newtable(L);
		set_field_stringInt(L, "id", (*iter).second->getID());
		set_field_stringInt(L, "fortIndex", (*iter).second->getFortIndex());
		set_field_stringNumber(L, "hp", (*iter).second->getHp());
		set_field_stringNumber(L, "maxHp", (*iter).second->getInitHp());
		set_field_stringNumber(L, "energy", (*iter).second->getEnergy());
		set_field_stringNumber(L, "x", (*iter).second->getPosX());
		set_field_stringNumber(L, "y", (*iter).second->getPosY());
		set_field_stringNumber(L, "radian", (*iter).second->getTurnRadian());
		set_field_stringInt(L, "bulletID", (*iter).second->getBulletID());
		set_field_stringNumber(L, "bornTime", (*iter).second->getFortBornTime());
		lua_pushinteger(L, nCountFort);
		lua_pushvalue(L, -2);
		lua_settable(L, -4);
		lua_pop(L, 1);
	}
	return 1;
}

int getSelfShipData(lua_State* L)
{
	if (!g_pBattle)
	{
		return 0;
	}
	lua_newtable(L);
	CShip* pShip = g_pBattle->getPlayerSelf()->getShip();
	set_field_stringInt(L, "id", pShip->getID());
	set_field_stringNumber(L, "hp", pShip->getHp());
	set_field_stringNumber(L, "maxHp", pShip->getInitHp());
	set_field_stringNumber(L, "energy", pShip->getEnergy());
//	set_field_stringInt(L, "barrelRadian", pShip->getBarrelRadian());
	return 1;
}

int getHostShipData(lua_State* L)
{
	if (!g_pBattle)
	{
		return 0;
	}
	lua_newtable(L);
	CShip* pShip = g_pBattle->getPlayerHost()->getShip();
	set_field_stringInt(L, "id", pShip->getID());
	set_field_stringNumber(L, "hp", pShip->getHp());
	set_field_stringNumber(L, "maxHp", pShip->getInitHp());
	set_field_stringNumber(L, "energy", pShip->getEnergy());
//	set_field_stringInt(L, "barrelRadian", pShip->getBarrelRadian());
	return 1;
}

int getSelfBulletData(lua_State* L)
{
	if (!g_pBattle)
	{
		return 0;
	}
	lua_newtable(L);
	vector<CBulletNormal*> pBullets = g_pBattle->getPlayerSelf()->getBulletMgr()->getBulletVec();
	for (int i = 0; i < pBullets.size(); i++)
	{
		lua_newtable(L);
		set_field_stringInt(L, "id", pBullets[i]->getBulletID());
		set_field_stringInt(L, "index", pBullets[i]->getBulletIndex());
		set_field_stringNumber(L, "x", pBullets[i]->getPosX());
		set_field_stringNumber(L, "y", pBullets[i]->getPosY());
		set_field_stringNumber(L, "radian", pBullets[i]->getTurnRadian());
		set_field_stringInt(L, "type", pBullets[i]->getBulletType());
		lua_pushinteger(L, i + 1);
		lua_pushvalue(L, -2);
		lua_settable(L, -4);
		lua_pop(L, 1);
	}
	return 1;
}

int getHostBulletData(lua_State* L)
{
	if (!g_pBattle)
	{
		return 0;
	}
	lua_newtable(L);
	vector<CBulletNormal*> pBullets = g_pBattle->getPlayerHost()->getBulletMgr()->getBulletVec();
	for (int i = 0; i < pBullets.size(); i++)
	{
		lua_newtable(L);
		set_field_stringInt(L, "id", pBullets[i]->getBulletID());
		set_field_stringInt(L, "index", pBullets[i]->getBulletIndex());
		set_field_stringNumber(L, "x", pBullets[i]->getPosX());
		set_field_stringNumber(L, "y", pBullets[i]->getPosY());
		set_field_stringNumber(L, "radian", pBullets[i]->getTurnRadian());
		set_field_stringInt(L, "type", pBullets[i]->getBulletType());
		lua_pushinteger(L, i + 1);
		lua_pushvalue(L, -2);
		lua_settable(L, -4);
		lua_pop(L, 1);
	}
	return 1;
}
	

// 初始化并设置 数据
// 创建战机
// 
int createPlayerFort(lua_State *L)
{
	if (!g_pBattle)
	{
		return 0;
	}
	int nFortID = lua_tointeger(L, 1);
	int nFortLv = lua_tointeger(L, 2);
	double dPosY = lua_tonumber(L, 3);
	int nArmyPoint = lua_tointeger(L, 4);
	double dPosX = g_pBattle->createFort(1, nFortID, nFortLv, dPosY, nArmyPoint);
	lua_newtable(L);
	set_field_stringNumber(L, "x", dPosX);
	return 1;
}

int createEnemyFort(lua_State *L)
{
	if (!g_pBattle)
	{
		return 0;
	}
	int nFortID = lua_tointeger(L, 1);
	int nFortLv = lua_tointeger(L, 2);
	double dPosY = lua_tonumber(L, 3);
	int nArmyPoint = lua_tointeger(L, 4);
	double dPosX = g_pBattle->createFort(2, nFortID, nFortLv, dPosY, nArmyPoint);
	lua_newtable(L);
	set_field_stringNumber(L, "x", dPosX);
	return 1;
}

int selfFortEvent(lua_State *L)
{
	if (!g_pBattle)
	{
		return 0;
	}
	lua_newtable(L);
	map<int, CFort*> mapForts = g_pBattle->getPlayerSelfForts();
	map<int, CFort*>::iterator iter = mapForts.begin();
	int nFortCount = 0;
	for (; iter != mapForts.end(); iter++)
	{
		nFortCount++;
		lua_newtable(L);
		set_field_stringInt(L, "id", (*iter).second->getID());
		set_field_stringInt(L, "index", (*iter).second->getFortIndex());

		vector<SFortEvent> sFortEvent = (*iter).second->getFortEvent();
		int nEventCount = 0;
		for (int i = 0; i < sFortEvent.size(); i++)
		{
			nEventCount++;
			lua_newtable(L);
			set_field_stringInt(L, "eventID", sFortEvent[i].nEventID);
			set_field_stringInt(L, "number", sFortEvent[i].dEventNumber);
			lua_pushinteger(L, nEventCount);
			lua_pushvalue(L, -2);
			lua_settable(L, -4);
			lua_pop(L, 1);
		}
		lua_pushstring(L, "event");

		(*iter).second->clearFortEvent();
		lua_pushinteger(L, nFortCount);//(*iter).second->getFortID()
		lua_pushvalue(L, -2);
		lua_settable(L, -4);
		lua_pop(L, 1);
	}
	return 1;
}

int hostFortEvent(lua_State *L)
{
	if (!g_pBattle)
	{
		return 0;
	}
	lua_newtable(L);
	map<int, CFort*> mapForts = g_pBattle->getPlayerHostForts();
	map<int, CFort*>::iterator iter = mapForts.begin();
	int nFortCount = 0;
	for (; iter != mapForts.end(); iter++)
	{
		nFortCount++;
		lua_newtable(L);
		set_field_stringInt(L, "id", (*iter).second->getID());
		set_field_stringInt(L, "index", (*iter).second->getFortIndex());

		vector<SFortEvent> sFortEvent = (*iter).second->getFortEvent();
		int nEventCount = 0;
		for (int i = 0; i < sFortEvent.size(); i++)
		{
			nEventCount++;
			lua_newtable(L);
			set_field_stringInt(L, "eventID", sFortEvent[i].nEventID);
			set_field_stringNumber(L, "number", sFortEvent[i].dEventNumber);
			lua_pushinteger(L, nEventCount);
			lua_pushvalue(L, -2);
			lua_settable(L, -4);
			lua_pop(L, 1);
		}
		lua_pushstring(L, "event");

		lua_pushinteger(L, nFortCount);//(*iter).second->getFortID()
		lua_pushvalue(L, -2);
		lua_settable(L, -4);
		lua_pop(L, 1);
	}
	return 1;
}

int selfBulletEvent(lua_State *L)
{
	if (!g_pBattle)
	{
		return 0;
	}
	lua_newtable(L);
	vector<SBulletEventData> sEventData = g_pBattle->getPlayerSelf()->getBulletMgr()->getBulletEvent();
	for (int i = 0; i < sEventData.size(); i++)
	{
		lua_newtable(L);
		set_field_stringInt(L, "eventID", sEventData[i].nEventID);
		set_field_stringInt(L, "bulletID", sEventData[i].nBulletID);
		set_field_stringInt(L, "bulletIndex", sEventData[i].nBulletIndex);
		set_field_stringNumber(L, "x", sEventData[i].dPosX);
		set_field_stringNumber(L, "y", sEventData[i].dPosY);
		lua_pushinteger(L, i + 1);
		lua_pushvalue(L, -2);
		lua_settable(L, -4);
		lua_pop(L, 1);
	}
	return 1;
}

int hostBulletEvent(lua_State *L)
{
	if (!g_pBattle)
	{
		return 0;
	}
	lua_newtable(L);
	vector<SBulletEventData> sEventData = g_pBattle->getPlayerHost()->getBulletMgr()->getBulletEvent();
	for (int i = 0; i < sEventData.size(); i++)
	{
		lua_newtable(L);
		set_field_stringInt(L, "eventID", sEventData[i].nEventID);
		set_field_stringInt(L, "bulletID", sEventData[i].nBulletID);
		set_field_stringInt(L, "bulletIndex", sEventData[i].nBulletIndex);
		set_field_stringNumber(L, "x", sEventData[i].dPosX);
		set_field_stringNumber(L, "y", sEventData[i].dPosY);
		lua_pushinteger(L, i + 1);
		lua_pushvalue(L, -2);
		lua_settable(L, -4);
		lua_pop(L, 1);
	}
	return 1;
}

int fortEventHandler(lua_State *L)
{
	if (!g_pBattle)
	{
		return 0;
	}
	int nHandler = toluafix_ref_function(L, 1, 0);
	g_pBattle->setFortEventHandler(nHandler);
	return 0;
}

int fortBornEventHandler(lua_State *L)
{
	if (!g_pBattle)
	{
		return 0;
	}
	int nHandler = toluafix_ref_function(L, 1, 0);
	return 0;
}

int bulletEventHandler(lua_State *L)
{
	int nHandler = toluafix_ref_function(L, 1, 0);
	g_pBattle->setBulletEventHandler(nHandler);
	return 0;
}


int testData(lua_State *L)
{
/*	if (!g_pBattle)
	{
		return 0;
	}
	*/
	lua_newtable(L);
	set_field_intDouble(L, 1, 0.45);
	set_field_stringInt(L, "testID", 001);
	return 1;
}

const struct luaL_Reg reg_info[] =
{
	{ "enterBattle", enterBattle },
	{ "setJsonDataPath", setJsonDataPath },        // 设置json表数据路径（军队json， 战舰json……）
	{ "setPlayerData", setPlayerData },            // 初始化双方战舰数据（双方的战舰id和战舰等级）
	{ "startBattle", start_battle },
	{ "stopBattle", stop_battle },
	{ "pauseBattle", pause_battle },
	{ "update", update },
	{ "deleteBattle", delete_battle},
	{ "getBattleTime", getBattleTime },
	{ "getPlayerSelfData", getPlayerSelfData},     // 玩家数据
	{ "getPlayerHostData", getPlayerHostData},
	{ "getSelfFortMgrData", getSelfFortMgrData},   // 玩家炮台管理数据
	{ "getHostFortMgrData", getHostFortMgrData}, 
	{ "getSelfFortData", getSelfFortData},         // 玩家战机数据
	{ "getHostFortData", getHostFortData}, 
	{ "getSelfShipData", getSelfShipData},         // 战舰数据
	{ "getHostShipData", getHostShipData},
	{ "getSelfBulletData", getSelfBulletData},     // 子弹数据
	{ "getHostBulletData", getHostBulletData},     
	{ "createPlayerFort", createPlayerFort},       // 创建战机（战机ID， 战机lv， y轴, 兵力点数）
	{ "createEnemyFort", createEnemyFort},
	{ "selfFortEvent", selfFortEvent },            // 炮台事件
	{ "hostFortEvent", hostFortEvent },
	{ "selfBulletEvent", selfBulletEvent },        // 子弹事件
	{ "hostBulletEvent", hostBulletEvent }, 
	{ "testData", testData},     //  测试用（获取数据）

	{ "fortEventHandler", fortEventHandler },
	{ "bulletEventHandler", bulletEventHandler},

	/*	{ "enterBossBattle", enterBossBattle },
	
	{ "setShipData", setShipData },// 参数：player战舰ID， 战舰技能等级， 炮台1， 炮台2， 炮台3， enemy战舰ID， 战舰技能等级， 炮台1， 炮台2， 炮台3
	{ "setShipDataInBossBattle", setShipDataInBossBattle },
	{ "setFortData", setFortData },

	{ "energyBodyData", energyBodyData },   // 能量体不在时table返回给lua 是nil
	{ "energyBodyEvent", energyBodyEvent },

	{ "synchordataBattle", synchordataBattle },
	{ "setEnergyBodyRoad", setEnergyBodyRoad },

	{ "fortFireSkill", fortFireSkill },// 参数：bool：我方true， 敌方false、 炮台ID
	{ "useProp", useProp },            // 参数：使用方：1，player；2，enemy 、道具ID、 目标方：1， player；2， enemy 、 炮台ID
	{ "useShipSkill", useShipSkill },  // 参数：使用方：1，player；2，enemy
	{ "playerBuffEvent", playerBuffEvent },
	{ "enemyBuffEvent", enemyBuffEvent },
	{ "propEvent", propEvent },   // 道具ID = 對象。對象：（左邊）0(全体及能量体）， 1， 2， 3、 （右邊）10(全体及能量体）， 11， 12， 13
	{ "shipSkillEvent", shipSkillEvent },  // player 释放战舰技能  1 = 0、 enemy释放战舰节能  2 = 0.

										   // boss
	{ "setBossNpcBuffRoad", setBossNpcBuffRoad }, // 暂时没用
	{ "bossEvent", bossEvent },
	{ "playerAddDamage", playerAddDamage },
	{ "getBossStage", getBossStage },
	{ "getBossTotalDamage", getBossTotalDamage },
	{ "getResourcePath", getResourcePath },
	//{"synchronizationBossBattle", synchronizationBossBattle},

	//{"phoneOpenFileTest", phoneOpenFileTest}, // 给lua端测试json文件读取。
	//{"testForWorkPath", testForWorkPath}, //给lua端测试当前json value 获取
	*/

	{ NULL,NULL }
};

extern "C" int luaopen_libpower(lua_State *L)
{
#if LUA_VERSION_NUM > 501
	luaL_newlib(L, reg_info);
	return 1;
#else
	luaL_openlib(L, "Battle", reg_info, 0);
	return 0;
#endif
}
