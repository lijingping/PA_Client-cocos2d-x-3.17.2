#pragma once

#ifndef EVENT_H
#define EVENT_H

#include "stdafx.h"

enum EnergyEvent
{
	ENERGY_BORN = 0,    // 能量体生成
	ENERGY_CHANGE = 1,  // 能量体转变
	ENERGY_JUMP = 2,    // 能量体跃迁
	ENERGY_GO_DIE = 3   // 能量体爆炸
};

struct sEnergyBodyEvent
{
	sEnergyBodyEvent()
	{
		nEventType = 0;
		nBodyType = 0;
		dBodyHp = 0.0;
		dPlayerDamage = 0.0;
		dEnemyDamage = 0.0;
		nBodyPosX = 0.0;
		nBodyPosY = 0.0;
	}
	int nEventType;
	int nBodyType;
	double dBodyHp;
	double dPlayerDamage;
	double dEnemyDamage;
	int nBodyPosX;
	int nBodyPosY;
};

enum FortEvent
{
	FORT_FIRE = 1,				 // 炮台发射子弹            
	// 技能
	FORT_SKILL = 2,				 // 炮台释放技能
	FORT_SKILL_END = 3,			 // 炮台释放技能结束
	// 加血
	FORT_ENERGY_ADD_HP = 4,		 // 炮台(能量体）加血     （值）   
	FORT_PROP_ADD_HP = 5,        // 道具加血              （值）
	FORT_CONTINUE_ADD_HP = 6,    // 持续回血              （值）
	FORT_SKILL_ADD_HP = 7,       // 技能回血              （值）
	// 能量
	FORT_SELF_ADD_ENERGY = 8,    // 炮台自身能量添加      （值）
	FORT_ENERGY_ADD_ENERGY = 9,	 // 炮台加能量(能量体)    （值）
	FORT_PROP_ADD_ENERGY = 10,    // 炮台道具加能         （值）
	FORT_ATTACK_ADD_ENERGY = 11, // 炮台攻击加能量        （值）
	FORT_BE_DAMAGE_ADD_ENERGY = 12, // 炮台被击加能量     （值）
	// 扣血
	FORT_BULLET_DAMAGE = 13,     // 子弹伤害扣血          （值）
	FORT_PROP_BULLET_DAMAGE = 14,// 道具炮弹伤害          （值）
	FORT_BUFF_BURN_DAMAGE = 15,  // 燃烧buff伤害          （值）
	FORT_NPC_DAMAGE = 16,        // NPC伤害               （值）
	FORT_SKILL_DAMAGE = 17,      // 技能傷害              （值）

	FORT_DEEP_DAMAGE = 18,       // 发射多百分50伤害
	FORT_BE_DEEP_DAMAGE = 19,    // 被额外百分50伤害         

	FORT_DIE = 20,				 // 炮台死亡 
	FORT_RELIVE_COOLDOWN = 21,   // 炮台复活倒计时(0-10s) (值）
//	//     FORT_RECOVER = 4,        //炮台复活状态（10秒）状态为瞬时
	FORT_RELIVE = 22,            // 炮台复活
	FORT_EVENT_CLEAN_GOOD_BUFF = 23,   // 炮台清空增益buff（敌方全体，或者我方全体）
	FORT_EVENT_CLEAN_BAD_BUFF = 24,   //炮台清空减益buff

	// 战舰技能
	FORT_SHIP_SKILL_ADD_HP = 25,    //加血
	FORT_SHIP_SKILL_ADD_ENERGY = 26,//加能量
	FORT_SHIP_SKILL_DAMAGE = 27     //伤害（扣血）

};

enum BossEvent
{
	BOSS_FIRE = 1,                   // boss普攻
	
	BOSS_SKILL_BEGIN = 2,            // boss技能开始
	BOSS_SKILL_FIRE = 3,             // boss技能爆破
	//BOSS_SKILL_2_BEGIN = 4,          // 技能1
	//BOSS_SKILL_2_FIRE = 5,           //
	//BOSS_SKILL_3_BEGIN = 6,          //

	BOSS_CALL_NPC_SKILL = 4,         // boss召唤npc
	BOSS_CALL_NPC_BACK = 5,          // boss呼唤npc回去

	BOSS_BE_DAMAGE_BY_BULLET = 6,    // 子弹伤害
	BOSS_BE_DAMAGE_BY_FORT_SKILL = 7,// 技能伤害
	BOSS_BE_DAMAGE_BY_NPC = 8,       // NPC 伤害
	BOSS_BE_DAMAGE_BY_PROP = 9,      // 道具伤害
	BOSS_BE_DAMAGE_BY_SHIP_SKILL = 10,//战舰技能伤害

	BOSS_CHANGE_STAGE_ONE = 11,      // 切换状态1
	BOSS_CHANGE_STAGE_TWO = 12,      // 切换状态2
	BOSS_CHANGE_STAGE_OVER = 13,     // 切换状态完成
    // ADD
    BOSS_BE_DEEP_DAMAGE_BY_FORT_SKILL = 14
};

