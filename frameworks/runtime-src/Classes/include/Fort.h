#pragma once
#ifndef fort_h
#define fort_h

#include "Shape.h"
#include "InitialData.h"
#include "BuffMgr.h"
#include "Event.h"
#include "FortSkill.h"
#include <vector>

using namespace std;

class CBattle;

class CFort          // : public CShape
{
public:
	CFort(bool isEnemy, int fortIndex, string wrongCodePath);
	~CFort();

	enum FortType
	{
		ATTACK_TYPE = 0,
		DEFENSE_TYPE = 1,
		SKILL_TYPE = 2
	};

	void update(double dt);

	CFortSkill * getFortSkill();

	//void createFort(bool isEnemy, int fortIndex);
	void setFortID(int ID);
// 伤害炮台
	double damageFort(double damage);   // damage 都是先扣完免伤率再带进来的
	// 子弹伤害
	void damageFortByBullet(double damage); 
	// 技能伤害
	void damageFortBySkillBurst(double damage);
	// 技能加重额外伤害
	void damageFortBySkillAddDamage(double damage);
	// NPC伤害
	void damageFortByNPC(double damage);
	// 燃烧伤害
	void percentDamage(double percent);
	// 道具炮弹伤害
	void damageFortByPropBullet(double dDamage);
	// 真实伤害
	void trueDamageFort(double damage);
	// 战舰技能百分比伤害
	void damageFortByShipSkill(double dDamage);

	void fortDie();
// 增加血量
	void addHp(double hp);
	// 技能加血
	void addHpBySkill(double percent);
	// 战舰技能加血
	void addHpByShipSkill(double percent);

// 设置炮台的数据

			//long nFortID = lua_tointeger(FortData, 3); // 炮台ID
			//long nBulletID = lua_tointeger(FortData, 4);//专用ID（子弹，图标）

			//long nFortType = lua_tointeger(FortData, 5); // 炮台类型
			//long nFortLevel = lua_tointeger(FortData, 6); //炮台等级
			//long nFortStarDomainCoe = lua_tointeger(FortData, 7); //炮台星域系数 
	void setFortData(int nFortID, int nBulletID, int nFortType, int nLevel, int nFortStarDomain, int nSkillLevel, string strPathJson);

	double getQualityCoeByLevel(int nLevel);
	
// 设置炮台的位置
	void setFortPos(int posX, int posY);

	void setFortBulletID(int fortID);
// 设置炮台的尺寸（大小）
	void fortSizeByID(int fortID);

// 能量
	void addEnergy(double value);
	// 技能型炮台的被动
	void addEnergySelf(); 
	// 能量体添加能量
	void addEnergyByEnergy(double value);
	// 伤害加能量（攻击(1)与被击(2)）
	void addEnergyByDamage(double dDamage, int nType);
	// 道具加能量
	void addEnergyByProp(double value);
	// 战舰技能加能量
	void addEnergyByShipSkill(double percent);

	int fortSkillFireBegin(string strBuffPer); // 技能
	void fortSkillFireEnd();
	const char * getIsAddBuff(); // 获取是否添加Buff的值

	int getFortBulletID();

	int getFortIndex();
	double getFortAck();
	 
	// 判断炮台是否存在
	bool isFortLive();
	int getFortID();
	double getFortHp();
	// 获取炮台初始化最大血量
	double getFortMaxHp();
	double getFortEnergy();
	double getFortMaxEnergy();

	int getFortPosX();
	int getFortPosY();

	bool isFire();

	//炮台复活(战舰技能复活炮台并加百分20血和百分百能量)
	void fortBeLiveByShipSkill(double dPercent);
	
	double getUnInjuryCoe();// 获取免伤率计算伤害。（因为攻击炮台和受击炮台都要有能量回复）

	void cleanFortEventVec();
	vector<int> getFortEventVec();

	double getMomentAddHp();
	void recoverAddHp(double dHp);

