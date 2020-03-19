#include "stdafx.h"
#include "Props.h"
#include "Battle.h"

CProps::CProps(CBattle *pBattle, string jsonStr, int propID)
	: m_nPropID(0)
	, m_nMissileOrNot(0)
	, m_dPropBuffTime(0)
	, m_dPropDamagePercent(0.0)
	, m_dPropBurstTime(0.0)
	, m_nTargetSide(0)
	, m_nTargetFort(0)
	, m_dPropBuffValue(0.0)
	, m_nUser(0)
	, m_dEnergyNpcDamage(0.0)
	, m_nPropBuffType(0)
{
	m_pPropBattle = pBattle;
	loadDataByJson(jsonStr, propID);
}


CProps::~CProps()
{

}

int CProps::update(double delta)
{
	if ((m_dPropBurstTime - delta < 0.00001) && (m_dPropBurstTime - delta > -0.00001))
	{
		m_dPropBurstTime = delta;
	}
	m_dPropBurstTime -= delta;
	if (m_dPropBurstTime <= 0)
	{
		burstProps();
		return 1;
	}
	return 0;
}

void CProps::initData()
{
	
}

void CProps::burstProps() 
{
	cout << " 道具爆炸。  burstProps   function " << endl;
	if (m_nPropID == 1001 || m_nPropID == 1002 || m_nPropID == 1003)
	{
		armorPiercingShell();
	}
	else if (m_nPropID == 1004 || m_nPropID == 1005 || m_nPropID == 1006)
	{
		burnShell();
	}
	else if (m_nPropID == 1007 || m_nPropID == 1008 || m_nPropID == 1009)
	{
		disturbShell();
	}
	else if (m_nPropID == 1010 || m_nPropID == 1011 || m_nPropID == 1012)
	{
		unenergyShell();
	}
	else if (m_nPropID == 1013 || m_nPropID == 1014 || m_nPropID == 1015)
	{
		deepDamageShell();
	}
	else if (m_nPropID == 1016 || m_nPropID == 1017 || m_nPropID == 1018)
	{
		damageShipShell();
	}
	else if (m_nPropID == 1101 || m_nPropID == 1102 || m_nPropID == 1103)
	{
		ackUpProp();
	}
	else if (m_nPropID == 1104 || m_nPropID == 1105 || m_nPropID == 1106)
	{
		fortRepairingProp();
	}
	else if (m_nPropID == 1107 || m_nPropID == 1108 || m_nPropID == 1109)
	{
		shieldProp();
	}
	else if (m_nPropID == 1110 || m_nPropID == 1111 || m_nPropID == 1112)
	{
		passiveSkillStrongProp();
	}
	else if (m_nPropID == 1201 || m_nPropID == 1202 || m_nPropID == 1203)
	{
		ackDownProp();
	}
	else if (m_nPropID == 1204 || m_nPropID == 1205 || m_nPropID == 1206)
	{
		unrepairingProp();
	}
	else if (m_nPropID == 1301 || m_nPropID == 1302 || m_nPropID == 1303)
	{
		//炮台复活
		reliveFortProp();
	}
	else if (m_nPropID == 1304 || m_nPropID == 1305 || m_nPropID == 1306)
	{
		chargeFortProp();
	}
	else if (m_nPropID == 1307 || m_nPropID == 1308 || m_nPropID == 1309)
	{
		// 能量体事件
	}
	else if (m_nPropID == 1401)
	{
		allFireProp();
	}
	else if (m_nPropID == 1402)
	{
		absoluteZoneProp();
	}
	else if (m_nPropID == 1403)
	{
		limitChargeProp();
	}
	else if (m_nPropID == 1404)
	{
		unmissileProp();
	}
	else if (m_nPropID == 1405)
	{
		cleanBuffProp();
	}
	else if (m_nPropID == 1406)
	{
		EMPunenergyProp();
	}
	else if (m_nPropID == 1407)
	{
		radiationUnrepairingProp();
	}
	else if (m_nPropID == 1408)
	{
		callNPCtoFight();
	}
}

