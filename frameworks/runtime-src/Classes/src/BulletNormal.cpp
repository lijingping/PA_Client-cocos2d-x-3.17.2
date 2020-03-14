#include "BulletNormal.h"
#include "Battle.h"


CBulletNormal::CBulletNormal(int nSide, int nID, int nType, CBattle* pBattle)
{
	m_nBulletSide = nSide;
	m_nBulletID = nID;
	m_nBulletType = nType;
	m_pBulletBattle = pBattle;
	m_nSizeRadius = 10;
	m_isShipBullet = false;
	m_isBulletToShip = false;
	m_isInShipUp = false;
	m_isDamageShip = false;
	m_pTargetFort = nullptr;
	m_dDirectionLength = 0;
	m_dBulletDamage = 0;
	m_nFirerID = 0;
	m_nFirerIndex = 0;
	if (m_nBulletSide == EPlayerKind::SELF)
	{
		m_dTurnRadian = 0;
	}
	else if (m_nBulletSide == EPlayerKind::ENEMY)
	{
		m_dTurnRadian = PI;
	}
}


CBulletNormal::~CBulletNormal()
{
}

void CBulletNormal::update(double dTime)
{
	if (m_nBulletType == EShootType::BULLET_SHELL)
	{
		if (m_isBulletToShip)
		{
			bulletShellMoveToShip(dTime);
		}
		else
		{
			bulletShellMove(dTime);
		}
	}
	else if (m_nBulletType == EShootType::PIERCE_SHELL)
	{
		pierceShellMove(dTime);
	}
	else if (m_nBulletType == EShootType::LASER_FIRE)
	{
		laserFire(dTime);
	}
}

void CBulletNormal::setBeginPos(double dPosX, double dPosY)
{
	m_dPosX = dPosX;
	m_dPosY = dPosY;
}

void CBulletNormal::bulletShellMove(double dTime)
{
	if (m_pTargetFort)
	{
		double dVecX = m_pTargetFort->getPosX() - m_dPosX;
		double dVecY = m_pTargetFort->getPosY() - m_dPosY;
		turnBulletDirection(dVecX, dVecY);
		// 向量长度
		double dVecOpposite = sqrt(dVecX * dVecX + dVecY * dVecY);
/*		double dSpeed = 0.0;
		if (m_isShipBullet)
		{
			dSpeed = SHIPBULLETSPEED;
		}
		else
		{
			dSpeed = BULLETSPEED;
		}
		*/
		double dMoveX = dVecX / dVecOpposite * dTime * m_nBulletSpeed;
		double dMoveY = dVecY / dVecOpposite * dTime * m_nBulletSpeed;
		m_dPosX = m_dPosX + dMoveX;
		m_dPosY = m_dPosY + dMoveY;
		double dDistance = CTool::countRange(m_dPosX, m_dPosY, m_pTargetFort->getPosX(), m_pTargetFort->getPosY());
		if (dDistance <= m_nSizeRadius + m_pTargetFort->getSizeRadius())
		{
			// 炮弹爆炸，造成伤害
			if (m_isShipBullet)
			{
				m_pTargetFort->beHurtByShipBullet(m_dBulletDamage);
			}
			else
			{
				m_pTargetFort->beHurtByFortBullet(m_dBulletDamage, m_nFirerID, m_nFirerIndex, true);
			}
			
			// 从Mgr那儿移除子弹
			if (m_nBulletSide == EPlayerKind::SELF)
			{
				m_pBulletBattle->getPlayerSelf()->getBulletMgr()->removeBulletFromVec(m_nBulletID, m_nBulletIndex);
			}
			else if (m_nBulletSide == EPlayerKind::ENEMY)
			{
				m_pBulletBattle->getPlayerHost()->getBulletMgr()->removeBulletFromVec(m_nBulletID, m_nBulletIndex);
			}
		}
	}
}

