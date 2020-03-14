#include "Fort.h"
#include "Battle.h"

CFort::CFort()
{

}

CFort::CFort(int fortSide, int nFortID, int nFortLv, CBattle *pBattle)
{
	m_nSide = fortSide;
	m_nID = nFortID;
	m_nLv = nFortLv;
	m_pFortBattle = pBattle;
	m_dPosX = 0;
	m_dPosY = 0;
	fortInitState();
}


CFort::~CFort()
{
}

void CFort::init()
{

}

void CFort::setBattlePoint(CBattle * pBattle)
{
	m_pFortBattle = pBattle;
}

void CFort::update(double dTime)
{
	if (m_isFortBorn) // ���״̬
	{
		m_dFortBornTime -= dTime;
		if (m_dFortBornTime <= 0)
		{
			m_isFortBorn = false;
			m_dFortBornTime = 0;
			// ս��ǳ��¼�
		//	insertFortEvent(EFortEvent::FORT_BORN, 0);
			m_pFortBattle->runFortEventHandler(m_nSide ,EFortEvent::FORT_BORN, m_nID, m_nFortIndex, 0);
		}
		return;
	}
	m_dCountStepTime = m_dCountStepTime + dTime;
	if (m_dCountStepTime >= ONE_STEP_TIME)
	{
		m_dCountStepTime -= ONE_STEP_TIME;
		// ת���״̬  //////////

		if (m_nFortState == EFortState::FORT_FLY)
		{
			justFly(ONE_STEP_TIME);
		}
		else if (m_nFortState == EFortState::FORT_PURSUIT_TARGET)
		{
			flyToTarget(ONE_STEP_TIME);
		}
		else if (m_nFortState == EFortState::FORT_ATTACK)
		{
			//ս���״̬
			//���״̬
			if (m_pLockTarget)   // �����ܻ�����ͨ�����Ҫ����ת��
			{
				turnFortBody(m_pLockTarget->getPosX(), m_pLockTarget->getPosY());
			}
			
			if (m_nFortFireState == EFortAttackState::FORT_FIRE)
			{
				m_dFireTimeCount += ONE_STEP_TIME;
				if (m_dFireTimeCount >= m_dFireInterval)
				{
					// �����Ƿ������

					m_dFireTimeCount -= m_dFireInterval;
					// ����
					//insertFortEvent(EFortEvent::FORT_FIRE_EVENT, 0);

					if (m_isLockShip)   // ���ս��
					{
						CShip* pShip;
						if (m_nSide == EPlayerKind::SELF)
						{
							pShip = m_pFortBattle->getPlayerHost()->getShip();
						}
						else
						{
							pShip = m_pFortBattle->getPlayerSelf()->getShip();
						}
						double dVecLength = sqrt(m_dFortVecX * m_dFortVecX + m_dFortVecY * m_dFortVecY);
						double dFireBeginX = m_dPosX + m_nSizeRadius * m_dFortVecX / dVecLength;
						double dFireBeginY = m_dPosY + m_nSizeRadius * m_dFortVecY / dVecLength;
						if (m_nSide == EPlayerKind::SELF)
						{
							if (m_nFortKind == EFortKinds::FORT_FIGHTSHIP)   // ս��
							{
								m_pFortBattle->getPlayerSelf()->getBulletMgr()->createBullet(m_nBulletID, m_nBulletType, dFireBeginX, dFireBeginY,
									m_nID, m_nFortIndex, m_dAtk);
							}
							else if (m_nFortKind == EFortKinds::FORT_MACHINE)   // սʿ
							{
								pShip->beDamageByFortBullet(m_dAtk);
							}
						}
						else
						{
							if (m_nFortKind == EFortKinds::FORT_FIGHTSHIP)
							{
								m_pFortBattle->getPlayerHost()->getBulletMgr()->createBullet(m_nBulletID, m_nBulletType, dFireBeginX, dFireBeginY,
									m_nID, m_nFortIndex, m_dAtk);
							}
							else
							{
								pShip->beDamageByFortBullet(m_dAtk);
							}
						}
					}
					else // ���ս��
					{
						// ������ڿ�λ���ڴ�
						//turnFortBody(m_pLockTarget->getPosX(), m_pLockTarget->getPosY());
						double dDistance = CTool::countRange(m_dPosX, m_dPosY, m_pLockTarget->getPosX(), m_pLockTarget->getPosY());
						if (dDistance > m_nRange + m_pLockTarget->getSizeRadius())
						{
							m_nFortState = EFortState::FORT_PURSUIT_TARGET;
							m_dFireTimeCount = 0;
						}
						double dVecX = m_pLockTarget->getPosX() - m_dPosX;
						double dVecY = m_pLockTarget->getPosY() - m_dPosY;
						double dVecLength = sqrt(dVecX * dVecX + dVecY * dVecY);
						double dFireBeginX = m_dPosX + m_nSizeRadius * dVecX / dVecLength;
						double dFireBeginY = m_dPosY + m_nSizeRadius * dVecY / dVecLength;
						if (m_nSide == EPlayerKind::SELF)
						{
							if (m_nFortKind == EFortKinds::FORT_FIGHTSHIP)   // ս�����ӵ�
							{
								m_pFortBattle->getPlayerSelf()->getBulletMgr()->createBullet(m_nBulletID, m_nBulletType, dFireBeginX, dFireBeginY,
									m_nID, m_nFortIndex, m_dAtk, m_pLockTarget);
							}
							else if (m_nFortKind == EFortKinds::FORT_MACHINE)
							{
								m_pLockTarget->beHurtByFortBullet(m_dAtk, m_nID, m_nFortIndex, true);
							}
						}
						else if (m_nSide == EPlayerKind::ENEMY)
						{
							if (m_nFortKind == EFortKinds::FORT_FIGHTSHIP)
							{
								m_pFortBattle->getPlayerHost()->getBulletMgr()->createBullet(m_nBulletID, m_nBulletType, dFireBeginX, dFireBeginY,
									m_nID, m_nFortIndex, m_dAtk, m_pLockTarget);
							}
							else if (m_nFortKind == EFortKinds::FORT_MACHINE)
							{
								m_pLockTarget->beHurtByFortBullet(m_dAtk, m_nID, m_nFortIndex, true);
							}
						}
					}
					m_pFortBattle->runFortEventHandler(m_nSide, EFortEvent::FORT_FIRE_EVENT, m_nID, m_nFortIndex, 0);
				}
			}
			else if (m_nFortFireState == EFortAttackState::FORT_SKILLING)  // ����״̬
			{
				m_dSkillTimeCount = m_dSkillTimeCount + ONE_STEP_TIME;
				if (m_dSkillTimeCount >= m_dSkillTime)
				{
					//���ܿ���
					m_dSkillTimeCount = 0;
					m_nFortFireState = EFortAttackState::FORT_FIRE;

				}
			}
		}
		if (m_pLockTarget == nullptr && !m_isLockShip) // û����Ŀ��ʱ��������Χ����̨
		{
			//countInRangeFort();
			searchFort();
			if (m_pLockTarget != nullptr)
			{
				m_nFortState = EFortState::FORT_PURSUIT_TARGET;
				turnFortBody(m_pLockTarget->getPosX(), m_pLockTarget->getPosY());
				// ת���¼�
				//insertFortEvent(EFortEvent::FORT_TURN_BODY, m_dTurnRadian);
				m_pFortBattle->runFortEventHandler(m_nSide, EFortEvent::FORT_TURN_BODY, m_nID, m_nFortIndex, m_dTurnRadian);
			}
			else
			{
				// ���ս��
				countShipDistance();
			}
		}
	}

}

