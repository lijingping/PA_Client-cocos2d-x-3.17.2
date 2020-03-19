#include "KeyFrame.h"
#include "Battle.h"

CKeyFrame::CKeyFrame(CBattle *pBattle)
{
	m_pKeyFrameBattle = pBattle;
	m_nPlayerBulletNumber = 0;
	m_nEnemyBulletNumber = 0;
}

CKeyFrame::~CKeyFrame()
{
}
// 参数：player ：请求数据。为0， enemy：请求数据。为1.
const char* CKeyFrame::getCharBattleData(int nPlayerIndex)
{
	ostringstream oss;
	int prec = numeric_limits<int>::digits10;   // 解决科学计数法的问题
	oss.precision(prec);
	if (nPlayerIndex == 0)
	{
		// battle.cpp 的数据
		oss << m_sBattleInfo.dEnergyTime << "," << m_sBattleInfo.isEnergyLive << "," << m_sBattleInfo.nUpdateFrameCount << "," << m_sBattleInfo.nHitBulletCount << ","
			<< m_sBattleInfo.dBattleTime << "," << m_sBattleInfo.isBattleRuning << "," << m_sBattleInfo.isBattleStop << "," << m_sBattleInfo.nEnergyCreateCount << ","
			<< m_sBattleInfo.nRefreshCount << "+";
		oss << m_nPlayerBulletNumber << "," << m_nEnemyBulletNumber << "+";
		// player的数据
		oss << m_pKeyFrameBattle->getPlayer()->isPlayerUnmissile() << "," << m_pKeyFrameBattle->getPlayer()->isHaveNpc() << "," << m_pKeyFrameBattle->getPlayer()->getNpcTime() << ","
			<< m_pKeyFrameBattle->getPlayer()->getPlayerShipEnergy() << "," << m_pKeyFrameBattle->getPlayer()->getPlayerPreviousHp() << "," << m_pKeyFrameBattle->getPlayer()->getCountDamageHp() << "+";
		// enemy的数据
		oss << m_pKeyFrameBattle->getEnemy()->isEnemyUnmissile() << "," << m_pKeyFrameBattle->getEnemy()->isHaveNpc() << "," << m_pKeyFrameBattle->getEnemy()->getNpcTime() << ","
			<< m_pKeyFrameBattle->getEnemy()->getEnemyShipEnergy() << "," << m_pKeyFrameBattle->getEnemy()->getEnemyPreviousHp() << "," << m_pKeyFrameBattle->getEnemy()->getCountDamageHp() << "+";
		// 我方炮台数据 （0， 1， 2）
		map<int, CFort*> mapPlayerFort = m_pKeyFrameBattle->getPlayer()->getShip()->getFortMgr()->getPlayerFort();
		for (int i = 0; i < 3; i++)
		{
			oss << mapPlayerFort[i]->getFortHp() << "," << mapPlayerFort[i]->getFortEnergy() << "," << mapPlayerFort[i]->getInterval() << "," << mapPlayerFort[i]->getUnInjuryCoe() << ","
				<< mapPlayerFort[i]->getFortAck() << "," << mapPlayerFort[i]->isFortLive() << "," << mapPlayerFort[i]->getFireTime() << "," << mapPlayerFort[i]->isAddPassiveSkill() << ","
				<< mapPlayerFort[i]->isParalysisState() << "," << mapPlayerFort[i]->isBurningState() << "," << mapPlayerFort[i]->isAckUpState() << "," << mapPlayerFort[i]->isAckDownState() << ","
				<< mapPlayerFort[i]->isRepairingState() << "," << mapPlayerFort[i]->isUnrepaireState() << "," << mapPlayerFort[i]->isUnEnergyState() << "," << mapPlayerFort[i]->isShieldState() << ","
				<< mapPlayerFort[i]->isReliveState() << "," << mapPlayerFort[i]->isSkillingState() << "," << mapPlayerFort[i]->isBreakArmorState() << "," << mapPlayerFort[i]->isPassiveSkillStrongerState() << ","
				<< mapPlayerFort[i]->isHavePassiveSkillStronger() << "," << mapPlayerFort[i]->getBurningCountTime() << "," << mapPlayerFort[i]->getRepairingCountTime() << "," << mapPlayerFort[i]->getReliveCountDown() << ","
				<< mapPlayerFort[i]->getReliveHp() << "," << mapPlayerFort[i]->getAckDownValue() << "," << mapPlayerFort[i]->getAckUpValue() << "," << mapPlayerFort[i]->getAddPassiveEnergyTime() << ","
				<< mapPlayerFort[i]->getMomentAddHp() << "," << mapPlayerFort[i]->getSkillAddHp() << "," << mapPlayerFort[i]->getPropAddHp() << "," << mapPlayerFort[i]->getContinueAddHp() << ","
				<< mapPlayerFort[i]->getSelfAddEnergy() << "," << mapPlayerFort[i]->getEnergyAddEnergy() << "," << mapPlayerFort[i]->getPropAddEnergy() << "," << mapPlayerFort[i]->getAttackAddEnergy() << ","
				<< mapPlayerFort[i]->getBeDamageAddEnergy() << "," << mapPlayerFort[i]->getBulletDamage() << "," << mapPlayerFort[i]->getPropBulletDamage() << "," << mapPlayerFort[i]->getBuffBurnDamage() << ","
				<< mapPlayerFort[i]->getNPCDamage() << "," << mapPlayerFort[i]->getSkillDamage() << "," << mapPlayerFort[i]->getSkillTime() << "," << mapPlayerFort[i]->getShipSkillDamage() << ","
				<< mapPlayerFort[i]->getShipSkillAddHp() << "," << mapPlayerFort[i]->getShipSkillAddEnergy() << "+";
		}
		// 敌方炮台数据
		map<int, CFort*> mapEnemyFort = m_pKeyFrameBattle->getEnemy()->getShip()->getFortMgr()->getEnemyFort();
		for (int i = 0; i < 3; i++)
		{
			oss << mapEnemyFort[i]->getFortHp() << "," << mapEnemyFort[i]->getFortEnergy() << "," << mapEnemyFort[i]->getInterval() << "," << mapEnemyFort[i]->getUnInjuryCoe() << ","
				<< mapEnemyFort[i]->getFortAck() << "," << mapEnemyFort[i]->isFortLive() << "," << mapEnemyFort[i]->getFireTime() << "," << mapEnemyFort[i]->isAddPassiveSkill() << ","
				<< mapEnemyFort[i]->isParalysisState() << "," << mapEnemyFort[i]->isBurningState() << "," << mapEnemyFort[i]->isAckUpState() << "," << mapEnemyFort[i]->isAckDownState() << ","
				<< mapEnemyFort[i]->isRepairingState() << "," << mapEnemyFort[i]->isUnrepaireState() << "," << mapEnemyFort[i]->isUnEnergyState() << "," << mapEnemyFort[i]->isShieldState() << ","
				<< mapEnemyFort[i]->isReliveState() << "," << mapEnemyFort[i]->isSkillingState() << "," << mapEnemyFort[i]->isBreakArmorState() << "," << mapEnemyFort[i]->isPassiveSkillStrongerState() << ","
				<< mapEnemyFort[i]->isHavePassiveSkillStronger() << "," << mapEnemyFort[i]->getBurningCountTime() << "," << mapEnemyFort[i]->getRepairingCountTime() << "," << mapEnemyFort[i]->getReliveCountDown() << ","
				<< mapEnemyFort[i]->getReliveHp() << "," << mapEnemyFort[i]->getAckDownValue() << "," << mapEnemyFort[i]->getAckUpValue() << "," << mapEnemyFort[i]->getAddPassiveEnergyTime() << ","
				<< mapEnemyFort[i]->getMomentAddHp() << "," << mapEnemyFort[i]->getSkillAddHp() << "," << mapEnemyFort[i]->getPropAddHp() << "," << mapEnemyFort[i]->getContinueAddHp() << ","
				<< mapEnemyFort[i]->getSelfAddEnergy() << "," << mapEnemyFort[i]->getEnergyAddEnergy() << "," << mapEnemyFort[i]->getPropAddEnergy() << "," << mapEnemyFort[i]->getAttackAddEnergy() << ","
				<< mapEnemyFort[i]->getBeDamageAddEnergy() << "," << mapEnemyFort[i]->getBulletDamage() << "," << mapEnemyFort[i]->getPropBulletDamage() << "," << mapEnemyFort[i]->getBuffBurnDamage() << ","
				<< mapEnemyFort[i]->getNPCDamage() << "," << mapEnemyFort[i]->getSkillDamage() << "," << mapEnemyFort[i]->getSkillTime() << "," << mapEnemyFort[i]->getShipSkillDamage() << ","
				<< mapEnemyFort[i]->getShipSkillAddHp() << "," << mapEnemyFort[i]->getShipSkillAddEnergy() << "+";
		}

		// 碰撞子弹的数据
		oss << m_mapKHitBullet.size() << "-";
		if (m_mapKHitBullet.size() > 0)
		{
			for (int i = 0; i < m_mapKHitBullet.size(); i++)
			{
				oss << m_mapKHitBullet[i]->nBulletID << "," << m_mapKHitBullet[i]->nBulletIndex << "," << m_mapKHitBullet[i]->isEnemy << "," << m_mapKHitBullet[i]->x << ","
					<< m_mapKHitBullet[i]->y << "/";
			}
		}
		oss << "+";

		// 能量体事件
		oss << m_vecEnergyBodyEvent.size() << "-";
		if (m_vecEnergyBodyEvent.size() > 0)
		{
			for (int i = 0; i < m_vecEnergyBodyEvent.size(); i++)
			{
				oss << m_vecEnergyBodyEvent[i]->nEventType << "," << m_vecEnergyBodyEvent[i]->nBodyType << "," << m_vecEnergyBodyEvent[i]->dBodyHp << "," << m_vecEnergyBodyEvent[i]->dPlayerDamage << ","
					<< m_vecEnergyBodyEvent[i]->dEnemyDamage << "," << m_vecEnergyBodyEvent[i]->nBodyPosX << "," << m_vecEnergyBodyEvent[i]->nBodyPosY << "/";
			}
		}
		oss << "+";

		// 我方子弹
		oss << m_vecPlayerBulletData.size() << "-";
		if (m_vecPlayerBulletData.size() > 0)
		{
			for (int i = 0; i < m_vecPlayerBulletData.size(); i++)
			{
				oss << m_vecPlayerBulletData[i].isEnemy << "," << m_vecPlayerBulletData[i].nBulletID << "," << m_vecPlayerBulletData[i].nFortIndex << "," << m_vecPlayerBulletData[i].nBulletIndex << ","
					<< m_vecPlayerBulletData[i].dPosX << "," << m_vecPlayerBulletData[i].dPosY << "," << m_vecPlayerBulletData[i].dTime << "/";
			}
		}
		oss << "+";

		// 敌方子弹
		oss << m_vecEnemyBulletData.size() << "-";
		if (m_vecEnemyBulletData.size() > 0)
		{
			for (int i = 0; i < m_vecEnemyBulletData.size(); i++)
			{
				oss << m_vecEnemyBulletData[i].isEnemy << "," << m_vecEnemyBulletData[i].nBulletID << "," << m_vecEnemyBulletData[i].nFortIndex << "," << m_vecEnemyBulletData[i].nBulletIndex << ","
					<< m_vecEnemyBulletData[i].dPosX << "," << m_vecEnemyBulletData[i].dPosY << "," << m_vecEnemyBulletData[i].dTime << "/";
			}
		}
		oss << "+";

		// 能量体数据
		if (m_sBattleInfo.isEnergyLive)
		{
			oss << 1 << "-" << m_sEnergyBodyData.dPlayerDamage << "," << m_sEnergyBodyData.dEnemyDamage << "," << m_sEnergyBodyData.dBodyHp << "," << m_sEnergyBodyData.dJumpTime << ","
				<< m_sEnergyBodyData.dChangeTime << "," << m_sEnergyBodyData.nBodyType << "," << m_sEnergyBodyData.nPosX << "," << m_sEnergyBodyData.nPosY << ","
				<< m_sEnergyBodyData.isJump << "," << m_sEnergyBodyData.isChange << "," << m_sEnergyBodyData.dInitHp << "," << m_sEnergyBodyData.nChangeTimeCount << ","
				<< m_sEnergyBodyData.nJumpTimeCount << "+";
		}
		else
		{
			oss << 0 << "-" << "+";
		}

		// player 的buff
		map<int, CBuff*> mapPlayerBuff = m_pKeyFrameBattle->getPlayer()->getBuffMgr()->getPlayerBuffMap();
		oss << mapPlayerBuff.size() << "-";
		if (mapPlayerBuff.size() > 0)
		{
			map<int, CBuff*>::iterator playerIter = mapPlayerBuff.begin();
			for (; playerIter != mapPlayerBuff.end(); playerIter++)
			{
				oss << (*playerIter).second->getBuffTime() << "," << (*playerIter).second->getBuffID() << "," << (*playerIter).second->getFortID() << "," << (*playerIter).second->getBuffIndex() << ","
					<< (*playerIter).second->getBuffValue() << "/";
			}
		}
		oss << "+";

		// enemy 的buff
		map<int, CBuff*> mapEnemyBuff = m_pKeyFrameBattle->getEnemy()->getBuffMgr()->getEnemyBuffMap();
		oss << mapEnemyBuff.size() << "-";
		if (mapEnemyBuff.size() > 0)
		{
			map<int, CBuff*>::iterator enemyIter = mapEnemyBuff.begin();
			for (; enemyIter != mapEnemyBuff.end(); enemyIter++)
			{
				oss << (*enemyIter).second->getBuffTime() << "," << (*enemyIter).second->getBuffID() << "," << (*enemyIter).second->getFortID() << "," << (*enemyIter).second->getBuffIndex() << ","
					<< (*enemyIter).second->getBuffValue() << "/";
			}
		}
		oss << "+";

		// player 的buffEvent
		vector<sBuffEvent> vecPlayerBuffEvent = m_pKeyFrameBattle->getPlayer()->getBuffMgr()->getPlayerBuffEvent();
		oss << vecPlayerBuffEvent.size() << "-";
		if (vecPlayerBuffEvent.size() > 0)
		{
			for (int i = 0; i < vecPlayerBuffEvent.size(); i++)
			{
				oss << vecPlayerBuffEvent[i].nBuffFort << "," << vecPlayerBuffEvent[i].nBuffID << "/";
			}
		}
		oss << "+";

		// enemy 的buffEvent
		vector<sBuffEvent> vecEnemyBuffEvent = m_pKeyFrameBattle->getEnemy()->getBuffMgr()->getEnemyBuffEvent();
		oss << vecEnemyBuffEvent.size() << "-";
		if (vecEnemyBuffEvent.size() > 0)
		{
			for (int i = 0; i < vecEnemyBuffEvent.size(); i++)
			{
				oss << vecEnemyBuffEvent[i].nBuffFort << "," << vecEnemyBuffEvent[i].nBuffID << "/";
			}
		}
		oss << "+";

		// player 炮台事件。
		map<int, CFort*> mapPlayerForts = m_pKeyFrameBattle->getPlayer()->getShip()->getFortMgr()->getPlayerFort();
		for (int i = 0; i < 3; i++)
		{
			vector<int> fortEvent = mapPlayerForts[i]->getFortEventVec();
			oss << fortEvent.size() << "-";
			if (fortEvent.size() > 0)
			{
				for (int j = 0; j < fortEvent.size(); j++)
				{
					oss << fortEvent[j] << "/";
				}
			}
			oss << "#";
		}
		oss << "+";

		// enemy 炮台事件
		map<int, CFort*> mapEnemyForts = m_pKeyFrameBattle->getEnemy()->getShip()->getFortMgr()->getEnemyFort();
		for (int i = 0; i < 3; i++)
		{
			vector<int> fortEvent = mapEnemyForts[i]->getFortEventVec();
			oss << fortEvent.size() << "-";
			if (fortEvent.size() > 0)
			{
				for (int j = 0; j < fortEvent.size(); j++)
				{
					oss << fortEvent[j] << "/";
				}
			}
			oss << "#";
		}
		oss << "+";

		// 道具MGR 数据
		CPropsMgr *pPropsMgr = m_pKeyFrameBattle->getPropMgr();
		oss << pPropsMgr->getPropsCount() << "," << pPropsMgr->isPlayerNpcSecond() << "," << pPropsMgr->isEnemyNpcSecond() << "," << pPropsMgr->getPlayerPropNpc() << ","
			<< pPropsMgr->getEnemyPropNpc() << "," << pPropsMgr->getPlayerDamage() << "," << pPropsMgr->getEnemyDamage();
		oss << "+";

		// 道具Map队列
		map<int, CProps*> mapProps = m_pKeyFrameBattle->getPropMgr()->getPropsMap();
		oss << mapProps.size() << "-";
		if (mapProps.size() > 0)
		{
			map<int, CProps*>::iterator iter = mapProps.begin();
			for (; iter != mapProps.end(); iter++)
			{
				oss << (*iter).first << "," << (*iter).second->getPropID() << "," << (*iter).second->getPropBurstTime() << "," << (*iter).second->getUserNum() << ","
					<< (*iter).second->getTargetNum() << "," << (*iter).second->getTargetFortID() << "," << (*iter).second->getEnergyNpcDamage() << "/";
			}
		}
		oss << "+";

		// 道具事件容器Vec
		vector<sPropEvent> vecPropEvent = m_pKeyFrameBattle->getPropMgr()->getPropEventVec();
		oss << vecPropEvent.size() << "-";
		if (vecPropEvent.size() > 0)
		{
			for (int i = 0; i < vecPropEvent.size(); i++)
			{
				oss << vecPropEvent[i].nPropEventID << "," << vecPropEvent[i].nTarget << "/";
			}
		}
		oss << "+";
	}
	else if (nPlayerIndex == 1)
	{
		// battle.cpp 的数据
		oss << m_sBattleInfo.dEnergyTime << "," << m_sBattleInfo.isEnergyLive << "," << m_sBattleInfo.nUpdateFrameCount << "," << m_sBattleInfo.nHitBulletCount << ","
			<< m_sBattleInfo.dBattleTime << "," << m_sBattleInfo.isBattleRuning << "," << m_sBattleInfo.isBattleStop << "," << m_sBattleInfo.nEnergyCreateCount << ","
			<< m_sBattleInfo.nRefreshCount << "+";
		oss << m_nEnemyBulletNumber << "," << m_nPlayerBulletNumber << "+";
		// player的数据
		oss << m_pKeyFrameBattle->getEnemy()->isEnemyUnmissile() << "," << m_pKeyFrameBattle->getEnemy()->isHaveNpc() << "," << m_pKeyFrameBattle->getEnemy()->getNpcTime() << ","
			<< m_pKeyFrameBattle->getEnemy()->getEnemyShipEnergy() << "," << m_pKeyFrameBattle->getEnemy()->getEnemyPreviousHp() << "," << m_pKeyFrameBattle->getEnemy()->getCountDamageHp() << "+";
		// enemy的数据
		oss << m_pKeyFrameBattle->getPlayer()->isPlayerUnmissile() << "," << m_pKeyFrameBattle->getPlayer()->isHaveNpc() << "," << m_pKeyFrameBattle->getPlayer()->getNpcTime() << ","
			<< m_pKeyFrameBattle->getPlayer()->getPlayerShipEnergy() << "," << m_pKeyFrameBattle->getPlayer()->getPlayerPreviousHp() << "," << m_pKeyFrameBattle->getPlayer()->getCountDamageHp() << "+";

		// 我方炮台数据 （0， 1， 2）
		map<int, CFort*> mapEnemyFort = m_pKeyFrameBattle->getEnemy()->getShip()->getFortMgr()->getEnemyFort();
		for (int i = 0; i < 3; i++)
		{
			oss << mapEnemyFort[i]->getFortHp() << "," << mapEnemyFort[i]->getFortEnergy() << "," << mapEnemyFort[i]->getInterval() << "," << mapEnemyFort[i]->getUnInjuryCoe() << ","
				<< mapEnemyFort[i]->getFortAck() << "," << mapEnemyFort[i]->isFortLive() << "," << mapEnemyFort[i]->getFireTime() << "," << mapEnemyFort[i]->isAddPassiveSkill() << ","
				<< mapEnemyFort[i]->isParalysisState() << "," << mapEnemyFort[i]->isBurningState() << "," << mapEnemyFort[i]->isAckUpState() << "," << mapEnemyFort[i]->isAckDownState() << ","
				<< mapEnemyFort[i]->isRepairingState() << "," << mapEnemyFort[i]->isUnrepaireState() << "," << mapEnemyFort[i]->isUnEnergyState() << "," << mapEnemyFort[i]->isShieldState() << ","
				<< mapEnemyFort[i]->isReliveState() << "," << mapEnemyFort[i]->isSkillingState() << "," << mapEnemyFort[i]->isBreakArmorState() << "," << mapEnemyFort[i]->isPassiveSkillStrongerState() << ","
				<< mapEnemyFort[i]->isHavePassiveSkillStronger() << "," << mapEnemyFort[i]->getBurningCountTime() << "," << mapEnemyFort[i]->getRepairingCountTime() << "," << mapEnemyFort[i]->getReliveCountDown() << ","
				<< mapEnemyFort[i]->getReliveHp() << "," << mapEnemyFort[i]->getAckDownValue() << "," << mapEnemyFort[i]->getAckUpValue() << "," << mapEnemyFort[i]->getAddPassiveEnergyTime() << ","
				<< mapEnemyFort[i]->getMomentAddHp() << "," << mapEnemyFort[i]->getSkillAddHp() << "," << mapEnemyFort[i]->getPropAddHp() << "," << mapEnemyFort[i]->getContinueAddHp() << ","
				<< mapEnemyFort[i]->getSelfAddEnergy() << "," << mapEnemyFort[i]->getEnergyAddEnergy() << "," << mapEnemyFort[i]->getPropAddEnergy() << "," << mapEnemyFort[i]->getAttackAddEnergy() << ","
				<< mapEnemyFort[i]->getBeDamageAddEnergy() << "," << mapEnemyFort[i]->getBulletDamage() << "," << mapEnemyFort[i]->getPropBulletDamage() << "," << mapEnemyFort[i]->getBuffBurnDamage() << ","
				<< mapEnemyFort[i]->getNPCDamage() << "," << mapEnemyFort[i]->getSkillDamage() << "," << mapEnemyFort[i]->getSkillTime() << "," << mapEnemyFort[i]->getShipSkillDamage() << ","
				<< mapEnemyFort[i]->getShipSkillAddHp() << "," << mapEnemyFort[i]->getShipSkillAddEnergy() << "+";
		}
		//for (int i = 0; i < 3; i++)
		//{
			//oss << m_mapEnemyFortData[i].nFortIndex << "," << m_mapEnemyFortData[i].nFortID << "," << m_mapEnemyFortData[i].nBulletID << "," << m_mapEnemyFortData[i].nFortType << ","
			//	<< m_mapEnemyFortData[i].nFortLevel << "," << m_mapEnemyFortData[i].dStarDomainCoe << "," << m_mapEnemyFortData[i].dQualityCoe << "," << m_mapEnemyFortData[i].dAckGrowCoe << ","
			//	<< m_mapEnemyFortData[i].dHpGrowCoe << "," << m_mapEnemyFortData[i].dSpeedCoe << "," << m_mapEnemyFortData[i].dEnergyCoe << "," << m_mapEnemyFortData[i].dHp << ","
			//	<< m_mapEnemyFortData[i].dEnergy << "," << m_mapEnemyFortData[i].dInterval << "," << m_mapEnemyFortData[i].dUninjuryRate << "," << m_mapEnemyFortData[i].dAck << ","
			//	<< MYFORT_POS_X << "," << m_mapEnemyFortData[i].nPosY << "," << m_mapEnemyFortData[i].isLife << "," << m_mapEnemyFortData[i].dFireTime << ","
			//	<< m_mapEnemyFortData[i].dInitAck << "," << m_mapEnemyFortData[i].dInitHp << "," << m_mapEnemyFortData[i].dDefense << "," << m_mapEnemyFortData[i].dInitUninjuryRate << ","
			//	<< m_mapEnemyFortData[i].dInitDamage << "," << m_mapEnemyFortData[i].isAddPassiveSkill << "," << m_mapEnemyFortData[i].isParalysis << "," << m_mapEnemyFortData[i].isBurning << ","
			//	<< m_mapEnemyFortData[i].isAckUp << "," << m_mapEnemyFortData[i].isAckDown << "," << m_mapEnemyFortData[i].isRepairing << "," << m_mapEnemyFortData[i].isUnrepaire << ","
			//	<< m_mapEnemyFortData[i].isUnenergy << "," << m_mapEnemyFortData[i].isShield << "," << m_mapEnemyFortData[i].isRelive << "," << m_mapEnemyFortData[i].isSkillFire << ","
			//	<< m_mapEnemyFortData[i].isBreakArmor << "," << m_mapEnemyFortData[i].isFortPassiveSkillStronger << "," << m_mapEnemyFortData[i].isHavePassiveSkillStronger << "," << m_mapEnemyFortData[i].dBurningCountTime << ","
			//	<< m_mapEnemyFortData[i].dRepairingCountTime << "," << m_mapEnemyFortData[i].dReliveCountTime << "," << m_mapEnemyFortData[i].dReliveHp << "," << m_mapEnemyFortData[i].dAckDownValue << ","
			//	<< m_mapEnemyFortData[i].dAckUpValue << "," << m_mapEnemyFortData[i].dAddPassiveEnergyTime << "," << m_mapEnemyFortData[i].dMomentAddHp << "," << m_mapEnemyFortData[i].dSkillAddHp << ","
			//	<< m_mapEnemyFortData[i].dPropAddHp << "," << m_mapEnemyFortData[i].dContinueAddHp << "," << m_mapEnemyFortData[i].dSelfAddEnergy << "," << m_mapEnemyFortData[i].dEnergyAddEnergy << ","
			//	<< m_mapEnemyFortData[i].dPropAddEnergy << "," << m_mapEnemyFortData[i].dAttackAddEnergy << "," << m_mapEnemyFortData[i].dBeDamageAddEnergy << "," << m_mapEnemyFortData[i].dBulletDamage << ","
			//	<< m_mapEnemyFortData[i].dPropBulletDamage << "," << m_mapEnemyFortData[i].dBuffBurnDamage << "," << m_mapEnemyFortData[i].dNPC_Damage << "," << m_mapEnemyFortData[i].dSkillDamage << ","
			//	<< m_mapEnemyFortData[i].dSkillTime << "," << m_mapEnemyFortData[i].dShipSkillDamage << "," << m_mapEnemyFortData[i].dShipSkillAddHp << "," << m_mapEnemyFortData[i].dShipSkillAddEnergy << "+";
		//}
		// 敌方炮台数据
		map<int, CFort*> mapPlayerFort = m_pKeyFrameBattle->getPlayer()->getShip()->getFortMgr()->getPlayerFort();
		for (int i = 0; i < 3; i++)
		{
			oss << mapPlayerFort[i]->getFortHp() << "," << mapPlayerFort[i]->getFortEnergy() << "," << mapPlayerFort[i]->getInterval() << "," << mapPlayerFort[i]->getUnInjuryCoe() << ","
				<< mapPlayerFort[i]->getFortAck() << "," << mapPlayerFort[i]->isFortLive() << "," << mapPlayerFort[i]->getFireTime() << "," << mapPlayerFort[i]->isAddPassiveSkill() << ","
				<< mapPlayerFort[i]->isParalysisState() << "," << mapPlayerFort[i]->isBurningState() << "," << mapPlayerFort[i]->isAckUpState() << "," << mapPlayerFort[i]->isAckDownState() << ","
				<< mapPlayerFort[i]->isRepairingState() << "," << mapPlayerFort[i]->isUnrepaireState() << "," << mapPlayerFort[i]->isUnEnergyState() << "," << mapPlayerFort[i]->isShieldState() << ","
				<< mapPlayerFort[i]->isReliveState() << "," << mapPlayerFort[i]->isSkillingState() << "," << mapPlayerFort[i]->isBreakArmorState() << "," << mapPlayerFort[i]->isPassiveSkillStrongerState() << ","
				<< mapPlayerFort[i]->isHavePassiveSkillStronger() << "," << mapPlayerFort[i]->getBurningCountTime() << "," << mapPlayerFort[i]->getRepairingCountTime() << "," << mapPlayerFort[i]->getReliveCountDown() << ","
				<< mapPlayerFort[i]->getReliveHp() << "," << mapPlayerFort[i]->getAckDownValue() << "," << mapPlayerFort[i]->getAckUpValue() << "," << mapPlayerFort[i]->getAddPassiveEnergyTime() << ","
				<< mapPlayerFort[i]->getMomentAddHp() << "," << mapPlayerFort[i]->getSkillAddHp() << "," << mapPlayerFort[i]->getPropAddHp() << "," << mapPlayerFort[i]->getContinueAddHp() << ","
				<< mapPlayerFort[i]->getSelfAddEnergy() << "," << mapPlayerFort[i]->getEnergyAddEnergy() << "," << mapPlayerFort[i]->getPropAddEnergy() << "," << mapPlayerFort[i]->getAttackAddEnergy() << ","
				<< mapPlayerFort[i]->getBeDamageAddEnergy() << "," << mapPlayerFort[i]->getBulletDamage() << "," << mapPlayerFort[i]->getPropBulletDamage() << "," << mapPlayerFort[i]->getBuffBurnDamage() << ","
				<< mapPlayerFort[i]->getNPCDamage() << "," << mapPlayerFort[i]->getSkillDamage() << "," << mapPlayerFort[i]->getSkillTime() << "," << mapPlayerFort[i]->getShipSkillDamage() << ","
				<< mapPlayerFort[i]->getShipSkillAddHp() << "," << mapPlayerFort[i]->getShipSkillAddEnergy() << "+";
		}
		//for (int i = 0; i < 3; i++)
		//{
		//	oss << m_mapPlayerFortData[i].nFortIndex << "," << m_mapPlayerFortData[i].nFortID << "," << m_mapPlayerFortData[i].nBulletID << "," << m_mapPlayerFortData[i].nFortType << ","
		//		<< m_mapPlayerFortData[i].nFortLevel << "," << m_mapPlayerFortData[i].dStarDomainCoe << "," << m_mapPlayerFortData[i].dQualityCoe << "," << m_mapPlayerFortData[i].dAckGrowCoe << ","
		//		<< m_mapPlayerFortData[i].dHpGrowCoe << "," << m_mapPlayerFortData[i].dSpeedCoe << "," << m_mapPlayerFortData[i].dEnergyCoe << "," << m_mapPlayerFortData[i].dHp << ","
		//		<< m_mapPlayerFortData[i].dEnergy << "," << m_mapPlayerFortData[i].dInterval << "," << m_mapPlayerFortData[i].dUninjuryRate << "," << m_mapPlayerFortData[i].dAck << ","
		//		<< ENEMYFORT_POS_X << "," << m_mapPlayerFortData[i].nPosY << "," << m_mapPlayerFortData[i].isLife << "," << m_mapPlayerFortData[i].dFireTime << ","
		//		<< m_mapPlayerFortData[i].dInitAck << "," << m_mapPlayerFortData[i].dInitHp << "," << m_mapPlayerFortData[i].dDefense << "," << m_mapPlayerFortData[i].dInitUninjuryRate << ","
		//		<< m_mapPlayerFortData[i].dInitDamage << "," << m_mapPlayerFortData[i].isAddPassiveSkill << "," << m_mapPlayerFortData[i].isParalysis << "," << m_mapPlayerFortData[i].isBurning << ","
		//		<< m_mapPlayerFortData[i].isAckUp << "," << m_mapPlayerFortData[i].isAckDown << "," << m_mapPlayerFortData[i].isRepairing << "," << m_mapPlayerFortData[i].isUnrepaire << ","
		//		<< m_mapPlayerFortData[i].isUnenergy << "," << m_mapPlayerFortData[i].isShield << "," << m_mapPlayerFortData[i].isRelive << "," << m_mapPlayerFortData[i].isSkillFire << ","
		//		<< m_mapPlayerFortData[i].isBreakArmor << "," << m_mapPlayerFortData[i].isFortPassiveSkillStronger << "," << m_mapPlayerFortData[i].isHavePassiveSkillStronger << "," << m_mapPlayerFortData[i].dBurningCountTime << ","
		//		<< m_mapPlayerFortData[i].dRepairingCountTime << "," << m_mapPlayerFortData[i].dReliveCountTime << "," << m_mapPlayerFortData[i].dReliveHp << "," << m_mapPlayerFortData[i].dAckDownValue << ","
		//		<< m_mapPlayerFortData[i].dAckUpValue << "," << m_mapPlayerFortData[i].dAddPassiveEnergyTime << "," << m_mapPlayerFortData[i].dMomentAddHp << "," << m_mapPlayerFortData[i].dSkillAddHp << ","
		//		<< m_mapPlayerFortData[i].dPropAddHp << "," << m_mapPlayerFortData[i].dContinueAddHp << "," << m_mapPlayerFortData[i].dSelfAddEnergy << "," << m_mapPlayerFortData[i].dEnergyAddEnergy << ","
		//		<< m_mapPlayerFortData[i].dPropAddEnergy << "," << m_mapPlayerFortData[i].dAttackAddEnergy << "," << m_mapPlayerFortData[i].dBeDamageAddEnergy << "," << m_mapPlayerFortData[i].dBulletDamage << ","
		//		<< m_mapPlayerFortData[i].dPropBulletDamage << "," << m_mapPlayerFortData[i].dBuffBurnDamage << "," << m_mapPlayerFortData[i].dNPC_Damage << "," << m_mapPlayerFortData[i].dSkillDamage << ","
		//		<< m_mapPlayerFortData[i].dSkillTime << "," << m_mapPlayerFortData[i].dShipSkillDamage << "," << m_mapPlayerFortData[i].dShipSkillAddHp << "," << m_mapPlayerFortData[i].dShipSkillAddEnergy << "+";
		//}

		// 碰撞子弹的数据
		oss << m_mapKHitBullet.size() << "-";
		if (m_mapKHitBullet.size() > 0)
		{
			for (int i = 0; i < m_mapKHitBullet.size(); i++)
			{
				oss << m_mapKHitBullet[i]->nBulletID << "," << m_mapKHitBullet[i]->nBulletIndex << "," << !m_mapKHitBullet[i]->isEnemy << "," << m_mapKHitBullet[i]->x << ","
					<< m_mapKHitBullet[i]->y << "/";
			}
		}
		oss << "+";

		// 能量体事件
		oss << m_vecEnergyBodyEvent.size() << "-";
		if (m_vecEnergyBodyEvent.size() > 0)
		{
			for (int i = 0; i < m_vecEnergyBodyEvent.size(); i++)
			{
				oss << m_vecEnergyBodyEvent[i]->nEventType << "," << m_vecEnergyBodyEvent[i]->nBodyType << "," << m_vecEnergyBodyEvent[i]->dBodyHp << "," << m_vecEnergyBodyEvent[i]->dEnemyDamage << ","
					<< m_vecEnergyBodyEvent[i]->dPlayerDamage << "," << m_vecEnergyBodyEvent[i]->nBodyPosX << "," << m_vecEnergyBodyEvent[i]->nBodyPosY << "/";
			}
		}
		oss << "+";

		// 我方子弹
		oss << m_vecEnemyBulletData.size() << "-";
		if (m_vecEnemyBulletData.size() > 0)
		{
			for (int i = 0; i < m_vecEnemyBulletData.size(); i++)
			{
				oss << !m_vecEnemyBulletData[i].isEnemy << "," << m_vecEnemyBulletData[i].nBulletID << "," << m_vecEnemyBulletData[i].nFortIndex << "," << m_vecEnemyBulletData[i].nBulletIndex << ","
					<< SCREEN_SIZE_WIDTH - m_vecEnemyBulletData[i].dPosX << "," << m_vecEnemyBulletData[i].dPosY << "," << m_vecEnemyBulletData[i].dTime << "/";
			}
		}
		oss << "+";

		// 敌方子弹
		oss << m_vecPlayerBulletData.size() << "-";
		if (m_vecPlayerBulletData.size() > 0)
		{
			for (int i = 0; i < m_vecPlayerBulletData.size(); i++)
			{
				oss << !m_vecPlayerBulletData[i].isEnemy << "," << m_vecPlayerBulletData[i].nBulletID << "," << m_vecPlayerBulletData[i].nFortIndex << "," << m_vecPlayerBulletData[i].nBulletIndex << ","
					<< SCREEN_SIZE_WIDTH - m_vecPlayerBulletData[i].dPosX << "," << m_vecPlayerBulletData[i].dPosY << "," << m_vecPlayerBulletData[i].dTime << "/";
			}
		}
		oss << "+";

		// 能量体数据
		if (m_sBattleInfo.isEnergyLive)
		{
			oss << 1 << "-" << m_sEnergyBodyData.dEnemyDamage << "," << m_sEnergyBodyData.dPlayerDamage << "," << m_sEnergyBodyData.dBodyHp << "," << m_sEnergyBodyData.dJumpTime << ","
				<< m_sEnergyBodyData.dChangeTime << "," << m_sEnergyBodyData.nBodyType << "," << m_sEnergyBodyData.nPosX << "," << m_sEnergyBodyData.nPosY << ","
				<< m_sEnergyBodyData.isJump << "," << m_sEnergyBodyData.isChange << "," << m_sEnergyBodyData.dInitHp << "," << m_sEnergyBodyData.nChangeTimeCount << ","
				<< m_sEnergyBodyData.nJumpTimeCount << "+";
		}
		else
		{
			oss << 0 << "-" << "+";
		}

		// player 的buff
		map<int, CBuff*> mapEnemyBuff = m_pKeyFrameBattle->getEnemy()->getBuffMgr()->getEnemyBuffMap();
		oss << mapEnemyBuff.size() << "-";
		if (mapEnemyBuff.size() > 0)
		{
			map<int, CBuff*>::iterator enemyIter = mapEnemyBuff.begin();
			for (; enemyIter != mapEnemyBuff.end(); enemyIter++)
			{
				oss << (*enemyIter).second->getBuffTime() << "," << (*enemyIter).second->getBuffID() << "," << (*enemyIter).second->getFortID() << "," << (*enemyIter).second->getBuffIndex() << ","
					<< (*enemyIter).second->getBuffValue() << "/";
			}
		}
		oss << "+";

		// enemy 的buff
		map<int, CBuff*> mapPlayerBuff = m_pKeyFrameBattle->getPlayer()->getBuffMgr()->getPlayerBuffMap();
		oss << mapPlayerBuff.size() << "-";
		if (mapPlayerBuff.size() > 0)
		{
			map<int, CBuff*>::iterator playerIter = mapPlayerBuff.begin();
			for (; playerIter != mapPlayerBuff.end(); playerIter++)
			{
				oss << (*playerIter).second->getBuffTime() << "," << (*playerIter).second->getBuffID() << "," << (*playerIter).second->getFortID() << "," << (*playerIter).second->getBuffIndex() << ","
					<< (*playerIter).second->getBuffValue() << "/";
			}
		}
		oss << "+";

		// player 的buffEvent
		vector<sBuffEvent> vecEnemyBuffEvent = m_pKeyFrameBattle->getEnemy()->getBuffMgr()->getEnemyBuffEvent();
		oss << vecEnemyBuffEvent.size() << "-";
		if (vecEnemyBuffEvent.size() > 0)
		{
			for (int i = 0; i < vecEnemyBuffEvent.size(); i++)
			{
				oss << vecEnemyBuffEvent[i].nBuffFort << "," << vecEnemyBuffEvent[i].nBuffID << "/";
			}
		}
		oss << "+";

		// enemy 的buffEvent
		vector<sBuffEvent> vecPlayerBuffEvent = m_pKeyFrameBattle->getPlayer()->getBuffMgr()->getPlayerBuffEvent();
		oss << vecPlayerBuffEvent.size() << "-";
		if (vecPlayerBuffEvent.size() > 0)
		{
			for (int i = 0; i < vecPlayerBuffEvent.size(); i++)
			{
				oss << vecPlayerBuffEvent[i].nBuffFort << "," << vecPlayerBuffEvent[i].nBuffID << "/";
			}
		}
		oss << "+";

		// player 炮台事件。
		map<int, CFort*> mapEnemyForts = m_pKeyFrameBattle->getEnemy()->getShip()->getFortMgr()->getEnemyFort();
		for (int i = 0; i < 3; i++)
		{
			vector<int> fortEvent = mapEnemyForts[i]->getFortEventVec();
			oss << fortEvent.size() << "-";
			if (fortEvent.size() > 0)
			{
				for (int j = 0; j < fortEvent.size(); j++)
				{
					oss << fortEvent[j] << "/";
				}
			}
			oss << "#";
		}
		oss << "+";

		// enemy 炮台事件
		map<int, CFort*> mapPlayerForts = m_pKeyFrameBattle->getPlayer()->getShip()->getFortMgr()->getPlayerFort();
		for (int i = 0; i < 3; i++)
		{
			vector<int> fortEvent = mapPlayerForts[i]->getFortEventVec();
			oss << fortEvent.size() << "-";
			if (fortEvent.size() > 0)
			{
				for (int j = 0; j < fortEvent.size(); j++)
				{
					oss << fortEvent[j] << "/";
				}
			}
			oss << "#";
		}
		oss << "+";

		// 道具MGR 数据
		CPropsMgr *pPropsMgr = m_pKeyFrameBattle->getPropMgr();
		oss << pPropsMgr->getPropsCount() << "," << pPropsMgr->isEnemyNpcSecond() << "," << pPropsMgr->isPlayerNpcSecond() << "," << pPropsMgr->getEnemyPropNpc() << ","
			<< pPropsMgr->getPlayerPropNpc() << "," << pPropsMgr->getEnemyDamage() << "," << pPropsMgr->getPlayerDamage();
		oss << "+";

		// 道具Map队列
		map<int, CProps*> mapProps = m_pKeyFrameBattle->getPropMgr()->getPropsMap();
		oss << mapProps.size() << "-";
		if (mapProps.size() > 0)
		{
			map<int, CProps*>::iterator iter = mapProps.begin();
			for (; iter != mapProps.end(); iter++)
			{
				oss << (*iter).first << "," << (*iter).second->getPropID() << "," << (*iter).second->getPropBurstTime() << "," << (*iter).second->getTargetNum() << ","
					<< (*iter).second->getUserNum() << "," << (*iter).second->getTargetFortID() << "," << (*iter).second->getEnergyNpcDamage() << "/";
			}
		}
		oss << "+";

		// 道具事件容器Vec
		vector<sPropEvent> vecPropEvent = m_pKeyFrameBattle->getPropMgr()->getPropEventVec();
		oss << vecPropEvent.size() << "-";
		if (vecPropEvent.size() > 0)
		{
			for (int i = 0; i < vecPropEvent.size(); i++)
			{
				int nTargetNum = 0;
				if (vecPropEvent[i].nTarget >= 10)
				{
					nTargetNum = vecPropEvent[i].nTarget - 10;
				}
				else if (vecPropEvent[i].nTarget < 10)
				{
					nTargetNum = vecPropEvent[i].nTarget + 10;
				}
				oss << vecPropEvent[i].nPropEventID << "," << vecPropEvent[i].nTarget << "/";
			}
		}
		oss << "+";
	}
	m_strCharBattleFrame = oss.str();// ①.29.0116, 0, 60, 0, 0.988438, 1, 0

	return m_strCharBattleFrame.c_str();
}

