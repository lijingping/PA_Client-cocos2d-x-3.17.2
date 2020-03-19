#pragma once
#ifndef KEYFRAME_H
#define KEYFRAME_H

#include "stdafx.h"
#include "Event.h"
#include <map>
#include <vector>
#include <sstream>
#include <limits>

using namespace std;

struct sBattleInfo
{
	sBattleInfo()
	{
		dEnergyTime = 0.0;
		isEnergyLive = false;
		nUpdateFrameCount = 0;
		nHitBulletCount = 0;
		dBattleTime = 0.0;
		isBattleRuning = false;
		isBattleStop = false;
		nEnergyCreateCount = 0;
		nRefreshCount = 0;
	}
	~sBattleInfo()
	{

	}
	//string sEnergyRoad;
	double dEnergyTime;
	bool isEnergyLive;
	int nUpdateFrameCount;
	int nHitBulletCount;
	double dBattleTime;
	bool isBattleRuning;
	bool isBattleStop;
	int nEnergyCreateCount;
	int nRefreshCount;
};

struct sHitBullet
{
	sHitBullet()
	{
		nBulletID = 0;
		nBulletIndex = 0;
		isEnemy = false;    // true 为1（我方子弹）， false为2（敌方子弹）
		x = 0.0;
		y = 0.0;
	}
	int nBulletID;
	int nBulletIndex;
	bool isEnemy;
	double x;
	double y;
};

struct sFortData
{
	sFortData()
	{

		nFortIndex = 0;
		nFortID = 0;		
		nBulletID = 0;
		nFortType = 0;
		nFortLevel = 0;
		dStarDomainCoe = 0.0;
		dQualityCoe = 0.0;
		dAckGrowCoe = 0.0;
		dHpGrowCoe = 0.0;
		dSpeedCoe = 0.0;
		dEnergyCoe = 0.0;
		dHp = 0.0;
		dEnergy = 0.0;
		dInterval = 0.0;
		dUninjuryRate = 0.0;
		dAck = 0.0;
		nPosX = 0;
		nPosY = 0;
		isLife = false;
		dFireTime = 0.0;
		dInitAck = 0.0;
		dInitHp = 0.0;
		dDefense = 0.0;
		dInitUninjuryRate = 0.0;
		dInitDamage = 0.0;
		isAddPassiveSkill = false;
		isParalysis = false;
		isBurning = false;
		isAckUp = false;

		isAckDown = false;
		isRepairing = false;
		isUnrepaire = false;
		isUnenergy = false;
		isShield = false;
		isRelive = false;
		isSkillFire = false;
		isBreakArmor = false;
		isFortPassiveSkillStronger = false;
		isHavePassiveSkillStronger = false;
		dBurningCountTime = false;
		dRepairingCountTime = false;
		dReliveCountTime = false;
		dReliveHp = false;
		dAckDownValue = false;
		dAckUpValue = false;
		dAddPassiveEnergyTime = false;

		dMomentAddHp = 0;
		dSkillAddHp = 0;
		dPropAddHp = 0;
		dContinueAddHp = 0;
		dSelfAddEnergy = 0;
		dEnergyAddEnergy = 0;
		dPropAddEnergy = 0;
		dAttackAddEnergy = 0;
		dBeDamageAddEnergy = 0;
		dBulletDamage = 0;
		dPropBulletDamage = 0;
		dBuffBurnDamage = 0;
		dNPC_Damage = 0;
		//dSecondCountForRelive = 0;
		dSkillDamage = 0;
		dSkillTime = 0;
		dShipSkillDamage = 0;
		dShipSkillAddHp = 0;
		dShipSkillAddEnergy = 0;
	};
	~sFortData()
	{

	};
	int nFortIndex;
	int nFortID;
	int nBulletID;
	int nFortType;
	int nFortLevel;
	double dStarDomainCoe;
	double dQualityCoe;
	double dAckGrowCoe;
	double dHpGrowCoe;
	double dSpeedCoe;
	double dEnergyCoe;
	double dHp; 
	double dEnergy;
	double dInterval;
	double dUninjuryRate;
	double dAck;
	int nPosX;
	int nPosY;
	bool isLife;
	double dFireTime;
	double dInitAck;
	double dInitHp;
	double dDefense;
	double dInitUninjuryRate;
	double dInitDamage;
	bool isAddPassiveSkill;
	bool isParalysis;
	bool isBurning;
	bool isAckUp;

