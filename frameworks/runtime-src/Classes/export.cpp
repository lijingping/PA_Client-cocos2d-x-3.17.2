//
//  export.cpp
//  newBattleObj
//
//  Created by Lin on 2017/11/9.
//  Copyright © 2017年 admin. All rights reserved.
//

#include "export.h"
#include "Battle.h"

CBattle *g_pBattle;

int enterBattle(lua_State *Start)
{
	int nBattleType = lua_tointeger(Start, 1);
	g_pBattle = new CBattle();
	string strSkillDataPath = lua_tostring(Start, 2);
	string strPropDataPath = lua_tostring(Start, 3);
	string strWrongCodePath = lua_tostring(Start, 4);
	string strShipDataPath = lua_tostring(Start, 5);
	g_pBattle->setJsonsPath(strSkillDataPath, strPropDataPath, strWrongCodePath, strShipDataPath);
	g_pBattle->initData(nBattleType);
	return 1;
}

int enterBossBattle(lua_State *Start)
{
	g_pBattle = new CBattle();
	int nBattleType = lua_tointeger(Start, 1);
	string strSkillDataPath = lua_tostring(Start, 2);
	string strPropDataPath = lua_tostring(Start, 3);
	string strWrongCodePath = lua_tostring(Start, 4);
	string strShipDataPath = lua_tostring(Start, 5);
	int nPlayer = lua_tointeger(Start, 6);
	string strBossDataPath = lua_tostring(Start, 7);
	int nBossID = lua_tointeger(Start, 8);
	string strBossNpcBuff = lua_tostring(Start, 9);
	g_pBattle->setJsonsPath(strSkillDataPath, strPropDataPath, strWrongCodePath, strShipDataPath);
	g_pBattle->setAllPlayerNumber(nPlayer);
	g_pBattle->setBossJsonPathAndID(strBossDataPath, nBossID);
	g_pBattle->initData(nBattleType);
	g_pBattle->getBoss()->splitNpcBuffRoad(strBossNpcBuff);
	return 1;
}

// 顺序:myshipID, enemyshipID
int setShipData(lua_State *ShipData)
{
    int myshipID = lua_tointeger(ShipData,1);
	int myShipSkillLevel = lua_tointeger(ShipData, 2);
	int myFort1 = lua_tointeger(ShipData, 3);
	int myFort2 = lua_tointeger(ShipData, 4);
	int myFort3 = lua_tointeger(ShipData, 5);
    int enemyshipID = lua_tointeger(ShipData, 6);
	int enemyShipSkillLevel = lua_tointeger(ShipData, 7);
	int enemyFort1 = lua_tointeger(ShipData, 8);
	int enemyFort2 = lua_tointeger(ShipData, 9);
	int enemyFort3 = lua_tointeger(ShipData, 10);
	g_pBattle->setInitShipData(myshipID, myShipSkillLevel, myFort1, myFort2, myFort3, enemyshipID, enemyShipSkillLevel, enemyFort1, enemyFort2, enemyFort3);
    return 1;
}

int setShipDataInBossBattle(lua_State *ShipData)
{
	if (!g_pBattle)
	{
		return 0;
	}
	int shipID = lua_tointeger(ShipData, 1);
	int shipSkillLevel = lua_tointeger(ShipData, 2);
	int fort1 = lua_tointeger(ShipData, 3);
	int fort2 = lua_tointeger(ShipData, 4);
	int fort3 = lua_tointeger(ShipData, 5);
	g_pBattle->setInitShipData(shipID, shipSkillLevel, fort1, fort2, fort3);
	return 1;
}


//需求顺序: 敌我炮台，位置，炮台ID， 炮台子弹ID，炮台类型，等级，星域系数                      品质系数，攻击，生命值，防御，攻速，能量，造成伤害，免伤率 
int setFortData(lua_State *FortData)
{
    //int myFort = lua_toboolean(FortData, 1); //我方炮台 是返回1，不是返回0
	int myFort = lua_tointeger(FortData, 1);  //我方炮台 是返回0(左)，不是返回1(右)
	long nFortPos = lua_tointeger(FortData, 2); //炮台位置(上0， 中1， 下2）

	long nFortID  = lua_tointeger(FortData, 3); // 炮台ID
	long nBulletID = lua_tointeger(FortData, 4);//专用ID（子弹，图标）

	long nFortType = lua_tointeger(FortData, 5); // 炮台类型 ( 攻击型 0， 防御型 1， 技能型 2）
	long nFortLevel = lua_tointeger(FortData, 6); //炮台等级
	long nFortStarDomainCoe = lua_tointeger(FortData, 7); //炮台星域系数 【 Coe : 系数 （coefficient缩写）】
	long nFortSkillLevel = lua_tointeger(FortData, 8); // 技能等级
	//string strJsonPath = lua_tostring(FortData, 9);

 //   double fortAtk = lua_tonumber(FortData, 8);// 炮台攻击
	//double fortHp = lua_tonumber(FortData, 9); //炮台生命值
	//double fortDef = lua_tonumber(FortData, 10);//炮台防御
 //   double fortAtkCD = lua_tonumber(FortData, 11);//炮台攻速
	//double fortEnergy = lua_tonumber(FortData, 12);//炮台能量
	//double fortDamage = lua_tonumber(FortData, 13); //造成伤害
	//double fortAvoidDamage = lua_tonumber(FortData, 14);//免伤率
//    double fortQuality = lua_tonumber(FortData, 6); //炮台品质系数

	g_pBattle->setInitFortData(myFort, nFortPos, nFortID, nBulletID, nFortType, nFortLevel, nFortStarDomainCoe, nFortSkillLevel);
    
    return 1;
}

