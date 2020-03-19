#pragma once
#include "json/json.h"
#include <fstream>
#include <string>
#include <sstream>
#include <map>
#include "InitialData.h"
#include <vector>
//#include <iostream>
using namespace std;

class CFort;
class CBattle;

class CFortSkill
{
public:
	CFortSkill(CFort *pFort, int nSkillLevel, string strPathJson, double starDomainCoe);
	~CFortSkill();
	void update(double delta);
	void loadDataByFile(string strFile, int nSkillLevel);
	void setSkillBattle(CBattle *pBattle);
	double getSkillTime();
	void lockTargetFort();   // 发射技能时，先锁定目标炮台
	const char* isAddBuff();  // 计算buff的概率值，添加buff为1，不添加返回0；
	void setAddBuff(string strBuffPer); // 客户端设置是否添加buff的布尔值

	CFort* getTargetFort();
	void getOneLineFort();
	void chooseStateFort(int nState);
	void fireSkill();
	double countSkillDamagePercent(double dType, double dCorrectType, double dRange, double correctRange, int nSkillLevel);
	double countScorePercent(double dScore, double dScoreCoe, double dCorrectScore, double dScoreGrow, int nSkillLevel);
	double countContinueTime(double dBuffBeginTime, double dContinueCoe, double dCorrectContinue, double dTimeGrow, int nSkillLevel);
	double countEffectValue(double dEffectValue, double dBuffCoe, double dCorrectBuff, double dBuffGrow, double nSkillLevel);

	void damagePlayerFort(int nTypeFire, double dAddDamage);  // nTypeFire :1 为普通技能伤害  2 为加了额外伤害的技能伤害
	//void damageEnemyFort(int nTypeFire, double dAddDamage);
	void damageWholePlayerForts(); // 全体伤害
	void damageWholeEnemyForts();

	CFort* getMinHpFort(map<int, CFort*> map);  // 获取最低生命值炮台（活）
	void splitBuffAdd(string strBuffPer);

	// ----------------各路大神技能--------------
	void firstSkill_DieCut();      // 死亡切割
	void secondSkill_SpreadPos();  // 扩散相位炮
	void thirdSkill_MaximalBurst(); // 极限爆破
	void fourthSkill_CrazyBurst(); //疯狂爆破
	void fifthSkill_SpiralWave(); //螺旋波动
	void sixthSkill_StormShoot(); //风暴速射
	void seventhSkill_GodLight(); //神罚之光
	void eighthSkill_LightningStrike(); //混沌雷击
	void ninthSkill_SpiralHit(); //螺旋冲击
	void tenthSkill_LightShoot(); // 光棱射线
	void eleventhSkill_BirdAngry();//不死鸟之怒
	void twelfthSkill_EnergyZone();//能量禁区
	void thirteenthSkill_PulseWave();//脉冲波动
	void fourteenthSkill_LightSpread();//光芒四射
	void fifteenthSkill_DragonHowl(); //狂龙之吼
	void sixteenthSkill_FightVoice(); //斗志之音
	void seventeenthSkill_DestroyLight();//毁灭之光
	void eighteenthSkill_UltimateBlow(); //极限之击
	void nineteenthSkill_DoubleWinding();//双子缠绕
	void twentiethSkill_AbsoluteDomain();//绝对领域
	void twentyFirst_SaveLight();   //救赎之光
	void twentySecond_DestroyBurst();//毁灭爆破
	void twentyThird_ElectricStorm();//电磁风暴
	void twentyFourth_FatalShoot(); //致命扫射
	void twentyFifth_OlympicFlame();//圣火
	void twentySixth_PunishKnife(); //制裁之刃
	void twentySeventh_DoomsdayTrial();//末日审判
	void twentyEighth_HolyDiscipline();//神圣惩戒
	void twenthNinth_LightningStorm();//闪电风暴
	void thirtieth_EndKnife();//终结旋刃

private:
	double m_dStarDomainCoe;
	int m_nSkillID;
	CBattle *m_pSkillBattle;
	CFort *m_pFort;
	CFort *m_pTargetFort;

	int m_nSkillLevel;
	double m_dSkillDamagePercent;
	double m_dScorePercent;
	double m_dContinueTime;
	double m_dSkillEffectValue;

	double m_dSkillTime;
	bool m_isAddBuff;

	int m_nSingleBuffAdd; // 1:单体添加buff；2:全体添加buff
	int m_nAddBuff[3];  // 重连是否同步？
};

