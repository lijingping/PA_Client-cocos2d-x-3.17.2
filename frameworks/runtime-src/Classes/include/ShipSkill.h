#pragma once

using namespace std;

class CBattle;

class CShipSkill
{
public:
	CShipSkill(bool isEnemy, int shipSkillID, CBattle *pBattle);
	~CShipSkill();
	void update(double dt);
	void setSkillData(double buffValue, double buffTime, double fireTime);
	void shipSkillFire();
	double getTotalAck(int nSide);
	void startUpdate();
	
	void ship1_fireSkill();  // 孤注一掷
	void ship2_fireSkill();  // 紧急戒备
	void ship3_fireSkill();  // 虚空光辉
	void ship4_fireSkill();  // 远古意志
	void ship5_fireSkill();  // 粉碎一击
	void ship6_fireSkill();  // 灼热风暴
	void ship7_fireSkill();  // 困兽之斗
	void ship8_fireSkill();  // 致胜之盾
	void ship9_fireSkill();  // 战神制裁
	void ship10_fireSkill(); // 神之眷顾

private:
	bool m_isEnemy;
	int m_nShipSkillID;
	CBattle *m_pShipSkillBattle;
	double m_dBuffValue;
	double m_dBuffTime;
	double m_dFireTime;
	double m_dTime;
	bool m_isUpdate;
};