const char* CKeyFrame::getCharOnlineSynchorData(int nPlayerIndex)
{
	ostringstream oss;
	int prec = numeric_limits<int>::digits10;
	oss.precision(prec);
	if (nPlayerIndex == 0)
	{
		// battle.cpp ???
		oss << m_sBattleInfo.dEnergyTime << "," << m_sBattleInfo.isEnergyLive << "," << m_sBattleInfo.nUpdateFrameCount << "," << m_sBattleInfo.nHitBulletCount << ","
			<< m_sBattleInfo.dBattleTime << "," << m_sBattleInfo.isBattleRuning << "," << m_sBattleInfo.isBattleStop << "," << m_sBattleInfo.nEnergyCreateCount << ","
			<< m_sBattleInfo.nRefreshCount << "+";
		oss << m_nPlayerBulletNumber << "," << m_nEnemyBulletNumber << "+";
		// player???
		oss << m_pKeyFrameBattle->getPlayer()->isPlayerUnmissile() << "," << m_pKeyFrameBattle->getPlayer()->isHaveNpc() << "," << m_pKeyFrameBattle->getPlayer()->getNpcTime() << ","
			<< m_pKeyFrameBattle->getPlayer()->getPlayerShipEnergy() << "," << m_pKeyFrameBattle->getPlayer()->getPlayerPreviousHp() << "," << m_pKeyFrameBattle->getPlayer()->getCountDamageHp() << "+";
		// enemy???
		oss << m_pKeyFrameBattle->getEnemy()->isEnemyUnmissile() << "," << m_pKeyFrameBattle->getEnemy()->isHaveNpc() << "," << m_pKeyFrameBattle->getEnemy()->getNpcTime() << ","
			<< m_pKeyFrameBattle->getEnemy()->getEnemyShipEnergy() << "," << m_pKeyFrameBattle->getEnemy()->getEnemyPreviousHp() << "," << m_pKeyFrameBattle->getEnemy()->getCountDamageHp() << "+";
		// 我方炮台数据 （0， 1， 2） ??????(0, 1, 2)
		map<int, CFort*> mapPlayerFort = m_pKeyFrameBattle->getPlayer()->getShip()->getFortMgr()->getPlayerFort();
		for (int i = 0; i < 3; i++)
		{
			oss << mapPlayerFort[i]->getFortHp() << "," << mapPlayerFort[i]->getFortEnergy() << "," << mapPlayerFort[i]->getInterval() << "," << mapPlayerFort[i]->getUnInjuryCoe() << ","
				<< mapPlayerFort[i]->getFortAck() << "," << mapPlayerFort[i]->isFortLive() << "," << mapPlayerFort[i]->getFireTime() << "," << mapPlayerFort[i]->isAddPassiveSkill() << ","
				<< mapPlayerFort[i]->isParalysisState() << "," << mapPlayerFort[i]->isBurningState() << "," << mapPlayerFort[i]->isAckUpState() << "," << mapPlayerFort[i]->isAckDownState() << ","
				<< mapPlayerFort[i]->isRepairingState() << "," << mapPlayerFort[i]->isUnrepaireState() << "," << mapPlayerFort[i]->isUnEnergyState() << "," << mapPlayerFort[i]->isShieldState() << ","
				<< mapPlayerFort[i]->isReliveState() << "," << mapPlayerFort[i]->isSkillingState() << "," << mapPlayerFort[i]->isBreakArmorState() << "," << mapPlayerFort[i]->isPassiveSkillStrongerState() << ","
				<< mapPlayerFort[i]->isHavePassiveSkillStronger() << "," << mapPlayerFort[i]->getBurningCountTime() << "," << mapPlayerFort[i]->getRepairingCountTime() << "," << mapPlayerFort[i]->getReliveCountDown() << ","
				<< mapPlayerFort[i]->getReliveHp() << "," << mapPlayerFort[i]->getAckDownValue() << "," << mapPlayerFort[i]->getAckUpValue() << "," << mapPlayerFort[i]->getAddPassiveEnergyTime() << ","
				<< mapPlayerFort[i]->getSkillTime() << "+";
		}
		// 敌方炮台数据   ??????
		map<int, CFort*> mapEnemyFort = m_pKeyFrameBattle->getEnemy()->getShip()->getFortMgr()->getEnemyFort();
		for (int i = 0; i < 3; i++)
		{
			oss << mapEnemyFort[i]->getFortHp() << "," << mapEnemyFort[i]->getFortEnergy() << "," << mapEnemyFort[i]->getInterval() << "," << mapEnemyFort[i]->getUnInjuryCoe() << ","
				<< mapEnemyFort[i]->getFortAck() << "," << mapEnemyFort[i]->isFortLive() << "," << mapEnemyFort[i]->getFireTime() << "," << mapEnemyFort[i]->isAddPassiveSkill() << ","
				<< mapEnemyFort[i]->isParalysisState() << "," << mapEnemyFort[i]->isBurningState() << "," << mapEnemyFort[i]->isAckUpState() << "," << mapEnemyFort[i]->isAckDownState() << ","
				<< mapEnemyFort[i]->isRepairingState() << "," << mapEnemyFort[i]->isUnrepaireState() << "," << mapEnemyFort[i]->isUnEnergyState() << "," << mapEnemyFort[i]->isShieldState() << ","
				<< mapEnemyFort[i]->isReliveState() << "," << mapEnemyFort[i]->isSkillingState() << "," << mapEnemyFort[i]->isBreakArmorState() << "," << mapEnemyFort[i]->isPassiveSkillStrongerState() << ","
				<< mapEnemyFort[i]->isHavePassiveSkillStronger() << "," << mapEnemyFort[i]->getBurningCountTime() << "," << mapEnemyFort[i]->getRepairingCountTime() << "," << mapEnemyFort[i]->getReliveCountDown() << ","
				<< mapEnemyFort[i]->getReliveHp() << "," << mapEnemyFort[i]->getAckDownValue() << "," << mapEnemyFort[i]->getAckUpValue() << "," << mapEnemyFort[i]->getAddPassiveEnergyTime() << ","
				<< mapEnemyFort[i]->getSkillTime() << "+";
		}

		// 能量体数据 ?????
		if (m_sBattleInfo.isEnergyLive)
		{
			oss << 1 << "-" << m_sEnergyBodyData.dPlayerDamage << "," << m_sEnergyBodyData.dEnemyDamage << "," << m_sEnergyBodyData.dBodyHp << "," << m_sEnergyBodyData.dJumpTime << ","
				<< m_sEnergyBodyData.dChangeTime << "," << m_sEnergyBodyData.nBodyType << "," << m_sEnergyBodyData.nPosX << "," << m_sEnergyBodyData.nPosY << ","
				<< m_sEnergyBodyData.isJump << "," << m_sEnergyBodyData.isChange << "," << m_sEnergyBodyData.dInitHp << "," << m_sEnergyBodyData.nChangeTimeCount << ","
				<< m_sEnergyBodyData.nJumpTimeCount << "+";
		}
		else
		{
			oss << 0 << "-" << "+";
		}

		// 道具MGR 数据 ??MGR ??
		CPropsMgr *pPropsMgr = m_pKeyFrameBattle->getPropMgr();
		oss << pPropsMgr->getPropsCount() << "," << pPropsMgr->isPlayerNpcSecond() << "," << pPropsMgr->isEnemyNpcSecond() << "," << pPropsMgr->getPlayerPropNpc() << ","
			<< pPropsMgr->getEnemyPropNpc() << "," << pPropsMgr->getPlayerDamage() << "," << pPropsMgr->getEnemyDamage();
		oss << "+";

	}
	else if (nPlayerIndex == 1)
	{
		// battle.cpp 的数据
		oss << m_sBattleInfo.dEnergyTime << "," << m_sBattleInfo.isEnergyLive << "," << m_sBattleInfo.nUpdateFrameCount << "," << m_sBattleInfo.nHitBulletCount << ","
			<< m_sBattleInfo.dBattleTime << "," << m_sBattleInfo.isBattleRuning << "," << m_sBattleInfo.isBattleStop << "," << m_sBattleInfo.nEnergyCreateCount << ","
			<< m_sBattleInfo.nRefreshCount << "+";
		oss << m_nEnemyBulletNumber << "," << m_nPlayerBulletNumber << "+";
		// player的数据
		oss << m_pKeyFrameBattle->getEnemy()->isEnemyUnmissile() << "," << m_pKeyFrameBattle->getEnemy()->isHaveNpc() << "," << m_pKeyFrameBattle->getEnemy()->getNpcTime() << ","
			<< m_pKeyFrameBattle->getEnemy()->getEnemyShipEnergy() << "," << m_pKeyFrameBattle->getEnemy()->getEnemyPreviousHp() << "," << m_pKeyFrameBattle->getEnemy()->getCountDamageHp() << "+";
		// enemy的数据
		oss << m_pKeyFrameBattle->getPlayer()->isPlayerUnmissile() << "," << m_pKeyFrameBattle->getPlayer()->isHaveNpc() << "," << m_pKeyFrameBattle->getPlayer()->getNpcTime() << ","
			<< m_pKeyFrameBattle->getPlayer()->getPlayerShipEnergy() << "," << m_pKeyFrameBattle->getPlayer()->getPlayerPreviousHp() << "," << m_pKeyFrameBattle->getPlayer()->getCountDamageHp() << "+";

		// 我方炮台数据 （0， 1， 2）
		map<int, CFort*> mapEnemyFort = m_pKeyFrameBattle->getEnemy()->getShip()->getFortMgr()->getEnemyFort();
		for (int i = 0; i < 3; i++)
		{
			oss << mapEnemyFort[i]->getFortHp() << "," << mapEnemyFort[i]->getFortEnergy() << "," << mapEnemyFort[i]->getInterval() << "," << mapEnemyFort[i]->getUnInjuryCoe() << ","
				<< mapEnemyFort[i]->getFortAck() << "," << mapEnemyFort[i]->isFortLive() << "," << mapEnemyFort[i]->getFireTime() << "," << mapEnemyFort[i]->isAddPassiveSkill() << ","
				<< mapEnemyFort[i]->isParalysisState() << "," << mapEnemyFort[i]->isBurningState() << "," << mapEnemyFort[i]->isAckUpState() << "," << mapEnemyFort[i]->isAckDownState() << ","
				<< mapEnemyFort[i]->isRepairingState() << "," << mapEnemyFort[i]->isUnrepaireState() << "," << mapEnemyFort[i]->isUnEnergyState() << "," << mapEnemyFort[i]->isShieldState() << ","
				<< mapEnemyFort[i]->isReliveState() << "," << mapEnemyFort[i]->isSkillingState() << "," << mapEnemyFort[i]->isBreakArmorState() << "," << mapEnemyFort[i]->isPassiveSkillStrongerState() << ","
				<< mapEnemyFort[i]->isHavePassiveSkillStronger() << "," << mapEnemyFort[i]->getBurningCountTime() << "," << mapEnemyFort[i]->getRepairingCountTime() << "," << mapEnemyFort[i]->getReliveCountDown() << ","
				<< mapEnemyFort[i]->getReliveHp() << "," << mapEnemyFort[i]->getAckDownValue() << "," << mapEnemyFort[i]->getAckUpValue() << "," << mapEnemyFort[i]->getAddPassiveEnergyTime() << ","
				<< mapEnemyFort[i]->getSkillTime() << "+";
		}
		// 敌方炮台数据
		map<int, CFort*> mapPlayerFort = m_pKeyFrameBattle->getPlayer()->getShip()->getFortMgr()->getPlayerFort();
		for (int i = 0; i < 3; i++)
		{
			oss << mapPlayerFort[i]->getFortHp() << "," << mapPlayerFort[i]->getFortEnergy() << "," << mapPlayerFort[i]->getInterval() << "," << mapPlayerFort[i]->getUnInjuryCoe() << ","
				<< mapPlayerFort[i]->getFortAck() << "," << mapPlayerFort[i]->isFortLive() << "," << mapPlayerFort[i]->getFireTime() << "," << mapPlayerFort[i]->isAddPassiveSkill() << ","
				<< mapPlayerFort[i]->isParalysisState() << "," << mapPlayerFort[i]->isBurningState() << "," << mapPlayerFort[i]->isAckUpState() << "," << mapPlayerFort[i]->isAckDownState() << ","
				<< mapPlayerFort[i]->isRepairingState() << "," << mapPlayerFort[i]->isUnrepaireState() << "," << mapPlayerFort[i]->isUnEnergyState() << "," << mapPlayerFort[i]->isShieldState() << ","
				<< mapPlayerFort[i]->isReliveState() << "," << mapPlayerFort[i]->isSkillingState() << "," << mapPlayerFort[i]->isBreakArmorState() << "," << mapPlayerFort[i]->isPassiveSkillStrongerState() << ","
				<< mapPlayerFort[i]->isHavePassiveSkillStronger() << "," << mapPlayerFort[i]->getBurningCountTime() << "," << mapPlayerFort[i]->getRepairingCountTime() << "," << mapPlayerFort[i]->getReliveCountDown() << ","
				<< mapPlayerFort[i]->getReliveHp() << "," << mapPlayerFort[i]->getAckDownValue() << "," << mapPlayerFort[i]->getAckUpValue() << "," << mapPlayerFort[i]->getAddPassiveEnergyTime() << ","
				<< mapPlayerFort[i]->getSkillTime() << "+";
		}

		// 能量体数据
		if (m_sBattleInfo.isEnergyLive)
		{
			oss << 1 << "-" << m_sEnergyBodyData.dEnemyDamage << "," << m_sEnergyBodyData.dPlayerDamage << "," << m_sEnergyBodyData.dBodyHp << "," << m_sEnergyBodyData.dJumpTime << ","
				<< m_sEnergyBodyData.dChangeTime << "," << m_sEnergyBodyData.nBodyType << "," << m_sEnergyBodyData.nPosX << "," << m_sEnergyBodyData.nPosY << ","
				<< m_sEnergyBodyData.isJump << "," << m_sEnergyBodyData.isChange << "," << m_sEnergyBodyData.dInitHp << "," << m_sEnergyBodyData.nChangeTimeCount << ","
				<< m_sEnergyBodyData.nJumpTimeCount << "+";
		}
		else
		{
			oss << 0 << "-" << "+";
		}

		// 道具MGR 数据
		CPropsMgr *pPropsMgr = m_pKeyFrameBattle->getPropMgr();
		oss << pPropsMgr->getPropsCount() << "," << pPropsMgr->isEnemyNpcSecond() << "," << pPropsMgr->isPlayerNpcSecond() << "," << pPropsMgr->getEnemyPropNpc() << ","
			<< pPropsMgr->getPlayerPropNpc() << "," << pPropsMgr->getEnemyDamage() << "," << pPropsMgr->getPlayerDamage();
		oss << "+";

	}

	m_strCharBattleFrame = oss.str();// ①.29.0116, 0, 60, 0, 0.988438, 1, 0

	return m_strCharBattleFrame.c_str();
}

