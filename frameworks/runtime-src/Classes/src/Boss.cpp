#include "Boss.h"
#include "Battle.h"


CBoss::CBoss(string strDataPath, CBattle *pBattle, int nPlayer, int bossID)
{
	m_nBossID = bossID;
	m_nAllPlayer = nPlayer;
	m_pBossBattle = pBattle;

	m_nBossStage = bossStage::ONE_STAGE;
	m_dBossTotalTime = 0.0;
	m_dFireTime = 0.0;
	m_dFireInterval = 0.0;
	m_dBossAck = 0.0;		// boss的攻击力
	m_dTotalDamage = 0.0;	// boss受到的总伤害
	m_isFire = false;		// 发射子弹
	m_dStageTime = 0.0;		// 现阶段状态总时间
	m_dStageTiming = 0.0;   // 状态时间
	m_nCountBullet = 0;		// 统计子弹
	m_dInjuryRate = 0.0;	// 免伤率
	m_dChangeTime = 0.0;	// 变身时间
	m_dNpcTime = 0.0;
	m_isNpcFlying = false;   
	m_isBossSkill = false;// boss skill

	m_isInChange = false;

	m_dNpcFlyTime = 0.0;	// NPC开火时间记录
	m_nCountNpc = 0;        // 统计NPC出场次数
	m_dBossSkilling = 0.0;  // 计算boss技能时间
	m_dSkillBurstTime = 0.0;	// 技能释放到技能产生伤害的时间
	m_dFireSkillCondition = 0.0;// 技能发射条件
	m_dDamageByBullet = 0.0;
	m_dDamageByFortSkill = 0.0;
	m_dDamageByNpc = 0.0;
	m_dDamageByProp = 0.0;
	m_dDamageByShipSkill = 0.0;
	m_dDataBulletBurstTime = 0.0;
	m_nNpcType = 0;

	loadBossData(strDataPath);
}


CBoss::~CBoss()
{
	cleanBossBulletVec();
}

void CBoss::init()
{
	m_pBossBulletMgr = new CBulletMgr();
	m_pBossBulletMgr->initData(true);
}

void CBoss::update(double delta)
{
	m_dBossTotalTime += delta;
	//m_pBossBulletMgr->update(delta);
	vector<CBullet*>::iterator iter = m_vecBossBullet.begin();
	for (; iter != m_vecBossBullet.end(); iter++)
	{
		int returnNum = (*iter)->bossBulletUpdata(delta);
		if (returnNum == 1)
		{
			// 计算boss普攻伤害
			m_isFire = false;
			bulletDamagePlayer();
			delete((*iter));
			(*iter) = nullptr;
			iter = m_vecBossBullet.erase(iter);
		}
		if (iter == m_vecBossBullet.end())
		{
			break;
		}
	}

	if (!m_isInChange) // 正常状态
	{
		m_dStageTiming += delta;
		m_dNpcTime += delta;

		if (m_dStageTiming >= m_dStageTime && !m_isBossSkill && !m_isFire)//要是在释放技能，等技能释放结束后再切换状态。
		{
			bossChangeBegin();
		}
		// 普攻达标后的下一次攻击时间才释放技能
		if (!m_isBossSkill)
		{
			if (!m_isFire)
			{
				m_dFireTime += delta;
				if (m_dFireTime > m_dFireInterval)
				{
					if ((m_dFireTime - m_dFireInterval < 0.00001) && (m_dFireTime - m_dFireInterval > -0.00001))
					{
						m_dFireTime = m_dFireInterval;
					}
					m_dFireTime -= m_dFireInterval;

					if (m_nCountBullet < m_dFireSkillCondition)
					{
						m_nCountBullet++;
						m_isFire = true;
						// boss发射子弹事件 (轨迹在lua中计算，无需坐标)
						m_vecBossEvent.insert(m_vecBossEvent.end(), BossEvent::BOSS_FIRE);
						//createBossBullet();
						CBullet *pBullet = new CBullet();
						pBullet->createBossBullet(m_nCountBullet, m_dDataBulletBurstTime);
						m_vecBossBullet.insert(m_vecBossBullet.end(), pBullet);
					}
					else
					{
						m_isBossSkill = true;
						// 发射技能
						m_vecBossEvent.insert(m_vecBossEvent.end(), BossEvent::BOSS_SKILL_BEGIN);
						m_dFireTime = 0;
						m_nCountBullet = 0;
					}
				}
			}
		}
		else
		{
			m_dBossSkilling += delta;
			if (m_dBossSkilling > m_dSkillBurstTime)
			{
				// 技能造成伤害
				bossSkillBurst();
				m_dBossSkilling = 0;
				m_isBossSkill = false;
			}
		}


		// npc 检测
		if (m_dNpcTime > m_dDataCallNpcTime)
		{
			m_isNpcFlying = true;
			m_nCountNpc++;
			// 召唤NPC事件
			m_nNpcType = nBuffRoad[m_nCountNpc - 1];
			m_vecBossEvent.insert(m_vecBossEvent.end(), BossEvent::BOSS_CALL_NPC_SKILL);
			if ((m_dNpcTime - m_dDataCallNpcTime < 0.00001) && (m_dNpcTime - m_dDataCallNpcTime > -0.00001))
			{
				m_dNpcTime = m_dDataCallNpcTime;
			}
			m_dNpcTime -= m_dDataCallNpcTime;
		}

		if (m_isNpcFlying) // npc是否在飞行
		{
			m_dNpcFlyTime += delta;
			if (m_dNpcFlyTime >= m_dDataNpcFireTime)
			{
				// npc 开火,计算伤害
				m_vecBossEvent.insert(m_vecBossEvent.end(), BossEvent::BOSS_CALL_NPC_BACK);
				NpcFight();
				m_dNpcFlyTime = 0.0;
				m_isNpcFlying = false;
			}
		}
	}
	else // 在切换状态下（变身）
	{
		m_dChangeTime += delta;

		if (m_nBossStage == bossStage::TWO_STAGE)
		{
			if (m_dChangeTime >= m_dDataChangeOneTime)
			{
				m_dChangeTime = 0;
				bossChangeOver();
			}
		}
		else if (m_nBossStage == bossStage::THREE_STAGE)
		{
			if (m_dChangeTime >= m_dDataChangeTwoTime)
			{
				m_dChangeTime = 0;
				bossChangeOver();
			}
		}
	}

}