int battleUpdate(lua_State *Time)
{
	double delta = lua_tonumber(Time, 1);
	if (g_pBattle)
	{
		g_pBattle->update(delta);
	}
	return 0;
}

//bullet需求顺序:specialID, width, height
//static int setBulletData(lua_State *BulletData)
//{
//    int sepcialID = lua_tonumber(BulletData, 1);
//    int width = lua_tonumber(BulletData,2);
//    int height = lua_tonumber(BulletData,3);
//    return 1;
//}

int start_battle(lua_State *L)
{
	if (g_pBattle)
	{
		g_pBattle->startFight();
	}
	return 0;
}

int stop_battle(lua_State *L)
{
	if (g_pBattle)
	{
		g_pBattle->stopFight();
	}
	return 0;
}

int resume_battle(lua_State *L)
{
	if (g_pBattle)
	{
		g_pBattle->resumeFight();
	}
	return 0;
}

//制作成返回Lua的table
//压入number类型的数据
void set_field_number(lua_State *L, const char *key, double value)
{
	lua_pushstring(L, key);
	lua_pushnumber(L, value); // 把数字value压入栈
	lua_settable(L, -3);
}
//压入int类型的数据
void set_field_int(lua_State *L, const char *key, int value)
{
	lua_pushstring(L, key);
	lua_pushinteger(L, value); // 把value作为数字压入栈
	lua_settable(L, -3);
}

//压入string
void set_field_string(lua_State *L, const char *key, const char *value)
{
	lua_pushstring(L, key);
	lua_pushstring(L, value);
	lua_settable(L, -3);
}
//bool类型
void set_field_bool(lua_State *L, const char *key, const bool value)
{
	lua_pushstring(L, key);
	lua_pushboolean(L, value);
	lua_settable(L, -3);
}

// key 为 integer
void set_field_intByInt(lua_State *L, int key, int value)
{
	lua_pushinteger(L, key);
	lua_pushinteger(L, value);
	lua_settable(L, -3);
}

// key 为integer , double 值
void set_field_intByDouble(lua_State *L, int key, double value)
{
	lua_pushinteger(L, key);
	lua_pushnumber(L, value);
	lua_settable(L, -3);
}

//int query_bullets(lua_State *m_pStack)
//{
//    lua_newtable(m_pStack);
//    set_field_string(m_pStack, "bullet_type","bullet_phy");
//    set_field_number(m_pStack, "duration", 0.015);
//    set_field_number(m_pStack, "dx", 1);
//    set_field_number(m_pStack, "dy", 0);
//    set_field_number(m_pStack, "fort_id", 90101);
//    set_field_number(m_pStack, "id", 0000);
//    set_field_string(m_pStack, "name","hit");
//    set_field_number(m_pStack, "special_id", 90101);
//    set_field_number(m_pStack, "x", 1110);
//    set_field_number(m_pStack, "y", 460);
//    return 1;
//}

int getBattleTime(lua_State *L)
{
	if (!g_pBattle)
	{
		return 0;
	}
	lua_newtable(L);
	set_field_int(L, "time", g_pBattle->getBattleTime());
	return 1;
}

int getFighterData(lua_State *L)
{
	if (!g_pBattle)
	{
		return 0;
	}
	lua_newtable(L);
	set_field_number(L, "playerMaxHp", g_pBattle->getPlayer()->getMaxPlayerHp());
	set_field_number(L, "playerCurHp", g_pBattle->getPlayer()->getPlayerHp());
	set_field_number(L, "playerShipEnergy", g_pBattle->getPlayer()->getPlayerShipEnergy());
	if (g_pBattle->getBattleType() != 3)
	{
		set_field_number(L, "enemyMaxHp", g_pBattle->getEnemy()->getMaxEnemyHp());
		set_field_number(L, "enemyCurHp", g_pBattle->getEnemy()->getEnemyHp());
		set_field_number(L, "enemyShipEnergy", g_pBattle->getEnemy()->getEnemyShipEnergy());
	}
	return 1;
}

int fortBuffs(lua_State *L, CFort *pFort)
{
	lua_newtable(L);
	int buffCount = 0;
	//char buffIndex[10];
	
	if (pFort->isAckUpState()) 
	{
		buffCount += 1;       
		set_field_intByInt(L, buffCount, Buff::FORT_ATK_ENHANCE); // 火力增幅
	}
	if (pFort->isRepairingState())
	{
		buffCount += 1;
		set_field_intByInt(L, buffCount, Buff::FORT_REPAIRING);  // 维修状态
	}
	if (pFort->isShieldState())
	{
		buffCount += 1;
		set_field_intByInt(L, buffCount, Buff::FORT_SHIELD); // 护盾状态
	}
	if (pFort->isPassiveSkillStrongerState())
	{
		buffCount += 1;
		set_field_intByInt(L, buffCount, Buff::FORT_PASSIVE_SKILL_STRONGER);//被动技能增强状态
	}
	if (pFort->isParalysisState())
	{
		buffCount += 1;
		//sprintf_s(buffIndex, "%d", buffCount);
		//set_field_int(L, buffIndex, Buff::FORT_PARALYSIS);  
		set_field_intByInt(L, buffCount, Debuff::FORT_PARALYSIS); // 瘫痪状态
	}
	if (pFort->isBurningState())
	{
		buffCount += 1;
		set_field_intByInt(L, buffCount, Debuff::FORT_BURNING);  // 燃烧状态
	}
	if (pFort->isAckDownState())
	{
		buffCount += 1;     
		set_field_intByInt(L, buffCount, Debuff::FORT_ATK_DISTURB); // 火力干扰
	}

	if (pFort->isUnrepaireState())
	{
		buffCount += 1;
		set_field_intByInt(L, buffCount, Debuff::FORT_REPAIR_DISTURB);  // 维修干扰
	}
	if (pFort->isUnEnergyState())
	{
		buffCount += 1; 
		set_field_intByInt(L, buffCount, Debuff::FORT_ENERGY_DISTURB); // 能量干扰
	}
	if (pFort->isBreakArmorState())
	{
		buffCount += 1;
		set_field_intByInt(L, buffCount, Debuff::FORT_BREAK_ARMOR);  // 破甲
	}

	return 1;
}

