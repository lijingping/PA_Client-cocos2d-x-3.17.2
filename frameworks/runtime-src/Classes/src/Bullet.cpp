#include "stdafx.h"
#include "Bullet.h"
#include "Battle.h"

CBullet::CBullet()
	: m_isEnemy(false)
	, m_nBulletID(0)
	, m_nBulletSpeed(0)
	, m_nIndexOfFort(0)
	, m_dPosX(0.0)
	, m_dPosY(0.0)
	, m_nBulletIndex(0)
	, m_dCountTime(0.0)
{
	m_isBossBullet = false;
	m_dBossBulletTime = 0.0;
}

CBullet::~CBullet()
{

}



void CBullet::update(double dt)
{
	m_dCountTime += dt;
	if (m_isEnemy)
	{
		m_dPosX -= m_nBulletSpeed * dt;
	}
	else
	{
		m_dPosX += m_nBulletSpeed * dt;
	}
}

int CBullet::bossBulletUpdata(double delta)
{
	if ((m_dBossBulletTime - delta < 0.00001) && (m_dBossBulletTime - delta > -0.00001))
	{
		m_dBossBulletTime = delta;
	}
	m_dBossBulletTime -= delta;
	if (m_dBossBulletTime <= 0)
	{
		return 1;
	}
	return 0;
}

void CBullet::createBullet(int bulletID, bool isEnemy, int fortIndex, int bulletIndex)
{
	m_nBulletID = bulletID;
	m_isEnemy = isEnemy;
	m_nIndexOfFort = fortIndex;
	m_nBulletIndex = bulletIndex;

	if (isEnemy)
	{
		m_dPosX = ENEMYFORT_POS_X - FORT_WIDTH * 0.5 + 50;
	}
	else
	{
		m_dPosX = MYFORT_POS_X + FORT_WIDTH * 0.5  - 50;
	}
	if (fortIndex == 0)
	{
		m_dPosY = FORT_TOP_POS_Y;
	}
	else if(fortIndex == 1)
	{
		m_dPosY = FORT_MID_POS_Y;
	}
	else if (fortIndex == 2)
	{
		m_dPosY = FORT_BOT_POS_Y;
	}
	
}

void CBullet::createBossBullet(int bulletIndex, double dTime)
{
	//m_isBossBullet = true;
	m_nBulletIndex = bulletIndex;
	m_dBossBulletTime = dTime;
}

void CBullet::setBulletSpeed(double dSpeed)
{
	m_nBulletSpeed = dSpeed;
}


double CBullet::getBulletPosX()
{
	return m_dPosX;
}

double CBullet::getBulletPosY()
{
	return m_dPosY;
}

int CBullet::getFortIndex()
{
	return m_nIndexOfFort;
}

int CBullet::getBulletIndex()
{
	return m_nBulletIndex;
}

int CBullet::getBulletID()
{
	return m_nBulletID;
}

bool CBullet::isEnemy()
{
	return m_isEnemy;
}

double CBullet::getBossBulletTime()
{
	return m_dBossBulletTime;
}

void CBullet::resetBulletOwner(int nSide)
{
	if (nSide == 0)
	{
		m_isEnemy = false;
	}
	else if (nSide == 1)
	{
		m_isEnemy = true;
	}
}

void CBullet::resetBulletID(int nBulletID)
{
	m_nBulletID = nBulletID;
}

void CBullet::resetFortIndex(int nFortIndex)
{
	m_nIndexOfFort = nFortIndex;
}

void CBullet::setPosX(double dPosX)
{
	m_dPosX = dPosX;
}

void CBullet::setPosY(double dPosY)
{
	m_dPosY = dPosY;
}

void CBullet::resetBulletIndex(int nBulletIndex)
{
	m_nBulletIndex = nBulletIndex;
}

void CBullet::resetTime(double dTime)
{
	m_dCountTime = dTime;
}

double CBullet::getCountTime()
{
	return m_dCountTime;
}
