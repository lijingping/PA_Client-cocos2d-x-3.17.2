#include "FortSkill.h"

#include "Battle.h"
#include "Fort.h"

CFortSkill::CFortSkill(CFort *pFort, int nSkillLevel, string strPathJson, double starDomainCoe)
	: m_nSkillLevel(0)
	, m_dSkillTime(0.0)
{
	m_dStarDomainCoe = starDomainCoe;
	m_dContinueTime = 0.0;
	m_dScorePercent = 0.0;
	m_dSkillDamagePercent = 0.0;
	m_dSkillEffectValue = 0.0;
	m_isAddBuff = false;

	m_nSingleBuffAdd = 0;

	m_pTargetFort = nullptr;
	m_pFort = pFort;
	m_nSkillID = m_pFort->getFortID() - 40000;
	loadDataByFile(strPathJson, nSkillLevel);
}


CFortSkill::~CFortSkill()
{
}

void CFortSkill::update(double delta)
{

}

void CFortSkill::loadDataByFile(string strFilePath, int nSkillLevel)
{
	m_nSkillLevel = nSkillLevel;
	double dTypeDamage = 0;
	double dBuff = 0;
	double dDebuff = 0;
	double dScoreCoe = 0;
	double dContinueCoe = 0;
	double dSingleDamage = 0;
	double dWholeDamage = 0;
	double dCorrectTypeDamage = 0;
	double dCorrectBuff = 0;
	double dCorrectDebuff = 0;
	double dCorrectScore = 0;
	double dCorrectContinue = 0;
	double dCorrectSingleDamage = 0;
	double dCorrectWholeDamage = 0;
	double dBuffValue = 0;
	double dBuffGrow = 0;
	double dBuffBeginTime = 0;
	double dTimeGrow = 0;
	double dScore = 0;
	double dScoreGrow = 0;

	//string strSkillID;
	//stringstream ss;
	//ss << m_nSkillID;
	//ss >> strSkillID;
	char cFortSkillID[8];
	sprintf(cFortSkillID, "%d", m_nSkillID);
	//Json::Reader reader;
	//Json::Value root;

	//ifstream openFile;
	//openFile.open(strFilePath, ios::binary);
	//if (reader.parse(openFile, root))
	//{
	//	cout << "炮台技能读取数据  begin" << endl;

	//	dTypeDamage = root[cFortSkillID]["type_damage"].asDouble();
	//	dBuff = root[cFortSkillID]["buff"].asDouble();
	//	dDebuff = root[cFortSkillID]["debuff"].asDouble();
	//	dScoreCoe = root[cFortSkillID]["score_coe"].asDouble();
	//	dContinueCoe = root[cFortSkillID]["continue_coe"].asDouble(); 
	//	dSingleDamage = root[cFortSkillID]["single_damage"].asDouble();
	//	dWholeDamage = root[cFortSkillID]["whole_damage"].asDouble();
	//	dCorrectTypeDamage = root[cFortSkillID]["correct_type_damage"].asDouble();
	//	dCorrectBuff = root[cFortSkillID]["correct_buff"].asDouble();
	//	dCorrectDebuff = root[cFortSkillID]["correct_debuff"].asDouble();
	//	dCorrectScore = root[cFortSkillID]["correct_score"].asDouble();
	//	dCorrectContinue = root[cFortSkillID]["correct_continue"].asDouble();
	//	dCorrectSingleDamage = root[cFortSkillID]["correct_single_damage"].asDouble();
	//	dCorrectWholeDamage = root[cFortSkillID]["correct_whole_damage"].asDouble();
	//	dBuffValue = root[cFortSkillID]["buff_value"].asDouble();
	//	dBuffGrow = root[cFortSkillID]["buff_grow"].asDouble();
	//	dBuffBeginTime = root[cFortSkillID]["buff_begin_time"].asDouble();
	//	dTimeGrow = root[cFortSkillID]["time_grow"].asDouble();
	//	dScore = root[cFortSkillID]["score"].asDouble();
	//	dScoreGrow = root[cFortSkillID]["score_grow"].asDouble();
	//	m_dSkillTime = root[cFortSkillID]["skill_time"].asDouble();
	//	cout << "读取到json文件内容........" << endl;
	//}
	//openFile.close();

	string strPath = FileUtils::getInstance()->fullPathForFilename(strFilePath);
	string strData = FileUtils::getInstance()->getStringFromFile(strPath);
	Document doc;
	doc.Parse<0>(strData.c_str());
	if (doc.IsObject())
	{
		rapidjson::Value& vValue = doc[cFortSkillID];//strSkillID.c_str()
		if (vValue.IsObject())
		{
			dTypeDamage = vValue["type_damage"].GetDouble();
			dBuff = vValue["buff"].GetDouble();
			dDebuff = vValue["debuff"].GetDouble();
			dScoreCoe = vValue["score_coe"].GetDouble();
			dContinueCoe = vValue["continue_coe"].GetDouble();
			dSingleDamage = vValue["single_damage"].GetDouble();
			dWholeDamage = vValue["whole_damage"].GetDouble();
			dCorrectTypeDamage = vValue["correct_type_damage"].GetDouble();
			dCorrectBuff = vValue["correct_buff"].GetDouble();
			dCorrectDebuff = vValue["correct_debuff"].GetDouble();
			dCorrectScore = vValue["correct_score"].GetDouble();
			dCorrectContinue = vValue["correct_continue"].GetDouble();
			dCorrectSingleDamage = vValue["correct_single_damage"].GetDouble();
			dCorrectWholeDamage = vValue["correct_whole_damage"].GetDouble();
			dBuffValue = vValue["buff_value"].GetDouble();
			dBuffGrow = vValue["buff_grow"].GetDouble();
			dBuffBeginTime = vValue["buff_begin_time"].GetDouble();
			dTimeGrow = vValue["time_grow"].GetDouble();
			dScore = vValue["score"].GetDouble();
			dScoreGrow = vValue["score_grow"].GetDouble();
			m_dSkillTime = vValue["skill_time"].GetDouble();
		}
	}

	switch (m_nSkillID)
	{
	case 50001:
		m_dSkillDamagePercent = countSkillDamagePercent(dTypeDamage, dCorrectTypeDamage, dSingleDamage, dCorrectSingleDamage, m_nSkillLevel);
		break;
	case 50002: // 扩散相位炮， 伤害， 效果值， 时间（火力干扰）（全体）
		m_dSkillDamagePercent = countSkillDamagePercent(dTypeDamage, dCorrectTypeDamage, dWholeDamage, dCorrectWholeDamage, m_nSkillLevel);
		m_dContinueTime = countContinueTime(dBuffBeginTime, dContinueCoe, dCorrectContinue, dTimeGrow, m_nSkillLevel);
		m_dSkillEffectValue = countEffectValue(dBuffValue, dDebuff, dCorrectDebuff, dBuffGrow, m_nSkillLevel);
		break;
	case 50003:
		m_dSkillDamagePercent = countSkillDamagePercent(dTypeDamage, dCorrectTypeDamage, dSingleDamage, dCorrectSingleDamage, m_nSkillLevel);
		break;
	case 50004:
		m_dSkillDamagePercent = countSkillDamagePercent(dTypeDamage, dCorrectTypeDamage, dSingleDamage, dCorrectSingleDamage, m_nSkillLevel);
		break;
	case 50005: // 螺旋波动， 伤害， 效果值， 时间（护盾）（单体）
		m_dSkillDamagePercent = countSkillDamagePercent(dTypeDamage, dCorrectTypeDamage, dSingleDamage, dCorrectSingleDamage, m_nSkillLevel);
		m_dContinueTime = countContinueTime(dBuffBeginTime, dContinueCoe, dCorrectContinue, dTimeGrow, m_nSkillLevel);
		m_dSkillEffectValue = countEffectValue(dBuffValue, dBuff, dCorrectBuff, dBuffGrow, m_nSkillLevel);
		break;
	case 50006: // 暴风速射， 伤害， 效果值（回血）（单体）
		m_dSkillDamagePercent = countSkillDamagePercent(dTypeDamage, dCorrectTypeDamage, dSingleDamage, dCorrectSingleDamage, m_nSkillLevel);
		m_dSkillEffectValue = countEffectValue(dBuffValue, dBuff, dCorrectBuff, dBuffGrow, m_nSkillLevel);
		break;
	case 50007:
		m_dSkillDamagePercent = countSkillDamagePercent(dTypeDamage, dCorrectTypeDamage, dSingleDamage, dCorrectSingleDamage, m_nSkillLevel);
		break;
	case 50008:  // 混沌雷击， 伤害， 几率， 时间（瘫痪）（单体）
		m_dSkillDamagePercent = countSkillDamagePercent(dTypeDamage, dCorrectTypeDamage, dSingleDamage, dCorrectSingleDamage, m_nSkillLevel);
		m_dContinueTime = countContinueTime(dBuffBeginTime, dContinueCoe, dCorrectContinue, dTimeGrow, m_nSkillLevel);
		m_dScorePercent = countScorePercent(dScore, dScoreCoe, dCorrectScore, dScoreGrow, m_nSkillLevel);
		m_nSingleBuffAdd = 1;
		break;
	case 50009: // 螺旋冲击，伤害，几率， 时间（维修干扰）（单体）
		m_dSkillDamagePercent = countSkillDamagePercent(dTypeDamage, dCorrectTypeDamage, dSingleDamage, dCorrectSingleDamage, m_nSkillLevel);
		m_dContinueTime = countContinueTime(dBuffBeginTime, dContinueCoe, dCorrectContinue, dTimeGrow, m_nSkillLevel);
		m_dScorePercent = countScorePercent(dScore, dScoreCoe, dCorrectScore, dScoreGrow, m_nSkillLevel);
		m_nSingleBuffAdd = 1;
		break;
	case 50010: // 光棱射线，伤害， 几率， 时间（瘫痪）（全体）
		m_dSkillDamagePercent = countSkillDamagePercent(dTypeDamage, dCorrectTypeDamage, dWholeDamage, dCorrectWholeDamage, m_nSkillLevel);
		m_dContinueTime = countContinueTime(dBuffBeginTime, dContinueCoe, dCorrectContinue, dTimeGrow, m_nSkillLevel);
		m_dScorePercent = countScorePercent(dScore, dScoreCoe, dCorrectScore, dScoreGrow, m_nSkillLevel);
		m_nSingleBuffAdd = 2;
		break;

	case 50011: //不死鸟之怒， 伤害， 几率， 时间（燃烧）（全体）
		m_dSkillDamagePercent = countSkillDamagePercent(dTypeDamage, dCorrectTypeDamage, dWholeDamage, dCorrectWholeDamage, m_nSkillLevel);
		m_dContinueTime = countContinueTime(dBuffBeginTime, dContinueCoe, dCorrectContinue, dTimeGrow, m_nSkillLevel);
		m_dScorePercent = countScorePercent(dScore, dScoreCoe, dCorrectScore, dScoreGrow, m_nSkillLevel);
		m_nSingleBuffAdd = 2;
		break;
	case 50012: //能量禁区， 伤害， 几率， 时间（瘫痪目标造成能量干扰）（全体）
		m_dSkillDamagePercent = countSkillDamagePercent(dTypeDamage, dCorrectTypeDamage, dWholeDamage, dCorrectWholeDamage, m_nSkillLevel);
		m_dContinueTime = countContinueTime(dBuffBeginTime, dContinueCoe, dCorrectContinue, dTimeGrow, m_nSkillLevel);
		m_dScorePercent = countScorePercent(dScore, dScoreCoe, dCorrectScore, dScoreGrow, m_nSkillLevel);
		m_nSingleBuffAdd = 2;
		break;
	case 50013: //脉冲波动， 伤害（瘫痪目标额外50伤害）（单体）
		m_dSkillDamagePercent = countSkillDamagePercent(dTypeDamage, dCorrectTypeDamage, dSingleDamage, dCorrectSingleDamage, m_nSkillLevel);
		break;
	case 50014: //光芒四射， 伤害， 几率， 时间（能量干扰）（全体）
		m_dSkillDamagePercent = countSkillDamagePercent(dTypeDamage, dCorrectTypeDamage, dWholeDamage, dCorrectWholeDamage, m_nSkillLevel);
		m_dContinueTime = countContinueTime(dBuffBeginTime, dContinueCoe, dCorrectContinue, dTimeGrow, m_nSkillLevel);
		m_dScorePercent = countScorePercent(dScore, dScoreCoe, dCorrectScore, dScoreGrow, m_nSkillLevel);
		m_nSingleBuffAdd = 2;
		break;
	case 50015: //狂龙之吼， 伤害， 几率， 时间（瘫痪）（单体）
		m_dSkillDamagePercent = countSkillDamagePercent(dTypeDamage, dCorrectTypeDamage, dSingleDamage, dCorrectSingleDamage, m_nSkillLevel);
		m_dContinueTime = countContinueTime(dBuffBeginTime, dContinueCoe, dCorrectContinue, dTimeGrow, m_nSkillLevel);
		m_dScorePercent = countScorePercent(dScore, dScoreCoe, dCorrectScore, dScoreGrow, m_nSkillLevel);
		m_nSingleBuffAdd = 1;
		break;
	case 50016: //斗志之音， 伤害（燃烧目标额外50/100伤害）（单体）
		m_dSkillDamagePercent = countSkillDamagePercent(dTypeDamage, dCorrectTypeDamage, dSingleDamage, dCorrectSingleDamage, m_nSkillLevel);
		break;
	case 50017: //毁灭之光， 伤害， 几率， 时间（燃烧）（单体）
		m_dSkillDamagePercent = countSkillDamagePercent(dTypeDamage, dCorrectTypeDamage, dSingleDamage, dCorrectSingleDamage, m_nSkillLevel);
		m_dContinueTime = countContinueTime(dBuffBeginTime, dContinueCoe, dCorrectContinue, dTimeGrow, m_nSkillLevel);
		m_dScorePercent = countScorePercent(dScore, dScoreCoe, dCorrectScore, dScoreGrow, m_nSkillLevel);
		m_nSingleBuffAdd = 1;
		break;
	case 50018: //极限之击， 伤害， 时间， 效果值（火力增幅）（单体）
		m_dSkillDamagePercent = countSkillDamagePercent(dTypeDamage, dCorrectTypeDamage, dSingleDamage, dCorrectSingleDamage, m_nSkillLevel);
		m_dContinueTime = countContinueTime(dBuffBeginTime, dContinueCoe, dCorrectContinue, dTimeGrow, m_nSkillLevel);
		m_dSkillEffectValue = countEffectValue(dBuffValue, dBuff, dCorrectBuff, dBuffGrow, m_nSkillLevel);
		break;
	case 50019: //双子缠绕， 伤害（额外伤害50）（单体）
		m_dSkillDamagePercent = countSkillDamagePercent(dTypeDamage, dCorrectTypeDamage, dSingleDamage, dCorrectSingleDamage, m_nSkillLevel);
		break;
	case 50020: //绝对领域， 伤害， 效果值， 时间（护盾）（单体）
		m_dSkillDamagePercent = countSkillDamagePercent(dTypeDamage, dCorrectTypeDamage, dSingleDamage, dCorrectSingleDamage, m_nSkillLevel);
		m_dContinueTime = countContinueTime(dBuffBeginTime, dContinueCoe, dCorrectContinue, dTimeGrow, m_nSkillLevel);
		m_dSkillEffectValue = countEffectValue(dBuffValue, dBuff, dCorrectBuff, dBuffGrow, m_nSkillLevel);
		break;
	case 50021: //救赎之光， 伤害， 效果值， 时间（火力增幅）（单体）
		m_dSkillDamagePercent = countSkillDamagePercent(dTypeDamage, dCorrectTypeDamage, dSingleDamage, dCorrectSingleDamage, m_nSkillLevel);
		m_dContinueTime = countContinueTime(dBuffBeginTime, dContinueCoe, dCorrectContinue, dTimeGrow, m_nSkillLevel);
		m_dSkillEffectValue = countEffectValue(dBuffValue, dBuff, dCorrectBuff, dBuffGrow, m_nSkillLevel);
		break;
	case 50022: //毁灭爆破， 伤害， 效果值， 时间（火力干扰）（全体）
		m_dSkillDamagePercent = countSkillDamagePercent(dTypeDamage, dCorrectTypeDamage, dWholeDamage, dCorrectWholeDamage, m_nSkillLevel);
		m_dContinueTime = countContinueTime(dBuffBeginTime, dContinueCoe, dCorrectContinue, dTimeGrow, m_nSkillLevel);
		m_dSkillEffectValue = countEffectValue(dBuffValue, dDebuff, dCorrectDebuff, dBuffGrow, m_nSkillLevel);
		break;
	case 50023: //电磁风暴， 伤害， 效果值， 时间（护盾）（全体）
		m_dSkillDamagePercent = countSkillDamagePercent(dTypeDamage, dCorrectTypeDamage, dWholeDamage, dCorrectWholeDamage, m_nSkillLevel);
		m_dContinueTime = countContinueTime(dBuffBeginTime, dContinueCoe, dCorrectContinue, dTimeGrow, m_nSkillLevel);
		m_dSkillEffectValue = countEffectValue(dBuffValue, dBuff, dCorrectBuff, dBuffGrow, m_nSkillLevel);
		break;
	case 50024: //致命扫射， 伤害， 效果值（回血）（全体）
		m_dSkillDamagePercent = countSkillDamagePercent(dTypeDamage, dCorrectTypeDamage, dWholeDamage, dCorrectWholeDamage, m_nSkillLevel);
		m_dSkillEffectValue = countEffectValue(dBuffValue, dBuff, dCorrectBuff, dBuffGrow, m_nSkillLevel);
		break;
	case 50025: //圣火， 伤害， 几率， 时间（燃烧）（全体）
		m_dSkillDamagePercent = countSkillDamagePercent(dTypeDamage, dCorrectTypeDamage, dWholeDamage, dCorrectWholeDamage, m_nSkillLevel);
		m_dScorePercent = countScorePercent(dScore, dScoreCoe, dCorrectScore, dScoreGrow, m_nSkillLevel);
		m_dContinueTime = countContinueTime(dBuffBeginTime, dContinueCoe, dCorrectContinue, dTimeGrow, m_nSkillLevel);
		m_nSingleBuffAdd = 2;
		break;
	case 50026: //制裁之刃， 伤害， 效果值（回血）（单体）
		m_dSkillDamagePercent = countSkillDamagePercent(dTypeDamage, dCorrectTypeDamage, dSingleDamage, dCorrectSingleDamage, m_nSkillLevel);
		m_dSkillEffectValue = countEffectValue(dBuffValue, dBuff, dCorrectBuff, dBuffGrow, m_nSkillLevel);
		break;
	case 50027: //末日审判， 伤害， 几率， 时间（维修干扰）（全体）
		m_dSkillDamagePercent = countSkillDamagePercent(dTypeDamage, dCorrectTypeDamage, dWholeDamage, dCorrectWholeDamage, m_nSkillLevel);
		m_dScorePercent = countScorePercent(dScore, dScoreCoe, dCorrectScore, dScoreGrow, m_nSkillLevel);
		m_dContinueTime = countContinueTime(dBuffBeginTime, dContinueCoe, dCorrectContinue, dTimeGrow, m_nSkillLevel);
		m_nSingleBuffAdd = 2;
		break;
	case 50028: //神圣惩戒， 伤害， 几率， 时间（维修干扰）（全体）
		m_dSkillDamagePercent = countSkillDamagePercent(dTypeDamage, dCorrectTypeDamage, dWholeDamage, dCorrectWholeDamage, m_nSkillLevel);
		m_dScorePercent = countScorePercent(dScore, dScoreCoe, dCorrectScore, dScoreGrow, m_nSkillLevel);
		m_dContinueTime = countContinueTime(dBuffBeginTime, dContinueCoe, dCorrectContinue, dTimeGrow, m_nSkillLevel);
		m_nSingleBuffAdd = 2;
		break;
	case 50029: //闪电风暴， 伤害， 几率， 时间（瘫痪）（全体）
		m_dSkillDamagePercent = countSkillDamagePercent(dTypeDamage, dCorrectTypeDamage, dWholeDamage, dCorrectWholeDamage, m_nSkillLevel);
		m_dScorePercent = countScorePercent(dScore, dScoreCoe, dCorrectScore, dScoreGrow, m_nSkillLevel);
		m_dContinueTime = countContinueTime(dBuffBeginTime, dContinueCoe, dCorrectContinue, dTimeGrow, m_nSkillLevel);
		m_nSingleBuffAdd = 2;
		break;
	case 50030: //终结旋刃， 伤害， 几率， 时间（能量干扰）（全体）
		m_dSkillDamagePercent = countSkillDamagePercent(dTypeDamage, dCorrectTypeDamage, dWholeDamage, dCorrectWholeDamage, m_nSkillLevel);
		m_dScorePercent = countScorePercent(dScore, dScoreCoe, dCorrectScore, dScoreGrow, m_nSkillLevel);
		m_dContinueTime = countContinueTime(dBuffBeginTime, dContinueCoe, dCorrectContinue, dTimeGrow, m_nSkillLevel);
		m_nSingleBuffAdd = 2;
		break;
	default:
		break;
	}
}

