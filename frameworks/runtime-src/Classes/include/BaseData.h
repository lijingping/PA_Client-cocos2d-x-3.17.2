#pragma once
#include "CommonData.h"

class CBaseData
{
public:
	CBaseData();
	~CBaseData();
	SYNTHE_SIZE(int, m_nSide, Side);
	SYNTHE_SIZE(int, m_nID, ID);
	SYNTHE_SIZE(int, m_nLv, Lv);
	SYNTHE_SIZE(double, m_dHp, Hp);
	SYNTHE_SIZE(double, m_dInitHp, InitHp);
	SYNTHE_SIZE(double, m_dEnergy, Energy);
	SYNTHE_SIZE(double, m_dAtk, Atk);
	SYNTHE_SIZE(double, m_dInitAtk, InitAtk);
	SYNTHE_SIZE(int, m_nRange, Range);//射程
	
	SYNTHE_SIZE(double, m_dPosX, PosX);
	SYNTHE_SIZE(double, m_dPosY, PosY);
	SYNTHE_SIZE(int, m_nSizeRadius, SizeRadius);  // 范围大小
	SYNTHE_SIZE(int, m_nSizeLength, SizeLength);  // 长
	SYNTHE_SIZE(int, m_nSizeWidth, SizeWidth);    // 宽 

	SYNTHE_SIZE(int, m_nBulletID, BulletID);             // 子弹ID
	SYNTHE_SIZE(int, m_nBulletType, BulletType);         // 子弹类型
	SYNTHE_SIZE(int, m_nBulletSpeed, BulletSpeed);   // 子弹飞行速度

	SYNTHE_SIZE(double, m_dSkillTime, SkillTime);        // 技能时间
	
	SYNTHE_SIZE(double, m_dFireInterval, FireInterval); // 攻击速度
	SYNTHE_SIZE(double, m_dInitFireInterval, InitFireInterval);//初始化攻速


	virtual bool isInRange(int ax, int ay, int bx, int by, int nRange);
};
