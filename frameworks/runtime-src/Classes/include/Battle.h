#pragma once

#ifndef battle_h
#define battle_h

#include <iostream>
#include <stdio.h>
#include <ctime>
#include <vector>
#include <cstring>

#include "Player.h"
#include "Enemy.h"
#include "EnergyBody.h"
#include "InitialData.h"
#include "Event.h"
#include "KeyFrame.h"
#include "PropsMgr.h"
#include "Boss.h"

#include "json/json.h"
#include <fstream>

#include "cocos2d.h"
#include "json/rapidjson.h"
#include "json/document.h"

USING_NS_CC;
using namespace rapidjson;

//#define _CRT_SECURE_NO_WARNINGS 1

using namespace std;

class CBattle
{
public:

	CBattle();
	~CBattle();
	void initData(int battleType);
	// 初始化设置炮台数据。     敌我炮台，位置(0, 1, 2)，炮台ID，子弹ID，炮台类型(0, 1, 2)，等级，炮台星域系数,  技能等级， 技能数据json文本路径
	void setInitFortData(int nPlayer, int nFortPos, int nFortID, int nBulletID, int nFortType, int nFortLevel, int nFortStarDomainCoe, int nSkillLevel);
	// 初始化设置战舰数据      我方战舰ID, 战舰技能等级， 炮台1， 炮台2， 炮台3， 敌方战舰ID， 敌方战舰技能等级， 炮台1， 炮台2， 炮台3.（这边要判断是否是有套装属性。）
	void setInitShipData(int playerShipID, int playerShipSkillLevel, int p1, int p2, int p3, int enemyShipID, int enemyShipSkillLevel, int e1, int e2, int e3);
	// 初始化boss战的战舰数据
	void setInitShipData(int playerShipID, int playerShipSkillLevel, int p1, int p2, int p3);

	void startFight();   // 战斗开始
	void stopFight();    // 战斗停止，结束
	void resumeFight();
	void update(double delta);
	void UpdateTime(double delta);
	void bossBattleUpdate(double delta); // boss 战的update

	// 返回 “-1”：未结束；“0”：player win；“1”：enemy win；“2”：平局
	int getBattleResult();
	int getBattleType();

	void playerWin();
	void playerLose();

	// 清空事件容器
	void cleanEventVec(); // for 服务器
	void cleanEnergyEventVec();

	CPlayer* getPlayer();
	CEnemy* getEnemy();
	CBoss* getBoss();
	CEnergyBody* getEnergyBody();
	CPropsMgr* getPropMgr();
	bool isEnergyBodyLive();

	int getUpdataFrameCount();

	void countHitBulletToDelete(CBullet* pBullet);
	void cleanHitBulletMap();
	map<int, sHitBullet*> getHitBulletMap();

	// 把能量体事件塞入容器
	void pushEnergyEventToVec(int eventType, bool isProp = false);
	vector<sEnergyBodyEvent*> getEnergyBodyEventVec();

	int getBattleTime();
	
	// 服务器调用
	//能量体初始时间
	void initEnergyRefreshTimes();
	const char *getEnergyTimeString();
	// 能量体规则路径
	void initEnergyBodyRoad();
	const char* getEnergyRoad();
	// buffRoad
	void initBossNpcBuffRoad();
	const char* getBossNpcBuffRoad();

	// 客户端调用
	void setEnergyBodyRoad(string data);
	void setEnergyTimeString(string data);

	// json文件路径
	void setJsonsPath(string skillDataPath, string propDataPath, string wrongCodePath, string shipSkillDataPath);
			// boss 的json文件
	void setBossJsonPathAndID(string bossJsonPath, int bossID = 1);
	// 发射炮台技能
	int fortSkillFire(int nSide, int nFortID, string strBuffPer);// 参数：哪边（我（1）敌（2）方炮台）， 炮台ID， 技能动画时间（s）, 炮台技能命中概率
	// 获取技能是否添加buff
	const char * fortSkillIsAddBuff(int nSide, int nFortID);
	// 使用道具
	int useProp(int nUser, int nPropID, int nTarget, int nFortID); // 使用方，p:1, e:2;  道具ID;  影响方：p:1, e:2; 炮台ID，若全体，为0.
	// 使用战舰技能
	int useShipSkill(int nUser);//使用方： p:1, e:2.

	// 摧毁能量体
	void destroyEnergyBody(bool isProp = false);
	// 分解能量体刷新时间
	void splitEnergyRefreshTime(string data);
	void selectRefreshTime();

	//设置帧数据到keyframe
	void setKeyFrameData();
	// 获取const char * 类型的battle数据
	const char* getCharBattleFrameData(int nPlayerIndex);//player请求数据：为0， enemy请求数据：为1（需要调换数据坐标前后）
	const char* getCharOnlineSynchorFrameData(int nPlayerIndex);
	const char* getCharBossBattleFrameDataReconnect();
	const char* getCharBossBattleFrameData();// 同步数据
	// 获取string类型的battle数据
	string getStringBattleFrameData();
	