int fortData(lua_State *L, CFort *pFort)
{
	if (!g_pBattle)
	{
		return 0;
	}
	lua_newtable(L);
	set_field_int(L, "fortID", pFort->getFortID());
	set_field_int(L, "fortIndex", pFort->getFortIndex());
	set_field_number(L, "maxHp", pFort->getFortMaxHp());
	set_field_number(L, "hp", pFort->getFortHp());
	set_field_number(L, "maxEnergy", pFort->getFortMaxEnergy());
	set_field_number(L, "energy", pFort->getFortEnergy());
	set_field_number(L, "bulletID", pFort->getFortBulletID());
	set_field_number(L, "x", pFort->getFortPosX());
	set_field_number(L, "y", pFort->getFortPosY());
	set_field_bool(L, "is_live", pFort->isFortLive());

	//lua_pushstring(L, "buffs");
	//fortBuffs(L, pFort);
	//lua_settable(L, -3);

	return 1;
}

int playerFortData(lua_State *L)
{
	if (!g_pBattle)
	{
		return 0;
	}
	lua_newtable(L);
	map<int, CFort*> mapPlayerFort = g_pBattle->getPlayer()->getShip()->getFortMgr()->getPlayerFort();
	for (int i =1; i < 4; i++)
	{
		fortData(L, mapPlayerFort[i-1]);
		lua_pushinteger(L, i);
		lua_pushvalue(L, -2);
		lua_settable(L, -4);
		lua_pop(L, 1);
	}

	return 1;
}

int enemyFortData(lua_State *L)
{
	if (!g_pBattle)
	{
		return 0;
	}
	lua_newtable(L);
	map<int, CFort*> mapEnemyFort = g_pBattle->getEnemy()->getShip()->getFortMgr()->getEnemyFort();
	for (int i = 0; i < 3; i++)
	{
		fortData(L, mapEnemyFort[i]);
		lua_pushinteger(L, i + 1);
		lua_pushvalue(L, -2);
		lua_settable(L, -4);
		lua_pop(L, 1);
	}
	return 1;
}

int bulletData(lua_State *L, CBullet* pBullet)
{ 
	lua_newtable(L);
	set_field_int(L, "bulletID", pBullet->getBulletID());
	set_field_int(L, "bulletIndex", pBullet->getBulletIndex());
	set_field_int(L, "fortIndex", pBullet->getFortIndex());
	set_field_bool(L, "owner_isEnemy", pBullet->isEnemy());
	set_field_number(L, "x", pBullet->getBulletPosX());
	set_field_number(L, "y", pBullet->getBulletPosY());
	return 1;
}

int playerBulletData(lua_State *L)
{
	if (!g_pBattle)
	{
		return 0;
	}
	lua_newtable(L);
	int nowPBulletCount = 1;
	map<int, CBullet*> mapPlayerBullet = g_pBattle->getPlayer()->getBulletMgr()->getPlayerBullet();
	map<int, CBullet*>::iterator iter = mapPlayerBullet.begin();
	for (; iter != mapPlayerBullet.end(); iter++)
	{
		bulletData(L, (*iter).second);
		lua_pushinteger(L, nowPBulletCount++);
		lua_pushvalue(L, -2);
		lua_settable(L, -4);
		lua_pop(L, 1);
	}
	return 1;
}

int enemyBulletData(lua_State *L)
{
	if (!g_pBattle)
	{
		return 0;
	}
	lua_newtable(L);
	int nowEBulletCount = 1;
	map<int, CBullet*> mapEnemyBullet = g_pBattle->getEnemy()->getBulletMgr()->getEnemyBullet();
	map<int, CBullet*>::iterator iter = mapEnemyBullet.begin();
	for (; iter != mapEnemyBullet.end(); iter++)
	{
		bulletData(L, (*iter).second);
		lua_pushinteger(L, nowEBulletCount++);
		lua_pushvalue(L, -2);
		lua_settable(L, -4);
		lua_pop(L, 1);
	}
	return 1;
}

int hitSingleBulletData(lua_State *L, sHitBullet *pHitBullet)
{
	lua_newtable(L);
	set_field_bool(L, "isEnemy", pHitBullet->isEnemy);
	set_field_int(L, "bulletID", pHitBullet->nBulletID);
	set_field_int(L, "bulletIndex", pHitBullet->nBulletIndex);
	set_field_number(L, "x", pHitBullet->x);
	set_field_number(L, "y", pHitBullet->y);
	return 1;
}