void CBoss::loadBossData(string strBossDataPath)  // 读取数据
{
	// 客户端
	//stringstream oss;
	//string bossID;
	//oss << m_nBossID;
	//oss >> bossID;
	char bossID[3];
	sprintf(bossID, "%d", m_nBossID);
	string strPath = FileUtils::getInstance()->fullPathForFilename(strBossDataPath);
	string strData = FileUtils::getInstance()->getStringFromFile(strPath);
	Document doc;
	doc.Parse<0>(strData.c_str());
	if (doc.IsObject())
	{
		rapidjson::Value& vValue = doc[bossID];
		if (vValue.IsObject())
		{
			m_dBossHp = vValue["boss_hp"].GetDouble();
			m_dInjuryRate = vValue["boss_defense"].GetDouble();
			m_dDataOneAckConst = vValue["phase1_damage"].GetDouble();
			m_dDataOneAckBase = vValue["phase1_damage_base"].GetDouble();
			m_dDataOneAckTime = vValue["phase1_damage_multiple"].GetDouble();
			m_dDataOneAckMax = vValue["phase1_damage_max"].GetDouble();
			m_dDataOneFireTime = vValue["phase1_damage_time"].GetDouble();   // 普攻需要改写
			m_dDataOneFireInterval = vValue["phase1_damage_speed"].GetDouble();

			m_dDataFireSkillCondition1 = vValue["phase1_skill"].GetDouble();
			m_dDataSkillBurstTime1 = vValue["phase1_skill_time"].GetDouble();
			m_dDataSkillDamageMultiple1 = vValue["phase1_skill_multiple"].GetDouble();
			m_dDataSkillBuffTime1 = vValue["phase1_buff_time"].GetDouble();
			m_dDataStageOneTime = vValue["phase1_time"].GetDouble();
			m_dDataChangeOneTime = vValue["phase1_over"].GetDouble();

			m_dDataTwoAckConst = vValue["phase2_damage"].GetDouble();
			m_dDataTwoAckBase = vValue["phase2_damage_base"].GetDouble();
			m_dDataTwoAckTime = vValue["phase2_damage_multiple"].GetDouble();
			m_dDataTwoAckMax = vValue["phase2_damage_max"].GetDouble();
			m_dDataTwoFireTime = vValue["phase2_damage_time"].GetDouble();
			m_dDataTwoFireInterval = vValue["phase2_damage_speed"].GetDouble();

			m_dDataFireSkillCondition2 = vValue["phase2_skill"].GetDouble();
			m_dDataSkillBurstTime2 = vValue["phase2_skill_time"].GetDouble();
			m_dDataSkillDamageMultiple2 = vValue["phase2_skill_multiple"].GetDouble();
			m_dDataSkillBuffTime2 = vValue["phase2_buff_time"].GetDouble();
			m_dDataStageTwoTime = vValue["phase2_time"].GetDouble();
			m_dDataChangeTwoTime = vValue["phase2_over"].GetDouble();

			m_dDataSkillBurstTime3 = vValue["phase3_skill_time"].GetDouble();
			m_dDataSkillDamageMultiple3 = vValue["phase3_skill_multiple"].GetDouble();

			m_dDataCallNpcTime = vValue["call_npc"].GetDouble();
			m_dDataNpcFireTime = vValue["npc_damage_time"].GetDouble();
			m_dDataNpcDamageMultiple = vValue["npc_damage_multiple"].GetDouble();
			m_nDataNpcBuff1_kind = vValue["npc1_buff"].GetInt();
			m_dDataNpcBuff1_value = vValue["npc1_buff_effect"].GetDouble();
			m_dDataNpcBuff1_time = vValue["npc1_buff_time"].GetDouble();
			m_nDataNpcBuff2_kind = vValue["npc2_buff"].GetInt();
			m_dDataNpcBuff2_value = vValue["npc2_buff_effect"].GetDouble();
			m_dDataNpcBuff2_time = vValue["npc2_buff_time"].GetDouble();
			m_nDataNpcBuff3_kind = vValue["npc3_buff"].GetInt();
			m_dDataNpcBuff3_value = vValue["npc3_buff_effect"].GetDouble();
			m_dDataNpcBuff3_time = vValue["npc3_buff_time"].GetDouble();
		}
	}

	// 服务器
	//Json::Reader reader;
	//Json::Value root;
	//ifstream openFile;
	//openFile.open(strBossDataPath, ios::binary);
	//if (!openFile.is_open())
	//{
	//	cout << "open fail" << endl;
	//}
	//if (reader.parse(openFile, root))
	//{
	//	m_dBossHp =root[bossID]["boss_hp"].asDouble();
	//	m_dInjuryRate = root[bossID]["boss_defense"].asDouble();
	//	m_dDataOneAckConst = root[bossID]["phase1_damage"].asDouble();
	//	m_dDataOneAckBase = root[bossID]["phase1_damage_base"].asDouble();
	//	m_dDataOneAckTime = root[bossID]["phase1_damage_multiple"].asDouble();
	//	m_dDataOneAckMax = root[bossID]["phase1_damage_max"].asDouble();
	//	m_dDataOneFireTime = root[bossID]["phase1_damage_time"].asDouble();   // 普攻需要改写
	//	m_dDataOneFireInterval = root[bossID]["phase1_damage_speed"].asDouble();

	//	m_dDataFireSkillCondition1 = root[bossID]["phase1_skill"].asDouble();
	//	m_dDataSkillBurstTime1 = root[bossID]["phase1_skill_time"].asDouble();
	//	m_dDataSkillDamageMultiple1 = root[bossID]["phase1_skill_multiple"].asDouble();
	//	m_dDataSkillBuffTime1 = root[bossID]["phase1_buff_time"].asDouble();
	//	m_dDataStageOneTime = root[bossID]["phase1_time"].asDouble();
	//	m_dDataChangeOneTime = root[bossID]["phase1_over"].asDouble();

	//	m_dDataTwoAckConst = root[bossID]["phase2_damage"].asDouble();
	//	m_dDataTwoAckBase = root[bossID]["phase2_damage_base"].asDouble();
	//	m_dDataTwoAckTime = root[bossID]["phase2_damage_multiple"].asDouble();
	//	m_dDataTwoAckMax = root[bossID]["phase2_damage_max"].asDouble();
	//	m_dDataTwoFireTime = root[bossID]["phase2_damage_time"].asDouble();
	//	m_dDataTwoFireInterval = root[bossID]["phase2_damage_speed"].asDouble();

	//	m_dDataFireSkillCondition2 = root[bossID]["phase2_skill"].asDouble();
	//	m_dDataSkillBurstTime2 = root[bossID]["phase2_skill_time"].asDouble();
	//	m_dDataSkillDamageMultiple2 = root[bossID]["phase2_skill_multiple"].asDouble();
	//	m_dDataSkillBuffTime2 = root[bossID]["phase2_buff_time"].asDouble();
	//	m_dDataStageTwoTime = root[bossID]["phase2_time"].asDouble();
	//	m_dDataChangeTwoTime = root[bossID]["phase2_over"].asDouble();

	//	m_dDataSkillBurstTime3 = root[bossID]["phase3_skill_time"].asDouble();
	//	m_dDataSkillDamageMultiple3 = root[bossID]["phase3_skill_multiple"].asDouble();

	//	m_dDataCallNpcTime = root[bossID]["call_npc"].asDouble();
	//	m_dDataNpcFireTime = root[bossID]["npc_damage_time"].asDouble();
	//	m_dDataNpcDamageMultiple = root[bossID]["npc_damage_multiple"].asDouble();
	//	m_nDataNpcBuff1_kind = root[bossID]["npc1_buff"].asInt();
	//	m_dDataNpcBuff1_value = root[bossID]["npc1_buff_effect"].asDouble();
	//	m_dDataNpcBuff1_time = root[bossID]["npc1_buff_time"].asDouble();
	//	m_nDataNpcBuff2_kind = root[bossID]["npc2_buff"].asInt();
	//	m_dDataNpcBuff2_value = root[bossID]["npc2_buff_effect"].asDouble();
	//	m_dDataNpcBuff2_time = root[bossID]["npc2_buff_time"].asDouble();
	//	m_nDataNpcBuff3_kind = root[bossID]["npc3_buff"].asInt();
	//	m_dDataNpcBuff3_value = root[bossID]["npc3_buff_effect"].asDouble();
	//	m_dDataNpcBuff3_time = root[bossID]["npc3_buff_time"].asDouble();
	//}
	//openFile.close();

	// 这边赋值阶段1的数据
	m_dBossAck = (m_dDataOneAckConst + m_nAllPlayer / m_dDataOneAckBase) * m_dDataOneAckTime;
	if (m_dBossAck > m_dDataOneAckMax)
	{
		m_dBossAck = m_dDataOneAckMax;
	}
	m_dStageTime = m_dDataStageOneTime;
	m_dFireInterval = m_dDataOneFireInterval;
	m_dSkillBurstTime = m_dDataSkillBurstTime1;
	m_dDataBulletBurstTime = m_dDataOneFireTime;

	m_dFireSkillCondition = m_dDataFireSkillCondition1;

}

