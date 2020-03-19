#pragma once

#include "Bullet.h"
#include <map>
using namespace std;


class CBulletMgr
{
public:
	enum bulletType
	{
		PLAYER_BULLET,
		ENEMY_BULLET,
		BOSS_BULLET
	};
	CBulletMgr();
	~CBulletMgr();
	void initData(bool nBulletType);
	
	void createBullet(int bulletID, int fortIndex, double dSpeed = 1000);
	void update(double dt);

	void cleanUpPlayerBulletMap();
	void cleanUpEnemyBulletMap();
	void deleteBulletByIndex(int index);

	map<int, CBullet*> getEnemyBullet();
	map<int, CBullet*> getPlayerBullet();

	int getPlayerBulletCount();
	void setPlayerBulletCount(int nNumber);
	int getEnemyBulletCount();
	void setEnemyBulletCount(int nNumber);

	void resetPlayerBullet(CBullet *pBullet, int whichBullet);
	void resetEnemyBullet(CBullet *pBullet, int whichBullet);

private:
	map<int, CBullet*> m_mapPlayerBullet;
	map<int, CBullet*> m_mapEnemyBullet;

	int m_nP_BulletCount;
	int m_nE_BulletCount;
	int m_nBulletType;
};

