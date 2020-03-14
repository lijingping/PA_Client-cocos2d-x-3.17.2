#include "FortMgr.h"
#include "Battle.h"

CFortMgr::CFortMgr()
{
}

CFortMgr::CFortMgr(int nSide, CBattle* pBattle)
{
	m_pFortMgrBattle = pBattle;
	m_nFortMgrSide = nSide;
	m_nCountFort = 0;
}

CFortMgr::~CFortMgr()
{
	map<int, CFort*>::iterator iter = m_mapForts.begin();
	for (; iter != m_mapForts.end(); iter++)
	{
		delete((*iter).second);
		(*iter).second = nullptr;
	}
	m_mapForts.clear();
}

void CFortMgr::init()
{
}

void CFortMgr::update(double dTime)
{
	map<int, CFort*>::iterator iter = m_mapForts.begin();
	for (; iter != m_mapForts.end(); iter++)
	{
		(*iter).second->update(dTime);
	}

}
// 生成战机
int CFortMgr::createFort(int nFortID, int nFortLv, int nFortPosY, int nArmyPoint)
{
	/*if (m_nFortMgrSide == EPlayerKind::SELF)
	{
		if (!m_pFortMgrBattle->getPlayerSelf()->isArmySpaceEnough(nArmyPoint)) // 兵力空间不够。
		{
			return 0;
		}
	}
	else
	{
		if (!m_pFortMgrBattle->getPlayerHost()->isArmySpaceEnough(nArmyPoint)) // 兵力空间不够。
		{
			return 0;
		}
	}
	int fortPosX = getRandFortX();
	if (m_nFortMgrSide == EPlayerKind::ENEMY)
	{
		fortPosX = BATTLE_VIEW_WIDTH - fortPosX;
	}
	CFort* pFort = new CFort(m_nFortMgrSide, nFortID, nFortLv, m_pFortMgrBattle);
	//pFort->setBattlePoint(m_pFortMgrBattle);
	pFort->setPosition(fortPosX, nFortPosY);
	pFort->setFortIndex(m_nCountFort);

	m_pFortMgrBattle->runFortEventHandler(EFortEvent::FORT_CREATE, nFortID, m_nCountFort, 0, 0); // 创建战机事件
	m_mapForts.insert(map<int, CFort*>::value_type(m_nCountFort, pFort));
	m_nCountFort++;
	if (m_nFortMgrSide == EPlayerKind::SELF)
	{
		m_pFortMgrBattle->getPlayerSelf()->addArmy(pFort->getArmPoint());
	}
	else
	{
		m_pFortMgrBattle->getPlayerHost()->addArmy(pFort->getArmPoint());
	}

	return fortPosX;
*/
		int nID = 0;
		double dBeginPosX = 0.0;
		double dBeginPosY = 0.0;
		for (int i = 0; i < 6; i++)
		{
			
			if (i < 3)
			{
				if (m_nFortMgrSide == EPlayerKind::SELF)
				{
					dBeginPosX = 150;
				}
				else if (m_nFortMgrSide == EPlayerKind::ENEMY)
				{
					dBeginPosX = 2650;
				}
			}
			else
			{
				if (m_nFortMgrSide == EPlayerKind::SELF)
				{
					dBeginPosX = 300;
				}
				else if (m_nFortMgrSide == EPlayerKind::ENEMY)
				{
					dBeginPosX = 2850;
				}
				
			}
			dBeginPosY = 133 * (i % 3);

			for (int j = 0; j < 6; j++)
			{
				m_nCountFort++;
				nID = 101 + rand() % 6;
				CFort* pFort = new CFort(m_nFortMgrSide, nID, 1, m_pFortMgrBattle);
				pFort->setFortIndex(m_nCountFort);
				double dFortPosX = 0.0;
				double dFortPosY = 0.0;
				dFortPosX = dBeginPosX + 50 * (j % 2);
				dFortPosY = dBeginPosY + 45 * (j % 3);
				pFort->setPosition(dFortPosX, dFortPosY);
				m_pFortMgrBattle->runFortEventHandler(EFortEvent::FORT_CREATE, nID, m_nCountFort, 0, 0); // 创建战机事件
				m_mapForts.insert(map<int, CFort*>::value_type(m_nCountFort, pFort));
			}
		}

		return 1;
		
}



void CFortMgr::createFortInClient(int nFortID, int nFortLv, int nFortPosY, int nFortPosX)
{
	CFort* pFort = new CFort(m_nFortMgrSide, nFortID, nFortLv, m_pFortMgrBattle);
	//pFort->setBattlePoint(m_pFortMgrBattle);
	pFort->setPosition(nFortPosY, nFortPosX);
	pFort->setFortIndex(m_nCountFort);
	m_mapForts.insert(map<int, CFort*>::value_type(m_nCountFort, pFort));
	m_nCountFort++;
}

int CFortMgr::getRandFortX()
{
	srand((unsigned)time(NULL));
	int fortPosX = rand() % CREATE_FORT_RANGE_X + CREATE_FORT_BEGIN_X; //(50 - 100)
	return fortPosX;
}

CFort * CFortMgr::getFortByID(int nFortID, int nFortIndex)
{
	map<int, CFort*>::iterator iter = m_mapForts.begin();
	for (; iter != m_mapForts.end(); iter++)
	{
		if ((*iter).second->getID() == nFortID && (*iter).second->getFortIndex() == nFortIndex)
		{
			return (*iter).second;
		}
	}
	return nullptr;
}

double CFortMgr::getFortAtkByID(int nFortID, int nFortIndex)
{
	map<int, CFort*>::iterator iter = m_mapForts.begin();
	for (; iter != m_mapForts.end(); iter++)
	{
		if ((*iter).second->getID() == nFortID && (*iter).second->getFortIndex() == nFortIndex)
		{
			return (*iter).second->getAtk();
		}
	}
	return 0.0;
}

void CFortMgr::removeBrokenFort(int nFortID, int nFortIndex)
{
	map<int, CFort*>::iterator iter = m_mapForts.begin();
	for (; iter != m_mapForts.end(); iter++)
	{
		if ((*iter).second->getID() == nFortID && (*iter).second->getFortIndex() == nFortIndex)
		{
			delete((*iter).second);
			(*iter).second = nullptr;
			m_mapForts.erase(iter);
			break;
		}
	}
	
}

map<int, CFort*> CFortMgr::getFortsMap()
{
	return m_mapForts;
}
