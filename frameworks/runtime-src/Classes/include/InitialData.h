#pragma once
#ifndef InitialData_h
#define InitialData_h

enum BattleType
{
	BATTLE_NORMAL = 0,
	BATTLE_EXPLORE = 1,
	BATTLE_ROB = 2,
	BATTLE_BOSS = 3,
	BATTLE_UNION = 4
};

enum ShipKind
{
	MY_SHIP,
	ENEMY_SHIP
};

enum ShipState
{
	SHIP_NORMAL_STATE = 0, //正常状态（无状态）
};

enum Buff
{
	FORT_ATK_ENHANCE = 1,     //火力增幅状态
	FORT_REPAIRING = 2,       //持续维修状态
	FORT_SHIELD = 3,          //护盾状态
	FORT_PASSIVE_SKILL_STRONGER = 4, //被动技能加强
};

enum Debuff
{
	FORT_PARALYSIS = 5,       //瘫痪状态
	FORT_BURNING = 6,         //燃烧状态
	FORT_ATK_DISTURB = 7,     //火力干扰状态
	FORT_REPAIR_DISTURB = 8,  //维修干扰状态
	FORT_ENERGY_DISTURB = 9,  //能量干扰状态
	FORT_BREAK_ARMOR = 10,	  //破甲状态
	PLAYER_UNMISSILE = 11     //禁用导弹
};

const int SCREEN_SIZE_WIDTH = 1280;
const int SCREEN_SIZE_HEIGHT = 720;

const int BATTLE_TIME = 180;

const int MYSHIP_POS_X = 150;
const int MYSHIP_POS_Y = SCREEN_SIZE_HEIGHT / 2;
const int ENEMYSHIP_POS_X = SCREEN_SIZE_WIDTH - MYSHIP_POS_X;
const int ENEMYSHIP_POS_Y = MYSHIP_POS_Y;
const int SHIP_WIDTH = 200;
const int SHIP_HALF_WIDTH = SHIP_WIDTH / 2;
const int SHIP_HEIGHT = SCREEN_SIZE_WIDTH - 40 * 2;

const int MYFORT_POS_X = MYSHIP_POS_X;
const int ENEMYFORT_POS_X = ENEMYSHIP_POS_X;
const int FORT_TOP_POS_Y = 540;
const int FORT_MID_POS_Y = 400;
const int FORT_BOT_POS_Y = 260;
const double FORT_RELIVE_TIME = 10.0;

const int BULLET_WIDTH = 40;
const int BULLET_HEIGHT = 40;

const int FORT_WIDTH = 100;
const int FORT_HEIGHT = 100;

const int ENERGY_WIDTH = 80;
const int ENERGY_HEIGHT = 80;

const int ENERGY_POS_X = SCREEN_SIZE_WIDTH / 2;
const int ENERGY_POS_Y_TOP = FORT_TOP_POS_Y;
const int ENERGY_POS_Y_MID = FORT_MID_POS_Y;
const int ENERGY_POS_Y_BOT = FORT_BOT_POS_Y;

const double NPC_ANIM_TIME = 3.7;
const int NPC_OUT_TIME = 3;

//

// 炮台品质系数
const double FORT_QUALITY_D = 0.6;
const double FORT_QUALITY_C = 0.8;
const double FORT_QUALITY_B = 1.0;
const double FORT_QUALITY_A = 1.1;
const double FORT_QUALITY_S = 1.2;

// 炮台攻击力成长系数（按类型）   coe 为 coefficient缩写（译：系数）
const double AckFORT_AckCOE = 1.3;
const double DefFORT_AckCOE = 1.2;
const double SkiFORT_AckCOE = 1.1;

// 炮台生命成长系数（按类型）
const double AckFORT_HpCOE = 1;
const double DefFORT_HpCOE = 1.3;
const double SkiFORT_HpCOE = 1.2;

// 炮台攻速系数（按类型）（单位：秒）
const double AckFORT_SpeCOE = 0.6;
const double DefFORT_SpeCOE = 1.2;
const double SkiFORT_SpeCOE = 0.9;

// 炮台能量系数（按类型）
const double AckFORT_EneCOE = 1.0;
const double DefFORT_EneCOE = 1.0;
const double SkiFORT_EneCOE = 2.5;
struct wrongCodeData
{
	wrongCodeData()
	{
		nSuccess = 0;
		nError = 0;
		nFortDie_skill = 0;
		nFortParalysis_skill = 0;
		nFortUnenergy = 0;
		nFortEnergyNotEnough = 0;
		nFortSkilling = 0;
		nPropNotEnough = 0;
		nPlayerUnmissile = 0;
		nFortDieProp = 0;
		nFortIsLifeRelive = 0;
		nEnergyIsDie = 0;
		nFortUnenergyProp = 0;
		nFortUnrepaireProp = 0;
		nFortArmorProp = 0;
		nSurrenderField = 0;
	}
	int nSuccess;
	int nError;
	int nFortDie_skill;
	int nFortParalysis_skill;
	int nFortUnenergy;
	int nFortEnergyNotEnough;
	int nFortSkilling;
	int nPropNotEnough;
	int nPlayerUnmissile;
	int nFortDieProp;
	int nFortIsLifeRelive;
	int nEnergyIsDie;
	int nFortUnenergyProp;
	int nFortUnrepaireProp;
	int nFortArmorProp;
	int nSurrenderField;
};

#endif /* InitialData_h */