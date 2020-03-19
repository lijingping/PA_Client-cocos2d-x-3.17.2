#include "stdafx.h"
#include "BulletMgr.h"


CBulletMgr::CBulletMgr()
: m_nP_BulletCount(0)
, m_nE_BulletCount(0)
, m_nBulletType(0)
{
}


CBulletMgr::~CBulletMgr()
{
	if (m_nBulletType == ENEMY_BULLET)
	{
		cleanUpEnemyBulletMap();
	}
	else if (m_nBulletType == PLAYER_BULLET)
	{
		cleanUpPlayerBulletMap();
	}
}

void CBulletMgr::initData(bool isEnemyBullet)
{
	if (isEnemyBullet)
	{
		m_nBulletType = bulletType::ENEMY_BULLET;
	}
	else
	{
		m_nBulletType = bulletType::PLAYER_BULLET;
	}
}

void CBulletMgr::createBullet(int bulletID, int fortIndex, double dSpeed)
{
	if (m_nBulletType == ENEMY_BULLET)
	{
		CBullet *pBullet = new CBullet();
		pBullet->createBullet(bulletID, true, fortIndex, m_nE_BulletCount);
		pBullet->setBulletSpeed(dSpeed);
		m_mapEnemyBullet.insert(map<int, CBullet*>::value_type(m_nE_BulletCount, pBullet));
		m_nE_BulletCount += 1;
	}
	else if (m_nBulletType == PLAYER_BULLET)
	{
		CBullet *pBullet = new CBullet();
		pBullet->createBullet(bulletID, false, fortIndex, m_nP_BulletCount);
		pBullet->setBulletSpeed(dSpeed);
//		pBullet->setBulletPower(bulletPower);
		m_mapPlayerBullet.insert(map<int, CBullet*>::value_type(m_nP_BulletCount, pBullet));
		m_nP_BulletCount += 1;
	}
}

void CBulletMgr::update(double dt)
{
	if (m_nBulletType == ENEMY_BULLET)
	{
		map<int, CBullet*>::iterator iter = m_mapEnemyBullet.begin();
		for (; iter != m_mapEnemyBullet.end(); iter++)
		{
			(*iter).second->update(dt);
		}
	}
	else if (m_nBulletType == PLAYER_BULLET)
	{
		map<int, CBullet*>::iterator iter = m_mapPlayerBullet.begin();
		for (; iter != m_mapPlayerBullet.end(); iter++)
		{
			(*iter).second->update(dt);
		}
	}
}

void CBulletMgr::cleanUpPlayerBulletMap()
{
	map<int, CBullet*>::iterator iter = m_mapPlayerBullet.begin();
	for (; iter != m_mapPlayerBullet.end(); iter++)
	{
		delete((*iter).second);
		(*iter).second = nullptr;
	}
	m_mapPlayerBullet.clear();
}

void CBulletMgr::cleanUpEnemyBulletMap()
{
	map<int, CBullet*>::iterator iter = m_mapEnemyBullet.begin();
	for (; iter != m_mapEnemyBullet.end(); iter++)
	{
		delete((*iter).second);
		(*iter).second = nullptr;
	}
	m_mapEnemyBullet.clear();
}

void CBulletMgr::deleteBulletByIndex(int index)
{
	if (m_nBulletType == ENEMY_BULLET)
	{
		map<int, CBullet*>::size_type iterEnemy = index;
		delete(m_mapEnemyBullet[iterEnemy]);
		m_mapEnemyBullet[iterEnemy] = nullptr;
		m_mapEnemyBullet.erase(iterEnemy);
	}
	else if(m_nBulletType == PLAYER_BULLET)
	{
		map<int, CBullet*>::iterator iterPlayer = m_mapPlayerBullet.begin();
		for (; iterPlayer != m_mapPlayerBullet.end(); iterPlayer++)
		{
			if ((*iterPlayer).second->getBulletIndex() == index)
			{
				delete((*iterPlayer).second);
				(*iterPlayer).second = nullptr;
				m_mapPlayerBullet.erase(iterPlayer);
				break;
			}
		}
	}
}

map<int, CBullet*> CBulletMgr::getEnemyBullet()
{
	return m_mapEnemyBullet;
}

map<int, CBullet*> CBulletMgr::getPlayerBullet()
{
	return m_mapPlayerBullet;
}

int CBulletMgr::getPlayerBulletCount()
{
	return m_nP_BulletCount;
}

void CBulletMgr::setPlayerBulletCount(int nNumber)
{
	m_nP_BulletCount = nNumber;
}

int CBulletMgr::getEnemyBulletCount()
{
	return m_nE_BulletCount;
}

void CBulletMgr::setEnemyBulletCount(int nNumber)
{
	m_nE_BulletCount = nNumber;
}

void CBulletMgr::resetPlayerBullet(CBullet * pBullet, int whichBullet)
{
	m_mapPlayerBullet.insert(map<int, CBullet*>::value_type(/*m_nP_BulletCount - */whichBullet, pBullet));
}

void CBulletMgr::resetEnemyBullet(CBullet * pBullet, int whichBullet)
{
	m_mapEnemyBullet.insert(map<int, CBullet*>::value_type(/*m_nE_BulletCount - */whichBullet, pBullet));
}


