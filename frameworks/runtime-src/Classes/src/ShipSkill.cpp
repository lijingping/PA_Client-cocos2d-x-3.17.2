#include "ShipSkill.h"
#include "Battle.h"


CShipSkill::CShipSkill(bool isEnemy, int shipSkillID, CBattle *pBattle)
{
	m_isEnemy = isEnemy;
	m_nShipSkillID = shipSkillID;
	m_pShipSkillBattle = pBattle;
	m_dFireTime = 0.0;
	m_dTime = 0.0;
	m_isUpdate = false;
}

CShipSkill::~CShipSkill()
{

}

void CShipSkill::update(double dt)
{
	if (m_isUpdate)
	{
		if ((m_dTime - dt < 0.00001) && (m_dTime - dt > -0.00001))
		{
			m_dTime = dt;
		}
		m_dTime += dt;
		if (m_dTime > m_dFireTime)
		{
			shipSkillFire();
			m_dTime = 0.0;
			m_isUpdate = false;
		}
	}
}

void CShipSkill::setSkillData(double buffValue, double buffTime, double fireTime)
{
	m_dBuffValue = buffValue * 0.01;
	m_dBuffTime = buffTime;
	m_dFireTime = fireTime;
}

void CShipSkill::shipSkillFire()
{
	if (m_nShipSkillID == 70001)
	{
		ship1_fireSkill();
	}
	else if (m_nShipSkillID == 70002)
	{
		ship2_fireSkill();
	}
	else if (m_nShipSkillID == 70003)
	{
		ship3_fireSkill();
	}
	else if (m_nShipSkillID == 70004)
	{
		ship4_fireSkill();
	}
	else if (m_nShipSkillID == 70005)
	{
		ship5_fireSkill();
	}
	else if (m_nShipSkillID == 70006)
	{
		ship6_fireSkill();
	}
	else if (m_nShipSkillID == 70007)
	{
		ship7_fireSkill();
	}
	else if (m_nShipSkillID == 70008)
	{
		ship8_fireSkill();
	}
	else if (m_nShipSkillID == 70009)
	{
		ship9_fireSkill();
	}
	else if (m_nShipSkillID == 70010)
	{
		ship10_fireSkill();
	}
}

double CShipSkill::getTotalAck(int nSide)
{
	double dAckCount = 0.0;
	if (nSide == 1)
	{
		map<int, CFort*> mapPlayerForts = m_pShipSkillBattle->getPlayer()->getShip()->getFortMgr()->getPlayerFort();
		map<int, CFort*>::iterator iter = mapPlayerForts.begin();
		for (; iter != mapPlayerForts.end(); iter++)
		{
			dAckCount += (*iter).second->getInitDamage();
		}
	}
	else if (nSide == 2)
	{
		map<int, CFort*> mapEnemyForts = m_pShipSkillBattle->getEnemy()->getShip()->getFortMgr()->getEnemyFort();
		map<int, CFort*>::iterator iter = mapEnemyForts.begin();
		for (; iter != mapEnemyForts.end(); iter++)
		{
			dAckCount += (*iter).second->getInitDamage();
		}
	}
	return dAckCount;
}

void CShipSkill::startUpdate()
{
    if (m_dFireTime <= 0)
    {
        shipSkillFire();
    }
    else
    {
        m_isUpdate = true;
    }

}