void CBulletNormal::bulletShellMoveToShip(double dTime)
{
	if (m_nBulletSide == EPlayerKind::SELF)
	{
		CShip* pShip = m_pBulletBattle->getPlayerHost()->getShip();
		if (m_isInShipUp)
		{
			pShip->beDamageByFortBullet(m_dBulletDamage);
			m_pBulletBattle->getPlayerSelf()->getBulletMgr()->removeBulletFromVec(m_nBulletID, m_nBulletIndex);
			return;
		}
		// 子弹飞行路线
		m_dPosX = m_dPosX + m_dTargetDirectionX / m_dDirectionLength * dTime * m_nBulletSpeed;
		m_dPosY = m_dPosY + m_dTargetDirectionY / m_dDirectionLength * dTime * m_nBulletSpeed;
		double dShipPosX = pShip->getPosX();
		double dShipPosY = pShip->getPosY();
		double dShipLength = pShip->getSizeLength();
		double dShipWidth = pShip->getSizeWidth();
		double dShipLeftX = dShipPosX - dShipLength * 0.5;
		double dShipLeftTopY = dShipPosY + dShipWidth * 0.5;
		double dShipLeftBottonY = dShipPosY - dShipWidth * 0.5;
		double dDistance = 0.0;
		if (m_dPosX < dShipLeftX)   // 右战舰左边界 左边
		{
			if (m_dPosY > dShipLeftTopY)
			{
				dDistance = CTool::countRange(m_dPosX, m_dPosY, dShipLeftX, dShipLeftTopY);
			}
			else if (m_dPosX < dShipLeftBottonY)
			{
				dDistance = CTool::countRange(m_dPosX, m_dPosY, dShipLeftX, dShipLeftBottonY);
			}
			else
			{
				dDistance = dShipLeftX - m_dPosX;
			}
		}
		else
		{
			if (m_dPosY > dShipLeftTopY)
			{
				dDistance = m_dPosY - dShipLeftTopY;
			}
			else if (m_dPosY < dShipLeftBottonY)
			{
				dDistance = dShipLeftBottonY - m_dPosY;
			}
			else
			{
				dDistance = 0;
			}
		}
		if (dDistance < m_nSizeRadius)
		{
			pShip->beDamageByFortBullet(m_dBulletDamage);
			m_pBulletBattle->getPlayerSelf()->getBulletMgr()->removeBulletFromVec(m_nBulletID, m_nBulletIndex);
		}	
	}
	else if (m_nBulletSide == EPlayerKind::ENEMY)
	{
		CShip* pShip = m_pBulletBattle->getPlayerSelf()->getShip();
		if (m_isInShipUp)   // 位于战舰上的子弹
		{
			pShip->beDamageByFortBullet(m_dBulletDamage);
			m_pBulletBattle->getPlayerHost()->getBulletMgr()->removeBulletFromVec(m_nBulletID, m_nBulletIndex);
			return;
		}
		m_dPosX = m_dPosX + m_dTargetDirectionX / m_dDirectionLength * dTime * m_nBulletSpeed;
		m_dPosY = m_dPosY + m_dTargetDirectionY / m_dDirectionLength * dTime * m_nBulletSpeed;
		double dDistance = 0.0;
		double dShipRightX = pShip->getPosX() + pShip->getSizeLength() * 0.5;
		double dShipRightTopY = pShip->getPosY() + pShip->getSizeWidth() * 0.5;
		double dShipRightBottonY = pShip->getPosY() - pShip->getSizeWidth() * 0.5;
		if (m_dPosX > dShipRightX)
		{
			if (m_dPosY > dShipRightTopY)
			{
				dDistance = CTool::countRange(m_dPosX, m_dPosY, dShipRightX, dShipRightTopY);
			}
			else if (m_dPosY < dShipRightBottonY)
			{
				dDistance = CTool::countRange(m_dPosX, m_dPosY, dShipRightX, dShipRightBottonY);
			}
			else
			{
				dDistance = m_dPosX - dShipRightX;
			}
		}
		else
		{
			if (m_dPosY > dShipRightTopY)
			{
				dDistance = m_dPosY - dShipRightTopY;
			}
			else if (m_dPosY < dShipRightBottonY)
			{
				dDistance = dShipRightBottonY - m_dPosY;
			}
			else
			{
				dDistance = 0;
			}
		}
		
		if (dDistance < m_nSizeRadius)
		{
			pShip->beDamageByFortBullet(m_dBulletDamage);
			m_pBulletBattle->getPlayerHost()->getBulletMgr()->removeBulletFromVec(m_nBulletID, m_nBulletIndex);
		}
	}
}