void CFortSkill::setSkillBattle(CBattle * pBattle)
{
	m_pSkillBattle = pBattle;
}

double CFortSkill::getSkillTime()
{
	return m_dSkillTime;
}

void CFortSkill::lockTargetFort()
{
	switch (m_nSkillID)
	{
	case 50001:
		getOneLineFort();
		break;
	case 50002:   // 全体

		break;
	case 50003:
		getOneLineFort();
		break;
	case 50004:
		getOneLineFort();
		break;
	case 50005:
		getOneLineFort();
		break;
	case 50006:
		getOneLineFort();
		break;
	case 50007:
		getOneLineFort();
		break;
	case 50008:  // 选择低生命值目标攻击
		if (m_pFort->isEnemy())
		{
			m_pTargetFort = getMinHpFort(m_pSkillBattle->getPlayer()->getShip()->getFortMgr()->getPlayerFort());
		}
		else
		{
			m_pTargetFort = getMinHpFort(m_pSkillBattle->getEnemy()->getShip()->getFortMgr()->getEnemyFort());
		}
		break;
	case 50009:   // 选择低生命值目标攻击
		if (m_pFort->isEnemy())
		{
			m_pTargetFort = getMinHpFort(m_pSkillBattle->getPlayer()->getShip()->getFortMgr()->getPlayerFort());
		}
		else
		{
			m_pTargetFort = getMinHpFort(m_pSkillBattle->getEnemy()->getShip()->getFortMgr()->getEnemyFort());
		}
		break;
	case 50010:    // 全体
		
		break;
	case 50011:    // 全体

		break;
	case 50012:    // 全体

		break;
	case 50013:    // 选择瘫痪目标攻击
		chooseStateFort(Debuff::FORT_PARALYSIS);
		break;
	case 50014:    // 全体
		
		break;
	case 50015:  
		getOneLineFort();
		break;
	case 50016:    // 选择燃烧目标攻击
		chooseStateFort(Debuff::FORT_BURNING);
		break;
	case 50017:    // 选择生命值最低目标攻击
		if (m_pFort->isEnemy())
		{
			m_pTargetFort = getMinHpFort(m_pSkillBattle->getPlayer()->getShip()->getFortMgr()->getPlayerFort());
		}
		else
		{
			m_pTargetFort = getMinHpFort(m_pSkillBattle->getEnemy()->getShip()->getFortMgr()->getEnemyFort());
		}
		break;
	case 50018:
		getOneLineFort();
		break;
	case 50019:    // 选择生命值最低目标攻击
		if (m_pFort->isEnemy())
		{
			m_pTargetFort = getMinHpFort(m_pSkillBattle->getPlayer()->getShip()->getFortMgr()->getPlayerFort());
		}
		else
		{
			m_pTargetFort = getMinHpFort(m_pSkillBattle->getEnemy()->getShip()->getFortMgr()->getEnemyFort());
		}
		break;
	case 50020:
		getOneLineFort();
		break;
	case 50021:
		getOneLineFort();
		break;
	case 50022:    // 全体

		break;
	case 50023:    // 全体

		break;
	case 50024:    // 全体

		break;
	case 50025:    // 全体
		
		break;
	case 50026:
		getOneLineFort();
		break;
	case 50027:    // 全体
		
		break;
	case 50028:    // 全体

		break;
	case 50029:    // 全体
		
		break;
	case 50030:    // 全体

		break;
	default:
		break;
	}
	return;
}

