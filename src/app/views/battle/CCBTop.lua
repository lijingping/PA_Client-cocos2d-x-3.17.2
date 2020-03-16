local BattleResourceMgr = require("app.utils.BattleResourceMgr");

local CCBTop = class("CCBTop", function ()
	return CCBLoader("ccbi/battle/CCBTop.ccbi")
end)
local pathPlayerHP = "res/resources/battle/pvp_hp_part5.png"
local pathEnemyHP = "res/resources/battle/pvp_hp_part7.png"

function CCBTop:InitData()
	print("CCBTop:InitData************************");
	self.m_battleType = BattleDataMgr:getBattleType();

	self.m_playerHpSprite = cc.Sprite:create(pathPlayerHP);
	self.m_playerHpSpriteSize = self.m_playerHpSprite:getContentSize();
	self.m_playerHpSprite:setSkewX(-23);
	self.m_playerHpSprite:setAnchorPoint(cc.p(1, 0.5));
	self.m_playerHpSprite:setPositionX(self.m_playerHpSpriteSize.width * 0.5);
	self.m_ccbNodeLeftHp:addChild(self.m_playerHpSprite);

	self.m_labelBattleTime = cc.LabelBMFont:create("03:00", "res/font/time_num.fnt");
    self.m_ccbNodeBattleTime:addChild(self.m_labelBattleTime);

	-- self.m_playerHP = cc.ProgressTimer:create(playerHpSprite);
 --    self.m_playerHP:setType(cc.PROGRESS_TIMER_TYPE_BAR);
 --    -- self.m_playerHP:setScale(0.8);
	-- self.m_playerHP:setPercentage(100);
	-- self.m_playerHP:setMidpoint(cc.p(1, 0));
 --    self.m_playerHP:setBarChangeRate(cc.p(1, 0));
 --    self.m_ccbNodeLeftHp:addChild(self.m_playerHP);
 	local playerLevel = BattleDataMgr:getCurPlayerInfo().level;
 	local playerName = BattleDataMgr:getCurPlayerInfo().name;
 	self.m_ccbLabelPlayerTopName:setString("Lv." .. playerLevel .. "  " .. playerName);
 	-- add 军衔图标
 	local famousPlayerLevel = BattleDataMgr:getCurPlayerInfo().rank;
 	local playerRankSprite = cc.Sprite:create(BattleResourceMgr:getBattleTopRankIconByLevel(famousPlayerLevel));
 	playerRankSprite:setScale(0.1);
 	self.m_ccbNodePlayerRankIcon:addChild(playerRankSprite);
    if self.m_battleType ~= 3 then
    	self.m_ccbNodeNormalBattle:setVisible(true);
	 	self.m_ccbNodeBossBattle:setVisible(false);

	 	self.m_enemyHpSprite = cc.Sprite:create(pathEnemyHP);
	 	self.m_enemyHpSpriteSize = self.m_enemyHpSprite:getContentSize();
	 	self.m_enemyHpSprite:setSkewX(22.5);
	 	self.m_enemyHpSprite:setAnchorPoint(cc.p(0, 0.5));
	 	self.m_enemyHpSprite:setPositionX(-self.m_enemyHpSpriteSize.width * 0.5);
	 	self.m_ccbNodeRightHp:addChild(self.m_enemyHpSprite);

	 	local enemyLevel = BattleDataMgr:getCurEnemyInfo().level;
	 	local enemyName = BattleDataMgr:getCurEnemyInfo().name;
	 	self.m_ccbLabelEnemyTopName:setString("Lv." .. enemyLevel .. "  " .. enemyName);
	 	-- add军衔图标
	 	local famousEnemyLevel = BattleDataMgr:getCurEnemyInfo().rank;
	 	local enemyRankSprite = cc.Sprite:create(BattleResourceMgr:getBattleTopRankIconByLevel(famousEnemyLevel));
	 	enemyRankSprite:setScale(0.1);
	 	self.m_ccbNodeEnemyRankIcon:addChild(enemyRankSprite);
	 --   	self.m_enemyHP = cc.ProgressTimer:create(cc.Sprite:create(pathEnemyHP));
	 --    self.m_enemyHP:setType(cc.PROGRESS_TIMER_TYPE_BAR);
	 --    -- self.m_enemyHP:setScale(0.8);
		-- self.m_enemyHP:setPercentage(100);
		-- self.m_enemyHP:setMidpoint(cc.p(0, 1));
	 --    self.m_enemyHP:setBarChangeRate(cc.p(1, 0));   
	 --    self.m_ccbNodeRightHp:addChild(self.m_enemyHP);

    elseif self.m_battleType == 3 then
    	self.m_ccbNodeNormalBattle:setVisible(false);
    	self.m_ccbNodeBossBattle:setVisible(true);

    	self.m_bossTotalDamage = 0;

    	self.m_ccbLabelAddDamage:setString(Str[11001] .. ": " .. BattleDataMgr:getAddAckPercent() * 100 .. "%");

    	self.m_labelBattleTime:setString("05:00");
    	-- local addDamageShow = cc.Sprite:create(BattleResourceMgr:getDomainBossPic("buff1"));
    	-- self.m_ccbNodeLeftHp:addChild(addDamageShow);
    	-- addDamageShow:setPosition(-20, -38);
    	-- self.m_labelAddDamage = cc.LabelTTF:create();
    	-- self.m_labelAddDamage:setFontSize(16);
    	-- self.m_labelAddDamage:setString("伤害加成" .. BattleDataMgr:getAddAckPercent() .. "%");
    	-- self.m_labelAddDamage:setPositionY(-38);
    	-- self.m_ccbNodeLeftHp:addChild(self.m_labelAddDamage);
    	-- local nameLv = cc.Sprite:create(BattleResourceMgr:getDomainBossPic("name1"));
    	-- self:addChild(nameLv);
    	-- nameLv:setPosition(250, -35);
    	-- local nameBoss = cc.Sprite:create(BattleResourceMgr:getDomainBossPic("name2"));
    	-- self:addChild(nameBoss);
    	-- nameBoss:setPosition(250, -35);
    end
    self.m_lastPlayerHp = 0;
    self.m_lastEnemyHp = 0;

    local fighterData = newBattle:getFighterData();
    self.m_ccbLabelLeftHp:setString(math.ceil(fighterData.playerCurHp));
    if self.m_battleType ~= 3 then
    	self.m_ccbLabelRightHp:setString(math.ceil(fighterData.enemyCurHp));
    end



    self.m_armatureTimer = nil;
    self.m_lastShowTime = -1;

    self.m_testForFightData = 0;