void CFort::setPosition(int nPosX, int nPosY)
{
	m_dPosX = nPosX;
	m_dPosY = nPosY;
}

void CFort::justFly(double dTime)
{
	CShip* pShip;
	if (m_nSide == EPlayerKind::SELF)
	{
		pShip = m_pFortBattle->getPlayerHost()->getShip();
		double dShipLength = pShip->getSizeLength();
		double dShipWidth = pShip->getSizeWidth();
		double dDistance = CTool::countRange(m_dPosX, m_dPosY, pShip->getPosX(), pShip->getPosY());
		if (dDistance >= FLY_TO_SHIP_DIS)
		{
			turnFortBody(pShip->getPosX() - dShipLength * 0.5, m_dPosY);
			m_dPosX = m_dPosX + dTime * m_dSpeed;
			
		}
		else
		{
			if (m_dPosX < pShip->getPosX() - dShipLength * 0.5)  // λ��ս����߽����
			{
				if (m_dPosY > pShip->getPosY() + dShipWidth * 0.5)   //����ս��
				{
					//��ת
					turnFortBody(pShip->getPosX() - dShipLength * 0.5, pShip->getPosY() + dShipWidth * 0.5);
					double dVecLength = sqrt(m_dFortVecX * m_dFortVecX + m_dFortVecY * m_dFortVecY);
					m_dPosX = m_dPosX + dTime * m_dSpeed * (m_dFortVecX / dVecLength);
					m_dPosY = m_dPosY + dTime * m_dSpeed * (m_dFortVecY / dVecLength);
				}
				else if (m_dPosY < pShip->getPosY() - dShipWidth * 0.5) // ����ս��
				{
					//xuanzhuan
					turnFortBody(pShip->getPosX() - dShipLength * 0.5, pShip->getPosY() - dShipWidth * 0.5);
					double dVecLength = sqrt(m_dFortVecX * m_dFortVecX + m_dFortVecY * m_dFortVecY);
					m_dPosX = m_dPosX + dTime * m_dSpeed * (m_dFortVecX / dVecLength);
					m_dPosY = m_dPosY + dTime * m_dSpeed * (m_dFortVecY / dVecLength);
				}
				else                                                   // ս���м�
				{
					turnFortBody(pShip->getPosX() - dShipLength * 0.5, m_dPosY);
					m_dPosX = m_dPosX + dTime * m_dSpeed;
				}
			}
			else if (m_dPosX >= pShip->getPosX() - dShipLength * 0.5)    // λ��ս����߽��ұ�
			{
				if (m_dPosY > pShip->getPosY() + dShipWidth * 0.5)    // ����ս��
				{
					// ��ת
					turnFortBody(m_dPosX, pShip->getPosY() + dShipWidth * 0.5);
					m_dPosY = m_dPosY - dTime * m_dSpeed;
				}
				else if (m_dPosY < pShip->getPosY() - dShipWidth * 0.5)  // ����ս��
				{
					// ��ת
					turnFortBody(m_dPosX, pShip->getPosY() - dShipWidth * 0.5);
					m_dPosY = m_dPosY + dTime * m_dSpeed;
				}
				else													// �м�
				{

				}
			}
		}
	}
	else if (m_nSide == EPlayerKind::ENEMY)            // �з���̨����ҷ�ս��
	{
		pShip = m_pFortBattle->getPlayerSelf()->getShip();
		double dShipLength = pShip->getSizeLength();
		double dShipWidth = pShip->getSizeWidth();
		double dDistance = CTool::countRange(m_dPosX, m_dPosY, pShip->getPosX(), pShip->getPosY());
		if (dDistance >= FLY_TO_SHIP_DIS)
		{
			turnFortBody(pShip->getPosX() - dShipLength * 0.5, m_dPosY);
			m_dPosX = m_dPosX - dTime * m_dSpeed;
		}
		else
		{
			if (m_dPosX > pShip->getPosX() + dShipLength * 0.5)  // λ��ս���ұ߽��ұ�
			{
				if (m_dPosY > pShip->getPosY() + dShipWidth * 0.5)   //����ս��
				{
					//��ת
					turnFortBody(pShip->getPosX() + dShipLength * 0.5, pShip->getPosY() + dShipWidth * 0.5);
					double dVecLength = sqrt(m_dFortVecX * m_dFortVecX + m_dFortVecY * m_dFortVecY);
					m_dPosX = m_dPosX + dTime * m_dSpeed * (m_dFortVecX / dVecLength);
					m_dPosY = m_dPosY + dTime * m_dSpeed * (m_dFortVecY / dVecLength);
				}
				else if (m_dPosY < pShip->getPosY() - dShipWidth * 0.5) // ����ս��
				{
					//xuanzhuan
					turnFortBody(pShip->getPosX() + dShipLength * 0.5, pShip->getPosY() - dShipWidth * 0.5);
					double dVecLength = sqrt(m_dFortVecX * m_dFortVecX + m_dFortVecY * m_dFortVecY);
					m_dPosX = m_dPosX + dTime * m_dSpeed * (m_dFortVecX / dVecLength);
					m_dPosY = m_dPosY + dTime * m_dSpeed * (m_dFortVecY / dVecLength);
				}
				else                                                   // ս���м�
				{
					m_dPosX = m_dPosX - dTime * m_dSpeed;
				}
			}
			else if (m_dPosX >= pShip->getPosX() - dShipLength * 0.5)    // λ��ս���ұ߽����
			{
				if (m_dPosY > pShip->getPosY() + dShipWidth * 0.5)    // ����ս��
				{
					// ��ת
					turnFortBody(m_dPosX, m_dPosY - 10);
					m_dPosY = m_dPosY - dTime * m_dSpeed;
				}
				else if (m_dPosY < pShip->getPosY() - dShipWidth * 0.5)  // ����ս��
				{
					// ��ת
					turnFortBody(m_dPosX, m_dPosY + 10);
					m_dPosY = m_dPosY + dTime * m_dSpeed;
				}
				else												   // �м�
				{

				}
			}
		}
	}
}

