#pragma once

#ifndef Ship_h
#define Ship_h

//#include "BaseClass.h"
#include "InitialData.h"
#include "FortMgr.h"
#include "ShipSkill.h"
#include <string>

using namespace std;

class CBattle;

class CShip       // : public CShape
{
public:
	enum ShipType
	{
		PLAYER_SHIP = 0,
		ENEMY_SHIP
	};
	CShip();
	~CShip();
	void update(double dt);

	void initData(int nShipType, string wrongCodePath);
	//攻擊戰艦計算傷害
	void damageShip(int damage);
	//设置ship的ID
	void setShipData(string strShipDataPath, int nID, int nShipSkillLevel, int fort1, int fort2, int fort3);

	void setPos(int posX, int posY);
	int getShipPosX();
	int getShipPosY();

	int getShipSkin();
	CFortsMgr* getFortMgr();

	void setShipBattle(CBattle *pBattle);
	//计算能量。
	//void countShipEnergyByHp();
	void createShipSkill(double buffValue, double buffTime, double fireTime);

	void useShipSkill();

private:  // 私有成员变量
	CFortsMgr* m_pFortMgr;
	int m_nShipID;
	int m_nShipHp;
	bool m_isDeath;
	bool m_isEnemy;
	int m_nShipPosX;
	int m_nShipPosY;
	int m_nShipSkin;

	CBattle *m_pShipBattle;

	CShipSkill *m_pShipSkill;
	int m_nShipSkillLevel;
	
};


#endif /* ship_h */