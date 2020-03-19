#pragma once

#include "Props.h"
#include "Event.h"
#include <map>
#include <string>
#include <vector>

using namespace std;

class CBattle;

class CPropsMgr
{
public:
	CPropsMgr(CBattle *pBattle, string propDataPath, string wrongDataPath);
	~CPropsMgr();
	void initData();
	void update(double delta);
	//nUser（使用道具方） 1：player方，2：enemy方；player(道具目标方) 1:player方， 2：enemy方； 全体目标，fortID为0。
	int useProp(int nUser, int nPropID, int player, int fortID);

	void usePropForReconnect(int nPropCount, int nPropID, double dBurstTime, int nUser, int nTargetSide, int nFortID, double dEnergyNpcDamage);
	void putPropEventToVec(int nPropEventID, int nTarget);

	//道具ID， 目标方， 炮台ID
	void insertUsePropEventInVec(int propID, int targetSide, int fortID);
	void insertPropBurstEventInVec();// 暂时先不用


	// 能量体召唤NPC 
	void energyBodyCallNpc(double damage, int nUser, int nTarget);

	int getPropsCount();
	void setPropsCount(int nCount);
	map<int, CProps*> getPropsMap();
	void cleanPropMap();
	vector<sPropEvent> getPropEventVec();
	void cleanPropEvent();
	bool isPlayerNpcSecond();
	void setPlayerNpcSecond(int nBool);
	bool isEnemyNpcSecond();
	void setEnemyNpcSecond(int nBool);
	int getPlayerPropNpc();
	void setPlayerPropNpc(int nKind);
	int getEnemyPropNpc();
	void setEnemyPropNpc(int nKind);
	double getPlayerDamage();
	void setPlayerDamage(double dDamage);
	double getEnemyDamage();
	void setEnemyDamage(double dDamage);

private:
	//bool m_isEnemy;
	CBattle *m_pPropMgrBattle;
	string m_strPropDataPath;
	string m_strWrongDataPath;

	int m_nPropsCount;
	map<int, CProps*> m_mapProps;

	vector<sPropEvent> m_vecPropEvent;

	// 排队NPC 
	bool m_isPlayerNpcSecond;  //是否有第二只NPC
	bool m_isEnemyNpcSecond;   //是否有第二只NPC
	int m_nPlayerPropNpc;    //是左玩家的道具NPC为1 是左玩家的能量体NPC为2， 初始为0.
	int m_nEnemyPropNpc;     //是右玩家的道具NPC为1 是右玩家的能量体NPC为2， 初始为0.
	double m_dPlayerDamage;  //左玩家的能量体伤害
	double m_dEnemyDamage;   //右玩家的能量体伤害
};