const char* CFortSkill::isAddBuff()
{
	ostringstream oss;
	if (m_pSkillBattle->getBattleType() == BattleType::BATTLE_NORMAL)
	{
		if (m_dScorePercent > 0)
		{
			srand((unsigned)time(NULL));
			if (m_nSingleBuffAdd == 1)
			{
				int randNum = rand() % 100;
				m_nAddBuff[0] = randNum;
				oss << randNum << "/";
			}
			else if (m_nSingleBuffAdd == 2)
			{
				for (int i = 0; i < 3; i++)
				{
					int randNum = rand() % 100;
					m_nAddBuff[i] = randNum;
					oss << randNum << "/";
				}
			}


		}
		else
		{
			oss << "0/";
		}
	}
	else if (m_pSkillBattle->getBattleType() == BattleType::BATTLE_BOSS)
	{
		oss << "0/";
	}
	return oss.str().c_str();
}

void CFortSkill::splitBuffAdd(string strBuffPer)
{
	char * buffPer;
	int len = strBuffPer.length();
	buffPer = (char *)malloc((len + 1) * sizeof(char));
	strBuffPer.copy(buffPer, len, 0);
	
	if (m_nSingleBuffAdd == 2)
	{
		sscanf(buffPer, "%d/%d/%d", &m_nAddBuff[0], &m_nAddBuff[1], &m_nAddBuff[2]);
	}
	else
	{
		sscanf(buffPer, "%d/", &m_nAddBuff[0]);
	}
}

void CFortSkill::setAddBuff(string strBuffPer)
{
	splitBuffAdd(strBuffPer);
}

CFort* CFortSkill::getTargetFort()
{
	return m_pTargetFort;
}

void CFortSkill::getOneLineFort()
{
	if (m_pFort->isEnemy())
	{
		m_pTargetFort = m_pSkillBattle->getPlayer()->getShip()->getFortMgr()->getFortByIndex(m_pFort->getFortIndex(), false);
	}
	else
	{
		m_pTargetFort = m_pSkillBattle->getEnemy()->getShip()->getFortMgr()->getFortByIndex(m_pFort->getFortIndex(), true);
	}
}

void CFortSkill::chooseStateFort(int nState)
{
	if (m_pFort->isEnemy())
	{
		map<int, CFort*> mapPlayerForts = m_pSkillBattle->getPlayer()->getShip()->getFortMgr()->getPlayerFort();
		map<int, CFort*>::iterator iter = mapPlayerForts.begin();
		vector<CFort*> vecStateFort;
		for (; iter != mapPlayerForts.end(); iter++)
		{
			if (nState == Debuff::FORT_PARALYSIS)
			{
				if ((*iter).second->isFortLive() && (*iter).second->isParalysisState())
				{
					vecStateFort.insert(vecStateFort.end(), (*iter).second);
				}
			}
			else if (nState == Debuff::FORT_BURNING)
			{
				if ((*iter).second->isFortLive() && (*iter).second->isBurningState())
				{
					vecStateFort.insert(vecStateFort.end(), (*iter).second);
				}
			}	
		}
		if (vecStateFort.size() == 0)
		{
			m_pTargetFort = m_pSkillBattle->getPlayer()->getShip()->getFortMgr()->getFortByIndex(m_pFort->getFortIndex(), false);
		}
		else if (vecStateFort.size() == 1)
		{
			m_pTargetFort = vecStateFort[0];
		}
		else if (vecStateFort.size() > 1)
		{
			CFort *pFort = nullptr;
			for (int i = 0; i < vecStateFort.size(); i++)
			{
				if (!pFort)
				{
					pFort = vecStateFort[i];
				}
				else
				{
					if (pFort)
					{
						if (pFort->getFortHp() > vecStateFort[i]->getFortHp())
						{
							pFort = vecStateFort[i];
						}
					}
				}
			}
			m_pTargetFort = pFort;
		}
	}
	else
	{
		map<int, CFort*> mapEnemyForts = m_pSkillBattle->getEnemy()->getShip()->getFortMgr()->getEnemyFort();
		map<int, CFort*>::iterator iter = mapEnemyForts.begin();
		vector<CFort*> vecStateFort;
		for (; iter != mapEnemyForts.end(); iter++)
		{
			if (nState == Debuff::FORT_PARALYSIS)
			{
				if ((*iter).second->isFortLive() && (*iter).second->isParalysisState())
				{
					vecStateFort.insert(vecStateFort.end(), (*iter).second);
				}
			}
			else if (nState == Debuff::FORT_BURNING)
			{
				if ((*iter).second->isFortLive() && (*iter).second->isBurningState())
				{
					vecStateFort.insert(vecStateFort.end(), (*iter).second);
				}
			}
		}
		if (vecStateFort.size() == 0)
		{
			m_pTargetFort = m_pSkillBattle->getEnemy()->getShip()->getFortMgr()->getFortByIndex(m_pFort->getFortIndex(), true);
		}
		else if (vecStateFort.size() == 1)
		{
			m_pTargetFort = vecStateFort[0];
		}
		else if (vecStateFort.size() > 1)
		{
			CFort *pFort = nullptr;
			for (int i = 0; i < vecStateFort.size(); i++)
			{
				if (!pFort)
				{
					pFort = vecStateFort[i];
				}
				else
				{
					if (pFort)
					{
						if (pFort->getFortHp() > vecStateFort[i]->getFortHp())
						{
							pFort = vecStateFort[i];
						}
					}
				}
			}
			m_pTargetFort = pFort;
		}
	}
}

void CFortSkill::fireSkill()
{
	switch (m_nSkillID)
	{
	case 50001:
		firstSkill_DieCut();
		break;
	case 50002:
		secondSkill_SpreadPos();
		break;
	case 50003:
		thirdSkill_MaximalBurst();
		break;
	case 50004:
		fourthSkill_CrazyBurst();
		break;
	case 50005:
		fifthSkill_SpiralWave();
		break;
	case 50006:
		sixthSkill_StormShoot();
		break;
	case 50007:
		seventhSkill_GodLight();
		break;
	case 50008:
		eighthSkill_LightningStrike();
		break;
	case 50009:
		ninthSkill_SpiralHit();
		break;
	case 50010:
		tenthSkill_LightShoot();
		break;
	case 50011:
		eleventhSkill_BirdAngry();
		break;
	case 50012:
		twelfthSkill_EnergyZone();
		break;
	case 50013:
		thirteenthSkill_PulseWave();
		break;
	case 50014:
		fourteenthSkill_LightSpread();
		break;
	case 50015:
		fifteenthSkill_DragonHowl();
		break;
	case 50016:
		sixteenthSkill_FightVoice();
		break;
	case 50017:
		seventeenthSkill_DestroyLight();
		break;
	case 50018:
		eighteenthSkill_UltimateBlow();
		break;
	case 50019:
		nineteenthSkill_DoubleWinding();
		break;
	case 50020:
		twentiethSkill_AbsoluteDomain();
		break;
	case 50021:
		twentyFirst_SaveLight();
		break;
	case 50022:
		twentySecond_DestroyBurst();
		break;
	case 50023:
		twentyThird_ElectricStorm();
		break;
	case 50024:
		twentyFourth_FatalShoot();
		break;
	case 50025:
		twentyFifth_OlympicFlame();
		break;
	case 50026:
		twentySixth_PunishKnife();
		break;
	case 50027:
		twentySeventh_DoomsdayTrial();
		break;
	case 50028:
		twentyEighth_HolyDiscipline();
		break;
	case 50029:
		twenthNinth_LightningStorm();
		break;
	case 50030:
		thirtieth_EndKnife();
		break;
	default:

		break;
	}
	
}

// 炮台类型伤害系数， 类型补正系数， 范围伤害系数， 类型范围补正系数， 技能等级 (技能伤害)
double CFortSkill::countSkillDamagePercent(double dType, double dCorrectType, double dRange, double dCorrectRange, int nSkillLevel)
{
	if (nSkillLevel == 1)
	{
		return (dType * dCorrectType + dRange * dCorrectRange) * m_dStarDomainCoe;
	}
	else
	{
		return dType * dCorrectType * m_dStarDomainCoe + (m_dStarDomainCoe + nSkillLevel) * dRange * dCorrectRange;
	}
}
// 效果命中， 炮台类型命中系数， 类型补正系数， 命中升级成长， 技能等级(buff命中率)
double CFortSkill::countScorePercent(double dScore, double dScoreCoe, double dCorrectScore, double dScoreGrow, int nSkillLevel)
{
	if (nSkillLevel == 1)
	{
		return dScore * dScoreCoe * dCorrectScore;
	}
	else 
	{
		return (dScore + nSkillLevel * dScoreGrow) * dScoreCoe * dCorrectScore;
	}
}
// 初始持续时间， 炮台类型持续时间系数， 类型补正系数， 持续时间成长， 技能等级(buff持续时间)
double CFortSkill::countContinueTime(double dBuffBeginTime, double dContinueCoe, double dCorrectContinue, double dTimeGrow, int nSkillLevel)
{
	if (nSkillLevel == 1)
	{
		return dBuffBeginTime * dContinueCoe * dCorrectContinue;
	}
	else
	{
		return (dBuffBeginTime + nSkillLevel * dTimeGrow) * dContinueCoe * dCorrectContinue;
	}
}
// 状态效果值， 炮台类型状态系数， 类型补正系数， 效果升级成长， 技能等级(效果伤害值)
double CFortSkill::countEffectValue(double dEffectValue, double dBuffCoe, double dCorrectBuff, double dBuffGrow, double nSkillLevel)
{
	if (nSkillLevel == 1)
	{
		return dEffectValue * dBuffCoe * dCorrectBuff;
	}
	else
	{
		return (dEffectValue + nSkillLevel * dBuffGrow) * dBuffCoe * dCorrectBuff;
	}

}

// type 1 :普通技能伤害   type 2 :加重技能伤害（额外百分比伤害）
void CFortSkill::damagePlayerFort(int nTypeFire, double dAddDamage)
{
	double skillDamage = m_pFort->getFortAck() * (m_dSkillDamagePercent + dAddDamage);
	if (m_pTargetFort->isFortLive())
	{
		if (nTypeFire == 1)
		{
			m_pTargetFort->damageFortBySkillBurst(skillDamage * (1 - m_pTargetFort->getUnInjuryCoe()));
		}
		else if (nTypeFire == 2)
		{
			m_pTargetFort->damageFortBySkillAddDamage(skillDamage * (1 - m_pTargetFort->getUnInjuryCoe()));
		}
	}
	else
	{
		map<int, CFort*> mapPlayerForts;
		if (m_pFort->isEnemy())
		{
			mapPlayerForts = m_pSkillBattle->getPlayer()->getShip()->getFortMgr()->getPlayerFort();
		}
		else
		{
			mapPlayerForts = m_pSkillBattle->getEnemy()->getShip()->getFortMgr()->getEnemyFort();
		}
		map<int, CFort*>::iterator iter = mapPlayerForts.begin();
		int nCountLiveFort = 0;
		for (; iter != mapPlayerForts.end(); iter++)
		{
			if ((*iter).second->getFortIndex() != m_pFort->getFortIndex() && (*iter).second->isFortLive())
			{
				nCountLiveFort++;
			}
		}
		if (nCountLiveFort == 2)
		{
			skillDamage *= 0.5;
		}
		iter = mapPlayerForts.begin();
		for (; iter != mapPlayerForts.end(); iter++)
		{
			if ((*iter).second->isFortLive())
			{
				if (nTypeFire == 1)
				{
					(*iter).second->damageFortBySkillBurst(skillDamage * (1 - (*iter).second->getUnInjuryCoe()));
				}
				else if (nTypeFire == 2)
				{
					(*iter).second->damageFortBySkillAddDamage(skillDamage * (1 - (*iter).second->getUnInjuryCoe()));
				}
			}
		}
	}
}