const char * CKeyFrame::getCharBossBattleData()
{
	ostringstream oss;
	int prec = numeric_limits<int>::digits10;
	oss.precision(prec);
	// battle.cpp 的数据
	oss << m_pKeyFrameBattle->getUpdataFrameCount() << "," << m_pKeyFrameBattle->getCountHitBullet() << ","
		<< m_pKeyFrameBattle->getTime() << "," << m_pKeyFrameBattle->isBattleRuning() << "," << m_pKeyFrameBattle->isBattleStop() << "+";
	oss << m_pKeyFrameBattle->getPlayer()->getBulletMgr()->getPlayerBulletCount() << "+";
	// player的数据
	oss << m_pKeyFrameBattle->getPlayer()->isPlayerUnmissile() << "," << m_pKeyFrameBattle->getPlayer()->isHaveNpc() << "," << m_pKeyFrameBattle->getPlayer()->getNpcTime() << ","
		<< m_pKeyFrameBattle->getPlayer()->getPlayerShipEnergy() << "," << m_pKeyFrameBattle->getPlayer()->getPlayerPreviousHp() << "," << m_pKeyFrameBattle->getPlayer()->getCountDamageHp() << "+";

	// 我方炮台数据 （0， 1， 2）
	map<int, CFort*> mapPlayerFort = m_pKeyFrameBattle->getPlayer()->getShip()->getFortMgr()->getPlayerFort();
	for (int i = 0; i < 3; i++)
	{	
		oss << mapPlayerFort[i]->getFortHp() << "," << mapPlayerFort[i]->getFortEnergy() << "," << mapPlayerFort[i]->getInterval() << "," << mapPlayerFort[i]->getUnInjuryCoe() << ","
			<< mapPlayerFort[i]->getFortAck() << "," << mapPlayerFort[i]->isFortLive() << "," << mapPlayerFort[i]->getFireTime() << "," << mapPlayerFort[i]->isAddPassiveSkill() << ","
			<< mapPlayerFort[i]->isParalysisState() << "," << mapPlayerFort[i]->isBurningState() << "," << mapPlayerFort[i]->isAckUpState() << "," << mapPlayerFort[i]->isAckDownState() << ","
			<< mapPlayerFort[i]->isRepairingState() << "," << mapPlayerFort[i]->isUnrepaireState() << "," << mapPlayerFort[i]->isUnEnergyState() << "," << mapPlayerFort[i]->isShieldState() << ","
			<< mapPlayerFort[i]->isReliveState() << "," << mapPlayerFort[i]->isSkillingState() << "," << mapPlayerFort[i]->isBreakArmorState() << "," << mapPlayerFort[i]->isPassiveSkillStrongerState() << ","
			<< mapPlayerFort[i]->isHavePassiveSkillStronger() << "," << mapPlayerFort[i]->getBurningCountTime() << "," << mapPlayerFort[i]->getRepairingCountTime() << "," << mapPlayerFort[i]->getReliveCountDown() << ","
			<< mapPlayerFort[i]->getReliveHp() << "," << mapPlayerFort[i]->getAckDownValue() << "," << mapPlayerFort[i]->getAckUpValue() << "," << mapPlayerFort[i]->getAddPassiveEnergyTime() << ","
			<< mapPlayerFort[i]->getMomentAddHp() << "," << mapPlayerFort[i]->getSkillAddHp() << "," << mapPlayerFort[i]->getPropAddHp() << "," << mapPlayerFort[i]->getContinueAddHp() << ","
			<< mapPlayerFort[i]->getSelfAddEnergy() << "," << mapPlayerFort[i]->getEnergyAddEnergy() << "," << mapPlayerFort[i]->getPropAddEnergy() << "," << mapPlayerFort[i]->getAttackAddEnergy() << ","
			<< mapPlayerFort[i]->getBeDamageAddEnergy() << "," << mapPlayerFort[i]->getBulletDamage() << "," << mapPlayerFort[i]->getPropBulletDamage() << "," << mapPlayerFort[i]->getBuffBurnDamage() << ","
			<< mapPlayerFort[i]->getNPCDamage() << "," << mapPlayerFort[i]->getSkillDamage() << "," << mapPlayerFort[i]->getSkillTime() << "," << mapPlayerFort[i]->getShipSkillDamage() << ","
			<< mapPlayerFort[i]->getShipSkillAddHp() << "," << mapPlayerFort[i]->getShipSkillAddEnergy() << "+";
	}

	// 碰撞子弹的数据
	map<int, sHitBullet*> mapHitBullet = m_pKeyFrameBattle->getHitBulletMap();
	oss << mapHitBullet.size() << "-";
	map<int, sHitBullet*>::iterator iterHitBullet = mapHitBullet.begin();
	for (; iterHitBullet != mapHitBullet.end(); iterHitBullet++)
	{
		oss << (*iterHitBullet).second->nBulletID << "," << (*iterHitBullet).second->nBulletIndex << "," << (*iterHitBullet).second->isEnemy << "," << (*iterHitBullet).second->x << ","
			<< (*iterHitBullet).second->y << "/";
	}
	oss << "+";

	// 我方子弹
	map<int, CBullet*> mapPlayerBullet = m_pKeyFrameBattle->getPlayer()->getBulletMgr()->getPlayerBullet();
	oss << mapPlayerBullet.size() << "-";
	map<int, CBullet*>::iterator iterBullet = mapPlayerBullet.begin();
	for (; iterBullet != mapPlayerBullet.end(); iterBullet++)
	{
		oss << (*iterBullet).second->isEnemy() << "," << (*iterBullet).second->getBulletID() << "," << (*iterBullet).second->getFortIndex() << "," << (*iterBullet).second->getBulletIndex() << ","
			<< (*iterBullet).second->getBulletPosX() << "," << (*iterBullet).second->getBulletPosY() << "," << (*iterBullet).second->getCountTime() << "/";
	}
	oss << "+";

	// player 的buff
	map<int, CBuff*> mapPlayerBuff = m_pKeyFrameBattle->getPlayer()->getBuffMgr()->getPlayerBuffMap();
	oss << mapPlayerBuff.size() << "-";
	if (mapPlayerBuff.size() > 0)
	{
		map<int, CBuff*>::iterator playerIter = mapPlayerBuff.begin();
		for (; playerIter != mapPlayerBuff.end(); playerIter++)
		{
			oss << (*playerIter).second->getBuffTime() << "," << (*playerIter).second->getBuffID() << "," << (*playerIter).second->getFortID() << "," << (*playerIter).second->getBuffIndex() << ","
				<< (*playerIter).second->getBuffValue() << "/";
		}
	}
	oss << "+";


	// player 的buffEvent
	vector<sBuffEvent> vecPlayerBuffEvent = m_pKeyFrameBattle->getPlayer()->getBuffMgr()->getPlayerBuffEvent();
	oss << vecPlayerBuffEvent.size() << "-";
	if (vecPlayerBuffEvent.size() > 0)
	{
		for (int i = 0; i < vecPlayerBuffEvent.size(); i++)
		{
			oss << vecPlayerBuffEvent[i].nBuffFort << "," << vecPlayerBuffEvent[i].nBuffID << "/";
		}
	}
	oss << "+";


	// player 炮台事件。
	map<int, CFort*> mapPlayerForts = m_pKeyFrameBattle->getPlayer()->getShip()->getFortMgr()->getPlayerFort();
	for (int i = 0; i < 3; i++)
	{
		vector<int> fortEvent = mapPlayerForts[i]->getFortEventVec();
		oss << fortEvent.size() << "-";
		if (fortEvent.size() > 0)
		{
			for (int j = 0; j < fortEvent.size(); j++)
			{
				oss << fortEvent[j] << "/";
			}
		}
		oss << "#";
	}
	oss << "+";


	// 道具MGR 数据
	CPropsMgr *pPropsMgr = m_pKeyFrameBattle->getPropMgr();
	oss << pPropsMgr->getPropsCount() << "," << pPropsMgr->isPlayerNpcSecond() << "," << pPropsMgr->isEnemyNpcSecond() << "," << pPropsMgr->getPlayerPropNpc() << ","
		<< pPropsMgr->getEnemyPropNpc() << "," << pPropsMgr->getPlayerDamage() << "," << pPropsMgr->getEnemyDamage();
	oss << "+";

	// 道具Map队列
	map<int, CProps*> mapProps = m_pKeyFrameBattle->getPropMgr()->getPropsMap();
	oss << mapProps.size() << "-";
	if (mapProps.size() > 0)
	{
		map<int, CProps*>::iterator iter = mapProps.begin();
		for (; iter != mapProps.end(); iter++)
		{
			oss << (*iter).first << "," << (*iter).second->getPropID() << "," << (*iter).second->getPropBurstTime() << "," << (*iter).second->getUserNum() << ","
				<< (*iter).second->getTargetNum() << "," << (*iter).second->getTargetFortID() << "," << (*iter).second->getEnergyNpcDamage() << "/";
		}
	}
	oss << "+";

	// 道具事件容器Vec
	vector<sPropEvent> vecPropEvent = m_pKeyFrameBattle->getPropMgr()->getPropEventVec();
	oss << vecPropEvent.size() << "-";
	if (vecPropEvent.size() > 0)
	{
		for (int i = 0; i < vecPropEvent.size(); i++)
		{
			oss << vecPropEvent[i].nPropEventID << "," << vecPropEvent[i].nTarget << "/";
		}
	}
	oss << "+";

	// boss 数据
	CBoss *pBoss = m_pKeyFrameBattle->getBoss();
	oss << pBoss->getBossAck() << "," << pBoss->getBossStage() << "," << pBoss->getTotalDamage() << "," << pBoss->isInChange() << ","
		<< pBoss->isFire() << "," << pBoss->getBossTotalTime() << "," << pBoss->getFireTime() << "," << pBoss->getStageTime() << ","
		<< pBoss->getStageTiming() << "," << pBoss->getCountBullet() << "," << pBoss->getChangeTime() << "," << pBoss->getNpcTime() << ","
		<< pBoss->isNpcFlying() << "," << pBoss->getNpcFlyTime() << "," << pBoss->getCountNpc() << "," << pBoss->getFireInterval() << ","
		<< pBoss->isBossSkill() << "," << pBoss->getBossSkilling() << "," << pBoss->getSkillBurstTime() << "," << pBoss->getFireSkillCondition() << ","
		<< pBoss->getBulletBurstTime() << "," << pBoss->getBulletDamageNumber() << "," << pBoss->getFortSkillDamageNumber() << "," << pBoss->getNpcDamageNumber() << ","
		<< pBoss->getPropDamageNumber() << "," << pBoss->getShipSkillDamageNumber() << "," << pBoss->getNpcType() << "+";

	// boss 子弹数据
	vector<CBullet*> vecBossBullet = m_pKeyFrameBattle->getBoss()->getBossBullet();
	oss << vecBossBullet.size() << "-";
	for (int i = 0; i < vecBossBullet.size(); i++)
	{
		oss << vecBossBullet[i]->getBulletIndex() << "," << vecBossBullet[i]->getBossBulletTime() << "/";
	}
	oss << "+";

	// boss 事件
	vector<int> vecBossEvent = m_pKeyFrameBattle->getBoss()->getBossEvent();
	oss << vecBossEvent.size() << "-";
	for (int i = 0; i < vecBossEvent.size(); i++)
	{
		oss << vecBossEvent[i] << "/";
	}
	oss << "+";

	m_strCharBattleFrame = oss.str();
	return m_strCharBattleFrame.c_str();
}