	double getSkillAddHp();
	void recoverSkillAddHp(double dHp);

	double getPropAddHp();
	void recoverPropAddHp(double dHp);

	double getContinueAddHp();
	void recoverContinueAddHp(double dHp);

	double getSelfAddEnergy();
	void recoverSelfAddEnergy(double dEnergy);

	double getEnergyAddEnergy();
	void recoverEnergyAddEnergy(double dEnergy);

	double getPropAddEnergy();
	void recoverPropAddEnergy(double dEnergy);

	double getAttackAddEnergy();
	void recoverAttackAddEnergy(double dEnergy);

	double getBeDamageAddEnergy();
	void recoverBeDamageAddEnergy(double dEnergy);

	double getBulletDamage();
	void recoverBulletDamage(double dDamage);

	double getPropBulletDamage();
	void recoverPropBuleltDamage(double dDamage);

	double getBuffBurnDamage();
	void recoverBuffBurnDamage(double dDamage);

	double getNPCDamage();
	void recoverNPCDamage(double dDamage);

	double getSkillDamage();
	void recoverSkillDamage(double dDamage);

	double getReliveCountDown();

	double getShipSkillDamage();
	void recoverShipSkillDamage(double dDamage);

	double getShipSkillAddHp();
	void recoverShipSkillAddHp(double dHp);

	double getShipSkillAddEnergy();
	void recoverShipSkillAddEnergy(double dEnergy);

	void setFortBattle(CBattle *pBattle);
	void initFortSkill(int nSkillLevel, string strPath, double starDomainCoe);
	void setHaveSuitBuff(bool is, double suitBuffValue);

	void injuryAdditionInBossBattle(double dPercent);

public:
	void fortNormalState();
	void fortParalysisState();  // 瘫痪
	void fortBurningState();    // 燃烧
	void fortAckEnhanceState(double buffValue);
	void fortAckDisturbState(double buffValue);
	void fortRepaire(double percent);          // 
	void fortRepaireByEnergy(double percent);  // 能量體恢復
	void fortRepairing();
	void fortUnrepaire();
	void fortSupplyEnergy(double value);
	void fortUnEnergy();
	void fortShield(double percent);
	void fortRelive(double dPercent);
	//void fortDestroy();  // 对炮台额外的百分50的伤害
	void fortBreakArmorState(); // 破甲状态
	void fortPassiveSkillStrongerState();// 增强被动技能

	void recoveryParalysis();
	void recoveryBurning();
	void recoveryAckUp();
	void recoveryAckDown();
	void recoveryEnergy();
	void recoveryRepairing();
	void recoveryUnrepaire();
	void recoveryUnEnergy();
	void recoveryShield();
	void recoveryFortBadBuff();
	void recoveryFortGoodBuff();
	void recoveryFortBreakArmorBuff();
	void recoveryFortPassiveSkillBuff();

	bool isParalysisState(); // 瘫痪
	bool isBurningState();   // 燃烧
	bool isAckUpState();     // 火力增幅
	bool isAckDownState();   // 火力干扰
	bool isRepairingState(); // 维修
	bool isUnrepaireState(); // 维修干扰
	bool isUnEnergyState();  // 能量干扰
	bool isShieldState();    // 护盾
	bool isReliveState();    // 复活状态
	bool isSkillingState();  // 技能状态
	bool isBreakArmorState();// 破甲状态
	bool isPassiveSkillStrongerState();// 增强被动技能状态

private:
	vector<int> m_vecFortEvent;    // 事件容器（即时增益buff和炮台动作）

	bool m_isEnemy;
	int m_nFortIndex;
	int m_nFortID;	
	int m_nFortBulletID;
	int m_nFortType;
	int m_nFortLevel;
	// 星域系数
	double m_dFortStarDomainCoe;
	// 品质系数
	double m_dFortQualityCoe;
	// 攻击成长系数
	double m_dFortAckGrowCoe;
	// 生命成长系数
	double m_dFortHpGrowCoe;
	// 攻速系数
	double m_dFortSpeedCoe;
	// 能量系数
	double m_dFortEnergyCoe;