void CFortSkill::damageWholePlayerForts()
{
	double skillDamage = m_pFort->getFortAck() * m_dSkillDamagePercent;
	map<int, CFort*> mapPlayerForts = m_pSkillBattle->getPlayer()->getShip()->getFortMgr()->getPlayerFort();
	map<int, CFort*>::iterator iter = mapPlayerForts.begin();
	//int nCountLiveFort = 0;
	//double resultDamage = 0.0;
	//for (; iter != mapPlayerForts.end(); iter++)
	//{
	//	if ((*iter).second->isFortLive())
	//	{
	//		nCountLiveFort++;
	//	}
	//}
	//if (nCountLiveFort == 1)
	//{
	//	resultDamage = 3 * skillDamage;
	//}
	//else if (nCountLiveFort == 2)
	//{
	//	resultDamage = skillDamage * 1.5;
	//}
	//else if (nCountLiveFort == 3)
	//{
	//	resultDamage = skillDamage;
	//}
	//iter = mapPlayerForts.begin();
	for (; iter != mapPlayerForts.end(); iter++)
	{
		if ((*iter).second->isFortLive())
		{
			(*iter).second->damageFortBySkillBurst(skillDamage * (1 - (*iter).second->getUnInjuryCoe()));
		}
	}
	//for (; iter != mapPlayerForts.end(); iter++)
	//{
	//	if ((*iter).second->isFortLive())
	//	{
	//		(*iter).second->damageFortBySkillBurst(skillDamage * (1 - (*iter).second->getUnInjuryCoe()));
	//	}
	//	else 
	//	{
	//		map<int, CFort*>::iterator secondIter = mapPlayerForts.begin();
	//		int nCountLiveFort = 0;
	//		int damageToCount = 0;
	//		for (; secondIter != mapPlayerForts.end(); secondIter++)
	//		{
	//			if ((*iter).second->getFortIndex() != (*secondIter).second->getFortIndex() && (*secondIter).second->isFortLive())
	//			{
	//				nCountLiveFort++;
	//			}
	//		}
	//		if (nCountLiveFort == 2)
	//		{
	//			damageToCount = skillDamage * 0.5;
	//		}
	//		else
	//		{
	//			damageToCount = skillDamage;
	//		}
	//		secondIter = mapPlayerForts.begin();
	//		for (; secondIter != mapPlayerForts.end(); secondIter++)
	//		{
	//			if ((*secondIter).second->isFortLive())
	//			{
	//				(*secondIter).second->damageFortBySkillBurst(damageToCount * (1 - (*secondIter).second->getUnInjuryCoe()));
	//			}
	//		}
	//	}
	//}
}

void CFortSkill::damageWholeEnemyForts()
{
	double skillDamage = m_pFort->getFortAck() * m_dSkillDamagePercent;
	map<int, CFort*> mapEnemyForts = m_pSkillBattle->getEnemy()->getShip()->getFortMgr()->getEnemyFort();
	map<int, CFort*>::iterator iter = mapEnemyForts.begin();
	//int nCountLiveFort = 0;
	//double resultDamage = 0.0;
	//for (; iter != mapEnemyForts.end(); iter++)
	//{
	//	if ((*iter).second->isFortLive())
	//	{
	//		nCountLiveFort++;
	//	}
	//}
	//if (nCountLiveFort == 1)
	//{
	//	resultDamage = 3 * skillDamage;
	//}
	//else if (nCountLiveFort == 2)
	//{
	//	resultDamage = skillDamage * 1.5;
	//}
	//else if (nCountLiveFort == 3)
	//{
	//	resultDamage = skillDamage;
	//}
	//iter = mapEnemyForts.begin();
	for (; iter != mapEnemyForts.end(); iter++)
	{
		if ((*iter).second->isFortLive())
		{
			(*iter).second->damageFortBySkillBurst(skillDamage * (1 - (*iter).second->getUnInjuryCoe()));
		}
	}
	//for (; iter != mapEnemyForts.end(); iter++)
	//{
		//if ((*iter).second->isFortLive())
		//{
		//	(*iter).second->damageFortBySkillBurst(skillDamage * (1 - (*iter).second->getUnInjuryCoe()));
		//}
		//else
		//{
		//	map<int, CFort*>::iterator secondIter = mapEnemyForts.begin();
		//	int nCountLiveFort = 0;
		//	int damageToCount = 0;
		//	for (; secondIter != mapEnemyForts.end(); secondIter++)
		//	{
		//		if ((*iter).second->getFortIndex() != (*secondIter).second->getFortIndex() && (*secondIter).second->isFortLive())
		//		{
		//			nCountLiveFort++;
		//		}
		//	}
		//	if (nCountLiveFort == 2)
		//	{
		//		damageToCount = skillDamage * 0.5;
		//	}
		//	else
		//	{
		//		damageToCount = skillDamage;
		//	}
		//	secondIter = mapEnemyForts.begin();
		//	for (; secondIter != mapEnemyForts.end(); secondIter++)
		//	{
		//		if ((*secondIter).second->isFortLive() )
		//		{
		//			(*secondIter).second->damageFortBySkillBurst(damageToCount * (1 - (*secondIter).second->getUnInjuryCoe()));
		//		}
		//	}
		//}
	//}
}

CFort* CFortSkill::getMinHpFort(map<int, CFort*> mapForts)
{
	CFort *pFort = nullptr;
	map<int, CFort*>::iterator iter = mapForts.begin();
	for (; iter != mapForts.end(); iter++)
	{
		if (!pFort && (*iter).second->isFortLive())
		{
			pFort = (*iter).second;
		}
		else
		{
			if (pFort)
			{
				if (pFort->getFortHp() > (*iter).second->getFortHp() && (*iter).second->isFortLive())
				{
					pFort = (*iter).second;
				}
			}
		}
	}
	return pFort;
}

//对单体目标造成{变量}%伤害
void CFortSkill::firstSkill_DieCut()
{
	if (m_pSkillBattle->getBattleType() == BattleType::BATTLE_NORMAL)
	{
		damagePlayerFort(1, 0);
	}
	else if (m_pSkillBattle->getBattleType() == BattleType::BATTLE_BOSS)
	{
		double damage = m_pFort->getFortAck() * m_dSkillDamagePercent;
		m_pSkillBattle->getBoss()->bossBeDamageByFortSkill(damage);
	}
}

//对全体目标造成{变量}%伤害，并对目标造成火力干扰【伤害-{变量}%】，持续{变量}秒(全体)
void CFortSkill::secondSkill_SpreadPos()
{
	if (m_pSkillBattle->getBattleType() == BattleType::BATTLE_NORMAL)
	{
		if (m_pFort->isEnemy())
		{
			damageWholePlayerForts();    // 伤害
			// buff
			map<int, CFort*> mapPlayerForts = m_pSkillBattle->getPlayer()->getShip()->getFortMgr()->getPlayerFort();
			map<int, CFort*>::iterator iter = mapPlayerForts.begin();
			for (; iter != mapPlayerForts.end(); iter++)
			{
				m_pSkillBattle->getPlayer()->getBuffMgr()->addBuff(Debuff::FORT_ATK_DISTURB, (*iter).second->getFortID(), m_dSkillEffectValue, m_dContinueTime);
			}
		}
		else
		{
			damageWholeEnemyForts();
			map<int, CFort*> mapEnemyForts = m_pSkillBattle->getEnemy()->getShip()->getFortMgr()->getEnemyFort();
			map<int, CFort*>::iterator iter = mapEnemyForts.begin();
			for (; iter != mapEnemyForts.end(); iter++)
			{
				m_pSkillBattle->getEnemy()->getBuffMgr()->addBuff(Debuff::FORT_ATK_DISTURB, (*iter).second->getFortID(), m_dSkillEffectValue, m_dContinueTime);
			}
		}
	}
	else if (m_pSkillBattle->getBattleType() == BattleType::BATTLE_BOSS)
	{
		double damage = m_pFort->getFortAck() * m_dSkillDamagePercent;
		m_pSkillBattle->getBoss()->bossBeDamageByFortSkill(damage);
	}
}

//对单体目标造成{变量}%伤害
void CFortSkill::thirdSkill_MaximalBurst()
{
	if (m_pSkillBattle->getBattleType() == BattleType::BATTLE_NORMAL)
	{
		damagePlayerFort(1, 0);
	}
	else if (m_pSkillBattle->getBattleType() == BattleType::BATTLE_BOSS)
	{
		double damage = m_pFort->getFortAck() * m_dSkillDamagePercent;
		m_pSkillBattle->getBoss()->bossBeDamageByFortSkill(damage);
	}
}

//对单体目标造成{变量}%伤害，当自身生命值低于30%时，额外造成50%伤害
void CFortSkill::fourthSkill_CrazyBurst()
{
	if (m_pSkillBattle->getBattleType() == BattleType::BATTLE_NORMAL)
	{
		double dHpPercent = m_pFort->getFortHp() / m_pFort->getFortMaxHp();
		if (dHpPercent >= 0.3)
		{
			damagePlayerFort(1, 0);
		}
		else
		{
			damagePlayerFort(2, 0.5);
		}
	}
	else if (m_pSkillBattle->getBattleType() == BattleType::BATTLE_BOSS)
	{
        double dHpPercent = m_pFort->getFortHp() / m_pFort->getFortMaxHp();
        if (dHpPercent < 0.3)
        {
            double damage = m_pFort->getFortAck() * m_dSkillDamagePercent * 1.5;
            m_pSkillBattle->getBoss()->bossBeDeepDamageByFortSkill(damage);
        }
        else
        {
            double damage = m_pFort->getFortAck() * m_dSkillDamagePercent * 1;
            m_pSkillBattle->getBoss()->bossBeDamageByFortSkill(damage);
        }
		
	}
}

//对单体目标造成{变量}%的技能伤害，并对我方生命值最低的炮台附加护盾【免伤+{变量}%】，持续{变量}秒 
void CFortSkill::fifthSkill_SpiralWave()
{
	if (m_pSkillBattle->getBattleType() == BattleType::BATTLE_NORMAL)
	{
		damagePlayerFort(1, 0);
		CFort *pFort = nullptr;
		if (m_pFort->isEnemy())
		{
			map<int, CFort*> mapEnemyForts = m_pSkillBattle->getEnemy()->getShip()->getFortMgr()->getEnemyFort();
			pFort = getMinHpFort(mapEnemyForts);
			m_pSkillBattle->getEnemy()->getBuffMgr()->addBuff(Buff::FORT_SHIELD, pFort->getFortID(), m_dSkillEffectValue, m_dContinueTime);
		}
		else
		{
			map<int, CFort*> mapPlayerForts = m_pSkillBattle->getPlayer()->getShip()->getFortMgr()->getPlayerFort();
			pFort = getMinHpFort(mapPlayerForts);
			m_pSkillBattle->getPlayer()->getBuffMgr()->addBuff(Buff::FORT_SHIELD, pFort->getFortID(), m_dSkillEffectValue, m_dContinueTime);
		}
	}
	else if (m_pSkillBattle->getBattleType() == BattleType::BATTLE_BOSS)
	{
		double damage = m_pFort->getFortAck() * m_dSkillDamagePercent;
		m_pSkillBattle->getBoss()->bossBeDamageByFortSkill(damage);

		map<int, CFort*> mapPlayerForts = m_pSkillBattle->getPlayer()->getShip()->getFortMgr()->getPlayerFort();
		CFort *pFort = getMinHpFort(mapPlayerForts);
		m_pSkillBattle->getPlayer()->getBuffMgr()->addBuff(Buff::FORT_SHIELD, pFort->getFortID(), m_dSkillEffectValue, m_dContinueTime);
	}
}

// 对单体目标造成{变量}%的技能伤害，并对我方生命值最低的炮台恢复{变量}%的生命值
void CFortSkill::sixthSkill_StormShoot()
{
	if (m_pSkillBattle->getBattleType() == BattleType::BATTLE_NORMAL)
	{
		damagePlayerFort(1, 0);
		CFort *pFort = nullptr;
		if (m_pFort->isEnemy())
		{
			map<int, CFort*> mapEnemyForts = m_pSkillBattle->getEnemy()->getShip()->getFortMgr()->getEnemyFort();
			pFort = getMinHpFort(mapEnemyForts);
			pFort->addHpBySkill(m_dSkillEffectValue);
		}
		else
		{
			map<int, CFort*> mapPlayerForts = m_pSkillBattle->getPlayer()->getShip()->getFortMgr()->getPlayerFort();
			pFort = getMinHpFort(mapPlayerForts);
			pFort->addHpBySkill(m_dSkillEffectValue);
		}
	}
	else if (m_pSkillBattle->getBattleType() == BattleType::BATTLE_BOSS)
	{
		double damage = m_pFort->getFortAck() * m_dSkillDamagePercent;
		m_pSkillBattle->getBoss()->bossBeDamageByFortSkill(damage);

		map<int, CFort*> mapPlayerForts = m_pSkillBattle->getPlayer()->getShip()->getFortMgr()->getPlayerFort();
		CFort *pFort = getMinHpFort(mapPlayerForts);
		pFort->addHpBySkill(m_dSkillEffectValue);
	}
}

