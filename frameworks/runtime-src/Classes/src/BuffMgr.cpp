#include "stdafx.h"
#include "BuffMgr.h"

#include "Battle.h"


CBuffMgr::CBuffMgr(bool isEnemy)
{
	m_isEnemy = isEnemy;
	m_nBuffIndex = 0;
}


CBuffMgr::~CBuffMgr()
{
	if (m_isEnemy)
	{
		cleanEnmeyBuffMap();
	}
	else
	{
		cleanPlayerBuffMap();
	}
	cleanBuffEventVec();
}

void CBuffMgr::update(double dt)
{
	if (m_isEnemy)
	{
		map<int, CBuff*>::iterator eIter = m_mapEnemyBuff.begin();
		for (; eIter != m_mapEnemyBuff.end();)
		{
			int nReturnNum = (*eIter).second->update(dt);
			if (nReturnNum == 1)      // return 1 为需要删除当前循环到的这个buff（恢复了炮台buff）
			{
				insertBuffEventToVec((*eIter).second->getFortID(), (*eIter).second->getBuffID() + 20);
				delete((*eIter).second);
				(*eIter).second = nullptr;
				m_mapEnemyBuff.erase(eIter++);
			}
			else
			{
				eIter++;
			}
		}
	}
	else
	{
		map<int, CBuff*>::iterator pIter = m_mapPlayerBuff.begin();
		for (; pIter != m_mapPlayerBuff.end();)
		{
			int nReturnNum = (*pIter).second->update(dt);
			if (nReturnNum == 1)
			{
				insertBuffEventToVec((*pIter).second->getFortID(), (*pIter).second->getBuffID() + 20);
				delete((*pIter).second);
				(*pIter).second = nullptr;
				m_mapPlayerBuff.erase(pIter++);
			}
			else
			{
				pIter++;
			}
		}
	}
}

void CBuffMgr::addBuff(int buffID, int fort, double buffValue, double buffTime)
{

	if (m_isEnemy)
	{
		map<int, CBuff*>::iterator enemyIter = m_mapEnemyBuff.begin();
		for (; enemyIter != m_mapEnemyBuff.end(); enemyIter++)
		{
			if ((*enemyIter).second->getBuffID() == buffID)
			{
				if (buffID == Debuff::PLAYER_UNMISSILE || (*enemyIter).second->getFortID() == fort)// 炮台有同一个buff 或者 buff是反导弹buff
				{
					(*enemyIter).second->resetBuffValue(buffValue, buffTime); // 替换:重设时间和效果。
					return;
				}
			}
		}
		CBuff* pBuff = new CBuff(m_isEnemy, fort);
		pBuff->setBuffBattle(m_pBuffMgrBattle);
		if (pBuff->createBuff(buffID, buffValue, buffTime))
		{
			insertBuffEventToVec(fort, buffID);
			pBuff->setBuffIndex(m_nBuffIndex);
			m_mapEnemyBuff.insert(map<int, CBuff*>::value_type(m_nBuffIndex, pBuff));
			m_nBuffIndex++;
		}
		else
		{
			delete(pBuff);
			pBuff = nullptr;
		}
	}
	else
	{
		map<int, CBuff*>::iterator playerIter = m_mapPlayerBuff.begin();
		for (; playerIter != m_mapPlayerBuff.end(); playerIter++)
		{
			if ((*playerIter).second->getBuffID() == buffID)   // 炮台有同一个buff
			{
				if (buffID == Debuff::PLAYER_UNMISSILE || (*playerIter).second->getFortID() == fort)
				{
					(*playerIter).second->resetBuffValue(buffValue, buffTime);             // 替换掉时间，buff回到一开始的状态
					return;
				}
			}
		}
		CBuff* pBuff = new CBuff(m_isEnemy, fort);
		pBuff->setBuffBattle(m_pBuffMgrBattle);
		if (pBuff->createBuff(buffID, buffValue, buffTime))
		{
			insertBuffEventToVec(fort, buffID);
			pBuff->setBuffIndex(m_nBuffIndex);
			m_mapPlayerBuff.insert(map<int, CBuff*>::value_type(m_nBuffIndex, pBuff));
			m_nBuffIndex++;
		}
		else
		{
			delete(pBuff);
			pBuff = nullptr;
		}
	}
}