void CBulletNormal::pierceShellMove(double dTime)
{
	double dMoveX = m_dTargetDirectionX / m_dDirectionLength * dTime * m_nBulletSpeed;
	double dMoveY = m_dTargetDirectionY / m_dDirectionLength * dTime * m_nBulletSpeed;
	m_dPosX = m_dPosX + dMoveX;
	m_dPosY = m_dPosY + dMoveY;
	
	map<int, CFort*> mapForts;
	if (m_nBulletSide == EPlayerKind::SELF)
	{
		mapForts = m_pBulletBattle->getPlayerHostForts();
	}
	else if (m_nBulletSide == EPlayerKind::ENEMY)
	{
		mapForts = m_pBulletBattle->getPlayerSelfForts();
	}
	map<int, CFort*>::iterator iter = mapForts.begin();
	for (; iter != mapForts.end(); iter++)
	{
		double dDistance = CTool::countRange(m_dPosX, m_dPosY, (*iter).second->getPosX(), (*iter).second->getPosY());
		if (dDistance <= (*iter).second->getSizeRadius() + m_nSizeRadius)
		{
			int nHaveFort = 0;
			for (int i = 0; i < m_vecRecordAttackFort.size(); i++)
			{
				if (m_vecRecordAttackFort[i]->getID() == (*iter).second->getID() &&
					m_vecRecordAttackFort[i]->getFortIndex() == (*iter).second->getFortIndex())   // 判断是否存在于已攻击的战机队列中
				{
					nHaveFort = 1;
					break;
				}
			}
			if (nHaveFort == 0)
			{
				// 攻击
				if ((*iter).second->getFortIndex() == m_pTargetFort->getFortIndex())
				{
					(*iter).second->beHurtByFortBullet(m_dBulletDamage, m_nFirerID, m_nFirerIndex, true);
				}
				else
				{
					(*iter).second->beHurtByFortBullet(m_dBulletDamage, m_nFirerID, m_nFirerIndex, false);
				}
				
				m_vecRecordAttackFort.insert(m_vecRecordAttackFort.end(), (*iter).second);
			}
		}
	}
	//攻击战舰的检测
	if (m_nBulletSide == EPlayerKind::SELF)
	{
		CShip *pShip = m_pBulletBattle->getPlayerHost()->getShip();
		double dShipLeftX = pShip->getPosX() - pShip->getSizeLength() * 0.5;
		double dShipLeftTopY = pShip->getPosY() + pShip->getSizeWidth() * 0.5;
		double dShipLeftBottonY = pShip->getPosY() - pShip->getSizeWidth() * 0.5;
		double dDistance = 0.0;
		if (m_dPosX < dShipLeftX) // 子弹于右边战舰左切边的左边
		{
			if (m_dPosY > dShipLeftTopY)
			{
				dDistance = CTool::countRange(m_dPosX, m_dPosY, dShipLeftX, dShipLeftTopY);
			}
			else if (m_dPosY < dShipLeftBottonY)
			{
				dDistance = CTool::countRange(m_dPosX, m_dPosY, dShipLeftX, dShipLeftBottonY);
			}
			else
			{
				dDistance = dShipLeftX - m_dPosX;
			}
		}
		else
		{
			if (m_dPosY > dShipLeftTopY)
			{
				dDistance = m_dPosY - dShipLeftTopY;
			}
			else if (m_dPosY < dShipLeftBottonY)
			{
				dDistance = dShipLeftBottonY - m_dPosY;
			}
			else
			{
				dDistance = 0;
			}
		}
		
		if (dDistance < m_nSizeRadius)
		{
			if (!m_isDamageShip)
			{
				m_pBulletBattle->getPlayerHost()->getShip()->beDamageByFortBullet(m_dBulletDamage);
				m_isDamageShip = true;
			}
		}
	}
	else if (m_nBulletSide == EPlayerKind::ENEMY)
	{
		CShip* pShip = m_pBulletBattle->getPlayerSelf()->getShip();
		double dShipRightX = pShip->getPosX() + pShip->getSizeLength() * 0.5;
		double dShipRightTopY = pShip->getPosY() + pShip->getSizeWidth() * 0.5;
		double dShipRightBottonY = pShip->getPosY() - pShip->getSizeWidth() * 0.5;
		double dDistance = 0.0;
		if (m_dPosX > dShipRightX) // 左边
		{
			if (m_dPosY > dShipRightTopY)
			{
				dDistance = CTool::countRange(m_dPosX, m_dPosY, dShipRightX, dShipRightTopY);
			}
			else if (m_dPosY < dShipRightBottonY)
			{
				dDistance = CTool::countRange(m_dPosX, m_dPosY, dShipRightX, dShipRightBottonY);
			}
			else
			{
				dDistance = m_dPosX - dShipRightX;
			}
		}
		else
		{
			if (m_dPosY > dShipRightTopY)
			{
				dDistance = m_dPosY - dShipRightTopY;
			}
			else if (m_dPosY < dShipRightBottonY)
			{
				dDistance = dShipRightBottonY - m_dPosY;
			}
			else
			{
				dDistance = 0;
			}
		}
		
		if (dDistance < m_nSizeRadius)
		{
			if (!m_isDamageShip)
			{
				m_pBulletBattle->getPlayerSelf()->getShip()->beDamageByFortBullet(m_dBulletDamage);
				m_isDamageShip = true;
			}
		}
	}
	if (m_dPosX < -m_nSizeRadius || m_dPosX > BATTLE_VIEW_WIDTH + m_nSizeRadius ||
		m_dPosY < -m_nSizeRadius || m_dPosY > BATTLE_VIEW_HEIGHT + m_nSizeRadius)              // 超出边界
	{
		//移除子弹
		if (m_nBulletSide == EPlayerKind::SELF)
		{
			m_pBulletBattle->getPlayerSelf()->getBulletMgr()->removeBulletFromVec(m_nBulletID, m_nBulletIndex);
		}
		else if (m_nBulletSide == EPlayerKind::ENEMY)
		{
			m_pBulletBattle->getPlayerHost()->getBulletMgr()->removeBulletFromVec(m_nBulletID, m_nBulletIndex);
		}
	}
}

