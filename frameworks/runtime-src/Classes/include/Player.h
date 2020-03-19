#pragma once

#include "Ship.h"
#include "BulletMgr.h"
#include "BuffMgr.h"
#include <string>
using namespace std;

class CBattle;

class CPlayer
{
public:
	CPlayer();
	~CPlayer();
	//static CPlayer* getInstance();
	void update(double dt);
	void initData(string wrongCodePath);

	void createBullet(CFort* fort);

	void addBuff(int buffID, int fortID = 0);

	// 对我方全体炮台添加buff
	void addPlayerWholeBuff(int buffID);

	void createShip(string wrongCodePath);
	void addBulletMgr();
	void addBuffMgr();


	void countPlayerMaxHp(double dHp);
	double getPlayerHp();
	double getMaxPlayerHp();
	CShip* getShip();
	CBulletMgr* getBulletMgr();
	CBuffMgr* getBuffMgr();

	void setPlayerBattle(CBattle *pBattle);

	void unmissileState();
	void recoveryUnmisslie();
	bool isPlayerUnmissile();

	bool isHaveNpc();
	void setNpcHereOrNot(bool isBool);
	void countPlayerShipEnergy();

	int useShipSkill();// 需添加战舰能量不足的错误代码
	int getPlayerShipEnergy();
	bool isPlayerShipFireSkill();
	void setShipSkillFire(bool is);

	double getNpcTime();
	void setNpcTime(double nTime);

	void setPlayerShipEnergy(int nEnergy);

	double getPlayerPreviousHp();
	void setPlayerPreviousHp(double dHp);

	double getPlayerNowHp();

	double getCountDamageHp();
	void setCountDamageHp(double dDamage);

private:
	CShip* m_pPlayerShip;
	CBulletMgr* m_pBulletMgr;
	CBuffMgr* m_pBuffMgr;

	int m_nFortID_top;
	int m_nFortID_mid;
	int m_nFortID_bot;

	double m_dPlayerHp;
	double m_dMaxPlayerHp;

	CBattle *m_pPlayerBattle;
	bool m_isUnmissileState;
	bool m_isNpcHere;

	double m_dNpcTime;

	int m_nPlayerShipEnergy;
	double m_dPlayerPreviousHp;
	double m_dPlayerNowHp;// --
	double m_dCountDamageHp;

	bool m_isShipFireSkill; //--
};

