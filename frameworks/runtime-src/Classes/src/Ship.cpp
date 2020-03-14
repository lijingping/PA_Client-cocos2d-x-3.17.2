#include "Ship.h"
#include "Battle.h"
#include "FortMgr.h"

CShip::CShip()
{
	m_nBulletType = EShootType::BULLET_SHELL;
}

CShip::CShip(int nPlayerSide, int nShipID, int nShipLv, CBattle *pBattle)
{
	m_nSide = nPlayerSide;
	m_nID = nShipID;
	m_nLv = nShipLv;
	m_pShipBattle = pBattle;

	m_dEnergy = 0;
	m_dShipFireTime = 0;
	if (m_nSide == EPlayerKind::SELF)
	{
		m_dPosX = SELF_SHIP_POS_X;
		m_dPosY = SHIP_POS_Y;
		m_dBarrelRadian = PI * 0.5;
	}
	else if (m_nSide == EPlayerKind::ENEMY)
	{
		m_dPosX = HOST_SHIP_POS_X;
		m_dPosY = SHIP_POS_Y;
		m_dBarrelRadian = -PI * 0.5;
	}
	m_pLockTarget = nullptr;
	m_nShipFireKind = EShipFireKinds::SINGLE_DAMAGE;
	m_nBulletType = EShootType::BULLET_SHELL;
	m_nShipState = EShipState::NORMAL_STATE;
	m_dShipSkillTime = 0;
	m_nBulletID = m_nID;
	init();
}


CShip::~CShip()
{
	
}

void CShip::init()
{
	loadJsonData();
}

void CShip::loadJsonData()
{
	//string strShipJsonPath = m_pShipBattle->getShipDataPath();
	//char cShipID[8];
	//sprintf(cShipID, "%d", m_nID);
	//string strPath = FileUtils::getInstance()->fullPathForFilename(strShipJsonPath);
	//string strData = FileUtils::getInstance()->getStringFromFile(strPath);
	//Document doc;
	//doc.Parse<0>(strData.c_str());
	//if (doc.IsObject())
	//{
		//rapidjson::Value& vValue = doc[cShipID];//strID.c_str()
		//if (vValue.IsObject())
		//{
			m_nSizeRadius = atoi(CBattle::getShipConfigDataValueByKey(m_nID, "radius"));
			m_nSizeLength = atoi(CBattle::getShipConfigDataValueByKey(m_nID, "shape_l"));
			m_nSizeWidth = atoi(CBattle::getShipConfigDataValueByKey(m_nID, "shape_w"));
			m_dInitHp = atof(CBattle::getShipConfigDataValueByKey(m_nID, "hp"));
			m_dInitAtk = atof(CBattle::getShipConfigDataValueByKey(m_nID, "atk"));
			m_dInitFireInterval = atof(CBattle::getShipConfigDataValueByKey(m_nID, "atk_speed"));
			m_nRange = atoi(CBattle::getShipConfigDataValueByKey(m_nID, "atk_distance"));
			m_nBulletSpeed = atoi(CBattle::getShipConfigDataValueByKey(m_nID, "bullet_speed"));
			// 范围伤害范围值、 移动速度

		//	m_dSkillTime = vValue["skill_time"));
		//}
	//}
	m_dHp = m_dInitHp;
	m_dAtk = m_dInitAtk;
	m_dFireInterval = m_dInitFireInterval;
}