// »´ÃÂª¡¶‘ˆ∑˘
void CShipSkill::ship1_fireSkill()
{
	if (m_isEnemy)  // µ–∑Ωµƒ’ΩΩ¢ººƒ‹
	{
		map<int, CFort*> mapEnemyForts = m_pShipSkillBattle->getEnemy()->getShip()->getFortMgr()->getEnemyFort();
		map<int, CFort*>::iterator iter = mapEnemyForts.begin();
		for (; iter != mapEnemyForts.end(); iter++)
		{
			if ((*iter).second->isFortLive())
			{
				m_pShipSkillBattle->getEnemy()->getBuffMgr()->addBuff(Buff::FORT_ATK_ENHANCE, (*iter).second->getFortID(), m_dBuffValue, m_dBuffTime);
			}
		}
	}
	else
	{
		map<int, CFort*> mapPlayerForts = m_pShipSkillBattle->getPlayer()->getShip()->getFortMgr()->getPlayerFort();
		map<int, CFort*>::iterator iter = mapPlayerForts.begin();
		for (; iter != mapPlayerForts.end(); iter++)
		{
			if ((*iter).second->isFortLive())
			{
				m_pShipSkillBattle->getPlayer()->getBuffMgr()->addBuff(Buff::FORT_ATK_ENHANCE, (*iter).second->getFortID(), m_dBuffValue, m_dBuffTime);
			}
		}
	}
}
//ø™∆Ù»´ÃÂª§∂‹°æ√‚…À¬ +15%°ø£¨Œ™…˙√¸÷µ◊ÓµÕµƒ≈⁄Ã®Ω¯––≥÷–¯Œ¨–ﬁ°æ√ø0.5√Îª÷∏¥1%…˙√¸°ø£¨≥÷–¯5√Î
void CShipSkill::ship2_fireSkill()
{
	if (m_isEnemy)
	{
		map<int, CFort*> mapEnemyForts = m_pShipSkillBattle->getEnemy()->getShip()->getFortMgr()->getEnemyFort();
		map<int, CFort*>::iterator iter = mapEnemyForts.begin();
		for (; iter != mapEnemyForts.end(); iter++)
		{
			if ((*iter).second->isFortLive())
			{
				m_pShipSkillBattle->getEnemy()->getBuffMgr()->addBuff(Buff::FORT_SHIELD, (*iter).second->getFortID(), m_dBuffValue, m_dBuffTime);
			}
		}
		CFort* pFort = nullptr;
		map<int, CFort*>::iterator iter_chooseHp = mapEnemyForts.begin();
		for (; iter_chooseHp != mapEnemyForts.end(); iter_chooseHp++)
		{
			if ((*iter_chooseHp).second->isFortLive())
			{
				if (!pFort)
				{
					pFort = (*iter_chooseHp).second;
				}
				else
				{
					if (pFort->getFortHp() > (*iter_chooseHp).second->getFortHp())
					{
						pFort = (*iter_chooseHp).second;
					}
				}
			}
		}
		m_pShipSkillBattle->getEnemy()->getBuffMgr()->addBuff(Buff::FORT_REPAIRING, pFort->getFortID(), 0, m_dBuffTime);
	}
	else
	{
		map<int, CFort*> mapPlayerForts = m_pShipSkillBattle->getPlayer()->getShip()->getFortMgr()->getPlayerFort();
		map<int, CFort*>::iterator iter = mapPlayerForts.begin();
		for(; iter != mapPlayerForts.end(); iter++)
		{
			if ((*iter).second->isFortLive())
			{
				m_pShipSkillBattle->getPlayer()->getBuffMgr()->addBuff(Buff::FORT_SHIELD, (*iter).second->getFortID(), m_dBuffValue, m_dBuffTime);
			}
		}
		CFort* pFort = nullptr;
		map<int, CFort*>::iterator iter_chooseHp = mapPlayerForts.begin();
		for (; iter_chooseHp != mapPlayerForts.end(); iter_chooseHp++)
		{
			if ((*iter_chooseHp).second->isFortLive())
			{
				if (!pFort)
				{
					pFort = (*iter_chooseHp).second;
				}
				else
				{
					if (pFort->getFortHp() > (*iter_chooseHp).second->getFortHp())
					{
						pFort = (*iter_chooseHp).second;
					}
				}
			}
		}
		m_pShipSkillBattle->getPlayer()->getBuffMgr()->addBuff(Buff::FORT_REPAIRING, pFort->getFortID(), 0, m_dBuffTime);
	}
}

