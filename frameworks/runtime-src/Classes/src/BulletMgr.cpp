#include "BulletMgr.h"
#include "Battle.h"


CBulletMgr::CBulletMgr(int nSide, CBattle* pBattle)
{
	m_nSide = nSide;
	m_pBattle = pBattle;
	m_nBulletCount = 0;
}


CBulletMgr::~CBulletMgr()
{
	vector<CBulletNormal*>::iterator iter = m_vecBullet.begin();
	for (; iter != m_vecBullet.end(); iter++)
	{
		delete((*iter));
		(*iter) = nullptr;
	}
	m_vecBullet.clear();
}

void CBulletMgr::update(double dTime)
{
	for (int i = 0; i < m_vecBullet.size(); i++)
	{
		m_vecBullet[i]->update(dTime);
	}
}

void CBulletMgr::createBullet(int nID, int nType, double dPosX, double dPosY, int nFirerID, int nFirerIndex, double dAtk, CFort* pTargetFort)
{
	CBulletNormal* pBullet = new CBulletNormal(m_nSide, nID, nType, m_pBattle);
	m_nBulletCount = m_nBulletCount + 1;
	pBullet->setBeginPos(dPosX, dPosY);
	//pBullet->firerAndTarget(pFirerFort, pTargetFort);
	pBullet->setBulletIndex(m_nBulletCount);
	pBullet->setFirerID(nFirerID);
	pBullet->setFirerIndex(nFirerIndex);
	if (pTargetFort == nullptr)
	{
		pBullet->setIsBulletToShip(true);
		pBullet->setTheVecOfShip();
	}
	else
	{
		pBullet->setTargetFort(pTargetFort);
	}
	
/*	double dAtk = 0.0;
	if (m_nSide == EPlayerKind::SELF)
	{
		dAtk = m_pBattle->getPlayerSelf()->getFortMgr()->getFortAtkByID(nFirerID, nFirerIndex);
	}
	else if (m_nSide == EPlayerKind::ENEMY)
	{
	 	dAtk = m_pBattle->getPlayerHost()->getFortMgr()->getFortAtkByID(nFirerID, nFirerIndex);
	}
	*/
	pBullet->setBulletDamage(dAtk);
	if (m_nSide == EPlayerKind::SELF)
	{
		pBullet->setBulletSpeed(m_pBattle->getPlayerSelf()->getFortMgr()->getFortByID(nFirerID, nFirerIndex)->getBulletSpeed());
	}
	else if (m_nSide == EPlayerKind::ENEMY)
	{
		pBullet->setBulletSpeed(m_pBattle->getPlayerHost()->getFortMgr()->getFortByID(nFirerID, nFirerIndex)->getBulletSpeed());
	}

	m_vecBullet.insert(m_vecBullet.end(), pBullet);
//	insertBulletEvent(nID, m_nBulletCount, dPosX, dPosY, EBulletEvent::BULLET_BORN);
	m_pBattle->runBulletEventHandler(m_nSide, EBulletEvent::BULLET_BORN, nID, m_nBulletCount);
}

/*void CBulletMgr::createBulletToShip(int nID, int nType, double dPosX, double dPosY, int nFirerID, int nFirerIndex, double dShipPosX, double dShipPosY)
{
}
*/

void CBulletMgr::createShipBullet(int nBulletID, int nType, double dPosX, double dPosY, CFort * pTargetFort)
{
	CBulletNormal* pBullet = new CBulletNormal(m_nSide, nBulletID, nType, m_pBattle);
	m_nBulletCount = m_nBulletCount + 1;
	pBullet->setBeginPos(dPosX, dPosY);
	pBullet->setIsShipBullet(true);
	pBullet->setTargetFort(pTargetFort);
	pBullet->setBulletIndex(m_nBulletCount);
	double dAtk = 0.0;
	if (m_nSide == EPlayerKind::SELF)
	{
		dAtk = m_pBattle->getPlayerSelf()->getShip()->getAtk();
		pBullet->setBulletSpeed(m_pBattle->getPlayerSelf()->getShip()->getBulletSpeed());
	}
	else if (m_nSide == EPlayerKind::ENEMY)
	{
		dAtk = m_pBattle->getPlayerHost()->getShip()->getAtk();
		pBullet->setBulletSpeed(m_pBattle->getPlayerHost()->getShip()->getBulletSpeed());
	}
	pBullet->setBulletDamage(dAtk);
	m_vecBullet.insert(m_vecBullet.end(), pBullet);
	//insertBulletEvent(nBulletID, m_nBulletCount, dPosX, dPosY, EBulletEvent::BULLET_BORN);
	m_pBattle->runBulletEventHandler(m_nSide, EBulletEvent::BULLET_BORN, nBulletID, m_nBulletCount);
}

void CBulletMgr::removeBulletFromVec(int nID, int nIndex)
{
	vector<CBulletNormal*>::iterator iter = m_vecBullet.begin();

	for (; iter != m_vecBullet.end();)
	{
		if ((*iter)->getBulletID() == nID && (*iter)->getBulletIndex() == nIndex)
		{
			//insertBulletEvent((*iter)->getBulletID(), (*iter)->getBulletIndex(), (*iter)->getPosX(), (*iter)->getPosY(), EBulletEvent::BULLET_BOMB);
			m_pBattle->runBulletEventHandler(m_nSide, EBulletEvent::BULLET_BOMB, (*iter)->getBulletID(), (*iter)->getBulletIndex());
			delete((*iter));
			(*iter) = nullptr;
			iter = m_vecBullet.erase(iter);	
			break;
		}
		else
		{
			iter++;
		}
	}
}

void CBulletMgr::removeBrokenTargetBullet(int nTargetID, int nTargetIndex)
{
	vector<CBulletNormal*>::iterator iter = m_vecBullet.begin();

	for (; iter != m_vecBullet.end();)
	{
		if ((*iter)->getTargetFortID() == nTargetID && (*iter)->getTargetFortIndex() == nTargetIndex)
		{
		//	insertBulletEvent((*iter)->getBulletID(), (*iter)->getBulletIndex(), (*iter)->getPosX(), (*iter)->getPosY(), EBulletEvent::BULLET_BOMB);
			m_pBattle->runBulletEventHandler(m_nSide, EBulletEvent::BULLET_REMOVE, (*iter)->getBulletID(), (*iter)->getBulletIndex());
			delete((*iter));
			(*iter) = nullptr;
			iter = m_vecBullet.erase(iter);
		}
		else
		{
			iter++;
		}
	}
}

vector<CBulletNormal*> CBulletMgr::getBulletVec()
{
	return m_vecBullet;
}

vector<SBulletEventData> CBulletMgr::getBulletEvent()
{
	return m_vecBulletEvent;
}

void CBulletMgr::insertBulletEvent(int nID, int nIndex, double dPosX, double dPosY, int nEvent)
{
	SBulletEventData sEventData;
	sEventData.nBulletID = nID;
	sEventData.nBulletIndex = nIndex;
	sEventData.dPosX = dPosX;
	sEventData.dPosY = dPosY;
	sEventData.nEventID = nEvent;
	m_vecBulletEvent.insert(m_vecBulletEvent.end(), sEventData);
}

void CBulletMgr::clearBulletEventVec()
{
	m_vecBulletEvent.clear();
}
