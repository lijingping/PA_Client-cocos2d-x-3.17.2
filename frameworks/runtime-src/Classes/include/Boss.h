#pragma once
#include <vector>
#include <string>
#include "Bullet.h"
#include "Event.h"
#include "BulletMgr.h"

using namespace std;

class CBattle;

class CBoss
{
public:
	enum bossStage
	{
		ONE_STAGE,
		TWO_STAGE,
		THREE_STAGE
	};
	CBoss(string strDataPath, CBattle *pBattle, int nPlayer, int bossID);
	~CBoss();
	void init();
	void update(double delta);
	void loadBossData(string strBossDataPath);// distinguish client and server
	void splitNpcBuffRoad(string strData);

	void createBossBullet(int nBulletIndex, double dTime);// 重连
	void addBossEvent(int nEvent); // 重连

	CBulletMgr* getBossBulletMgr();

	vector<int> getBossEvent();
	vector<CBullet*> getBossBullet();

	// 设置全服玩家数
	//void setAllPlayerNumber(int nPlayer);

	void cleanBossEventVec();
	void cleanBossBulletVec();
	// 普通子弹攻击玩家炮台
	void bulletDamagePlayer();
	// 技能
	void bossSkillBurst();
	void oneStageSkill();
	void twoStageSkill();
	void finalSkill();

	// boss切换状态时的数据转换
	void changeDataToNextStage();
	// boss开始切换状态
	void bossChangeBegin();
	// 设置对战炮台瘫痪
	void setFortParalysis();
	// 炮台恢复状态
	void recoverFortState();
	// 切换状态结束
	void bossChangeOver();
	// 召唤NPC攻击玩家
	void NpcFight();
	// 锁定npc携带的buff
	int chooseNpcBuff(int nKind);

	// boss 受击
	void bossBeDamageByBullet(double dDamage);
	void bossBeDamageByFortSkill(double dDamage);
	void bossBeDamageByNPC(double dDamage);
	void bossBeDamageByProp(double dDamage);
	void bossBeDamageByShipSkill(double dDamage);
    void bossBeDeepDamageByFortSkill(double dDamage);

	// boss的免伤率
	double getBossUninjuryRate();
	// 返回boss被击总血量
	double getBossTotalDamage();

	// 作显示事件调用的数据接口
	double getBulletDamageNumber();
	double getFortSkillDamageNumber();
	double getNpcDamageNumber();
	double getPropDamageNumber();
	double getShipSkillDamageNumber();
	int getNpcType();

	// 恢复数据（获取显示的数据之后）
	void recoveryNumber();

	void setNumberData(double dBullet, double dFortSkill, double dNpc, double dProp, double dShipSkill, int nNpcType);

//------------------------------------------
	       // 重连
//------------------------------------------
	double getBossAck();
	int getBossStage();
	double getTotalDamage();
	bool isInChange();
	bool isFire();
	double getBossTotalTime();
	double getFireTime();
	double getStageTime();
	double getStageTiming();
	int getCountBullet();
	// 免伤率
	double getChangeTime();
	double getNpcTime();
	bool isNpcFlying();
	double getNpcFlyTime();
	int getCountNpc();
	double getFireInterval();
	bool isBossSkill();
	double getBossSkilling();
	double getSkillBurstTime();
	// speed
	double getFireSkillCondition();
	double getBulletBurstTime();

	void cntSetBossAck(double dBossAck);
	void cntSetBossStage(int nBossStage);
	void cntSetTotalDamage(double dTotalDamage);
	void cntIsInChange(int nIs);
	void cntIsFire(int nIs);
	void cntSetBossTotalTime(double dTotalTime);
	void cntSetFireTime(double dTime);
	void cntSetStageTime(double dTime);
	void cntSetStageTiming(double dTime);
	void cntSetCountBullet(int nBulletCount);
	void cntSetChangeTime(double dTime);
	void cntSetNpcTime(double dTime);
	void cntIsNpcFlying(int nIs);
	void cntSetNpcFlyTime(double dTime);
	void cntSetCountNpc(int nCount);
	void cntSetFireInterval(double dInterval);
	void cntIsBossSkill(int nIs);
	void cntSetBossSkilling(double dTime);
	void cntSetSkillBurstTime(double dTime);
	void cntSetFireSkillCondition(double dNumber);
	void cntSetBulletBurstTime(double dTime);

private:
	CBattle *m_pBossBattle;
	CBulletMgr *m_pBossBulletMgr;

	int m_nBossID;
	int nBuffRoad[10];