//对单体目标造成{变量}%伤害，当目标生命值低于50%，则额外造成50%伤害
void CFortSkill::seventhSkill_GodLight()
{
	if (m_pSkillBattle->getBattleType() == BattleType::BATTLE_NORMAL)
	{
		if (m_pTargetFort->getFortHp() / m_pTargetFort->getFortMaxHp() < 0.5)
		{
			damagePlayerFort(2, 0.5);
		}
		else
		{
			damagePlayerFort(1, 0);
		}
	}
	else if (m_pSkillBattle->getBattleType() == BattleType::BATTLE_BOSS)
	{
		double damage = m_pFort->getFortAck() * m_dSkillDamagePercent;
		m_pSkillBattle->getBoss()->bossBeDamageByFortSkill(damage);
	}
}

//对单体目标造成{变量}%伤害，并有{变量}%概率对目标造成瘫痪【无法行动】，持续{变量}秒，优先攻击生命值最低的目标。
void CFortSkill::eighthSkill_LightningStrike()
{
	if (m_pSkillBattle->getBattleType() == BattleType::BATTLE_NORMAL)
	{
		damagePlayerFort(1, 0);
		if (m_nAddBuff[0] < (m_dScorePercent * 100))
		{
			if (m_pTargetFort->isEnemy())
			{
				m_pSkillBattle->getEnemy()->getBuffMgr()->addBuff(Debuff::FORT_PARALYSIS, m_pTargetFort->getFortID(), 0, m_dContinueTime);
			}
			else
			{
				m_pSkillBattle->getPlayer()->getBuffMgr()->addBuff(Debuff::FORT_PARALYSIS, m_pTargetFort->getFortID(), 0, m_dContinueTime);
			}
		}
	}
	else if (m_pSkillBattle->getBattleType() == BattleType::BATTLE_BOSS)
	{
		double damage = m_pFort->getFortAck() * m_dSkillDamagePercent;
		m_pSkillBattle->getBoss()->bossBeDamageByFortSkill(damage);
	}
}

//对单体目标造成{变量}%伤害，并有{变量}%概率对目标造成维修干扰【无法恢复血量】，持续{变量}秒，优先攻击生命值最低的目标。
void CFortSkill::ninthSkill_SpiralHit()
{
	if (m_pSkillBattle->getBattleType() == BattleType::BATTLE_NORMAL)
	{
		damagePlayerFort(1, 0);
		if (m_nAddBuff[0] < (m_dScorePercent * 100))
		{
			if (m_pTargetFort->isEnemy())
			{
				m_pSkillBattle->getEnemy()->getBuffMgr()->addBuff(Debuff::FORT_REPAIR_DISTURB, m_pTargetFort->getFortID(), 0, m_dContinueTime);
			}
			else
			{
				m_pSkillBattle->getPlayer()->getBuffMgr()->addBuff(Debuff::FORT_REPAIR_DISTURB, m_pTargetFort->getFortID(), 0, m_dContinueTime);
			}
		}
	}
	else if (m_pSkillBattle->getBattleType() == BattleType::BATTLE_BOSS)
	{
		double damage = m_pFort->getFortAck() * m_dSkillDamagePercent;
		m_pSkillBattle->getBoss()->bossBeDamageByFortSkill(damage);
	}
}

//对全体目标造成{变量}%伤害,当目标处于燃烧状态时有{变量}%概率对目标造成瘫痪【无法行动】，持续{变量}秒
void CFortSkill::tenthSkill_LightShoot()
{
	if (m_pSkillBattle->getBattleType() == BattleType::BATTLE_NORMAL)
	{
		//srand((unsigned)time(NULL));
		if (m_pFort->isEnemy())
		{
			damageWholePlayerForts();
			map<int, CFort*> mapPlayerForts = m_pSkillBattle->getPlayer()->getShip()->getFortMgr()->getPlayerFort();
			map<int, CFort*>::iterator iter = mapPlayerForts.begin();
			for (; iter != mapPlayerForts.end(); iter++)
			{
				if ((*iter).second->isBurningState())
				{
					/*int nRandNum = rand() % 100;*/
					if (m_nAddBuff[(*iter).second->getFortIndex()] < (m_dScorePercent * 100))
					{
						m_pSkillBattle->getPlayer()->getBuffMgr()->addBuff(Debuff::FORT_PARALYSIS, (*iter).second->getFortID(), 0, m_dContinueTime);
					}
				}
			}
		}
		else
		{
			damageWholeEnemyForts();
			map<int, CFort*> mapEnemyForts = m_pSkillBattle->getEnemy()->getShip()->getFortMgr()->getEnemyFort();
			map<int, CFort*>::iterator iter = mapEnemyForts.begin();
			for (; iter != mapEnemyForts.end(); iter++)
			{
				if ((*iter).second->isBurningState())
				{
					if (m_nAddBuff[(*iter).second->getFortIndex()] < (m_dScorePercent * 100))
					{
						m_pSkillBattle->getEnemy()->getBuffMgr()->addBuff(Debuff::FORT_PARALYSIS, (*iter).second->getFortID(), 0, m_dContinueTime);
					}
				}
			}
		}
	}
	else if (m_pSkillBattle->getBattleType() == BattleType::BATTLE_BOSS)
	{
		double damage = m_pFort->getFortAck() * m_dSkillDamagePercent;
		m_pSkillBattle->getBoss()->bossBeDamageByFortSkill(damage);
	}
}

//对全体目标造成{ 变量 }%伤害，并有{ 变量 }%概率对目标造成燃烧【每0.5秒损失1%生命】，持续{ 变量 }秒
void CFortSkill::eleventhSkill_BirdAngry()
{
	if (m_pSkillBattle->getBattleType() == BattleType::BATTLE_NORMAL)
	{
		if (m_pFort->isEnemy())
		{
			damageWholePlayerForts();
			map<int, CFort*> mapPlayerForts = m_pSkillBattle->getPlayer()->getShip()->getFortMgr()->getPlayerFort();
			map<int, CFort*>::iterator iter = mapPlayerForts.begin();
			for (; iter != mapPlayerForts.end(); iter++)
			{
				if ((*iter).second->isFortLive())
				{
					if (m_nAddBuff[(*iter).second->getFortIndex()] < (m_dScorePercent * 100))
					{
						m_pSkillBattle->getPlayer()->getBuffMgr()->addBuff(Debuff::FORT_BURNING, (*iter).second->getFortID(), 0, m_dContinueTime);
					}
				}
			}
		}
		else
		{
			damageWholeEnemyForts();
			map<int, CFort*> mapEnemyForts = m_pSkillBattle->getEnemy()->getShip()->getFortMgr()->getEnemyFort();
			map<int, CFort*>::iterator iter = mapEnemyForts.begin();
			for (; iter != mapEnemyForts.end(); iter++)
			{
				if ((*iter).second->isFortLive())
				{
					if (m_nAddBuff[(*iter).second->getFortIndex()] < (m_dScorePercent * 100))
					{
						m_pSkillBattle->getEnemy()->getBuffMgr()->addBuff(Debuff::FORT_BURNING, (*iter).second->getFortID(), 0, m_dContinueTime);
					}
				}
			}
		}
	}
	else if (m_pSkillBattle->getBattleType() == BattleType::BATTLE_BOSS)
	{
		double damage = m_pFort->getFortAck() * m_dSkillDamagePercent;
		m_pSkillBattle->getBoss()->bossBeDamageByFortSkill(damage);
	}
}

//对全体目标造成{变量}%伤害，当目标处于瘫痪状态时有{变量}%概率对目标造成能量干扰【无法获得能量且释放技能】，持续{变量}秒
void CFortSkill::twelfthSkill_EnergyZone()
{
	if (m_pSkillBattle->getBattleType() == BattleType::BATTLE_NORMAL)
	{
		if (m_pFort->isEnemy())
		{
			damageWholePlayerForts();
			map<int, CFort*> mapPlayerForts = m_pSkillBattle->getPlayer()->getShip()->getFortMgr()->getPlayerFort();
			map<int, CFort*>::iterator iter = mapPlayerForts.begin();
			for (; iter != mapPlayerForts.end(); iter++)
			{
				if ((*iter).second->isFortLive() && (*iter).second->isParalysisState())
				{
					if (m_nAddBuff[(*iter).second->getFortIndex()] < (m_dScorePercent * 100))
					{
						m_pSkillBattle->getPlayer()->getBuffMgr()->addBuff(Debuff::FORT_ENERGY_DISTURB, (*iter).second->getFortID(), 0, m_dContinueTime);
					}
				}
			}
		}
		else
		{
			damageWholeEnemyForts();
			map<int, CFort*> mapEnemyForts = m_pSkillBattle->getEnemy()->getShip()->getFortMgr()->getEnemyFort();
			map<int, CFort*>::iterator iter = mapEnemyForts.begin();
			for (; iter != mapEnemyForts.end(); iter++)
			{
				if ((*iter).second->isFortLive() && (*iter).second->isParalysisState())
				{
					if (m_nAddBuff[(*iter).second->getFortIndex()] < (m_dScorePercent * 100))
					{
						m_pSkillBattle->getEnemy()->getBuffMgr()->addBuff(Debuff::FORT_ENERGY_DISTURB, (*iter).second->getFortID(), 0, m_dContinueTime);
					}
				}
			}
		}
	}
	else if (m_pSkillBattle->getBattleType() == BattleType::BATTLE_BOSS)
	{
		double damage = m_pFort->getFortAck() * m_dSkillDamagePercent;
		m_pSkillBattle->getBoss()->bossBeDamageByFortSkill(damage);
	}
}

//对单体目标造成{变量}%伤害，并对处于瘫痪状态的目标额外造成50%的伤害，且优先攻击处于瘫痪状态的目标。
void CFortSkill::thirteenthSkill_PulseWave()
{
	if (m_pSkillBattle->getBattleType() == BattleType::BATTLE_NORMAL)
	{
		if (m_pTargetFort->isParalysisState())
		{
			damagePlayerFort(2, 0.5);
		}
		else
		{
			damagePlayerFort(1, 0);
		}
	}
	else if (m_pSkillBattle->getBattleType() == BattleType::BATTLE_BOSS)
	{
		double damage = m_pFort->getFortAck() * m_dSkillDamagePercent;
		m_pSkillBattle->getBoss()->bossBeDamageByFortSkill(damage);
	}
}

//对全体目标造成{ 变量 }%伤害，有{ 变量 }%概率造成能量干扰【无法获得能量且释放技能与释放技能】，持续{ 变量 }秒
void CFortSkill::fourteenthSkill_LightSpread()
{
	if (m_pSkillBattle->getBattleType() == BattleType::BATTLE_NORMAL)
	{
		if (m_pFort->isEnemy())
		{
			damageWholePlayerForts();
			map<int, CFort*> mapPlayerForts = m_pSkillBattle->getPlayer()->getShip()->getFortMgr()->getPlayerFort();
			map<int, CFort*>::iterator iter = mapPlayerForts.begin();
			for (; iter != mapPlayerForts.end(); iter++)
			{
				if ((*iter).second->isFortLive())
				{
					if (m_nAddBuff[(*iter).second->getFortIndex()] < (m_dScorePercent * 100))
					{
						m_pSkillBattle->getPlayer()->getBuffMgr()->addBuff(Debuff::FORT_ENERGY_DISTURB, (*iter).second->getFortID(), 0, m_dContinueTime);
					}
				}
			}
		}
		else
		{
			damageWholeEnemyForts();
			map<int, CFort*> mapEnemyForts = m_pSkillBattle->getEnemy()->getShip()->getFortMgr()->getEnemyFort();
			map<int, CFort*>::iterator iter = mapEnemyForts.begin();
			for (; iter != mapEnemyForts.end(); iter++)
			{
				if ((*iter).second->isFortLive())
				{
					if (m_nAddBuff[(*iter).second->getFortIndex()] < (m_dScorePercent * 100))
					{
						m_pSkillBattle->getEnemy()->getBuffMgr()->addBuff(Debuff::FORT_ENERGY_DISTURB, (*iter).second->getFortID(), 0, m_dContinueTime);
					}
				}
			}
		}
	}
	else if (m_pSkillBattle->getBattleType() == BattleType::BATTLE_BOSS)
	{
		double damage = m_pFort->getFortAck() * m_dSkillDamagePercent;
		m_pSkillBattle->getBoss()->bossBeDamageByFortSkill(damage);
	}
}