void CBoss::splitNpcBuffRoad(string strData)
{
	const char *cRoad = strData.c_str();
	//int length = strData.length();
	//cRoad = new char[length + 1];
	//strcpy(cRoad, strData.c_str());
	sscanf(cRoad, "%d,%d,%d,%d,%d,%d,%d,%d,%d,%d", &nBuffRoad[0], &nBuffRoad[1], &nBuffRoad[2], &nBuffRoad[3], &nBuffRoad[4],
		&nBuffRoad[5], &nBuffRoad[6], &nBuffRoad[7], &nBuffRoad[8], &nBuffRoad[9]);
	//delete(cRoad);
}

void CBoss::createBossBullet(int nBulletIndex, double dTime)
{
	//m_pBossBulletMgr->createBullet(BOSS_ID, 1, m_dBossBulletSpeed);
	CBullet* pBullet = new CBullet();
	pBullet->createBossBullet(nBulletIndex, dTime);
	m_vecBossBullet.insert(m_vecBossBullet.end(), pBullet);
}

void CBoss::addBossEvent(int nEvent)
{
	m_vecBossEvent.insert(m_vecBossEvent.end(), nEvent);
}

CBulletMgr * CBoss::getBossBulletMgr()
{
	return m_pBossBulletMgr;
}

vector<int> CBoss::getBossEvent()
{
	return m_vecBossEvent;
}