end

function CCBTop:setPlayerHP(percent)
	if self.m_playerHpSprite then
		-- self.m_playerHP:setPercentage(percent * 100);
		-- dump(self.m_playerHpSpriteSize);
		local spriteLength = self.m_playerHpSpriteSize.width * percent;
		self.m_playerHpSprite:setTextureRect(cc.rect(0, 0, spriteLength, self.m_playerHpSpriteSize.height));
	end
end

function CCBTop:setEnemyHP(percent)
	if self.m_enemyHpSprite then
		-- self.m_enemyHP:setPercentage(percent  * 100);
		local spriteLength = self.m_enemyHpSpriteSize.width * percent;
		self.m_enemyHpSprite:setTextureRect(cc.rect(0, 0, spriteLength, self.m_enemyHpSpriteSize.height));
	end
end

function CCBTop:setTime(passTime)
	local showTime = passTime;
	if showTime < 0 then
		showTime = 0;
	end
	local min = math.floor(showTime / 60);
	local second = math.floor(showTime % 60);
	self.m_labelBattleTime:setString(string.format("%02d:%02d", min, second));

	if self.m_battleType ~= 3 then
		if min == 0 and second <= 10 then
			-- print("battleType .. : ", self.m_battleType, "  second .  秒：", second);
			self:setHintTimer(second);
		end
	end
end

function CCBTop:refresh()
	-- dump(battle.query_ships());
	--战舰血条
	local FighterHp = newBattle.getFighterData()
	-- dump(FighterHp);

	local playerMaxHp = FighterHp.playerMaxHp

	local playerCurHp = FighterHp.playerCurHp
	if playerCurHp ~= playerMaxHp then
		self:setPlayerHP(playerCurHp / playerMaxHp);
		self.m_ccbLabelLeftHp:setString(math.ceil(playerCurHp) .. "/" .. math.ceil(playerMaxHp));
		self:setMyHp(math.ceil(playerCurHp));
	end	

	-- if BattleDataMgr.m_isNeedReverse == false then
	-- 	playerInfo = battle.query_ships()[1];
	-- 	enemyInfo = battle.query_ships()[2];
	-- else
	-- 	playerInfo = battle.query_ships()[2];	
	-- 	enemyInfo = battle.query_ships()[1];	
	-- end	
	if self.m_battleType ~= 3 then
		local enemyMaxHp = FighterHp.enemyMaxHp	
		local enemyCurHp = FighterHp.enemyCurHp	 

		if enemyCurHp ~= enemyMaxHp then
			self:setEnemyHP(enemyCurHp / enemyMaxHp);
			self.m_ccbLabelRightHp:setString(math.ceil(enemyCurHp) .. "/" .. math.ceil(enemyMaxHp));	
			self:setNotMyHp(math.ceil(enemyCurHp));
		end
	elseif self.m_battleType == 3 then
		local totalDamage = newBattle.getBossTotalDamage().totalDamage;
		if self.m_bossTotalDamage < totalDamage then
			self.m_ccbLabelCountDamage:setString(math.ceil(totalDamage));
			self.m_bossTotalDamage = totalDamage;
		end
	end

	--战斗时间
	-- dump(newBattle.time())
	-- "<var>" = {
	--     "time" = 179
	-- }
	self:setTime(newBattle.time().time);
end

function CCBTop:setHintTimer(time)
	if self.m_lastShowTime == time then
		return;
	end
	self.m_lastShowTime = time;
	print("show hint time:", time)
	if self.m_armatureTimer == nil then
		self.m_armatureTimer = BattleResourceMgr:getCountdownArmature();
		self.m_ccbNodeTimer:addChild(self.m_armatureTimer);
	end
	if time > 0 then
		self.m_armatureTimer:setVisible(true);
		self.m_armatureTimer:getAnimation():play("num"..time);
	else
		self.m_armatureTimer:setVisible(false);
	end
end

--玩家总血量
function CCBTop:setMyHp(playerHp)
	self.m_myHp = playerHp;
end

function CCBTop:getMyrHp()
	return self.m_myHp
end

--对方总血量
function CCBTop:setNotMyHp(enemyHp)
	self.m_notMyHp = enemyHp;
end

function CCBTop:getNotMyHp()
	return self.m_notMyHp
end

return CCBTop