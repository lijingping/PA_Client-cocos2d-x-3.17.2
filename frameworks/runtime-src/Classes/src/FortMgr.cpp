#include "stdafx.h"
#include "FortMgr.h"


#include <stdio.h>
#include "Battle.h"

CFortsMgr::CFortsMgr(bool isEnemy, string wrongCodePath)
	: m_nMyTop_fortID(0)
	, m_nMyMid_fortID(0)
	, m_nMyBot_fortID(0)
	, m_nEnemyTop_fortID(0)
	, m_nEnemyMid_fortID(0)
	, m_nEnemyBot_fortID(0)
	, m_isPCleanBetBuff(false)
	, m_isPCleanBadBuff(false)
	, m_isECleanBetBuff(false)
	, m_isECleanBadBuff(false)
	, m_nRecentDiePlayerFort(0)
	, m_nRecentDieEnemyFort(0)

{
	m_isEnemy = isEnemy;
	m_strWrongCodePath = wrongCodePath;
}

CFortsMgr::~CFortsMgr()
{
	if (m_isEnemy)
	{
		map<int, CFort*>::iterator iter = m_mapEnemyForts.begin();
		for (; iter != m_mapEnemyForts.end(); )
		{
			delete((*iter).second);
			(*iter).second = nullptr;
			m_mapEnemyForts.erase(iter++);
		}
	}
	else
	{
		map<int, CFort*>::iterator pIter = m_mapMyForts.begin();
		for (; pIter != m_mapMyForts.end(); )
		{
			delete((*pIter).second);
			(*pIter).second = nullptr;
			m_mapMyForts.erase(pIter++);
		}
	}
}


void CFortsMgr::createForts()  //int fort1, int fort2, int fort3, bool isEnemy
{
	//m_nFortID_top = fort1;
	//m_nFortID_mid = fort2;
	//m_nFortID_bot = fort3;
	//m_isEnemy = isEnemy;
	//CFort *pFortTop = new CFort();
	//pFortTop->createFort(fort1, m_isEnemy, 0);
	//CFort *pFortMid = new CFort();
	//pFortMid->createFort(fort2, m_isEnemy, 1);
	//CFort *pFortBot = new CFort();
	//pFortBot->createFort(fort3, m_isEnemy, 2);

	CFort *pFortTop = new CFort(m_isEnemy, 0, m_strWrongCodePath);
	CFort *pFortMid = new CFort(m_isEnemy, 1, m_strWrongCodePath);
	CFort *pFortBot = new CFort(m_isEnemy, 2, m_strWrongCodePath);
	pFortTop->setFortBattle(m_pFortMgrBattle);
	pFortMid->setFortBattle(m_pFortMgrBattle);
	pFortBot->setFortBattle(m_pFortMgrBattle);

	if (m_isEnemy)
	{
		pFortTop->setFortPos(ENEMYFORT_POS_X, FORT_TOP_POS_Y);
		pFortMid->setFortPos(ENEMYFORT_POS_X, FORT_MID_POS_Y);
		pFortBot->setFortPos(ENEMYFORT_POS_X, FORT_BOT_POS_Y);
		m_mapEnemyForts.insert(map<int, CFort*>::value_type(0, pFortTop));
		m_mapEnemyForts.insert(map<int, CFort*>::value_type(1, pFortMid));
		m_mapEnemyForts.insert(map<int, CFort*>::value_type(2, pFortBot));
	}
	else
	{
		pFortTop->setFortPos(MYFORT_POS_X, FORT_TOP_POS_Y);
		pFortMid->setFortPos(MYFORT_POS_X, FORT_MID_POS_Y);
		pFortBot->setFortPos(MYFORT_POS_X, FORT_BOT_POS_Y);
		m_mapMyForts.insert(map<int, CFort*>::value_type(0, pFortTop));
		m_mapMyForts.insert(map<int, CFort*>::value_type(1, pFortMid));
		m_mapMyForts.insert(map<int, CFort*>::value_type(2, pFortBot));
	}
}

void CFortsMgr::removeBrokenFort(int fortID)
{
	if(m_isEnemy)
	{
		map<int, CFort*>::iterator iter = m_mapEnemyForts.begin();
		for (; iter != m_mapEnemyForts.end(); iter++)
		{
			if ((*iter).second->getFortID() == fortID)
			{
				delete((*iter).second);
				(*iter).second = nullptr;
				m_mapEnemyForts.erase(iter);
				break;
			}
		}
	}
	else
	{
		map<int, CFort*>::iterator iter = m_mapMyForts.begin();
		for (; iter != m_mapMyForts.end(); iter++)
		{
			if ((*iter).second->getFortID() == fortID)
			{
				delete((*iter).second);
				(*iter).second = nullptr;
				m_mapMyForts.erase(iter);
				break;
			}
		}
	}

	//    for(int i = 0; i < m_mapForts.size(); i++)
	//    {
	//        if(m_mapForts[i]->getFortID() == fortID)
	//        {
	//            m_mapForts.erase(i);
	//        }
	//    }
}