void CFort::flyToTarget(double dTime)
{
	//	if (m_pAttackTarget != nullptr)
	//	{
	if (m_pLockTarget)
	{
		turnFortBody(m_pLockTarget->getPosX(), m_pLockTarget->getPosY());
		//����m_dSpeed�ٶ��ƶ�
		//����������ʾ�ƶ�ս���ȼ�������
		double dVecX = m_pLockTarget->getPosX() - this->getPosX();
		double dVecY = m_pLockTarget->getPosY() - this->getPosY();
		//�ɹ��ȶ������
		//б��ֵ
		double dVecXY = sqrt(dVecX * dVecX + dVecY * dVecY);
		double dMoveX = dVecX / dVecXY * (dTime * m_dSpeed);
		double dMoveY = dVecY / dVecXY * (dTime * m_dSpeed);
		//���������з��򣬴˴�����Ҫ�������ƶ����
		m_dPosX = m_dPosX + dMoveX;
		m_dPosY = m_dPosY + dMoveY;

		double dDistance = CTool::countRange(m_dPosX, m_dPosY, m_pLockTarget->getPosX(), m_pLockTarget->getPosY());
		if (dDistance <= m_nRange + m_pLockTarget->getSizeRadius())
		{
			m_nFortState = EFortState::FORT_ATTACK;
			//insertFortEvent(EFortEvent::FORT_ATTACK_READY, 0);
			m_pFortBattle->runFortEventHandler(m_nSide, EFortEvent::FORT_ATTACK_READY, m_nID, m_nFortIndex, 0);
		}
	}
	else
	{
		m_nFortState == EFortState::FORT_FLY;
	}
	//	}
}

void CFort::beHurtByShipBullet(double dInjury)
{
	m_dHp = m_dHp - dInjury;
	//insertFortEvent(EFortEvent::FORT_BE_DAMAGE, dInjury);
	m_pFortBattle->runFortEventHandler(m_nSide, EFortEvent::FORT_BE_DAMAGE, m_nID, m_nFortIndex, dInjury);
	if (m_dHp <= 0)
	{
		fortGoDie();
	}
	m_isBeLockedByShip = true;
}