int hitBulletsData(lua_State *L)
{
	if (!g_pBattle)
	{
		return 0;
	}
	lua_newtable(L);
	int nHitBulletCount = 1;
	map<int, sHitBullet*> mapHitBullet = g_pBattle->getHitBulletMap();
	map<int, sHitBullet*>::iterator iter = mapHitBullet.begin();
	for (; iter != mapHitBullet.end(); iter++)
	{
		hitSingleBulletData(L, (*iter).second);
		lua_pushinteger(L, nHitBulletCount++);
		lua_pushvalue(L, -2);
		lua_settable(L, -4);
		lua_pop(L, 1);
	}
	g_pBattle->cleanHitBulletMap();
	return 1;
}

int energyBodyData(lua_State *L) // 能量体还需要一段动画时间，待定。jump的动画，type的change动画。待定。
{
	if (!g_pBattle || !g_pBattle->isEnergyBodyLive())
	{
		return 0;
	}
	lua_newtable(L);
	set_field_int(L, "energyType", g_pBattle->getEnergyBody()->getBodyType());
	set_field_number(L, "maxHp", g_pBattle->getEnergyBody()->getBodyMaxHp());
	set_field_number(L, "hp", g_pBattle->getEnergyBody()->getBodyHp());
	set_field_number(L, "x", g_pBattle->getEnergyBody()->getBodyPosX());
	set_field_number(L, "y", g_pBattle->getEnergyBody()->getBodyPosY());
	if (g_pBattle->getEnergyBody()->getPlayerDamage() > g_pBattle->getEnergyBody()->getEnemyDamage())
	{
		set_field_int(L, "buffGetter", 1);
	}
	else if (g_pBattle->getEnergyBody()->getPlayerDamage() < g_pBattle->getEnergyBody()->getEnemyDamage())
	{
		set_field_int(L, "buffGetter", 2);
	}
	else if (g_pBattle->getEnergyBody()->getPlayerDamage() == g_pBattle->getEnergyBody()->getEnemyDamage())
	{
		set_field_int(L, "buffGetter", 3);
	}
	return 1;
}

int energyBodyEventData(lua_State *L, sEnergyBodyEvent* pEnergyEvent)
{
	lua_newtable(L);
	set_field_int(L, "eventType", pEnergyEvent->nEventType);
	set_field_int(L, "energyType", pEnergyEvent->nBodyType);
	set_field_int(L, "x", pEnergyEvent->nBodyPosX);
	set_field_int(L, "y", pEnergyEvent->nBodyPosY);
	// buff的归属方
	if (pEnergyEvent->dPlayerDamage > pEnergyEvent->dEnemyDamage)  // 我方（左）
	{
		set_field_int(L, "buffGetter", 1);
	}
	else if (pEnergyEvent->dPlayerDamage < pEnergyEvent->dEnemyDamage) // 敌方（右）
	{
		set_field_int(L, "buffGetter", 2);
	}
	else if (pEnergyEvent->dPlayerDamage == pEnergyEvent->dEnemyDamage) // 相等
	{
		set_field_int(L, "buffGetter", 3);
	}

	return 1;
}

int energyBodyEvent(lua_State *L)
{
	if (!g_pBattle )//|| !g_pBattle->isEnergyBodyLive()
	{
		return 0;
	}
	lua_newtable(L);
	int nCountEvent = 1;
	vector<sEnergyBodyEvent*> vecEnergyBodyEvent = g_pBattle->getEnergyBodyEventVec();
	vector<sEnergyBodyEvent*>::iterator iter = vecEnergyBodyEvent.begin();
	for (; iter != vecEnergyBodyEvent.end(); iter++)
	{
		energyBodyEventData(L, *iter);
		lua_pushinteger(L, nCountEvent++);
		lua_pushvalue(L, -2);
		lua_settable(L, -4);
		lua_pop(L, 1);
	}
	g_pBattle->cleanEnergyEventVec();
	return 1;
}

