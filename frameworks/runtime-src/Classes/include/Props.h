#pragma once
#include "json/json.h"
#include <fstream>
#include <string>
#include <sstream>

using namespace std;

class CBattle;
class CProps
{
public:
	CProps(CBattle *pBattle, string jsonStr, int propID);
	~CProps();

	int update(double delta);
	void initData();
	void burstProps();
	void loadDataByJson(string jsonStr, int propID);

	// nUser : (使用道具者) 1 player, 2 enemy;
	// return 1:即时道具，无播放时间。 return 2:有动画道具。return 3：当前有NPC在场。return 错误代码。
	int isUseProp(int nUser, int nPlayer, int nFortID, string wrongCodePath);   // player 为1，代表player  nplayer为2， 代表enemy
	int getPropID();
	int getUserNum();
	int getTargetNum();
	int getTargetFortID();

	void setEnergyNpcDamage(double damage);

	double getTotalAck(int nSide); // 1 : player    2 : enemy

	void armorPiercingShell();  //穿甲弹
	void burnShell();        // 燃烧弹
	void disturbShell();     // 干扰弹
	void unenergyShell();    //禁能弹
	void deepDamageShell();  //强袭导弹
	void damageShipShell();  //对舰导弹
	void ackUpProp();      //火力增幅道具
	void fortRepairingProp();//战损维修道具
	void shieldProp();          //护盾道具
	void passiveSkillStrongProp();//战术技能增强道具
	void ackDownProp();          //火力干扰道具
	void unrepairingProp();      //维修干扰道具
	void reliveFortProp();       //损毁修复道具
	void chargeFortProp();       //炮台充能道具
	void destoryEnergyBodyProp();//能量崩溃（摧毁能量体）道具
	void lockEnergyBodyProp();   //能量锁定（能量体不再变化）道具
	void energyBodyJumpProp();   //能量跃迁（能量体转移到其他火力线上）道具
	void allFireProp();          //火力全开道具（火力增幅）
	void absoluteZoneProp();     //绝对领域（护盾）
	void limitChargeProp();   //极限充能（百分百能量）
	void unmissileProp();       //反导弹道具（）
	void cleanBuffProp();       //净化程式（清除减益buff or 增益buff）
	void EMPunenergyProp();     //EMP震荡波（无法充能和释放技能）
	void radiationUnrepairingProp();//辐射震荡波（无法恢复血量）
	void callNPCtoFight();       //呼叫NPC 

	// -------------
	void setPropID(int nPropID);
	double getPropBurstTime();
	void setPropBurstTime(double dBurstTime);
	void setUser(int nUser);
	void setTargetSide(int nTarget);
	void setTargetFort(int nTargetFort);
	double getEnergyNpcDamage();

private:
	int m_nPropID;    //-
	CBattle *m_pPropBattle;
	int m_nMissileOrNot;
	double m_dPropDamagePercent;
	double m_dPropBuffTime;
	double m_dPropBurstTime;  //-
	double m_dPropBuffValue;

	int m_nUser;           //
	int m_nTargetSide;      //
	int m_nTargetFort;       //

	double m_dEnergyNpcDamage;  //

	int m_nPropBuffType;
};

