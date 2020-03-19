#include "stdafx.h"
#include "Battle.h"

#include <time.h>

//int CBattle::intMaxTest()
//{
//	Json::Reader reader;
//	Json::Value root;
//	int a = 0;
//
//	ifstream openFile;
//	openFile.open("data/libcode.json", ios::binary);
//	if (reader.parse(openFile, root))
//	{
//		a = root["battle"]["request_skill"]["fort_unenergy"].asInt();
//	}
//	openFile.close();
//	return a;
//}

CBattle::CBattle() //new 的时候回执行构造函数
	: m_updateCount(0)
	, m_nBattleResult(-1)
	, m_dEnergyRefreshTime(0.0)
	, m_isEnergyLive(false)
	, m_nCountUpdateFrame(0)
	, m_nBattleType(0)

	, m_dBattleTime(0.0)
	, m_isBattleRuning(false)
	, m_isBattleStop(false)

	, m_nCountHitBullet(0)
	, m_nEnergyCreateCount(0)
	, m_nRefreshCount(0)
	, m_pEnergyBody(nullptr)
{
	m_arrRefreshTime[10] = { 0 };
	m_nBossID = 0;
	m_nFailerFortNum = 0;
	//int b = intMaxTest();

	//Json::Reader reader;
	//Json::Value root;

	//ifstream openFile;
	//openFile.open("data/libcode.json", ios::binary);
	//if (reader.parse(openFile, root))
	//{
	//	int number1 = root["50001"]["buff"].asInt();
	//	string string1 = root["50001"]["name"].asString();
	//	int number2 = root["50001"]["debuff"].asInt();
	//}
	//openFile.close();
	
}

CBattle::~CBattle()
{
	if (m_pPlayer)
	{
		delete(m_pPlayer);
		m_pPlayer = nullptr;
	}

	if (m_pKeyFrame)
	{
		delete(m_pKeyFrame);
		m_pKeyFrame = nullptr;
	}
	if (m_pPropsMgr)
	{
		delete(m_pPropsMgr);
		m_pPropsMgr = nullptr;
	}

	cleanHitBulletMap();
	
	if (m_nBattleType == 0 )
	{
		if (m_pEnemy)
		{
			delete(m_pEnemy);
			m_pEnemy = nullptr;
		}
		if (m_pEnergyBody)
		{
			delete(m_pEnergyBody);
			m_pEnergyBody = nullptr;
		}
		cleanEnergyEventVec();
	}
	else if (m_nBattleType == 3)
	{
		if (m_pBoss)
		{
			delete(m_pBoss);
			m_pBoss = nullptr;
		}
	}
}


void CBattle::startFight()
{
	m_isBattleRuning = true;
	m_isBattleStop = false;
}

void CBattle::stopFight()
{
	m_isBattleStop = true;
}

void CBattle::resumeFight()
{
	m_isBattleStop = false;
}

void CBattle::update(double delta)
{
	if (m_isBattleRuning && !m_isBattleStop)
	{
		if (m_nBattleType == BattleType::BATTLE_NORMAL)
		{
			m_dBattleTime += delta;
			UpdateTime(delta);
		}
		else if (m_nBattleType == BattleType::BATTLE_BOSS)
		{
			if (!m_pBoss->isInChange() && m_pBoss->getBossStage() != 2)
			{
				m_dBattleTime += delta;
			}
			bossBattleUpdate(delta);
		}
	}
}

void CBattle::initData(int battleType)
{
	m_pKeyFrame = new CKeyFrame(this);

	if (!m_pKeyFrame)
	{
		return;
	}
	m_nBattleType = battleType;

	if (m_nBattleType == BattleType::BATTLE_NORMAL)
	{
		m_pPlayer = new CPlayer();
		m_pEnemy = new CEnemy();

		m_pPlayer->setPlayerBattle(this);
		m_pPlayer->initData(m_strWrongCodePath);

		m_pEnemy->setEnemyBattle(this);
		m_pEnemy->initData(m_strWrongCodePath);

	}
	else if (m_nBattleType == BattleType::BATTLE_BOSS)
	{
		m_pPlayer = new CPlayer();
		m_pPlayer->setPlayerBattle(this);
		m_pPlayer->initData(m_strWrongCodePath);

		m_pBoss = new CBoss(m_sBossDataPath, this, m_nPlayerNumber, m_nBossID);
	}
	m_pPropsMgr = new CPropsMgr(this, m_strPropDataPath, m_strWrongCodePath);

	decodeWrongCodeJsonFileData();
}

void CBattle::setInitFortData(int nPlayer, int nFortPos, int nFortID, int nBulletID, int nFortType, int nFortLevel, int nFortStarDomainCoe, int nSkillLevel)
{
	if (nPlayer == 0) // 我方
	{
		m_pPlayer->getShip()->getFortMgr()->getFortByIndex(nFortPos, false)->setFortData(nFortID, nBulletID, nFortType, nFortLevel, nFortStarDomainCoe, nSkillLevel, m_strSkillDataPath);
	}
	else if (nPlayer == 1) // 敌方
	{
		m_pEnemy->getShip()->getFortMgr()->getFortByIndex(nFortPos, true)->setFortData(nFortID, nBulletID, nFortType, nFortLevel, nFortStarDomainCoe, nSkillLevel, m_strSkillDataPath);
	}
}

void CBattle::setInitShipData(int playerShipID, int playerShipSkillLevel, int p1, int p2, int p3, int enemyShipID, int enemyShipSkillLevel, int e1, int e2, int e3)
{
	m_pPlayer->getShip()->setShipData(m_strShipSkillDataPath, playerShipID, playerShipSkillLevel, p1, p2, p3);
	m_pEnemy->getShip()->setShipData(m_strShipSkillDataPath, enemyShipID, enemyShipSkillLevel, e1, e2, e3);
	cout << "设置 e & p 战舰数据：   成功" << endl;
}

void CBattle::setInitShipData(int playerShipID, int playerShipSkillLevel, int p1, int p2, int p3)
{
	m_pPlayer->getShip()->setShipData(m_strShipSkillDataPath, playerShipID, playerShipSkillLevel, p1, p2, p3);
}

void CBattle::UpdateTime(double delta)
{
	m_nCountUpdateFrame += 1;
//	cleanEnergyEventVec();
//	cleanHitBulletMap();
	m_nCountHitBullet = 0;
	m_pPlayer->update(delta);
	m_pEnemy->update(delta);
	m_pPropsMgr->update(delta);

	if ((m_dEnergyRefreshTime - delta < 0.000001) && (m_dEnergyRefreshTime - delta > -0.000001))
	{
		m_dEnergyRefreshTime = delta;
	}
	m_dEnergyRefreshTime -= delta;

	if (m_dEnergyRefreshTime <= 0)
	{
		m_nRefreshCount++;
		selectRefreshTime();
		if (!m_isEnergyLive)
		{
			// new能量体
			cout << "new energyBody" << endl;
			m_pEnergyBody = new CEnergyBody(m_sEnergyBodyRoad, m_nEnergyCreateCount);
			m_nEnergyCreateCount++;

			if (m_pEnergyBody)
			{
				m_pEnergyBody->setBodyHp((m_pPlayer->getMaxPlayerHp() + m_pEnemy->getMaxEnemyHp()) / 6);
				pushEnergyEventToVec(EnergyEvent::ENERGY_BORN);
				m_isEnergyLive = true;
			}
			else
			{
				cout << "能量体new失败" << endl;
				return;
			}
		}
	}

	map<int, CBullet*> mapPlayerBullet = m_pPlayer->getBulletMgr()->getPlayerBullet();  // 玩家的子弹
	map<int, CBullet*> mapEnemyBullet = m_pEnemy->getBulletMgr()->getEnemyBullet();  // 敌人的子弹
	map<int, CFort*> mapPlayerFort = m_pPlayer->getShip()->getFortMgr()->getPlayerFort(); //玩家的炮台
	map<int, CFort*> mapEnemyFort = m_pEnemy->getShip()->getFortMgr()->getEnemyFort();  // 敌人的炮台

	if (m_isEnergyLive)
	{
		m_pEnergyBody->update(delta);
		if (m_pEnergyBody->isEnergyJump())
		{
			pushEnergyEventToVec( EnergyEvent::ENERGY_JUMP);
		}
		if (m_pEnergyBody->isEnergyChange())
		{
			pushEnergyEventToVec( EnergyEvent::ENERGY_CHANGE);
		}
		//  能量体死亡
		if (!m_pEnergyBody->isEnergyLive())
		{
			// 能量体的buff
			int nFortIndex = 0;

			if (m_pEnergyBody->getBodyPosY() == ENERGY_POS_Y_TOP)
			{
				nFortIndex = 0;
			}
			else if (m_pEnergyBody->getBodyPosY() == ENERGY_POS_Y_MID)
			{
				nFortIndex = 1;
			}
			else if (m_pEnergyBody->getBodyPosY() == ENERGY_POS_Y_BOT)
			{
				nFortIndex = 2;
			}
		
			if (m_pEnergyBody->getWhoWin() == EnergyGetter::PLAYER_OWNER)
			{
				if (m_pEnergyBody->getBodyType() == EnergyType::CURE_ENERGY)
				{
					mapPlayerFort[nFortIndex]->fortRepaireByEnergy(m_pEnergyBody->addHpEnergyBodyBuff());
				}
				else if (m_pEnergyBody->getBodyType() == EnergyType::CHARGE_ENERGY)
				{
					mapPlayerFort[nFortIndex]->addEnergyByEnergy(m_pEnergyBody->addEnergyBuff());
				}
				else if (m_pEnergyBody->getBodyType() == EnergyType::CALL_HELP_ENERGY)
				{
					//  NPC战舰，hert   player的Fort
					              
					double dTotalDamage = 0;
					map<int, CFort*>::iterator enemyIter = mapEnemyFort.begin();
					for (; enemyIter != mapEnemyFort.end(); enemyIter++)
					{
						dTotalDamage += (*enemyIter).second->getFortAck();
					}
					map<int, CFort*>::iterator playerIter = mapPlayerFort.begin();
					for (; playerIter != mapPlayerFort.end(); playerIter++)
					{
						dTotalDamage += (*playerIter).second->getFortAck();
					}
					double dResultDamage = dTotalDamage * m_pEnergyBody->addDamageToFort();

					m_pPropsMgr->energyBodyCallNpc(dResultDamage, 1, 2);
					/*map<int, CFort*>::iterator eIter = mapEnemyFort.begin();
					for (; eIter != mapEnemyFort.end(); eIter++)
					{
						double dDamage = dResultDamage * (1 - (*eIter).second->getUnInjuryCoe());
						if ((*eIter).second->isFortLive())
						{
							(*eIter).second->damageFortByNPC(dDamage);
						}
					}*/
					
				}
			}
			else if (m_pEnergyBody->getWhoWin() == EnergyGetter::ENEMY_OWNER)
			{
				if (m_pEnergyBody->getBodyType() == EnergyType::CURE_ENERGY)
				{
					mapEnemyFort[nFortIndex]->fortRepaireByEnergy(m_pEnergyBody->addHpEnergyBodyBuff());
				}
				else if (m_pEnergyBody->getBodyType() == EnergyType::CHARGE_ENERGY)
				{
					mapEnemyFort[nFortIndex]->addEnergyByEnergy(m_pEnergyBody->addEnergyBuff());
				}
				else if (m_pEnergyBody->getBodyType() == EnergyType::CALL_HELP_ENERGY)
				{
					//NPC战舰 hert enemy 的Fort
					int nTotalDamage = 0;
					map<int, CFort*>::iterator enemyIter = mapEnemyFort.begin();
					for (; enemyIter != mapEnemyFort.end(); enemyIter++)
					{
						nTotalDamage = nTotalDamage + (*enemyIter).second->getFortAck();
					}
					map<int, CFort*>::iterator playerIter = mapPlayerFort.begin();
					for (; playerIter != mapPlayerFort.end(); playerIter++)
					{
						nTotalDamage = nTotalDamage + (*playerIter).second->getFortAck();
					}
					double dResultDamage = nTotalDamage * m_pEnergyBody->addDamageToFort();

					m_pPropsMgr->energyBodyCallNpc(dResultDamage, 2, 1);
					/*map<int, CFort*>::iterator pIter = mapPlayerFort.begin();
					for (; pIter != mapPlayerFort.end(); pIter++)
					{
						double dDamage = nResultDamage * (1 - (*pIter).second->getUnInjuryCoe());
						if ((*pIter).second->isFortLive())
						{
							(*pIter).second->damageFortByNPC(dDamage);
						}
					}*/
				}
			}
			else if (m_pEnergyBody->getWhoWin() == EnergyGetter::NONE_OWNER)
			{

			}
			destroyEnergyBody();
		}
	}


	map<int, CBullet*>::iterator playerBulletIter = mapPlayerBullet.begin();
	for (; playerBulletIter != mapPlayerBullet.end(); playerBulletIter++)
	{
		int pFortIndex = (*playerBulletIter).second->getFortIndex();

		if (m_isEnergyLive && m_pEnergyBody->getBodyPosY() == ENERGY_POS_Y_TOP && pFortIndex == 0 && 
			(*playerBulletIter).second->getBulletPosX() < ENERGY_POS_X )															//- m_pEnergyBody->getBodyWidth() / 2 - BULLET_HALF_WIDTH)
		{
			if ((*playerBulletIter).second->getBulletPosX() >= ENERGY_POS_X - ENERGY_WIDTH / 2 - BULLET_WIDTH / 2 - 25)					//m_pEnergyBody->getBodyWidth() / 2 
			{
				m_pEnergyBody->playerDamage(mapPlayerFort[pFortIndex]->getFortAck());
				mapPlayerFort[pFortIndex]->addEnergyByDamage(mapPlayerFort[pFortIndex]->getFortAck(), 1);
				countHitBulletToDelete((*playerBulletIter).second);
				m_pPlayer->getBulletMgr()->deleteBulletByIndex((*playerBulletIter).second->getBulletIndex());
			}
		}
		else if (m_isEnergyLive && m_pEnergyBody->getBodyPosY() == ENERGY_POS_Y_MID && pFortIndex == 1 &&
			(*playerBulletIter).second->getBulletPosX() < ENERGY_POS_X)																 // - m_pEnergyBody->getBodyWidth() / 2 - BULLET_HALF_WIDTH)
		{
			if ((*playerBulletIter).second->getBulletPosX() >= ENERGY_POS_X - ENERGY_WIDTH / 2 - BULLET_WIDTH / 2 - 25)					 //m_pEnergyBody->getBodyWidth() / 2
			{
				m_pEnergyBody->playerDamage(mapPlayerFort[pFortIndex]->getFortAck());
				mapPlayerFort[pFortIndex]->addEnergyByDamage(mapPlayerFort[pFortIndex]->getFortAck(), 1);
				countHitBulletToDelete((*playerBulletIter).second);
				m_pPlayer->getBulletMgr()->deleteBulletByIndex((*playerBulletIter).second->getBulletIndex());
			}
		}
		else if (m_isEnergyLive && m_pEnergyBody->getBodyPosY() == ENERGY_POS_Y_BOT && pFortIndex == 2 &&
			(*playerBulletIter).second->getBulletPosX() < ENERGY_POS_X)																 // - m_pEnergyBody->getBodyWidth() / 2 - BULLET_HALF_WIDTH)
		{
			if ((*playerBulletIter).second->getBulletPosX() >= ENERGY_POS_X - ENERGY_WIDTH / 2 - BULLET_WIDTH / 2 - 25)					 //m_pEnergyBody->getBodyWidth() / 2
			{
				m_pEnergyBody->playerDamage(mapPlayerFort[pFortIndex]->getFortAck());
				mapPlayerFort[pFortIndex]->addEnergyByDamage(mapPlayerFort[pFortIndex]->getFortAck(), 1);
				countHitBulletToDelete((*playerBulletIter).second);
				m_pPlayer->getBulletMgr()->deleteBulletByIndex((*playerBulletIter).second->getBulletIndex());
			}
		}
		else
		{
			if ((*playerBulletIter).second->getBulletPosX() >= ENEMYSHIP_POS_X - SHIP_HALF_WIDTH - BULLET_WIDTH / 2)   //玩家的炮台射出的子弹是否打到了敌方的战舰。
			{

				if (mapEnemyFort[pFortIndex]->isFortLive())
				{
					if ((*playerBulletIter).second->getBulletPosX() >= ENEMYFORT_POS_X - FORT_WIDTH / 2 - BULLET_WIDTH / 2)
					{
						double dDamage = mapPlayerFort[pFortIndex]->getFortAck() * (1.0 - mapEnemyFort[pFortIndex]->getUnInjuryCoe());
						mapEnemyFort[pFortIndex]->damageFortByBullet(dDamage);
						mapPlayerFort[pFortIndex]->addEnergyByDamage(dDamage, 1);
						countHitBulletToDelete((*playerBulletIter).second);
						m_pPlayer->getBulletMgr()->deleteBulletByIndex((*playerBulletIter).second->getBulletIndex());
					}
				}
				else
				{
					// 攻击剩余活着的炮台 
					int aliveFortCount = 0;
					int bulletDamage = mapPlayerFort[pFortIndex]->getFortAck();

					map<int, CFort*>::iterator eIter = mapEnemyFort.begin();
					for (; eIter != mapEnemyFort.end(); eIter++)
					{
						if ((*eIter).second->getFortIndex() != pFortIndex)
						{
							if ((*eIter).second->isFortLive())
							{
								aliveFortCount++;
							}
						}
					}
					if (aliveFortCount == 0)
					{

					}
					else if (aliveFortCount == 1)
					{

					}
					else if (aliveFortCount == 2)
					{
						bulletDamage = bulletDamage * 0.5;
					}
					map<int, CFort*>::iterator iter = mapEnemyFort.begin();
					for (; iter != mapEnemyFort.end(); iter++)
					{
						if ((*iter).second->getFortIndex() != pFortIndex)
						{
							if ((*iter).second->isFortLive())
							{
								double dDamage = bulletDamage * (1.0 - (*iter).second->getUnInjuryCoe());
								(*iter).second->damageFortByBullet(dDamage);
								mapPlayerFort[pFortIndex]->addEnergyByDamage(dDamage, 1);
							}
						}
					}

					countHitBulletToDelete((*playerBulletIter).second);
					m_pPlayer->getBulletMgr()->deleteBulletByIndex((*playerBulletIter).second->getBulletIndex());
				}
			}
		}
	}

	map<int, CBullet*>::iterator enemyBulletIter = mapEnemyBullet.begin();
	for (; enemyBulletIter != mapEnemyBullet.end(); enemyBulletIter++)
	{
		int eFortIndex = (*enemyBulletIter).second->getFortIndex();
		if (m_isEnergyLive && m_pEnergyBody->getBodyPosY() == ENERGY_POS_Y_TOP && eFortIndex == 0 &&
			(*enemyBulletIter).second->getBulletPosX() > ENERGY_POS_X)																// - m_pEnergyBody->getBodyWidth() / 2 - BULLET_HALF_WIDTH
		{
			if ((*enemyBulletIter).second->getBulletPosX() <= ENERGY_POS_X + ENERGY_WIDTH / 2 + BULLET_WIDTH / 2 + 25)//距离不够（加10）//m_pEnergyBody->getBodyWidth() / 2 
			{
				m_pEnergyBody->enemyDamage(mapEnemyFort[eFortIndex]->getFortAck());
				mapEnemyFort[eFortIndex]->addEnergyByDamage(mapEnemyFort[eFortIndex]->getFortAck(), 1);
				countHitBulletToDelete((*enemyBulletIter).second);
				m_pEnemy->getBulletMgr()->deleteBulletByIndex((*enemyBulletIter).second->getBulletIndex());
			}
		}
		else if (m_isEnergyLive && m_pEnergyBody->getBodyPosY() == ENERGY_POS_Y_MID && eFortIndex == 1 &&
			(*enemyBulletIter).second->getBulletPosX() > ENERGY_POS_X)																// - m_pEnergyBody->getBodyWidth() / 2 - BULLET_HALF_WIDTH
		{
			if ((*enemyBulletIter).second->getBulletPosX() <= ENERGY_POS_X + ENERGY_WIDTH / 2 + BULLET_WIDTH / 2 + 25)					//m_pEnergyBody->getBodyWidth() / 2
			{
				m_pEnergyBody->enemyDamage(mapEnemyFort[eFortIndex]->getFortAck());
				mapEnemyFort[eFortIndex]->addEnergyByDamage(mapEnemyFort[eFortIndex]->getFortAck(), 1);
				countHitBulletToDelete((*enemyBulletIter).second);
				m_pEnemy->getBulletMgr()->deleteBulletByIndex((*enemyBulletIter).second->getBulletIndex());
			}
		}
		else if (m_isEnergyLive && m_pEnergyBody->getBodyPosY() == ENERGY_POS_Y_BOT && eFortIndex == 2 &&
			(*enemyBulletIter).second->getBulletPosX() > ENERGY_POS_X)																// - m_pEnergyBody->getBodyWidth() / 2 - BULLET_HALF_WIDTH
		{
			if ((*enemyBulletIter).second->getBulletPosX() <= ENERGY_POS_X + ENERGY_WIDTH / 2 + BULLET_WIDTH / 2 + 25)					// m_pEnergyBody->getBodyWidth() / 2
			{
				m_pEnergyBody->enemyDamage(mapEnemyFort[eFortIndex]->getFortAck());
				mapEnemyFort[eFortIndex]->addEnergyByDamage(mapEnemyFort[eFortIndex]->getFortAck(), 1);
				countHitBulletToDelete((*enemyBulletIter).second);
				m_pEnemy->getBulletMgr()->deleteBulletByIndex((*enemyBulletIter).second->getBulletIndex());
			}
		}
		else
		{
			if ((*enemyBulletIter).second->getBulletPosX() <= MYSHIP_POS_X + SHIP_HALF_WIDTH + BULLET_WIDTH / 2)
			{

				if (mapPlayerFort[eFortIndex]->isFortLive())
				{
					if ((*enemyBulletIter).second->getBulletPosX() <= MYFORT_POS_X + FORT_WIDTH / 2 + BULLET_WIDTH / 2)
					{
						double dDamage = mapEnemyFort[eFortIndex]->getFortAck() * (1 - mapPlayerFort[eFortIndex]->getUnInjuryCoe());
						mapPlayerFort[eFortIndex]->damageFortByBullet(dDamage);
						mapEnemyFort[eFortIndex]->addEnergyByDamage(dDamage, 1);
						countHitBulletToDelete((*enemyBulletIter).second);
						m_pEnemy->getBulletMgr()->deleteBulletByIndex((*enemyBulletIter).second->getBulletIndex());
					}
				}
				else
				{
					int aliveFortCount = 0;
					map<int, CFort*>::iterator pIter = mapPlayerFort.begin();
					for (; pIter != mapPlayerFort.end(); pIter++)
					{
						if ((*pIter).second->getFortIndex() != eFortIndex)
						{
							if ((*pIter).second->isFortLive())
							{
								aliveFortCount++;
							}
						}
					}
					int bulletDamage = mapEnemyFort[eFortIndex]->getFortAck();
					if (aliveFortCount == 0)
					{

					}
					else if (aliveFortCount == 1)
					{

					}
					else if (aliveFortCount == 2)
					{
						bulletDamage = bulletDamage * 0.5;
					}
					map<int, CFort*>::iterator iter = mapPlayerFort.begin();
					for (; iter != mapPlayerFort.end(); iter++)
					{
						if ((*iter).second->getFortIndex() != eFortIndex)
						{
							if ((*iter).second->isFortLive())
							{
								double dDamage = bulletDamage * (1.0 - (*iter).second->getUnInjuryCoe());
								(*iter).second->damageFortByBullet(dDamage);
								mapEnemyFort[eFortIndex]->addEnergyByDamage(dDamage, 1);
							}
						}
					}

					countHitBulletToDelete((*enemyBulletIter).second);
					m_pEnemy->getBulletMgr()->deleteBulletByIndex((*enemyBulletIter).second->getBulletIndex());
				}
			}
		}
	}
	if (m_pPlayer->getPlayerHp() <= 0) // player lose
	{
		playerLose();
		m_nBattleResult = 1;
		map<int, CFort*>::iterator countLifeIter = mapPlayerFort.begin();
		for (; countLifeIter != mapPlayerFort.end(); countLifeIter++)
		{
			if ((*countLifeIter).second->isFortLive())
			{
				m_nFailerFortNum++;
			}
		}
	}
	if (m_pEnemy->getEnemyHp() <= 0) // player win
	{
		playerWin();
		m_nBattleResult = 0;
		map<int, CFort*>::iterator countLifeIter = mapEnemyFort.begin();
		for (; countLifeIter != mapEnemyFort.end(); countLifeIter++)
		{
			if ((*countLifeIter).second->isFortLive())
			{
				m_nFailerFortNum++;
			}
		}
	}
	if (m_pPlayer->getPlayerHp() <= 0 && m_pEnemy->getEnemyHp() <= 0) // 平局
	{
		m_nBattleResult = 2;
		m_nFailerFortNum = 0;
	}
	if (m_dBattleTime >= 180)
	{
		stopFight();
		if (m_pPlayer->getPlayerHp() > m_pEnemy->getEnemyHp())
		{
			m_nBattleResult = 0;
			map<int, CFort*>::iterator countLifeIter = mapEnemyFort.begin();
			for (; countLifeIter != mapEnemyFort.end(); countLifeIter++)
			{
				if ((*countLifeIter).second->isFortLive())
				{
					m_nFailerFortNum++;
				}
			}
		}
		else if (m_pPlayer->getPlayerHp() < m_pEnemy->getEnemyHp())
		{
			m_nBattleResult = 1;
			map<int, CFort*>::iterator countLifeIter = mapPlayerFort.begin();
			for (; countLifeIter != mapPlayerFort.end(); countLifeIter++)
			{
				if ((*countLifeIter).second->isFortLive())
				{
					m_nFailerFortNum++;
				}
			}
		}
		else if (m_pPlayer->getPlayerHp() == m_pEnemy->getEnemyHp())
		{
			m_nBattleResult = 2;
			m_nFailerFortNum = 0;
		}
	}
	// 测试用的（重设数据）；
	//if (m_nCountUpdateFrame == 600)
	//{
	//	CBattle *pBattle = m_vecBattleFrame[60];
	//	restartGame(m_vecBattleFrame[60]);
	//	const char * a = getCharBattleFrameData();
	//	int b = 0;
	//	b = b + 1;
	//}
	//if (m_nCountUpdateFrame == 100)
	//{
	//	const char * a = getCharBattleFrameData();
	//	//char abc[] = "0-#0-#0-#+0-#0-#0-#+";
	//	//char *st1;
	//	//char *st2;
	//	//st1 = strtok(abc, "+");
	//	//st2 = strtok(NULL, "+");
	//	//setPlayerFortsEvent(st1);
	//	//setEnemyFortsEvent(st2);
	//	int b = 0;
	//	b = b + 1;
	//}
	//if (m_nCountUpdateFrame == 50)
	//{
	//	const char * a = getCharOnlineSynchorFrameData(0);
	//}
}

