#pragma once

#include <vector>
#include "BulletNormal.h"
#include "Event.h"

class CBattle;
class CBulletMgr
{
public:
	CBulletMgr(int nSide, CBattle* pBattle);
	~CBulletMgr();

	void update(double dTime);

	// 射击炮台
	void createBullet(int nID, int nType, double dPosX, double dPosY, int nFirerID, int nFirerIndex, double dAtk, CFort* pTargetFort = nullptr);
	// 射击战舰
//	void createBulletToShip(int nID, int nType, double dPosX, double dPosY, int nFirerID, int nFirerIndex, double dShipPosX, double dShipPosY);
	// 战舰的子弹
	void createShipBullet(int nID, int nType, double dPosX, double dPosY, CFort* pTargetFort);

	void removeBulletFromVec(int nID, int nIndex);
	// 移除射往阵亡战机子弹
	void removeBrokenTargetBullet(int nTargetID, int nTargetIndex);

	vector<CBulletNormal*> getBulletVec();

	vector<SBulletEventData> getBulletEvent();
	void insertBulletEvent(int nID, int nIndex, double dPosX, double dPosY, int nEvent);
	void clearBulletEventVec();

private:
	int m_nSide;
	CBattle* m_pBattle;
	vector<CBulletNormal*> m_vecBullet;
	int m_nBulletCount;
	vector<SBulletEventData> m_vecBulletEvent;
};

