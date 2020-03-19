#include "stdafx.h"
#include "PropsMgr.h"
#include "Battle.h"

CPropsMgr::CPropsMgr(CBattle *pBattle, string propDataPath, string wrongDataPath)
{
	m_pPropMgrBattle = pBattle;
	m_strPropDataPath = propDataPath;
	m_strWrongDataPath = wrongDataPath;
	m_nPropsCount = 0;
	m_isEnemyNpcSecond = false;
	m_isPlayerNpcSecond = false;
	m_nPlayerPropNpc = 0;
	m_nEnemyPropNpc = 0;
	m_dPlayerDamage = 0.0;
	m_dEnemyDamage = 0.0;
}


CPropsMgr::~CPropsMgr()
{
	cleanPropMap();
}

void CPropsMgr::initData()
{

}

void CPropsMgr::update(double delta)
{
	map<int, CProps*>::iterator iter = m_mapProps.begin();
	for (; iter != m_mapProps.end(); )
	{
		int nNumber = (*iter).second->update(delta);
		if (nNumber == 1)
		{
			if ((*iter).second->getPropID() == propEvent::CALL_NPC_BY_PROP)
			{
				insertUsePropEventInVec(propEvent::NPC_BACK, (*iter).second->getTargetNum(), (*iter).second->getTargetFortID());
			}
			delete((*iter).second);
			(*iter).second = nullptr;
			m_mapProps.erase(iter++);
		}
		else
		{
			iter++;
		}
	}
	if (m_isPlayerNpcSecond)
	{
		if (!m_pPropMgrBattle->getPlayer()->isHaveNpc())
		{
			if (m_nPlayerPropNpc == 1)
			{
				useProp(1, propEvent::CALL_NPC_BY_PROP, 2, 0);
			}
			else if (m_nPlayerPropNpc == 2)
			{
				energyBodyCallNpc(m_dPlayerDamage, 1, 2);
			}
			m_isPlayerNpcSecond = false;
			m_nPlayerPropNpc = 0;
		}
	}
	if (m_isEnemyNpcSecond)
	{
		if (!m_pPropMgrBattle->getEnemy()->isHaveNpc())
		{
			if (m_nEnemyPropNpc == 1)
			{
				useProp(2, propEvent::CALL_NPC_BY_PROP, 1, 0);
			}
			else if (m_nEnemyPropNpc == 2)
			{
				energyBodyCallNpc(m_dEnemyDamage, 2, 1);
			}
			m_isEnemyNpcSecond = false;
			m_nEnemyPropNpc = 0;
		}
	}
}

int CPropsMgr::useProp(int nUser, int nPropID, int targeter, int fortID)
{
	CProps *pProp = new CProps(m_pPropMgrBattle, m_strPropDataPath, nPropID);
	int nUseEvent = pProp->isUseProp(nUser, targeter, fortID, m_strWrongDataPath);
	if (nUseEvent == 1)  //即食道具(delete pProp)
	{
		insertUsePropEventInVec(nPropID, targeter, fortID);
		m_nPropsCount += 1;
		delete(pProp);
		pProp = nullptr;
		return 1;
	}
	else if (nUseEvent == 2)  //需要动画时间de道具
	{
		insertUsePropEventInVec(nPropID, targeter, fortID);
		m_mapProps.insert(map<int, CProps*>::value_type(m_nPropsCount, pProp));
		m_nPropsCount += 1;
		return 1;
	}
	else if (nUseEvent == 3)
	{
		if (nUser == 1)
		{
			m_isPlayerNpcSecond = true;
			m_nPlayerPropNpc = 1;
		}
		else if (nUser == 2)
		{
			m_isEnemyNpcSecond = true;
			m_nEnemyPropNpc = 1;
		}
		delete(pProp);
		pProp = nullptr;
		m_nPropsCount += 1;
		return 1;
	}
	else if (nUseEvent == 4)
	{
		// 对boss使用的debuff道具。？？ 加一错误代码。让服务器也跟着判
	}
	m_nPropsCount += 1;
	delete(pProp);
	pProp = nullptr;
	return nUseEvent;
}

void CPropsMgr::usePropForReconnect(int nPropCount, int nPropID, double dBurstTime, int nUser, int nTargetSide, int nFortID, double dEnergyNpcDamage)
{
	CProps *pProp = new CProps(m_pPropMgrBattle, m_strPropDataPath, nPropID);
	m_mapProps.insert(map<int, CProps*>::value_type(nPropCount, pProp));
	pProp->setPropBurstTime(dBurstTime);
	pProp->setUser(nUser);
	pProp->setTargetSide(nTargetSide);
	pProp->setTargetFort(nFortID);
	pProp->setEnergyNpcDamage(dEnergyNpcDamage);
}

