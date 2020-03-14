#pragma once

#include "BulletBase.h"
#include "CommonData.h"
#include "Fort.h"
#include "Tool.h"
#include <vector>
#include <map>

using namespace std;

class CBattle;

class CBulletNormal:public CBulletBase
{
public:
	CBulletNormal(int nSide, int nID, int nType, CBattle* pBattle);
	~CBulletNormal();

	void update(double dTime);

	void setBeginPos(double dPosX, double dPosY);
	
	void bulletShellMove(double dTime);    // 导弹移动
	void bulletShellMoveToShip(double dTime);// 子弹射向战舰
	void pierceShellMove(double dTime);    // 穿甲弹
	void laserFire(double dTime);          // 激光

	//void firerAndTarget(CFort* pFirerFort, CFort* pTargetFort);
	void setTargetFort(CFort* pFort);
	void setTheVecOfShip();
	void bulletFly(double dTime);
	
	int getTargetFortID();
	int getTargetFortIndex();
	// 点到方向向量的距离
	double countPointToLineDis(double dPointX, double dPointY);
	// 计算旋转角度
	void turnBulletDirection(double dVecX, double dVecY);


	SYNTHE_SIZE(int, m_nBulletType, BulletType);
	SYNTHE_SIZE(bool, m_isShipBullet, IsShipBullet);            // 是否为战舰子弹
	SYNTHE_SIZE(bool, m_isBulletToShip, IsBulletToShip);        // 是否是射向战舰的子弹
	//SYNTHE_SIZE(CFort*, m_pTargetFort, TargetFort);             // 目标炮台
	//SYNTHE_SIZE(CFort*, m_pFirerFort, FirerFort);               // 发射者
	SYNTHE_SIZE(double, m_dTargetDirectionX, TargetDirectionX); // 方向的X量
	SYNTHE_SIZE(double, m_dTargetDirectionY, TargetDirectionY); // 方向的Y量
	SYNTHE_SIZE(double, m_dDirectionLength, DirectionLength);   // 向量的长度
	SYNTHE_SIZE(double, m_dBulletDamage, BulletDamage);         // 子弹的伤害
	SYNTHE_SIZE(int, m_nFirerID, FirerID);                      // 射击者ID
	SYNTHE_SIZE(int, m_nFirerIndex, FirerIndex);                // 射击着序号
	SYNTHE_SIZE(double, m_dTurnRadian, TurnRadian);             // 旋转角度（弧度）
	SYNTHE_SIZE(bool, m_isInShipUp, IsInShipUp);                // 子弹是否在战舰上
	SYNTHE_SIZE(bool, m_isDamageShip, IsDamageShip);            // 是否攻击过战舰	

private: 

	CBattle* m_pBulletBattle;
	vector<CFort*> m_vecRecordAttackFort;
	//CFort* m_pTargetFort;
};