// ����������ޣ������ǣ��Ƿ���Ҫ��Ӧʱ�䣩
void CFort::beHurtByFortBullet(double dInjury, int nFirerID, int nFirerIndex, bool isTarget)
{
	m_dHp = m_dHp - dInjury;
//	insertFortEvent(EFortEvent::FORT_BE_DAMAGE, dInjury);
	m_pFortBattle->runFortEventHandler(m_nSide, EFortEvent::FORT_BE_DAMAGE, m_nID, m_nFortIndex, dInjury);
	if (m_dHp <= 0)
	{
		fortGoDie();
		return;
	}
	if (isTarget)  // ��Ŀ�귽��������������Ƿ���ӵ�������������
	{
		CFort* pFort;
		if (m_nSide == EPlayerKind::SELF)
		{
			pFort = m_pFortBattle->getPlayerHost()->getFortMgr()->getFortByID(nFirerID, nFirerIndex);
		}
		else if (m_nSide == EPlayerKind::ENEMY)
		{
			pFort = m_pFortBattle->getPlayerSelf()->getFortMgr()->getFortByID(nFirerID, nFirerIndex);
		}
		if (pFort != nullptr)
		{
		/*	if (m_pAttackTarget == nullptr)
			{
				m_pAttackTarget = pFort;
				if (m_pLockTarget == nullptr)
				{
					m_nFortState = EFortState::FORT_PURSUIT_TARGET;
					turnFortBody(pFort->getPosX(), pFort->getPosY());
				}
			}
			*/
			putFortInAttackVec(pFort);
		}
	}
}

void CFort::turnFortBody(double dTargetPosX, double dTargetPosY)
{
	double dVecPosX = dTargetPosX - m_dPosX;
	double dVecPosY = dTargetPosY - m_dPosY;
//	double d1 = m_dFortVecX / m_dFortVecY;
//	double d2 = dVecPosX / dVecPosY;
//	double d3 = d1 - d2;
	if (m_dFortVecY == 0 && dVecPosY == 0)
	{
		m_dFortVecX = dVecPosX;
		if (m_dFortVecX < 0)
		{
			m_dTurnRadian = -PI * 0.5;
		}
		else if (m_dFortVecX > 0)
		{
			m_dTurnRadian = PI * 0.5;
		}
		return;
	}
	if (m_dFortVecX == 0 && dVecPosX == 0)
	{
		m_dFortVecY = dVecPosY;
		if (m_dFortVecY < 0)
		{
			m_dTurnRadian = PI;
		}
		else if (m_dFortVecY > 0)
		{
			m_dTurnRadian = 0;
		}
		return;
	}
	if ( m_dFortVecY != 0 && dVecPosY != 0 && 
		abs(m_dFortVecX / m_dFortVecY - dVecPosX / dVecPosY ) < 0.001 ) //  ��ת�Ƕ�С��0.05��
	{
		return;
	}

	m_dFortVecX = dVecPosX;    // ��¼ս��ķ���
	m_dFortVecY = dVecPosY;
	// ��������
	double dVecLength = sqrt(dVecPosX * dVecPosX + dVecPosY * dVecPosY);
	double dRadian = asin(dVecPosY / dVecLength);
	if (dVecPosX < 0)
	{
		m_dTurnRadian = -PI * 0.5 + dRadian;
	/*	if (dVecPosY > 0)
		{
			m_dTurnRadian =  -PI * 0.5 + dRadian;
		}
		else
		{
			m_dTurnRadian =  -PI * 0.5 - dRadian;
		}
		*/
	}
	else
	{
		m_dTurnRadian = PI * 0.5 - dRadian;
	/*	if (dVecPosY > 0)
		{
			m_dTurnRadian = PI * 0.5 - dRadian;
		}
		else
		{
			m_dTurnRadian = PI * 0.5 + dRadian;
		}
		*/
	}
}

bool CFort::isStillLive()
{
	if (m_dHp >= 0)
	{
		return true;
	}
	else
	{
		return false;
	}
}