int fortEvent(lua_State *L, CFort *pFort)        //vector<int> vecEvent
{
	lua_newtable(L);
	vector<int> vecEvent = pFort->getFortEventVec();
	if (vecEvent.size() <= 0)
	{
		return 0;
	}
	
	vector<int>::iterator iter = vecEvent.begin();
	for (; iter != vecEvent.end(); iter++)
	{
		if (*iter == FortEvent::FORT_FIRE)
		{
			set_field_intByInt(L, FortEvent::FORT_FIRE, 0);
		}
		else if (*iter == FortEvent::FORT_SKILL)
		{
			if (pFort->getFortSkill()->getTargetFort())
			{
				set_field_intByInt(L, FortEvent::FORT_SKILL, pFort->getFortSkill()->getTargetFort()->getFortIndex());
			}
			else
			{
				set_field_intByInt(L, FortEvent::FORT_SKILL, -1);
			}
		}
		else if (*iter == FortEvent::FORT_SKILL_END)
		{
			set_field_intByInt(L, FortEvent::FORT_SKILL_END, 0);
		}
		else if (*iter == FortEvent::FORT_ENERGY_ADD_HP)
		{
			set_field_intByDouble(L, FortEvent::FORT_ENERGY_ADD_HP, pFort->getMomentAddHp());
			pFort->recoverAddHp(0.0);
		}
		else if (*iter == FortEvent::FORT_PROP_ADD_HP)
		{
			set_field_intByDouble(L, FortEvent::FORT_PROP_ADD_HP, pFort->getPropAddHp());
			pFort->recoverPropAddHp(0.0);
		}
		else if (*iter == FortEvent::FORT_CONTINUE_ADD_HP)
		{
			set_field_intByDouble(L, FortEvent::FORT_CONTINUE_ADD_HP, pFort->getContinueAddHp());
			pFort->recoverContinueAddHp(0.0);
		}
		else if (*iter == FortEvent::FORT_SKILL_ADD_HP)
		{
			set_field_intByDouble(L, FortEvent::FORT_SKILL_ADD_HP, pFort->getSkillAddHp());
			pFort->recoverSkillAddHp(0.0);
		}
		else if (*iter == FortEvent::FORT_SELF_ADD_ENERGY)
		{
			set_field_intByDouble(L, FortEvent::FORT_SELF_ADD_ENERGY, pFort->getSelfAddEnergy());
			pFort->recoverSelfAddEnergy(0.0);
		}
		else if (*iter == FortEvent::FORT_ENERGY_ADD_ENERGY)
		{
			set_field_intByDouble(L, FortEvent::FORT_ENERGY_ADD_ENERGY, pFort->getEnergyAddEnergy());
			pFort->recoverEnergyAddEnergy(0.0);
		}
		else if (*iter == FortEvent::FORT_PROP_ADD_ENERGY)
		{
			set_field_intByDouble(L, FortEvent::FORT_PROP_ADD_ENERGY, pFort->getPropAddEnergy());
			pFort->recoverPropAddEnergy(0.0);
		}
		else if (*iter == FortEvent::FORT_ATTACK_ADD_ENERGY)
		{
			set_field_intByDouble(L, FortEvent::FORT_ATTACK_ADD_ENERGY, pFort->getAttackAddEnergy());
			pFort->recoverAttackAddEnergy(0.0);
		}
		else if (*iter == FortEvent::FORT_BE_DAMAGE_ADD_ENERGY)
		{
			set_field_intByDouble(L, FortEvent::FORT_BE_DAMAGE_ADD_ENERGY, pFort->getBeDamageAddEnergy());
			pFort->recoverBeDamageAddEnergy(0.0);
		}
		else if (*iter == FortEvent::FORT_BULLET_DAMAGE)
		{
			set_field_intByDouble(L, FortEvent::FORT_BULLET_DAMAGE, pFort->getBulletDamage());
			pFort->recoverBulletDamage(0.0);
		}
		else if (*iter == FortEvent::FORT_PROP_BULLET_DAMAGE)
		{
			set_field_intByDouble(L, FortEvent::FORT_PROP_BULLET_DAMAGE, pFort->getPropBulletDamage());
			pFort->recoverPropBuleltDamage(0.0);
		}
		else if (*iter == FortEvent::FORT_BUFF_BURN_DAMAGE)
		{
			set_field_intByDouble(L, FortEvent::FORT_BUFF_BURN_DAMAGE, pFort->getBuffBurnDamage());
			pFort->recoverBuffBurnDamage(0.0);
		}
		else if (*iter == FortEvent::FORT_NPC_DAMAGE)
		{
			set_field_intByDouble(L, FortEvent::FORT_NPC_DAMAGE, pFort->getNPCDamage());
			pFort->recoverNPCDamage(0.0);
		}
		else if (*iter == FortEvent::FORT_SKILL_DAMAGE)
		{
			set_field_intByDouble(L, FortEvent::FORT_SKILL_DAMAGE, pFort->getSkillDamage());
			pFort->recoverSkillDamage(0.0);
		}
		else if (*iter == FortEvent::FORT_DEEP_DAMAGE)
		{

		}
		else if (*iter == FortEvent::FORT_BE_DEEP_DAMAGE)
		{
			set_field_intByDouble(L, FortEvent::FORT_BE_DEEP_DAMAGE, pFort->getSkillDamage());
			pFort->recoverSkillDamage(0.0);
		}
		else if (*iter == FortEvent::FORT_DIE)
		{
			set_field_intByInt(L, FortEvent::FORT_DIE, 0);
		}
		else if (*iter == FortEvent::FORT_RELIVE_COOLDOWN)
		{
			set_field_intByDouble(L, FortEvent::FORT_RELIVE_COOLDOWN, pFort->getReliveCountDown());
		}
		else if (*iter == FortEvent::FORT_RELIVE)
		{
			set_field_intByInt(L, FortEvent::FORT_RELIVE, 0);
		}
		else if (*iter == FortEvent::FORT_SHIP_SKILL_ADD_HP)
		{
			set_field_intByDouble(L, FortEvent::FORT_SHIP_SKILL_ADD_HP, pFort->getShipSkillAddHp());
			pFort->recoverShipSkillAddHp(0.0);
		}
		else if (*iter == FortEvent::FORT_SHIP_SKILL_ADD_ENERGY)
		{
			set_field_intByDouble(L, FortEvent::FORT_SHIP_SKILL_ADD_ENERGY, pFort->getShipSkillAddEnergy());
			pFort->recoverShipSkillAddEnergy(0.0);
		}
		else if (*iter == FortEvent::FORT_SHIP_SKILL_DAMAGE)
		{
			set_field_intByDouble(L, FortEvent::FORT_SHIP_SKILL_DAMAGE, pFort->getShipSkillDamage());
			pFort->recoverShipSkillDamage(0.0);
		}
	}
	pFort->cleanFortEventVec();
	return 1;
}