vector<CBullet*> CBoss::getBossBullet()
{
	return m_vecBossBullet;
}

//void CBoss::setAllPlayerNumber(int nPlayer)
//{
//	m_nAllPlayer = nPlayer;
//}

void CBoss::cleanBossEventVec()
{
	m_vecBossEvent.clear();
}

void CBoss::cleanBossBulletVec()
{
	vector<CBullet*>::iterator iter = m_vecBossBullet.begin();
	for (; iter != m_vecBossBullet.end(); iter++)
	{
		delete((*iter));
		(*iter) = nullptr;
	}
	m_vecBossBullet.clear();
}

void CBoss::bulletDamagePlayer()
{
	map<int, CFort*> mapPlayerForts = m_pBossBattle->getPlayer()->getShip()->getFortMgr()->getPlayerFort();
	map<int, CFort*>::iterator iter = mapPlayerForts.begin();
	for (; iter != mapPlayerForts.end(); iter++)
	{
		if ((*iter).second->isFortLive())
		{
			(*iter).second->damageFortByBullet(m_dBossAck * (1 - (*iter).second->getUnInjuryCoe()));
		}
	}
}


void CBoss::bossSkillBurst()
{
	m_vecBossEvent.insert(m_vecBossEvent.end(), BossEvent::BOSS_SKILL_FIRE);
	if (m_nBossStage == bossStage::ONE_STAGE)
	{
		oneStageSkill();
	}
	else if (m_nBossStage == bossStage::TWO_STAGE)
	{
		twoStageSkill();
	}
	else if (m_nBossStage == bossStage::THREE_STAGE)
	{
		finalSkill();
	}
}
//每4次普攻之后释放一次技能，对敌方全体炮台进行大规模轰炸，并且附加灼伤与禁止维修状态。状态持续5秒。
void CBoss::oneStageSkill()
{
	//wholeDamagePlayer(m_dDataSkillDamageMultiple1);
	map<int, CFort*> mapPlayerForts = m_pBossBattle->getPlayer()->getShip()->getFortMgr()->getPlayerFort();
	map<int, CFort*>::iterator iter = mapPlayerForts.begin();
	//int nCountLiveFort = 0;
	//for (; iter != mapPlayerForts.end(); iter++)
	//{
	//	if ((*iter).second->isFortLive())
	//	{
	//		nCountLiveFort++;
	//	}
	//}
	//double damage = m_dBossAck * m_dDataSkillDamageMultiple1;
	//if (nCountLiveFort == 1)
	//{
	//	damage *= 3;
	//}
	//else if (nCountLiveFort == 2)
	//{
	//	damage *= 1.5;
	//}
	//iter = mapPlayerForts.begin();
	for (; iter != mapPlayerForts.end(); iter++)
	{
		if ((*iter).second->isFortLive())
		{
			(*iter).second->damageFortBySkillBurst(m_dBossAck * m_dDataSkillDamageMultiple1 * (1 - ((*iter).second->getUnInjuryCoe())));
			m_pBossBattle->getPlayer()->getBuffMgr()->addBuff(Debuff::FORT_BURNING, (*iter).second->getFortID(), 0, m_dDataSkillBuffTime1);
			m_pBossBattle->getPlayer()->getBuffMgr()->addBuff(Debuff::FORT_REPAIR_DISTURB, (*iter).second->getFortID(), 0, m_dDataSkillBuffTime1);
		}
	}
}
//每4次普攻之后释放一次技能，召唤海盗战机助战对玩家战舰进行大规模扫射，造成全体伤害，并附加能量干扰状态持续5秒。
void CBoss::twoStageSkill()
{
	map<int, CFort*> mapPlayerForts = m_pBossBattle->getPlayer()->getShip()->getFortMgr()->getPlayerFort();
	//int nCountLiveFort = 0;
	map<int, CFort*>::iterator iter = mapPlayerForts.begin();
	//for (; iter != mapPlayerForts.end(); iter++)
	//{
	//	if ((*iter).second->isFortLive())
	//	{
	//		nCountLiveFort++;
	//	}
	//}
	//double damage = m_dBossAck * m_dDataSkillDamageMultiple2;
	//if (nCountLiveFort == 1)
	//{
	//	damage *= 3;
	//}
	//else if (nCountLiveFort == 2)
	//{
	//	damage *= 1.5;
	//}
	//iter = mapPlayerForts.begin();
	for (; iter != mapPlayerForts.end(); iter++)
	{
		if ((*iter).second->isFortLive())
		{
			(*iter).second->damageFortBySkillBurst(m_dBossAck * m_dDataSkillDamageMultiple2 * (1 - ((*iter).second->getUnInjuryCoe())));
			m_pBossBattle->getPlayer()->getBuffMgr()->addBuff(Debuff::FORT_ENERGY_DISTURB, (*iter).second->getFortID(), 0, m_dDataSkillBuffTime2);
		}
	}
}

