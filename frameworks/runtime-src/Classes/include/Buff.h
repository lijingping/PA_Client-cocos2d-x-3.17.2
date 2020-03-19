#pragma once

class CBattle;

class CBuff
{
public:
	enum buffObject
	{
		SHIP_BUFF,
		FORT_BUFF
	};
	CBuff(bool isEnemy, int fort = 0);
	~CBuff();
	int update(double dt);
	bool createBuff(int buffID, double buffValue, double buffTime);

	void resetBuffTime(double dTime);
	void resetBuffValue(double effectValue, double dTime);
	void setBuffIndex(int buffIndex);
	int getBuffIndex();

	int recoveryFortState();

	int getFortID();
	int getBuffID();

	void setBuffBattle(CBattle *pBattle);

	void addBuffTime(double dTime);

	//  重连
	double getBuffTime();
	double getBuffValue();

private:
	bool m_isEnemy;

	double m_dTime;
	int m_nBuffID;
	int m_nFortID;
	int m_nBuffIndex;
	double m_dBuffValue;  //buff 都是替换，同一时间只会出现一个，只是buff的时间在变。但是每个buff的时间，效果值都不一样。

	CBattle *m_pBuffBattle;
};

