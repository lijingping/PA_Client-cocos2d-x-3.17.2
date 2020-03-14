#pragma once

#include "CommonData.h"
#include "Fort.h"

class CBulletBase
{
public:
	CBulletBase();
	~CBulletBase();
	SYNTHE_SIZE(int ,m_nBulletID, BulletID);
	SYNTHE_SIZE(int, m_nBulletIndex, BulletIndex);
	SYNTHE_SIZE(double, m_dPosX, PosX);
	SYNTHE_SIZE(double, m_dPosY, PosY);
	SYNTHE_SIZE(int, m_nBulletSide, BulletSide);
	SYNTHE_SIZE(CFort*, m_pTargetFort, TargetFort);
	SYNTHE_SIZE(double, m_dDamageNum, DamageNum);
	SYNTHE_SIZE(int, m_nSizeRadius, SizeRadius);
	SYNTHE_SIZE(int, m_nBulletSpeed, BulletSpeed);

	virtual void update(double dTime);
};