void CBoss::finalSkill()
{
	map<int, CFort*> mapPlayerForts = m_pBossBattle->getPlayer()->getShip()->getFortMgr()->getPlayerFort();
	map<int, CFort*>::iterator iter = mapPlayerForts.begin();
	for (; iter != mapPlayerForts.end(); iter++)
	{
		if ((*iter).second->isFortLive())
		{
			(*iter).second->damageFortBySkillBurst(m_dBossAck * m_dDataSkillDamageMultiple3 * 1);//(1 - ((*iter).second->getUnInjuryCoe()))
		}
	}
}

void CBoss::changeDataToNextStage()
{
	if (m_nBossStage == bossStage::ONE_STAGE)
	{

		m_nBossStage = bossStage::TWO_STAGE;
		m_dStageTiming = 0;
		m_dBossAck = (m_dDataTwoAckConst + m_nAllPlayer / m_dDataTwoAckBase) * m_dDataTwoAckTime;
		if (m_dBossAck > m_dDataTwoAckMax)
		{
			m_dBossAck = m_dDataTwoAckMax;
		}
		m_dStageTime = m_dDataStageTwoTime;
		m_dFireInterval = m_dDataTwoFireInterval;
		m_dSkillBurstTime = m_dDataSkillBurstTime2;
		m_dFireSkillCondition = m_dDataFireSkillCondition2;
		m_dDataBulletBurstTime = m_dDataTwoFireTime;

		m_vecBossEvent.insert(m_vecBossEvent.end(), BossEvent::BOSS_CHANGE_STAGE_ONE);
		// 切换状态1事件

	}
	else if (m_nBossStage == bossStage::TWO_STAGE)
	{
		m_nBossStage = bossStage::THREE_STAGE;
		m_dStageTiming = 0;
		m_dSkillBurstTime = m_dDataSkillBurstTime3;

		m_vecBossEvent.insert(m_vecBossEvent.end(), BossEvent::BOSS_CHANGE_STAGE_TWO);
		// 切换状态2事件

	}

}