//对单体目标造成{变量}%伤害，并有{变量}%概率对目标造成瘫痪【无法行动】，持续{变量}秒
void CFortSkill::fifteenthSkill_DragonHowl()
{
	if (m_pSkillBattle->getBattleType() == BattleType::BATTLE_NORMAL)
	{
		damagePlayerFort(1, 0);
		if (m_nAddBuff[0] < (m_dScorePercent * 100))
		{
			if (m_pTargetFort->isEnemy())
			{
				m_pSkillBattle->getEnemy()->getBuffMgr()->addBuff(Debuff::FORT_PARALYSIS, m_pTargetFort->getFortID(), 0, m_dContinueTime);
			}
			else
			{
				m_pSkillBattle->getPlayer()->getBuffMgr()->addBuff(Debuff::FORT_PARALYSIS, m_pTargetFort->getFortID(), 0, m_dContinueTime);
			}
		}
	}
	else if (m_pSkillBattle->getBattleType() == BattleType::BATTLE_BOSS)
	{
		double damage = m_pFort->getFortAck() * m_dSkillDamagePercent;
		m_pSkillBattle->getBoss()->bossBeDamageByFortSkill(damage);
	}
}

//对单体目标造成{变量}%伤害，对燃烧状态的目标额外造成50%的伤害，且优先攻击处于燃烧状态的目标。当自身处于火力增幅状态时额外伤害提升至100%。
void CFortSkill::sixteenthSkill_FightVoice()
{
	if (m_pSkillBattle->getBattleType() == BattleType::BATTLE_NORMAL)
	{
		if (m_pTargetFort->isBurningState())
		{
			if (m_pFort->isAckUpState())
			{
				damagePlayerFort(2, 1);
			}
			else
			{
				damagePlayerFort(2, 0.5);
			}
		}
		else
		{
			damagePlayerFort(1, 0);
		}
	}
	else if (m_pSkillBattle->getBattleType() == BattleType::BATTLE_BOSS)
	{
		double damage = m_pFort->getFortAck() * m_dSkillDamagePercent;
		m_pSkillBattle->getBoss()->bossBeDamageByFortSkill(damage);
	}
}

//对目标造成{变量}%伤害，有{变量}%概率对目标造成燃烧【每0.5秒损失1%生命】，持续{变量}秒，且优先攻击处于生命值最低的目标。当自身处于火力增幅状态燃烧命中率增加至100%
void CFortSkill::seventeenthSkill_DestroyLight()
{
	if (m_pSkillBattle->getBattleType() == BattleType::BATTLE_NORMAL)
	{
		damagePlayerFort(1, 0);
		if (m_pFort->isAckUpState())
		{
			if (m_pTargetFort->isEnemy())
			{
				m_pSkillBattle->getEnemy()->getBuffMgr()->addBuff(Debuff::FORT_BURNING, m_pTargetFort->getFortID(), 0, m_dContinueTime);
			}
			else
			{
				m_pSkillBattle->getPlayer()->getBuffMgr()->addBuff(Debuff::FORT_BURNING, m_pTargetFort->getFortID(), 0, m_dContinueTime);
			}
		}
		else
		{
			if (m_nAddBuff[0] < (m_dScorePercent * 100))
			{
				if (m_pTargetFort->isEnemy())
				{
					m_pSkillBattle->getEnemy()->getBuffMgr()->addBuff(Debuff::FORT_BURNING, m_pTargetFort->getFortID(), 0, m_dContinueTime);
				}
				else
				{
					m_pSkillBattle->getPlayer()->getBuffMgr()->addBuff(Debuff::FORT_BURNING, m_pTargetFort->getFortID(), 0, m_dContinueTime);
				}
			}
		}
	}
	else if (m_pSkillBattle->getBattleType() == BattleType::BATTLE_BOSS)
	{
		double damage = m_pFort->getFortAck() * m_dSkillDamagePercent;
		m_pSkillBattle->getBoss()->bossBeDamageByFortSkill(damage);
	}
}

//对单体目标造成{变量}%伤害，并对我方进攻型炮台附加火力增幅特效【伤害+{变量}%】，持续{变量}秒
void CFortSkill::eighteenthSkill_UltimateBlow()
{
	if (m_pSkillBattle->getBattleType() == BattleType::BATTLE_NORMAL)
	{
		damagePlayerFort(1, 0);
		if (m_pFort->isEnemy())
		{
			map<int, CFort*> mapEnemyForts = m_pSkillBattle->getEnemy()->getShip()->getFortMgr()->getEnemyFort();
			map<int, CFort*>::iterator iter = mapEnemyForts.begin();
			for (; iter != mapEnemyForts.end(); iter++)
			{
				if ((*iter).second->isFortLive() && (*iter).second->getFortType() == 0) // 0 为攻击型 
				{
					m_pSkillBattle->getEnemy()->getBuffMgr()->addBuff(Buff::FORT_ATK_ENHANCE, (*iter).second->getFortID(), m_dSkillEffectValue, m_dContinueTime);
				}
			}
		}
		else
		{
			map<int, CFort*> mapPlayerForts = m_pSkillBattle->getPlayer()->getShip()->getFortMgr()->getPlayerFort();
			map<int, CFort*>::iterator iter = mapPlayerForts.begin();
			for (; iter != mapPlayerForts.end(); iter++)
			{
				if ((*iter).second->isFortLive() && (*iter).second->getFortType() == 0)
				{
					m_pSkillBattle->getPlayer()->getBuffMgr()->addBuff(Buff::FORT_ATK_ENHANCE, (*iter).second->getFortID(), m_dSkillEffectValue, m_dContinueTime);
				}
			}
		}
	}
	else if (m_pSkillBattle->getBattleType() == BattleType::BATTLE_BOSS)
	{
		double damage = m_pFort->getFortAck() * m_dSkillDamagePercent;
		m_pSkillBattle->getBoss()->bossBeDamageByFortSkill(damage);

		map<int, CFort*> mapPlayerForts = m_pSkillBattle->getPlayer()->getShip()->getFortMgr()->getPlayerFort();
		map<int, CFort*>::iterator iter = mapPlayerForts.begin();
		for (; iter != mapPlayerForts.end(); iter++)
		{
			if ((*iter).second->isFortLive() && (*iter).second->getFortType() == 0)
			{
				m_pSkillBattle->getPlayer()->getBuffMgr()->addBuff(Buff::FORT_ATK_ENHANCE, (*iter).second->getFortID(), m_dSkillEffectValue, m_dContinueTime);
			}
		}
	}
}

//对单体目标造成{变量}%伤害，并对生命值＜50%的目标额外造成50%伤害，优先攻击生命值最低的炮台
void CFortSkill::nineteenthSkill_DoubleWinding()
{
	if (m_pSkillBattle->getBattleType() == BattleType::BATTLE_NORMAL)
	{
		double dHpPercent = m_pTargetFort->getFortHp() / m_pTargetFort->getFortMaxHp();
		if (dHpPercent < 0.5)
		{
			damagePlayerFort(2, 0.5);
		}
		else
		{
			damagePlayerFort(1, 0);
		}
	}
	else if (m_pSkillBattle->getBattleType() == BattleType::BATTLE_BOSS)
	{
		double damage = m_pFort->getFortAck() * m_dSkillDamagePercent;
		m_pSkillBattle->getBoss()->bossBeDamageByFortSkill(damage);
	}
}

//对单体目标造成{变量}%伤害，并对我方全体附加护盾【免伤+{变量}%】，持续{变量}秒
void CFortSkill::twentiethSkill_AbsoluteDomain()
{
	if (m_pSkillBattle->getBattleType() == BattleType::BATTLE_NORMAL)
	{
		damagePlayerFort(1, 0);
		if (m_pFort->isEnemy())
		{
			map<int, CFort*> mapEnemyForts = m_pSkillBattle->getEnemy()->getShip()->getFortMgr()->getEnemyFort();
			map<int, CFort*>::iterator iter = mapEnemyForts.begin();
			for (; iter != mapEnemyForts.end(); iter++)
			{
				if ((*iter).second->isFortLive())
				{
					m_pSkillBattle->getEnemy()->getBuffMgr()->addBuff(Buff::FORT_SHIELD, (*iter).second->getFortID(), m_dSkillEffectValue, m_dContinueTime);
				}
			}
		}
		else
		{
			map<int, CFort*> mapPlayerForts = m_pSkillBattle->getPlayer()->getShip()->getFortMgr()->getPlayerFort();
			map<int, CFort*>::iterator iter = mapPlayerForts.begin();
			for (; iter != mapPlayerForts.end(); iter++)
			{
				if ((*iter).second->isFortLive())
				{
					m_pSkillBattle->getPlayer()->getBuffMgr()->addBuff(Buff::FORT_SHIELD, (*iter).second->getFortID(), m_dSkillEffectValue, m_dContinueTime);
				}
			}
		}
	}
	else if (m_pSkillBattle->getBattleType() == BattleType::BATTLE_BOSS)
	{
		double damage = m_pFort->getFortAck() * m_dSkillDamagePercent;
		m_pSkillBattle->getBoss()->bossBeDamageByFortSkill(damage);

		map<int, CFort*> mapPlayerForts = m_pSkillBattle->getPlayer()->getShip()->getFortMgr()->getPlayerFort();
		map<int, CFort*>::iterator iter = mapPlayerForts.begin();
		for (; iter != mapPlayerForts.end(); iter++)
		{
			if ((*iter).second->isFortLive())
			{
				m_pSkillBattle->getPlayer()->getBuffMgr()->addBuff(Buff::FORT_SHIELD, (*iter).second->getFortID(), m_dSkillEffectValue, m_dContinueTime);
			}
		}
	}
}

//对单体目标造成{变量}%伤害，并对我方全体附加火力增幅【伤害+{变量}%】，持续{变量}秒
void CFortSkill::twentyFirst_SaveLight()
{
	if (m_pSkillBattle->getBattleType() == BattleType::BATTLE_NORMAL)
	{
		damagePlayerFort(1, 0);
		if (m_pFort->isEnemy())
		{
			map<int, CFort*> mapEnemyForts = m_pSkillBattle->getEnemy()->getShip()->getFortMgr()->getEnemyFort();
			map<int, CFort*>::iterator iter = mapEnemyForts.begin();
			for (; iter != mapEnemyForts.end(); iter++)
			{
				if ((*iter).second->isFortLive())
				{
					m_pSkillBattle->getEnemy()->getBuffMgr()->addBuff(Buff::FORT_ATK_ENHANCE, (*iter).second->getFortID(), m_dSkillEffectValue, m_dContinueTime);
				}
			}
		}
		else
		{
			map<int, CFort*> mapPlayerForts = m_pSkillBattle->getPlayer()->getShip()->getFortMgr()->getPlayerFort();
			map<int, CFort*>::iterator iter = mapPlayerForts.begin();
			for (; iter != mapPlayerForts.end(); iter++)
			{
				if ((*iter).second->isFortLive())
				{
					m_pSkillBattle->getPlayer()->getBuffMgr()->addBuff(Buff::FORT_ATK_ENHANCE, (*iter).second->getFortID(), m_dSkillEffectValue, m_dContinueTime);
				}
			}
		}
	}
	else if (m_pSkillBattle->getBattleType() == BattleType::BATTLE_BOSS)
	{
		double damage = m_pFort->getFortAck() * m_dSkillDamagePercent;
		m_pSkillBattle->getBoss()->bossBeDamageByFortSkill(damage);

		map<int, CFort*> mapPlayerForts = m_pSkillBattle->getPlayer()->getShip()->getFortMgr()->getPlayerFort();
		map<int, CFort*>::iterator iter = mapPlayerForts.begin();
		for (; iter != mapPlayerForts.end(); iter++)
		{
			if ((*iter).second->isFortLive())
			{
				m_pSkillBattle->getPlayer()->getBuffMgr()->addBuff(Buff::FORT_ATK_ENHANCE, (*iter).second->getFortID(), m_dSkillEffectValue, m_dContinueTime);
			}
		}
	}
}

