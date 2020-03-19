#include "stdafx.h"
#include "Ship.h"
#include "Battle.h"

#include <stdio.h>

CShip::CShip()
	: m_isEnemy(false)
	, m_nShipID(0)
	, m_nShipHp(0)
	, m_nShipPosX(0)
	, m_nShipPosY(0)
	, m_nShipSkin(0)
	, m_isDeath(false)
	, m_nShipSkillLevel(0)
{

}

CShip::~CShip()
{
	if (m_pFortMgr)
	{
		delete(m_pFortMgr);
		m_pFortMgr = nullptr;
	}
	if (m_pShipSkill)
	{
		delete(m_pShipSkill);
		m_pShipSkill = nullptr;
	}
}

void CShip::update(double dt)
{
	m_pFortMgr->update(dt);
	m_pShipSkill->update(dt);
}

void CShip::initData(int nShipType, string wrongCodePath)
{
	if (nShipType == ShipType::PLAYER_SHIP)
	{
		m_isEnemy = false;
		setPos(MYSHIP_POS_X, MYSHIP_POS_Y);
		m_pFortMgr = new CFortsMgr(m_isEnemy, wrongCodePath);
	}
	else if (nShipType == ShipType::ENEMY_SHIP)
	{
		m_isEnemy = true;
		setPos(ENEMYSHIP_POS_X, ENEMYSHIP_POS_Y);
		m_pFortMgr = new CFortsMgr(m_isEnemy, wrongCodePath);
	}
	m_pFortMgr->setFortMgrBattle(m_pShipBattle);
	m_pFortMgr->createForts();
}

void CShip::damageShip(int damage)
{
	m_nShipHp -= damage;
}

void CShip::setShipData(string strShipDataPath, int nID, int nShipSkillLevel, int fort1, int fort2, int fort3)
{
	cout << "in CShip.cpp " << strShipDataPath << " shipID ：" << nID << " skillLevel: " << nShipSkillLevel << "  " << fort1 << "  " << fort2 << "  " << fort3 << endl;
	m_nShipID = nID;
	m_nShipSkillLevel = nShipSkillLevel;

	int equipForts[5] = { fort1, fort2, fort3 };

	//string strShipID;
	//stringstream ss;
	//ss << m_nShipID;
	//ss >> strShipID;

	//Json::Reader reader;
	//Json::Value root;

	//ifstream openFile;

	//openFile.open(strShipDataPath, ios::binary);

	//if (openFile.is_open())
	//{
	//	cout << "ship_list.json open success" << endl;
	//}
	//if (!reader.parse(openFile, root))
	//{
	//	cout << "ship parse ship skill json faild .......in setShipData function()" << endl;;
	//	return;
	//}
	//string strShipName = root[strShipID]["ship_name"].asString();
	//string strShipSkillName = root[strShipID]["skill_name"].asString();
	char cShipID[8];
	sprintf(cShipID, "%d", m_nShipID);
	//itoa(m_nShipID, c, 10);
	//double skillValue = root[cShipID]["skill_base_value_per"].asDouble();
	//double skillTime = root[cShipID]["last_time"].asDouble();
	//double upSkillValue = root[cShipID]["upgrade_base_value_per"].asDouble();
	//double upSkillTime = root[cShipID]["upgrade_last_time"].asDouble();
	//int fortID1 = root[cShipID]["fort_id1"].asInt();
	//int fortID2 = root[cShipID]["fort_id2"].asInt();
	//int fortID3 = root[cShipID]["fort_id3"].asInt();
	//double suitBuffValue = root[cShipID]["suite_attri_per"].asDouble() * 0.01;

	string strPath = FileUtils::getInstance()->fullPathForFilename(strShipDataPath);
	string strData = FileUtils::getInstance()->getStringFromFile(strPath);
	Document doc;
	doc.Parse<0>(strData.c_str());

	if (!doc.IsObject())
	{
		return;
	}
	rapidjson::Value& vValue = doc[cShipID];

	double skillValue = vValue["skill_base_value_per"].GetDouble();
	double skillTime = vValue["last_time"].GetDouble();
	double upSkillValue = vValue["upgrade_base_value_per"].GetDouble();
	double upSkillTime = vValue["upgrade_last_time"].GetDouble();
	int fortID1 = vValue["fort_id1"].GetInt();
	int fortID2 = vValue["fort_id2"].GetInt();
	int fortID3 = vValue["fort_id3"].GetInt();
	double suitBuffValue = vValue["suite_attri_per"].GetDouble() * 0.01;
	double fireTime = vValue["time"].GetDouble();


	int countSameFort = 0;
	for (int i = 0; i < 3; i++)
	{
		if (equipForts[i] == fortID1)
		{
			countSameFort += 1;
		}
		else if (equipForts[i] == fortID2)
		{
			countSameFort += 1;
		}
		else if (equipForts[i] == fortID3)
		{
			countSameFort += 1;
		}
	}
	if (countSameFort == 3)
	{
		m_pFortMgr->setFortSuitBuff(suitBuffValue);
	}
	createShipSkill(skillValue + (nShipSkillLevel - 1) * upSkillValue, skillTime + (nShipSkillLevel - 1) * upSkillTime, fireTime);
	std::cout << " new 战舰技能   成功 " << endl;
	//openFile.close();
}

void CShip::setPos(int posX, int posY)
{
	m_nShipPosX = posX;
	m_nShipPosY = posY;
}

int CShip::getShipPosX()
{
	return m_nShipPosX;
}

int CShip::getShipPosY()
{
	return m_nShipPosY;
}


int CShip::getShipSkin()
{
	return m_nShipSkin;
}

CFortsMgr * CShip::getFortMgr()
{
	return m_pFortMgr;
}

void CShip::setShipBattle(CBattle * pBattle)
{
	m_pShipBattle = pBattle;
}

void CShip::createShipSkill(double buffValue, double buffTime, double fireTime)
{
	m_pShipSkill = new CShipSkill(m_isEnemy, m_nShipID, m_pShipBattle);
	m_pShipSkill->setSkillData(buffValue, buffTime, fireTime);
}

void CShip::useShipSkill()
{
	m_pShipSkill->startUpdate();
}