void CBattle::bossBattleUpdate(double delta)
{
	m_nCountUpdateFrame += 1;
	m_nCountHitBullet = 0;
	m_pPlayer->update(delta);
	m_pBoss->update(delta);
	m_pPropsMgr->update(delta);

	map<int, CFort*> mapPlayerForts = m_pPlayer->getShip()->getFortMgr()->getPlayerFort();
	map<int, CBullet*> mapPlayerBullets = m_pPlayer->getBulletMgr()->getPlayerBullet();
	map<int, CBullet*>::iterator iter = mapPlayerBullets.begin();
	for (; iter != mapPlayerBullets.end(); iter++)
	{
		if ((*iter).second->getBulletPosX() >= ENEMYSHIP_POS_X - SHIP_HALF_WIDTH - BULLET_WIDTH * 0.5)
		{
			int fortIndex = (*iter).second->getFortIndex();
			double damage = mapPlayerForts[fortIndex]->getFortAck();
			m_pBoss->bossBeDamageByBullet(damage);
			mapPlayerForts[fortIndex]->addEnergyByDamage(damage * (1 - m_pBoss->getBossUninjuryRate()), 1);
			countHitBulletToDelete((*iter).second);
			m_pPlayer->getBulletMgr()->deleteBulletByIndex((*iter).second->getBulletIndex());
		}
	}
	if (m_pPlayer->getPlayerHp() <= 0)
	{
		playerLose();
		m_nBattleResult = 1;
	}
}

// 返回 “-1”：未结束；“0”：player win；“1”：enemy win；“2”：平局
int CBattle::getBattleResult() 
{
	return m_nBattleResult;
}

int CBattle::getBattleType()
{
	return m_nBattleType;
}

void CBattle::playerWin()
{
	stopFight();
}

void CBattle::playerLose()
{
	stopFight();
}

void CBattle::cleanEventVec()
{

	cleanHitBulletMap();
	map<int, CFort*> mapPlayerForts = m_pPlayer->getShip()->getFortMgr()->getPlayerFort();
	map<int, CFort*>::iterator iter = mapPlayerForts.begin();
	for (; iter != mapPlayerForts.end(); iter++)
	{
		(*iter).second->cleanFortEventVec();
	}
	m_pPlayer->getBuffMgr()->cleanBuffEventVec();
	if (m_nBattleType != 3)
	{
		map<int, CFort*> mapEnemyForts = m_pEnemy->getShip()->getFortMgr()->getEnemyFort();
		map<int, CFort*>::iterator iter2 = mapEnemyForts.begin();
		for (; iter2 != mapEnemyForts.end(); iter2++)
		{
			(*iter2).second->cleanFortEventVec();
		}
		cleanEnergyEventVec();
		m_pEnemy->getBuffMgr()->cleanBuffEventVec();
	}
	else
	{
		m_pBoss->cleanBossEventVec();
	}
	m_pPropsMgr->cleanPropEvent();
}

void CBattle::cleanEnergyEventVec()
{
	vector<sEnergyBodyEvent*>::iterator iter = m_vecEnergyBodyEvent.begin();
	for (; iter != m_vecEnergyBodyEvent.end(); iter++)
	{
		delete(*iter);
		*iter = nullptr;
	}
	m_vecEnergyBodyEvent.clear();
}

CPlayer * CBattle::getPlayer()
{
	return m_pPlayer;
}

CEnemy * CBattle::getEnemy()
{
	return m_pEnemy;
}

CBoss * CBattle::getBoss()
{
	return m_pBoss;
}

CEnergyBody * CBattle::getEnergyBody()
{
	return m_pEnergyBody;
}

CPropsMgr* CBattle::getPropMgr()
{
	return m_pPropsMgr;
}

bool CBattle::isEnergyBodyLive()
{
	return m_isEnergyLive;
}

//vector<CBattle*> CBattle::getBattleFrameVec()
//{
//	//return m_mapBattleFrame;
//	return m_vecBattleFrame;
//}

int CBattle::getUpdataFrameCount()
{
	return m_nCountUpdateFrame;
}

void CBattle::countHitBulletToDelete(CBullet * pBullet)
{
	sHitBullet* pHitBullet = new sHitBullet();
	if (!pHitBullet)
	{
		return;
	}
	pHitBullet->isEnemy = pBullet->isEnemy();
	pHitBullet->nBulletID = pBullet->getBulletID();
	pHitBullet->nBulletIndex = pBullet->getBulletIndex();
	pHitBullet->x = pBullet->getBulletPosX();
	pHitBullet->y = pBullet->getBulletPosY();
	m_mapHitBullet.insert(map<int, sHitBullet*>::value_type(m_nCountHitBullet, pHitBullet));
	m_nCountHitBullet++;
}

void CBattle::cleanHitBulletMap()
{
	map<int, sHitBullet*>::iterator iter = m_mapHitBullet.begin();
	for (; iter != m_mapHitBullet.end(); iter++)
	{
		delete((*iter).second);
		(*iter).second = nullptr;
	}
	m_mapHitBullet.clear();
}

map<int, sHitBullet*> CBattle::getHitBulletMap()
{
	return m_mapHitBullet;
}

void CBattle::pushEnergyEventToVec(int eventType, bool isProp)
{
	sEnergyBodyEvent* pEnergyEvent = new sEnergyBodyEvent();
	if (!pEnergyEvent)
	{
		return;
	}
	pEnergyEvent->nEventType = eventType;
	pEnergyEvent->nBodyType = m_pEnergyBody->getBodyType();
	pEnergyEvent->nBodyPosX = m_pEnergyBody->getBodyPosX();
	pEnergyEvent->nBodyPosY = m_pEnergyBody->getBodyPosY();
	pEnergyEvent->dBodyHp = m_pEnergyBody->getBodyHp();
    if (isProp)
    {
        pEnergyEvent->dPlayerDamage = 0;
        pEnergyEvent->dEnemyDamage = 0;
    }
    else
    {
        pEnergyEvent->dPlayerDamage = m_pEnergyBody->getPlayerDamage();
        pEnergyEvent->dEnemyDamage = m_pEnergyBody->getEnemyDamage();
    }

	m_vecEnergyBodyEvent.insert(m_vecEnergyBodyEvent.end(), pEnergyEvent);
}

vector<sEnergyBodyEvent*> CBattle::getEnergyBodyEventVec()
{
	return m_vecEnergyBodyEvent;
}

int CBattle::getBattleTime()
{
	if (m_nBattleType != 3)
	{
		return BATTLE_TIME - (int)m_dBattleTime;
	}
	else
	{
		return m_dBattleTime;
	}
}

void CBattle::initEnergyRefreshTimes()
{
	srand((unsigned)time(NULL));
	ostringstream oss;

	for (int i = 0; i < 10; i++)
	{
		m_arrRefreshTime[i] = (rand() % 16) + 15;
		if (i < 9)
		{
			oss << m_arrRefreshTime[i] << ",";
		}
		else
		{
			oss << m_arrRefreshTime[i];
		}
	}

	m_stringEnergyTime = oss.str();
	selectRefreshTime();
}

