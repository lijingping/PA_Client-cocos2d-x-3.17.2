#pragma once

#include "stdafx.h"
#include "CommonData.h"
#include "Player.h"
#include "Event.h"
#include <time.h>
#include <assert.h>
#include "cocos2d.h"

#include <json/rapidjson.h>
#include <json/document.h>

#include "scripting/lua-bindings/manual/CCLuaEngine.h"
#include "scripting/lua-bindings/manual/tolua_fix.h"


USING_NS_CC;
using namespace rapidjson;
using namespace std;

class CBattle
{
public:
	CBattle();
	~CBattle();
	void init();
	void createPlayer(int nSelfShipID, int nSelfShipLv, int nHostShipID, int nHostShipLv);
	void update(double dDelta);
	void setJsonDataPath(string strArmDataPath, string strShipDataPath);
	void setPlayerInitData(int nSelfShipID, int nSelfShipLv, int nHostShipID, int nHostShipLv);
	double createFort(int nSide, int nFortID, int nFortLv, int nPosY, int nArmyPoint);

	void gameOver();

	map<int, CFort*> getPlayerSelfForts();
	map<int, CFort*> getPlayerHostForts();
	string getArmDataPath();
	string getShipDataPath();


	void insertEventHandlerMap(int nIndex, int nHandler);
	int getHandlerByIndex(int nIndex);
	int getFortEventLuaHandler();
	void runFortEventHandler(int nSide, int nEventID, int nFortID, int nFortIndex, double dEventNumber, double dReserveNumber = 0);
	void runBulletEventHandler(int nSide, int nEventID, int nBulletID, int nBulletIndex, double dEventNumber = 0);

	SYNTHE_SIZE(int, m_nBattleType, BattleType);
	SYNTHE_SIZE(double, m_dDeltaTime, DeltaTime);
	SYNTHE_SIZE(double, m_dBattleTime, BattleTime);
	SYNTHE_SIZE(CPlayer*, m_pPlayerSelf, PlayerSelf);
	SYNTHE_SIZE(CPlayer*, m_pPlayerHost, PlayerHost);
	SYNTHE_SIZE(bool, m_isGamePause, GamePause);
	SYNTHE_SIZE(bool, m_isGameStop, GameStop);
	SYNTHE_SIZE(int, m_nFortEventHandler, FortEventHandler);
	SYNTHE_SIZE(int, m_nBulletEventHandler, BulletEventHandler);

//	CC_SYNTHESIZE(double, m_dDeltaTime, DeltaTime);
    
    void loadingConfigData();
    static const char* getArmsConfigDataValueByKey(int id, const char* key);
    static const char* getShipConfigDataValueByKey(int id, const char* key);

private:
	string m_strArmDataPath;
	string m_strShipDataPath;
	map<int, int> m_mapFortHandler;
    static map<int, map<char*, char*>> m_mapArmsConfigData;
    static map<int, map<char*, char*>> m_mapShipConfigData;
};