	double m_dHp;
	double m_dEnergy;
	double m_dInterval;
	double m_dUnInjuryRate;
	double m_dFortDamage;

	int m_nPosX;
	int m_nPosY;
	bool m_isLive;
	double m_dFireTime;
	bool m_isFire; // 没用

	CBattle *m_pFortBattle;
	CFortSkill *m_pFortSkill;

	string m_strWrongCodePath;
	bool m_isHaveSuitBuff;     //在一开始设置ship数据的时候赋值的，所以，重连无需赋值。
	double m_dSuitBuffValue;

private:   // 初始数值
	double m_dInitAck;
	double m_dInitHp;
	double m_dInitEnergy;
	double m_dInitDefense;
	double m_dInitUnInjuryRate;
	double m_dInitDamage;
	
	bool m_isAddPassiveSkill;  // 检测被动技能只添加一次（攻擊型炮臺）

private:
	bool m_isFortParalysis;   // 瘫痪
	bool m_isFortBurning;    // 燃烧
	bool m_isFortAckUp;      // 火力增幅

	bool m_isFortAckDown;    // 火力干扰
	bool m_isFortRepairing;  // 持续维修
	bool m_isFortUnrepaire;  // 维修干扰
	bool m_isFortUnEnergy;     // 能量
	bool m_isFortShield;
	bool m_isFortRelive;

	bool m_isFortSkillFire;
	bool m_isFortBreakArmor;    // 破甲
	bool m_isFortPassiveSkillStronger; // 被动技能增强
	bool m_isHavePassiveSkillStronger;

	double m_dBurningCountTime;
	double m_dRepairingCountTime;
	double m_dReliveCountDown;
	double m_dReliveHp;
	double m_dAckDownValue;
	double m_dAckUpValue;

	double m_dAddPassiveEnergyTime;  // 技能型炮台被动加能量时间
	
	// 為顯示而生的變量
private:
	double m_dMomentAddHp;      // 瞬间回血           ·
	double m_dSkillAddHp;       // 技能回血
	double m_dPropAddHp;        // 道具的瞬間回血     ·
	double m_dContinueAddHp;    // 持續回血           ·
	double m_dSelfAddEnergy;    // 自身添加的能量     ·
	double m_dEnergyAddEnergy;  // 能量體添加的能量體 ·
	double m_dPropAddEnergy;    // 道具添加能量       ·
	double m_dAttackAddEnergy;  // 攻擊添加的能量     ·
	double m_dBeDamageAddEnergy;// 被擊添加的能量     ·
	double m_dBulletDamage;     // 子弹伤害
	double m_dPropBulletDamage; // 道具炮弹伤害
	double m_dBuffBurnDamage;   // 燃烧buff伤害
	double m_dNPC_Damage;       // NPC伤害
	//double m_dSecondCountForRelive;// 复活时间一秒发一次

	double m_dSkillDamage;      // 技能傷害
	double m_dSkillTime;
	double m_dShipSkillDamage;  // 战舰技能扣血
	double m_dShipSkillAddHp;   // 战舰技能加血
	double m_dShipSkillAddEnergy;//战舰技能加能量