	bool isAckDown;
	bool isRepairing;
	bool isUnrepaire;
	bool isUnenergy;
	bool isShield;
	bool isRelive;
	bool isSkillFire;
	bool isBreakArmor;
	bool isFortPassiveSkillStronger;
	bool isHavePassiveSkillStronger;
	double dBurningCountTime;
	double dRepairingCountTime;
	double dReliveCountTime;
	double dReliveHp;
	double dAckDownValue; 
	double dAckUpValue;
	double dAddPassiveEnergyTime;

	double dMomentAddHp;
	double dSkillAddHp;
	double dPropAddHp;
	double dContinueAddHp;
	double dSelfAddEnergy;
	double dEnergyAddEnergy;
	double dPropAddEnergy;
	double dAttackAddEnergy;
	double dBeDamageAddEnergy;
	double dBulletDamage;
	double dPropBulletDamage;
	double dBuffBurnDamage;
	double dNPC_Damage;
	//double dSecondCountForRelive;
	double dSkillDamage;
	double dSkillTime;
	double dShipSkillDamage;
	double dShipSkillAddHp;
	double dShipSkillAddEnergy;
	//
	vector<int> fortEvent;
};

struct SBulletData
{
	SBulletData()
	{
		isEnemy = false;
		nBulletID = 0;
		nFortIndex = 0;
		nBulletIndex = 0;
		dPosX = 0.0;
		dPosY = 0.0;
		dTime = 0.0;
	}
	bool isEnemy;
	int nBulletID;
	int nFortIndex;
	int nBulletIndex;
	double dPosX;
	double dPosY;
	double dTime;
};

struct SEnergyBodyData
{
	SEnergyBodyData()
	{
		dPlayerDamage = 0.0;
		dEnemyDamage = 0.0;
		dBodyHp = 0.0;
		dJumpTime = 0.0;
		dChangeTime = 0.0;
		nBodyType = 0;
		nPosX = 0;
		nPosY = 0;
		isJump = false;
		isChange = false;
		dInitHp = 0.0;
		nChangeTimeCount = 0;
		nJumpTimeCount = 0;
		isEnergyLock = false;
	}
	double dPlayerDamage;
	double dEnemyDamage;
	double dBodyHp;
	double dJumpTime;
	double dChangeTime;
	int nBodyType;
	int nPosX;
	int nPosY;
	bool isJump;
	bool isChange;
	double dInitHp;
	int nChangeTimeCount;
	int nJumpTimeCount;

	bool isEnergyLock;
};

class CBattle;

class CKeyFrame
{
public:
	CKeyFrame(CBattle *pBattle);
	~CKeyFrame();
	const char* getCharBattleData(int nPlayerIndex); // 0 ：player; 1: enemy
	const char* getCharOnlineSynchorData(int nPlayerIndex);// 0:player ;1:enemy.
	const char* getCharBossBattleData();
	const char* getCharOnlineBossBattleData();
	string getStringBattleData();
	void cleanContainerData();
	void setBattleFrameData(sBattleInfo info);
	int getBattleFrameData();
	void setBulletNumber(int nPlayer, int nEnemy);
	void setHitBulletData(map<int, sHitBullet*> map);
	int getHitBulletData();
	void setEnergyBodyEventData(vector<sEnergyBodyEvent*> event);
	int getEnergyBodyEventData();
	void setPlayerFortData(sFortData pData, int nIndex);
	int getPlayerFortData();
	void setEnemyFortData(sFortData pData, int nIndex);
	int getEnemyFortData();
	void setPlayerFortEventData();
	int getPlayerFortEventData();
	void setEnemyFortEventData();
	int getEnemyFortEventData();
	void setPlayerBulletData(SBulletData data);
	void setEnemyBulletData(SBulletData data);
	void setEnergyBodyData(SEnergyBodyData data);

private:
	CBattle *m_pKeyFrameBattle;
	string m_strCharBattleFrame;
	string m_sEnergyBodyRoad;
	sBattleInfo m_sBattleInfo;
	int m_nPlayerBulletNumber;
	int m_nEnemyBulletNumber;
	map<int, sHitBullet*> m_mapKHitBullet;
	vector<sEnergyBodyEvent*> m_vecEnergyBodyEvent;
	map<int, sFortData> m_mapPlayerFortData;
	map<int, sFortData> m_mapEnemyFortData;
	vector<SBulletData> m_vecPlayerBulletData;
	vector<SBulletData> m_vecEnemyBulletData;
	SEnergyBodyData m_sEnergyBodyData;
};

#endif // !KEYFRAME_H