void CFortsMgr::createFortByID(int fortID)
{
	//int nNewFortIndex = 0;
	//if (fortID == m_nFortID_top)
	//{
	//	nNewFortIndex = 0;
	//}
	//else if (fortID == m_nFortID_mid)
	//{
	//	nNewFortIndex = 1;
	//}
	//else if (fortID == m_nFortID_bot)
	//{
	//	nNewFortIndex = 2;
	//}
	//CFort *fort = new CFort();
	//fort->createFort(fortID, m_isEnemy, nNewFortIndex);

}

double CFortsMgr::getPlayerTotalHp()
{	
	double dPlayerTotalHp = 0.0;
	map<int, CFort*>::iterator playerIter = m_mapMyForts.begin();
	for (; playerIter != m_mapMyForts.end(); playerIter++)
	{
		dPlayerTotalHp += (*playerIter).second->getFortHp();
	}
	return dPlayerTotalHp;
}

double CFortsMgr::getEnemyTotalHp()
{
	double dEnemyTotaoHp = 0.0;
	map<int, CFort*>::iterator enemyIter = m_mapEnemyForts.begin();
	for (; enemyIter != m_mapEnemyForts.end(); enemyIter++)
	{
		dEnemyTotaoHp += (*enemyIter).second->getFortHp();
	}
	return dEnemyTotaoHp;
}

void CFortsMgr::cleanBetterBuff()
{
	if (m_isEnemy)
	{
		m_isECleanBetBuff = true;
		map<int, CFort*>::iterator eIter = m_mapEnemyForts.begin();
		for (; eIter != m_mapEnemyForts.end(); eIter++)
		{
			(*eIter).second->recoveryFortGoodBuff();
		}
		m_pFortMgrBattle->getEnemy()->getBuffMgr()->deleteEnemyGoodBuff();
	}
	else
	{
		m_isPCleanBetBuff = true;
		map<int, CFort*>::iterator pIter = m_mapMyForts.begin();
		for (; pIter != m_mapMyForts.end(); pIter++)
		{
			(*pIter).second->recoveryFortGoodBuff();
		}
		m_pFortMgrBattle->getPlayer()->getBuffMgr()->deletePlayerGoodBuff();
	}
}

void CFortsMgr::cleanBadBuff()
{
	if (m_isEnemy)
	{
		m_isECleanBadBuff = true;
		map<int, CFort*>::iterator eIter = m_mapEnemyForts.begin();
		for (; eIter != m_mapEnemyForts.end(); eIter++)
		{
			(*eIter).second->recoveryFortBadBuff();
		}
		m_pFortMgrBattle->getEnemy()->getBuffMgr()->deleteEnemyBadBuff();
	}
	else
	{
		m_isPCleanBadBuff = true;
		map<int, CFort*>::iterator pIter = m_mapMyForts.begin();
		for (; pIter != m_mapMyForts.end(); pIter++)
		{
			(*pIter).second->recoveryFortBadBuff();
		}
		m_pFortMgrBattle->getPlayer()->getBuffMgr()->deletePlayerBadBuff();
	}
}

int CFortsMgr::getFortAck(int fortIndex)
{
	int nFortAck = 0;
	if (m_isEnemy)
	{
		nFortAck = m_mapEnemyForts[fortIndex]->getFortAck();
	}
	else
	{
		nFortAck = m_mapMyForts[fortIndex]->getFortAck();
	}
	return nFortAck;
}

bool CFortsMgr::isFortLive(int fortIndex)
{
	if (m_isEnemy)
	{
		return m_mapEnemyForts[fortIndex]->isFortLive();
	}
	else
	{
		return m_mapMyForts[fortIndex]->isFortLive();
	}
}

CFort * CFortsMgr::getFortByID(int ID, bool isEnemy)
{
	//    for(vector<CFort *>::const_iterator it = m_vecForts.begin();it != m_vecForts.end();it++)
	//    {
	//        if((*it)->getFortID() == ID)
	//        {
	//            return (*it);
	//        }
	//    }
	if (!isEnemy)
	{
		for (int i = 0; i < m_mapMyForts.size(); i++)
		{
			if (m_mapMyForts[i]->getFortID() == ID)
			{
				return m_mapMyForts[i];
			}
		}
	}
	else
	{
		for (int i = 0; i < m_mapEnemyForts.size(); i++)
		{
			if (m_mapEnemyForts[i]->getFortID() == ID)
			{
				return m_mapEnemyForts[i];
			}
		}
	}
	return nullptr;
}