int playerFortEvent(lua_State *L)
{
	if (!g_pBattle)
	{
		return 0;
	}
	lua_newtable(L);
	//set_field_int(L, "test", 1);
	//set_field_intByDouble(L, 2, 13); 

	if (g_pBattle->getPlayer()->getShip()->getFortMgr()->isPlayerCleanBetterBuff())
	{
		set_field_int(L, "cleanGoodBuff", FortEvent::FORT_EVENT_CLEAN_GOOD_BUFF);
		g_pBattle->getPlayer()->getShip()->getFortMgr()->recoveryCleanBetterBuff();
	}
	if (g_pBattle->getPlayer()->getShip()->getFortMgr()->isPlayerCleanBadBuff())
	{
		set_field_int(L, "cleanBadBuff", FortEvent::FORT_EVENT_CLEAN_BAD_BUFF);
		g_pBattle->getPlayer()->getShip()->getFortMgr()->recoveryCleanBadBuff();
	}
	map<int, CFort*> mapPlayerFort = g_pBattle->getPlayer()->getShip()->getFortMgr()->getPlayerFort();
	map<int, CFort*>::iterator iter = mapPlayerFort.begin();
	for (; iter != mapPlayerFort.end(); iter++)
	{
		fortEvent(L, (*iter).second);             //  ->getFortEventVec()
		lua_pushinteger(L, (*iter).second->getFortIndex() + 1);//(*iter).second->getFortID()
		lua_pushvalue(L, -2);
		lua_settable(L, -4);
		lua_pop(L, 1);
	}
	return 1;
}

int enemyFortEvent(lua_State *L)
{
	if (!g_pBattle)
	{
		return 0;
	}
	lua_newtable(L);
	if (g_pBattle->getEnemy()->getShip()->getFortMgr()->isEnemyCleanBetterBuff())
	{
		set_field_int(L, "cleanGoodBuff", FortEvent::FORT_EVENT_CLEAN_GOOD_BUFF);
		g_pBattle->getEnemy()->getShip()->getFortMgr()->recoveryCleanBetterBuff();
	}
	if (g_pBattle->getEnemy()->getShip()->getFortMgr()->isEnemyCleanBadBuff())
	{
		set_field_int(L, "cleanBadBuff", FortEvent::FORT_EVENT_CLEAN_BAD_BUFF);
		g_pBattle->getEnemy()->getShip()->getFortMgr()->recoveryCleanBadBuff();
	}
	map<int, CFort*> mapEnemyFort = g_pBattle->getEnemy()->getShip()->getFortMgr()->getEnemyFort();
	map<int, CFort*>::iterator iter = mapEnemyFort.begin();
	for (; iter != mapEnemyFort.end(); iter++)
	{
		fortEvent(L, (*iter).second);
		lua_pushinteger(L, (*iter).second->getFortIndex() + 1);
		lua_pushvalue(L, -2);
		lua_settable(L, -4);
		lua_pop(L, 1);
	}
	return 1;
}

int restartBattle(lua_State *L)
{
	if (!g_pBattle)
	{
		return 0;
	}
	char* battleData = (char*)lua_tostring(L, 1);

	g_pBattle->setAllBattleData(battleData);

	return 1;
}

int synchordataBattle(lua_State *L)
{
	if (!g_pBattle)
	{
		return 0;
	}
	char* battleData = (char* )lua_tostring(L, 1);
	g_pBattle->synchronizationData(battleData);
	return 1;
}

int deleteBattle(lua_State *L)
{
	if (!g_pBattle)
	{
		return 0;

	}
	delete(g_pBattle);
	g_pBattle = nullptr;
	
	return 1;
}

int setEnergyBodyRoad(lua_State *L)
{
	if (!g_pBattle)
	{
		return 0;
	}
	string freshTime = lua_tostring(L, 1);
	string energyData = lua_tostring(L, 2);
	g_pBattle->setEnergyTimeString(freshTime);
	g_pBattle->setEnergyBodyRoad(energyData);
	return 1;
}

int playerBuffEvent(lua_State *L)
{
	if (!g_pBattle)
	{
		return 0;
	}
	lua_newtable(L);
	vector<sBuffEvent> buffEvent = g_pBattle->getPlayer()->getBuffMgr()->getPlayerBuffEvent();
	if (buffEvent.size() > 0)
	{
		for (int i = 0; i < buffEvent.size(); i++)
		{
			lua_newtable(L);
			set_field_intByInt(L, buffEvent[i].nBuffID, buffEvent[i].nBuffFort);
			lua_pushinteger(L, i + 1);
			lua_pushvalue(L, -2);
			lua_settable(L, -4);
			lua_pop(L, 1);
		}
	}
	g_pBattle->getPlayer()->getBuffMgr()->cleanBuffEventVec();
	return 1;
}

int enemyBuffEvent(lua_State *L)
{
	if (!g_pBattle)
	{
		return 0;
	}
	lua_newtable(L);
	vector<sBuffEvent> buffEvent = g_pBattle->getEnemy()->getBuffMgr()->getEnemyBuffEvent();
	if (buffEvent.size() > 0)
	{
		for (int i = 0; i < buffEvent.size(); i++)
		{
			lua_newtable(L);
			set_field_intByInt(L, buffEvent[i].nBuffID, buffEvent[i].nBuffFort);
			lua_pushinteger(L, i + 1);
			lua_pushvalue(L, -2);
			lua_settable(L, -4);
			lua_pop(L, 1);
		}
	}
	g_pBattle->getEnemy()->getBuffMgr()->cleanBuffEventVec();
	return 1;
}