void CFort::fortInitState()
{
	m_nFortState = EFortState::FORT_FLY;
	m_nFortFireState = EFortAttackState::FORT_FIRE;
	m_nBulletType = EShootType::BULLET_SHELL;
	m_nFortFireType = 0;
	m_nBuffState = 0;
	m_dEnergy = 0;
	m_dCountStepTime = 0.0;
	m_dFireTimeCount = 0;
	m_dSkillTimeCount = 0.0;
	m_dTurnRadian = 0;
	m_dFortVecX = 0;
	m_dFortVecY = 0;
	m_pLockTarget = nullptr;
	m_pAttackTarget = nullptr;
	m_isFortBorn = true;
	m_isBeLockedByShip = false;
	m_isLockShip = false;
	if (m_nSide == EPlayerKind::SELF)
	{
		m_dTurnRadian = PI * 0.5;
	}
	else
	{
		m_dTurnRadian = -PI * 0.5;
	}
	//string strArmJsonPath = m_pFortBattle->getArmDataPath();
    //int cFortID = m_nID;
	//char cFortID[8];
	//sprintf(cFortID, "%d", m_nID);
	//string strPath = FileUtils::getInstance()->fullPathForFilename(strArmJsonPath);
	//string strData = FileUtils::getInstance()->getStringFromFile(strPath);
	//Document doc;
	//doc.Parse<0>(strData.c_str());
	//if (doc.IsObject())
	//{
	//	rapidjson::Value& vValue = doc[cFortID];//strID.c_str()
	//	if (vValue.IsObject())
		//{
			int nFortType = atoi(CBattle::getArmsConfigDataValueByKey(m_nID, "type"));
			if (nFortType == 0)
			{
				m_nFortKind = EFortKinds::FORT_MACHINE;
			}
			else if (nFortType == 1)
			{
				m_nFortKind = EFortKinds::FORT_FIGHTSHIP;
			}

			m_nSizeRadius = atoi(CBattle::getArmsConfigDataValueByKey(m_nID, "radius"));
			m_nSizeLength = atoi(CBattle::getArmsConfigDataValueByKey(m_nID, "shape_l"));
			m_nSizeWidth = atoi(CBattle::getArmsConfigDataValueByKey(m_nID, "shape_w"));
			m_dInitHp = atof(CBattle::getArmsConfigDataValueByKey(m_nID, "hp"));
			m_dInitAtk = atof(CBattle::getArmsConfigDataValueByKey(m_nID, "atk"));
			m_dInitFireInterval = atof(CBattle::getArmsConfigDataValueByKey(m_nID, "atk_speed"));
			m_nRange = atoi(CBattle::getArmsConfigDataValueByKey(m_nID, "atk_distance"));
			// ·¶Î§ÉËº¦¡°atk_range¡±
			m_dInitSpeed = atof(CBattle::getArmsConfigDataValueByKey(m_nID, "speed"));
			m_nEnergyCost = atoi(CBattle::getArmsConfigDataValueByKey(m_nID, "consume"));
			m_nArmPoint = atoi(CBattle::getArmsConfigDataValueByKey(m_nID, "cost"));
			m_dInitBornTime = atof(CBattle::getArmsConfigDataValueByKey(m_nID, "production_time"));
			m_nBeDestroyEnergy = atoi(CBattle::getArmsConfigDataValueByKey(m_nID, "destruction_reward"));
			m_nBulletSpeed = atoi(CBattle::getArmsConfigDataValueByKey(m_nID, "bullet_speed"));
			// Éý¼¶2¼¶3¼¶µÄÌáÉýÊý¾Ý  ¡£
			// lv2_project     lv2_up       lv3_project       lv3_up

			//	m_dSkillTime = vValue["skill_time"));
		//}
	//}
	m_dHp = m_dInitHp;
	m_dAtk = m_dInitAtk;
	m_dFireInterval = m_dInitFireInterval;
	m_dSpeed = m_dInitSpeed;
	m_dFortBornTime = m_dInitBornTime;
	m_nBulletID = m_nID;
}

void CFort::fortGoDie()
{
	//ս�������¼�
	//fortInitState();
	//insertFortEvent(EFortEvent::FORT_DIE, 0);
	m_pFortBattle->runFortEventHandler(m_nSide, EFortEvent::FORT_DIE, m_nID, m_nFortIndex, 0);
	if (m_nSide == EPlayerKind::SELF)
	{
		m_pFortBattle->getPlayerSelf()->armyCountDown(m_nArmPoint); // ���վ�ӿռ�
		m_pFortBattle->getPlayerHost()->addEnergy(m_nBeDestroyEnergy);
/*		if (m_isBeLockedByShip) // ��ս������
		{
			//ս��Ŀ�����Ƴ�
			m_pFortBattle->getPlayerHost()->getShip()->targetIsBroken(m_nID, m_nFortIndex);
		}
		*/
		CShip *pShip = m_pFortBattle->getPlayerHost()->getShip();
		if (pShip->getLockTarget() && pShip->getLockTarget()->getFortIndex() == m_nFortIndex)
		{
			pShip->targetIsBroken(m_nID, m_nFortIndex);
		}
		// �Լ���ս�����Ŀ��  (��δ���Ƕ�ͷ��)
/*		if (m_pLockTarget)
		{
			m_pLockTarget->attackerIsBroken(m_nID, m_nFortIndex);
		}
		*/
		// �����Լ���ս�������Ŀ��
/*		vector<CFort*>::iterator iter = m_vecAttackTarget.begin();
		for (; iter < m_vecAttackTarget.end(); iter++)
		{
			if ((*iter)->getFortIndex() != m_pLockTarget->getFortIndex())
			{
				(*iter)->targetIsBroken();
			}
		}
		*/
		map<int, CFort*> mapForts = m_pFortBattle->getPlayerHostForts();
		map<int, CFort*>::iterator iter = mapForts.begin();
		for (; iter != mapForts.end(); iter++)
		{

			CFort* pTargetFort = (*iter).second->getLockTarget();
			if (pTargetFort != nullptr)
			{
				if (pTargetFort->getID() == m_nID && pTargetFort->getFortIndex() == m_nFortIndex)
				{
					(*iter).second->targetIsBroken();
				}
			}
		}
		m_pFortBattle->getPlayerHost()->getBulletMgr()->removeBrokenTargetBullet(m_nID, m_nFortIndex);// �Ƴ������Լ����ӵ�
		m_pFortBattle->getPlayerSelf()->getFortMgr()->removeBrokenFort(m_nID, m_nFortIndex);
	}
	else if (m_nSide == EPlayerKind::ENEMY)
	{
		m_pFortBattle->getPlayerHost()->armyCountDown(m_nArmPoint);
		m_pFortBattle->getPlayerSelf()->addEnergy(m_nBeDestroyEnergy);
	/*	if (m_isBeLockedByShip)
		{
			m_pFortBattle->getPlayerSelf()->getShip()->targetIsBroken(m_nID, m_nFortIndex);
		}
		*/
		CShip *pShip = m_pFortBattle->getPlayerSelf()->getShip();
		if (pShip->getLockTarget() && pShip->getLockTarget()->getFortIndex() == m_nFortIndex)
		{
			pShip->targetIsBroken(m_nID, m_nFortIndex);
		}
/*		if (m_pLockTarget)
		{
			m_pLockTarget->attackerIsBroken(m_nID, m_nFortIndex);
		}
		*/

		// �����Լ���ս�������Ŀ��
/*		vector<CFort*>::iterator iter = m_vecAttackTarget.begin();
		for (; iter < m_vecAttackTarget.end(); iter++)
		{
			if ((*iter)->getFortIndex() != m_pLockTarget->getFortIndex())
			{
				(*iter)->targetIsBroken();
			}
		}
		*/
		map<int, CFort*> mapForts = m_pFortBattle->getPlayerSelfForts();
		map<int, CFort*>::iterator iter = mapForts.begin();
		for (; iter != mapForts.end(); iter++)
		{

			CFort* pTargetFort = (*iter).second->getLockTarget();
			if (pTargetFort != nullptr)
			{
				if (pTargetFort->getID() == m_nID && pTargetFort->getFortIndex() == m_nFortIndex)
				{
					(*iter).second->targetIsBroken();
				}
			}
		}
		// �Ƿ��Ƴ� Ŀ��������ս����ӵ�(�ش�:Ҫ��
		m_pFortBattle->getPlayerSelf()->getBulletMgr()->removeBrokenTargetBullet(m_nID, m_nFortIndex);
		m_pFortBattle->getPlayerHost()->getFortMgr()->removeBrokenFort(m_nID, m_nFortIndex);
	}
	

}