const char * CBattle::getEnergyTimeString()
{
	return m_stringEnergyTime.c_str();
}

void CBattle::initEnergyBodyRoad()
{
	srand((unsigned)time(NULL));
	ostringstream oss;
	for (int i = 0; i < 10; i++)
	{
		oss << rand() % 3 << "," << rand() % 3 << "," << rand() % 2 << "," << rand() % 2 << "," << rand() % 2 << "," << rand() % 2 << ","
			<< rand() % 2 << "," << rand() % 2 << "," << rand() % 2 << "," << rand() % 2 << "," << rand() % 2 << "," << rand() % 2 << ","
            << rand() % 2 << "," << rand() % 2 << "," << rand() % 2 << "," << rand() % 2 << "#";
	}
	m_sEnergyBodyRoad = oss.str();
	
}

const char * CBattle::getEnergyRoad()
{
	return m_sEnergyBodyRoad.c_str();
}

void CBattle::initBossNpcBuffRoad()
{
	srand((unsigned)time(NULL));
	ostringstream oss;
	for (int i = 0; i < 10; i++)
	{
		oss << rand() % 3 ;
		if (i < 9)
		{
			oss << ",";
		}
	}
	m_sBossNpcBuffRoad = oss.str();

	m_pBoss->splitNpcBuffRoad(m_sBossNpcBuffRoad);
}

const char * CBattle::getBossNpcBuffRoad()
{
	return m_sBossNpcBuffRoad.c_str();
}

void CBattle::setEnergyBodyRoad(string data)
{
	m_sEnergyBodyRoad = data;
}

void CBattle::setEnergyTimeString(string data)
{
	m_stringEnergyTime = data;
	splitEnergyRefreshTime(data);
}

void CBattle::setJsonsPath(string skillDataPath, string propDataPath, string wrongCodePath, string shipSkillDataPath)
{
	m_strSkillDataPath = skillDataPath;
	m_strPropDataPath = propDataPath;
	m_strWrongCodePath = wrongCodePath;
	m_strShipSkillDataPath = shipSkillDataPath;
}

// 设置boss数据文件路径和boss的ID
void CBattle::setBossJsonPathAndID(string bossJsonPath, int bossID)
{
	m_sBossDataPath = bossJsonPath;
	m_nBossID = bossID;
}

int CBattle::fortSkillFire(int nSide, int nFortID, string strBuffPer)
{
	if(nSide == 1)
	{
		return m_pPlayer->getShip()->getFortMgr()->getFortByID(nFortID, false)->fortSkillFireBegin(strBuffPer);
	}
	else //if (nSide == 2)
	{
		return m_pEnemy->getShip()->getFortMgr()->getFortByID(nFortID, true)->fortSkillFireBegin(strBuffPer);
	}
	return 0;
}

const char * CBattle::fortSkillIsAddBuff(int nSide, int nFortID)
{
	if (nSide == 1)
	{
		return m_pPlayer->getShip()->getFortMgr()->getFortByID(nFortID, false)->getIsAddBuff();
	}
	else
	{
		return m_pEnemy->getShip()->getFortMgr()->getFortByID(nFortID, true)->getIsAddBuff();
	}
	return 0;
}

int CBattle::useProp(int nUser, int nPropID, int nTarget, int nFortID)
{
	return m_pPropsMgr->useProp(nUser, nPropID, nTarget, nFortID);
}

int CBattle::useShipSkill(int nUser)
{
	if (nUser == 1)
	{
		return m_pPlayer->useShipSkill();
	}
	else
	{
		return m_pEnemy->useShipSkill();
	}
}

void CBattle::destroyEnergyBody(bool isProp)
{
    if (isProp)
    {
     	pushEnergyEventToVec(EnergyEvent::ENERGY_GO_DIE, true);
    }
    else
    {
        pushEnergyEventToVec(EnergyEvent::ENERGY_GO_DIE);
    }

	m_isEnergyLive = false;

	if (m_pEnergyBody)
	{
		delete(m_pEnergyBody);
		m_pEnergyBody = nullptr;
	}
}

void CBattle::splitEnergyRefreshTime(string data)
{
	char* refreshTime;
	int len = data.length();
	refreshTime = (char*)malloc((len + 1) * sizeof(char));
	data.copy(refreshTime, len, 0);

	sscanf(refreshTime, "%d, %d, %d, %d, %d, %d, %d, %d, %d, %d", &m_arrRefreshTime[0], &m_arrRefreshTime[1], &m_arrRefreshTime[2], &m_arrRefreshTime[3], 
		&m_arrRefreshTime[4], &m_arrRefreshTime[5], &m_arrRefreshTime[6], &m_arrRefreshTime[7],	&m_arrRefreshTime[8], &m_arrRefreshTime[9]); 
	selectRefreshTime(); // 第一次设置energy的数据（重连时该执行语句在前，对于之后的m_dEnergyRefreshTime赋值会覆盖掉，没影响）
}

void CBattle::selectRefreshTime()
{
	m_dEnergyRefreshTime = m_arrRefreshTime[m_nRefreshCount];
}
void CBattle::setKeyFrameData()
{
	m_pKeyFrame->cleanContainerData();

	sBattleInfo pInfo;
	pInfo.dEnergyTime = m_dEnergyRefreshTime;
	pInfo.isEnergyLive = m_isEnergyLive;
	pInfo.nUpdateFrameCount = m_nCountUpdateFrame;
	pInfo.nHitBulletCount = m_nCountHitBullet;
	pInfo.dBattleTime = m_dBattleTime;
	pInfo.isBattleRuning = m_isBattleRuning;
	pInfo.isBattleStop = m_isBattleStop;
	pInfo.nEnergyCreateCount = m_nEnergyCreateCount;
	pInfo.nRefreshCount = m_nRefreshCount;
	m_pKeyFrame->setBattleFrameData(pInfo);

	m_pKeyFrame->setBulletNumber(m_pPlayer->getBulletMgr()->getPlayerBulletCount(), m_pEnemy->getBulletMgr()->getEnemyBulletCount());
	m_pKeyFrame->setHitBulletData(m_mapHitBullet);
	m_pKeyFrame->setEnergyBodyEventData(m_vecEnergyBodyEvent);

	sFortData fortData;
	map<int, CFort*> mapForts = m_pPlayer->getShip()->getFortMgr()->getPlayerFort();
	map<int, CFort*>::iterator pFortIter = mapForts.begin();
	for (; pFortIter != mapForts.end(); pFortIter++)
	{
		fortData.nFortIndex = (*pFortIter).second->getFortIndex();//--
		fortData.nFortID = (*pFortIter).second->getFortID();//--
		fortData.nBulletID = (*pFortIter).second->getFortBulletID();//--
		fortData.nFortType = (*pFortIter).second->getFortType();//--
		fortData.nFortLevel = (*pFortIter).second->getFortLevel();//--
		fortData.dStarDomainCoe = (*pFortIter).second->getStarDomainCoe();//--
		fortData.dQualityCoe = (*pFortIter).second->getQualityCoe();//--
		fortData.dAckGrowCoe = (*pFortIter).second->getAckGrowCoe();//--
		fortData.dHpGrowCoe = (*pFortIter).second->getHpGrowCoe();//--
		fortData.dSpeedCoe = (*pFortIter).second->getSpeedCoe();//--
		fortData.dEnergyCoe = (*pFortIter).second->getEnergyCoe();//--
		fortData.dHp = (*pFortIter).second->getFortHp();
		fortData.dEnergy = (*pFortIter).second->getFortEnergy();
		fortData.dInterval = (*pFortIter).second->getInterval();
		fortData.dUninjuryRate = (*pFortIter).second->getUnInjuryCoe();
		fortData.dAck = (*pFortIter).second->getFortAck();
		fortData.nPosX = (*pFortIter).second->getFortPosX();//--
		fortData.nPosY = (*pFortIter).second->getFortPosY();//--
		fortData.isLife = (*pFortIter).second->isFortLive();
		fortData.dFireTime = (*pFortIter).second->getFireTime();
		fortData.dInitAck = (*pFortIter).second->getInitAck();//--
		fortData.dInitHp = (*pFortIter).second->getFortMaxHp();//--
		fortData.dDefense = (*pFortIter).second->getDefense();//--
		fortData.dInitUninjuryRate = (*pFortIter).second->getInitUnInjuryRate();//--
		fortData.dInitDamage = (*pFortIter).second->getInitDamage();//--
		fortData.isAddPassiveSkill = (*pFortIter).second->isAddPassiveSkill();
		fortData.isParalysis = (*pFortIter).second->isParalysisState();
		fortData.isBurning = (*pFortIter).second->isBurningState();
		fortData.isAckUp = (*pFortIter).second->isAckUpState();

		fortData.isAckDown = (*pFortIter).second->isAckDownState();
		fortData.isRepairing = (*pFortIter).second->isRepairingState();
		fortData.isUnrepaire = (*pFortIter).second->isUnrepaireState();
		fortData.isUnenergy = (*pFortIter).second->isUnEnergyState();
		fortData.isShield = (*pFortIter).second->isShieldState();
		fortData.isRelive = (*pFortIter).second->isReliveState();
		fortData.isSkillFire = (*pFortIter).second->isSkillingState();
		fortData.isBreakArmor = (*pFortIter).second->isBreakArmorState();
		fortData.isFortPassiveSkillStronger = (*pFortIter).second->isPassiveSkillStrongerState();
		fortData.isHavePassiveSkillStronger = (*pFortIter).second->isHavePassiveSkillStronger();
		fortData.dBurningCountTime = (*pFortIter).second->getBurningCountTime();
		fortData.dRepairingCountTime = (*pFortIter).second->getRepairingCountTime();
		fortData.dReliveCountTime = (*pFortIter).second->getReliveCountDown();
		fortData.dReliveHp = (*pFortIter).second->getReliveHp();
		fortData.dAckDownValue = (*pFortIter).second->getAckDownValue();
		fortData.dAckUpValue = (*pFortIter).second->getAckUpValue();
		fortData.dAddPassiveEnergyTime = (*pFortIter).second->getAddPassiveEnergyTime();
		fortData.dMomentAddHp = (*pFortIter).second->getMomentAddHp();//--
		fortData.dSkillAddHp = (*pFortIter).second->getSkillAddHp();//--
		fortData.dPropAddHp = (*pFortIter).second->getPropAddHp();//--
		fortData.dContinueAddHp = (*pFortIter).second->getContinueAddHp();//--
		fortData.dSelfAddEnergy = (*pFortIter).second->getSelfAddEnergy();//--
		fortData.dEnergyAddEnergy = (*pFortIter).second->getEnergyAddEnergy();//--
		fortData.dPropAddEnergy = (*pFortIter).second->getPropAddEnergy();//--
		fortData.dAttackAddEnergy = (*pFortIter).second->getAttackAddEnergy();//--
		fortData.dBeDamageAddEnergy = (*pFortIter).second->getBeDamageAddEnergy();//--
		fortData.dBulletDamage = (*pFortIter).second->getBulletDamage();//--
		fortData.dPropBulletDamage = (*pFortIter).second->getPropBulletDamage();//--
		fortData.dBuffBurnDamage = (*pFortIter).second->getBuffBurnDamage();//--
		fortData.dNPC_Damage = (*pFortIter).second->getNPCDamage();//--
		//fortData.dSecondCountForRelive = (*pFortIter).second->getSecondCountForRelive();
		fortData.dSkillDamage = (*pFortIter).second->getSkillDamage();//--
		fortData.dSkillTime = (*pFortIter).second->getSkillTime();
		fortData.dShipSkillDamage = (*pFortIter).second->getShipSkillDamage();//--
		fortData.dShipSkillAddHp = (*pFortIter).second->getShipSkillAddHp();//--
		fortData.dShipSkillAddEnergy = (*pFortIter).second->getShipSkillAddEnergy();//--
		m_pKeyFrame->setPlayerFortData(fortData, (*pFortIter).second->getFortIndex());
	}

	map<int, CFort*> mapEnemyForts = m_pEnemy->getShip()->getFortMgr()->getEnemyFort();
	map<int, CFort*>::iterator pEnemyIter = mapEnemyForts.begin();
	for (; pEnemyIter != mapEnemyForts.end(); pEnemyIter++)
	{
		fortData.nFortIndex = (*pEnemyIter).second->getFortIndex();
		fortData.nFortID = (*pEnemyIter).second->getFortID();
		fortData.nBulletID = (*pEnemyIter).second->getFortBulletID();
		fortData.nFortType = (*pEnemyIter).second->getFortType();
		fortData.nFortLevel = (*pEnemyIter).second->getFortLevel();
		fortData.dStarDomainCoe = (*pEnemyIter).second->getStarDomainCoe();
		fortData.dQualityCoe = (*pEnemyIter).second->getQualityCoe();
		fortData.dAckGrowCoe = (*pEnemyIter).second->getAckGrowCoe();
		fortData.dHpGrowCoe = (*pEnemyIter).second->getHpGrowCoe();
		fortData.dSpeedCoe = (*pEnemyIter).second->getSpeedCoe();
		fortData.dEnergyCoe = (*pEnemyIter).second->getEnergyCoe();  //--------
		fortData.dHp = (*pEnemyIter).second->getFortHp();
		fortData.dEnergy = (*pEnemyIter).second->getFortEnergy();
		fortData.dInterval = (*pEnemyIter).second->getInterval();
		fortData.dUninjuryRate = (*pEnemyIter).second->getUnInjuryCoe();
		fortData.dAck = (*pEnemyIter).second->getFortAck();
		fortData.nPosX = (*pEnemyIter).second->getFortPosX();
		fortData.nPosY = (*pEnemyIter).second->getFortPosY();
		fortData.isLife = (*pEnemyIter).second->isFortLive();
		fortData.dFireTime = (*pEnemyIter).second->getFireTime();
		fortData.dInitAck = (*pEnemyIter).second->getInitAck();
		fortData.dInitHp = (*pEnemyIter).second->getFortMaxHp();
		fortData.dDefense = (*pEnemyIter).second->getDefense();
		fortData.dInitUninjuryRate = (*pEnemyIter).second->getInitUnInjuryRate();
		fortData.dInitDamage = (*pEnemyIter).second->getInitDamage();
		fortData.isAddPassiveSkill = (*pEnemyIter).second->isAddPassiveSkill();
		fortData.isParalysis = (*pEnemyIter).second->isParalysisState();
		fortData.isBurning = (*pEnemyIter).second->isBurningState();
		fortData.isAckUp = (*pEnemyIter).second->isAckUpState();

		fortData.isAckDown = (*pEnemyIter).second->isAckDownState();
		fortData.isRepairing = (*pEnemyIter).second->isRepairingState();
		fortData.isUnrepaire = (*pEnemyIter).second->isUnrepaireState();
		fortData.isUnenergy = (*pEnemyIter).second->isUnEnergyState();
		fortData.isShield = (*pEnemyIter).second->isShieldState();
		fortData.isRelive = (*pEnemyIter).second->isReliveState();
		fortData.isSkillFire = (*pEnemyIter).second->isSkillingState();
		fortData.isBreakArmor = (*pEnemyIter).second->isBreakArmorState();
		fortData.isFortPassiveSkillStronger = (*pEnemyIter).second->isPassiveSkillStrongerState();
		fortData.isHavePassiveSkillStronger = (*pEnemyIter).second->isHavePassiveSkillStronger();
		fortData.dBurningCountTime = (*pEnemyIter).second->getBurningCountTime();
		fortData.dRepairingCountTime = (*pEnemyIter).second->getRepairingCountTime();
		fortData.dReliveCountTime = (*pEnemyIter).second->getReliveCountDown();
		fortData.dReliveHp = (*pEnemyIter).second->getReliveHp();
		fortData.dAckDownValue = (*pEnemyIter).second->getAckDownValue();
		fortData.dAckUpValue = (*pEnemyIter).second->getAckUpValue();
		fortData.dAddPassiveEnergyTime = (*pEnemyIter).second->getAddPassiveEnergyTime();
		fortData.dMomentAddHp = (*pEnemyIter).second->getMomentAddHp();
		fortData.dSkillAddHp = (*pEnemyIter).second->getSkillAddHp();
		fortData.dPropAddHp = (*pEnemyIter).second->getPropAddHp();
		fortData.dContinueAddHp = (*pEnemyIter).second->getContinueAddHp();
		fortData.dSelfAddEnergy = (*pEnemyIter).second->getSelfAddEnergy();
		fortData.dEnergyAddEnergy = (*pEnemyIter).second->getEnergyAddEnergy();
		fortData.dPropAddEnergy = (*pEnemyIter).second->getPropAddEnergy();
		fortData.dAttackAddEnergy = (*pEnemyIter).second->getAttackAddEnergy();
		fortData.dBeDamageAddEnergy = (*pEnemyIter).second->getBeDamageAddEnergy();
		fortData.dBulletDamage = (*pEnemyIter).second->getBulletDamage();
		fortData.dPropBulletDamage = (*pEnemyIter).second->getPropBulletDamage();
		fortData.dBuffBurnDamage = (*pEnemyIter).second->getBuffBurnDamage();
		fortData.dNPC_Damage = (*pEnemyIter).second->getNPCDamage();
		//fortData.dSecondCountForRelive = (*pEnemyIter).second->getSecondCountForRelive();
		fortData.dSkillDamage = (*pEnemyIter).second->getSkillDamage();
		fortData.dSkillTime = (*pEnemyIter).second->getSkillTime();
		fortData.dShipSkillDamage = (*pEnemyIter).second->getShipSkillDamage();
		fortData.dShipSkillAddHp = (*pEnemyIter).second->getShipSkillAddHp();
		fortData.dShipSkillAddEnergy = (*pEnemyIter).second->getShipSkillAddEnergy();
		m_pKeyFrame->setEnemyFortData(fortData, (*pEnemyIter).second->getFortIndex());
	}
	
	SBulletData bulletData;
	map<int, CBullet*> mapPlayerBullet = m_pPlayer->getBulletMgr()->getPlayerBullet();
	map<int, CBullet*>::iterator pBulletIter = mapPlayerBullet.begin();
	for (; pBulletIter != mapPlayerBullet.end(); pBulletIter++)
	{
		bulletData.isEnemy = (*pBulletIter).second->isEnemy();
		bulletData.nBulletID = (*pBulletIter).second->getBulletID();
		bulletData.nFortIndex = (*pBulletIter).second->getFortIndex();
		bulletData.nBulletIndex = (*pBulletIter).second->getBulletIndex();
		bulletData.dPosX = (*pBulletIter).second->getBulletPosX();
		bulletData.dPosY = (*pBulletIter).second->getBulletPosY();
		bulletData.dTime = (*pBulletIter).second->getCountTime();
		m_pKeyFrame->setPlayerBulletData(bulletData);
	}

	map<int, CBullet*> mapEnemyBullet = m_pEnemy->getBulletMgr()->getEnemyBullet();
	map<int, CBullet*>::iterator eBulletIter = mapEnemyBullet.begin();
	for (; eBulletIter != mapEnemyBullet.end(); eBulletIter++)
	{
		bulletData.isEnemy = (*eBulletIter).second->isEnemy();
		bulletData.nBulletID = (*eBulletIter).second->getBulletID();
		bulletData.nFortIndex = (*eBulletIter).second->getFortIndex();
		bulletData.nBulletIndex = (*eBulletIter).second->getBulletIndex();
		bulletData.dPosX = (*eBulletIter).second->getBulletPosX();
		bulletData.dPosY = (*eBulletIter).second->getBulletPosY();
		bulletData.dTime = (*eBulletIter).second->getCountTime();
		m_pKeyFrame->setEnemyBulletData(bulletData);
	}

	if (m_isEnergyLive)
	{
		SEnergyBodyData energyData;
		energyData.dPlayerDamage = m_pEnergyBody->getPlayerDamage();
		energyData.dEnemyDamage = m_pEnergyBody->getEnemyDamage();
		energyData.dBodyHp = m_pEnergyBody->getBodyHp();
		energyData.dJumpTime = m_pEnergyBody->getJumpTime();
		energyData.dChangeTime = m_pEnergyBody->getChangeTime();
		energyData.nBodyType = m_pEnergyBody->getBodyType();
		energyData.nPosX = m_pEnergyBody->getBodyPosX();
		energyData.nPosY = m_pEnergyBody->getBodyPosY();
		energyData.isJump = m_pEnergyBody->isEnergyJump();
		energyData.isChange = m_pEnergyBody->isEnergyChange();
		energyData.dInitHp = m_pEnergyBody->getBodyMaxHp();
		energyData.nChangeTimeCount = m_pEnergyBody->getBodyChangeTimes();
		energyData.nJumpTimeCount = m_pEnergyBody->getBodyJumpTimes();

		energyData.isEnergyLock = m_pEnergyBody->isEnergyLock();
		m_pKeyFrame->setEnergyBodyData(energyData);
	}
}