int propEvent(lua_State *L)
{
	if (!g_pBattle)
	{
		return 0;
	}
	lua_newtable(L);
	vector<sPropEvent> propEvent = g_pBattle->getPropMgr()->getPropEventVec();
	if (propEvent.size() > 0)
	{
		for (int i = 0; i < propEvent.size(); i++)
		{
			lua_newtable(L);
			set_field_intByInt(L, propEvent[i].nPropEventID, propEvent[i].nTarget);
			lua_pushinteger(L, i + 1);
			lua_pushvalue(L, -2);
			lua_settable(L, -4);
			lua_pop(L, 1);
		}
	}
	g_pBattle->getPropMgr()->cleanPropEvent();
	return 1;
}

int shipSkillEvent(lua_State *L)
{
	if (!g_pBattle)
	{
		return 0;
	}
	lua_newtable(L);
	if (g_pBattle->getPlayer()->isPlayerShipFireSkill())
	{
		set_field_intByInt(L, 1, 0);
		g_pBattle->getPlayer()->setShipSkillFire(false);
	}
	if (g_pBattle->getBattleType() == 0 && g_pBattle->getEnemy()->isEnemyShipFireSkill())
	{
		set_field_intByInt(L, 2, 0);
		g_pBattle->getEnemy()->setShipSkillFire(false);
	}
	return 1;
}

int fortFireSkill(lua_State *L)  // 参数：敌（我）方炮台， 炮台ID
{
	if (!g_pBattle)
	{
		return 0;
	}
	int nSize = lua_tointeger(L, 1);  // 是我方炮台，返回1，不是为2
	int nFortID = lua_tointeger(L, 2);
	string strBuffPer = lua_tostring(L, 3);
	//double dSkillTime = lua_tonumber(L, 3);
	g_pBattle->fortSkillFire(nSize, nFortID, strBuffPer);
	return 1;
}

int useProp(lua_State *L)
{
	if (!g_pBattle)
	{
		return 0;
	}
	int nUser = lua_tointeger(L, 1);
	int nPropID = lua_tointeger(L, 2);
	int nTarget = lua_tointeger(L, 3);
	int nFortID = lua_tointeger(L, 4);
	g_pBattle->useProp(nUser, nPropID, nTarget, nFortID);
	return 1;
}

int useShipSkill(lua_State *L)
{
	if (!g_pBattle)
	{
		return 0;
	}
	int nUser = lua_tointeger(L, 1);
	g_pBattle->useShipSkill(nUser);
	return 1;
}

int setBossNpcBuffRoad(lua_State *L)
{
	if (!g_pBattle)
	{
		return 0;
	}
	string strData = lua_tostring(L, 1);
	g_pBattle->getBoss()->splitNpcBuffRoad(strData);
	return 1;
}

int bossEvent(lua_State *L)
{
	if (!g_pBattle)
	{
		return 0;
	}
	lua_newtable(L);
	CBoss *pBoss = g_pBattle->getBoss();
	vector<int> vecEvent = g_pBattle->getBoss()->getBossEvent();
	//if (vecEvent.size() <= 0)
	//{
	//	return 0;
	//}
	vector<int>::iterator iter = vecEvent.begin();
	for (; iter != vecEvent.end(); iter++)
	{
		if (*iter == BossEvent::BOSS_FIRE)
		{
			set_field_intByInt(L, BossEvent::BOSS_FIRE, 0);
		}
		else if (*iter == BossEvent::BOSS_SKILL_BEGIN)
		{
			set_field_intByInt(L, BossEvent::BOSS_SKILL_BEGIN, 0);
		}
		else if (*iter == BossEvent::BOSS_SKILL_FIRE)
		{
			set_field_intByInt(L, BossEvent::BOSS_SKILL_FIRE, 0);
		}
		else if (*iter == BossEvent::BOSS_CALL_NPC_SKILL)
		{
			set_field_intByInt(L, BossEvent::BOSS_CALL_NPC_SKILL, pBoss->getNpcType());
		}
		else if (*iter == BossEvent::BOSS_CALL_NPC_BACK)
		{
			set_field_intByInt(L, BossEvent::BOSS_CALL_NPC_BACK, 0);
		}
		else if (*iter == BossEvent::BOSS_BE_DAMAGE_BY_BULLET)
		{
			set_field_intByDouble(L, BossEvent::BOSS_BE_DAMAGE_BY_BULLET, pBoss->getBulletDamageNumber());
		}
		else if (*iter == BossEvent::BOSS_BE_DAMAGE_BY_FORT_SKILL)
		{
			set_field_intByDouble(L, BossEvent::BOSS_BE_DAMAGE_BY_FORT_SKILL, pBoss->getFortSkillDamageNumber());
		}
		else if (*iter == BossEvent::BOSS_BE_DAMAGE_BY_NPC)
		{
			set_field_intByDouble(L, BossEvent::BOSS_BE_DAMAGE_BY_NPC, pBoss->getNpcDamageNumber());
		}
		else if (*iter == BossEvent::BOSS_BE_DAMAGE_BY_PROP)
		{
			set_field_intByDouble(L, BossEvent::BOSS_BE_DAMAGE_BY_PROP, pBoss->getPropDamageNumber());
		}
		else if (*iter == BossEvent::BOSS_BE_DAMAGE_BY_SHIP_SKILL)
		{
			set_field_intByDouble(L, BossEvent::BOSS_BE_DAMAGE_BY_SHIP_SKILL, pBoss->getShipSkillDamageNumber());
		}
		else if (*iter == BossEvent::BOSS_CHANGE_STAGE_ONE)
		{
			set_field_intByInt(L, BossEvent::BOSS_CHANGE_STAGE_ONE, 0); 
		}
		else if (*iter == BossEvent::BOSS_CHANGE_STAGE_TWO)
		{
			set_field_intByInt(L, BossEvent::BOSS_CHANGE_STAGE_TWO, 0);
		}
		else if (*iter == BossEvent::BOSS_CHANGE_STAGE_OVER)
		{
			set_field_intByInt(L, BossEvent::BOSS_CHANGE_STAGE_OVER, 0);
		}
        else if (*iter == BossEvent::BOSS_BE_DEEP_DAMAGE_BY_FORT_SKILL)
        {
            set_field_intByDouble(L, BossEvent::BOSS_BE_DEEP_DAMAGE_BY_FORT_SKILL, pBoss->getFortSkillDamageNumber());
        }
	}
	pBoss->recoveryNumber();
	pBoss->cleanBossEventVec();
	return 1;
}