	//////////////////////////////////
	        // 断线连接与同步//
	//////////////////////////////////
public:
	void resetFortEventVec(int nEvent);
	//getFortEventVec is up.
	//setIsEnemy 其实不用，一开始初始化就有了，还要根据这个判断是哪边的那个炮台。
	bool isEnemy();
	//setFortIndex() 也不用，上0，中1， 下2，一开始设定好的标记。用这个FortIndex获取炮台管理的第几个炮台
	//getFortIndex() is up。
	//setFortID();炮臺ID
	//getFortID();
	//setFortBulletID();子彈ID
	//getFortBulletID();
	void resetFortType(int nFortType);  //炮臺類型
	int getFortType();
	void resetFortLevel(int nLevel);  // 炮臺等級
	int getFortLevel();
	void resetFortStarDomainCoe(double dStarDomainCoe); //星域係數
	double getStarDomainCoe();
	void resetFortQualityCoe(double dQualityCoe); //品质系数
	double getQualityCoe();
	void resetFortAckGrowCoe(double dAckGrowCoe); //攻击成长系数
	double getAckGrowCoe();
	void resetFortHpGrowCoe(double dHpGrowCoe); //生命成长系数
	double getHpGrowCoe();
	void resetFortSpeedCoe(double dSpeedCoe); //攻速系数
	double getSpeedCoe();
	void resetFortEnergyCoe(double dEnergyCoe); //能量系数
	double getEnergyCoe();
	void resetHp(double dHp); //血量
	//getFortHp()
	void resetEnergy(double dEnergy); //能量
	//getFortEnergy();
	void resetFortInterval(double dInterval); //发射子弹速度
	double getInterval();
	void resetUninjuryRate(double dUninjuryRate); //免伤率
	//double getUnInjuryCoe();
	void resetFortAck(double dAck); //炮台伤害
	//getFortAck()
	// setFortPos(x, y)   getFortPosX()   getFortPosY(); // 炮台坐标
	void resetFortLife(bool isLife); //炮台是否存活状态
	//isFortLive();
	void resetFireTime(double dFireTime); //炮台当前射击停留的时间
	double getFireTime();
	void resetInitAck(double dAck); // 初始化攻擊力，計算都用傷害，攻擊力并不用，其實可以不用。
	double getInitAck();
	void resetInitHp(double dInitHp); //初始化血量（最大血量）
	//double geMaxtFortHp();
	//初始化能量為100；初始化時就有了，此處不寫了
	void resetDefense(double dDefense); //用於計算免傷率，其實有免傷率，這個就不用了。
	double getDefense();
	void resetInitUnInjuryRate(double dRate); //初始化免傷率
	double getInitUnInjuryRate();
	void resetInitDamage(double dInitDamage); //初始化傷害值
	double getInitDamage();
	void resetAddPassiveSkill(bool isAdd); //技能型炮臺的被動技能檢測
	bool isAddPassiveSkill();
	void resetFortParalysis(bool isParalysis); // 干擾狀態
	void resetFortBurning(bool isBurning); // 燃燒狀態
	void resetAckUp(bool isAckUp); // 火力增幅

	void resetAckDown(bool isAckDown);// 火力干扰
	void resetRepairing(bool isRepairing);// 维修
	void resetUnrepaire(bool isUnrepaire);// 维修干扰
	void resetUnEnergy(bool isUnenergy);// 能量干扰
	void resetShield(bool isShield);// 护盾
	void resetRelive(bool isRelive);// 炮台复活
	void resetSkillFire(bool isSkillFire);//释放技能
	void resetBreakArmor(bool isBreakArmor);// 破甲
	void resetPassiveSkillStronger(bool isPassiveSkillStronger);//被动技能
	bool isHavePassiveSkillStronger();          
	void resetHavePassiveSkillStronger(bool isHave);
	double getBurningCountTime();
	void setBurningCountTime(double dTime);
	double getRepairingCountTime();
	void setRepairingCountTime(double dTime);

	void setReliveCountDown(double dTime);
	double getReliveHp();
	void setReliveHp(double dHp);
	double getAckDownValue();
	void setAckDownValue(double dValue);
	double getAckUpValue();
	void setAckUpValue(double dValue);
	double getAddPassiveEnergyTime();
	void setAddPassiveEnergyTime(double dTime);
	double getSecondCountForRelive();
	void setSecondCountForRelive(double dTime);
	double getSkillTime();
	void setSkillTime(double dTime);
}; 

#endif /* fort_h */

