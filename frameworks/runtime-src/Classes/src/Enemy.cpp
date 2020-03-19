#include "stdafx.h"
#include "Enemy.h"
#include "Battle.h"

CEnemy::CEnemy()
{
	m_nFortID_top = 0;
	m_nFortID_mid = 0;
	m_nFortID_bot = 0;
	m_dEnemyHp = 0.0;
	m_dEnemyMaxHp = 0.0;
	m_isUnmissileState = false;
	m_dNpcTime = NPC_OUT_TIME + NPC_ANIM_TIME;

	m_nEnemyShipEnergy = 0;
	m_dEnemyPreviousHp = 0.0;
	m_dEnemyNowHp = 0.0;
	m_dCountDamageHp = 0.0;
	m_isShipFireSkill = false;
	m_isNpcHere = false;
}

CEnemy::~CEnemy()
{
	//if (m_pInstance)
	//{
	//	delete(m_pInstance);
		//m_pInstance = nullptr;
	//}
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
	if (m_pEnemyShip)
	{
		delete(m_pEnemyShip);
		m_pEnemyShip = nullptr;
	}
}


void CEnemy::update(double dt) // 执行分顺序
{
	m_pEnemyShip->update(dt);
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
	countEnemyShipEnergy();
}

void CEnemy::initData(string wrongCodePath)
{
	//m_nFortID_top = fort1;
	//m_nFortID_mid = fort2;
	//m_nFortID_bot = fort3;
	createShip(wrongCodePath);
	addBulletMgr();
	addBuffMgr();

	//m_pBulletMgr->createBullet(5101, 1);  // 测试用
	//m_pBulletMgr->deleteBulletByIndex(0);
}

void CEnemy::createShip(string wrongCodePath)
{
	m_pEnemyShip = new CShip();
	m_pEnemyShip->setShipBattle(m_pEnemyBattle);
	m_pEnemyShip->initData(CShip::ShipType::ENEMY_SHIP, wrongCodePath);

}

void CEnemy::addBulletMgr()
{
	m_pBulletMgr = new CBulletMgr();
	m_pBulletMgr->initData(true);
}

void CEnemy::addBuffMgr() 
{
	m_pBuffMgr = new CBuffMgr(true);
	m_pBuffMgr->setBuffMgrBattle(m_pEnemyBattle);
}

void CEnemy::addBuff(int buffID, int fortID)
{
	m_pBuffMgr->addBuff(buffID, fortID);
}

void CEnemy::addEnemyWholeBuff(int buffID)
{
	map<int, CFort*> mapEnemyFort = m_pEnemyShip->getFortMgr()->getEnemyFort();
	map<int, CFort*>::iterator iter = mapEnemyFort.begin();
	for (; iter != mapEnemyFort.end(); iter++)
	{
		m_pBuffMgr->addBuff(buffID, (*iter).second->getFortID());
	}
}

double CEnemy::getEnemyHp()
{
	m_dEnemyHp = m_pEnemyShip->getFortMgr()->getEnemyTotalHp();
	return m_dEnemyHp;
}

void CEnemy::countEnemyMaxHp(double dHp)
{
	m_dEnemyMaxHp += dHp;
}

//void CEnemy::setEnemyHp()
//{
//	m_dEnemyHp = m_pEnemyShip->getFortMgr()->getEnemyTotalHp();
//}

CShip * CEnemy::getShip()
{
	return m_pEnemyShip;
}

CBulletMgr * CEnemy::getBulletMgr()
{
	return m_pBulletMgr;
}

CBuffMgr * CEnemy::getBuffMgr()
{
	return m_pBuffMgr;
}

void CEnemy::setEnemyBattle(CBattle * pBattle)
{
	m_pEnemyBattle = pBattle;
}

void CEnemy::unmissileState()
{
	m_isUnmissileState = true;
}

void CEnemy::recoveryUnmissile()
{
	m_isUnmissileState = false;
}

bool CEnemy::isEnemyUnmissile()
{
	return m_isUnmissileState;
}

bool CEnemy::isHaveNpc()
{
	return m_isNpcHere;
}

void CEnemy::setNpcHereOrNot(bool isBool)
{
	m_isNpcHere = isBool;
}

void CEnemy::countEnemyShipEnergy()
{
	double onePercentHp = m_dEnemyMaxHp * 0.01;
	if (m_dEnemyPreviousHp == 0)
	{
		m_dEnemyPreviousHp = m_dEnemyMaxHp;
	}
	m_dEnemyNowHp = getEnemyHp();
	if (m_dEnemyNowHp <= 0)
	{
		return;
	}
	double dDamage = m_dEnemyPreviousHp - m_dEnemyNowHp;
	if (dDamage > 0)
	{
		m_dCountDamageHp += dDamage;
	}
	int onePercentTimes = m_dCountDamageHp / onePercentHp;
	if (onePercentTimes > 1)
	{
		m_dCountDamageHp -= onePercentTimes * onePercentHp;
		m_nEnemyShipEnergy += 2 * onePercentTimes;
		if (m_nEnemyShipEnergy > 100)
		{
			m_nEnemyShipEnergy = 100;
		}
	}
	m_dEnemyPreviousHp = m_dEnemyNowHp;
}

int CEnemy::useShipSkill()
{
	// 需添加战舰能量不足的错误代码
	//if (m_nEnemyShipEnergy < 100)
	//{
	//	return 2;
	//}
	//else
	//{
		m_nEnemyShipEnergy = 0;
		m_isShipFireSkill = true;
		m_pEnemyShip->useShipSkill();
		return 1;
	//}
}

int CEnemy::getEnemyShipEnergy()
{
	return m_nEnemyShipEnergy;
}

bool CEnemy::isEnemyShipFireSkill()
{
	return m_isShipFireSkill;
}

void CEnemy::setShipSkillFire(bool is)
{
	m_isShipFireSkill = is;
}

double CEnemy::getNpcTime()
{
	return m_dNpcTime;
}

void CEnemy::setNpcTime(double dTime)
{
	m_dNpcTime = dTime;
}

void CEnemy::setEnemyShipEnergy(int nEnergy)
{
	m_nEnemyShipEnergy = nEnergy;
}

double CEnemy::getEnemyPreviousHp()
{
	return m_dEnemyPreviousHp;
}

void CEnemy::setEnemyPreviousHp(double dHp)
{
	m_dEnemyPreviousHp = dHp;
}

double CEnemy::getEnemyNowHp()
{
	return m_dEnemyNowHp;
}

double CEnemy::getCountDamageHp()
{
	return m_dCountDamageHp;
}

void CEnemy::setCountDamageHp(double dDamage)
{
	m_dCountDamageHp = dDamage;
}

void CEnemy::createBullet(CFort* fort)
{
	m_pBulletMgr->createBullet(fort->getFortBulletID(), fort->getFortIndex());
}

double CEnemy::getMaxEnemyHp()
{
	return m_dEnemyMaxHp;
}