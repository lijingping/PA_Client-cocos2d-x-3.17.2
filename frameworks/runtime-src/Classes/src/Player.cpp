#include "Player.h"
#include "Battle.h"


CPlayer::CPlayer()
{
}


CPlayer::CPlayer(int nPlayerSide)
{
	m_nPlayerSide = nPlayerSide;
	m_nPlayerEnergy = 0;
	m_nPlayerArmy = 0;
	m_dAddEnergyTime = 0;
}

CPlayer::~CPlayer()
{
	delete(m_pShip);
	m_pShip = nullptr;
	delete(m_pFortMgr);
	m_pFortMgr = nullptr;
	delete(m_pBulletMgr);
}

void CPlayer::init(int nShipID, int nShipLv)
{
	//createShip();
	createShip(nShipID, nShipLv);
	createFortMgr();
	createBulletMgr();
}

void CPlayer::createShip(int nShipID, int nShipLv)
{
	m_pShip = new CShip(m_nPlayerSide, nShipID, nShipLv, m_pPlayerBattle);
}

void CPlayer::createFortMgr()
{
	m_pFortMgr = new CFortMgr(m_nPlayerSide, m_pPlayerBattle);
}

void CPlayer::createBulletMgr()
{
	m_pBulletMgr = new CBulletMgr(m_nPlayerSide, m_pPlayerBattle);
}

void CPlayer::setBattlePoint(CBattle * pBattle)
{
	m_pPlayerBattle = pBattle;
}

void CPlayer::update(double dTime)
{
	m_dTotalBattleTime = m_dTotalBattleTime + dTime;
	autoAddEnergy(dTime);

	m_pShip->update(dTime);
	m_pFortMgr->update(dTime);
	m_pBulletMgr->update(dTime);
	//m_pPlayerBattle->getPlayerSelfForts();
}

void CPlayer::autoAddEnergy(double dTime)
{
	if (m_nPlayerEnergy >= ENERGY_MAX)
	{
		return;
	}
	m_dAddEnergyTime = m_dAddEnergyTime + dTime;
	if (m_dAddEnergyTime >= 1)
	{
		if (BATTLE_TIME - m_pPlayerBattle->getBattleTime() < ENERGY_QUICK_TIME)// 2倍能量增长
		{
			m_nPlayerEnergy = m_nPlayerEnergy + ENERGY_COUR_SPEED * 2;
		}
		else
		{
			m_nPlayerEnergy = m_nPlayerEnergy + ENERGY_COUR_SPEED;
		}
		m_dAddEnergyTime--;
		if (m_nPlayerEnergy >= ENERGY_MAX)
		{
			m_nPlayerEnergy = ENERGY_MAX;
		}
	}
}

void CPlayer::addEnergy(int nEnergy)
{
	if (m_nPlayerEnergy >= ENERGY_MAX)
	{
		return;
	}
	m_nPlayerEnergy = m_nPlayerEnergy + nEnergy;
	if (m_nPlayerEnergy >= ENERGY_MAX)
	{
		m_nPlayerEnergy = ENERGY_MAX;
	}
}

void CPlayer::addEnergyOnePoint()
{
	m_nPlayerEnergy++;
}

// 判断战力空间是否充足
bool CPlayer::isArmySpaceEnough(int nArmy)
{
	if (m_nPlayerArmy + nArmy <= MAX_ARMY_FORCE)
	{
		return true;
	}
	return false;
}

void CPlayer::addArmy(int nArmy)
{
	m_nPlayerArmy += nArmy;
}

void CPlayer::armyCountDown(int nArmy)
{
	m_nPlayerArmy -= nArmy;
}

CShip * CPlayer::getShip()
{
	return m_pShip;
}

CFortMgr * CPlayer::getFortMgr()
{
	return m_pFortMgr;
}

CBulletMgr * CPlayer::getBulletMgr()
{
	return m_pBulletMgr;
}