const char * CKeyFrame::getCharOnlineBossBattleData()
{
	ostringstream oss;
	int prec = numeric_limits<int>::digits10;
	oss.precision(prec);
	// battle.cpp ???
	oss << m_pKeyFrameBattle->getUpdataFrameCount() << "," << m_pKeyFrameBattle->getCountHitBullet() << ","
		<< m_pKeyFrameBattle->getTime() << "," << m_pKeyFrameBattle->isBattleRuning() << "," << m_pKeyFrameBattle->isBattleStop() << "+";

	oss << m_pKeyFrameBattle->getPlayer()->getBulletMgr()->getPlayerBulletCount() << "+";
	// player???
	oss << m_pKeyFrameBattle->getPlayer()->isPlayerUnmissile() << "," << m_pKeyFrameBattle->getPlayer()->isHaveNpc() << "," << m_pKeyFrameBattle->getPlayer()->getNpcTime() << ","
		<< m_pKeyFrameBattle->getPlayer()->getPlayerShipEnergy() << "," << m_pKeyFrameBattle->getPlayer()->getPlayerPreviousHp() << "," << m_pKeyFrameBattle->getPlayer()->getCountDamageHp() << "+";

	// 我方炮台数据 （0， 1， 2） ??????(0, 1, 2)
	map<int, CFort*> mapPlayerFort = m_pKeyFrameBattle->getPlayer()->getShip()->getFortMgr()->getPlayerFort();

	for (int i = 0; i < 3; i++)
	{
		oss << mapPlayerFort[i]->getFortHp() << ","	<< mapPlayerFort[i]->getFortEnergy() << "," << mapPlayerFort[i]->getInterval() << "," << mapPlayerFort[i]->getUnInjuryCoe() << "," 
			<< mapPlayerFort[i]->getFortAck() << "," << mapPlayerFort[i]->isFortLive() << "," << mapPlayerFort[i]->getFireTime() << ","	<< mapPlayerFort[i]->isAddPassiveSkill() << "," 
			<< mapPlayerFort[i]->isParalysisState() << "," << mapPlayerFort[i]->isBurningState() << ","	<< mapPlayerFort[i]->isAckUpState() << "," << mapPlayerFort[i]->isAckDownState() << "," 
			<< mapPlayerFort[i]->isRepairingState() << "," << mapPlayerFort[i]->isUnrepaireState() << "," << mapPlayerFort[i]->isUnEnergyState() << "," << mapPlayerFort[i]->isShieldState() << "," 
			<< mapPlayerFort[i]->isReliveState() << "," << mapPlayerFort[i]->isSkillingState() << "," << mapPlayerFort[i]->isBreakArmorState() << "," << mapPlayerFort[i]->isPassiveSkillStrongerState() << "," 
			<< mapPlayerFort[i]->isHavePassiveSkillStronger() << "," << mapPlayerFort[i]->getBurningCountTime() << "," << mapPlayerFort[i]->getRepairingCountTime() << "," << mapPlayerFort[i]->getReliveCountDown() << "," 
			<< mapPlayerFort[i]->getReliveHp() << "," << mapPlayerFort[i]->getAckDownValue() << ","	<< mapPlayerFort[i]->getAckUpValue() << "," << mapPlayerFort[i]->getAddPassiveEnergyTime() << "," 
			<< mapPlayerFort[i]->getSkillTime() << "+";
	}

	// 道具MGR 数据 ??MGR ??
	CPropsMgr *pPropsMgr = m_pKeyFrameBattle->getPropMgr();
	oss << pPropsMgr->getPropsCount() << "," << pPropsMgr->isPlayerNpcSecond() << "," << pPropsMgr->isEnemyNpcSecond() << "," << pPropsMgr->getPlayerPropNpc() << ","
		<< pPropsMgr->getEnemyPropNpc() << "," << pPropsMgr->getPlayerDamage() << "," << pPropsMgr->getEnemyDamage();
	oss << "+";

	// boss 数据
	CBoss *pBoss = m_pKeyFrameBattle->getBoss();
	oss << pBoss->getBossAck() << "," << pBoss->getBossStage() << "," << pBoss->getTotalDamage() << "," << pBoss->isInChange() << ","
		<< pBoss->isFire() << "," << pBoss->getBossTotalTime() << "," << pBoss->getFireTime() << "," << pBoss->getStageTime() << ","
		<< pBoss->getStageTiming() << "," << pBoss->getCountBullet() << "," << pBoss->getChangeTime() << "," << pBoss->getNpcTime() << ","
		<< pBoss->isNpcFlying() << "," << pBoss->getNpcFlyTime() << "," << pBoss->getCountNpc() << "," << pBoss->getFireInterval() << ","
		<< pBoss->isBossSkill() << "," << pBoss->getBossSkilling() << "," << pBoss->getSkillBurstTime() << "," << pBoss->getFireSkillCondition() << ","
		<< pBoss->getBulletBurstTime() << "+";

	m_strCharBattleFrame = oss.str();
	return m_strCharBattleFrame.c_str();
}

