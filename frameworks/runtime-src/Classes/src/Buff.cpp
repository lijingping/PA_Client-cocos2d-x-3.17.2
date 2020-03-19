#include "stdafx.h"
#include "Buff.h"
#include "Battle.h"

CBuff::CBuff(bool isEnemy, int fort)
	: m_dTime(0.0)
	, m_nBuffID(0)
	, m_nBuffIndex(0)
{	
	m_isEnemy = isEnemy;
	m_dBuffValue = 0.0;
	m_nFortID = fort; 

}


CBuff::~CBuff()
{

}

bool CBuff::createBuff(int buffID, double buffValue, double buffTime)
{
	m_nBuffID = buffID;
	m_dTime = buffTime;
	m_dBuffValue = buffValue;

	CFort* pFort = nullptr;
	if (m_nFortID != 0)
	{
		if (m_isEnemy)
		{
			pFort = m_pBuffBattle->getEnemy()->getShip()->getFortMgr()->getFortByID(m_nFortID, m_isEnemy);
		}
		else
		{
			pFort = m_pBuffBattle->getPlayer()->getShip()->getFortMgr()->getFortByID(m_nFortID, m_isEnemy);
		}
		if (!pFort->isFortLive())
		{
			return false;
		}
	}

	if (buffID == Buff::FORT_ATK_ENHANCE)          // 火力增幅
	{
		pFort->fortAckEnhanceState(buffValue);
	}
	else if (buffID == Buff::FORT_REPAIRING)       // 持续维修
	{
		if (pFort->isUnrepaireState())
		{
			return false;
		}
		pFort->fortRepairing();
	}
	else if (buffID == Buff::FORT_SHIELD)          // 护盾
	{
		if (pFort->isBreakArmorState())
		{
			return false;
		}
		pFort->fortShield(buffValue);
	}
	else if (buffID == Buff::FORT_PASSIVE_SKILL_STRONGER) // 被动技能增强
	{
		pFort->fortPassiveSkillStrongerState();
	}
	else if (buffID == Debuff::FORT_PARALYSIS)     // 瘫痪
	{
		pFort->fortParalysisState();
	}
	else if (buffID == Debuff::FORT_BURNING)       // 燃烧
	{
		pFort->fortBurningState();
	}
	else if (buffID == Debuff::FORT_ATK_DISTURB)    // 火力干扰
	{
		pFort->fortAckDisturbState(buffValue);
	}
	else if (buffID == Debuff::FORT_REPAIR_DISTURB) // 维修干扰 （无法回血，也无法使用道具回血）
	{
		pFort->fortUnrepaire();	
	}
	else if (buffID == Debuff::FORT_ENERGY_DISTURB) // 能量干扰 （不能充能(使用技能，使用能量恢复道具)）
	{
		pFort->fortUnEnergy();
	}
	else if (buffID == Debuff::FORT_BREAK_ARMOR)   //破甲状态（与护盾叠加时护盾失效）
	{
		pFort->fortBreakArmorState();
	}
	else if (buffID == Debuff::PLAYER_UNMISSILE)  //反导弹
	{
		if (m_isEnemy)
		{
			m_pBuffBattle->getEnemy()->unmissileState();
		}
		else
		{
			m_pBuffBattle->getPlayer()->unmissileState();
		}
	}
	return true;
}

// 存在buff重设时间
void CBuff::resetBuffTime(double time)
{
	m_dTime = time;
}

void CBuff::resetBuffValue(double effectValue, double time)
{
	m_dBuffValue = effectValue;
	m_dTime = time;

	CFort* pFort = nullptr;
	if (m_nFortID != 0)
	{
		if (m_isEnemy)
		{
			pFort = m_pBuffBattle->getEnemy()->getShip()->getFortMgr()->getFortByID(m_nFortID, m_isEnemy);
		}
		else
		{
			pFort = m_pBuffBattle->getPlayer()->getShip()->getFortMgr()->getFortByID(m_nFortID, m_isEnemy);
		}
		if (!pFort->isFortLive())
		{
			return;
		}
	}

	if (m_nBuffID == Buff::FORT_ATK_ENHANCE)          // 火力增幅
	{
		pFort->fortAckEnhanceState(effectValue);
	}
	else if (m_nBuffID == Buff::FORT_REPAIRING)       // 持续维修
	{
		if (pFort->isUnrepaireState())
		{
			return;
		}
		pFort->fortRepairing();
	}
	else if (m_nBuffID == Buff::FORT_SHIELD)          // 护盾
	{
		if (pFort->isBreakArmorState())
		{
			return;
		}
		pFort->fortShield(effectValue);
	}
	else if (m_nBuffID == Buff::FORT_PASSIVE_SKILL_STRONGER) //被动增强
	{
		pFort->fortPassiveSkillStrongerState();
	}
	else if (m_nBuffID == Debuff::FORT_PARALYSIS)     // 瘫痪
	{
		pFort->fortParalysisState();
	}
	else if (m_nBuffID == Debuff::FORT_BURNING)       // 燃烧
	{
		pFort->fortBurningState();
	}
	else if (m_nBuffID == Debuff::FORT_ATK_DISTURB)    // 火力干扰
	{
		pFort->fortAckDisturbState(effectValue);
	}
	else if (m_nBuffID == Debuff::FORT_REPAIR_DISTURB) // 维修干扰 （无法回血，也无法使用道具回血）
	{
		pFort->fortUnrepaire();
	}
	else if (m_nBuffID == Debuff::FORT_ENERGY_DISTURB) // 能量干扰 （不能充能(使用技能，使用能量恢复道具)）
	{
		pFort->fortUnEnergy();
	}
	else if (m_nBuffID == Debuff::FORT_BREAK_ARMOR)   // 破甲
	{
		pFort->fortBreakArmorState();
	}
	else if (m_nBuffID == Debuff::PLAYER_UNMISSILE)
	{

	}
	resetBuffTime(time);
}