//对全体目标造成{变量}%伤害，并对目标造成火力干扰【伤害-{变量}%】，持续{变量}秒，当自身生命值＜30%时状态持续时间翻倍。
void CFortSkill::twentySecond_DestroyBurst()
{
	if (m_pSkillBattle->getBattleType() == BattleType::BATTLE_NORMAL)
	{
		if (m_pFort->isEnemy())
		{
			damageWholePlayerForts();
			map<int, CFort*> mapPlayerForts = m_pSkillBattle->getPlayer()->getShip()->getFortMgr()->getPlayerFort();
			map<int, CFort*>::iterator iter = mapPlayerForts.begin();
			for (; iter != mapPlayerForts.end(); iter++)
			{
				if ((*iter).second->isFortLive())
				{
					if (m_pFort->getFortHp() / m_pFort->getFortMaxHp() < 0.3)
					{
						m_pSkillBattle->getPlayer()->getBuffMgr()->addBuff(Debuff::FORT_ATK_DISTURB, (*iter).second->getFortID(), m_dSkillEffectValue, m_dContinueTime * 2);
					}
					else
					{
						m_pSkillBattle->getPlayer()->getBuffMgr()->addBuff(Debuff::FORT_ATK_DISTURB, (*iter).second->getFortID(), m_dSkillEffectValue, m_dContinueTime);
					}
				}
			}
		}
		else
		{
			damageWholeEnemyForts();
			map<int, CFort*> mapEnemyForts = m_pSkillBattle->getEnemy()->getShip()->getFortMgr()->getEnemyFort();
			map<int, CFort*>::iterator iter = mapEnemyForts.begin();
			for (; iter != mapEnemyForts.end(); iter++)
			{
				if ((*iter).second->isFortLive())
				{
					if (m_pFort->getFortHp() / m_pFort->getFortMaxHp() < 0.3)
					{
						m_pSkillBattle->getEnemy()->getBuffMgr()->addBuff(Debuff::FORT_ATK_DISTURB, (*iter).second->getFortID(), m_dSkillEffectValue, m_dContinueTime * 2);
					}
					else
					{
						m_pSkillBattle->getEnemy()->getBuffMgr()->addBuff(Debuff::FORT_ATK_DISTURB, (*iter).second->getFortID(), m_dSkillEffectValue, m_dContinueTime);
					}
				}
			}
		}
	}
	else if (m_pSkillBattle->getBattleType() == BattleType::BATTLE_BOSS)
	{
		double damage = m_pFort->getFortAck() * m_dSkillDamagePercent;
		m_pSkillBattle->getBoss()->bossBeDamageByFortSkill(damage);
	}
}

//对全体目标造成{变量}%伤害，并对我方防御型炮台附加护盾【免伤+{变量}%】，持续{变量}秒，当自身生命值＜30%时状态持续时间翻倍。
void CFortSkill::twentyThird_ElectricStorm()
{
	if (m_pSkillBattle->getBattleType() == BattleType::BATTLE_NORMAL)
	{
		if (m_pFort->isEnemy())
		{
			damageWholePlayerForts();
			map<int, CFort*> mapEnemyForts = m_pSkillBattle->getEnemy()->getShip()->getFortMgr()->getEnemyFort();
			map<int, CFort*>::iterator iter = mapEnemyForts.begin();
			for (; iter != mapEnemyForts.end(); iter++)
			{
				if ((*iter).second->isFortLive() && (*iter).second->getFortType() == 1)  // 防御型炮台，1
				{
					if (m_pFort->getFortHp() / m_pFort->getFortMaxHp() < 0.3)
					{
						m_pSkillBattle->getEnemy()->getBuffMgr()->addBuff(Buff::FORT_SHIELD, (*iter).second->getFortID(), m_dSkillEffectValue, m_dContinueTime * 2);
					}
					else
					{
						m_pSkillBattle->getEnemy()->getBuffMgr()->addBuff(Buff::FORT_SHIELD, (*iter).second->getFortID(), m_dSkillEffectValue, m_dContinueTime);
					}
				}
			}
		}
		else
		{
			damageWholeEnemyForts();
			map<int, CFort*> mapPlayerForts = m_pSkillBattle->getPlayer()->getShip()->getFortMgr()->getPlayerFort();
			map<int, CFort*>::iterator iter = mapPlayerForts.begin();
			for (; iter != mapPlayerForts.end(); iter++)
			{
				if ((*iter).second->isFortLive() && (*iter).second->getFortType() == 1)  // 防御型炮台，1
				{
					if (m_pFort->getFortHp() / m_pFort->getFortMaxHp() < 0.3)
					{
						m_pSkillBattle->getPlayer()->getBuffMgr()->addBuff(Buff::FORT_SHIELD, (*iter).second->getFortID(), m_dSkillEffectValue, m_dContinueTime * 2);
					}
					else
					{
						m_pSkillBattle->getPlayer()->getBuffMgr()->addBuff(Buff::FORT_SHIELD, (*iter).second->getFortID(), m_dSkillEffectValue, m_dContinueTime);
					}
				}
			}
		}
	}
	else if (m_pSkillBattle->getBattleType() == BattleType::BATTLE_BOSS)
	{
		double damage = m_pFort->getFortAck() * m_dSkillDamagePercent;
		m_pSkillBattle->getBoss()->bossBeDamageByFortSkill(damage);

		map<int, CFort*> mapPlayerForts = m_pSkillBattle->getPlayer()->getShip()->getFortMgr()->getPlayerFort();
		map<int, CFort*>::iterator iter = mapPlayerForts.begin();
		for (; iter != mapPlayerForts.end(); iter++)
		{
			if ((*iter).second->isFortLive() && (*iter).second->getFortType() == 1)  // 防御型炮台，1
			{
				if (m_pFort->getFortHp() / m_pFort->getFortMaxHp() < 0.3)
				{
					m_pSkillBattle->getPlayer()->getBuffMgr()->addBuff(Buff::FORT_SHIELD, (*iter).second->getFortID(), m_dSkillEffectValue, m_dContinueTime * 2);
				}
				else
				{
					m_pSkillBattle->getPlayer()->getBuffMgr()->addBuff(Buff::FORT_SHIELD, (*iter).second->getFortID(), m_dSkillEffectValue, m_dContinueTime);
				}
			}
		}
	}
}

//对全体目标造成{变量}%伤害，并对我方防御型炮台恢复{变量}%的生命值，当自身生命值＜30%时恢复效果翻倍。
void CFortSkill::twentyFourth_FatalShoot()
{
	if (m_pSkillBattle->getBattleType() == BattleType::BATTLE_NORMAL)
	{
		if (m_pFort->isEnemy())
		{
			damageWholePlayerForts();
			map<int, CFort*> mapEnemyForts = m_pSkillBattle->getEnemy()->getShip()->getFortMgr()->getEnemyFort();
			map<int, CFort*>::iterator iter = mapEnemyForts.begin();
			for (; iter != mapEnemyForts.end(); iter++)
			{
				if ((*iter).second->isFortLive() && (*iter).second->getFortType() == 1)  // 防御型炮台，1
				{
					if (m_pFort->getFortHp() / m_pFort->getFortMaxHp() < 0.3)
					{
						(*iter).second->addHpBySkill(m_dSkillEffectValue * 2);
					}
					else
					{
						(*iter).second->addHpBySkill(m_dSkillEffectValue);
					}
				}
			}
		}
		else
		{
			damageWholeEnemyForts();
			map<int, CFort*> mapPlayerForts = m_pSkillBattle->getPlayer()->getShip()->getFortMgr()->getPlayerFort();
			map<int, CFort*>::iterator iter = mapPlayerForts.begin();
			for (; iter != mapPlayerForts.end(); iter++)
			{
				if ((*iter).second->isFortLive() && (*iter).second->getFortType() == 1)  // 防御型炮台，1
				{
					if (m_pFort->getFortHp() / m_pFort->getFortMaxHp() < 0.3)
					{
						(*iter).second->addHpBySkill(m_dSkillEffectValue * 2);
					}
					else
					{
						(*iter).second->addHpBySkill(m_dSkillEffectValue);
					}
				}
			}
		}
	}
	else if (m_pSkillBattle->getBattleType() == BattleType::BATTLE_BOSS)
	{
		double damage = m_pFort->getFortAck() * m_dSkillDamagePercent;
		m_pSkillBattle->getBoss()->bossBeDamageByFortSkill(damage);

		map<int, CFort*> mapPlayerForts = m_pSkillBattle->getPlayer()->getShip()->getFortMgr()->getPlayerFort();
		map<int, CFort*>::iterator iter = mapPlayerForts.begin();
		for (; iter != mapPlayerForts.end(); iter++)
		{
			if ((*iter).second->isFortLive() && (*iter).second->getFortType() == 1)  // 防御型炮台，1
			{
				if (m_pFort->getFortHp() / m_pFort->getFortMaxHp() < 0.3)
				{
					(*iter).second->addHpBySkill(m_dSkillEffectValue * 2);
				}
				else
				{
					(*iter).second->addHpBySkill(m_dSkillEffectValue);
				}
			}
		}
	}
}

//对全体目标造成{变量}%伤害，有{变量}%概率对目标造成燃烧【每0.5秒损失1%生命】，持续2秒，当目标处于维修干扰状态时燃烧状态命中率提升至100%
void CFortSkill::twentyFifth_OlympicFlame()
{
	if (m_pSkillBattle->getBattleType() == BattleType::BATTLE_NORMAL)
	{
		if (m_pFort->isEnemy())
		{
			damageWholePlayerForts();
			map<int, CFort*> mapPlayerFort = m_pSkillBattle->getPlayer()->getShip()->getFortMgr()->getPlayerFort();
			map<int, CFort*>::iterator iter = mapPlayerFort.begin();
			for (; iter != mapPlayerFort.end(); iter++)
			{
				if ((*iter).second->isFortLive())
				{
					if ((*iter).second->isUnrepaireState())
					{
						m_pSkillBattle->getPlayer()->getBuffMgr()->addBuff(Debuff::FORT_BURNING, (*iter).second->getFortID(), 0, m_dContinueTime);
					}
					else
					{
						if (m_nAddBuff[(*iter).second->getFortIndex()] < (m_dScorePercent * 100))
						{
							m_pSkillBattle->getPlayer()->getBuffMgr()->addBuff(Debuff::FORT_BURNING, (*iter).second->getFortID(), 0, m_dContinueTime);
						}
					}
				}
			}
		}
		else
		{
			damageWholeEnemyForts();
			map<int, CFort*> mapEnemyForts = m_pSkillBattle->getEnemy()->getShip()->getFortMgr()->getEnemyFort();
			map<int, CFort*>::iterator iter = mapEnemyForts.begin();
			for (; iter != mapEnemyForts.end(); iter++)
			{
				if ((*iter).second->isFortLive())
				{
					if ((*iter).second->isUnrepaireState())
					{
						m_pSkillBattle->getEnemy()->getBuffMgr()->addBuff(Debuff::FORT_BURNING, (*iter).second->getFortID(), 0, m_dContinueTime);
					}
					else
					{
						if (m_nAddBuff[(*iter).second->getFortIndex()] < (m_dScorePercent * 100))
						{
							m_pSkillBattle->getEnemy()->getBuffMgr()->addBuff(Debuff::FORT_BURNING, (*iter).second->getFortID(), 0, m_dContinueTime);
						}
					}
				}
			}
		}
	}
	else if (m_pSkillBattle->getBattleType() == BattleType::BATTLE_BOSS)
	{
		double damage = m_pFort->getFortAck() * m_dSkillDamagePercent;
		m_pSkillBattle->getBoss()->bossBeDamageByFortSkill(damage);
	}
}