int playerAddDamage(lua_State *L)
{
	double addPercent = lua_tonumber(L, 1);
	g_pBattle->addInjuryPercent(addPercent);
	return 1;
}

int getBossStage(lua_State *L)
{
	lua_newtable(L);
	int nBossStage = g_pBattle->getBoss()->getBossStage();
	set_field_int(L, "bossStage", nBossStage);
	return 1;
}

int getBossTotalDamage(lua_State *L)
{
	lua_newtable(L);
	set_field_number(L, "totalDamage", g_pBattle->getBoss()->getBossTotalDamage());
	return 1;
}

//int testForWorkPath(lua_State *L)
//{
//	if (!g_pBattle)
//	{
//		return 0;
//	}
//	lua_newtable(L);
//	g_pBattle->decodeWrongCodeJsonFileData();
//	//const char* workPath = g_pBattle->testForWorkPath();
//	//map<int, int> mapTestData = g_pBattle->testForJson;
//	////set_field_string(L, "path", workPath);
//	//map<int, int>::iterator iter = mapTestData.begin();
//	//for (; iter != mapTestData.end(); iter++)
//	//{
//	//	set_field_int(L, "success", (*iter).first);
//	//	set_field_int(L, "wrongCode", (*iter).second);
//	//}
//	set_field_string(L, "workPath", g_pBattle->getFilePathInAndroid());
//	return 1;
//}

const struct luaL_Reg reg_info[] =
{
	{"enterBattle", enterBattle},
	{"enterBossBattle", enterBossBattle},
	{"start", start_battle},
	{"stop", stop_battle},
	{"setShipData", setShipData},// 参数：player战舰ID， 战舰技能等级， 炮台1， 炮台2， 炮台3， enemy战舰ID， 战舰技能等级， 炮台1， 炮台2， 炮台3
	{"setShipDataInBossBattle", setShipDataInBossBattle},
	{"setFortData", setFortData},

	{"update", battleUpdate},
	{"time", getBattleTime},
	{"getFighterData", getFighterData },
	//{"query_bullets", query_bullets},
	{"playerFortData", playerFortData},
	{"enemyFortData", enemyFortData},
	{"playerBulletData", playerBulletData},
	{"enemyBulletData", enemyBulletData},
	{"hitBulletData", hitBulletsData},
	{"energyBodyData", energyBodyData},   // 能量体不在时table返回给lua 是nil
	{"energyBodyEvent", energyBodyEvent},
	{"playerFortEvent", playerFortEvent},
	{"enemyFortEvent", enemyFortEvent},

	{"restartBattle", restartBattle},
	{"synchordataBattle", synchordataBattle},
	{"deleteBattle", deleteBattle},
	{"setEnergyBodyRoad", setEnergyBodyRoad},

	{"fortFireSkill", fortFireSkill},// 参数：bool：我方true， 敌方false、 炮台ID
	{"useProp", useProp},            // 参数：使用方：1，player；2，enemy 、道具ID、 目标方：1， player；2， enemy 、 炮台ID
	{"useShipSkill", useShipSkill},  // 参数：使用方：1，player；2，enemy
	{"playerBuffEvent", playerBuffEvent},
	{"enemyBuffEvent", enemyBuffEvent},
	{"propEvent", propEvent},   // 道具ID = 對象。對象：（左邊）0(全体及能量体）， 1， 2， 3、 （右邊）10(全体及能量体）， 11， 12， 13
	{"shipSkillEvent", shipSkillEvent},  // player 释放战舰技能  1 = 0、 enemy释放战舰节能  2 = 0.

	// boss
	{"setBossNpcBuffRoad", setBossNpcBuffRoad}, // 暂时没用
	{"bossEvent", bossEvent},
	{"playerAddDamage", playerAddDamage},
	{"getBossStage", getBossStage},
	{"getBossTotalDamage", getBossTotalDamage},
	//{"synchronizationBossBattle", synchronizationBossBattle},

	//{"phoneOpenFileTest", phoneOpenFileTest}, // 给lua端测试json文件读取。
	//{"testForWorkPath", testForWorkPath}, //给lua端测试当前json value 获取
    
    {NULL,NULL}
};

extern "C" int luaopen_libpower(lua_State *L)
{
#if LUA_VERSION_NUM > 501
    luaL_newlib(L, reg_info);
    return 1;
#else
    luaL_openlib(L, "newBattle", reg_info, 0);
    return 0;
#endif
}
