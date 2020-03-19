#include "stdafx.h"
#include "Player.h"
#include "Battle.h"


CPlayer::CPlayer()
{
	m_nFortID_top = 0;
	m_nFortID_mid = 0;
	m_nFortID_bot = 0;
	m_dPlayerHp = 0.0;
	m_dMaxPlayerHp = 0.0;
	m_isUnmissileState = false;
	m_dNpcTime = NPC_OUT_TIME + NPC_ANIM_TIME;

	m_nPlayerShipEnergy = 0;
	m_dPlayerPreviousHp = 0.0;
	m_dPlayerNowHp = 0.0;
	m_dCountDamageHp = 0.0;
	m_isShipFireSkill = false;
	m_isNpcHere = false;
}


CPlayer::~CPlayer()
{
	//if (m_pInstance != nullptr)
	//{
	//	delete m_pInstance;
		//m_pInstance = nullptr;
	//}
	if (m_pPlayerShip)
	{
		delete(m_pPlayerShip);
		m_pPlayerShip = nullptr;
	}
	if (m_pBuffMgr)
	{
		delete(m_pBuffMgr);
		m_pBuffMgr = nullptr;
	}
	if (m_pBulletMgr)
	{
		delete(m_pBulletMgr);
		m_pBulletMgr = nullptr;
	}

}

//CPlayer* CPlayer::m_pInstance = nullptr;
//
//CPlayer* CPlayer::getInstance()
//{
//	if (!m_pInstance)
//	{
//		m_pInstance = new CPlayer();
//	}
//	return m_pInstance;
//}

void CPlayer::update(double dt)
{
	m_pPlayerShip->update(dt); 
	m_pBulletMgr->update(dt);
	m_pBuffMgr->update(dt);
	if (m_isNpcHere)
	{
		if ((m_dNpcTime - dt < 0.00001) && (m_dNpcTime - dt > -0.00001))
		{
			m_dNpcTime = dt;
		}
		m_dNpcTime -= dt;
		if (m_dNpcTime <= 0)
		{
			m_isNpcHere = false;
			m_dNpcTime = NPC_ANIM_TIME + NPC_OUT_TIME;
		}
	}
	countPlayerShipEnergy();
}

void CPlayer::initData(string wrongCodePath)
{
	//m_nFortID_top = fort1;
	//m_nFortID_mid = fort2;
	//m_nFortID_bot = fort3;
	createShip(wrongCodePath);
	addBulletMgr();
	addBuffMgr();

	//m_pBulletMgr->createBullet(5031, 2);// 测试用

}

void CPlayer::createShip(string wrongCodePath)
{
	m_pPlayerShip = new CShip();
	m_pPlayerShip->setShipBattle(m_pPlayerBattle);
	m_pPlayerShip->initData(CShip::ShipType::PLAYER_SHIP, wrongCodePath);
	//m_pPlayerShip->createFort(m_nFortID_top, m_nFortID_mid, m_nFortID_bot);
}

void CPlayer::addBulletMgr()
{
	m_pBulletMgr = new CBulletMgr();
	m_pBulletMgr->initData(false);
}

void CPlayer::addBuffMgr()
{
	m_pBuffMgr = new CBuffMgr(false);
	m_pBuffMgr->setBuffMgrBattle(m_pPlayerBattle);
}

void CPlayer::createBullet(CFort* fort)
{
	m_pBulletMgr->createBullet(fort->getFortBulletID(), fort->getFortIndex());
}

void CPlayer::addBuff(int buffID, int fortID)
{
	m_pBuffMgr->addBuff(buffID, fortID);
}

void CPlayer::addPlayerWholeBuff(int buffID)
{
	map<int, CFort*> mapPlayerFort = m_pPlayerShip->getFortMgr()->getPlayerFort();
	map<int, CFort*>::iterator iter = mapPlayerFort.begin();
	for (; iter != mapPlayerFort.end(); iter++)
	{
		m_pBuffMgr->addBuff(buffID, (*iter).second->getFortID());
	}
}