//void CBuffMgr::deleteBuff(int buffIndex)  // buff时间到了删除buff
//{
//	if (m_isEnemy)
//	{
//		map<int, CBuff*>::iterator eIter = m_mapEnemyBuff.begin();
//		for (; eIter != m_mapEnemyBuff.end(); eIter++)
//		{
//			if ((*eIter).second->getBuffIndex() == buffIndex)
//			{
//				delete((*eIter).second);
//				(*eIter).second = nullptr;
//				m_mapEnemyBuff.erase(eIter);
//				break;
//			}
//		}
//	}
//	else
//	{
//		map<int, CBuff*>::iterator pIter = m_mapPlayerBuff.begin();
//		for (; pIter != m_mapPlayerBuff.end(); pIter++)
//		{
//			if ((*pIter).second->getBuffIndex() == buffIndex)
//			{
//				delete((*pIter).second);
//				(*pIter).second = nullptr;
//				m_mapPlayerBuff.erase(pIter);
//				break;
//			}
//		}
//	}
//}

void CBuffMgr::deleteBuffByFortID(int fortID, int buffID)   // buff持续过程中，遇干扰时
{
	if (m_isEnemy)
	{
		map<int, CBuff*>::iterator enemyIter = m_mapEnemyBuff.begin();
		for (; enemyIter != m_mapEnemyBuff.end(); enemyIter++)
		{
			if ((*enemyIter).second->getFortID() == fortID && (*enemyIter).second->getBuffID() == buffID)
			{
				insertBuffEventToVec((*enemyIter).second->getFortID(), (*enemyIter).second->getBuffID() + 20);
				delete((*enemyIter).second);
				(*enemyIter).second = nullptr;
				m_mapEnemyBuff.erase(enemyIter);
				break;
			}
		}
	}
	else
	{
		map<int, CBuff*>::iterator playerIter = m_mapPlayerBuff.begin();
		for (; playerIter != m_mapPlayerBuff.end(); playerIter++)
		{
			if ((*playerIter).second->getFortID() == fortID && (*playerIter).second->getBuffID() == buffID)
			{
				insertBuffEventToVec((*playerIter).second->getFortID(), (*playerIter).second->getBuffID() + 20);
				delete((*playerIter).second);
				(*playerIter).second = nullptr;
				m_mapPlayerBuff.erase(playerIter);
				break;
			}
		}
	}
}

void CBuffMgr::deleteAllBuffByFortID(int nFortID)
{
	if (m_isEnemy)
	{
		map<int, CBuff*>::iterator iter = m_mapEnemyBuff.begin();
		map<int, CBuff*>::iterator iter_delete;
		for (; iter != m_mapEnemyBuff.end();)
		{
			if ((*iter).second->getFortID() == nFortID)
			{
				insertBuffEventToVec((*iter).second->getFortID(), (*iter).second->getBuffID() + 20);
				delete((*iter).second);
				(*iter).second = nullptr;
				iter_delete = iter;
				iter++;
				m_mapEnemyBuff.erase(iter_delete);
			}
			else
			{
				iter++;
			}
		}
	}
	else
	{
		map<int, CBuff*>::iterator iter = m_mapPlayerBuff.begin();
		map<int, CBuff*>::iterator iter_delete;
		for (; iter != m_mapPlayerBuff.end();)
		{
			if ((*iter).second->getFortID() == nFortID)
			{
				insertBuffEventToVec((*iter).second->getFortID(), (*iter).second->getBuffID() + 20);
				delete((*iter).second);
				(*iter).second = nullptr;
				iter_delete = iter;
				iter++;
				m_mapPlayerBuff.erase(iter_delete);
			}
			else
			{
				iter++;
			}
		}
	}
}
// 于析构函数里，推出战斗时调用，用来清空容器里的buff
void CBuffMgr::cleanPlayerBuffMap()
{
	map<int, CBuff*>::iterator iter = m_mapPlayerBuff.begin();
	for (; iter != m_mapPlayerBuff.end(); iter++)
	{
		delete (*iter).second;
		(*iter).second = nullptr;
	}
	m_mapPlayerBuff.clear();
}
// 于析构函数里，推出战斗时调用，用来清空容器里的buff
void CBuffMgr::cleanEnmeyBuffMap()
{
	map<int, CBuff*>::iterator iter = m_mapEnemyBuff.end();
	for (; iter != m_mapEnemyBuff.end(); iter++)
	{
		delete (*iter).second;
		(*iter).second = nullptr;
	}
	m_mapEnemyBuff.clear();
}