void CProps::loadDataByJson(string jsonStr, int propID)
{
	m_nPropID = propID;
	int target = 0;
	int missile = 0;
	double dBurstTime = 0.0;
	double damagePercent = 0.0;
	int buffType = 0;
	int buffTime = 0;
	double buffValue = 0.0;
	//string strPropID;
	//stringstream ss;
	//ss << propID;
	//ss >> strPropID;
	char cPropID[7];
	sprintf(cPropID, "%d", propID);

	//Json::Reader reader;
	//Json::Value root;
	//ifstream openFile;
	//if (!openFile.is_open())
	//{
	//	cout << "openfile failed.   in prop function : loadDataByJson().  read prop DATA " << endl;
	//}
	//openFile.open(jsonStr, ios::binary);
	//if (reader.parse(openFile, root))
	//{
	//	target = root[cPropID]["target"].asInt();
	//	missile = root[cPropID]["missile"].asInt();
	//	dBurstTime = root[cPropID]["time"].asDouble();
	//	damagePercent = root[cPropID]["attack"].asInt();
	//	buffType = root[cPropID]["buff_type"].asInt();
	//	buffTime = root[cPropID]["continued"].asInt();
	//	buffValue = root[cPropID]["buff_value"].asDouble();
	//	cout << "prop 读取data end ：：：：：" << endl;
	//}
	string strPath = FileUtils::getInstance()->fullPathForFilename(jsonStr);
	string strData = FileUtils::getInstance()->getStringFromFile(strPath);
	Document doc;
	doc.Parse<0>(strData.c_str());
	if (doc.IsObject())
	{
		rapidjson::Value& vValue = doc[cPropID];
		if (vValue.IsObject())
		{
			target = vValue["target"].GetInt();
			missile = vValue["missile"].GetInt();
			dBurstTime = vValue["time"].GetDouble();
			damagePercent = vValue["attack"].GetDouble();
			buffType = vValue["buff_type"].GetInt();
			buffTime = vValue["continued"].GetInt();
			buffValue = vValue["buff_value"].GetDouble();
		}
	}
	//openFile.close();
	m_nMissileOrNot = missile;
	m_dPropDamagePercent = damagePercent;
	m_dPropBuffTime = buffTime;
	m_dPropBurstTime = dBurstTime;
 
	m_dPropBuffValue = buffValue;
	m_nPropBuffType = buffType;
}

 // return 0 ,失败， 1 ， 即时，不加容器，  2， 加容器里。  3 NPC  第二只。
int CProps::isUseProp(int nUser, int nPlayer, int nFortID, string wrongCodePath)
{
	m_nUser = nUser;
	m_nTargetSide = nPlayer;
	m_nTargetFort = nFortID;

	vector<wrongCodeData> vecWrongCodeData = m_pPropBattle->getWrongCodeData();

	 //能量体道具
	if (m_nPropID == 1307) //摧毀能量體
	{
		//if (m_pPropBattle->isEnergyBodyLive())
		//{
			destoryEnergyBodyProp();
			return 1;
		//}
		//else
		//{
		//	cout << "energy body is not here.  destroy energy" << endl;
		//	return vecWrongCodeData[0].nEnergyIsDie;
		//}
	}
	else if (m_nPropID == 1308) //锁定能量体
	{
		//if (m_pPropBattle->isEnergyBodyLive())
		//{
			lockEnergyBodyProp();
			return 1;
		//}
		//else
		//{
		//	cout << "energy body is not here .. lock energy" << endl;
		//	return vecWrongCodeData[0].nEnergyIsDie;
		//}
	}
	else if (m_nPropID == 1309) //能量体跃迁
	{
		//if (m_pPropBattle->isEnergyBodyLive())
		//{
			energyBodyJumpProp();
			return 1;
		//}
		//else
		//{
		//	cout << "energy body is not here .... jump energy " << endl;
		//	return vecWrongCodeData[0].nEnergyIsDie;
		//}
	}

	if (nFortID != 0)
	{
		// addWrongCode 维修干扰，维修道具不能使用(客户端服务端要分（其实只服务端需要））
		if (m_nPropID == 1104 || m_nPropID == 1105 || m_nPropID == 1106)
		{
			/*if (nUser == 1)
			{
				if (m_pPropBattle->getPlayer()->getShip()->getFortMgr()->getFortByID(nFortID, false)->isUnrepaireState())
				{
					return 300001;
				}
			}
			else if (nUser == 2)
			{
				if (m_pPropBattle->getEnemy()->getShip()->getFortMgr()->getFortByID(nFortID, true)->isUnrepaireState())
				{
					return 300001;
				}
			}*/
		}
		// addWrongCode 能量干扰，充能道具不能使用
		if (m_nPropID == 1304 || m_nPropID == 1305 || m_nPropID == 1306 || m_nPropID == 1403)
		{
	/*		if (nUser == 1)
			{
				if (m_pPropBattle->getPlayer()->getShip()->getFortMgr()->getFortByID(nFortID, false)->isUnEnergyState())
				{
					return 300002;
				}
			}
			else if (nUser == 2)
			{
				if (m_pPropBattle->getEnemy()->getShip()->getFortMgr()->getFortByID(nFortID, true)->isUnEnergyState())
				{
					return 300002;
				}
			}*/
		}
		// 炮台复活道具
		if (m_nPropID == 1301 || m_nPropID == 1302 || m_nPropID == 1303)
		{
			if (nPlayer == 1)
			{
				// 炮台复活
				reliveFortProp();
				return 1;
			}
			else if (nPlayer == 2)
			{
				reliveFortProp();
				return 1;
			}
		}
		else
		{
			cout << "不是炮台复活道具。 not fort relive prop" << endl;
			//if (nPlayer == 1)
			//{
			//	// 目标炮台已死
			//	if (!m_pPropBattle->getPlayer()->getShip()->getFortMgr()->getFortByID(nFortID, false)->isFortLive())
			//	{
			//		cout << " is fort die .can not use prop for dead fort " << endl; 
			//		//return root["battle"]["request_prop"]["fort_die_prop"].asInt();
			//		return vecWrongCodeData[0].nFortDieProp;
			//	}
			//}
			//else if (nPlayer == 2)
			//{
			//	if (!m_pPropBattle->getEnemy()->getShip()->getFortMgr()->getFortByID(nFortID, true)->isFortLive())
			//	{
			//		cout << " is fort die .can not use prop for dead fort  ..... enemy" << endl;
			//		//return root["battle"]["request_prop"]["fort_die_prop"].asInt();
			//		return vecWrongCodeData[0].nFortDieProp;
			//	}
			//}
		}
	}
	if (m_nMissileOrNot == 1)   // 为1 是导弹，0：非导弹
	{
		//if (nUser == 1)
		//{
		//	// 判断炮台是否在反导弹条约
		//	if (m_pPropBattle->getPlayer()->isPlayerUnmissile())
		//	{
		//		return vecWrongCodeData[0].nPlayerUnmissile;
		//	}
		//}
		//else if (nUser == 2)
		//{
		//	if (m_pPropBattle->getEnemy()->isEnemyUnmissile())
		//	{
		//		return vecWrongCodeData[0].nPlayerUnmissile;
		//	}
		//}
	}
	if (m_nPropID == propEvent::CALL_NPC_BY_PROP)// 道具是否是npc
	{
		if (m_nTargetSide == 1)// 目标是否是左玩家。
		{
			if (m_pPropBattle->getEnemy()->isHaveNpc())
			{
				return 3;
			}
			else
			{
				m_pPropBattle->getEnemy()->setNpcHereOrNot(true);
			}
		}
		else if (nPlayer == 2)// 目标是右玩家（enemy）
		{
			if (m_pPropBattle->getPlayer()->isHaveNpc())
			{
				return 3;
			}
			else
			{
				m_pPropBattle->getPlayer()->setNpcHereOrNot(true);
			}
		}
	}
	if (m_pPropBattle->getBattleType() == BattleType::BATTLE_BOSS)
	{
		if (m_nPropBuffType == 2 && m_nMissileOrNot == 0) // 对boss使用的debuff道具
		{
			return 4;
		}
	}
	if (m_dPropBurstTime <= 0)
	{
		//prop的效果
		burstProps();
		return 1;
	}
	else
	{
		return 2;
	}
	return 0;
}