int CBuff::update(double dt)
{
	if ((m_dTime - dt < 0.00001) && (m_dTime - dt > -0.00001))
	{
		m_dTime = dt;
	}
	m_dTime -= dt;
	if (m_dTime <= 0)
	{
		return recoveryFortState();
	}
	return 0;
}

void CBuff::setBuffIndex(int buffIndex)
{
	m_nBuffIndex = buffIndex;
}

int CBuff::getBuffIndex()
{
	return m_nBuffIndex;
}

int CBuff::recoveryFortState()
{
	// 移除buff
	CFort* pFort = nullptr;
	CBuffMgr* pBuffMgr = nullptr;

	if (m_isEnemy)
	{
		pFort = m_pBuffBattle->getEnemy()->getShip()->getFortMgr()->getFortByID(m_nFortID, m_isEnemy);
		pBuffMgr = m_pBuffBattle->getEnemy()->getBuffMgr();
	}
	else
	{
		pFort = m_pBuffBattle->getPlayer()->getShip()->getFortMgr()->getFortByID(m_nFortID, m_isEnemy);
		pBuffMgr = m_pBuffBattle->getPlayer()->getBuffMgr();
	}
	if (m_nBuffID == Buff::FORT_ATK_ENHANCE)          // 火力增幅
	{
		pFort->recoveryAckUp();
		return 1;
	}
	else if (m_nBuffID == Buff::FORT_REPAIRING)       // 持续维修
	{
		pFort->recoveryRepairing();
		return 1;
	}
	else if (m_nBuffID == Buff::FORT_SHIELD)          // 护盾
	{
		pFort->recoveryShield();
		return 1;
	}
	else if (m_nBuffID == Buff::FORT_PASSIVE_SKILL_STRONGER) // 被动增强
	{
		pFort->recoveryFortPassiveSkillBuff();
		return 1;
	}
	else if (m_nBuffID == Debuff::FORT_PARALYSIS)     // 瘫痪
	{
		pFort->recoveryParalysis();
		return 1;
	}
	else if (m_nBuffID == Debuff::FORT_BURNING)       // 燃烧
	{
		pFort->recoveryBurning();
		return 1;
	}
	else if (m_nBuffID == Debuff::FORT_ATK_DISTURB)    // 火力干扰
	{
		pFort->recoveryAckDown();
		return 1;
	}
	else if (m_nBuffID == Debuff::FORT_REPAIR_DISTURB)      // 维修干扰
	{
		pFort->recoveryUnrepaire();
		return 1;
	}
	else if (m_nBuffID == Debuff::FORT_ENERGY_DISTURB)     // 能量干扰 （不能充能，使用技能，使用能量恢复道具）
	{
		pFort->recoveryUnEnergy();
		return 1;
	}
	else if (m_nBuffID == Debuff::FORT_BREAK_ARMOR)     // 破甲
	{
		pFort->recoveryFortBreakArmorBuff();
		return 1;
	}
	else if (m_nBuffID == Debuff::PLAYER_UNMISSILE)   //反导弹
	{
		if (m_isEnemy)
		{
			m_pBuffBattle->getEnemy()->recoveryUnmissile();
            return 1;
		}
		else
		{
			m_pBuffBattle->getPlayer()->recoveryUnmisslie();
            return 1;
		}
	}
	return 0;
	//pBuffMgr->deleteBuff(m_nBuffIndex);
}

int CBuff::getFortID()
{
	return m_nFortID;
}

int CBuff::getBuffID()
{
	return m_nBuffID;
}

void CBuff::setBuffBattle(CBattle * pBattle)
{
	m_pBuffBattle = pBattle;
}

void CBuff::addBuffTime(double dTime)
{
	m_dTime += dTime;
}

double CBuff::getBuffTime()
{
	return m_dTime;
}

double CBuff::getBuffValue()
{
	return m_dBuffValue;
}
