#pragma once

#include "CommonData.h"
#include "Ship.h"
#include "FortMgr.h"
#include "BulletMgr.h"

class CBattle;

class CPlayer
{
public:
	CPlayer();
	CPlayer(int nPlayerSide);
	~CPlayer();
	void init(int nShipID, int nShipLv);
	void createShip(int nShipID, int nShipLv);
	void createFortMgr();
	void createBulletMgr();
	void setBattlePoint(CBattle *pBattle);
	void update(double dTime);
	void autoAddEnergy(double dTime);
	void addEnergy(int nEnergy);
	void addEnergyOnePoint();

	bool isArmySpaceEnough(int nArmy);   
	void addArmy(int nArmy);
	void armyCountDown(int nArmy);

	CShip* getShip();
	CFortMgr* getFortMgr();
	CBulletMgr* getBulletMgr();
	SYNTHE_SIZE(int, m_nPlayerSide, PlayerSide);
	SYNTHE_SIZE(int, m_nPlayerEnergy, PlayerEnergy);
	SYNTHE_SIZE(int, m_nPlayerArmy, PlayerArmy);
	SYNTHE_SIZE(double, m_dAddEnergyTime, AddEnergyTime);
	SYNTHE_SIZE(double, m_dTotalBattleTime, TotalBattleTime);

private:
	CBattle *m_pPlayerBattle;
	CShip* m_pShip;
	CFortMgr* m_pFortMgr;
	CBulletMgr* m_pBulletMgr;
};