// 服务器获取战斗数据接口
const char* CBattle::getCharBattleFrameData(int nPlayerIndex)
{
	setKeyFrameData();
	return m_pKeyFrame->getCharBattleData(nPlayerIndex);
}

const char* CBattle::getCharOnlineSynchorFrameData(int nPlayerIndex)
{
	setKeyFrameData();
	return m_pKeyFrame->getCharOnlineSynchorData(nPlayerIndex);
}

const char * CBattle::getCharBossBattleFrameDataReconnect()
{
	return m_pKeyFrame->getCharBossBattleData();
}

const char * CBattle::getCharBossBattleFrameData()
{
	return m_pKeyFrame->getCharOnlineBossBattleData();
}

string CBattle::getStringBattleFrameData()
{
	return m_pKeyFrame->getStringBattleData();
}



void CBattle::setEnergyRefreshTime(double dEnergyRefreshTime)
{
	m_dEnergyRefreshTime = dEnergyRefreshTime;
}

double CBattle::getEnergyRefreshTime()
{
	return m_dEnergyRefreshTime;
}

void CBattle::resetEnergyLive(bool isLife)
{
	m_isEnergyLive = isLife;
}

//void CBattle::resetUpdateFrame(int nCountFrame)
//{
//	m_nCountUpdateFrame = nCountFrame;
//}

//void CBattle::resetBattleFrameVec(vector<CBattle*> vec)
//{
//	m_vecBattleFrame = vec;
//}

void CBattle::resetCountHitBullet(int nCount)
{
	m_nCountHitBullet = nCount;
}

int CBattle::getCountHitBullet()
{
	return m_nCountHitBullet;
}

void CBattle::resetHitBulletMap(map<int, sHitBullet*> map)
{
	m_mapHitBullet = map;
}


void CBattle::resetBattleTime(double dTime)
{
	m_dBattleTime = dTime;
}

double CBattle::getTime()
{
	return m_dBattleTime;
}

void CBattle::resetBattleRuning(bool isRuning)
{
	m_isBattleRuning = isRuning;
}

bool CBattle::isBattleRuning()
{
	return m_isBattleRuning;
}

void CBattle::resetBattleStop(bool isStop)
{
	m_isBattleStop = isStop;
}

bool CBattle::isBattleStop()
{
	return m_isBattleStop;
}

void CBattle::setAllBattleData(char * data)
{
	if (m_nBattleType == 0)
	{
		setAllNormalBattleData(data);
	}
	else if (m_nBattleType == 3)
	{
		setAllBossBattleData(data);
	}
}

void CBattle::setAllNormalBattleData(char *allBattleData)
{
	char *battleChar;
	char *bulletMgrChar;
	char *playerChar;
	char *enemyChar;
	char *playerFort1, *playerFort2, *playerFort3;
	char *enemyFort1, *enemyFort2, *enemyFort3;
	char *hitBulletChar;
	char *energyBodyEventChar;
	char *playerBulletChar;
	char *enemyBulletChar;
	char *energyBodyChar;
	char *playerBuffChar;
	char *enemyBuffChar;
	char *playerBuffEventChar;
	char *enemyBuffEventChar;
	char *playerFortsEvent;
	char *enemyFortsEvent;

	char *propMgrData;
	char *perPropMapData;
	char *propEventData;

	battleChar = strtok(allBattleData, "+");
	bulletMgrChar = strtok(NULL, "+");
	playerChar = strtok(NULL, "+");
	enemyChar = strtok(NULL, "+");
	playerFort1 = strtok(NULL, "+");
	playerFort2 = strtok(NULL, "+");
	playerFort3 = strtok(NULL, "+");
	enemyFort1 = strtok(NULL, "+");
	enemyFort2 = strtok(NULL, "+");
	enemyFort3 = strtok(NULL, "+");
	hitBulletChar = strtok(NULL, "+");
	energyBodyEventChar = strtok(NULL, "+");
	playerBulletChar = strtok(NULL, "+");
	enemyBulletChar = strtok(NULL, "+");
	energyBodyChar = strtok(NULL, "+");
	playerBuffChar = strtok(NULL, "+");
	enemyBuffChar = strtok(NULL, "+");
	playerBuffEventChar = strtok(NULL, "+");
	enemyBuffEventChar = strtok(NULL, "+");
	playerFortsEvent = strtok(NULL, "+");
	enemyFortsEvent = strtok(NULL, "+");

	propMgrData = strtok(NULL, "+");
	perPropMapData = strtok(NULL, "+");
	propEventData = strtok(NULL, "+");

	setBattleData(battleChar);
	setBulletMgrData(bulletMgrChar);
	setPlayerData(playerChar);
	setEnemyData(enemyChar);
	//setPlayerFortData(playerFort1);

	setPlayerFortData_reconnect(playerFort1, 0, 1);
	setPlayerFortData_reconnect(playerFort2, 1, 1);
	setPlayerFortData_reconnect(playerFort3, 2, 1);
	setPlayerFortData_reconnect(enemyFort1, 0, 2);
	setPlayerFortData_reconnect(enemyFort2, 1, 2);
	setPlayerFortData_reconnect(enemyFort3, 2, 2);
	setHitBulletData(hitBulletChar);
	setEnergyBodyEventData(energyBodyEventChar);
	setPlayerBulletDataReconnect(playerBulletChar);
	setEnemyBulletDataReconnect(enemyBulletChar);
	setEnergyBodyData(energyBodyChar);
	setPlayerBuff(playerBuffChar);
	setEnemyBuff(enemyBuffChar);
	setPlayerBuffEvent(playerBuffEventChar);
	setEnemyBuffEvent(enemyBuffEventChar);
	setPlayerFortsEvent(playerFortsEvent);
	setEnemyFortsEvent(enemyFortsEvent);

	setPropMgrData(propMgrData);
	setPerPropMapData(perPropMapData);  // 同步不做，重連做
	setPropEventData(propEventData);
}

void CBattle::setAllBossBattleData(char * battleData)
{
	char *battleChar;
	char *bulletMgrChar;
	char *playerChar;
	char *playerFort1, *playerFort2, *playerFort3;
	char *hitBulletChar;
	char *playerBulletChar;
	char *playerBuffChar;
	char *playerBuffEventChar;
	char *playerFortsEvent;

	char *propMgrData;
	char *perPropMapData;
	char *propEventData;
	char *bossData;
	char *bossBulletData;
	char *bossEventData;

	battleChar = strtok(battleData, "+");
	bulletMgrChar = strtok(NULL, "+");
	playerChar = strtok(NULL, "+");
	playerFort1 = strtok(NULL, "+");
	playerFort2 = strtok(NULL, "+");
	playerFort3 = strtok(NULL, "+");
	hitBulletChar = strtok(NULL, "+");
	playerBulletChar = strtok(NULL, "+");
	playerBuffChar = strtok(NULL, "+");
	playerBuffEventChar = strtok(NULL, "+");
	playerFortsEvent = strtok(NULL, "+");

	propMgrData = strtok(NULL, "+");
	perPropMapData = strtok(NULL, "+");
	propEventData = strtok(NULL, "+");
	bossData = strtok(NULL, "+");
	bossBulletData = strtok(NULL, "+");
	bossEventData = strtok(NULL, "+");

	setBossBattleData(battleChar);
	setBossBulletMgrData(bulletMgrChar);
	setPlayerData(playerChar);

	setPlayerFortData_reconnect(playerFort1, 0, 1);
	setPlayerFortData_reconnect(playerFort2, 1, 1);
	setPlayerFortData_reconnect(playerFort3, 2, 1);
	setHitBulletData(hitBulletChar);
	setPlayerBulletDataReconnect(playerBulletChar);
	setPlayerBuff(playerBuffChar);
	setPlayerBuffEvent(playerBuffEventChar);
	setPlayerFortsEvent(playerFortsEvent);

	setPropMgrData(propMgrData);
	setPerPropMapData(perPropMapData);  // 同步不做，重連做
	setPropEventData(propEventData);
	setBattleData_BossReconnect(bossData);
	setBossBulletReconnect(bossBulletData);
	setBossEventReconnect(bossEventData);
}

void CBattle::synchronizationData(char * data)
{
	if (m_nBattleType == BattleType::BATTLE_NORMAL)
	{
		onlineSynchordata(data);
	}
	else if (m_nBattleType == BattleType::BATTLE_BOSS)
	{
		synchronizationBossData(data);
	}
}

void CBattle::onlineSynchordata(char * allBattleData)
{
	char *battleChar;
	char *bulletMgrChar;
	char *playerChar;
	char *enemyChar;
	char *playerFort1, *playerFort2, *playerFort3;
	char *enemyFort1, *enemyFort2, *enemyFort3;
	//char *hitBulletChar;
	//char *energyBodyEventChar;
	//char *playerBulletChar;
	//char *enemyBulletChar;
	char *energyBodyChar;
	//char *playerBuffChar;
	//char *enemyBuffChar;
	//char *playerBuffEventChar;
	//char *enemyBuffEventChar;
	//char *playerFortsEvent;
	//char *enemyFortsEvent;

	char *propMgrData;
	//char *perPropMapData;
	//char *propEventData;

	battleChar = strtok(allBattleData, "+");
	bulletMgrChar = strtok(NULL, "+");
	playerChar = strtok(NULL, "+");
	enemyChar = strtok(NULL, "+");
	playerFort1 = strtok(NULL, "+");
	playerFort2 = strtok(NULL, "+");
	playerFort3 = strtok(NULL, "+");
	enemyFort1 = strtok(NULL, "+");
	enemyFort2 = strtok(NULL, "+");
	enemyFort3 = strtok(NULL, "+");
	//hitBulletChar = strtok(NULL, "+");
	//energyBodyEventChar = strtok(NULL, "+");
	//playerBulletChar = strtok(NULL, "+");
	//enemyBulletChar = strtok(NULL, "+");
	energyBodyChar = strtok(NULL, "+");
	//playerBuffChar = strtok(NULL, "+");
	//enemyBuffChar = strtok(NULL, "+");
	//playerBuffEventChar = strtok(NULL, "+");
	//enemyBuffEventChar = strtok(NULL, "+");
	//playerFortsEvent = strtok(NULL, "+");
	//enemyFortsEvent = strtok(NULL, "+");

	propMgrData = strtok(NULL, "+");
	//perPropMapData = strtok(NULL, "+");
	//propEventData = strtok(NULL, "+");

	int nReturn = setBattleSynchordata(battleChar);
	if (nReturn == 0)
	{
		return;
	}
	setBulletMgrData(bulletMgrChar);
	setPlayerData(playerChar);
	setEnemyData(enemyChar);
	setPlayerFortData_synchordata(playerFort1, 0, 1);
	setPlayerFortData_synchordata(playerFort2, 1, 1);
	setPlayerFortData_synchordata(playerFort3, 2, 1);
	setPlayerFortData_synchordata(enemyFort1, 0, 2);
	setPlayerFortData_synchordata(enemyFort2, 1, 2);
	setPlayerFortData_synchordata(enemyFort3, 2, 2);

	setEnergyBodyData(energyBodyChar);

	setPropMgrData(propMgrData);

}

void CBattle::synchronizationBossData(char * bossBattleData)
{
	char *battleChar;
	char *bulletMgrChar;
	char *playerChar;
	char *playerFort1, *playerFort2, *playerFort3;
	char *propMgrData;
	char *bossData;

	battleChar = strtok(bossBattleData, "+");
	bulletMgrChar = strtok(NULL, "+");
	playerChar = strtok(NULL, "+");
	playerFort1 = strtok(NULL, "+");
	playerFort2 = strtok(NULL, "+");
	playerFort3 = strtok(NULL, "+");
	propMgrData = strtok(NULL, "+");
	bossData = strtok(NULL, "+");

	setBossBattleData(battleChar);
	setBossBulletMgrData(bulletMgrChar);
	setPlayerData(playerChar);
	setPlayerFortData_synchordata(playerFort1, 0, 1);
	setPlayerFortData_synchordata(playerFort2, 1, 1);
	setPlayerFortData_synchordata(playerFort3, 2, 1);
	setPropMgrData(propMgrData);
	setBattleData_BossSynchordata(bossData);
}