int CProps::getPropID()
{
	return m_nPropID;
}
int CProps::getUserNum()
{
	return m_nUser;
}
int CProps::getTargetNum()
{
	return m_nTargetSide;
}
int CProps::getTargetFortID()
{
	return m_nTargetFort;
}

void CProps::setEnergyNpcDamage(double damage)
{
	m_dEnergyNpcDamage = damage;
}

double CProps::getTotalAck(int nSide)
{
	double dInitDamageCount = 0.0;
	if (nSide == 1) 
	{
		map<int, CFort*> playerForts = m_pPropBattle->getPlayer()->getShip()->getFortMgr()->getPlayerFort();
		map<int, CFort*>::iterator iter = playerForts.begin();
		for (; iter != playerForts.end(); iter++)
		{
			dInitDamageCount = dInitDamageCount + (*iter).second->getInitDamage();
		}
	}
	else if (nSide == 2)
	{
		map<int, CFort*> enemyForts = m_pPropBattle->getEnemy()->getShip()->getFortMgr()->getEnemyFort();
		map<int, CFort*>::iterator iter = enemyForts.begin();
		for (; iter != enemyForts.end(); iter++)
		{
			dInitDamageCount = dInitDamageCount + (*iter).second->getInitDamage();
		}
	}
	return dInitDamageCount;
}