void CBulletNormal::laserFire(double dTime)
{
	map<int, CFort*> mapForts;
	if (m_nBulletSide == EPlayerKind::SELF)
	{
		mapForts = m_pBulletBattle->getPlayerHostForts();
	}
	else if (m_nBulletSide == EPlayerKind::ENEMY)
	{
		mapForts = m_pBulletBattle->getPlayerSelfForts();
	}
	map<int, CFort*>::iterator iter = mapForts.begin();
	for (; iter != mapForts.end(); iter++)
	{
		// 判断正负两边
		if (m_dTargetDirectionX > 0)
		{
			if ((*iter).second->getPosX() < m_dPosX)
			{
				continue;
			}
		}
		else if (m_dTargetDirectionX < 0)
		{
			if ((*iter).second->getPosY() > m_dPosX)
			{
				continue;
			}
		}
		else if (m_dTargetDirectionX == 0)
		{
			if (m_dTargetDirectionY < 0)
			{
				if ((*iter).second->getPosY() > m_dPosY)
				{
					continue;
				}
			}
			else if (m_dTargetDirectionY > 0)
			{
				if ((*iter).second->getPosY() < m_dPosY)
				{
					continue;
				}
			}
		}
		double dPointToLineDis = countPointToLineDis((*iter).second->getPosX(), (*iter).second->getPosY());
		if (dPointToLineDis <= (*iter).second->getSizeRadius() + m_nSizeRadius)
		{
			// 攻击
			if ((*iter).second->getFortIndex() == m_pTargetFort->getFortIndex())
			{
				(*iter).second->beHurtByFortBullet(m_dBulletDamage, m_nFirerID, m_nFirerIndex, true);
			}
			else
			{
				(*iter).second->beHurtByFortBullet(m_dBulletDamage, m_nFirerID, m_nFirerIndex, false);
			}
			
		}
	}
	// 计算战舰距离(激光）(距离检测有待进一步分析计算）
	double dShipToLineDis = 0.0;
	CShip* pShip;
	if (m_nBulletSide == EPlayerKind::SELF)
	{
		pShip = m_pBulletBattle->getPlayerHost()->getShip();
	}
	else if (m_nBulletSide == EPlayerKind::ENEMY)
	{
		pShip = m_pBulletBattle->getPlayerSelf()->getShip();
	}
	dShipToLineDis = countPointToLineDis(pShip->getPosX(), pShip->getPosY());
	if (dShipToLineDis <= pShip->getSizeWidth() * 0.5 + m_nSizeRadius)
	{
		pShip->beDamageByFortBullet(m_dBulletDamage);
	}
	// 移除子弹
	if (m_nBulletSide == EPlayerKind::SELF)
	{
		m_pBulletBattle->getPlayerSelf()->getBulletMgr()->removeBulletFromVec(m_nBulletID, m_nBulletIndex);
	}
	else if (m_nBulletSide == EPlayerKind::ENEMY)
	{
		m_pBulletBattle->getPlayerHost()->getBulletMgr()->removeBulletFromVec(m_nBulletID, m_nBulletIndex);
	}
}