void CBattle::setBattleData(char * data)
{
	double dEnergyTime = 0;
	int nEnergyLive = 0;
	int nUpdateFrameCount = 0;
	int nHitBulletCount = 0;
	double dBattleTime = 0;
	int nBattleRun = 0;
	int nBattleStop = 0;
	int nEnergyCreateCount = 0;
	int nRefreshCount = 0;
	sscanf(data, "%lf,%d,%d,%d,%lf,%d,%d,%d,%d", &dEnergyTime, &nEnergyLive, &nUpdateFrameCount, &nHitBulletCount, &dBattleTime, &nBattleRun, &nBattleStop, &nEnergyCreateCount,
		&nRefreshCount);
	m_dEnergyRefreshTime = dEnergyTime;
	m_nEnergyCreateCount = nEnergyCreateCount;

	if (nEnergyLive == 0)
	{
		m_isEnergyLive = false;
	}
	else if (nEnergyLive == 1)
	{
		m_isEnergyLive = true;
		if (!m_pEnergyBody)
		{
			m_pEnergyBody = new CEnergyBody(m_sEnergyBodyRoad, m_nEnergyCreateCount);
			if (!m_pEnergyBody)
			{
				return;
			}
			pushEnergyEventToVec(EnergyEvent::ENERGY_BORN);
		}
	}

	m_nCountUpdateFrame = nUpdateFrameCount;
	m_nCountHitBullet = nHitBulletCount;
	m_dBattleTime = dBattleTime;
	if (nBattleRun == 0)
	{
		m_isBattleRuning = false;
	}
	else
	{
		m_isBattleRuning = true;
	}
	if (nBattleStop == 0)
	{
		m_isBattleStop = false;
	}
	else
	{
		m_isBattleStop = true;
	}
	m_nRefreshCount = nRefreshCount;
}

// 返回0为不执行同步操作，等下次同步。情况：服务器已经创建了能量体而客户端还没有创建；服务器没有能量体而客户端能量体还在跑（能量体临界值）。
int CBattle::setBattleSynchordata(char * data)
{
	double dEnergyTime = 0;
	int nEnergyLive = 0;
	int nUpdateFrameCount = 0;
	int nHitBulletCount = 0;
	double dBattleTime = 0;
	int nBattleRun = 0;
	int nBattleStop = 0;
	int nEnergyCreateCount = 0;
	int nRefreshCount = 0;
	sscanf(data, "%lf,%d,%d,%d,%lf,%d,%d,%d,%d", &dEnergyTime, &nEnergyLive, &nUpdateFrameCount, &nHitBulletCount, &dBattleTime, &nBattleRun, &nBattleStop, &nEnergyCreateCount,
		&nRefreshCount);
	if ((m_isEnergyLive == true && nEnergyLive == 0) || (m_isEnergyLive == false && nEnergyLive == 1))
	{
		return 0;
	}
	m_dEnergyRefreshTime = dEnergyTime;
	m_nEnergyCreateCount = nEnergyCreateCount;

	//if (nEnergyLive == 0)
	//{
	//	m_isEnergyLive = false;
	//}
	//else if (nEnergyLive == 1)
	//{
	//	m_isEnergyLive = true;
	//	if (!m_pEnergyBody)
	//	{
	//		m_pEnergyBody = new CEnergyBody(m_sEnergyBodyRoad, m_nEnergyCreateCount);
	//		if (!m_pEnergyBody)
	//		{
	//			return;
	//		}
	//		pushEnergyEventToVec(EnergyEvent::ENERGY_BORN);
	//	}
	//}

	m_nCountUpdateFrame = nUpdateFrameCount;
	m_nCountHitBullet = nHitBulletCount;
	m_dBattleTime = dBattleTime;
	if (nBattleRun == 0)
	{
		m_isBattleRuning = false;
	}
	else
	{
		m_isBattleRuning = true;
	}
	if (nBattleStop == 0)
	{
		m_isBattleStop = false;
	}
	else
	{
		m_isBattleStop = true;
	}
	m_nRefreshCount = nRefreshCount;
	return 1;
}

void CBattle::setBulletMgrData(char * data)
{
	int nPlayerCount = 0;
	int nEnemyCount = 0;
	sscanf(data, "%d,%d", &nPlayerCount, &nEnemyCount);
	m_pPlayer->getBulletMgr()->setPlayerBulletCount(nPlayerCount);
	m_pEnemy->getBulletMgr()->setEnemyBulletCount(nEnemyCount);
}

void CBattle::setPlayerData(char * data)
{
	int nIsPlayerUnmissile = 0;
	int nIsNpcHere = 0;
	double dNpcTime = 0.0;
	int nPlayerShipEnergy = 0;
	double dPlayerPreviousHp = 0.0;
	double dCountDamageHp = 0.0;
	sscanf(data, "%d,%d,%lf,%d,%lf,%lf", &nIsPlayerUnmissile, &nIsNpcHere, &dNpcTime, &nPlayerShipEnergy, &dPlayerPreviousHp, &dCountDamageHp);
	if (nIsPlayerUnmissile == 0)
	{
		m_pPlayer->recoveryUnmisslie();
	}
	else if (nIsPlayerUnmissile == 1)
	{
		m_pPlayer->unmissileState();
	}
	if (nIsNpcHere == 0)
	{
		m_pPlayer->setNpcHereOrNot(false);
	}
	else if (nIsNpcHere == 1)
	{
		m_pPlayer->setNpcHereOrNot(true);
	}
	m_pPlayer->setNpcTime(dNpcTime);

	m_pPlayer->setPlayerShipEnergy(nPlayerShipEnergy);
	m_pPlayer->setPlayerPreviousHp(dPlayerPreviousHp);
	m_pPlayer->setCountDamageHp(dCountDamageHp);
}

void CBattle::setEnemyData(char * data)
{
	int nIsEnemyUnmissile = 0;
	int nIsNpcHere = 0;
	double dNpcTime = 0.0;
	int nEnemyShipEnergy = 0;
	double dEnemyPreviousHp = 0.0;
	double dCountDamageHp = 0.0;
	sscanf(data, "%d,%d,%lf,%d,%lf,%lf", &nIsEnemyUnmissile, &nIsNpcHere, &dNpcTime, &nEnemyShipEnergy, &dEnemyPreviousHp, &dCountDamageHp);
	if (nIsEnemyUnmissile == 0)
	{
		m_pEnemy->recoveryUnmissile();
	}
	else if (nIsEnemyUnmissile == 1)
	{
		m_pEnemy->unmissileState();
	}
	if (nIsNpcHere == 0)
	{
		m_pEnemy->setNpcHereOrNot(false);
	}
	else if (nIsNpcHere == 1)
	{
		m_pEnemy->setNpcHereOrNot(true);
	}
	m_pEnemy->setNpcTime(dNpcTime);
	m_pEnemy->setEnemyShipEnergy(nEnemyShipEnergy);
	m_pEnemy->setEnemyPreviousHp(dEnemyPreviousHp);
	m_pEnemy->setCountDamageHp(dCountDamageHp);
}

//void CBattle::setPlayerFortData(char * data)
//{
//	int nFortIndex = 0;
//	int nFortID = 0;
//	int nBulletID = 0;
//	int nFortType = 0;
//	int nFortLevel = 0;
//	double dStarDomainCoe = 0.0;
//	double dQualityCoe = 0.0;
//	double dAckGrowCoe = 0.0;
//	double dHpGrowCoe = 0.0;
//	double dSpeedCoe = 0.0;
//	double dEnergyCoe = 0.0;
//	double dHp = 0.0;
//	double dEnergy = 0.0;
//	double dInterval = 0.0;
//	double dUninjuryRate = 0.0;
//	double dAck = 0.0;
//	int nPosX = 0;
//	int nPosY = 0;
//	int nLife = 0;
//	double dFireTime = 0.0;
//	double dInitAck = 0.0;
//	double dInitHp = 0.0;
//	double dDefense = 0.0;
//	double dInitUninjuryRate = 0.0;
//	double dInitDamage = 0.0;
//	int nAddPassiveSkill = 0;
//	int nParalysis = 0;
//	int nBurning = 0;
//	int nAckUp = 0;
//
//	int nAckDown = 0;
//	int nRepairing = 0;
//	int nUnrepaire = 0;
//	int nUnenergy = 0;
//	int nShield = 0;
//	int nRelive = 0;
//	int nSkillFire = 0;
//	int nBreakArmor = 0;
//	int nFortPassiveSkillStronger = 0;
//	int nHavePassiveSkillStronger = 0;
//	double dBurningCountTime = 0.0;
//	double dRepairingCountTime = 0.0;
//	double dReliveCountTime = 0.0;
//	double dReliveHp = 0.0;
//	double dAckDownValue = 0.0;
//	double dAckUpValue = 0.0;
//	double dAddPassiveEnergyTime = 0.0;
//	double dMomentAddHp = 0.0;
//	double dSkillAddHp = 0.0;
//	double dPropAddHp = 0.0;
//	double dContinueAddHp = 0.0;
//	double dSelfAddEnergy = 0.0;
//	double dEnergyAddEnergy = 0.0;
//	double dPropAddEnergy = 0.0;
//	double dAttackAddEnergy = 0.0;
//	double dBeDamageAddEnergy = 0.0;
//	double dBulletDamage = 0.0;
//	double dPropBulletDamage = 0.0;
//	double dBuffBurnDamage = 0.0;
//	double dNPC_Damage = 0.0;
//	double dSkillDamage = 0.0;
//	double dSkillTime = 0.0;
//	double dShipSkillDamage = 0.0;
//	double dShipSkillAddHp = 0.0;
//	double dShipSkillAddEnergy = 0.0;
//	
//	sscanf(data, "%d,%d,%d,%d,%d,%lf,%lf,%lf,%lf,%lf,%lf,%lf,%lf,%lf,%lf,%lf,%d,%d,%d,%lf,%lf,%lf,%lf,%lf,%lf,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%lf,%lf,%lf,%lf,%lf,%lf,%lf,%lf,%lf,%lf,%lf,%lf,%lf,%lf,%lf,%lf,%lf,%lf,%lf,%lf,%lf,%lf,%lf,%lf,%lf", 
//		&nFortIndex, &nFortID, &nBulletID, &nFortType, &nFortLevel, &dStarDomainCoe, &dQualityCoe, &dAckGrowCoe, &dHpGrowCoe, &dSpeedCoe, &dEnergyCoe, &dHp, &dEnergy, &dInterval, &dUninjuryRate, &dAck,
//		&nPosX, &nPosY, &nLife, &dFireTime, &dInitAck, &dInitHp, &dDefense, &dInitUninjuryRate, &dInitDamage, &nAddPassiveSkill, &nParalysis, &nBurning, &nAckUp, &nAckDown, &nRepairing, &nUnrepaire, 
//		&nUnenergy, &nShield, &nRelive, &nSkillFire, &nBreakArmor, &nFortPassiveSkillStronger, &nHavePassiveSkillStronger, &dBurningCountTime, &dRepairingCountTime, &dReliveCountTime, &dReliveHp, 
//		&dAckDownValue, &dAckUpValue, &dAddPassiveEnergyTime, &dMomentAddHp, &dSkillAddHp, &dPropAddHp, &dContinueAddHp, &dSelfAddEnergy, &dEnergyAddEnergy, &dPropAddEnergy, &dAttackAddEnergy, 
//		&dBeDamageAddEnergy, &dBulletDamage, &dPropBulletDamage, &dBuffBurnDamage, &dNPC_Damage, &dSkillDamage, &dSkillTime, &dShipSkillDamage, &dShipSkillAddHp, &dShipSkillAddEnergy);
//	CFort *playerFort = m_pPlayer->getShip()->getFortMgr()->getPlayerFort()[nFortIndex];
//	if (!playerFort->isFortLive())
//	{
//		return;
//	}
//	playerFort->setFortID(nFortID);
//	playerFort->setFortBulletID(nBulletID);
//	playerFort->resetFortType(nFortType);
//	playerFort->resetFortLevel(nFortLevel);
//	playerFort->resetFortStarDomainCoe(dStarDomainCoe);
//	playerFort->resetFortQualityCoe(dQualityCoe);
//	playerFort->resetFortAckGrowCoe(dAckGrowCoe);
//	playerFort->resetFortHpGrowCoe(dHpGrowCoe);
//	playerFort->resetFortSpeedCoe(dSpeedCoe);
//	playerFort->resetFortEnergyCoe(dEnergyCoe);
//	playerFort->resetHp(dHp);
//	playerFort->resetEnergy(dEnergy);
//	playerFort->resetFortInterval(dInterval);
//	playerFort->resetUninjuryRate(dUninjuryRate);
//	playerFort->resetFortAck(dAck);
//	playerFort->setFortPos(nPosX, nPosY);
//	if (nLife == 0)
//	{
//		playerFort->resetFortLife(false);
//	}
//	else if (nLife == 1)
//	{
//		playerFort->resetFortLife(true);
//	}
//	playerFort->resetFireTime(dFireTime);
//	playerFort->resetInitAck(dInitAck);
//	playerFort->resetInitHp(dInitHp);
//	playerFort->resetDefense(dDefense);
//	playerFort->resetInitUnInjuryRate(dInitUninjuryRate);
//	playerFort->resetInitDamage(dInitDamage);
//	if (nAddPassiveSkill == 0)
//	{
//		playerFort->resetAddPassiveSkill(false);
//	}
//	else if (nAddPassiveSkill == 1)
//	{
//		playerFort->resetAddPassiveSkill(true);
//	}
//	if (nParalysis == 0)
//	{
//		playerFort->resetFortParalysis(false);
//	}
//	else if (nParalysis == 1)
//	{
//		playerFort->resetFortParalysis(true);
//	}
//	if (nBurning == 0)
//	{
//		playerFort->resetFortBurning(false);
//	}
//	else if (nBurning == 1)
//	{
//		playerFort->resetFortBurning(true);
//	}
//	if (nAckUp == 0)
//	{
//		playerFort->resetAckUp(false);
//	}
//	else if (nAckUp == 1)
//	{
//		playerFort->resetAckUp(true);
//	}
//	if (nAckDown == 0)
//	{
//		playerFort->resetAckDown(false);
//	}
//	else if (nAckDown == 1)
//	{
//		playerFort->resetAckDown(true);
//	}
//	if (nRepairing == 0)
//	{
//		playerFort->resetRepairing(false);
//	}
//	else if (nRepairing == 1)
//	{
//		playerFort->resetRepairing(true);
//	}
//	if (nUnrepaire == 0)
//	{
//		playerFort->resetUnrepaire(false);
//	}
//	else if (nUnrepaire == 1)
//	{
//		playerFort->resetUnrepaire(true);
//	}
//	if (nUnenergy == 0)
//	{
//		playerFort->resetUnEnergy(false);
//	}
//	else if (nUnenergy == 1)
//	{
//		playerFort->resetUnEnergy(true);
//	}
//	if (nShield == 0)
//	{
//		playerFort->resetShield(false);
//	}
//	else if (nShield == 1)
//	{
//		playerFort->resetShield(true);
//	}
//	if (nRelive == 0)
//	{
//		playerFort->resetRelive(false);
//	}
//	else if (nRelive == 1)
//	{
//		playerFort->resetRelive(true);
//	}
//	if (nSkillFire == 0)
//	{
//		playerFort->resetSkillFire(false);
//	}
//	else if (nSkillFire == 1)
//	{
//		playerFort->resetSkillFire(true);
//	}
//	if (nBreakArmor == 0)
//	{
//		playerFort->resetBreakArmor(false);
//	}
//	else if (nBreakArmor == 1)
//	{
//		playerFort->resetBreakArmor(true);
//	}
//	if (nFortPassiveSkillStronger == 0)
//	{
//		playerFort->resetPassiveSkillStronger(false);
//	}
//	else if (nFortPassiveSkillStronger == 1)
//	{
//		playerFort->resetPassiveSkillStronger(true);
//	}
//	if (nHavePassiveSkillStronger == 0)
//	{
//		playerFort->resetHavePassiveSkillStronger(false);
//	}
//	else if (nHavePassiveSkillStronger == 1)
//	{
//		playerFort->resetHavePassiveSkillStronger(true);
//	}
//	playerFort->setBurningCountTime(dBurningCountTime);
//	playerFort->setRepairingCountTime(dRepairingCountTime);
//	playerFort->setReliveCountDown(dReliveCountTime);
//	playerFort->setReliveHp(dReliveHp);
//	playerFort->setAckDownValue(dAckDownValue);
//	playerFort->setAckUpValue(dAckUpValue);
//	playerFort->setAddPassiveEnergyTime(dAddPassiveEnergyTime);
//	playerFort->recoverAddHp(dMomentAddHp);
//	playerFort->recoverSkillAddHp(dSkillAddHp);
//	playerFort->recoverPropAddHp(dPropAddHp);
//	playerFort->recoverContinueAddHp(dContinueAddHp);
//	playerFort->recoverSelfAddEnergy(dSelfAddEnergy);
//	playerFort->recoverEnergyAddEnergy(dEnergyAddEnergy);
//	playerFort->recoverPropAddEnergy(dPropAddEnergy);
//	playerFort->recoverAttackAddEnergy(dAttackAddEnergy);
//	playerFort->recoverBeDamageAddEnergy(dBeDamageAddEnergy);
//	playerFort->recoverBulletDamage(dBulletDamage);
//	playerFort->recoverPropBuleltDamage(dPropBulletDamage);
//	playerFort->recoverBuffBurnDamage(dBuffBurnDamage);
//	playerFort->recoverNPCDamage(dNPC_Damage);
//	playerFort->recoverSkillDamage(dSkillDamage);
//	playerFort->setSkillTime(dSkillTime);
//	playerFort->recoverShipSkillDamage(dShipSkillDamage);
//	playerFort->recoverShipSkillAddHp(dShipSkillAddHp);
//	playerFort->recoverShipSkillAddEnergy(dShipSkillAddEnergy);
//}