//穿甲弹
void CProps::armorPiercingShell()
{
	CFort *pFort = nullptr;
	double dResultDamage = 0.0;
	if (m_nTargetSide == 1) // player
	{
		dResultDamage = getTotalAck(2);
		pFort = m_pPropBattle->getPlayer()->getShip()->getFortMgr()->getFortByID(m_nTargetFort, false);
		m_pPropBattle->getPlayer()->getBuffMgr()->addBuff(Debuff::FORT_BREAK_ARMOR, m_nTargetFort, 0, m_dPropBuffTime);
		if (pFort->isFortLive())
		{
			pFort->damageFortByPropBullet(m_dPropDamagePercent * dResultDamage * (1 - pFort->getUnInjuryCoe()));
		}
	}
	else if (m_nTargetSide == 2) // enemy
	{
		dResultDamage = getTotalAck(1);
		if (m_pPropBattle->getBattleType() == BattleType::BATTLE_NORMAL)
		{
			pFort = m_pPropBattle->getEnemy()->getShip()->getFortMgr()->getFortByID(m_nTargetFort, true);
			m_pPropBattle->getEnemy()->getBuffMgr()->addBuff(Debuff::FORT_BREAK_ARMOR, m_nTargetFort, 0, m_dPropBuffTime);
			if (pFort->isFortLive())
			{
				pFort->damageFortByPropBullet(m_dPropDamagePercent * dResultDamage * (1 - pFort->getUnInjuryCoe()));
			}
		}
		else if (m_pPropBattle->getBattleType() == BattleType::BATTLE_BOSS)
		{
			m_pPropBattle->getBoss()->bossBeDamageByProp(dResultDamage * m_dPropDamagePercent);
		}
	}
}
// 燃烧弹
void CProps::burnShell()
{
	CFort *pFort = nullptr;
	double dResultDamage = 0.0;
	if (m_nTargetSide == 1) // player
	{
		dResultDamage = getTotalAck(2);
		pFort = m_pPropBattle->getPlayer()->getShip()->getFortMgr()->getFortByID(m_nTargetFort, false);
		m_pPropBattle->getPlayer()->getBuffMgr()->addBuff(Debuff::FORT_BURNING, m_nTargetFort, 0, m_dPropBuffTime);
		if (pFort->isFortLive())
		{
			pFort->damageFortByPropBullet(m_dPropDamagePercent * dResultDamage * (1 - pFort->getUnInjuryCoe()));
		}
	}
	else if (m_nTargetSide == 2) // enemy
	{
		dResultDamage = getTotalAck(1);
		if (m_pPropBattle->getBattleType() == BattleType::BATTLE_NORMAL)
		{
			pFort = m_pPropBattle->getEnemy()->getShip()->getFortMgr()->getFortByID(m_nTargetFort, true);
			m_pPropBattle->getEnemy()->getBuffMgr()->addBuff(Debuff::FORT_BURNING, m_nTargetFort, 0, m_dPropBuffTime);
			if (pFort->isFortLive())
			{
				pFort->damageFortByPropBullet(m_dPropDamagePercent * dResultDamage * (1 - pFort->getUnInjuryCoe()));
			}
		}
		else if (m_pPropBattle->getBattleType() == BattleType::BATTLE_BOSS)
		{
			m_pPropBattle->getBoss()->bossBeDamageByProp(m_dPropDamagePercent * dResultDamage);
		}
	}

}
// 干扰弹(瘫痪)
void CProps::disturbShell()
{
	CFort *pFort = nullptr;
	double dResultDamage = 0.0;
	if (m_nTargetSide == 1) // player
	{
		dResultDamage = getTotalAck(2);
		pFort = m_pPropBattle->getPlayer()->getShip()->getFortMgr()->getFortByID(m_nTargetFort, false);
		m_pPropBattle->getPlayer()->getBuffMgr()->addBuff(Debuff::FORT_PARALYSIS, m_nTargetFort, 0, m_dPropBuffTime);
		if (pFort->isFortLive())
		{
			pFort->damageFortByPropBullet(m_dPropDamagePercent * dResultDamage * (1 - pFort->getUnInjuryCoe()));
		}
	}
	else if (m_nTargetSide == 2) // enemy
	{
		dResultDamage = getTotalAck(1);
		if (m_pPropBattle->getBattleType() == BattleType::BATTLE_NORMAL)
		{
			pFort = m_pPropBattle->getEnemy()->getShip()->getFortMgr()->getFortByID(m_nTargetFort, true);
			m_pPropBattle->getEnemy()->getBuffMgr()->addBuff(Debuff::FORT_PARALYSIS, m_nTargetFort, 0, m_dPropBuffTime);
			if (pFort->isFortLive())
			{
				pFort->damageFortByPropBullet(m_dPropDamagePercent * dResultDamage * (1 - pFort->getUnInjuryCoe()));
			}
		}
		else if (m_pPropBattle->getBattleType() == BattleType::BATTLE_BOSS)
		{
			m_pPropBattle->getBoss()->bossBeDamageByProp(m_dPropDamagePercent * dResultDamage);
		}
	}

}
// 禁能弹（能量干扰）
void CProps::unenergyShell()
{
	CFort *pFort = nullptr;
	double dResultDamage = 0.0;
	if (m_nTargetSide == 1) // player
	{
		dResultDamage = getTotalAck(2);
		pFort = m_pPropBattle->getPlayer()->getShip()->getFortMgr()->getFortByID(m_nTargetFort, false);
		m_pPropBattle->getPlayer()->getBuffMgr()->addBuff(Debuff::FORT_ENERGY_DISTURB, m_nTargetFort, 0, m_dPropBuffTime);
		if (pFort->isFortLive())
		{
			pFort->damageFortByPropBullet(m_dPropDamagePercent * dResultDamage * (1 - pFort->getUnInjuryCoe()));
		}
	}
	else if (m_nTargetSide == 2) // enemy
	{
		dResultDamage = getTotalAck(1);
		if (m_pPropBattle->getBattleType() == BattleType::BATTLE_NORMAL)
		{
			pFort = m_pPropBattle->getEnemy()->getShip()->getFortMgr()->getFortByID(m_nTargetFort, true);
			m_pPropBattle->getEnemy()->getBuffMgr()->addBuff(Debuff::FORT_ENERGY_DISTURB, m_nTargetFort, 0, m_dPropBuffTime);
			if (pFort->isFortLive())
			{
				pFort->damageFortByPropBullet(m_dPropDamagePercent * dResultDamage * (1 - pFort->getUnInjuryCoe()));
			}
		}
		else if (m_pPropBattle->getBattleType() == BattleType::BATTLE_BOSS)
		{
			m_pPropBattle->getBoss()->bossBeDamageByProp(m_dPropDamagePercent * dResultDamage);
		}
	}

}
//强袭导弹（伤害）
void CProps::deepDamageShell()
{
	CFort *pFort = nullptr;
	double dResultDamage = 0.0;
	if (m_nTargetSide == 1) // player
	{
		dResultDamage = getTotalAck(2);
		pFort = m_pPropBattle->getPlayer()->getShip()->getFortMgr()->getFortByID(m_nTargetFort, false);
		if (pFort->isFortLive())
		{
			pFort->damageFortByPropBullet(m_dPropDamagePercent * dResultDamage * (1 - pFort->getUnInjuryCoe()));
		}
	}
	else if (m_nTargetSide == 2) // enemy
	{
		dResultDamage = getTotalAck(1);
		if (m_pPropBattle->getBattleType() == BattleType::BATTLE_NORMAL)
		{
			pFort = m_pPropBattle->getEnemy()->getShip()->getFortMgr()->getFortByID(m_nTargetFort, true);
			if (pFort->isFortLive())
			{
				pFort->damageFortByPropBullet(m_dPropDamagePercent * dResultDamage * (1 - pFort->getUnInjuryCoe()));
			}
		}
		else if (m_pPropBattle->getBattleType() == BattleType::BATTLE_BOSS)
		{
			m_pPropBattle->getBoss()->bossBeDamageByProp(m_dPropDamagePercent * dResultDamage);
		}
	}

}
//对舰导弹
void CProps::damageShipShell()
{
	if (m_nTargetSide == 1)
	{
		double dResultDamage = getTotalAck(2);
		map<int, CFort*> mapPlayerFort = m_pPropBattle->getPlayer()->getShip()->getFortMgr()->getPlayerFort();
		map<int, CFort*>::iterator iter = mapPlayerFort.begin();
		for (; iter != mapPlayerFort.end(); iter++)
		{
			if ((*iter).second->isFortLive())
			{
				(*iter).second->damageFortByPropBullet(m_dPropDamagePercent * dResultDamage * (1 - (*iter).second->getUnInjuryCoe()));
			}
		}
	}
	else
	{
		double dResultDamage = getTotalAck(1);
		if (m_pPropBattle->getBattleType() == BattleType::BATTLE_NORMAL)
		{
			map<int, CFort*> mapEnemyFort = m_pPropBattle->getEnemy()->getShip()->getFortMgr()->getEnemyFort();
			map<int, CFort*>::iterator iter = mapEnemyFort.begin();
			for (; iter != mapEnemyFort.end(); iter++)
			{
				if ((*iter).second->isFortLive())
				{
					(*iter).second->damageFortByPropBullet(m_dPropDamagePercent * dResultDamage * (1 - (*iter).second->getUnInjuryCoe()));
				}
			}
		}
		else if (m_pPropBattle->getBattleType() == BattleType::BATTLE_BOSS)
		{
			m_pPropBattle->getBoss()->bossBeDamageByProp(m_dPropDamagePercent * dResultDamage);
		}
	}
}
//火力增幅
void CProps::ackUpProp()
{
	if (m_nTargetSide == 1)
	{
		m_pPropBattle->getPlayer()->getBuffMgr()->addBuff(Buff::FORT_ATK_ENHANCE, m_nTargetFort, m_dPropBuffValue, m_dPropBuffTime);
	}
	else
	{
		m_pPropBattle->getEnemy()->getBuffMgr()->addBuff(Buff::FORT_ATK_ENHANCE, m_nTargetFort, m_dPropBuffValue, m_dPropBuffTime);
	}
}
//战损修复
void CProps::fortRepairingProp()
{
	if (m_nTargetSide == 1)
	{
		m_pPropBattle->getPlayer()->getBuffMgr()->addBuff(Buff::FORT_REPAIRING, m_nTargetFort, 0, m_dPropBuffTime);
	}
	else
	{
		m_pPropBattle->getEnemy()->getBuffMgr()->addBuff(Buff::FORT_REPAIRING, m_nTargetFort, 0, m_dPropBuffTime);
	}
}

