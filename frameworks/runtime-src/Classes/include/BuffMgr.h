#pragma once

#include <map>
#include <vector>
#include "Buff.h"
#include "InitialData.h"
#include "Event.h"

 // 炮台的buff和ship的buff

class CBattle;

using namespace std;

class CBuffMgr
{
public:
	CBuffMgr(bool isEnemy);
	~CBuffMgr();
	void update(double dt);
	void addBuff(int buffID, int fort = 0, double buffValue = 0.0, double buffTime = 0.0);
	//void deleteBuff(int buffIndex);
	void deleteBuffByFortID(int fortID, int buffID);
	void deleteAllBuffByFortID(int nFortID);  // 删除所有buff
	void cleanPlayerBuffMap();
	void cleanEnmeyBuffMap();

	void deletePlayerBadBuff();
	void deletePlayerGoodBuff();
	void deleteEnemyBadBuff();
	void deleteEnemyGoodBuff();

	void setBuffMgrBattle(CBattle *pBattle);
	void insertBuffEventToVec(int fort, int buffID);
	void cleanBuffEventVec();

	vector<sBuffEvent> getPlayerBuffEvent();
	vector<sBuffEvent> getEnemyBuffEvent();

	void addBuffTime(int buffID, int fortID, double addTime);

	map<int, CBuff*> getPlayerBuffMap();
	map<int, CBuff*> getEnemyBuffMap();
	void setBuffIndex(int nBuffIndex);

private:
	map<int, CBuff*> m_mapPlayerBuff;
	map<int, CBuff*> m_mapEnemyBuff;

	bool m_isEnemy;
	int m_nBuffIndex;

	CBattle *m_pBuffMgrBattle;
	vector<sBuffEvent> m_vecPlayerBuffEvent;
	vector<sBuffEvent> m_vecEnemyBuffEvent;
};

