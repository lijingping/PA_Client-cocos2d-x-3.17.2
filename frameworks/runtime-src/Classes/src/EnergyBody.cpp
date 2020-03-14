#include "stdafx.h"
#include "EnergyBody.h"


CEnergyBody::CEnergyBody(string energyRoad, int energyIndex)
	: m_dJumpTime(15.0)
	, m_dChangeTime(10.0)
	, m_nSizeWidth(0)
	, m_nSizeHeight(0)
	, m_dBodyHp(0)
	, m_dInitBodyHp(0)
	, m_dPlayerDamage(0.0)
	, m_dEnemyDamage(0.0)
	, m_nBodyType(0)
	, m_nBodyPosY(0)
	, m_isEnergyJump(false)
	, m_isEnergyChange(false)
	, m_nChangeTimes(0)
	, m_nJumpTimes(0)
	, m_nRandPosY(0)
	, m_isEnergyLock(false)
	, m_nJump1(0)
	, m_nJump2(0)
	, m_nJump3(0)
	, m_nJump4(0)
	, m_nJump5(0)
	, m_nJump6(0)
	, m_nChange1(0)
	, m_nChange2(0)
	, m_nChange3(0)
	, m_nChange4(0)
	, m_nChange5(0)
	, m_nChange6(0)
	, m_nChange7(0)
	, m_nChange8(0)
{
	m_nBodyPosX = SCREEN_SIZE_WIDTH / 2;
	m_nEnergyIndex = energyIndex;
	//initData();
	splitStringToData(energyRoad);
	if (m_nRandPosY == 0)
	{
		m_nBodyPosY = ENERGY_POS_Y_TOP;
	}
	else if (m_nRandPosY == 1)
	{
		m_nBodyPosY = ENERGY_POS_Y_MID;
	}
	else
	{
		m_nBodyPosY = ENERGY_POS_Y_BOT;
	}
	
}


CEnergyBody::~CEnergyBody()
{
}

void CEnergyBody::initData()
{
	//clock_t nowTime;
	//nowTime = clock();
	//m_nBodyType = clock() % 3;

	//int randPosY = clock() % 3;
	//if (m_nRandPosY == 0)
	//{
	//	m_nBodyPosY = ENERGY_POS_Y_TOP;
	//}
	//else if (m_nRandPosY == 1)
	//{
	//	m_nBodyPosY = ENERGY_POS_Y_MID;
	//}
	//else
	//{
	//	m_nBodyPosY = ENERGY_POS_Y_BOT;
	//}

}

void CEnergyBody::update(double dt)
{

	m_dJumpTime -= dt;
	if ((m_dJumpTime < 0.00001) && (m_dJumpTime > -0.00001))
	{
		m_dJumpTime = 0;
	}
	m_isEnergyJump = false;
	if (m_dJumpTime <= 0)
	{
		changeBodyPos();
		m_nJumpTimes++;
		m_isEnergyJump = true;
	}
	if (!m_isEnergyLock)
	{
		if ((m_dChangeTime - dt < 0.00001) && (m_dChangeTime - dt > -0.00001))
		{
			m_dChangeTime = dt;
		}
		m_dChangeTime -= dt;
		m_isEnergyChange = false;
		if (m_dChangeTime <= 0)
		{
			changeBodyType();
			m_dChangeTime = 10;
			m_nChangeTimes++;  // ´ÎÊý
			m_isEnergyChange = true;
		}
	}
}

void CEnergyBody::setBodySize()
{
}

int CEnergyBody::getBodyWidth()
{
	return m_nSizeWidth;
}

int CEnergyBody::getBodyHeight()
{
	return m_nSizeHeight;
}

void CEnergyBody::playerDamage(double damage)
{
	m_dBodyHp -= damage; 
	//if (m_dBodyHp > 0)
	//{
		m_dPlayerDamage += damage;
	//}
	//else
	//{
	//	m_dPlayerDamage += (damage + m_dBodyHp);
	//	m_dBodyHp = 0;
	//}
}

void CEnergyBody::enemyDamage(double damage)
{
	m_dBodyHp -= damage;
	//if (m_dBodyHp > 0)
	//{
		m_dEnemyDamage += damage;
	//}
	//else
	//{
	//	m_dEnemyDamage += (damage + m_dBodyHp);
	//	m_dBodyHp = 0;
	//}
}

void CEnergyBody::setBodyHp(double dHp)
{
	m_dInitBodyHp = dHp * 0.2;
	m_dBodyHp = m_dInitBodyHp;
}