void CBuffMgr::deletePlayerBadBuff()
{
	map<int, CBuff*>::iterator pIter = m_mapPlayerBuff.begin();
	for (; pIter != m_mapPlayerBuff.end(); )
	{
		if ((*pIter).second->getBuffID() == Debuff::FORT_PARALYSIS || 
			(*pIter).second->getBuffID() == Debuff::FORT_BURNING ||
			(*pIter).second->getBuffID() == Debuff::FORT_ATK_DISTURB ||
			(*pIter).second->getBuffID() == Debuff::FORT_REPAIR_DISTURB ||
			(*pIter).second->getBuffID() == Debuff::FORT_ENERGY_DISTURB ||
			(*pIter).second->getBuffID() == Debuff::FORT_BREAK_ARMOR ||
			(*pIter).second->getBuffID() == Debuff::PLAYER_UNMISSILE)
		{
			insertBuffEventToVec((*pIter).second->getFortID(), (*pIter).second->getBuffID() + 20);
			(*pIter).second->recoveryFortState();
			delete((*pIter).second);
			(*pIter).second = nullptr;
			m_mapPlayerBuff.erase(pIter++);
		 }
		else
		{
			pIter++;
		}
	}
}

void CBuffMgr::deletePlayerGoodBuff()
{
	map<int, CBuff*>::iterator pIter = m_mapPlayerBuff.begin();
	for (; pIter != m_mapPlayerBuff.end(); )
	{
		if ((*pIter).second->getBuffID() == Buff::FORT_ATK_ENHANCE ||
			(*pIter).second->getBuffID() == Buff::FORT_REPAIRING ||
			(*pIter).second->getBuffID() == Buff::FORT_SHIELD ||
			(*pIter).second->getBuffID() == Buff::FORT_PASSIVE_SKILL_STRONGER) 
		{
			insertBuffEventToVec((*pIter).second->getFortID(), (*pIter).second->getBuffID() + 20);
			(*pIter).second->recoveryFortState();
			delete((*pIter).second);
			(*pIter).second = nullptr;
			m_mapPlayerBuff.erase(pIter++);
		}
		else
		{
			pIter++;
		}
	}
}

void CBuffMgr::deleteEnemyBadBuff()
{
	map<int, CBuff*>::iterator eIter = m_mapEnemyBuff.begin();
	for (; eIter != m_mapEnemyBuff.end(); )
	{
		if ((*eIter).second->getBuffID() == Debuff::FORT_PARALYSIS ||
			(*eIter).second->getBuffID() == Debuff::FORT_BURNING ||
			(*eIter).second->getBuffID() == Debuff::FORT_ATK_DISTURB ||
			(*eIter).second->getBuffID() == Debuff::FORT_REPAIR_DISTURB ||
			(*eIter).second->getBuffID() == Debuff::FORT_ENERGY_DISTURB ||
			(*eIter).second->getBuffID() == Debuff::FORT_BREAK_ARMOR || 
			(*eIter).second->getBuffID() == Debuff::PLAYER_UNMISSILE)
		{ 
			insertBuffEventToVec((*eIter).second->getFortID(), (*eIter).second->getBuffID() + 20);
			(*eIter).second->recoveryFortState();
			delete((*eIter).second);
			(*eIter).second = nullptr;
			m_mapEnemyBuff.erase(eIter++);
		}
		else
		{
			eIter++;
		}
	}
}