// Ŀ��ս��������
void CFort::targetIsBroken()
{
	m_pLockTarget = nullptr;
//	m_pAttackTarget = nullptr;
	m_nFortState = EFortState::FORT_FLY;
	m_dFireTimeCount = 0;

	// �ж�����Ŀ��͹����ߣ� û����ǰλ����ǰ��
	//countInRangeFort();
	//judgeCloseTarget();
	/*
	searchFort();
	if (m_pLockTarget != nullptr)
	{
		turnFortBody(m_pLockTarget->getPosX(), m_pLockTarget->getPosY());
		//	insertFortEvent(EFortEvent::FORT_TURN_BODY, m_dTurnRadian);
		m_pFortBattle->runFortEventHandler(m_nSide, EFortEvent::FORT_TURN_BODY, m_nID, m_nFortIndex, m_dTurnRadian);
		double dDistance = CTool::countRange(m_dPosX, m_dPosY, m_pLockTarget->getPosX(), m_pLockTarget->getPosY());
		if (dDistance > m_nRange)
		{
			m_nFortState = EFortState::FORT_PURSUIT_TARGET;
	
		}
		else
		{
			m_nFortState = EFortState::FORT_ATTACK;
		//	insertFortEvent(EFortEvent::FORT_ATTACK_READY, 0);
			m_pFortBattle->runFortEventHandler(m_nSide, EFortEvent::FORT_ATTACK_READY, m_nID, m_nFortIndex, 0);
		}
	}
	else
	{
		//		if (m_pAttackTarget != nullptr)
		//		{
		//			turnFortBody(m_pAttackTarget->getPosX(), m_pAttackTarget->getPosY());
		//			m_nFortState = EFortState::FORT_PURSUIT_TARGET;
		//		}
		//		else
		//		{
				
		countShipDistance();

		//	}
	}
*/
	// �Ƿ���Ҫ���û����ڣ����ǣ�Ŀ�������󣬶�ÿ�ʼ��һ��Ŀ����


}

//�����߱��ݻ�
void CFort::attackerIsBroken(int nFort, int nFortIndex)
{
	// �ж��Ƿ�͹������ǻ�����
	if (m_pLockTarget->getID() == nFort && m_pLockTarget->getFortIndex() == nFortIndex) //��ս�������Ŀ���ǹ�����
	{
		targetIsBroken();
	}
	else
	{
		if (m_vecAttackTarget.size() > 0)
		{
			vector<CFort*>::iterator iter = m_vecAttackTarget.begin();
			//�Ƴ���������еĹ�����
			for (; iter < m_vecAttackTarget.end(); )
			{
				if (nFort == (*iter)->getID() && nFortIndex == (*iter)->getFortIndex())
				{
					iter = m_vecAttackTarget.erase(iter);
					break;
				}
				else
				{
					iter++;
				}
			}
		}
	}
/*	if (m_vecInRangeForts.size() > 0)
	{
		vector<CFort*>::iterator iter = m_vecInRangeForts.begin();
		for (; iter < m_vecInRangeForts.end(); )
		{
			if (nFort == (*iter)->getID() && nFortIndex == (*iter)->getFortIndex())
			{
				m_vecInRangeForts.erase(iter);
				break;
			}
			else
			{
				iter++;
			}
		}
	}
	*/
}


//���빥��������
void CFort::putFortInAttackVec(CFort * pFort)  
{
	if (pFort->isStillLive())
	{
		return;
	}
	if (m_vecAttackTarget.size() > 0)
	{
		int countFort = 0;
		for (int i = 0; i < m_vecAttackTarget.size(); i++)
		{
			if (m_vecAttackTarget[i]->getID() == pFort->getID() && 
				m_vecAttackTarget[i]->getFortIndex() == pFort->getFortIndex())
			{
				countFort = 1;
				break;
			}
		}
		if (countFort == 0)
		{
			m_vecAttackTarget.insert(m_vecAttackTarget.end(), pFort);
		}
	}
	else
	{
		m_vecAttackTarget.insert(m_vecAttackTarget.end(), pFort);
	}
}