void CPropsMgr::putPropEventToVec(int nPropEventID, int nTarget)
{
	sPropEvent propEvent;
	propEvent.nPropEventID = nPropEventID;
	propEvent.nTarget = nTarget;
	m_vecPropEvent.insert(m_vecPropEvent.end(), propEvent);
}

vector<sPropEvent> CPropsMgr::getPropEventVec()
{
	return m_vecPropEvent;
}

void CPropsMgr::insertUsePropEventInVec(int propID, int targetSide, int fortID)
{
	sPropEvent propEvent;
	propEvent.nPropEventID = propID;
	if (targetSide == 1)
	{
		if (fortID != 0)
		{
			propEvent.nTarget = 0 + m_pPropMgrBattle->getPlayer()->getShip()->getFortMgr()->getFortByID(fortID, false)->getFortIndex() + 1;
		}
		else
		{
			propEvent.nTarget = 0;
		}
	}
	else if (targetSide == 2)
	{
		if (fortID != 0)
		{
			propEvent.nTarget = 10 + m_pPropMgrBattle->getEnemy()->getShip()->getFortMgr()->getFortByID(fortID, true)->getFortIndex() + 1;
		}
		else
		{
			propEvent.nTarget = 10;
		}
	}
	if (propID == 1307 || propID == 1308 || propID == 1309)
	{
		propEvent.nTarget = 4;
	}
	m_vecPropEvent.insert(m_vecPropEvent.end(), propEvent); 
}

void CPropsMgr::insertPropBurstEventInVec()
{
}

void CPropsMgr::cleanPropEvent()
{
	m_vecPropEvent.clear();
}

bool CPropsMgr::isPlayerNpcSecond()
{
	return m_isPlayerNpcSecond;
}

void CPropsMgr::setPlayerNpcSecond(int nBool)
{
	if (nBool == 0)
	{
		m_isPlayerNpcSecond = false;
	}
	else
	{
		m_isPlayerNpcSecond = true;
	}
}

bool CPropsMgr::isEnemyNpcSecond()
{
	return m_isEnemyNpcSecond;
}

void CPropsMgr::setEnemyNpcSecond(int nBool)
{
	if (nBool == 0)
	{
		m_isEnemyNpcSecond = false;
	}
	else
	{
		m_isEnemyNpcSecond = true;
	}
}

int CPropsMgr::getPlayerPropNpc()
{
	return m_nPlayerPropNpc;
}

void CPropsMgr::setPlayerPropNpc(int nKind)
{
	m_nPlayerPropNpc = nKind;
}

int CPropsMgr::getEnemyPropNpc()
{
	return m_nEnemyPropNpc;
}

void CPropsMgr::setEnemyPropNpc(int nKind)
{
	m_nEnemyPropNpc = nKind;
}

double CPropsMgr::getPlayerDamage()
{
	return m_dPlayerDamage;
}

void CPropsMgr::setPlayerDamage(double dDamage)
{
	m_dPlayerDamage = dDamage;
}

double CPropsMgr::getEnemyDamage()
{
	return m_dEnemyDamage;
}

void CPropsMgr::setEnemyDamage(double dDamage)
{
	m_dEnemyDamage = dDamage;
}

void CPropsMgr::energyBodyCallNpc(double damage, int nUser, int nTarget)
{
	CProps *pProp = new CProps(m_pPropMgrBattle, m_strPropDataPath, propEvent::CALL_NPC_BY_PROP);
	int nUseEvent = pProp->isUseProp(nUser, nTarget, 0, m_strWrongDataPath);
	pProp->setEnergyNpcDamage(damage);
	if (nUseEvent == 2)
	{
		insertUsePropEventInVec(propEvent::CALL_NPC_BY_PROP, nTarget, 0);
		m_mapProps.insert(map<int, CProps*>::value_type(m_nPropsCount, pProp));
	}
	else if (nUseEvent == 3)
	{
		if (nUser == 1)
		{
			m_dPlayerDamage = damage;
			m_isPlayerNpcSecond = true;
			m_nPlayerPropNpc = 2;
		}
		else if (nUser == 2)
		{
			m_dEnemyDamage = damage;
			m_isEnemyNpcSecond = true;
			m_nEnemyPropNpc = 2;
		}
		delete(pProp);
		pProp = nullptr;
	}
	m_nPropsCount++;
}

int CPropsMgr::getPropsCount()
{
	return m_nPropsCount;
}

void CPropsMgr::setPropsCount(int nCount)
{
	m_nPropsCount = nCount;
}

map<int, CProps*> CPropsMgr::getPropsMap()
{
	return m_mapProps;
}

void CPropsMgr::cleanPropMap()
{
	map<int, CProps*>::iterator iter = m_mapProps.begin();
	for (; iter != m_mapProps.end(); iter++)
	{
		delete((*iter).second);
		(*iter).second = nullptr;
	}
	m_mapProps.clear();
}
