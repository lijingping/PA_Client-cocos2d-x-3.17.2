#pragma once

enum EFortEvent
{
	FORT_BORN = 1,                   // 完成生产
	FORT_TURN_BODY = 2,              // 旋转机体 （旋转度数）
	FORT_ATTACK_READY = 3,           // 攻击准备
	FORT_FIRE_EVENT = 4,                   // 攻击发动
	FORT_SKILL_ON = 5,               // 技能开
	FORT_SKILL_OFF = 6,              // 技能完
	FORT_BE_DAMAGE = 7,              // 被攻击  （扣除的血量）
	FORT_ADD_ATK = 8,                // 攻击加强
	FORT_ADD_HP = 9,                 // 血量增加 （增加的血量）
	FORT_ADD_ENERGY = 10,            // 能量增加 （增加的能量）
	FORT_DIE = 11,                   // 死亡
	FORT_CREATE = 12
};

struct SFortEvent
{
	SFortEvent()
	{
		nEventID = 0;
		dEventNumber = 0.0;
	}
	int nEventID;
	double dEventNumber;
};

enum EBulletEvent
{
	BULLET_BORN = 1,    // 子弹创建
	BULLET_BOMB = 2,    // 子弹爆炸
	BULLET_REMOVE = 3   // 移除子弹
};

struct SBulletEventData
{
	SBulletEventData()
	{
		nBulletID = 0;
		nBulletIndex = 0;
		dPosX = 0.0;
		dPosY = 0.0;
		nEventID = 0;
	}
	int nBulletID;
	int nBulletIndex;
	double dPosX;
	double dPosY;
	int nEventID;
};

enum EShipEvent
{

};

struct SShipEventData
{

};