void CBattle::setHitBulletData(char * data)
{
	char *dataSize;
	int nVecSize = 0;
	char *dataContent;
	dataSize = strtok(data, "-");
	sscanf(dataSize, "%d", &nVecSize);
	if (nVecSize == 0)
	{
		return;
	}
	dataContent = strtok(NULL, "-");
	char *elementData;
	int nBulletID = 0;
	int nBulletIndex = 0;
	int nEnemy = 0;
	double x = 0.0;
	double y = 0.0;
	elementData = strtok(dataContent, "/");
	int countBullet = 0;
	cleanHitBulletMap();    // 先清除一下容器
	while (elementData != NULL)
	{
		sscanf(elementData, "%d, %d, %d, %lf, %lf", &nBulletID, &nBulletIndex, &nEnemy, &x, &y);
		sHitBullet *pBullet = new sHitBullet();
		if (!pBullet)
		{
			return;
		}
		pBullet->nBulletID = nBulletID;
		pBullet->nBulletIndex = nBulletIndex;
		if (nEnemy == 0)
		{
			pBullet->isEnemy = false;
		}
		else
		{
			pBullet->isEnemy = true;
		}
		pBullet->x = x;
		pBullet->y = y;
		m_mapHitBullet.insert(map<int, sHitBullet*>::value_type(countBullet, pBullet));
		countBullet++;
		elementData = strtok(NULL, "/");
	}
}

void CBattle::setEnergyBodyEventData(char * data)
{
	char *dataSize;
	dataSize = strtok(data, "-");
	int nVecSize = 0;
	sscanf(dataSize, "%d", &nVecSize);
	if (nVecSize == 0)
	{
		return;
	}
	char *dataContent;
	dataContent = strtok(NULL, "-");
	char *elementData;
	int nEventType = 0;
	int nBodyType = 0;
	double dBodyHp = 0.0;
	double dPlayerDamage = 0.0;
	double dEnemyDamage = 0.0;
	int nBodyPosX = 0;
	int nBodyPosY = 0;
	cleanEnergyEventVec();
	elementData = strtok(dataContent, "/");
	while (elementData != NULL)
	{
		sscanf(elementData, "%d, %d, %lf, %lf, %lf, %d, %d", &nEventType, &nBodyType, &dBodyHp, &dPlayerDamage, &dEnemyDamage, &nBodyPosX, &nBodyPosY);
		sEnergyBodyEvent *pData = new sEnergyBodyEvent();
		if (!pData)
		{
			return;
		}
		pData->nEventType = nEventType;
		pData->nBodyType = nBodyType;
		pData->dBodyHp = dBodyHp;
		pData->dPlayerDamage = dPlayerDamage;
		pData->dEnemyDamage = dEnemyDamage;
		pData->nBodyPosX = nBodyPosX;
		pData->nBodyPosY = nBodyPosY;
		m_vecEnergyBodyEvent.insert(m_vecEnergyBodyEvent.end(), pData);
		elementData = strtok(NULL, "/");
	}
}

void CBattle::setPlayerBulletDataReconnect(char * data)
{
	char *dataSize;
	int nVecSize = 0;
	dataSize = strtok(data, "-");
	sscanf(dataSize, "%d", &nVecSize);
	if (nVecSize == 0)
	{
		return;
	}
	char *dataContent;
	dataContent = strtok(NULL, "-");
	char *elementData;
	int nIsEnemy = 0;
	int nBulletID = 0;
	int nFortIndex = 0;
	int nBulletIndex = 0;
	double dPosX = 0.0;
	double dPosY = 0.0;
	double dTime = 0.0;
	m_pPlayer->getBulletMgr()->cleanUpPlayerBulletMap();
	map<int, CBullet*> mapPlayerBullet = m_pPlayer->getBulletMgr()->getPlayerBullet();
	elementData = strtok(dataContent, "/");
	while (elementData != NULL)
	{
		sscanf(elementData, "%d, %d, %d, %d, %lf, %lf, %lf", &nIsEnemy, &nBulletID, &nFortIndex, &nBulletIndex, &dPosX, &dPosY, &dTime);
		//map<int, CBullet*>::iterator iter = mapPlayerBullet.begin();
		//for (; iter != mapPlayerBullet.end(); iter++)
		//{
		//	if ((*iter).second->getBulletIndex() == nBulletIndex)
		//	{
		//		if ((*iter).second->getBulletPosX() < dPosX)
		//		{
		//			(*iter).second->setPosX(dPosX);
		//		}

		//		//(*iter).second->setPosY(dPosY);
		//	}
		//}
		CBullet* pBullet;
		if (nIsEnemy == 0)
		{
			/*if (m_pPlayer->getBulletMgr()->getPlayerBullet()[nBulletIndex])
			{
				pBullet = m_pPlayer->getBulletMgr()->getPlayerBullet()[nBulletIndex];
				pBullet->setPosX(dPosX);
				pBullet->setPosY(dPosY);
				pBullet->resetTime(dTime);
			}
			else
			{*/
				pBullet = new CBullet();
				if (!pBullet)
				{
					return;
				}
				pBullet->resetBulletOwner(nIsEnemy);
				pBullet->resetBulletID(nBulletID);
				pBullet->resetFortIndex(nFortIndex);
				pBullet->resetBulletIndex(nBulletIndex);
				pBullet->setPosX(dPosX);
				pBullet->setPosY(dPosY);
				pBullet->resetTime(dTime);
				m_pPlayer->getBulletMgr()->resetPlayerBullet(pBullet, nBulletIndex);
			//}
		}
		elementData = strtok(NULL, "/");
	}
}

void CBattle::setEnemyBulletDataReconnect(char * data)
{
	char *dataSize;
	int nVecSize = 0;
	dataSize = strtok(data, "-");
	sscanf(dataSize, "%d", &nVecSize);
	if (nVecSize == 0)
	{
		return;
	}
	char *dataContent;
	dataContent = strtok(NULL, "-");
	char *elementData;
	int nIsEnemy = 0;
	int nBulletID = 0;
	int nFortIndex = 0;
	int nBulletIndex = 0;
	double dPosX = 0.0;
	double dPosY = 0.0;
	double dTime = 0.0;
	m_pEnemy->getBulletMgr()->cleanUpEnemyBulletMap();
	map<int, CBullet*> mapEnemyBullet = m_pEnemy->getBulletMgr()->getEnemyBullet();
	elementData = strtok(dataContent, "/");
	while (elementData != NULL)
	{
		sscanf(elementData, "%d, %d, %d, %d, %lf, %lf, %lf", &nIsEnemy, &nBulletID, &nFortIndex, &nBulletIndex, &dPosX, &dPosY, &dTime);
		//map<int, CBullet*>::iterator iter = mapEnemyBullet.begin();
		//for (; iter != mapEnemyBullet.end(); iter++)
		//{
		//	if ((*iter).second->getBulletIndex() == nBulletIndex)
		//	{
		//		(*iter).second->setPosX(dPosX);
		//		(*iter).second->setPosY(dPosY); 
		//	}
		//}
		CBullet* pBullet;
		if (nIsEnemy == 1)
		{
			/*if (m_pEnemy->getBulletMgr()->getEnemyBullet()[nBulletIndex])
			{
				pBullet = m_pEnemy->getBulletMgr()->getEnemyBullet()[nBulletIndex];
				pBullet->setPosX(dPosX);
				pBullet->setPosY(dPosY);
				pBullet->resetTime(dTime);
			}
			else
			{*/
				pBullet = new CBullet();
				if (!pBullet)
				{
					return;
				}
				pBullet->resetBulletOwner(nIsEnemy);
				pBullet->resetBulletID(nBulletID);
				pBullet->resetFortIndex(nFortIndex);
				pBullet->resetBulletIndex(nBulletIndex);
				pBullet->setPosX(dPosX);
				pBullet->setPosY(dPosY);
				pBullet->resetTime(dTime);
				m_pEnemy->getBulletMgr()->resetEnemyBullet(pBullet, nBulletIndex);
			//}
		}
		elementData = strtok(NULL, "/");
	}
}

void CBattle::setEnergyBodyData(char * data)
{
	char *dataSize;
	int nVecSize = 0;
	dataSize = strtok(data, "-");
	sscanf(dataSize, "%d", &nVecSize);
	if (nVecSize == 0 || !m_pEnergyBody)
	{
		return;
	}

	char *dataContent;
	dataContent = strtok(NULL, "-");
	double dPlayerDamage = 0.0;
	double dEnemyDamage = 0.0;
	double dBodyHp = 0.0;
	double dJumpTime = 0.0;
	double dChangeTime = 0.0;
	int nBodyType = 0;
	int nPosX = 0;
	int nPosY = 0;
	int nIsJump = 0;
	int nIsChange = 0;
	double dInitHp = 0;
	int nChangeTimes = 0;
	int nJumpTimes = 0;
	int nIsEnergyLock = 0;
	sscanf(dataContent, "%lf, %lf, %lf, %lf, %lf, %d, %d, %d, %d, %d, %lf, %d, %d, %d", &dPlayerDamage, &dEnemyDamage, &dBodyHp, &dJumpTime, &dChangeTime,
		&nBodyType, &nPosX, &nPosY, &nIsJump, &nIsChange, &dInitHp, &nChangeTimes, &nJumpTimes, &nIsEnergyLock);
	m_pEnergyBody->resetPlayerDamage(dPlayerDamage);
	m_pEnergyBody->resetEnemyDamage(dEnemyDamage);
	m_pEnergyBody->resetBodyHp(dBodyHp);
	m_pEnergyBody->resetJumpTime(dJumpTime);
	m_pEnergyBody->resetChangeTime(dChangeTime);
	m_pEnergyBody->resetBodyType(nBodyType);
	m_pEnergyBody->resetBodyPosX(nPosX);
	m_pEnergyBody->resetBodyPosY(nPosY);
	m_pEnergyBody->setIsEnergyJump(nIsJump);
	m_pEnergyBody->setIsEnergyChange(nIsChange);
	m_pEnergyBody->resetInitBodyHp(dInitHp);
	m_pEnergyBody->setBodyChangeTimes(nChangeTimes);
	m_pEnergyBody->setBodyJumpTimes(nJumpTimes);
	m_pEnergyBody->setEnergyLock(nIsEnergyLock);
}

void CBattle::setPlayerBuff(char * data)
{
	char *dataSize;
	int nVecSize = 0;
	dataSize = strtok(data, "-");
	sscanf(dataSize, "%d", &nVecSize);
	if (nVecSize == 0)
	{
		return;
	}
	m_pPlayer->getBuffMgr()->cleanBuffEventVec();
	m_pPlayer->getBuffMgr()->cleanPlayerBuffMap();
	char *dataContent;
	dataContent = strtok(NULL, "-");
	char *elementData;
	double dBuffTime = 0.0;
	int nBuffID = 0;
	int nFortID = 0;
	int nBuffIndex = 0;
	double dBuffValue = 0.0;
	elementData = strtok(dataContent, "/");
	while (elementData != NULL)
	{
		sscanf(elementData, "%lf, %d, %d, %d, %lf", &dBuffTime, &nBuffID, &nFortID, &nBuffIndex, &dBuffValue);
		m_pPlayer->getBuffMgr()->setBuffIndex(nBuffIndex);
		m_pPlayer->getBuffMgr()->addBuff(nBuffID, nFortID, dBuffValue, dBuffTime);
		elementData = strtok(NULL, "/");
	}
}

void CBattle::setEnemyBuff(char * data)
{
	char *dataSize;
	int nVecSize = 0;
	dataSize = strtok(data, "-");
	sscanf(dataSize, "%d", &nVecSize);
	if (nVecSize == 0)
	{
		return;
	}
	m_pEnemy->getBuffMgr()->cleanBuffEventVec();
	m_pEnemy->getBuffMgr()->cleanEnmeyBuffMap();
	char *dataContent;
	dataContent = strtok(NULL, "-");
	char *elementData;
	double dBuffTime = 0.0;
	int nBuffID = 0;
	int nFortID = 0;
	int nBuffIndex = 0;
	double dBuffValue = 0.0;
	elementData = strtok(dataContent, "/");
	while (elementData != NULL)
	{
		sscanf(elementData, "%lf, %d, %d, %d, %lf", &dBuffTime, &nBuffID, &nFortID, &nBuffIndex, &dBuffValue);
		m_pEnemy->getBuffMgr()->setBuffIndex(nBuffIndex);
		m_pEnemy->getBuffMgr()->addBuff(nBuffID, nFortID, dBuffValue, dBuffTime);
		elementData = strtok(NULL, "/");
	}
}

void CBattle::setPlayerBuffEvent(char * data)
{
	char *dataSize;
	int nVecSize = 0;
	dataSize = strtok(data, "-");
	sscanf(dataSize, "%d", &nVecSize);
	if (nVecSize == 0)
	{
		return;
	}
	char *dataContent;
	dataContent = strtok(NULL, "-");
	char *elementData;
	int nBuffFort = 0.0;
	int nBuffID = 0;
	elementData = strtok(dataContent, "/");
	vector<sBuffEvent> playerBuffEvent = m_pPlayer->getBuffMgr()->getPlayerBuffEvent();
	while (elementData != NULL)
	{
		sscanf(elementData, "%d, %d", &nBuffFort, &nBuffID);
		m_pPlayer->getBuffMgr()->insertBuffEventToVec(nBuffFort, nBuffID);
		elementData = strtok(NULL, "/");
	}
}

void CBattle::setEnemyBuffEvent(char * data)
{
	char *dataSize;
	int nVecSize = 0;
	dataSize = strtok(data, "-");
	sscanf(dataSize, "%d", &nVecSize);
	if (nVecSize == 0)
	{
		return;
	}
	char *dataContent;
	dataContent = strtok(NULL, "-");
	char *elementData;
	int nBuffFort = 0.0;
	int nBuffID = 0;
	elementData = strtok(dataContent, "/");
	while (elementData != NULL)
	{
		sscanf(elementData, "%d, %d", &nBuffFort, &nBuffID);
		m_pEnemy->getBuffMgr()->insertBuffEventToVec(nBuffFort, nBuffID);
		elementData = strtok(NULL, "/");
	}
}
//1 - 3/ # 2 - 4/5/ # 1 - 2/ # +
void CBattle::setPlayerFortsEvent(char * data)
{
	map<int, CFort*> mapPlayerForts = m_pPlayer->getShip()->getFortMgr()->getPlayerFort();
	char *firstVecData;
	char *secondVecData;
	char *thirdVecData;

	firstVecData = strtok(data, "#");
	secondVecData = strtok(data, "#");
	thirdVecData = strtok(data, "#");
	if (firstVecData != NULL)
	{		
		char *vecSize;
		int nVecSize = 0;
		vecSize = strtok(firstVecData, "-");
		sscanf(vecSize, "%d", &nVecSize);
		if (nVecSize > 0)
		{
			mapPlayerForts[0]->cleanFortEventVec();
			char *dataContent;
			dataContent = strtok(NULL, "-");
			int nData = 0;
			char *elementData;
			elementData = strtok(dataContent, "/");
			while (elementData != NULL)
			{
				sscanf(elementData, "%d", &nData);
				mapPlayerForts[0]->resetFortEventVec(nData);
				elementData = strtok(NULL, "/");
			}
		}
	}
	if (secondVecData != NULL)
	{
		char *vecSize;
		int nVecSize = 0;
		vecSize = strtok(secondVecData, "-");
		sscanf(vecSize, "%d", &nVecSize);
		if (nVecSize > 0)
		{
			mapPlayerForts[1]->cleanFortEventVec();
			char *dataContent;
			dataContent = strtok(NULL, "-");
			int nData = 0;
			char *elementData;
			elementData = strtok(dataContent, "/");
			vector<int> vecEventFort1 = mapPlayerForts[1]->getFortEventVec();
			while (elementData != NULL)
			{
				sscanf(elementData, "%d", &nData);
				vecEventFort1.insert(vecEventFort1.end(), nData);
				elementData = strtok(NULL, "/");
			}
		}
	}
	if (thirdVecData != NULL)
	{
		char *vecSize;
		int nVecSize = 0;
		vecSize = strtok(thirdVecData, "-");
		sscanf(vecSize, "%d", &nVecSize);
		if (nVecSize > 0)
		{
			mapPlayerForts[2]->cleanFortEventVec();
			char *dataContent;
			dataContent = strtok(NULL, "-");
			int nData = 0;
			char *elementData;
			elementData = strtok(dataContent, "/");
			vector<int> vecEventFort2 = mapPlayerForts[2]->getFortEventVec();
			while (elementData != NULL)
			{
				sscanf(elementData, "%d", &nData);
				vecEventFort2.insert(vecEventFort2.end(), nData);
				elementData = strtok(NULL, "/");
			}
		}
	}
}