struct sBuffEvent
{
	sBuffEvent()
	{
		nBuffID = 0;
		nBuffFort = 0;
	}
	int nBuffID;
	int nBuffFort;
};

enum buffEvent
{
	ACK_UP_BUFF_ADD = 1,          // 添加火力增幅
	REPAIRING_BUFF_ADD = 2,       // 添加持续维修
	SHIELD_BUFF_ADD = 3,          // 添加护盾
	PASSIVE_SKILL_STRONGER_BUFF_ADD = 4,// 添加被动技能增强
	PARALYSIS_BUFF_ADD = 5,       // 添加瘫痪
	BURNING_BUFF_ADD = 6,         // 添加燃烧
	ACK_DOWN_BUFF_ADD = 7,        // 添加火力干扰
	REPAIR_DISTURB_BUFF_ADD = 8,  // 添加维修干扰
	ENERGY_DISTURB_BUFF_ADD = 9,  // 添加能量干扰
	BREAK_ARMOR_BUFF_ADD = 10,    // 添加破甲
	UNMISSILE_BUFF_ADD = 11,      // 添加反导弹

	ACK_UP_BUFF_DELETE = 21,      // 删除火力增幅
	REPAIRING_BUFF_DELETE = 22,   // 删除持续维修
	SHIELD_BUFF_DELETE = 23,      // 删除护盾
	PASSIVE_SKILL_STRONGER_BUFF_DELETE = 24, // 删除被动技能增强
	PARALYSIS_BUFF_DELETE = 25,   // 删除瘫痪
	BURNING_BUFF_DELETE = 26,     // 删除燃烧
	ACK_DOWN_BUFF_DELETE = 27,    // 删除火力干扰
	REPAIR_DISTURB_BUFF_DELETE = 28, // 删除维修干扰
	ENERGY_DISTURB_BUFF_DELETE = 29, // 删除能量干扰
	BREAK_ARMOR_BUFF_DELETE = 30, // 删除破甲
	UNMISSILE_BUFF_DELETE = 31,   // 删除反导弹
};

struct sPropEvent
{
	sPropEvent()
	{
		nPropEventID = 0;
		nTarget = 0;
	}
	int nPropEventID;
	int nTarget;
};

enum propEvent
{
	USE_ARMOR_PIERCING_SHELL = 1,    //穿甲弹（伤害加破甲）
	USE_BURN_SHELL = 2,               //燃烧弹
	USE_DISTURB_SHELL = 3,             //干扰弹（瘫痪）
	USE_UNENERGY_SHELL = 4,             //禁能弹（能量干扰）
	USE_DEEP_DAMAGE_SHELL = 5,           //强袭导弹（伤害）
	USE_DAMAGE_SHIP_SHELL = 6,            //对舰导弹（全体伤害）
	USE_ACK_UP_PROP = 7,                   //火力增幅
	USE_FORT_REPAIRING_PROP = 8,            //战损维修（持续维修）
	USE_SHIELD_PROP = 9,                     //能量护盾（护盾）
	USE_PASSIVE_SKILL_STRONG_PROP = 10,       //战术技能强化
	USE_ACK_DOWN_PROP = 11,                  //火力干扰
	USE_UNREPAIRING_PROP = 12,              //维修干扰
	USE_RELIVE_FORT_PROP = 13,             //战损修复（复活炮台）
	USE_CHARGE_FORT_PROP = 14,            //炮台充能（恢复能量）
	USE_DESTORY_ENERGY_BODY_PROP = 15,   //摧毁能量体
	USE_LOCK_ENERGY_BODY_PROP = 16,     //锁定能量体
	USE_JUMP_ENERGY_BODY_PROP = 17,    //能量体跃迁
	USE_ALL_FIRE_PROP = 18,           //火力全开（全体火力增幅）
	USE_ABSOLUTE_ZONE_PROP = 19,     //绝对领域（护盾）
	USE_LIMIT_CHARGE_PROP = 20,       //极限充能（满能量）
	USE_UNMISSILE_PROP = 21,           //反导弹条约（禁用导弹）
	USE_CLEAN_BUFF_PROP = 22,           //净化程式（清除buff）
	USE_EMP_UNENERGY_PROP = 23,          //EMP震荡波（全体能量干扰）
	USE_RADIATION_UNREPAIRING_PROP = 24,  //辐射震荡波（全体维修干扰）
	CALL_NPC_BY_PROP = 1408,                //呼叫支援（呼叫NPC）（道具）
	//CALL_NPC_BY_ENERGY = 26,                //呼叫支援（呼叫NPC）（能量体）

	BURST_ARMOR_PIERCING_SHELL = 51,          //穿甲弹爆炸
	BURST_BURN_SHELL = 52,                   //燃烧弹爆炸
	BURST_DISTURB_SHELL = 53,               //干扰弹爆炸
	BURST_UNENERGY_SHELL = 54,             //禁能弹爆炸
	BURST_DEEP_DAMAGE_SHELL = 55,         //强袭弹爆炸
	BURST_DAMAGE_SHIP_SHELL = 56,        //对舰弹爆炸

	NPC_BACK = 75                      //NPC返程
};

#endif // EVENT_H