	int m_nAllPlayer;       // 全服玩家数

	double m_dBossAck;		// boss的攻击力
	int m_nBossStage;		// boss的阶段
	double m_dTotalDamage;	// boss受到的总伤害
	bool m_isInChange;		// 是否切换状态
	bool m_isFire;			// 发射子弹
	double m_dBossTotalTime;// 总时间
	double m_dFireTime;		// 计算普通攻击的发射时间
	double m_dStageTime;    // 现阶段的状态总时间
	double m_dStageTiming;	// 状态时间
	int m_nCountBullet;		// 统计子弹
	double m_dInjuryRate;	// 免伤率
	double m_dChangeTime;	// 变身时间
	double m_dNpcTime;		// 召唤NPC时间
	bool m_isNpcFlying;     // NPC在场
	double m_dNpcFlyTime;	// NPC开火时间记录
	int m_nCountNpc;        // 统计NPC出场次数
	double m_dFireInterval;	//普通子弹开火间隔
	bool m_isBossSkill;     // boss是否在释放技能
	double m_dBossSkilling; // 计算boss技能时间
	double m_dSkillBurstTime;	 // 技能释放到技能产生伤害的时间
	double m_dBossBulletSpeed;   // boss 子弹速度
	double m_dFireSkillCondition;// 技能发射条件
	double m_dDataBulletBurstTime;// 普通子弹,开火到计算伤害的时间

	double m_dBossHp;
	double m_dDataOneAckConst;    //常数
	double m_dDataOneAckBase;	  //基数
	double m_dDataOneAckTime;	  //倍数
	double m_dDataOneAckMax;	  //上限
	double m_dDataOneFireInterval;//攻击间隔
	double m_dDataOneFireTime;    //攻击时间
	double m_dDataTwoAckConst;	  //常数
	double m_dDataTwoAckBase;	  //基数
	double m_dDataTwoAckTime;	  //倍数
	double m_dDataTwoAckMax;	  //上限
	double m_dDataTwoFireInterval;//攻击间隔
	double m_dDataTwoFireTime;    //攻击时间
	double m_dDataStageOneTime;   //状态1的时间
	double m_dDataStageTwoTime;	  // 状态2的时间
	double m_dDataChangeOneTime;  // 状态1的变换时间
	double m_dDataChangeTwoTime;  // 状态2的变换时间

	double m_dDataFireSkillCondition1; // 阶段1发射技能条件（普攻次数）
	double m_dDataFireSkillCondition2; // 阶段2发射技能条件（普攻次数）

	double m_dDataSkillBurstTime1;	// 技能1释放到技能产生伤害的时间
	double m_dDataSkillBurstTime2;	// 技能2释放到技能产生伤害的时间
	double m_dDataSkillBurstTime3;	// 技能3释放到技能产生伤害的时间
	double m_dDataSkillDamageMultiple1; // 技能1 的伤害倍数
	double m_dDataSkillDamageMultiple2; // 技能2 的伤害倍数
	double m_dDataSkillDamageMultiple3; // 技能3 的伤害倍数
	double m_dDataSkillBuffTime1;   // 技能1 的buff持续时间
	double m_dDataSkillBuffTime2;   // 技能2 的buff持续时间


	double m_dDataCallNpcTime;   // 召唤NPC的时间 (25秒)
	double m_dDataNpcFireTime;   // NPC召唤出来后到开火的时间
	int m_nDataNpcBuff1_kind;    // buff1 的类型
	double m_dDataNpcBuff1_value;// buff1 的效果值
	double m_dDataNpcBuff1_time; // buff1 的时间
	int m_nDataNpcBuff2_kind;    // buff2 的类型
	double m_dDataNpcBuff2_value;// buff2 的buff值
	double m_dDataNpcBuff2_time; // buff2 的时间
	int m_nDataNpcBuff3_kind;    // buff3 的类型
	double m_dDataNpcBuff3_value;// buff3 的buff值
	double m_dDataNpcBuff3_time; // buff3 的时间
	double m_dDataNpcDamageMultiple; // npc伤害倍数

	double m_dDataBulletSpeed1;  // boss状态1的子弹速度   （默认1000)
	double m_dDataBulletSpeed2;  // boss状态2的子弹速度

	vector<int> m_vecBossEvent;
	vector<CBullet*> m_vecBossBullet;

	double m_dDamageByBullet;
	double m_dDamageByFortSkill;
	double m_dDamageByNpc;
	double m_dDamageByProp;
	double m_dDamageByShipSkill;
	int m_nNpcType;
};