//护盾道具
void CProps::shieldProp()
{
	if (m_nTargetSide == 1)
	{
		cout << " player add shield. for use shield prop " << endl;
		m_pPropBattle->getPlayer()->getBuffMgr()->addBuff(Buff::FORT_SHIELD, m_nTargetFort, m_dPropBuffValue, m_dPropBuffTime);
	}
	else
	{
		cout << " enemy add shield . for .use shield prop ....." << endl;
		m_pPropBattle->getEnemy()->getBuffMgr()->addBuff(Buff::FORT_SHIELD, m_nTargetFort, m_dPropBuffValue, m_dPropBuffTime);
	}
}
// 被动技能强化
void CProps::passiveSkillStrongProp()
{
	if (m_nTargetSide == 1)
	{
		m_pPropBattle->getPlayer()->getBuffMgr()->addBuff(Buff::FORT_PASSIVE_SKILL_STRONGER, m_nTargetFort, 0, m_dPropBuffTime);
	}
	else
	{
		m_pPropBattle->getEnemy()->getBuffMgr()->addBuff(Buff::FORT_PASSIVE_SKILL_STRONGER, m_nTargetFort, 0, m_dPropBuffTime);
	}
}
//火力干扰
void CProps::ackDownProp()
{
	if (m_nTargetSide == 1)
	{
		m_pPropBattle->getPlayer()->getBuffMgr()->addBuff(Debuff::FORT_ATK_DISTURB, m_nTargetFort, m_dPropBuffValue, m_dPropBuffTime);
	}
	else
	{
		m_pPropBattle->getEnemy()->getBuffMgr()->addBuff(Debuff::FORT_ATK_DISTURB, m_nTargetFort, m_dPropBuffValue, m_dPropBuffTime);
	}
}
//维修干扰
void CProps::unrepairingProp()
{
	if (m_nTargetSide == 1)
	{
		m_pPropBattle->getPlayer()->getBuffMgr()->addBuff(Debuff::FORT_REPAIR_DISTURB, m_nTargetFort, 0, m_dPropBuffTime);
	}
	else
	{
		m_pPropBattle->getEnemy()->getBuffMgr()->addBuff(Debuff::FORT_REPAIR_DISTURB, m_nTargetFort, 0, m_dPropBuffTime);
	}
}
//损毁修复（复活炮台）
void CProps::reliveFortProp()
{
	if (m_nTargetSide == 1)
	{
		m_pPropBattle->getPlayer()->getShip()->getFortMgr()->getFortByID(m_nTargetFort, false)->fortRelive(m_dPropBuffValue);
	}
	else
	{
		m_pPropBattle->getEnemy()->getShip()->getFortMgr()->getFortByID(m_nTargetFort, true)->fortRelive(m_dPropBuffValue);
	}
}
// 炮台充能
void CProps::chargeFortProp()
{
	if (m_nTargetSide == 1)
	{
		m_pPropBattle->getPlayer()->getShip()->getFortMgr()->getFortByID(m_nTargetFort, false)->fortSupplyEnergy(m_dPropBuffValue);
	}
	else
	{
		m_pPropBattle->getEnemy()->getShip()->getFortMgr()->getFortByID(m_nTargetFort, true)->fortSupplyEnergy(m_dPropBuffValue);
	}
}
// 摧毀能量體
void CProps::destoryEnergyBodyProp()
{
	m_pPropBattle->destroyEnergyBody(true);
}
// 能量体锁定
void CProps::lockEnergyBodyProp()
{
	m_pPropBattle->getEnergyBody()->lockEnergy();
}
// 能量体跃迁
void CProps::energyBodyJumpProp()
{
	m_pPropBattle->getEnergyBody()->jumpEnergyBodyNow();
}
// 火力全开
void CProps::allFireProp()
{
	map<int, CFort*> mapForts;
	if (m_nTargetSide == 1)
	{
		mapForts = m_pPropBattle->getPlayer()->getShip()->getFortMgr()->getPlayerFort();
		map<int, CFort*>::iterator iter = mapForts.begin();
		for (; iter != mapForts.end(); iter++)
		{
			if ((*iter).second->isFortLive())
			{
				m_pPropBattle->getPlayer()->getBuffMgr()->addBuff(Buff::FORT_ATK_ENHANCE, (*iter).second->getFortID(), m_dPropBuffValue, m_dPropBuffTime);
			}
		}
	}
	else
	{
		mapForts = m_pPropBattle->getEnemy()->getShip()->getFortMgr()->getEnemyFort();
		map<int, CFort*>::iterator iter = mapForts.begin();
		for (; iter != mapForts.end(); iter++)
		{
			if ((*iter).second->isFortLive())
			{
				m_pPropBattle->getEnemy()->getBuffMgr()->addBuff(Buff::FORT_ATK_ENHANCE, (*iter).second->getFortID(), m_dPropBuffValue, m_dPropBuffTime);
			}
		}
	}
}
//全体护盾
void CProps::absoluteZoneProp()
{
	map<int, CFort*> mapForts;
	if (m_nTargetSide == 1)
	{
		mapForts = m_pPropBattle->getPlayer()->getShip()->getFortMgr()->getPlayerFort();
		map<int, CFort*>::iterator iter = mapForts.begin();
		for (; iter != mapForts.end(); iter++)
		{
			if ((*iter).second->isFortLive())
			{
				m_pPropBattle->getPlayer()->getBuffMgr()->addBuff(Buff::FORT_SHIELD, (*iter).second->getFortID(), m_dPropBuffValue, m_dPropBuffTime);
			}
		}
	}
	else
	{
		mapForts = m_pPropBattle->getEnemy()->getShip()->getFortMgr()->getEnemyFort();
		map<int, CFort*>::iterator iter = mapForts.begin();
		for (; iter != mapForts.end(); iter++)
		{
			if ((*iter).second->isFortLive())
			{
				m_pPropBattle->getEnemy()->getBuffMgr()->addBuff(Buff::FORT_SHIELD, (*iter).second->getFortID(), m_dPropBuffValue, m_dPropBuffTime);
			}
		}
	}
}
// 极限充能
void CProps::limitChargeProp()
{
	if (m_nTargetSide == 1)
	{
		m_pPropBattle->getPlayer()->getShip()->getFortMgr()->getFortByID(m_nTargetFort, false)->fortSupplyEnergy(m_dPropBuffValue);
	}
	else
	{
		m_pPropBattle->getEnemy()->getShip()->getFortMgr()->getFortByID(m_nTargetFort, true)->fortSupplyEnergy(m_dPropBuffValue);
	}
}
// 反导弹（导弹禁用）
void CProps::unmissileProp()
{
	if (m_nTargetSide == 1)
	{
		m_pPropBattle->getPlayer()->getBuffMgr()->addBuff(Debuff::PLAYER_UNMISSILE, 0, 0, m_dPropBuffTime);
	}
	else
	{
		m_pPropBattle->getEnemy()->getBuffMgr()->addBuff(Debuff::PLAYER_UNMISSILE, 0, 0, m_dPropBuffTime);
	}
}
// 清除减益buff或者 增益buff
void CProps::cleanBuffProp()
{
	if (m_nUser == 1)
	{
		if (m_nTargetSide == 1) // 对自己使用（清除坏的buff）
		{
			m_pPropBattle->getPlayer()->getShip()->getFortMgr()->cleanBadBuff();
		}
		else      // 对对方使用（清除好的buff）
		{
			m_pPropBattle->getEnemy()->getShip()->getFortMgr()->cleanBetterBuff();
		}
	}
	else if (m_nUser == 2)
	{
		if (m_nTargetSide == 1)
		{
			m_pPropBattle->getPlayer()->getShip()->getFortMgr()->cleanBetterBuff();
		}
		else
		{
			m_pPropBattle->getEnemy()->getShip()->getFortMgr()->cleanBadBuff();
		}
	}
}
// 能量干扰
void CProps::EMPunenergyProp()
{
	map<int, CFort*> mapForts;
	if (m_nTargetSide == 1)
	{
		mapForts = m_pPropBattle->getPlayer()->getShip()->getFortMgr()->getPlayerFort();
		map<int, CFort*>::iterator iter = mapForts.begin();
		for (; iter != mapForts.end(); iter++)
		{
			if ((*iter).second->isFortLive())
			{
				m_pPropBattle->getPlayer()->getBuffMgr()->addBuff(Debuff::FORT_ENERGY_DISTURB, (*iter).second->getFortID(), 0, m_dPropBuffTime);
			}	
		}
	}
	else
	{
		mapForts = m_pPropBattle->getEnemy()->getShip()->getFortMgr()->getEnemyFort();
		map<int, CFort*>::iterator iter = mapForts.begin();
		for (; iter != mapForts.end(); iter++)
		{
			if ((*iter).second->isFortLive())
			{
				m_pPropBattle->getEnemy()->getBuffMgr()->addBuff(Debuff::FORT_ENERGY_DISTURB, (*iter).second->getFortID(), 0, m_dPropBuffTime);
			}
		}
	}
}
// 维修干扰
void CProps::radiationUnrepairingProp()
{
	map<int, CFort*> mapForts;
	if (m_nTargetSide == 1)
	{
		mapForts = m_pPropBattle->getPlayer()->getShip()->getFortMgr()->getPlayerFort();
		map<int, CFort*>::iterator iter = mapForts.begin();
		for (; iter != mapForts.end(); iter++)
		{
			if ((*iter).second->isFortLive())
			{
				m_pPropBattle->getPlayer()->getBuffMgr()->addBuff(Debuff::FORT_REPAIR_DISTURB, (*iter).second->getFortID(), 0, m_dPropBuffTime);
			}
		}
	}
	else
	{
		mapForts = m_pPropBattle->getEnemy()->getShip()->getFortMgr()->getEnemyFort();
		map<int, CFort*>::iterator iter = mapForts.begin();
		for (; iter != mapForts.end(); iter++)
		{
			if ((*iter).second->isFortLive())
			{
				m_pPropBattle->getEnemy()->getBuffMgr()->addBuff(Debuff::FORT_REPAIR_DISTURB, (*iter).second->getFortID(), 0, m_dPropBuffTime);
			}
		}
	}
}