void CBoss::bossChangeBegin()
{
	m_isInChange = true;
	setFortParalysis();
	changeDataToNextStage();
}

void CBoss::setFortParalysis()
{
	map<int, CFort*> mapPlayerForts = m_pBossBattle->getPlayer()->getShip()->getFortMgr()->getPlayerFort();
	map<int, CFort*>::iterator iter = mapPlayerForts.begin();
	for (; iter != mapPlayerForts.end(); iter++)
	{
		if ((*iter).second->isFortLive())
		{
			(*iter).second->fortParalysisState();
		}
	}
}

void CBoss::recoverFortState()
{
	map<int, CFort*> mapPlayerForts = m_pBossBattle->getPlayer()->getShip()->getFortMgr()->getPlayerFort();
	map<int, CFort*>::iterator iter = mapPlayerForts.begin();
	for (; iter != mapPlayerForts.end(); iter++)
	{
		if ((*iter).second->isFortLive())
		{
			(*iter).second->recoveryParalysis();
		}
	}
}

// 转换结束，恢复炮台攻击（boss第二阶段转第三阶段完，//炮台bu恢复攻击），
// 恢复boss
void CBoss::bossChangeOver()
{
	m_isInChange = false;

	m_vecBossEvent.insert(m_vecBossEvent.end(), BossEvent::BOSS_CHANGE_STAGE_OVER);
	if (m_nBossStage == bossStage::THREE_STAGE)
	{
		// 技能三   毁天灭地
		m_isBossSkill = true;
		m_vecBossEvent.insert(m_vecBossEvent.end(), BossEvent::BOSS_SKILL_BEGIN);
	}
	else
	{
		recoverFortState();
	}
}

void CBoss::NpcFight()
{
	map<int, CFort*> mapPlayerForts = m_pBossBattle->getPlayer()->getShip()->getFortMgr()->getPlayerFort();
	map<int, CFort*>::iterator iter = mapPlayerForts.begin();
	for (; iter != mapPlayerForts.end(); iter++)
	{
		if ((*iter).second->isFortLive())
		{
			(*iter).second->damageFortBySkillBurst(m_dBossAck * m_dDataNpcDamageMultiple * (1 - ((*iter).second->getUnInjuryCoe())));
			if (nBuffRoad[m_nCountNpc - 1] == 0)
			{
				int buffID = chooseNpcBuff(m_nDataNpcBuff1_kind);
				m_pBossBattle->getPlayer()->getBuffMgr()->addBuff(buffID, (*iter).second->getFortID(), m_dDataNpcBuff1_value, m_dDataNpcBuff1_time);
			}
			else if (nBuffRoad[m_nCountNpc - 1] == 1)
			{
				int buffID = chooseNpcBuff(m_nDataNpcBuff2_kind);
				m_pBossBattle->getPlayer()->getBuffMgr()->addBuff(buffID, (*iter).second->getFortID(), m_dDataNpcBuff2_value, m_dDataNpcBuff2_time);
			}
			else if (nBuffRoad[m_nCountNpc - 1] == 2)
			{
				int buffID = chooseNpcBuff(m_nDataNpcBuff3_kind);
				m_pBossBattle->getPlayer()->getBuffMgr()->addBuff(buffID, (*iter).second->getFortID(), m_dDataNpcBuff3_value, m_dDataNpcBuff3_time);
			}
		}
	}
}
//1、瘫痪
//2、燃烧
//3、破甲
//4、火力干扰
//5、维修干扰
//6、能量干扰
int CBoss::chooseNpcBuff(int nKind)
{
	if (nKind == 1)
	{
		return Debuff::FORT_PARALYSIS;
	}
	else if (nKind == 2)
	{
		return Debuff::FORT_BURNING;
	}
	else if (nKind == 3)
	{
		return Debuff::FORT_BREAK_ARMOR;
	}
	else if (nKind == 4)
	{
		return Debuff::FORT_ATK_DISTURB;
	}
	else if (nKind == 5)
	{
		return Debuff::FORT_REPAIR_DISTURB;
	}
	else if (nKind == 6)
	{
		return Debuff::FORT_ENERGY_DISTURB;
	}
	return 0;
}