CFort * CFortsMgr::getFortByIndex(int index, bool isEnemy)
{
	if (isEnemy)
	{
		return m_mapEnemyForts[index];
	}
	else
	{
		return m_mapMyForts[index];
	}

}

//int* CFortsMgr::getFortsPos(int fortID, bool isEnemy)
//{
//	int *pos = new int[2];
//	if (!isEnemy)
//	{
//		pos[0] = MYFORT_POS_X;
//		if (fortID == m_nMyTop_fortID)
//		{
//			pos[1] = FORT_TOP_POS_Y;
//		}
//		else if (fortID == m_nMyMid_fortID)
//		{
//			pos[1] = FORT_MID_POS_Y;
//		}
//		else if (fortID == m_nMyBot_fortID)
//		{
//			pos[1] = FORT_BOT_POS_Y;
//		}
//	}
//	else
//	{
//		pos[0] = ENEMYFORT_POS_X;
//		if (fortID == m_nEnemyTop_fortID)
//		{
//			pos[1] = FORT_TOP_POS_Y;
//		}
//		else if (fortID == m_nEnemyMid_fortID)
//		{
//			pos[1] = FORT_MID_POS_Y;
//		}
//		else if (fortID == m_nEnemyBot_fortID)
//		{
//			pos[1] = FORT_BOT_POS_Y;
//		}
//	}
//	return pos;
//}

map<int, CFort*> CFortsMgr::getPlayerFort()
{
	return m_mapMyForts;
}

map<int, CFort*> CFortsMgr::getEnemyFort()
{
	return m_mapEnemyForts;
}

bool CFortsMgr::isPlayerCleanBetterBuff()
{
	return m_isPCleanBetBuff;
}

bool CFortsMgr::isPlayerCleanBadBuff()
{
	return m_isPCleanBadBuff;
}

bool CFortsMgr::isEnemyCleanBetterBuff()
{
	return m_isECleanBetBuff;
}

void CFortsMgr::recoveryCleanBetterBuff()
{
	if (m_isEnemy)
	{
		m_isECleanBetBuff = false;
	}
	else
	{
		m_isPCleanBetBuff = false;
	}
}

void CFortsMgr::recoveryCleanBadBuff()
{
	if (m_isEnemy)
	{
		m_isECleanBadBuff = false;
	}
	else
	{
		m_isPCleanBadBuff = false;
	}
}

void CFortsMgr::setFortMgrBattle(CBattle * pBattle)
{
	m_pFortMgrBattle = pBattle;
}

void CFortsMgr::setFortSuitBuff(double suitBuffValue)
{
	if (m_isEnemy)
	{
		map<int, CFort*>::iterator iter = m_mapEnemyForts.begin();
		for (; iter != m_mapEnemyForts.end(); iter++)
		{
			(*iter).second->setHaveSuitBuff(true, suitBuffValue);
		}
	}
	else
	{
		map<int, CFort*>::iterator iter = m_mapMyForts.begin();
		for (; iter != m_mapMyForts.end(); iter++)
		{
			(*iter).second->setHaveSuitBuff(true, suitBuffValue);
		}
	}
}

void CFortsMgr::setPlayerDieFortID(int fortID)
{
	m_nRecentDiePlayerFort = fortID;
}

void CFortsMgr::setEnemyDieFortID(int fortID)
{
	m_nRecentDieEnemyFort = fortID;
}

int CFortsMgr::getDiePlayerFortID()
{
	return m_nRecentDiePlayerFort;
}

int CFortsMgr::getDieEnemyFortID()
{
	return m_nRecentDieEnemyFort;
}

void CFortsMgr::addInjuryPercent(double dPercent)
{
	map<int, CFort*>::iterator iter = m_mapMyForts.begin();
	for (; iter != m_mapMyForts.end(); iter++)
	{
		(*iter).second->injuryAdditionInBossBattle(dPercent);
	}
}

bool CFortsMgr::isEnemyCleanBadBuff()
{
	return m_isECleanBadBuff;
}

void CFortsMgr::update(double dt)
{
	if (m_isEnemy)
	{
		map<int, CFort*>::iterator enemyIter = m_mapEnemyForts.begin();
		for (; enemyIter != m_mapEnemyForts.end(); enemyIter++)
		{
			(*enemyIter).second->update(dt);
		}
	}
	else
	{
		map<int, CFort*>::iterator iter = m_mapMyForts.begin();
		for (; iter != m_mapMyForts.end(); iter++)
		{
			(*iter).second->update(dt);
		}
	}
}