// ��̷�Χ��ս��ѹ�������У��ж���û�غϵ�ս�� ���򲻼������룩����ʱ���ã�
/*
void CFort::inRangeFortInVec(CFort * pFort)
{
	if (m_vecInRangeForts.size() > 0)
	{
		int nHaveFortAlready = 0;
		for (int i = 0; i < m_vecInRangeForts.size(); i++)
		{
			if (m_vecInRangeForts[i]->getID() == pFort->getID() &&
				m_vecInRangeForts[i]->getFortIndex() == pFort->getFortIndex())
			{
				nHaveFortAlready = 1;
				break;
			}
		}
		if (nHaveFortAlready == 0)
		{
			m_vecInRangeForts.insert(m_vecInRangeForts.end(), pFort);
		}
	}
	else
	{
		m_vecInRangeForts.insert(m_vecInRangeForts.end(), pFort);
	}
}
*/

void CFort::countShipDistance()
{
	double dDistance = 0.0;
	CShip* pShip;
	if (m_nSide == EPlayerKind::SELF)
	{
		pShip = m_pFortBattle->getPlayerHost()->getShip();
		double dShipPosX = pShip->getPosX();
		double dShipPosY = pShip->getPosY();
		double dShipLength = pShip->getSizeLength();
		double dShipWidth = pShip->getSizeWidth();
		if (m_dPosX <= dShipPosX - dShipLength * 0.5)
		{
			if (m_dPosY > dShipPosY + dShipWidth * 0.5)
			{
				dDistance = CTool::countRange(m_dPosX, m_dPosY, dShipPosX - dShipLength * 0.5, dShipPosY + dShipWidth * 0.5);
			}
			else if (m_dPosY < dShipPosY - dShipWidth * 0.5)
			{
				dDistance = CTool::countRange(m_dPosX, m_dPosY, dShipPosX - dShipLength * 0.5, dShipPosY - dShipWidth * 0.5);
			}
			else
			{
				dDistance = dShipPosX - dShipLength * 0.5 - m_dPosX;
			}
		}
		else
		{
			if (m_dPosY > dShipPosY + dShipWidth * 0.5)
			{
				dDistance = m_dPosY - (dShipPosY + dShipWidth * 0.5);
			}
			else if (m_dPosY < dShipPosY - dShipWidth * 0.5)
			{
				dDistance = dShipPosY - dShipWidth * 0.5 - m_dPosY;
			}
			else
			{
				dDistance = 0;
			}
		}
	}
	else if (m_nSide == EPlayerKind::ENEMY)
	{
		pShip = m_pFortBattle->getPlayerSelf()->getShip();
		double dShipPosX = pShip->getPosX();
		double dShipPosY = pShip->getPosY();
		double dShipLength = pShip->getSizeLength();
		double dShipWidth = pShip->getSizeWidth();
		if (m_dPosX >= dShipPosX + dShipLength * 0.5)
		{
			if (m_dPosY > dShipPosY + dShipWidth * 0.5)
			{
				dDistance = CTool::countRange(m_dPosX, m_dPosY, dShipPosX + dShipLength * 0.5, dShipPosY + dShipWidth * 0.5);
			}
			else if (m_dPosY < dShipPosY - dShipWidth * 0.5)
			{
				dDistance = CTool::countRange(m_dPosX, m_dPosY, dShipPosX + dShipLength * 0.5, dShipPosY - dShipWidth * 0.5);
			}
			else
			{
				dDistance = m_dPosX - (dShipPosX + dShipLength * 0.5);
			}
		}
		else
		{
			if (m_dPosY > dShipPosY + dShipWidth * 0.5)
			{
				dDistance = m_dPosY - (dShipPosY + dShipWidth * 0.5);
			}
			else if (m_dPosY < dShipPosY - dShipWidth * 0.5)
			{
				dDistance = dShipPosY - dShipWidth * 0.5 - m_dPosY;
			}
			else
			{
				dDistance = 0;
			}
		}
	}
	if (dDistance <= m_nRange)
	{
		m_isLockShip = true;
		m_nFortState = EFortState::FORT_ATTACK;
		// ��ת���巽��
		double dShipPosX = pShip->getPosX();
		double dShipPosY = pShip->getPosY();
		double dShipLength = pShip->getSizeLength();
		double dShipWidth = pShip->getSizeWidth();
		if (m_nSide == EPlayerKind::SELF)
		{
			if (m_dPosX <= dShipPosX - dShipLength * 0.5)
			{
				if (m_dPosY > dShipPosY + dShipWidth * 0.5)
				{
					turnFortBody(dShipPosX - dShipLength * 0.5, dShipPosY + dShipWidth * 0.5);
				}
				else if (m_dPosY < dShipPosY - dShipWidth * 0.5)
				{
					turnFortBody(dShipPosX - dShipLength * 0.5, dShipPosY - dShipWidth * 0.5);
				}
				else
				{
					turnFortBody(dShipPosX - dShipLength * 0.5, m_dPosY);
				}
			}
			else
			{
				if (m_dPosY > dShipPosY + dShipWidth * 0.5)
				{
					turnFortBody(m_dPosX, dShipPosY + dShipWidth * 0.5);
				}
				else if (m_dPosY < dShipPosY - dShipWidth * 0.5)
				{
					turnFortBody(m_dPosX, dShipPosY - dShipWidth * 0.5);
				}
				else
				{

				}
			}
		}
		else if (m_nSide == EPlayerKind::ENEMY)
		{
			if (m_dPosX >= dShipPosX + dShipLength * 0.5)
			{
				if (m_dPosY > dShipPosY + dShipWidth * 0.5)
				{
					turnFortBody(dShipPosX + dShipLength * 0.5, dShipPosY + dShipWidth * 0.5);
				}
				else if (m_dPosY < dShipPosY - dShipWidth * 0.5)
				{
					turnFortBody(dShipPosX + dShipLength * 0.5, dShipPosY - dShipWidth * 0.5);
				}
				else
				{
					turnFortBody(dShipPosX + dShipLength * 0.5, m_dPosY);
				}
			}
			else
			{
				if (m_dPosY > dShipPosY + dShipWidth * 0.5)
				{
					turnFortBody(m_dPosX, dShipPosY + dShipWidth * 0.5);
				}
				else if (m_dPosY < dShipPosY - dShipWidth * 0.5)
				{
					turnFortBody(m_dPosX, dShipPosY - dShipWidth * 0.5);
				}
				else
				{

				}
			}
		}
		m_pFortBattle->runFortEventHandler(m_nSide, EFortEvent::FORT_TURN_BODY, m_nID, m_nFortIndex, m_dTurnRadian);
		//insertFortEvent(EFortEvent::FORT_ATTACK_READY, 0);
		m_pFortBattle->runFortEventHandler(m_nSide, EFortEvent::FORT_ATTACK_READY, m_nID, m_nFortIndex, 0);
	}
}

