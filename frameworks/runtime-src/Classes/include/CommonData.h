#pragma once

#define pai 3.14;

#define SYNTHE_SIZE(varType, varName, funName) \
protected: varType varName;\
public: virtual varType get##funName(void) const { return varName; }\
public: virtual void set##funName(varType var){ varName = var; }

/*#define CC_SYNTHESIZE(varType, varName, funName)\
protected: varType varName;\
public: virtual varType get##funName(void) const { return varName; }\
public: virtual void set##funName(varType var){ varName = var; }*/

#define BULLETSPEED 1000;
#define SHIPBULLETSPEED 1200;
#define PI 3.14159


enum EBattleType
{
	NORMAL_BATTLE = 1,
	CRASH_BATTLE = 2
};

//玩家类型
enum EPlayerKind
{
	SELF = 1,
	ENEMY = 2,
	END = ENEMY
};

enum EFortState
{
	FORT_FLY = 1,           //飞行状态
	FORT_PURSUIT_TARGET = 2,//追击目标
	FORT_ATTACK = 3,        //攻击状态

};

// 炮台攻击下的状态
enum EFortAttackState
{
	
	FORT_FIRE = 1,          //炮弹攻击状态
	FORT_SKILLING = 2,      //技能
};

// 炮台类型
enum EFortKinds
{
	NONE = 0,
	FORT_MACHINE = 1,       // 战士
	FORT_FIGHTSHIP = 2      // 战机
};

/*// 战机攻击方式
enum EFortFireTypes
{
	FORT_FIRE_BULLET = 1,    // 子弹
	FORT_FIRE_LIGHT = 2,     // 激光
};
*/

enum EFortBuffState
{
	FORT_ATK_ENHANCE = 1,     //火力增幅状态
	FORT_REPAIRING = 2,       //持续维修状态
	FORT_SHIELD = 3,          //护盾状态
	FORT_PASSIVE_SKILL_STRONGER = 4, //被动技能加强

};

enum EFortDebuffState
{
	FORT_PARALYSIS = 5,       //瘫痪状态
	FORT_BURNING = 6,         //燃烧状态
	FORT_ATK_DISTURB = 7,     //火力干扰状态
	FORT_REPAIR_DISTURB = 8,  //维修干扰状态
	FORT_ENERGY_DISTURB = 9,  //能量干扰状态
	FORT_BREAK_ARMOR = 10,	  //破甲状态
	PLAYER_UNMISSILE = 11     //禁用导弹
};

enum EShipFireKinds
{
	SINGLE_DAMAGE = 1,       //单头攻击
	DOUBLE_DAMAGE = 2        //双头（多头）攻击
};

enum EShootType   // 射击类型
{
	BULLET_SHELL = 1,  // 普通炮弹
	PIERCE_SHELL = 2,  // 穿透弹
	LASER_FIRE = 3,    // 激光
};

// 战舰的状态
enum EShipState
{ 
	NORMAL_STATE = 1,    // 普通状态
	FIRE_STATE = 2,      // 开火状态
	SKILLING_STATE = 3   // 技能状态
};

const int BATTLE_TIME = 180;     //战斗总时长
const int BATTLE_VIEW_WIDTH = 3000;//战斗场景宽 
const int BATTLE_VIEW_HEIGHT = 400;//战斗场景高
const double ONE_STEP_TIME = 0.017; // 计算一次战机行为时间间隔
const int FLY_TO_SHIP_DIS = 400; // 飞往战舰的最远距离

const int ENERGY_COUR_SPEED = 1; //能量回复速度(s)
const int ENERGY_MAX = 30;       //能量上限
const int MAX_ARMY_FORCE = 50;   //总兵力上限
const int ENERGY_QUICK_TIME = 60; //能量倍速恢复时间

const int SHIP_HP = 5000;        //战舰血量
const int SHIP_ATK = 150;        //战舰伤害
const int SHIP_FIRE_INTERVAL = 1;//战舰攻击间隔
const int SHIP_MAX_ENERGY = 100; //战舰能量上限
const int SELF_SHIP_POS_X = 250; //左战舰x坐标
const int SHIP_POS_Y = 200;      //战舰y坐标
const int HOST_SHIP_POS_X = BATTLE_VIEW_WIDTH - SELF_SHIP_POS_X;//右战舰x坐标
//const int SHIP_HALF_WIDTH = 150; // 战舰一半的宽

const int CREATE_FORT_RANGE_X = 200; //创建战机x坐标的范围
const int CREATE_FORT_BEGIN_X = 150; //创建战机x坐标起点

const int MAX_FORT_CARD = 8;     //手牌种类数量
const int MAX_SCIENCE_CARD = 3;  //科技牌上限