void CBoss::bossBeDamageByBullet(double dDamage)
{
	if (m_dDamageByBullet == 0)
	{
		m_dDamageByBullet = dDamage * (1 - m_dInjuryRate);
		m_dTotalDamage += m_dDamageByBullet;
		m_vecBossEvent.insert(m_vecBossEvent.end(), BossEvent::BOSS_BE_DAMAGE_BY_BULLET);
	}
	else
	{
		m_dDamageByBullet = m_dDamageByBullet + dDamage * (1 - m_dInjuryRate);
		m_dTotalDamage += dDamage * (1 - m_dInjuryRate);
	}
}

void CBoss::bossBeDamageByFortSkill(double dDamage)
{
	m_dDamageByFortSkill = dDamage * (1 - m_dInjuryRate);
	m_dTotalDamage += m_dDamageByFortSkill;
	m_vecBossEvent.insert(m_vecBossEvent.end(), BossEvent::BOSS_BE_DAMAGE_BY_FORT_SKILL);
}

void CBoss::bossBeDamageByNPC(double dDamage)
{
	m_dDamageByNpc = dDamage * (1 - m_dInjuryRate);
	m_dTotalDamage += m_dDamageByNpc;
	m_vecBossEvent.insert(m_vecBossEvent.end(), BossEvent::BOSS_BE_DAMAGE_BY_NPC);
}

void CBoss::bossBeDamageByProp(double dDamage)
{
	m_dDamageByProp = dDamage * (1 - m_dInjuryRate);  
	//m_dDamageByProp = dDamage;// 道具先做不扣免伤率的
	m_dTotalDamage += m_dDamageByProp;
	m_vecBossEvent.insert(m_vecBossEvent.end(), BossEvent::BOSS_BE_DAMAGE_BY_PROP);
}

void CBoss::bossBeDamageByShipSkill(double dDamage)
{
	m_dDamageByShipSkill = dDamage * (1 - m_dInjuryRate);
	m_dTotalDamage += m_dDamageByShipSkill;
	m_vecBossEvent.insert(m_vecBossEvent.end(), BossEvent::BOSS_BE_DAMAGE_BY_SHIP_SKILL);
}

void CBoss::bossBeDeepDamageByFortSkill(double dDamage)
{
    m_dDamageByFortSkill = dDamage * (1 - m_dInjuryRate);
    m_dTotalDamage += m_dDamageByFortSkill;
    m_vecBossEvent.insert(m_vecBossEvent.end(), BossEvent::BOSS_BE_DEEP_DAMAGE_BY_FORT_SKILL);
}

double CBoss::getBossUninjuryRate()
{
	return m_dInjuryRate;
}

double CBoss::getBossTotalDamage()
{
	return m_dTotalDamage;
}

double CBoss::getBulletDamageNumber()
{
	return m_dDamageByBullet;
}

double CBoss::getFortSkillDamageNumber()
{
	return m_dDamageByFortSkill;
}

double CBoss::getNpcDamageNumber()
{
	return m_dDamageByNpc;
}

double CBoss::getPropDamageNumber()
{
	return m_dDamageByProp;
}

double CBoss::getShipSkillDamageNumber()
{
	return m_dDamageByShipSkill;
}

int CBoss::getNpcType()
{
	return m_nNpcType;
}

void CBoss::recoveryNumber()
{
	m_dDamageByBullet = 0.0;
	m_dDamageByFortSkill = 0.0;
	m_dDamageByNpc = 0.0;
	m_dDamageByProp = 0.0;
	m_dDamageByShipSkill = 0.0;
	m_nNpcType = 0;
}

