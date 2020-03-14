#pragma once
#include "InitialData.h"

class CBullet            // : public CShape
{
public:
	CBullet();
	~CBullet();
	void update(double dt);
	int bossBulletUpdata(double delta);
	void createBullet(int bulletID, bool isEnemy, int fortIndex, int bulletIndex);

	void createBossBullet(int bulletIndex, double dTime);
	void setBulletSpeed(double dSpeed);

	double getBulletPosX();
	double getBulletPosY();
	int getFortIndex();
	int getBulletIndex();
	int getBulletID();
	bool isEnemy();

	double getBossBulletTime();

	// 断线重连（响应服务器数据）
public:
	void resetBulletOwner(int nSide);
	// isEnemy();
	void resetBulletID(int nBulletID);
	//int getBulletID();
	void resetFortIndex(int nFortIndex);
	void setPosX(double dPosX);
	void setPosY(double dPosY);
	void resetBulletIndex(int nBulletIndex);
	void resetTime(double dTime);
	double getCountTime();

private:
	bool m_isEnemy;
	int m_nBulletID;
	int m_nBulletSpeed;
	int m_nIndexOfFort;
	double m_dPosX;
	double m_dPosY;
	int m_nBulletIndex;
	double m_dCountTime;

	bool m_isBossBullet;
	double m_dBossBulletTime;
};