void CBuffMgr::deleteEnemyGoodBuff()
{
	map<int, CBuff*>::iterator eIter = m_mapEnemyBuff.begin();
	for (; eIter != m_mapEnemyBuff.end(); )
	{
		if ((*eIter).second->getBuffID() == Buff::FORT_ATK_ENHANCE ||
			(*eIter).second->getBuffID() == Buff::FORT_REPAIRING ||
			(*eIter).second->getBuffID() == Buff::FORT_SHIELD ||
			(*eIter).second->getBuffID() == Buff::FORT_PASSIVE_SKILL_STRONGER)
		{
			insertBuffEventToVec((*eIter).second->getFortID(), (*eIter).second->getBuffID() + 20);
			(*eIter).second->recoveryFortState();
			delete((*eIter).second);
			(*eIter).second = nullptr;
			m_mapEnemyBuff.erase(eIter++);
		}
		else
		{
			eIter++;
		}
	}
}

void CBuffMgr::setBuffMgrBattle(CBattle * pBattle)
{
	m_pBuffMgrBattle = pBattle;
}

void CBuffMgr::insertBuffEventToVec(int fort, int buffID)
{
	sBuffEvent buffEvent;
	buffEvent.nBuffFort = fort;
	buffEvent.nBuffID = buffID;
	if (m_isEnemy)
	{
		m_vecEnemyBuffEvent.insert(m_vecEnemyBuffEvent.end(), buffEvent);
	}
	else
	{
		m_vecPlayerBuffEvent.insert(m_vecPlayerBuffEvent.end(), buffEvent);
	}
	
}

void CBuffMgr::cleanBuffEventVec()
{
	if (m_isEnemy)
	{
		m_vecEnemyBuffEvent.clear();
	}
	else
	{
		m_vecPlayerBuffEvent.clear();
	}
}

vector<sBuffEvent> CBuffMgr::getPlayerBuffEvent()
{
	return m_vecPlayerBuffEvent;
}

vector<sBuffEvent> CBuffMgr::getEnemyBuffEvent()
{
	return m_vecEnemyBuffEvent;
}

void CBuffMgr::addBuffTime(int buffID, int fortID, double addTime)
{
	if (m_isEnemy)
	{
		map<int, CBuff*>::iterator iter = m_mapEnemyBuff.begin();
		for (; iter != m_mapEnemyBuff.end(); iter++)
		{
			if ((*iter).second->getBuffID() == buffID && (*iter).second->getFortID() == fortID)
			{
				(*iter).second->addBuffTime(addTime);
			}
		}
	}
	else
	{
		map<int, CBuff*>::iterator iter = m_mapPlayerBuff.begin();
		for (; iter != m_mapPlayerBuff.end(); iter++)
		{
			if ((*iter).second->getBuffID() == buffID && (*iter).second->getFortID() == fortID)
			{
				(*iter).second->addBuffTime(addTime);
			}
		}
	}
}

map<int, CBuff*> CBuffMgr::getPlayerBuffMap()
{
	return m_mapPlayerBuff;
}

map<int, CBuff*> CBuffMgr::getEnemyBuffMap()
{
	return m_mapEnemyBuff;
}

void CBuffMgr::setBuffIndex(int nBuffIndex)
{
	m_nBuffIndex = nBuffIndex;
}