//π•ª˜µ–∑Ω»´ÃÂ£¨‘Ï≥…100%µƒ…À∫¶£¨»Ùµ–∑Ω¥¶”⁄“Ï≥£◊¥Ã¨‘Ú∂ÓÕ‚‘ˆº”50%…À∫¶
void CShipSkill::ship3_fireSkill()
{
	if (m_isEnemy)
	{
		double enemyAck = getTotalAck(2);
		map<int, CFort*> mapPlayerForts = m_pShipSkillBattle->getPlayer()->getShip()->getFortMgr()->getPlayerFort();
		map<int, CFort*>::iterator iter = mapPlayerForts.begin();
		for (; iter != mapPlayerForts.end(); iter++)
		{
			if ((*iter).second->isFortLive())
			{
				if ((*iter).second->isAckDownState() || (*iter).second->isParalysisState() ||
					(*iter).second->isBurningState() || (*iter).second->isUnEnergyState() ||
					(*iter).second->isUnrepaireState() || (*iter).second->isBreakArmorState())
				{
					(*iter).second->damageFortByShipSkill(enemyAck * (m_dBuffValue + 0.5) * ( 1 - (*iter).second->getUnInjuryCoe()));
				}
				else
				{
					(*iter).second->damageFortByShipSkill(enemyAck * m_dBuffValue * (1 - (*iter).second->getUnInjuryCoe()));
				}
			}
		}
	}
	else
	{
		double playerAck = getTotalAck(1);
		if (m_pShipSkillBattle->getBattleType() == BattleType::BATTLE_NORMAL)
		{
			map<int, CFort*> mapEnemyForts = m_pShipSkillBattle->getEnemy()->getShip()->getFortMgr()->getEnemyFort();
			map<int, CFort*>::iterator iter = mapEnemyForts.begin();
			for (; iter != mapEnemyForts.end(); iter++)
			{
				if ((*iter).second->isFortLive())
				{
					if ((*iter).second->isAckDownState() || (*iter).second->isParalysisState() ||
						(*iter).second->isBurningState() || (*iter).second->isUnEnergyState() ||
						(*iter).second->isUnrepaireState() || (*iter).second->isBreakArmorState())
					{
						(*iter).second->damageFortByShipSkill(playerAck * (m_dBuffValue + 0.5) * (1 - (*iter).second->getUnInjuryCoe()));
					}
					else
					{
						(*iter).second->damageFortByShipSkill(playerAck * m_dBuffValue * (1 - (*iter).second->getUnInjuryCoe()));
					}
				}
			}
		}
		else if (m_pShipSkillBattle->getBattleType() == BattleType::BATTLE_BOSS)
		{
			m_pShipSkillBattle->getBoss()->bossBeDamageByShipSkill(playerAck * m_dBuffValue);
		}
	}
}
//¡¢º¥«Â≥˝Œ“∑ΩÀ˘”–ºı“Ê◊¥Ã¨£¨≤¢ª÷∏¥≈⁄Ã®10%…˙√¸÷µ”Î10%ƒ‹¡ø°£
void CShipSkill::ship4_fireSkill()
{
	if (m_isEnemy)
	{
		m_pShipSkillBattle->getEnemy()->getShip()->getFortMgr()->cleanBadBuff();
		map<int, CFort*> mapEnemyForts = m_pShipSkillBattle->getEnemy()->getShip()->getFortMgr()->getEnemyFort();
		map<int, CFort*>::iterator iter = mapEnemyForts.begin();
		for (; iter != mapEnemyForts.end(); iter++)
		{
			if ((*iter).second->isFortLive())
			{
				(*iter).second->addHpByShipSkill(m_dBuffValue);
				(*iter).second->addEnergyByShipSkill(m_dBuffValue);
			}
		}
	}
	else
	{
		m_pShipSkillBattle->getPlayer()->getShip()->getFortMgr()->cleanBadBuff();
		map<int, CFort*> mapPlayerForts = m_pShipSkillBattle->getPlayer()->getShip()->getFortMgr()->getPlayerFort();
		map<int, CFort*>::iterator iter = mapPlayerForts.begin();
		for (; iter != mapPlayerForts.end(); iter++)
		{
			if ((*iter).second->isFortLive())
			{
				(*iter).second->addHpByShipSkill(m_dBuffValue);
				(*iter).second->addEnergyByShipSkill(m_dBuffValue);
			}
		}
	}
}
//π•ª˜µ–∑Ω»´ÃÂ£¨‘Ï≥…150%µƒ…À∫¶Õ¨ ±∏Ωº”∆∆º◊–ßπ˚°æ√‚…À¬ πÈ0°ø£¨≥÷–¯5√Î
void CShipSkill::ship5_fireSkill()
{
	if (m_isEnemy)
	{
		double enemyAck = getTotalAck(2);
		map<int, CFort*> mapPlayerForts = m_pShipSkillBattle->getPlayer()->getShip()->getFortMgr()->getPlayerFort();
		map<int, CFort*>::iterator iter = mapPlayerForts.begin();
		for (; iter != mapPlayerForts.end(); iter++)
		{
			if ((*iter).second->isFortLive())
			{
				(*iter).second->damageFortByShipSkill(enemyAck * m_dBuffValue * (1 - (*iter).second->getUnInjuryCoe()));
				m_pShipSkillBattle->getPlayer()->getBuffMgr()->addBuff(Debuff::FORT_BREAK_ARMOR, (*iter).second->getFortID(), 0, m_dBuffTime);
			}
		}
	}
	else
	{
		double playerAck = getTotalAck(1);
		if (m_pShipSkillBattle->getBattleType() == BattleType::BATTLE_NORMAL)
		{
			map<int, CFort*> mapEnemyForts = m_pShipSkillBattle->getEnemy()->getShip()->getFortMgr()->getEnemyFort();
			map<int, CFort*>::iterator iter = mapEnemyForts.begin();
			for (; iter != mapEnemyForts.end(); iter++)
			{
				if ((*iter).second->isFortLive())
				{
					(*iter).second->damageFortByShipSkill(playerAck * m_dBuffValue * (1 - (*iter).second->getUnInjuryCoe()));
					m_pShipSkillBattle->getEnemy()->getBuffMgr()->addBuff(Debuff::FORT_BREAK_ARMOR, (*iter).second->getFortID(), 0, m_dBuffTime);
				}
			}
		}
		else if (m_pShipSkillBattle->getBattleType() == BattleType::BATTLE_BOSS)
		{
			m_pShipSkillBattle->getBoss()->bossBeDamageByShipSkill(playerAck * m_dBuffValue);
		}
	}
}
//π•ª˜µ–∑Ω»´ÃÂ£¨‘Ï≥…150%µƒ…À∫¶Õ¨ ±∏Ωº”Œ¨–ﬁ∏…»≈°æŒﬁ∑®ª÷∏¥…˙√¸÷µ°ø£¨≥÷–¯5√Î£¨»Ùƒø±Í¥¶”⁄»º…’◊¥Ã¨£¨‘Ú»º…’◊¥Ã¨≥÷–¯ ±º‰‘ˆº”5√Î
void CShipSkill::ship6_fireSkill()
{
	if (m_isEnemy)
	{
		double enemyAck = getTotalAck(2);
		map<int, CFort*> mapPlayerForts = m_pShipSkillBattle->getPlayer()->getShip()->getFortMgr()->getPlayerFort();
		map<int, CFort*>::iterator iter = mapPlayerForts.begin();
		for (; iter != mapPlayerForts.end(); iter++)
		{
			if ((*iter).second->isFortLive())
			{
				(*iter).second->damageFortByShipSkill(enemyAck * m_dBuffValue * (1 - (*iter).second->getUnInjuryCoe()));
				m_pShipSkillBattle->getPlayer()->getBuffMgr()->addBuff(Debuff::FORT_REPAIR_DISTURB, (*iter).second->getFortID(), 0, m_dBuffTime);
				if ((*iter).second->isBurningState())
				{
					m_pShipSkillBattle->getPlayer()->getBuffMgr()->addBuffTime(Debuff::FORT_BURNING, (*iter).second->getFortID(), 5);
				}
			}
		}
	}
	else
	{
		double playerAck = getTotalAck(1);
		if (m_pShipSkillBattle->getBattleType() == BattleType::BATTLE_NORMAL)
		{
			map<int, CFort*> mapEnemyForts = m_pShipSkillBattle->getEnemy()->getShip()->getFortMgr()->getEnemyFort();
			map<int, CFort*>::iterator iter = mapEnemyForts.begin();
			for (; iter != mapEnemyForts.end(); iter++)
			{
				if ((*iter).second->isFortLive())
				{
					(*iter).second->damageFortByShipSkill(playerAck * m_dBuffValue * (1 - (*iter).second->getUnInjuryCoe()));
					m_pShipSkillBattle->getEnemy()->getBuffMgr()->addBuff(Debuff::FORT_REPAIR_DISTURB, (*iter).second->getFortID(), 0, m_dBuffTime);
					if ((*iter).second->isBurningState())
					{
						m_pShipSkillBattle->getEnemy()->getBuffMgr()->addBuffTime(Debuff::FORT_BURNING, (*iter).second->getFortID(), 5);
					}
				}
			}
		}
		else if (m_pShipSkillBattle->getBattleType() == BattleType::BATTLE_BOSS)
		{
			m_pShipSkillBattle->getBoss()->bossBeDamageByShipSkill(playerAck * m_dBuffValue);
		}
	}
}
//¡¢º¥«Â≥˝µ–∑Ω‘ˆ“Ê–ßπ˚£¨≤¢∏Ωº”Ã±ªæ◊¥Ã¨£¨≥÷–¯5√Î
void CShipSkill::ship7_fireSkill()
{
	if (m_isEnemy)
	{
		m_pShipSkillBattle->getPlayer()->getShip()->getFortMgr()->cleanBetterBuff();
		map<int, CFort*> mapPlayerForts = m_pShipSkillBattle->getPlayer()->getShip()->getFortMgr()->getPlayerFort();
		map<int, CFort*>::iterator iter = mapPlayerForts.begin();
		for (; iter != mapPlayerForts.end(); iter++)
		{
			if ((*iter).second->isFortLive())
			{
				m_pShipSkillBattle->getPlayer()->getBuffMgr()->addBuff(Debuff::FORT_PARALYSIS, (*iter).second->getFortID(), 0, m_dBuffTime);
			}
		}
	}
	else
	{
		if (m_pShipSkillBattle->getBattleType() == BattleType::BATTLE_NORMAL)
		{
			m_pShipSkillBattle->getEnemy()->getShip()->getFortMgr()->cleanBetterBuff();
			map<int, CFort*> mapEnemyForts = m_pShipSkillBattle->getEnemy()->getShip()->getFortMgr()->getEnemyFort();
			map<int, CFort*>::iterator iter = mapEnemyForts.begin();
			for (; iter != mapEnemyForts.end(); iter++)
			{
				if ((*iter).second->isFortLive())
				{
					m_pShipSkillBattle->getEnemy()->getBuffMgr()->addBuff(Debuff::FORT_PARALYSIS, (*iter).second->getFortID(), 0, m_dBuffTime);
				}
			}
		}
		else if (m_pShipSkillBattle->getBattleType() == BattleType::BATTLE_BOSS)
		{

		}
	}
}
//ø™∆ÙŒﬁµ–ª§∂‹£®√‚…À¬ 100%£©£¨‘⁄ª§∂‹¥Ê‘⁄ ±≥÷–¯Œ¨–ﬁ≈⁄Ã®°æ√ø0.5√Îª÷∏¥1%…˙√¸°ø£¨◊¥Ã¨≥÷–¯5√Î°£
void CShipSkill::ship8_fireSkill()
{
	if (m_isEnemy)
	{
		map<int, CFort*> mapEnemyForts = m_pShipSkillBattle->getEnemy()->getShip()->getFortMgr()->getEnemyFort();
		map<int, CFort*>::iterator iter = mapEnemyForts.begin();
		for (; iter != mapEnemyForts.end(); iter++)
		{
			if ((*iter).second->isFortLive())
			{
				m_pShipSkillBattle->getEnemy()->getBuffMgr()->addBuff(Buff::FORT_SHIELD, (*iter).second->getFortID(), 1, m_dBuffTime);
				m_pShipSkillBattle->getEnemy()->getBuffMgr()->addBuff(Buff::FORT_REPAIRING, (*iter).second->getFortID(), 0, m_dBuffTime);
			}
		}
	}
	else
	{
		map<int, CFort*> mapPlayerForts = m_pShipSkillBattle->getPlayer()->getShip()->getFortMgr()->getPlayerFort();
		map<int, CFort*>::iterator iter = mapPlayerForts.begin();
		for (; iter != mapPlayerForts.end(); iter++)
		{
			if ((*iter).second->isFortLive())
			{
				m_pShipSkillBattle->getPlayer()->getBuffMgr()->addBuff(Buff::FORT_SHIELD, (*iter).second->getFortID(), 1, m_dBuffTime);
				m_pShipSkillBattle->getPlayer()->getBuffMgr()->addBuff(Buff::FORT_REPAIRING, (*iter).second->getFortID(), 0, m_dBuffTime);
			}
		}
	}
}
//π•ª˜µ–∑Ω»´ÃÂ£¨‘Ï≥…150%…À∫¶£¨Œ“∑Ω√øÀªŸ“ª◊˘≈⁄Ã®∂ÓÕ‚‘ˆº”50%…À∫¶
void CShipSkill::ship9_fireSkill()
{
	map<int, CFort*> mapEnemyForts;
	if (m_pShipSkillBattle->getBattleType() == BattleType::BATTLE_NORMAL)
	{
		mapEnemyForts = m_pShipSkillBattle->getEnemy()->getShip()->getFortMgr()->getEnemyFort();
	}

	map<int, CFort*> mapPlayerForts = m_pShipSkillBattle->getPlayer()->getShip()->getFortMgr()->getPlayerFort();
	if (m_isEnemy)
	{
		double enemyAck = getTotalAck(2);
		int countDieFort = 0;
		map<int, CFort*>::iterator enemyIter = mapEnemyForts.begin();
		for (; enemyIter != mapEnemyForts.end(); enemyIter++)
		{
			if (!(*enemyIter).second->isFortLive())
			{
				countDieFort += 1;
			}
		}
		map<int, CFort*>::iterator playerIter = mapPlayerForts.begin();
		for (; playerIter != mapPlayerForts.end(); playerIter++)
		{
			if ((*playerIter).second->isFortLive())
			{
				(*playerIter).second->damageFortByShipSkill(enemyAck * ( m_dBuffValue + (countDieFort * 0.5) ) * (1 - (*playerIter).second->getUnInjuryCoe()));
			}
		}
	}
	else
	{
		double playerAck = getTotalAck(1);
		int countDieFort = 0;
		map<int, CFort*>::iterator playerIter = mapPlayerForts.begin();
		for (; playerIter != mapPlayerForts.end(); playerIter++)
		{
			if (!(*playerIter).second->isFortLive())
			{
				countDieFort += 1;
			}
		}
		if (m_pShipSkillBattle->getBattleType() == BattleType::BATTLE_NORMAL)
		{
			map<int, CFort*>::iterator enemyIter = mapEnemyForts.begin();
			for (; enemyIter != mapEnemyForts.end(); enemyIter++)
			{
				if ((*enemyIter).second->isFortLive())
				{
					(*enemyIter).second->damageFortByShipSkill(playerAck * (m_dBuffValue + (countDieFort * 0.5)) * (1 - (*enemyIter).second->getUnInjuryCoe()));
				}
			}
		}
		else if (m_pShipSkillBattle->getBattleType() == BattleType::BATTLE_BOSS)
		{
			m_pShipSkillBattle->getBoss()->bossBeDamageByShipSkill(playerAck * (m_dBuffValue + (countDieFort * 0.5)));
		}
	}
}
//¡¢º¥–ﬁ∏¥“ª◊˘“—ÀªŸµƒ≈⁄Ã®£®»ÙÕ¨ ±”–∂‡◊˘≈⁄Ã®ÀªŸ‘Ú–ﬁ∏¥◊Ó∫ÛÀªŸµƒ≈⁄Ã®£©£¨–ﬁ∏¥µƒ≈⁄Ã®ª÷∏¥20%…˙√¸÷µ≤¢≥‰¬˙ƒ‹¡ø
void CShipSkill::ship10_fireSkill()
{
	int arrFortID[5];
	int countFort = 0;
	if (m_isEnemy)
	{
		int fortID = m_pShipSkillBattle->getEnemy()->getShip()->getFortMgr()->getDieEnemyFortID();
		map<int, CFort*> mapEnemyForts = m_pShipSkillBattle->getEnemy()->getShip()->getFortMgr()->getEnemyFort();
		map<int, CFort*>::iterator iter = mapEnemyForts.begin();
		for (; iter != mapEnemyForts.end(); iter++)
		{
			if (!(*iter).second->isFortLive())
			{
				arrFortID[countFort] = (*iter).second->getFortID();
				countFort += 1;
			}
		}
		if (countFort == 0)
		{
			return;
		}
		else if (countFort == 1)
		{
			m_pShipSkillBattle->getEnemy()->getShip()->getFortMgr()->getFortByID(arrFortID[0], true)->fortBeLiveByShipSkill(m_dBuffValue);
		}
		else if (countFort == 2)
		{
			m_pShipSkillBattle->getEnemy()->getShip()->getFortMgr()->getFortByID(fortID, true)->fortBeLiveByShipSkill(m_dBuffValue);
		}
	}
	else
	{
		int fortID = m_pShipSkillBattle->getPlayer()->getShip()->getFortMgr()->getDiePlayerFortID();
		map<int, CFort*> mapPlayerForts = m_pShipSkillBattle->getPlayer()->getShip()->getFortMgr()->getPlayerFort();
		map<int, CFort*>::iterator iter = mapPlayerForts.begin();
		for (; iter != mapPlayerForts.end(); iter++)
		{
			if (!(*iter).second->isFortLive())
			{
				arrFortID[countFort] = (*iter).second->getFortID();
				countFort += 1;
			}
		}
		if (countFort == 0)
		{
			return;
		}
		else if (countFort == 1)
		{
			m_pShipSkillBattle->getPlayer()->getShip()->getFortMgr()->getFortByID(arrFortID[0], false)->fortBeLiveByShipSkill(m_dBuffValue);
		}
		else if (countFort == 2)
		{
			m_pShipSkillBattle->getPlayer()->getShip()->getFortMgr()->getFortByID(fortID, false)->fortBeLiveByShipSkill(m_dBuffValue);
		}
	}
}