void CEnergyBody::changeBodyPos()
{
	//clock_t randPos;
	//randPos = clock() % 2;
	int nRandPos = 0;
	if (m_nJumpTimes == 0)
	{
		nRandPos = m_nJump1;
	}
	else if (m_nJumpTimes == 1)
	{
		nRandPos = m_nJump2;
	}
	else if (m_nJumpTimes == 2)
	{
		nRandPos = m_nJump3;
	}
	else if (m_nJumpTimes == 3)
	{
		nRandPos = m_nJump4;
	}
	else if (m_nJumpTimes == 4)
	{
		nRandPos = m_nJump5;
	}
	else if (m_nJumpTimes == 5)
	{
		nRandPos = m_nJump6;
	}

	if (m_nBodyPosY == ENERGY_POS_Y_TOP)
	{
		if (nRandPos == 0)
		{
			m_nBodyPosY = ENERGY_POS_Y_MID;
		}
		else
		{
			m_nBodyPosY = ENERGY_POS_Y_BOT;
		}
	}
	else if (m_nBodyPosY == ENERGY_POS_Y_MID)
	{
		if (nRandPos == 0)
		{
			m_nBodyPosY = ENERGY_POS_Y_TOP;
		}
		else
		{
			m_nBodyPosY = ENERGY_POS_Y_BOT;
		}
	}
	else if (m_nBodyPosY == ENERGY_POS_Y_BOT)
	{
		if (nRandPos == 0)
		{
			m_nBodyPosY = ENERGY_POS_Y_TOP;
		}
		else
		{
			m_nBodyPosY = ENERGY_POS_Y_MID;
		}
	}
	
	m_dJumpTime = 15;
}

void CEnergyBody::changeBodyType()
{
	//clock_t randType;
	//randType = clock() % 2;
	int nRandType = 0;
	if (m_nChangeTimes == 0)
	{
		nRandType = m_nChange1;
	}
	else if (m_nChangeTimes == 1)
	{
		nRandType = m_nChange2;
	}
	else if (m_nChangeTimes == 2)
	{
		nRandType = m_nChange3;
	}
	else if (m_nChangeTimes == 3)
	{
		nRandType = m_nChange4;
	}
	else if (m_nChangeTimes == 4)
	{
		nRandType = m_nChange5;
	}
	else if (m_nChangeTimes == 5)
	{
		nRandType = m_nChange6;
	}
	else if (m_nChangeTimes == 6)
	{
		nRandType = m_nChange7;
	}
	else if (m_nChangeTimes == 7)
	{
		nRandType = m_nChange8;
	}

	if (m_nBodyType == CURE_ENERGY)
	{
		if (nRandType == 0)
		{
			m_nBodyType = CHARGE_ENERGY;
		}
		else
		{
			m_nBodyType = CALL_HELP_ENERGY;
		}
	}
	else if (m_nBodyType == CHARGE_ENERGY)
	{
		if (nRandType == 0)
		{
			m_nBodyType = CURE_ENERGY;
		}
		else
		{
			m_nBodyType = CALL_HELP_ENERGY;
		}
	}
	else if (m_nBodyType == CALL_HELP_ENERGY)
	{
		if (nRandType == 0)
		{
			m_nBodyType = CURE_ENERGY;
		}
		else
		{
			m_nBodyType = CHARGE_ENERGY;
		}
	}

}

bool CEnergyBody::isEnergyLive()
{
	if (m_dBodyHp > 0)
	{
		return true;
	}
	return false;
}

int CEnergyBody::getBodyPosX()
{
	return m_nBodyPosX;
}

int CEnergyBody::getBodyPosY()
{
	return m_nBodyPosY;
}

int CEnergyBody::getBodyType()
{
	return m_nBodyType;
}

double CEnergyBody::getBodyHp()
{
	return m_dBodyHp;
}

double CEnergyBody::getBodyMaxHp()
{
	return m_dInitBodyHp;
}

double CEnergyBody::getPlayerDamage()
{
	return m_dPlayerDamage;
}

double CEnergyBody::getEnemyDamage()
{
	return m_dEnemyDamage;
}

bool CEnergyBody::isEnergyJump()
{
	return m_isEnergyJump;
}

bool CEnergyBody::isEnergyChange()
{
	return m_isEnergyChange;
}

void CEnergyBody::lockEnergy()
{
	m_isEnergyLock = true;
}

void CEnergyBody::jumpEnergyBodyNow()
{
	m_dJumpTime = 0;
}

double CEnergyBody::addHpEnergyBodyBuff()
{
	double percentHp = 0.0;
	if (getWhoWin() == EnergyGetter::PLAYER_OWNER)
	{
		percentHp = (m_dPlayerDamage - m_dEnemyDamage) / m_dInitBodyHp;
	}
	else if (getWhoWin() == EnergyGetter::ENEMY_OWNER)
	{
		percentHp = (m_dEnemyDamage - m_dPlayerDamage) / m_dInitBodyHp;
	}
	else if (getWhoWin() == EnergyGetter::NONE_OWNER)
	{

	}
	if (percentHp > 0.2)
	{
		percentHp = 0.2;
	}
	return percentHp;
}

