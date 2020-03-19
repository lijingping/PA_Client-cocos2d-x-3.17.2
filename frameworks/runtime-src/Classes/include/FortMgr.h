#pragma once
#ifndef CFortsMgr_h
#define CFortsMgr_h


#include <vector>
#include <map>

#include "InitialData.h"
#include <stdio.h>
#include "Fort.h"
#include <string>

using namespace std;

class CBattle;

class CFortsMgr
{
public:
	CFortsMgr(bool isEnemy, string wrongCodePath);
	~CFortsMgr();

	void update(double delta);

	//创建炮台
	void createForts();  //int fort1, int fort2, int fort3, bool isEnemy
	//移除损坏炮台
	void removeBrokenFort(int fortID);
	//复活损坏的炮台
	void createFortByID(int fortID);
	//攻击炮台
	//void damageFort(int fortIndex, int nDamage);

	double getPlayerTotalHp();
	double getEnemyTotalHp();

	void cleanBetterBuff();
	void cleanBadBuff();

	int getFortAck(int fortIndex);
	bool isFortLive(int fortIndex);

	CFort* getFortByID(int ID, bool isEnemy);
	CFort* getFortByIndex(int index, bool isEnemy);
	//int* getFortsPos(int fortID, bool isEnemy);

	map<int, CFort*> getPlayerFort();
	map<int, CFort*> getEnemyFort();

	bool isPlayerCleanBetterBuff();
	bool isPlayerCleanBadBuff();
	bool isEnemyCleanBadBuff();
	bool isEnemyCleanBetterBuff();
	void recoveryCleanBetterBuff();
	void recoveryCleanBadBuff();

	void setFortMgrBattle(CBattle *pBattle);
	void setFortSuitBuff(double suitBuffValue);

	// for 提取最后死亡的一炮台
	void setPlayerDieFortID(int fortID);
	void setEnemyDieFortID(int fortID);
	int getDiePlayerFortID();
	int getDieEnemyFortID();

	// 设置boss战的伤害加成
	void addInjuryPercent(double dPercent);

private:
	map<int, CFort*> m_mapMyForts;
	map<int, CFort*> m_mapEnemyForts;
	bool m_isEnemy;
	int m_nMyTop_fortID;
	int m_nMyMid_fortID;
	int m_nMyBot_fortID;
	int m_nEnemyTop_fortID;
	int m_nEnemyMid_fortID;
	int m_nEnemyBot_fortID;
	// P:player 我方
	bool m_isPCleanBetBuff;
	bool m_isPCleanBadBuff;
	// E:enemy 敌方
	bool m_isECleanBetBuff;
	bool m_isECleanBadBuff;

	CBattle *m_pFortMgrBattle;
	string m_strWrongCodePath;

	int m_nRecentDiePlayerFort;
	int m_nRecentDieEnemyFort;
};


#endif /* CFortsMgr_h */