void CShip::update(double dTime)
{
	//多头还是单头？单头：多个目标选最近？
	if (m_nShipFireKind == EShipFireKinds::SINGLE_DAMAGE)// 单头
	{
		if (m_pLockTarget == nullptr)
		{
			// 搜索（单头攻击）普通攻击的对象，不涉及统计在射程范围内的所有敌机。后期有需要在添加
			map<int, CFort*> mapForts;
			if (m_nSide == EPlayerKind::SELF)
			{
				mapForts = m_pShipBattle->getPlayerHostForts();
			}
			else if (m_nSide == EPlayerKind::ENEMY)
			{
				mapForts = m_pShipBattle->getPlayerSelfForts();
			}
			map<int, CFort*>::iterator iter = mapForts.begin();
			int recodeRange = 0;
			for (; iter != mapForts.end(); iter++)
			{
				double dRange = CTool::countRange(m_dPosX, m_dPosY, (*iter).second->getPosX(), (*iter).second->getPosY());
				if (dRange <= m_nRange)
				{
					if (recodeRange == 0)
					{
						recodeRange = dRange;
						m_pLockTarget = (*iter).second;
					}
					else
					{
						if (dRange < recodeRange)
						{
							recodeRange = dRange;
							m_pLockTarget = (*iter).second;
						}
					}
				}
			}
			if (m_pLockTarget != nullptr)
			{
				m_nShipState = EShipState::FIRE_STATE;
				// 旋转事件。
				//turnBarrelDir(m_pLockTarget->getPosX(), m_pLockTarget->getPosY());
				////////
			}
		}
	}
	else if (m_nShipFireKind == EShipFireKinds::DOUBLE_DAMAGE)  // 头多
	{
		// 射程范围内的敌机，全部攻击。同一时间攻击。（待设：攻击最靠近的前两个）
		map<int, CFort*> mapForts;
		if (m_nSide == EPlayerKind::SELF)
		{
			mapForts = m_pShipBattle->getPlayerHostForts();
		}
		else if (m_nSide == EPlayerKind::ENEMY)
		{
			mapForts = m_pShipBattle->getPlayerSelfForts();
		}
		map<int, CFort*>::iterator iter = mapForts.begin();
		for (; iter != mapForts.end(); iter++)
		{
			if (CTool::isInRange(m_dPosX, m_dPosY, (*iter).second->getPosX(), (*iter).second->getPosY(), m_nRange))
			{
				if (m_vecInRangeFort.size() > 0)
				{
					bool isFortIn = false;
					for (int i = 0; i < m_vecInRangeFort.size(); i++)
					{
						if (m_vecInRangeFort[i]->getID() == (*iter).second->getID() && 
							m_vecInRangeFort[i]->getFortIndex() == (*iter).second->getFortIndex())
						{
							isFortIn = true;
							break;
						}
					}
					if (!isFortIn)
					{
						m_vecInRangeFort.insert(m_vecInRangeFort.end(), (*iter).second);
					}
				}
				else
				{
					m_vecInRangeFort.insert(m_vecInRangeFort.end(), (*iter).second);// 塞入vec  容器
				}
			}
		}
	}
	if (m_nShipState == EShipState::FIRE_STATE)
	{
		if (m_nShipFireKind == EShipFireKinds::SINGLE_DAMAGE)
		{
			if (m_pLockTarget)
			{
				if (m_pLockTarget->isStillLive())
				{
					m_dShipFireTime = m_dShipFireTime + dTime;
					//turnBarrelDir(m_pLockTarget->getPosX(), m_pLockTarget->getPosY());
					if (m_dShipFireTime >= m_dFireInterval)
					{
						m_dShipFireTime = m_dShipFireTime - m_dFireInterval;
						//攻击(发射子弹)
						////////////////////
						// 计算子弹方向的向量  (有炮筒的计算）
		/*				double dVecX = m_pLockTarget->getPosX() - m_dPosX;
						double dVecY = m_pLockTarget->getPosY() - m_dPosY;
						double dVecDirection = sqrt(dVecX * dVecX + dVecY * dVecY);
						double dPosX = m_dPosX + SHIP_HALF_WIDTH * dVecX / dVecDirection;
						double dPosY = m_dPosY + SHIP_HALF_WIDTH * dVecY / dVecDirection;
						*/
						if (m_nSide == EPlayerKind::SELF)
						{
							m_pShipBattle->getPlayerSelf()->getBulletMgr()->createShipBullet(m_nID, m_nBulletType, m_dPosX + m_nSizeLength * 0.5, m_dPosY, m_pLockTarget);
						}
						else if (m_nSide == EPlayerKind::ENEMY)
						{
							m_pShipBattle->getPlayerHost()->getBulletMgr()->createShipBullet(m_nID, m_nBulletType, m_dPosX - m_nSizeLength * 0.5, m_dPosY, m_pLockTarget);
						}
					}
				}
			}
		}
		else if (m_nShipFireKind == EShipFireKinds::DOUBLE_DAMAGE)
		{
			if (m_vecInRangeFort.size() > 0)
			{
				m_dShipFireTime = m_dShipFireTime + dTime;
				if (m_dShipFireTime >= m_dFireInterval)
				{
					m_dShipFireTime = m_dShipFireTime - m_dFireInterval;
					for (int i = 0; i < m_vecInRangeFort.size(); i++)
					{
						//m_vecInRangeFort[i]
					}
				}
			}
		}
	}
	else if (m_nShipState = EShipState::SKILLING_STATE)
	{
		m_dShipSkillTime += dTime;
		if (m_dShipSkillTime >= m_dSkillTime)
		{
					//  技能
			m_dShipSkillTime = 0;

		}
	}
}

void CShip::setShipBattle(CBattle * pBattle)
{
	m_pShipBattle = pBattle;
}

void CShip::attackFort()
{
}

void CShip::beDamageByFortBullet(int nInjury)
{
	m_dHp = m_dHp - nInjury;
	if (m_dHp <= 0)
	{
		shipDeath();
	}
}

void CShip::targetIsBroken(int nFortID, int nFortIndex)
{
	if (m_nShipFireKind == EShipFireKinds::SINGLE_DAMAGE)
	{
		m_pLockTarget = nullptr;
		m_nShipState = EShipState::NORMAL_STATE;
	}
	else if (m_nShipFireKind == EShipFireKinds::DOUBLE_DAMAGE)
	{
		vector<CFort*>::iterator iter = m_vecInRangeFort.begin();
		for (; iter != m_vecInRangeFort.end(); )
		{
			if ((*iter)->getID() == nFortID && (*iter)->getFortIndex() == nFortIndex)
			{
				iter = m_vecInRangeFort.erase(iter);
				break;
			}
			else
			{
				iter++;
			}
		}
		if (m_vecInRangeFort.size() <= 0)
		{
			m_nShipState = EShipState::NORMAL_STATE;
		}
	}
	m_dShipFireTime = 0;
}

 // 炮筒转动和跟随
void CShip::turnBarrelDir(double dPosX, double dPosY)
{
	double dVecX = dPosX - m_dPosX;
	double dVecY = dPosY - m_dPosY;
	double dVec = sqrt(dVecX * dVecX + dVecY * dVecY);
	double dRadian = asin(dVecY / dVec);
	if (dVecX < 0)
	{
		m_dBarrelRadian = PI - dRadian;
	}
	else
	{
		m_dBarrelRadian = dRadian;
	}
}

void CShip::shipDeath()
{
	m_pShipBattle->gameOver();
}