	// 重连数据接口
	void setAllBattleData(char *data);
	void setAllNormalBattleData(char *allBattleData);
	void setAllBossBattleData(char *battleData);

	// 线上同步数据接口
	void synchronizationData(char *data);
	// 普通战斗同步
	void onlineSynchordata(char *partBattleData);
	// 同步boss战数据
	void synchronizationBossData(char *bossBattleData);

	void setBattleData(char *data);     // 重连
	int setBattleSynchordata(char* data);// 普通战斗同步
	void setBulletMgrData(char *data);

	void setPlayerData(char *data);
	void setEnemyData(char *data);

	void setPlayerFortData(char *data);
	void setEnemyFortData(char *data);
	void setHitBulletData(char *data);
	void setEnergyBodyEventData(char *data);
	void setPlayerBulletDataReconnect(char *data);
	void setEnemyBulletDataReconnect(char *data);
	void setEnergyBodyData(char *data);

	void setPlayerBuff(char *data);
	void setEnemyBuff(char *data);
	void setPlayerBuffEvent(char *data);
	void setEnemyBuffEvent(char *data);
	void setPlayerFortsEvent(char *data);
	void setEnemyFortsEvent(char *data);
	void setPropMgrData(char *data);
	void setPerPropMapData(char *data);
	void setPropEventData(char *data);
	
	void setBossBattleData(char *data);
	void setBossBulletMgrData(char *data);
	void setPlayerFortData_reconnect(char *data, int nFortIndex, int nPlayer);
	void setPlayerFortData_synchordata(char *data, int nFortIndex, int nPlayer);
	void setBattleData_BossReconnect(char *data);
	void setBattleData_BossSynchordata(char *data);
	void setBossBulletReconnect(char *data);
	void setBossEventReconnect(char *data);

	void decodeWrongCodeJsonFileData(); // 解析错误代码
	vector<wrongCodeData> getWrongCodeData();

	// 设置全服玩家数 (boss战)
	void setAllPlayerNumber(int nPlayerNumber);
	// boss战增加的伤害加成
	void addInjuryPercent(double dPercent);
	// boss战最后结果
	double getBossResultInjury();

	// 战败方剩余炮台数
	int getFailerFortCount();
	void countSurrenderFort(int player);

private:
	int m_nBattleResult;
	int m_nBattleType;

	CPlayer *m_pPlayer;
	CEnemy *m_pEnemy;
	CBoss *m_pBoss;
	CPropsMgr *m_pPropsMgr;
	//CDataMgr *m_pDataMgr;
	int m_updateCount;

	CEnergyBody *m_pEnergyBody;
	double m_dEnergyRefreshTime;
	bool m_isEnergyLive;

	// 事件
	int m_nCountUpdateFrame;
	//vector<CBattle*> m_vecBattleFrame;

	int m_nCountHitBullet;
	map<int, sHitBullet*> m_mapHitBullet;

	vector<sEnergyBodyEvent*> m_vecEnergyBodyEvent;

private:
	double m_dBattleTime;
	bool m_isBattleRuning;
	bool m_isBattleStop;
	CKeyFrame *m_pKeyFrame;
	string m_sEnergyBodyRoad;
	int m_nEnergyCreateCount;
	string m_stringEnergyTime;
	int m_nRefreshCount;
	int m_arrRefreshTime[12];

	string m_strSkillDataPath;
	string m_strPropDataPath;
	string m_strWrongCodePath;
	string m_strShipSkillDataPath;
	vector<wrongCodeData> m_vecWrongCodeData;

	string m_sBossNpcBuffRoad;
	string m_sBossDataPath;

	int m_nPlayerNumber;
	int m_nBossID;

	int m_nFailerFortNum; // 战斗结束，失败方剩余炮台数

	// 断线重连设置的数据接口（同步）
public:
	void resetPlayer(CPlayer *pPlayer);
	void resetEnemy(CEnemy *pEnemy);
	void setEnergyRefreshTime(double dEnergyRefreshTime);
	double getEnergyRefreshTime();
	void resetEnergyLive(bool isLife);
	//isEnergyBodyLive();
	void resetCountHitBullet(int nCount);
	int getCountHitBullet();
	void resetHitBulletMap(map<int, sHitBullet*> map);
	//void resetEnergyBodyEventVec(vector<sEnergyBodyEvent*> vec);
	void resetBattleTime(double dTime);
	double getTime();
	void resetBattleRuning(bool isRuning);
	bool isBattleRuning();
	void resetBattleStop(bool isStop);
	bool isBattleStop();


};


#endif /* battle_h */