void CPlayer::countPlayerMaxHp(double dHp)
{
	m_dMaxPlayerHp += dHp;
}

double CPlayer::getPlayerHp()
{
	m_dPlayerHp = m_pPlayerShip->getFortMgr()->getPlayerTotalHp();
	return m_dPlayerHp;
}

CShip* CPlayer::getShip()
{
	return m_pPlayerShip;
}

CBulletMgr * CPlayer::getBulletMgr()
{
	return m_pBulletMgr;
}

CBuffMgr * CPlayer::getBuffMgr()
{
	return m_pBuffMgr;
}

void CPlayer::setPlayerBattle(CBattle * pBattle)
{
	m_pPlayerBattle = pBattle;
}

void CPlayer::unmissileState()
{
	m_isUnmissileState = true;
}

void CPlayer::recoveryUnmisslie()
{
	m_isUnmissileState = false;
}

bool CPlayer::isPlayerUnmissile()
{
	return m_isUnmissileState;
}

bool CPlayer::isHaveNpc()
{
	return m_isNpcHere;
}

void CPlayer::setNpcHereOrNot(bool isBool)
{
	m_isNpcHere = isBool;
}

void CPlayer::countPlayerShipEnergy()
{
	double onePercentHp = m_dMaxPlayerHp * 0.01;
	if (m_dPlayerPreviousHp == 0)
	{
		m_dPlayerPreviousHp = m_dMaxPlayerHp;
	}
	m_dPlayerNowHp = getPlayerHp();
	if (m_dPlayerNowHp <= 0)
	{
		return;
	}
	double dDamage = m_dPlayerPreviousHp - m_dPlayerNowHp;
	if (dDamage > 0)
	{
		m_dCountDamageHp += dDamage;
	}
	int onePercentTimes = m_dCountDamageHp / onePercentHp;
	if (onePercentTimes > 1)
	{
		m_dCountDamageHp -= onePercentTimes * onePercentHp;
		m_nPlayerShipEnergy += 2 * onePercentTimes;
		if (m_nPlayerShipEnergy > 100)
		{
			m_nPlayerShipEnergy = 100;
		}
	}
	m_dPlayerPreviousHp = m_dPlayerNowHp;
}

int CPlayer::useShipSkill()
{
	// addWrongCode 需添加战舰能量不足的错误代码
	//if (m_nPlayerShipEnergy < 100)
	//{
	//	return 2;
	//}
	//else
	//{
		m_nPlayerShipEnergy = 0;
		m_isShipFireSkill = true;
		m_pPlayerShip->useShipSkill();
		return 1;
	//}

}

int CPlayer::getPlayerShipEnergy()
{
	return m_nPlayerShipEnergy;
}

bool CPlayer::isPlayerShipFireSkill()
{
	return m_isShipFireSkill;
}

void CPlayer::setShipSkillFire(bool is)
{
	m_isShipFireSkill = is;
}

double CPlayer::getNpcTime()
{
	return m_dNpcTime;
}

void CPlayer::setNpcTime(double dTime)
{
	m_dNpcTime = dTime;
}

void CPlayer::setPlayerShipEnergy(int nEnergy)
{
	m_nPlayerShipEnergy = nEnergy;
}

double CPlayer::getPlayerPreviousHp()
{
	return m_dPlayerPreviousHp;
}

void CPlayer::setPlayerPreviousHp(double dHp)
{
	m_dPlayerPreviousHp = dHp;
}

double CPlayer::getPlayerNowHp()
{
	return m_dPlayerNowHp;
}

double CPlayer::getCountDamageHp()
{
	return m_dCountDamageHp;
}

void CPlayer::setCountDamageHp(double dDamage)
{
	m_dCountDamageHp = dDamage;
}

double CPlayer::getMaxPlayerHp()
{
	return m_dMaxPlayerHp;
}