string CKeyFrame::getStringBattleData()
{
	ostringstream oss;
	int prec = numeric_limits<int>::digits10;
	oss.precision(prec);
	// battle.cpp 的数据
	oss << m_pKeyFrameBattle->getUpdataFrameCount() << "," << m_pKeyFrameBattle->getCountHitBullet() << ","
		<< m_pKeyFrameBattle->getTime() << "," << m_pKeyFrameBattle->isBattleRuning() << "," << m_pKeyFrameBattle->isBattleStop() << "+";
	// 我方炮台数据 （0， 1， 2）
	for (int i = 0; i < 3; i++)
	{
		oss << m_mapPlayerFortData[i].nFortIndex << "," << m_mapPlayerFortData[i].nFortID << "," << m_mapPlayerFortData[i].nBulletID << "," << m_mapPlayerFortData[i].nFortType << ","
			<< m_mapPlayerFortData[i].nFortLevel << "," << m_mapPlayerFortData[i].dStarDomainCoe << "," << m_mapPlayerFortData[i].dQualityCoe << "," << m_mapPlayerFortData[i].dAckGrowCoe << ","
			<< m_mapPlayerFortData[i].dHpGrowCoe << "," << m_mapPlayerFortData[i].dSpeedCoe << "," << m_mapPlayerFortData[i].dEnergyCoe << "," << m_mapPlayerFortData[i].dHp << ","
			<< m_mapPlayerFortData[i].dEnergy << "," << m_mapPlayerFortData[i].dInterval << "," << m_mapPlayerFortData[i].dUninjuryRate << "," << m_mapPlayerFortData[i].dAck << ","
			<< m_mapPlayerFortData[i].nPosX << "," << m_mapPlayerFortData[i].nPosY << "," << m_mapPlayerFortData[i].isLife << "," << m_mapPlayerFortData[i].dFireTime << ","
			<< m_mapPlayerFortData[i].dInitAck << "," << m_mapPlayerFortData[i].dInitHp << "," << m_mapPlayerFortData[i].dDefense << "," << m_mapPlayerFortData[i].dInitUninjuryRate << ","
			<< m_mapPlayerFortData[i].dInitDamage << "," << m_mapPlayerFortData[i].isAddPassiveSkill << "," << m_mapPlayerFortData[i].isParalysis << "," << m_mapPlayerFortData[i].isBurning << ","
			<< m_mapPlayerFortData[i].isAckUp << "+";
	}
	// 敌方炮台数据
	for (int i = 0; i < 3; i++)
	{
		oss << m_mapEnemyFortData[i].nFortIndex << "," << m_mapEnemyFortData[i].nFortID << "," << m_mapEnemyFortData[i].nBulletID << "," << m_mapEnemyFortData[i].nFortType << ","
			<< m_mapEnemyFortData[i].nFortLevel << "," << m_mapEnemyFortData[i].dStarDomainCoe << "," << m_mapEnemyFortData[i].dQualityCoe << "," << m_mapEnemyFortData[i].dAckGrowCoe << ","
			<< m_mapEnemyFortData[i].dHpGrowCoe << "," << m_mapEnemyFortData[i].dSpeedCoe << "," << m_mapEnemyFortData[i].dEnergyCoe << "," << m_mapEnemyFortData[i].dHp << ","
			<< m_mapEnemyFortData[i].dEnergy << "," << m_mapEnemyFortData[i].dInterval << "," << m_mapEnemyFortData[i].dUninjuryRate << "," << m_mapEnemyFortData[i].dAck << ","
			<< m_mapEnemyFortData[i].nPosX << "," << m_mapEnemyFortData[i].nPosY << "," << m_mapEnemyFortData[i].isLife << "," << m_mapEnemyFortData[i].dFireTime << ","
			<< m_mapEnemyFortData[i].dInitAck << "," << m_mapEnemyFortData[i].dInitHp << "," << m_mapEnemyFortData[i].dDefense << "," << m_mapEnemyFortData[i].dInitUninjuryRate << ","
			<< m_mapEnemyFortData[i].dInitDamage << "," << m_mapEnemyFortData[i].isAddPassiveSkill << "," << m_mapEnemyFortData[i].isParalysis << "," << m_mapEnemyFortData[i].isBurning << ","
			<< m_mapEnemyFortData[i].isAckUp << "+";
	}

	return oss.str();// ①.29.0116, 0, 60, 0, 0.988438, 1, 0
}