void CBattle::setEnemyFortsEvent(char * data)
{
	map<int, CFort*> mapEnemyForts = m_pEnemy->getShip()->getFortMgr()->getEnemyFort();
	char *firstVecData;
	char *secondVecData;
	char *thirdVecData;

	firstVecData = strtok(data, "#");
	secondVecData = strtok(data, "#");
	thirdVecData = strtok(data, "#");
	if (firstVecData != NULL)
	{
		char *vecSize;
		int nVecSize = 0;
		vecSize = strtok(firstVecData, "-");
		sscanf(vecSize, "%d", &nVecSize);
		if (nVecSize > 0)
		{
			mapEnemyForts[0]->cleanFortEventVec();
			char *dataContent;
			dataContent = strtok(NULL, "-");
			int nData = 0;
			char *elementData;
			elementData = strtok(dataContent, "/");
			vector<int> vecEventFort0 = mapEnemyForts[0]->getFortEventVec();
			while (elementData != NULL)
			{
				sscanf(elementData, "%d", &nData);
				vecEventFort0.insert(vecEventFort0.end(), nData);
				elementData = strtok(NULL, "/");
			}
		}
	}
	if (secondVecData != NULL)
	{
		char *vecSize;
		int nVecSize = 0;
		vecSize = strtok(secondVecData, "-");
		sscanf(vecSize, "%d", &nVecSize);
		if (nVecSize > 0)
		{
			mapEnemyForts[1]->cleanFortEventVec();
			char *dataContent;
			dataContent = strtok(NULL, "-");
			int nData = 0;
			char *elementData;
			elementData = strtok(dataContent, "/");
			vector<int> vecEventFort1 = mapEnemyForts[1]->getFortEventVec();
			while (elementData != NULL)
			{
				sscanf(elementData, "%d", &nData);
				vecEventFort1.insert(vecEventFort1.end(), nData);
				elementData = strtok(NULL, "/");
			}
		}
	}
	if (thirdVecData != NULL)
	{
		char *vecSize;
		int nVecSize = 0;
		vecSize = strtok(thirdVecData, "-");
		sscanf(vecSize, "%d", &nVecSize);
		if (nVecSize > 0)
		{
			mapEnemyForts[2]->cleanFortEventVec();
			char *dataContent;
			dataContent = strtok(NULL, "-");
			int nData = 0;
			char *elementData;
			elementData = strtok(dataContent, "/");
			vector<int> vecEventFort2 = mapEnemyForts[2]->getFortEventVec();
			while (elementData != NULL)
			{
				sscanf(elementData, "%d", &nData);
				vecEventFort2.insert(vecEventFort2.end(), nData);
				elementData = strtok(NULL, "/");
			}
		}
	}
}

void CBattle::setPropMgrData(char * data)
{
	int nPropCount = 0;
	int nIsPlayerNpcSecond = 0;
	int nIsEnemyNpcSecond = 0;
	int nPlayerPropNpc = 0;
	int nEnemyPropNpc = 0;
	double dPlayerDamage = 0.0;
	double dEnemyDamage = 0.0;
	sscanf(data, "%d,%d,%d,%d,%d,%lf,%lf", &nPropCount, &nIsPlayerNpcSecond, &nIsEnemyNpcSecond, &nPlayerPropNpc, &nEnemyPropNpc, &dPlayerDamage, &dEnemyDamage);
	m_pPropsMgr->setPropsCount(nPropCount);
	m_pPropsMgr->setPlayerNpcSecond(nIsPlayerNpcSecond);
	m_pPropsMgr->setEnemyNpcSecond(nIsEnemyNpcSecond);
	m_pPropsMgr->setPlayerPropNpc(nPlayerPropNpc);
	m_pPropsMgr->setEnemyPropNpc(nEnemyPropNpc);
	m_pPropsMgr->setPlayerDamage(dPlayerDamage);
	m_pPropsMgr->setEnemyDamage(dEnemyDamage);
}

void CBattle::setPerPropMapData(char * data)
{
	char *dataSize;
	int nVecSize = 0;
	dataSize = strtok(data, "-");
	sscanf(dataSize, "%d", &nVecSize);
	if (nVecSize <= 0)
	{
		return;
	}
	char *dataContent;
	dataContent = strtok(NULL, "-");
	char *elementData;
	int nMapFirst = 0;
	int nPropID = 0;
	double dPropBurstTime = 0.0;
	int nUser = 0;
	int nTargetSide = 0;
	int nTargetFortID = 0;
	double dEnergyNpcDamage = 0.0;
	m_pPropsMgr->cleanPropMap();
	elementData = strtok(dataContent, "/");
	while (elementData != NULL)
	{
		sscanf(elementData, "%d,%d,%lf,%d,%d,%d,%lf", &nMapFirst, &nPropID, &dPropBurstTime, &nUser, &nTargetSide, &nTargetFortID, &dEnergyNpcDamage);
		m_pPropsMgr->usePropForReconnect(nMapFirst, nPropID, dPropBurstTime, nUser, nTargetSide, nTargetFortID, dEnergyNpcDamage);
		elementData = strtok(NULL, "/");
	}
}

void CBattle::setPropEventData(char * data)
{
	char *dataSize;
	int nVecSize = 0;
	dataSize = strtok(data, "-");
	sscanf(dataSize, "%d", &nVecSize);
	if (nVecSize <= 0)
	{
		return;
	}
	char *dataContent;
	dataContent = strtok(NULL, "-");
	char *elementData;
	int nPropEventID = 0;
	int nTarget = 0;
	m_pPropsMgr->cleanPropEvent();
	elementData = strtok(dataContent, "/");
	while (elementData != NULL)
	{
		sscanf(elementData, "%d,%d", &nPropEventID, &nTarget);
		m_pPropsMgr->putPropEventToVec(nPropEventID, nTarget);
	}
}

void CBattle::setBossBattleData(char * data)
{
	int nUpdateFrameCount = 0;
	int nHitBulletCount = 0;
	double dBattleTime = 0;
	int nBattleRun = 0;
	int nBattleStop = 0;
	sscanf(data, "%d,%d,%lf,%d,%d", &nUpdateFrameCount, &nHitBulletCount, &dBattleTime, &nBattleRun, &nBattleStop);

	m_nCountUpdateFrame = nUpdateFrameCount;
	m_nCountHitBullet = nHitBulletCount;
	m_dBattleTime = dBattleTime;
	if (nBattleRun == 0)
	{
		m_isBattleRuning = false;
	}
	else
	{
		m_isBattleRuning = true;
	}
	if (nBattleStop == 0)
	{
		m_isBattleStop = false;
	}
	else
	{
		m_isBattleStop = true;
	}
}

void CBattle::setBossBulletMgrData(char * data)
{
	int nPlayerCount = 0;
	sscanf(data, "%d", &nPlayerCount);
	m_pPlayer->getBulletMgr()->setPlayerBulletCount(nPlayerCount);
}

void CBattle::setPlayerFortData_reconnect(char * data, int nFortIndex, int nPlayer)
{
	double dHp = 0.0;
	double dEnergy = 0.0;
	double dInterval = 0.0;
	double dUninjuryRate = 0.0;
	double dAck = 0.0;
	int nLife = 0;
	double dFireTime = 0.0;
	//double dInitAck = 0.0;
	//double dInitHp = 0.0;
	//double dDefense = 0.0;
	//double dInitUninjuryRate = 0.0;
	//double dInitDamage = 0.0;
	int nAddPassiveSkill = 0;
	int nParalysis = 0;
	int nBurning = 0;
	int nAckUp = 0;

	int nAckDown = 0;
	int nRepairing = 0;
	int nUnrepaire = 0;
	int nUnenergy = 0;
	int nShield = 0;
	int nRelive = 0;
	int nSkillFire = 0;
	int nBreakArmor = 0;
	int nFortPassiveSkillStronger = 0;
	int nHavePassiveSkillStronger = 0;
	double dBurningCountTime = 0.0;
	double dRepairingCountTime = 0.0;
	double dReliveCountTime = 0.0;
	double dReliveHp = 0.0;
	double dAckDownValue = 0.0;
	double dAckUpValue = 0.0;
	double dAddPassiveEnergyTime = 0.0;
	double dMomentAddHp = 0.0;
	double dSkillAddHp = 0.0;
	double dPropAddHp = 0.0;
	double dContinueAddHp = 0.0;
	double dSelfAddEnergy = 0.0;
	double dEnergyAddEnergy = 0.0;
	double dPropAddEnergy = 0.0;
	double dAttackAddEnergy = 0.0;
	double dBeDamageAddEnergy = 0.0;
	double dBulletDamage = 0.0;
	double dPropBulletDamage = 0.0;
	double dBuffBurnDamage = 0.0;
	double dNPC_Damage = 0.0;
	double dSkillDamage = 0.0;
	double dSkillTime = 0.0;
	double dShipSkillDamage = 0.0;
	double dShipSkillAddHp = 0.0;
	double dShipSkillAddEnergy = 0.0;

	sscanf(data, "%lf,%lf,%lf,%lf,%lf,%d,%lf,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%lf,%lf,%lf,%lf,%lf,%lf,%lf,%lf,%lf,%lf,%lf,%lf,%lf,%lf,%lf,%lf,%lf,%lf,%lf,%lf,%lf,%lf,%lf,%lf,%lf",
		&dHp, &dEnergy, &dInterval, &dUninjuryRate, &dAck, &nLife, &dFireTime, &nAddPassiveSkill, &nParalysis, &nBurning, &nAckUp, &nAckDown, &nRepairing, &nUnrepaire,
		&nUnenergy, &nShield, &nRelive, &nSkillFire, &nBreakArmor, &nFortPassiveSkillStronger, &nHavePassiveSkillStronger, &dBurningCountTime, &dRepairingCountTime, &dReliveCountTime, &dReliveHp,
		&dAckDownValue, &dAckUpValue, &dAddPassiveEnergyTime, &dMomentAddHp, &dSkillAddHp, &dPropAddHp, &dContinueAddHp, &dSelfAddEnergy, &dEnergyAddEnergy, &dPropAddEnergy, &dAttackAddEnergy,
		&dBeDamageAddEnergy, &dBulletDamage, &dPropBulletDamage, &dBuffBurnDamage, &dNPC_Damage, &dSkillDamage, &dSkillTime, &dShipSkillDamage, &dShipSkillAddHp, &dShipSkillAddEnergy);
	CFort *playerFort;
	if (nPlayer == 1)
	{
		playerFort = m_pPlayer->getShip()->getFortMgr()->getPlayerFort()[nFortIndex];
	}
	else
	{
		playerFort = m_pEnemy->getShip()->getFortMgr()->getEnemyFort()[nFortIndex];
	}
		
	if (!playerFort->isFortLive())
	{
		return;
	}
	playerFort->resetHp(dHp);
	playerFort->resetEnergy(dEnergy);
	playerFort->resetFortInterval(dInterval);
	playerFort->resetUninjuryRate(dUninjuryRate);
	playerFort->resetFortAck(dAck);
	if (nLife == 0)
	{
		playerFort->resetFortLife(false);
	}
	else if (nLife == 1)
	{
		playerFort->resetFortLife(true);
	}
	playerFort->resetFireTime(dFireTime);
	//playerFort->resetInitAck(dInitAck);
	//playerFort->resetInitHp(dInitHp);
	//playerFort->resetDefense(dDefense);
	//playerFort->resetInitUnInjuryRate(dInitUninjuryRate);
	//playerFort->resetInitDamage(dInitDamage);
	if (nAddPassiveSkill == 0)
	{
		playerFort->resetAddPassiveSkill(false);
	}
	else if (nAddPassiveSkill == 1)
	{
		playerFort->resetAddPassiveSkill(true);
	}
	if (nParalysis == 0)
	{
		playerFort->resetFortParalysis(false);
	}
	else if (nParalysis == 1)
	{
		playerFort->resetFortParalysis(true);
	}
	if (nBurning == 0)
	{
		playerFort->resetFortBurning(false);
	}
	else if (nBurning == 1)
	{
		playerFort->resetFortBurning(true);
	}
	if (nAckUp == 0)
	{
		playerFort->resetAckUp(false);
	}
	else if (nAckUp == 1)
	{
		playerFort->resetAckUp(true);
	}
	if (nAckDown == 0)
	{
		playerFort->resetAckDown(false);
	}
	else if (nAckDown == 1)
	{
		playerFort->resetAckDown(true);
	}
	if (nRepairing == 0)
	{
		playerFort->resetRepairing(false);
	}
	else if (nRepairing == 1)
	{
		playerFort->resetRepairing(true);
	}
	if (nUnrepaire == 0)
	{
		playerFort->resetUnrepaire(false);
	}
	else if (nUnrepaire == 1)
	{
		playerFort->resetUnrepaire(true);
	}
	if (nUnenergy == 0)
	{
		playerFort->resetUnEnergy(false);
	}
	else if (nUnenergy == 1)
	{
		playerFort->resetUnEnergy(true);
	}
	if (nShield == 0)
	{
		playerFort->resetShield(false);
	}
	else if (nShield == 1)
	{
		playerFort->resetShield(true);
	}
	if (nRelive == 0)
	{
		playerFort->resetRelive(false);
	}
	else if (nRelive == 1)
	{
		playerFort->resetRelive(true);
	}
	if (nSkillFire == 0)
	{
		playerFort->resetSkillFire(false);
	}
	else if (nSkillFire == 1)
	{
		playerFort->resetSkillFire(true);
	}
	if (nBreakArmor == 0)
	{
		playerFort->resetBreakArmor(false);
	}
	else if (nBreakArmor == 1)
	{
		playerFort->resetBreakArmor(true);
	}
	if (nFortPassiveSkillStronger == 0)
	{
		playerFort->resetPassiveSkillStronger(false);
	}
	else if (nFortPassiveSkillStronger == 1)
	{
		playerFort->resetPassiveSkillStronger(true);
	}
	if (nHavePassiveSkillStronger == 0)
	{
		playerFort->resetHavePassiveSkillStronger(false);
	}
	else if (nHavePassiveSkillStronger == 1)
	{
		playerFort->resetHavePassiveSkillStronger(true);
	}
	playerFort->setBurningCountTime(dBurningCountTime);
	playerFort->setRepairingCountTime(dRepairingCountTime);
	playerFort->setReliveCountDown(dReliveCountTime);
	playerFort->setReliveHp(dReliveHp);
	playerFort->setAckDownValue(dAckDownValue);
	playerFort->setAckUpValue(dAckUpValue);
	playerFort->setAddPassiveEnergyTime(dAddPassiveEnergyTime);
	playerFort->recoverAddHp(dMomentAddHp);
	playerFort->recoverSkillAddHp(dSkillAddHp);
	playerFort->recoverPropAddHp(dPropAddHp);
	playerFort->recoverContinueAddHp(dContinueAddHp);
	playerFort->recoverSelfAddEnergy(dSelfAddEnergy);
	playerFort->recoverEnergyAddEnergy(dEnergyAddEnergy);
	playerFort->recoverPropAddEnergy(dPropAddEnergy);
	playerFort->recoverAttackAddEnergy(dAttackAddEnergy);
	playerFort->recoverBeDamageAddEnergy(dBeDamageAddEnergy);
	playerFort->recoverBulletDamage(dBulletDamage);
	playerFort->recoverPropBuleltDamage(dPropBulletDamage);
	playerFort->recoverBuffBurnDamage(dBuffBurnDamage);
	playerFort->recoverNPCDamage(dNPC_Damage);
	playerFort->recoverSkillDamage(dSkillDamage);
	playerFort->setSkillTime(dSkillTime);
	playerFort->recoverShipSkillDamage(dShipSkillDamage);
	playerFort->recoverShipSkillAddHp(dShipSkillAddHp);
	playerFort->recoverShipSkillAddEnergy(dShipSkillAddEnergy);
}