double CEnergyBody::addEnergyBuff()
{
	if (getWhoWin() == EnergyGetter::PLAYER_OWNER)
	{
		return (m_dPlayerDamage / m_dInitBodyHp) * 100;
	}
	else if (getWhoWin() == EnergyGetter::ENEMY_OWNER)
	{
		return (m_dEnemyDamage / m_dInitBodyHp) * 100;
	}
	else if (getWhoWin() == EnergyGetter::NONE_OWNER)
	{
		return 0;
	}
	return 0;
}

double CEnergyBody::addDamageToFort()
{
	if (getWhoWin() == EnergyGetter::PLAYER_OWNER)
	{
		return (m_dPlayerDamage / m_dInitBodyHp);
	}
	else if (getWhoWin() == EnergyGetter::ENEMY_OWNER)
	{
		return (m_dEnemyDamage / m_dInitBodyHp);
	}
	else if (getWhoWin() == EnergyGetter::NONE_OWNER)
	{
		return 0;
	}
	return 0;
}

int CEnergyBody::getWhoWin()
{
	if (m_dPlayerDamage > m_dEnemyDamage)
	{
		return EnergyGetter::PLAYER_OWNER;
	}
	else if (m_dPlayerDamage < m_dEnemyDamage)
	{
		return EnergyGetter::ENEMY_OWNER;
	}
	else
	{
		return EnergyGetter::NONE_OWNER;
	}
	return 0;
}

void CEnergyBody::splitStringToData(string data)
{
	int nEnergyIndex = 0;
	char *energyData;
	int len = data.length();
	energyData = (char *)malloc((len + 1) * sizeof(char));
	data.copy(energyData, len, 0);

	char *energyRoad;
	energyRoad = strtok(energyData, "#");
	while (energyRoad != NULL)
	{
		if (nEnergyIndex == m_nEnergyIndex)
		{
			break;
		}
		nEnergyIndex++;
		energyRoad = strtok(NULL, "#");
	}
	sscanf(energyRoad, "%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d", &m_nBodyType, &m_nRandPosY, &m_nJump1, &m_nChange1, &m_nJump2, &m_nChange2, &m_nJump3, &m_nChange3, &m_nJump4, &m_nChange4,
		&m_nJump5, &m_nChange5, &m_nJump6, &m_nChange6, &m_nChange7, &m_nChange8);
}

void CEnergyBody::resetPlayerDamage(double dDamage)
{
	m_dPlayerDamage = dDamage;
}

void CEnergyBody::resetEnemyDamage(double dDamage)
{
	m_dEnemyDamage = dDamage;
}

void CEnergyBody::resetBodyHp(double dHp)
{
	m_dBodyHp = dHp;
}
 
void CEnergyBody::resetJumpTime(double dTime)
{
	m_dJumpTime = dTime;
}

double CEnergyBody::getJumpTime()
{
	return m_dJumpTime;
}

void CEnergyBody::resetChangeTime(double dTime)
{
	m_dChangeTime = dTime;
}

double CEnergyBody::getChangeTime()
{
	return m_dChangeTime;
}

void CEnergyBody::resetBodyType(int nType)
{
	m_nBodyType = nType;
}

void CEnergyBody::resetBodyPosX(int nPosX)
{
	m_nBodyPosX = nPosX;
}

void CEnergyBody::resetBodyPosY(int nPosY)
{
	m_nBodyPosY = nPosY;
}

void CEnergyBody::setIsEnergyJump(int n)
{
	if (n == 0)
	{
		m_isEnergyJump = false;
	}
	else if (n == 1)
	{
		m_isEnergyJump = true;
	}
}

void CEnergyBody::setIsEnergyChange(int n)
{
	if (n == 0)
	{
		m_isEnergyChange = false;
	}
	else if (n == 1)
	{
		m_isEnergyChange = true;
	}
}

void CEnergyBody::resetInitBodyHp(double dInitHp)
{
	m_dInitBodyHp = dInitHp;
}

void CEnergyBody::setBodyChangeTimes(int nTimes)
{
	m_nChangeTimes = nTimes;
}

int CEnergyBody::getBodyChangeTimes()
{
	return m_nChangeTimes;
}

void CEnergyBody::setBodyJumpTimes(int nTimes)
{
	m_nJumpTimes = nTimes;
}

int CEnergyBody::getBodyJumpTimes()
{
	return m_nJumpTimes;
}

bool CEnergyBody::isEnergyLock()
{
	return m_isEnergyLock;
}

void CEnergyBody::setEnergyLock(int isLock)
{
	if (isLock == 0)
	{
		m_isEnergyLock = false;
	}
	else
	{
		m_isEnergyLock = true;
	}
}
