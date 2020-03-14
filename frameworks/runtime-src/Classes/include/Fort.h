#pragma once

#include <math.h>

#include <vector>
#include "Event.h"

#include "BaseData.h"

using namespace std;

class CBattle;

class CFort:public CBaseData
{
public:
	CFort();
	CFort(int fortSide, int nFortID, int nFortLv, CBattle *pBattle);
	~CFort();

	void init();
	void setBattlePoint(CBattle* pBattle);
	void update(double dTime);
	void setPosition(int nPosX, int nPosY);

	void justFly(double dTime);
	void flyToTarget(double dTime);
	void beHurtByShipBullet(double dInjury);
	void beHurtByFortBullet(double dInjuty, int nFirerID, int nFirerIndex, bool isTarget);// 添加了：是否是射击方的目标对象
	void turnFortBody(double dTargetPosX, double dTargetPosY);   // 机身旋转角度

	bool isStillLive();
	void fortInitState();
	void fortGoDie();
	void targetIsBroken();
	void attackerIsBroken(int nFort, int nFortIndex);

	void putFortInAttackVec(CFort* pFort);  //塞入攻击中的敌机队列
	//void inRangeFortInVec(CFort* pFort);    //塞入在射程范围内的低级队列
	void countShipDistance();               //和敌方战舰的距离

	void searchFort();

	void insertFortEvent(int nEvent, double dEventNumber);
	vector<SFortEvent> getFortEvent();
	void clearFortEvent();

	// ----------------------
	void countInRangeFort();                //统计范围内所有敌机
	void judgeCloseTarget();                //判定最近的攻击中的敌机
	// ----------------------

	SYNTHE_SIZE(int, m_nFortState, FortState);
	SYNTHE_SIZE(int, m_nBuffState, BuffState);
	SYNTHE_SIZE(int, m_nFortIndex, FortIndex);
	SYNTHE_SIZE(bool, m_isLockShip, LockShip);               // 是否锁定战舰作为攻击对象
	SYNTHE_SIZE(bool, m_isBeLockedByShip, IsBeLockedByShip); // 被战舰锁定攻击
	SYNTHE_SIZE(double, m_dSpeed, speed);                    // 移动速度
	SYNTHE_SIZE(double, m_dInitSpeed, InitSpeed);
	SYNTHE_SIZE(CFort*, m_pAttackTarget, AttackTarget);   // 主动攻击的敌机
	SYNTHE_SIZE(int, m_nFortFireState, FortFireState);    // 战机的攻击状态
	SYNTHE_SIZE(CFort*, m_pLockTarget, LockTarget);       // 锁定攻击对象
	SYNTHE_SIZE(double, m_dFireTimeCount, FireTimeCount); // 开火时间
	SYNTHE_SIZE(double, m_dSkillTimeCount, SkillTimeCount);//技能时间计算
	SYNTHE_SIZE(double, m_dCountStepTime, CountStepTime); // 计算每一步运算的时间
	
	SYNTHE_SIZE(int, m_nFortKind, FortKind);             //战机类型
	SYNTHE_SIZE(int, m_nFortFireType, FortFireType);     //攻击类型
	SYNTHE_SIZE(int, m_dInitBornTime, InitBornTime);     //初始化生产时间
	SYNTHE_SIZE(double, m_dFortBornTime, FortBornTime);  //生产战机时间
	SYNTHE_SIZE(bool, m_isFortBorn, IsFortBorn);         //生产状态

	SYNTHE_SIZE(double, m_dFortVecX, FortVecX);          //战机x方向
	SYNTHE_SIZE(double, m_dFortVecY, FortVecY);          //战机y方向

	SYNTHE_SIZE(int, m_nEnergyCost, EnergyCost);         //生产时的能量消耗
	SYNTHE_SIZE(int, m_nArmPoint, ArmPoint);             //军队占用点
	SYNTHE_SIZE(int, m_nBeDestroyEnergy, BeDestroyEnergy);//机坠奖励（能量）

	
	SYNTHE_SIZE(double, m_dTurnRadian, TurnRadian);      // 转过的弧度（计算炮口）(方向朝上为正）


	// 转动的弧度（用于计算炮口位置，射击子弹位置）
	// 反应时间（转机时，



private:
	CBattle* m_pFortBattle;
	vector<CFort*> m_vecInRangeForts;    // 在射程范围内的战机
	vector<CFort*> m_vecAttackTarget;    // 正在攻击的战机
	vector<SFortEvent> m_vecFortEvent;   // 战机的事件
};