void CBattle::setPlayerFortData_synchordata(char * data, int nFortIndex, int nPlayer)
{
	double dHp = 0.0;
	double dEnergy = 0.0;
	double dInterval = 0.0;
	double dUninjuryRate = 0.0;
	double dAck = 0.0;
	int nLife = 0;
	double dFireTime = 0.0;
	int nAddPassiveSkill = 0;
	int nParalysis = 0;
	int nBurning = 0;
	int nAckUp = 0;

	int nAckDown = 0;
	int nRepairing = 0;
	int nUnrepaire = 0;
	int nUnenergy = 0;
	int nShield = 0;
	int nRelive = 0;
	int nSkillFire = 0;
	int nBreakArmor = 0;
	int nFortPassiveSkillStronger = 0;
	int nHavePassiveSkillStronger = 0;
	double dBurningCountTime = 0.0;
	double dRepairingCountTime = 0.0;
	double dReliveCountTime = 0.0;
	double dReliveHp = 0.0;
	double dAckDownValue = 0.0;
	double dAckUpValue = 0.0;
	double dAddPassiveEnergyTime = 0.0;
	double dSkillTime = 0.0;

	sscanf(data, "%lf,%lf,%lf,%lf,%lf,%d,%lf,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%lf,%lf,%lf,%lf,%lf,%lf,%lf,%lf",
		&dHp, &dEnergy, &dInterval, &dUninjuryRate, &dAck, &nLife, &dFireTime, &nAddPassiveSkill, &nParalysis, &nBurning, &nAckUp, &nAckDown, &nRepairing, &nUnrepaire,
		&nUnenergy, &nShield, &nRelive, &nSkillFire, &nBreakArmor, &nFortPassiveSkillStronger, &nHavePassiveSkillStronger, &dBurningCountTime, &dRepairingCountTime, &dReliveCountTime, &dReliveHp,
		&dAckDownValue, &dAckUpValue, &dAddPassiveEnergyTime, &dSkillTime);
	CFort *playerFort;
	if (nPlayer == 1)
	{
		playerFort = m_pPlayer->getShip()->getFortMgr()->getPlayerFort()[nFortIndex];
	}
	else
	{
		playerFort = m_pEnemy->getShip()->getFortMgr()->getEnemyFort()[nFortIndex];
	}
	if (!playerFort->isFortLive())
	{
		return;
	}
	playerFort->resetHp(dHp);
	playerFort->resetEnergy(dEnergy);
	playerFort->resetFortInterval(dInterval);
	playerFort->resetUninjuryRate(dUninjuryRate);
	playerFort->resetFortAck(dAck);
	if (nLife == 0)
	{
		playerFort->resetFortLife(false);
	}
	else if (nLife == 1)
	{
		playerFort->resetFortLife(true);
	}
	playerFort->resetFireTime(dFireTime);

	if (nAddPassiveSkill == 0)
	{
		playerFort->resetAddPassiveSkill(false);
	}
	else if (nAddPassiveSkill == 1)
	{
		playerFort->resetAddPassiveSkill(true);
	}
	if (nParalysis == 0)
	{
		playerFort->resetFortParalysis(false);
	}
	else if (nParalysis == 1)
	{
		playerFort->resetFortParalysis(true);
	}
	if (nBurning == 0)
	{
		playerFort->resetFortBurning(false);
	}
	else if (nBurning == 1)
	{
		playerFort->resetFortBurning(true);
	}
	if (nAckUp == 0)
	{
		playerFort->resetAckUp(false);
	}
	else if (nAckUp == 1)
	{
		playerFort->resetAckUp(true);
	}
	if (nAckDown == 0)
	{
		playerFort->resetAckDown(false);
	}
	else if (nAckDown == 1)
	{
		playerFort->resetAckDown(true);
	}
	if (nRepairing == 0)
	{
		playerFort->resetRepairing(false);
	}
	else if (nRepairing == 1)
	{
		playerFort->resetRepairing(true);
	}
	if (nUnrepaire == 0)
	{
		playerFort->resetUnrepaire(false);
	}
	else if (nUnrepaire == 1)
	{
		playerFort->resetUnrepaire(true);
	}
	if (nUnenergy == 0)
	{
		playerFort->resetUnEnergy(false);
	}
	else if (nUnenergy == 1)
	{
		playerFort->resetUnEnergy(true);
	}
	if (nShield == 0)
	{
		playerFort->resetShield(false);
	}
	else if (nShield == 1)
	{
		playerFort->resetShield(true);
	}
	if (nRelive == 0)
	{
		playerFort->resetRelive(false);
	}
	else if (nRelive == 1)
	{
		playerFort->resetRelive(true);
	}
	if (nSkillFire == 0)
	{
		playerFort->resetSkillFire(false);
	}
	else if (nSkillFire == 1)
	{
		playerFort->resetSkillFire(true);
	}
	if (nBreakArmor == 0)
	{
		playerFort->resetBreakArmor(false);
	}
	else if (nBreakArmor == 1)
	{
		playerFort->resetBreakArmor(true);
	}
	if (nFortPassiveSkillStronger == 0)
	{
		playerFort->resetPassiveSkillStronger(false);
	}
	else if (nFortPassiveSkillStronger == 1)
	{
		playerFort->resetPassiveSkillStronger(true);
	}
	if (nHavePassiveSkillStronger == 0)
	{
		playerFort->resetHavePassiveSkillStronger(false);
	}
	else if (nHavePassiveSkillStronger == 1)
	{
		playerFort->resetHavePassiveSkillStronger(true);
	}
	playerFort->setBurningCountTime(dBurningCountTime);
	playerFort->setRepairingCountTime(dRepairingCountTime);
	playerFort->setReliveCountDown(dReliveCountTime);
	playerFort->setReliveHp(dReliveHp);
	playerFort->setAckDownValue(dAckDownValue);
	playerFort->setAckUpValue(dAckUpValue);
	playerFort->setAddPassiveEnergyTime(dAddPassiveEnergyTime);
	playerFort->setSkillTime(dSkillTime);

}

void CBattle::setBattleData_BossReconnect(char * data)
{
	double dBossAck = 0.0;
	int nBossStage = 0;
	double dTotalDamage = 0.0;
	int nIsInChange = 0;
	int nIsFire = 0;
	double dBossTotalTime = 0.0;
	double dFireTime = 0.0;
	double dStageTime = 0.0;
	double dStageTiming = 0.0;
	int nCountBullet = 0;
	double dChangeTime = 0.0;
	double dNpcTime = 0.0;
	int nIsNpcFlying = 0;
	double dNpcFlyTime = 0.0;
	int nCountNpc = 0;
	double dFireInterval = 0.0;
	int nIsBossSkill = 0;
	double dBossSkilling = 0.0;
	double dSkillBurstTime = 0.0;
	double dFireSkillCondition = 0.0;
	double dBulletBurstTime = 0.0;
	double dBulletDamage = 0.0;  // 
	double dFortSkillDamage = 0.0;
	double dNpcDamage = 0.0;
	double dPropDamage = 0.0;
	double dShipSkillDamage = 0.0;
	int nNpcType = 0;

	sscanf(data, "%lf,%d,%lf,%d,%d,%lf,%lf,%lf,%lf,%d,%lf,%lf,%d,%lf,%d,%lf,%d,%lf,%lf,%lf,%lf,%lf,%lf,%lf,%lf,%lf,%d", &dBossAck, &nBossStage, &dTotalDamage,
		&nIsInChange, &nIsFire, &dBossTotalTime, &dFireTime, &dStageTime, &dStageTiming, &nCountBullet, &dChangeTime, &dNpcTime, &nIsNpcFlying,
		&dNpcFlyTime, &nCountNpc, &dFireInterval, &nIsBossSkill, &dBossSkilling, &dSkillBurstTime, &dFireSkillCondition, &dBulletBurstTime,
		&dBulletDamage, &dFortSkillDamage, &dNpcDamage, &dPropDamage, &dShipSkillDamage, &nNpcType);

	m_pBoss->cntSetBossAck(dBossAck);
	m_pBoss->cntSetBossStage(nBossStage);
	m_pBoss->cntSetTotalDamage(dTotalDamage);
	m_pBoss->cntIsInChange(nIsInChange);
	m_pBoss->cntIsFire(nIsFire);
	m_pBoss->cntSetBossTotalTime(dBossTotalTime);
	m_pBoss->cntSetFireTime(dFireTime);//--
	m_pBoss->cntSetStageTime(dStageTime);
	m_pBoss->cntSetStageTiming(dStageTiming);//--
	m_pBoss->cntSetCountBullet(nCountBullet);
	m_pBoss->cntSetChangeTime(dChangeTime);//--
	m_pBoss->cntSetNpcTime(dNpcTime);     //--
	m_pBoss->cntIsNpcFlying(nIsNpcFlying);
	m_pBoss->cntSetNpcFlyTime(dNpcFlyTime); //--
	m_pBoss->cntSetCountNpc(nCountNpc);
	m_pBoss->cntSetFireInterval(dFireInterval);
	m_pBoss->cntIsBossSkill(nIsBossSkill);
	m_pBoss->cntSetBossSkilling(dBossSkilling); //--
	m_pBoss->cntSetSkillBurstTime(dSkillBurstTime);
	m_pBoss->cntSetFireSkillCondition(dFireSkillCondition);
	m_pBoss->cntSetBulletBurstTime(dBulletBurstTime);
	m_pBoss->setNumberData(dBulletDamage, dFortSkillDamage, dNpcDamage, dPropDamage, dShipSkillDamage, nNpcType);
}

void CBattle::setBattleData_BossSynchordata(char * data)
{
	double dBossAck = 0.0;
	int nBossStage = 0;
	double dTotalDamage = 0.0;
	int nIsInChange = 0;
	int nIsFire = 0;
	double dBossTotalTime = 0.0;
	double dFireTime = 0.0;
	double dStageTime = 0.0;
	double dStageTiming = 0.0;
	int nCountBullet = 0;
	double dChangeTime = 0.0;
	double dNpcTime = 0.0;
	int nIsNpcFlying = 0;
	double dNpcFlyTime = 0.0;
	int nCountNpc = 0;
	double dFireInterval = 0.0;
	int nIsBossSkill = 0;
	double dBossSkilling = 0.0;
	double dSkillBurstTime = 0.0;
	double dFireSkillCondition = 0.0;
	double dBulletBurstTime = 0.0;

	sscanf(data, "%lf,%d,%lf,%d,%d,%lf,%lf,%lf,%lf,%d,%lf,%lf,%d,%lf,%d,%lf,%d,%lf,%lf,%lf,%lf", &dBossAck, &nBossStage, &dTotalDamage,
		&nIsInChange, &nIsFire, &dBossTotalTime, &dFireTime, &dStageTime, &dStageTiming, &nCountBullet, &dChangeTime, &dNpcTime, &nIsNpcFlying, 
		&dNpcFlyTime, &nCountNpc, &dFireInterval, &nIsBossSkill, &dBossSkilling, &dSkillBurstTime, &dFireSkillCondition, &dBulletBurstTime);

	if (m_pBoss->getFireTime() > dFireTime || m_pBoss->getStageTiming() > dStageTiming || m_pBoss->getChangeTime() > dChangeTime ||
		m_pBoss->getNpcTime() > dNpcTime || m_pBoss->getNpcFlyTime() >dNpcFlyTime || m_pBoss->getBossSkilling() > dBossSkilling)
	{
		return;
	}
	m_pBoss->cntSetBossAck(dBossAck);
	m_pBoss->cntSetBossStage(nBossStage);
	m_pBoss->cntSetTotalDamage(dTotalDamage);
	m_pBoss->cntIsInChange(nIsInChange);
	m_pBoss->cntIsFire(nIsFire);
	m_pBoss->cntSetBossTotalTime(dBossTotalTime);
	m_pBoss->cntSetFireTime(dFireTime);//--
	m_pBoss->cntSetStageTime(dStageTime);
	m_pBoss->cntSetStageTiming(dStageTiming);//--
	m_pBoss->cntSetCountBullet(nCountBullet);
	m_pBoss->cntSetChangeTime(dChangeTime);//--
	m_pBoss->cntSetNpcTime(dNpcTime);     //--
	m_pBoss->cntIsNpcFlying(nIsNpcFlying);
	m_pBoss->cntSetNpcFlyTime(dNpcFlyTime); //--
	m_pBoss->cntSetCountNpc(nCountNpc);
	m_pBoss->cntSetFireInterval(dFireInterval);
	m_pBoss->cntIsBossSkill(nIsBossSkill);
	m_pBoss->cntSetBossSkilling(dBossSkilling); //--
	m_pBoss->cntSetSkillBurstTime(dSkillBurstTime);
	m_pBoss->cntSetFireSkillCondition(dFireSkillCondition);
	m_pBoss->cntSetBulletBurstTime(dBulletBurstTime);
}

void CBattle::setBossBulletReconnect(char * data)
{
	char *vecSize;
	int nVecSize = 0;
	vecSize = strtok(data, "-");
	sscanf(vecSize, "%d", &nVecSize);
	if (nVecSize <= 0)
	{
		return;
	}
	m_pBoss->cleanBossBulletVec();
	char *dataContent;
	dataContent = strtok(NULL, "-");
	int nBulletIndex = 0;
	double dBulletBurstTime = 0.0;
	char *elementData;
	elementData = strtok(dataContent, "/");
	while (elementData != NULL)
	{
		sscanf(elementData, "%d,%lf", &nBulletIndex, &dBulletBurstTime);
		m_pBoss->createBossBullet(nBulletIndex, dBulletBurstTime);
		elementData = strtok(NULL, "/");
	}

}

void CBattle::setBossEventReconnect(char * data)
{
	char *vecSize;
	int nVecSize = 0;
	vecSize = strtok(data, "-");
	sscanf(vecSize, "%d", &nVecSize);
	if (nVecSize <= 0)
	{
		return;
	}
	m_pBoss->cleanBossEventVec();

	char *dataContent;
	dataContent = strtok(NULL, "-");
	int nEvent = 0;
	char *elementData;
	elementData = strtok(dataContent, "/");

	while (elementData != NULL)
	{
		sscanf(elementData, "%d", &nEvent);
		m_pBoss->addBossEvent(nEvent);
		elementData = strtok(NULL, "/");
	}

}

void CBattle::decodeWrongCodeJsonFileData()
{
	string strPath = FileUtils::getInstance()->fullPathForFilename(m_strWrongCodePath);
	string strData = FileUtils::getInstance()->getStringFromFile(strPath);
	Document doc;
	doc.Parse<0>(strData.c_str());
	if (doc.IsObject())
	{
		wrongCodeData sWrongCodeData;
		rapidjson::Value& vSuccess = doc["success"];
		sWrongCodeData.nSuccess = vSuccess.GetInt();
		rapidjson::Value& vError = doc["error"];
		sWrongCodeData.nError = vError.GetInt();
		rapidjson::Value& vValue = doc["request_skill"];
		if (vValue.IsObject())
		{
			sWrongCodeData.nFortDie_skill = vValue["fort_die_skill"].GetInt();
			sWrongCodeData.nFortParalysis_skill = vValue["fort_paralysis_skill"].GetInt();
			sWrongCodeData.nFortUnenergy = vValue["fort_unenergy"].GetInt();
			sWrongCodeData.nFortEnergyNotEnough = vValue["fort_energy_not_enough"].GetInt();
			sWrongCodeData.nFortSkilling = vValue["fort_skilling"].GetInt();
		}
		rapidjson::Value& vPropCode = doc["request_prop"];
		if (vPropCode.IsObject())
		{
			sWrongCodeData.nPropNotEnough = vPropCode["prop_not_enough"].GetInt();
			sWrongCodeData.nPlayerUnmissile = vPropCode["player_unmissile"].GetInt();
			sWrongCodeData.nFortDieProp = vPropCode["fort_die_prop"].GetInt();
			sWrongCodeData.nFortIsLifeRelive = vPropCode["fort_is_life_relive"].GetInt();
			sWrongCodeData.nEnergyIsDie = vPropCode["energy_is_die"].GetInt();
			sWrongCodeData.nFortUnenergyProp = vPropCode["fort_unenergy_prop"].GetInt();
			sWrongCodeData.nFortUnrepaireProp = vPropCode["fort_unrepaire_prop"].GetInt();
			sWrongCodeData.nFortArmorProp = vPropCode["fort_armor_prop"].GetInt();
		}
		rapidjson::Value& vSurrenderCode = doc["request_surrender"];
		if (vSurrenderCode.IsObject())
		{
			sWrongCodeData.nSurrenderField = vSurrenderCode["surrender_field"].GetInt();
		}
		m_vecWrongCodeData.insert(m_vecWrongCodeData.end(), sWrongCodeData);
	}
	//doc.Clear(); // for array（数组）
}

vector<wrongCodeData> CBattle::getWrongCodeData()
{
	return m_vecWrongCodeData;
}

void CBattle::setAllPlayerNumber(int nPlayerNumber)
{
	m_nPlayerNumber = nPlayerNumber;
}

// boss战增加的伤害加成
void CBattle::addInjuryPercent(double dPercent)
{
	m_pPlayer->getShip()->getFortMgr()->addInjuryPercent(dPercent);
}

double CBattle::getBossResultInjury()
{
	return m_pBoss->getBossTotalDamage();
}

int CBattle::getFailerFortCount()
{
	return m_nFailerFortNum;
}

void CBattle::countSurrenderFort(int player)
{
	if (player == 0)
	{
		map<int, CFort*> mapPlayerFort = m_pPlayer->getShip()->getFortMgr()->getPlayerFort(); //玩家的炮台
		map<int, CFort*>::iterator playerIter = mapPlayerFort.begin();
		for (; playerIter != mapPlayerFort.end(); playerIter++)
		{
			if ((*playerIter).second->isFortLive())
			{
				m_nFailerFortNum++;
			}
		}
	}
	else if (player == 1)
	{
		map<int, CFort*> mapEnemyFort = m_pEnemy->getShip()->getFortMgr()->getEnemyFort();  // 敌人的炮台
		map<int, CFort*>::iterator enemyIter = mapEnemyFort.begin();
		for (; enemyIter != mapEnemyFort.end(); enemyIter++)
		{
			if ((*enemyIter).second->isFortLive())
			{
				m_nFailerFortNum++;
			}
		}
	}
}