void CProps::callNPCtoFight()
{
	map<int, CFort*> mapPlayerForts = m_pPropBattle->getPlayer()->getShip()->getFortMgr()->getPlayerFort();

	if (m_dEnergyNpcDamage == 0)// 道具NPC
	{
		if (m_nUser == 1)  //player为使用者
		{
			double countFortAck = 0;
			map<int, CFort*>::iterator iter = mapPlayerForts.begin();
			for (; iter != mapPlayerForts.end(); iter++)
			{
				countFortAck += (*iter).second->getFortAck();
			}
			double damageValue = countFortAck * m_dPropBuffValue;
			if (m_pPropBattle->getBattleType() == BattleType::BATTLE_NORMAL)
			{
				map<int, CFort*> mapEnemyForts = m_pPropBattle->getEnemy()->getShip()->getFortMgr()->getEnemyFort();
				map<int, CFort*>::iterator enemyIter = mapEnemyForts.begin();
				for (; enemyIter != mapEnemyForts.end(); enemyIter++)
				{
					if ((*enemyIter).second->isFortLive())
					{
						(*enemyIter).second->damageFortByNPC(damageValue * (1 - (*enemyIter).second->getUnInjuryCoe()));
					}
				}
			}
			else if (m_pPropBattle->getBattleType() == BattleType::BATTLE_BOSS)
			{
				// damage boss~~
				// m_pPropBattle
				m_pPropBattle->getBoss()->bossBeDamageByNPC(damageValue);
			}
		}
		else
		{
			map<int, CFort*> mapEnemyForts = m_pPropBattle->getEnemy()->getShip()->getFortMgr()->getEnemyFort();
			double countFortAck = 0;
			map<int, CFort*>::iterator iter = mapEnemyForts.begin();
			for (; iter != mapEnemyForts.end(); iter++)
			{
				countFortAck += (*iter).second->getFortAck();
			}
			double damageValue = countFortAck * m_dPropBuffValue;
			map<int, CFort*>::iterator playerIter = mapPlayerForts.begin();
			for (; playerIter != mapPlayerForts.end(); playerIter++)
			{
				if ((*playerIter).second->isFortLive())
				{
					(*playerIter).second->damageFortByNPC(damageValue * (1 - (*playerIter).second->getUnInjuryCoe()));
				}
			}
		}
	}
	else    // 能量体NPC 
	{
		map<int, CFort*> mapEnemyForts = m_pPropBattle->getEnemy()->getShip()->getFortMgr()->getEnemyFort();
		if (m_nUser == 1)
		{
			map<int, CFort*>::iterator enemyIter = mapEnemyForts.begin();
			for (; enemyIter != mapEnemyForts.end(); enemyIter++)
			{
				if ((*enemyIter).second->isFortLive())
				{
					(*enemyIter).second->damageFortByNPC(m_dEnergyNpcDamage * (1 - (*enemyIter).second->getUnInjuryCoe()));
				}
			}
		}
		else if (m_nUser == 2)
		{
			map<int, CFort*>::iterator playerIter = mapPlayerForts.begin();
			for (; playerIter != mapPlayerForts.end(); playerIter++)
			{
				if ((*playerIter).second->isFortLive())
				{
					(*playerIter).second->damageFortByNPC(m_dEnergyNpcDamage * (1 - (*playerIter).second->getUnInjuryCoe()));
				}
			}
		}
		m_dEnergyNpcDamage = 0;
	}
}

void CProps::setPropID(int nPropID)
{
	m_nPropID = nPropID;
}

double CProps::getPropBurstTime()
{
	return m_dPropBurstTime;
}

void CProps::setPropBurstTime(double dBurstTime)
{
	m_dPropBurstTime = dBurstTime;
}

void CProps::setUser(int nUser)
{
	m_nUser = nUser;
}

void CProps::setTargetSide(int nTarget)
{
	m_nTargetSide = nTarget;
}

void CProps::setTargetFort(int nTargetFort)
{
	m_nTargetFort = nTargetFort;
}

double CProps::getEnergyNpcDamage()
{
	return m_dEnergyNpcDamage;
}
