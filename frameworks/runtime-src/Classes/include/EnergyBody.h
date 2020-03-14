#pragma once
#include <time.h>

#include "InitialData.h"
#include "Event.h"
#include <cstring>

using namespace std;

enum EnergyType
{
	CURE_ENERGY = 0,
	CHARGE_ENERGY = 1,
	CALL_HELP_ENERGY = 2
};

enum EnergyGetter
{
	PLAYER_OWNER,
	ENEMY_OWNER,
	NONE_OWNER
};



class CEnergyBody
{
public:

	CEnergyBody(string energyRoad, int energyIndex);
	~CEnergyBody();

	void initData();
	void update(double dt);

	void setBodySize();
	int getBodyWidth();
	int getBodyHeight();
	void playerDamage(double damage);
	void enemyDamage(double damage);
	void setBodyHp(double dHp);

	void changeBodyPos();
	void changeBodyType();

	bool isEnergyLive();
	int getBodyPosX();
	int getBodyPosY();
	int getBodyType();
	double getBodyHp();
	double getBodyMaxHp();
	double getPlayerDamage();
	double getEnemyDamage();
	bool isEnergyJump();
	bool isEnergyChange();

	// for prop 🐴
	void lockEnergy();
	void jumpEnergyBodyNow();
	//--------------------------

	double addHpEnergyBodyBuff();
	double addEnergyBuff();
	double addDamageToFort();
	int getWhoWin();
	void splitStringToData(string data);

	///////////////////////////////
	          //断线&同步
	void resetPlayerDamage(double dDamage);
	void resetEnemyDamage(double dDamage);
	void resetBodyHp(double dHp);
	void resetJumpTime(double dTime);
	double getJumpTime();
	void resetChangeTime(double dTime);
	double getChangeTime();
	void resetBodyType(int nType);
	void resetBodyPosX(int nPosX);
	void resetBodyPosY(int nPosY);
	void setIsEnergyJump(int n);
	void setIsEnergyChange(int n);
	void resetInitBodyHp(double dInitHp);

	void setBodyChangeTimes(int nTimes);
	int getBodyChangeTimes();
	void setBodyJumpTimes(int nTimes);
	int getBodyJumpTimes();
	bool isEnergyLock();
	void setEnergyLock(int isLock);

private:
	int m_nSizeWidth;
	int m_nSizeHeight;
	double m_dPlayerDamage;
	double m_dEnemyDamage;
	double m_dBodyHp;

	double m_dJumpTime;
	double m_dChangeTime;
	int m_nBodyType;

	int m_nBodyPosX;
	int m_nBodyPosY;
	bool m_isEnergyJump;
	bool m_isEnergyChange;

	double m_dInitBodyHp;
	int m_nEnergyIndex;
	int m_nChangeTimes;
	int m_nJumpTimes;

	bool m_isEnergyLock;

	int m_nRandPosY;
	int m_nJump1;
	int m_nChange1;
	int m_nJump2;
	int m_nChange2;
	int m_nJump3;
	int m_nChange3;
	int m_nJump4;
	int m_nChange4;
    int m_nJump5;
	int m_nChange5;
    int m_nJump6;
	int m_nChange6;
    int m_nChange7;
    int m_nChange8;
};

