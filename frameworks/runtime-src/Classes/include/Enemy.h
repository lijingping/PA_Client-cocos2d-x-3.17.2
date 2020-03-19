#pragma once
#include "Ship.h"
#include "BulletMgr.h"
#include "BuffMgr.h"

class CBattle;

class CEnemy
{
public:
	CEnemy();
	~CEnemy();
	//static CEnemy *getInstance();
	void update(double dt);
	void initData(string wrongCodePath);

	void createBullet(CFort* fort);
	void createShip(string wrongCodePath);
	void addBulletMgr();
	void addBuffMgr();
	void addBuff(int buffID, int fortID);

	// 对敌方全体炮台添加buff
	void addEnemyWholeBuff(int buffID);  

	//void setEnemyHp();
	double getEnemyHp();
	double getMaxEnemyHp();
	void countEnemyMaxHp(double dHp);

	CShip* getShip();
	CBulletMgr* getBulletMgr();
	CBuffMgr* getBuffMgr();

	void setEnemyBattle(CBattle *pBattle);

	void unmissileState();
	void recoveryUnmissile();
	bool isEnemyUnmissile();

	bool isHaveNpc();
	void setNpcHereOrNot(bool isBool);

	void countEnemyShipEnergy();

	int useShipSkill();// 需添加战舰能量不足的错误代码
	int getEnemyShipEnergy();
	bool isEnemyShipFireSkill();
	void setShipSkillFire(bool is);

	double getNpcTime();
	void setNpcTime(double nTime);
	
	void setEnemyShipEnergy(int nEnergy);

	double getEnemyPreviousHp();
	void setEnemyPreviousHp(double dHp);

	double getEnemyNowHp();

	double getCountDamageHp();
	void setCountDamageHp(double dDamage);

private:
	//static CEnemy *m_pInstance;
	CShip *m_pEnemyShip;
	CBulletMgr *m_pBulletMgr;
	CBuffMgr* m_pBuffMgr;
	int m_nFortID_top;
	int m_nFortID_mid;
	int m_nFortID_bot;

	double m_dEnemyHp;
	double m_dEnemyMaxHp;

	CBattle *m_pEnemyBattle;
	bool m_isUnmissileState;
	bool m_isNpcHere;
	
	double m_dNpcTime;

	int m_nEnemyShipEnergy;
	double m_dEnemyPreviousHp;
	double m_dEnemyNowHp;  // --
	double m_dCountDamageHp;

	bool m_isShipFireSkill; // --
};