void CKeyFrame::cleanContainerData()
{
	m_mapKHitBullet.clear();
	m_vecEnergyBodyEvent.clear();
	m_mapPlayerFortData.clear();
	m_mapEnemyFortData.clear();
	m_vecPlayerBulletData.clear();
	m_vecEnemyBulletData.clear();
}

void CKeyFrame::setBattleFrameData(sBattleInfo info)
{
	m_sBattleInfo = info;
}

void CKeyFrame::setBulletNumber(int nPlayer, int nEnemy)
{
	m_nPlayerBulletNumber = nPlayer;
	m_nEnemyBulletNumber = nEnemy;
}

void CKeyFrame::setHitBulletData(map<int, sHitBullet*> map)
{
	m_mapKHitBullet = map;
}

void CKeyFrame::setEnergyBodyEventData(vector<sEnergyBodyEvent*> event)
{
	m_vecEnergyBodyEvent = event;
}

void CKeyFrame::setPlayerFortData(sFortData pData, int nIndex)
{
	m_mapPlayerFortData.insert(map<int, sFortData>::value_type(nIndex, pData));
}

void CKeyFrame::setEnemyFortData(sFortData pData, int nIndex)
{
	m_mapEnemyFortData.insert(map<int, sFortData>::value_type(nIndex, pData));
}

void CKeyFrame::setPlayerBulletData(SBulletData data)
{
	m_vecPlayerBulletData.insert(m_vecPlayerBulletData.end(), data);
}

void CKeyFrame::setEnemyBulletData(SBulletData data)
{
	m_vecEnemyBulletData.insert(m_vecEnemyBulletData.end(), data);
}

void CKeyFrame::setEnergyBodyData(SEnergyBodyData data)
{
	m_sEnergyBodyData = data;
}