// ����ս��
void CFort::searchFort()
{
	map<int, CFort*> mapForts;
	if (m_nSide == EPlayerKind::SELF)
	{
		mapForts = m_pFortBattle->getPlayerHostForts();
	}
	else
	{
		mapForts = m_pFortBattle->getPlayerSelfForts();
	}
	map<int, CFort*>::iterator iter = mapForts.begin();
	double dNearerDis = 0.0;
	for (; iter != mapForts.end(); iter++)
	{
		if ((*iter).second->getIsFortBorn()) // �����״̬�²�����
		{
			continue;
		}
		double dDistance = CTool::countRange(m_dPosX, m_dPosY, (*iter).second->getPosX(), (*iter).second->getPosY());
		if (dNearerDis == 0)
		{
			m_pLockTarget = (*iter).second;
			dNearerDis = dDistance;
		}
		else
		{
			if (dNearerDis > dDistance)
			{
				m_pLockTarget = (*iter).second;
				dNearerDis = dDistance;
			}
			else if (dNearerDis == dDistance)       // ������ͬ���ж�Ѫ��
			{
				if (m_pLockTarget->getHp() > (*iter).second->getHp())    //Ѫ���ٵ�ս������
				{
					m_pLockTarget = (*iter).second;
				}
			}
		}
	}
}

void CFort::insertFortEvent(int nEvent, double dEventNumber)
{
	SFortEvent sFortEvent;
	sFortEvent.nEventID = nEvent;
	sFortEvent.dEventNumber = dEventNumber;
	m_vecFortEvent.insert(m_vecFortEvent.end(), sFortEvent);
}

vector<SFortEvent> CFort::getFortEvent()
{
	return m_vecFortEvent;
}

void CFort::clearFortEvent()
{
	m_vecFortEvent.clear();
}

// ͳ�Ʒ�Χ����̨
void CFort::countInRangeFort()
{
	map<int, CFort*> mapForts;
	if (m_nSide == EPlayerKind::SELF)
	{
		mapForts = m_pFortBattle->getPlayerHostForts();
	}
	else if (m_nSide == EPlayerKind::ENEMY)
	{
		mapForts = m_pFortBattle->getPlayerSelfForts();
	}
	double dNearerDis = 0.0;    // ���������ֵ�����ڱȽ�
	map<int, CFort*>::iterator iter = mapForts.begin();
	for (; iter != mapForts.end(); iter++)
	{
		double dDistance = CTool::countRange(m_dPosX, m_dPosY, (*iter).second->getPosX(), (*iter).second->getPosY());
		if (dDistance <= m_nRange)
		{
			//��������
			//inRangeFortInVec((*iter).second);
			if (dNearerDis == 0)
			{
				dNearerDis = dDistance;
				m_pLockTarget = (*iter).second;
			}
	 		else
			{
				if (dNearerDis > dDistance)
				{
					dNearerDis = dDistance;
					m_pLockTarget = (*iter).second;
				}
			}
		}
	}
}

//�ж����Ľ��еĵл�
void CFort::judgeCloseTarget()
{
	if (m_vecAttackTarget.size() > 1)
	{
		double dNearerDis = 0.0;
		for (int i = 0; i < m_vecAttackTarget.size(); i++)
		{
			double dDistance = CTool::countRange(m_dPosX, m_dPosY, m_vecAttackTarget[i]->getPosX(), m_vecAttackTarget[i]->getPosY());
			if (dNearerDis == 0)
			{
				dNearerDis = dDistance;
				m_pAttackTarget = m_vecAttackTarget[i];
			}
			else
			{
				if (dNearerDis > dDistance)
				{
					dNearerDis = dDistance;
					m_pAttackTarget = m_vecAttackTarget[i];
				}
			}
		}
	}
}