/*void CBulletNormal::firerAndTarget(CFort * pFirerFort, CFort* pTargetFort)
{
	m_pFirerFort = pFirerFort;
	m_pTargetFort = pTargetFort;
	double targetBeginPosX = pTargetFort->getPosX();
	double targetBeginPosY = pTargetFort->getPosY();
	m_dTargetDirectionX = targetBeginPosX - m_dPosX;
	m_dTargetDirectionY = targetBeginPosY - m_dPosY;
	m_dDirectionLength = sqrt(m_dTargetDirectionX * m_dTargetDirectionX + m_dTargetDirectionY * m_dTargetDirectionY);
	m_dBulletDamage = pFirerFort->getAtk();
}
*/

void CBulletNormal::setTargetFort(CFort * pFort)
{
	m_pTargetFort = pFort;
	double targetBeginPosX = pFort->getPosX();
	double targetBeginPosY = pFort->getPosY();
	m_dTargetDirectionX = targetBeginPosX - m_dPosX;
	m_dTargetDirectionY = targetBeginPosY - m_dPosY;
	m_dDirectionLength = sqrt(m_dTargetDirectionX * m_dTargetDirectionX + m_dTargetDirectionY * m_dTargetDirectionY);
	turnBulletDirection(m_dTargetDirectionX, m_dTargetDirectionY);

}