//对单体目标造成{变量}%伤害，若目标处于燃烧或维修干扰状态时对我方全体炮台恢复{变量}%的生命值。
void CFortSkill::twentySixth_PunishKnife()
{
	if (m_pSkillBattle->getBattleType() == BattleType::BATTLE_NORMAL)
	{
		damagePlayerFort(1, 0);
		if (m_pTargetFort->isBurningState() || m_pTargetFort->isUnrepaireState())
		{
			if (m_pTargetFort->isEnemy())
			{
				map<int, CFort*> mapPlayerFort = m_pSkillBattle->getPlayer()->getShip()->getFortMgr()->getPlayerFort();
				map<int, CFort*>::iterator iter = mapPlayerFort.begin();
				for (; iter != mapPlayerFort.end(); iter++)
				{
					if ((*iter).second->isFortLive())
					{
						(*iter).second->addHpBySkill(m_dSkillEffectValue);
					}
				}
			}
			else
			{
				map<int, CFort*> mapEnemyFort = m_pSkillBattle->getEnemy()->getShip()->getFortMgr()->getEnemyFort();
				map<int, CFort*>::iterator iter = mapEnemyFort.begin();
				for (; iter != mapEnemyFort.end(); iter++)
				{
					if ((*iter).second->isFortLive())
					{
						(*iter).second->addHpBySkill(m_dSkillEffectValue);
					}
				}
			}
		}
	}
	else if (m_pSkillBattle->getBattleType() == BattleType::BATTLE_BOSS)
	{
		double damage = m_pFort->getFortAck() * m_dSkillDamagePercent;
		m_pSkillBattle->getBoss()->bossBeDamageByFortSkill(damage);
	}
}

//对全体目标造成{变量}%伤害，对{变量}%概率对目标造成维修干扰【无法恢复血量】，持续{变量}秒，当目标处于燃烧状态时维修干扰命中率提升至100%
void CFortSkill::twentySeventh_DoomsdayTrial()
{
	if (m_pSkillBattle->getBattleType() == BattleType::BATTLE_NORMAL)
	{
		if (m_pFort->isEnemy())
		{
			damageWholePlayerForts();
			map<int, CFort*> mapPlayerForts = m_pSkillBattle->getPlayer()->getShip()->getFortMgr()->getPlayerFort();
			map<int, CFort*>::iterator iter = mapPlayerForts.begin();
			for (; iter != mapPlayerForts.end(); iter++)
			{
				if ((*iter).second->isFortLive())
				{
					if ((*iter).second->isBurningState())
					{
						m_pSkillBattle->getPlayer()->getBuffMgr()->addBuff(Debuff::FORT_REPAIR_DISTURB, (*iter).second->getFortID(), 0, m_dContinueTime);
					}
					else
					{
						if (m_nAddBuff[(*iter).second->getFortIndex()] < (m_dScorePercent * 100))
						{
							m_pSkillBattle->getPlayer()->getBuffMgr()->addBuff(Debuff::FORT_REPAIR_DISTURB, (*iter).second->getFortID(), 0, m_dContinueTime);
						}
					}
				}
			}
		}
		else
		{
			damageWholeEnemyForts();
			map<int, CFort*> mapEnemyForts = m_pSkillBattle->getEnemy()->getShip()->getFortMgr()->getEnemyFort();
			map<int, CFort*>::iterator iter = mapEnemyForts.begin();
			for (; iter != mapEnemyForts.end(); iter++)
			{
				if ((*iter).second->isFortLive())
				{
					if ((*iter).second->isBurningState())
					{
						m_pSkillBattle->getEnemy()->getBuffMgr()->addBuff(Debuff::FORT_REPAIR_DISTURB, (*iter).second->getFortID(), 0, m_dContinueTime);
					}
					else
					{
						if (m_nAddBuff[(*iter).second->getFortIndex()] < (m_dScorePercent * 100))
						{
							m_pSkillBattle->getEnemy()->getBuffMgr()->addBuff(Debuff::FORT_REPAIR_DISTURB, (*iter).second->getFortID(), 0, m_dContinueTime);
						}
					}
				}
			}
		}
	}
	else if (m_pSkillBattle->getBattleType() == BattleType::BATTLE_BOSS)
	{
		double damage = m_pFort->getFortAck() * m_dSkillDamagePercent;
		m_pSkillBattle->getBoss()->bossBeDamageByFortSkill(damage);
	}
}

//对全体目标造成{变量}%伤害，并有{变量}%概率对目标造成维修干扰【无法恢复血量】，持续{变量}秒，若目标是防守型炮台则状态命中率提升至100%
void CFortSkill::twentyEighth_HolyDiscipline()
{
	if (m_pSkillBattle->getBattleType() == BattleType::BATTLE_NORMAL)
	{
		if (m_pFort->isEnemy())
		{
			damageWholePlayerForts();
			map<int, CFort*> mapPlayerForts = m_pSkillBattle->getPlayer()->getShip()->getFortMgr()->getPlayerFort();
			map<int, CFort*>::iterator iter = mapPlayerForts.begin();
			for (; iter != mapPlayerForts.end(); iter++)
			{
				if ((*iter).second->isFortLive())
				{
					if ((*iter).second->getFortType() == 1)
					{
						m_pSkillBattle->getPlayer()->getBuffMgr()->addBuff(Debuff::FORT_REPAIR_DISTURB, (*iter).second->getFortID(), 0, m_dContinueTime);
					}
					else
					{
						if (m_nAddBuff[(*iter).second->getFortIndex()] < (m_dScorePercent * 100))
						{
							m_pSkillBattle->getPlayer()->getBuffMgr()->addBuff(Debuff::FORT_REPAIR_DISTURB, (*iter).second->getFortID(), 0, m_dContinueTime);
						}
					}
				}
			}
		}
		else
		{
			damageWholeEnemyForts();
			map<int, CFort*> mapEnemyForts = m_pSkillBattle->getEnemy()->getShip()->getFortMgr()->getEnemyFort();
			map<int, CFort*>::iterator iter = mapEnemyForts.begin();
			for (; iter != mapEnemyForts.end(); iter++)
			{
				if ((*iter).second->isFortLive())
				{
					if ((*iter).second->getFortType() == 1)
					{
						m_pSkillBattle->getEnemy()->getBuffMgr()->addBuff(Debuff::FORT_REPAIR_DISTURB, (*iter).second->getFortID(), 0, m_dContinueTime);
					}
					else
					{
						if (m_nAddBuff[(*iter).second->getFortIndex()] < (m_dScorePercent * 100))
						{
							m_pSkillBattle->getEnemy()->getBuffMgr()->addBuff(Debuff::FORT_REPAIR_DISTURB, (*iter).second->getFortID(), 0, m_dContinueTime);
						}
					}
				}
			}
		}
	}
	else if (m_pSkillBattle->getBattleType() == BattleType::BATTLE_BOSS)
	{
		double damage = m_pFort->getFortAck() * m_dSkillDamagePercent;
		m_pSkillBattle->getBoss()->bossBeDamageByFortSkill(damage);
	}
}

//对全体目标造成{变量}%伤害，并有{变量}%概率对目标造成瘫痪【无法行动】，持续{变量}秒，若目标是攻击型炮台则状态命中率提升至100%
void CFortSkill::twenthNinth_LightningStorm()
{
	if (m_pSkillBattle->getBattleType() == BattleType::BATTLE_NORMAL)
	{
		if (m_pFort->isEnemy())
		{
			damageWholePlayerForts();
			map<int, CFort*> mapPlayerForts = m_pSkillBattle->getPlayer()->getShip()->getFortMgr()->getPlayerFort();
			map<int, CFort*>::iterator iter = mapPlayerForts.begin();
			for (; iter != mapPlayerForts.end(); iter++)
			{
				if ((*iter).second->isFortLive())
				{
					if ((*iter).second->getFortType() == 0)
					{
						m_pSkillBattle->getPlayer()->getBuffMgr()->addBuff(Debuff::FORT_PARALYSIS, (*iter).second->getFortID(), 0, m_dContinueTime);
					}
					else
					{
						if (m_nAddBuff[(*iter).second->getFortIndex()] < (m_dScorePercent * 100))
						{
							m_pSkillBattle->getPlayer()->getBuffMgr()->addBuff(Debuff::FORT_PARALYSIS, (*iter).second->getFortID(), 0, m_dContinueTime);
						}
					}
				}
			}
		}
		else
		{
			damageWholeEnemyForts();
			map<int, CFort*> mapEnemyForts = m_pSkillBattle->getEnemy()->getShip()->getFortMgr()->getEnemyFort();
			map<int, CFort*>::iterator iter = mapEnemyForts.begin();
			for (; iter != mapEnemyForts.end(); iter++)
			{
				if ((*iter).second->isFortLive())
				{
					if ((*iter).second->getFortType() == 0)
					{
						m_pSkillBattle->getEnemy()->getBuffMgr()->addBuff(Debuff::FORT_PARALYSIS, (*iter).second->getFortID(), 0, m_dContinueTime);
					}
					else
					{
						if (m_nAddBuff[(*iter).second->getFortIndex()] < (m_dScorePercent * 100))
						{
							m_pSkillBattle->getEnemy()->getBuffMgr()->addBuff(Debuff::FORT_PARALYSIS, (*iter).second->getFortID(), 0, m_dContinueTime);
						}
					}
				}
			}
		}
	}
	else if (m_pSkillBattle->getBattleType() == BattleType::BATTLE_BOSS)
	{
		double damage = m_pFort->getFortAck() * m_dSkillDamagePercent;
		m_pSkillBattle->getBoss()->bossBeDamageByFortSkill(damage);
	}
}

//对全体目标造成{变量}%伤害，并有{变量}%概率对目标造成能量干扰【无法获得能量且释放技能】，持续{变量}秒，若目标是技能型炮台则状态命中率提升至100%
void CFortSkill::thirtieth_EndKnife()
{
	if (m_pSkillBattle->getBattleType() == BattleType::BATTLE_NORMAL)
	{
		if (m_pFort->isEnemy())
		{
			damageWholePlayerForts();
			map<int, CFort*> mapPlayerForts = m_pSkillBattle->getPlayer()->getShip()->getFortMgr()->getPlayerFort();
			map<int, CFort*>::iterator iter = mapPlayerForts.begin();
			for (; iter != mapPlayerForts.end(); iter++)
			{
				if ((*iter).second->isFortLive())
				{
					if ((*iter).second->getFortType() == 2)
					{
						m_pSkillBattle->getPlayer()->getBuffMgr()->addBuff(Debuff::FORT_ENERGY_DISTURB, (*iter).second->getFortID(), 0, m_dContinueTime);
					}
					else
					{
						if (m_nAddBuff[(*iter).second->getFortIndex()] < (m_dScorePercent * 100))
						{
							m_pSkillBattle->getPlayer()->getBuffMgr()->addBuff(Debuff::FORT_ENERGY_DISTURB, (*iter).second->getFortID(), 0, m_dContinueTime);
						}
					}
				}
			}
		}
		else
		{
			damageWholeEnemyForts();
			map<int, CFort*> mapEnemyForts = m_pSkillBattle->getEnemy()->getShip()->getFortMgr()->getEnemyFort();
			map<int, CFort*>::iterator iter = mapEnemyForts.begin();
			for (; iter != mapEnemyForts.end(); iter++)
			{
				if ((*iter).second->isFortLive())
				{
					if ((*iter).second->getFortType() == 2)
					{
						m_pSkillBattle->getEnemy()->getBuffMgr()->addBuff(Debuff::FORT_ENERGY_DISTURB, (*iter).second->getFortID(), 0, m_dContinueTime);
					}
					else
					{
						if (m_nAddBuff[(*iter).second->getFortIndex()] < (m_dScorePercent * 100))
						{
							m_pSkillBattle->getEnemy()->getBuffMgr()->addBuff(Debuff::FORT_ENERGY_DISTURB, (*iter).second->getFortID(), 0, m_dContinueTime);
						}
					}
				}
			}
		}
	}
	else if (m_pSkillBattle->getBattleType() == BattleType::BATTLE_BOSS)
	{
		double damage = m_pFort->getFortAck() * m_dSkillDamagePercent;
		m_pSkillBattle->getBoss()->bossBeDamageByFortSkill(damage);
	}
}