void CBoss::setNumberData(double dBullet, double dFortSkill, double dNpc, double dProp, double dShipSkill, int nNpcType)
{
	m_dDamageByBullet = dBullet;
	m_dDamageByFortSkill = dFortSkill;
	m_dDamageByNpc = dNpc;
	m_dDamageByProp = dProp;
	m_dDamageByShipSkill = dShipSkill;
	m_nNpcType = nNpcType;
}

double CBoss::getBossAck()
{
	return m_dBossAck;
}

int CBoss::getBossStage()
{
	return m_nBossStage;
}

double CBoss::getTotalDamage()
{
	return m_dTotalDamage;
}

bool CBoss::isInChange()
{
	return m_isInChange;
}

bool CBoss::isFire()
{
	return m_isFire;
}

double CBoss::getBossTotalTime()
{
	return m_dBossTotalTime;
}

double CBoss::getFireTime()
{
	return m_dFireTime;
}

double CBoss::getStageTime()
{
	return m_dStageTime;
}

double CBoss::getStageTiming()
{
	return m_dStageTiming;
}

int CBoss::getCountBullet()
{
	return m_nCountBullet;
}

double CBoss::getChangeTime()
{
	return m_dChangeTime;
}

double CBoss::getNpcTime()
{
	return m_dNpcTime;
}

bool CBoss::isNpcFlying()
{
	return m_isNpcFlying;
}

double CBoss::getNpcFlyTime()
{
	return m_dNpcFlyTime;
}

int CBoss::getCountNpc()
{
	return m_nCountNpc;
}

double CBoss::getFireInterval()
{
	return m_dFireInterval;
}

bool CBoss::isBossSkill()
{
	return m_isBossSkill;
}

double CBoss::getBossSkilling()
{
	return m_dBossSkilling;
}

double CBoss::getSkillBurstTime()
{
	return m_dSkillBurstTime;
}

double CBoss::getFireSkillCondition()
{
	return m_dFireSkillCondition;
}

double CBoss::getBulletBurstTime()
{
	return m_dDataBulletBurstTime;
}

void CBoss::cntSetBossAck(double dBossAck)
{
	m_dBossAck = dBossAck;
}

void CBoss::cntSetBossStage(int nBossStage)
{
	m_nBossStage = nBossStage;
}

void CBoss::cntSetTotalDamage(double dTotalDamage)
{
	m_dTotalDamage = dTotalDamage;
}

void CBoss::cntIsInChange(int nIs)
{
	if (nIs == 0)
	{
		m_isInChange = false;
	}
	else
	{
		m_isInChange = true;
	}
}

void CBoss::cntIsFire(int nIs)
{
	if (nIs == 0)
	{
		m_isFire = false;
	}
	else
	{
		m_isFire = true;
	}
}

void CBoss::cntSetBossTotalTime(double dTotalTime)
{
	m_dBossTotalTime = dTotalTime;
}

void CBoss::cntSetFireTime(double dTime)
{
	m_dFireTime = dTime;
}

void CBoss::cntSetStageTime(double dTime)
{
	m_dStageTime = dTime;
}

void CBoss::cntSetStageTiming(double dTime)
{
	m_dStageTiming = dTime;
}

void CBoss::cntSetCountBullet(int nBulletCount)
{
	m_nCountBullet = nBulletCount;
}

void CBoss::cntSetChangeTime(double dTime)
{
	m_dChangeTime = dTime;
}

void CBoss::cntSetNpcTime(double dTime)
{
	m_dNpcTime = dTime;
}

void CBoss::cntIsNpcFlying(int nIs)
{
	if (nIs == 0)
	{
		m_isNpcFlying = false;
	}
	else
	{
		m_isNpcFlying = true;
	}
}

void CBoss::cntSetNpcFlyTime(double dTime)
{
	m_dNpcFlyTime = dTime;
}

void CBoss::cntSetCountNpc(int nCount)
{
	m_nCountNpc = nCount;
}

void CBoss::cntSetFireInterval(double dInterval)
{
	m_dFireInterval = dInterval;
}

void CBoss::cntIsBossSkill(int nIs)
{
	if (nIs == 0)
	{
		m_isBossSkill = false;
	}
	else
	{
		m_isBossSkill = true;
	}
}

void CBoss::cntSetBossSkilling(double dTime)
{
	m_dBossSkilling = dTime;
}

void CBoss::cntSetSkillBurstTime(double dTime)
{
	m_dSkillBurstTime = dTime;
}

void CBoss::cntSetFireSkillCondition(double dNumber)
{
	m_dFireSkillCondition = dNumber;
}

void CBoss::cntSetBulletBurstTime(double dTime)
{
	m_dDataBulletBurstTime = dTime;
}