void CBulletNormal::setTheVecOfShip()
{
	CShip* pTargetShip;
	if (m_nBulletSide == EPlayerKind::SELF)
	{
		pTargetShip = m_pBulletBattle->getPlayerHost()->getShip();
		double dShipLeftX = pTargetShip->getPosX() - pTargetShip->getSizeLength() * 0.5;
		double dShipLeftTopY = pTargetShip->getPosY() + pTargetShip->getSizeWidth() * 0.5;
		double dShipLeftBottonY = pTargetShip->getPosY() - pTargetShip->getSizeWidth() * 0.5;
		if (m_dPosX < dShipLeftX)
		{
			m_dTargetDirectionX = dShipLeftX - m_dPosX;
			if (m_dPosY > dShipLeftTopY)
			{
				m_dTargetDirectionY = dShipLeftTopY - m_dPosY;
			}
			else if (m_dPosY < dShipLeftBottonY)
			{
				m_dTargetDirectionY = dShipLeftBottonY - m_dPosY;
			}
			else
			{
				m_dTargetDirectionY = 0;
			}
		}
		else
		{
			m_dTargetDirectionX = 0;
			if (m_dPosY > dShipLeftTopY)
			{
				m_dTargetDirectionY = dShipLeftTopY - m_dPosY;
			}
			else if (m_dPosY < dShipLeftBottonY)
			{
				m_dTargetDirectionY = dShipLeftBottonY - m_dPosY;
			}
			else
			{
				m_isInShipUp = true;
				m_dTargetDirectionY = 0;
			}
		}
	}
	else if (m_nBulletSide == EPlayerKind::ENEMY)
	{
		pTargetShip = m_pBulletBattle->getPlayerSelf()->getShip();
		double dShipRightX = pTargetShip->getPosX() + pTargetShip->getSizeLength() * 0.5;
		double dShipRightTopY = pTargetShip->getPosY() + pTargetShip->getSizeWidth() * 0.5;
		double dShipRightBottonY = pTargetShip->getPosY() - pTargetShip->getSizeWidth() * 0.5;
		if (m_dPosX > dShipRightX)
		{
			m_dTargetDirectionX = dShipRightX - m_dPosX;
			if (m_dPosY > dShipRightTopY)
			{
				m_dTargetDirectionY = dShipRightTopY - m_dPosY;
			}
			else if (m_dPosY < dShipRightBottonY)
			{
				m_dTargetDirectionY = dShipRightBottonY - m_dPosY;
			}
			else
			{
				m_dTargetDirectionY = 0;
			}
		}
		else
		{
			m_dTargetDirectionX = 0;
			if (m_dPosY > dShipRightTopY)
			{
				m_dTargetDirectionY = dShipRightTopY - m_dPosY;
			}
			else if (m_dPosY < dShipRightBottonY)
			{
				m_dTargetDirectionY = dShipRightBottonY - m_dPosY;
			}
			else
			{
				m_isInShipUp = true;     //m_dTargetDirectionY = 1;     // 叠于战舰上，赋值小值，在update上判
				m_dTargetDirectionY = 0;
			}
		}
	}

	m_dDirectionLength = sqrt(m_dTargetDirectionX * m_dTargetDirectionX + m_dTargetDirectionY * m_dTargetDirectionY);
	turnBulletDirection(m_dTargetDirectionX, m_dTargetDirectionY);
}

void CBulletNormal::bulletFly(double dTime)
{
}

int CBulletNormal::getTargetFortID()
{
	return m_pTargetFort->getID();
}

int CBulletNormal::getTargetFortIndex()
{
	return m_pTargetFort->getFortIndex();
}

double CBulletNormal::countPointToLineDis(double dPointX, double dPointY)
{
	// 计算出炮台与炮口初始时的向量
	double dFortVecX = dPointX - m_dPosX;
	double dFortVecY = dPointY - m_dPosY;
	// 两向量的点乘
	double dVecMul = m_dTargetDirectionX * dFortVecX + m_dTargetDirectionY * dFortVecY;
	// 两向量的模 乘积
	double dVecMudMul = sqrt(m_dTargetDirectionX * m_dTargetDirectionX + m_dTargetDirectionY * m_dTargetDirectionY) *
		sqrt(dFortVecX * dFortVecX + dFortVecY * dFortVecY);
	// 计算与激光偏离的角度
	double dVecAngle = acos(dVecMul / dVecMudMul);
	// 点到线的距离
	double dPointToLineDis = sin(dVecAngle) * sqrt(dFortVecX * dFortVecX + dFortVecY * dFortVecY);
	return dPointToLineDis;
}

// 创建子弹时，锁定目标时的方向（先不放update里面）
void CBulletNormal::turnBulletDirection(double dVecX, double dVecY)
{
	double dVecLength = sqrt(dVecX * dVecX + dVecY * dVecY);
	double dRadian = asin(dVecY / dVecLength);
	if (dVecX < 0)
	{
		m_dTurnRadian = PI + dRadian;
	}
	else
	{
		m_dTurnRadian = -dRadian;
	}
}
