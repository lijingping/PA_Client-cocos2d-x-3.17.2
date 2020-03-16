local ResourceMgr = require("app.utils.ResourceMgr");
local BattleResourceMgr = require("app.utils.BattleResourceMgr");

local RankUpView = class("RankUpView", cc.Node)

local rankIconPosX, rankIconPosY = 0, 150; 
local rankTextPosX, rankTextPosY = 0, 80;
local barPosX, barPosY = 0, -80;
local btnPosX, btnPosY = 0, -200;
local barRightLabelPosX = 250;

-- 进度条增长速度
local progressSpeed = 0.01;

function RankUpView:ctor(addFamous)
	
	local layerColor = cc.LayerColor:create(cc.c4b(0, 0, 0, 255 * 0.6), display.width, display.height);
	self:addChild(layerColor);
	layerColor:ignoreAnchorPointForPosition(false);
	layerColor:setAnchorPoint(cc.p(0.5, 0.5));
	layerColor:setPosition(cc.p(0, 0));

	local listener = cc.EventListenerTouchOneByOne:create();
	listener:setSwallowTouches(true);
	listener:registerScriptHandler(function(touch, event) return true; end, cc.Handler.EVENT_TOUCH_BEGAN);
	local eventDispatcher = self:getEventDispatcher();
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layerColor);

	self.m_nodeCenter = cc.Node:create();
	self:addChild(self.m_nodeCenter);

	if display.resolution >= 2 then
		self.m_nodeCenter:setScale(display.reduce);
	end

	local barBg = cc.Sprite:create(BattleResourceMgr:getBattleRankBarBg());
	barBg:setPosition(barPosX, barPosY); -- -3   -5
	self.m_nodeCenter:addChild(barBg);

	self.m_progressTimer = cc.ProgressTimer:create(cc.Sprite:create(BattleResourceMgr:getBattleRankBar()));
	self.m_progressTimer:setType(cc.PROGRESS_TIMER_TYPE_BAR);
	self.m_progressTimer:setPosition(barPosX, barPosY); -- -3   -5
	self.m_progressTimer:setPercentage(0);
	self.m_progressTimer:setBarChangeRate(cc.p(1, 0));
	self.m_progressTimer:setMidpoint(cc.p(0, 0));
	self.m_nodeCenter:addChild(self.m_progressTimer);

	-- local progressTo = cc.ProgressTo:create(5, 100);
	-- self.m_progressTimer:runAction(progressTo);

	local ensureBtn = ccui.Button:create(ResourceMgr:getGreenBtnNormal(), ResourceMgr:getGreenBtnHigh(),
		ResourceMgr:getGreenBtnHigh());
	self.m_nodeCenter:addChild(ensureBtn);
	ensureBtn:setPosition(btnPosX, btnPosY);
	ensureBtn:setTitleText(Str[1001]);
	ensureBtn:setTitleFontSize(20);
	ensureBtn:addClickEventListener(function()
		Audio:stopMusic();
		App:enterScene("MainScene");
		-- self:removeSelf();
	end);

	self.m_labelRank = cc.LabelTTF:create();
	self.m_labelRank:setFontSize(20);
	self.m_labelRank:setPosition(barPosX, barPosY); -- -3   -5
	self.m_nodeCenter:addChild(self.m_labelRank);
	self.m_labelRank:setString("0 / 0");

	-- self.m_rankExpTable = table.clone(require("app.constants.rank_exp"));
	-- local tableSize = 0;

	-- dump(self.m_rankExpTable);
	-- for k, v in pairs(self.m_rankExpTable) do
	-- 	print("i : " , k);
	-- 	if tonumber(k) == 3 then
	-- 		dump(self.m_rankExpTable[tostring(k + 1)]);
	-- 	end
	-- end


	-- for k, v in pairs(self.m_rankExpTable) do
	-- 	tableSize = tableSize + 1;
	-- end
	-- self.m_preRankID, self.m_curRankID = 0, 0;
	-- local nextRankExp = 0;

	-- 声望计算前后的数额及于哪个段位ID
	-- for k, v in pairs(self.m_rankExpTable) do
	-- 	if tonumber(k) < tableSize then
	-- 		if self.m_playerFamousPre >= self.m_rankExpTable[k].exp and 
	-- 			self.m_playerFamousPre < self.m_rankExpTable[tostring(k + 1)].exp then
	-- 			self.m_preRankID = v.id;
	-- 		end
	-- 		if self.m_playerFamous >= self.m_rankExpTable[k].exp and
	-- 			self.m_playerFamous < self.m_rankExpTable[tostring(k + 1)].exp then
	-- 			self.m_curRankID = v.id;
	-- 			nextRankExp = self.m_rankExpTable[tostring(k + 1)].exp;
	-- 		end
	-- 	else
	-- 		if self.m_playerFamousPre >= v.exp then
	-- 			self.m_preRankID = v;
	-- 		end
	-- 		if self.m_playerFamous >= v.exp then
	-- 			self.m_curRankID = v;
	-- 			nextRankExp = self.m_rankExpTable[tostring(k + 1)].exp;
	-- 		end
	-- 	end
	-- 	if self.m_preRankID ~= 0 and self.m_curRankID ~= 0 then
	-- 		break;
	-- 	end
	-- end

	-- 计算过后的声望值
	self.m_playerFamous = UserDataMgr:getPlayerFamous();
	-- 本次计算前的声望值
	self.m_playerFamousPre = self.m_playerFamous - addFamous;

	-- 获取军衔信息
	self.m_newRankInfo = UserDataMgr:getRankInfoByFamous(self.m_playerFamous);

	self.m_oldRankInfo = UserDataMgr:getRankInfoByFamous(self.m_playerFamousPre);

	local prePercent = self.m_oldRankInfo.curExp / self.m_oldRankInfo.levelUpExp;
	if prePercent > 1 then 
		prePercent = 1;
	end

	self.m_progressTimer:setPercentage(prePercent * 100);
	-- self.m_labelRank:setString(self.m_newRankInfo.curExp .. " / " .. self.m_newRankInfo.levelUpExp);

	local percent = self.m_newRankInfo.curExp / self.m_newRankInfo.levelUpExp;

	-- 战斗打赢
	if addFamous > 0 then
		-- 显示增加的声望值（坐落于进度条右边）
		local labelRightRank = cc.LabelBMFont:create("+" .. addFamous, "res/font/rank_up.fnt");
		self.m_nodeCenter:addChild(labelRightRank);
		labelRightRank:setPosition(barRightLabelPosX, barPosY - 8);

		-- 显示当前声望的图标
		self.m_spriteRank = cc.Sprite:create(ResourceMgr:getRankBigIconByLevel(self.m_oldRankInfo.level));
		self.m_nodeCenter:addChild(self.m_spriteRank);
		self.m_spriteRank:setPosition(rankIconPosX, rankIconPosY);

		self.m_spriteRankText = cc.Sprite:create(ResourceMgr:getRankTextByLevel(self.m_oldRankInfo.level));
		self.m_nodeCenter:addChild(self.m_spriteRankText);
		self.m_spriteRankText:setPosition(rankTextPosX, rankTextPosY);

		--if self.m_preRankID == self.m_curRankID then
		self:resultAnimLight();
		self:addFamousBarAnimLight();
		-- 声望增加前后是同一等级
		if self.m_oldRankInfo.level == self.m_newRankInfo.level then
			if self.m_newRankInfo.level < 12 then
				local time = addFamous * progressSpeed;
				local progressTo = cc.ProgressTo:create(time, percent * 100);
				self.m_progressTimer:runAction(progressTo);
				self.m_labelRank:setString(self.m_newRankInfo.curExp .. " / " .. self.m_newRankInfo.levelUpExp);
			else
				self.m_progressTimer:setPercentage(100);
				self.m_labelRank:setString(self.m_newRankInfo.curExp .. " / 99999999");
			end
		else
			-- 声望等级升级
			self.m_labelRank:setString(self.m_oldRankInfo.levelUpExp .. " / " .. self.m_oldRankInfo.levelUpExp);
			local time = (self.m_oldRankInfo.levelUpExp - self.m_oldRankInfo.curExp) * progressSpeed; 
			local progressTo = cc.ProgressTo:create(time, 100);

			local callfunc = cc.CallFunc:create(function()
					-- self:addProgressEffect(1);
					self:animRankUpdate();
				end)

			local sequence = cc.Sequence:create(progressTo, callfunc);
			self.m_progressTimer:runAction(sequence); 

		end
		self:rankLabelAction(addFamous);
	elseif addFamous <= 0 then
		local labelRightRank = cc.LabelBMFont:create(addFamous, "res/font/rank_down.fnt");
		self.m_nodeCenter:addChild(labelRightRank);
		labelRightRank:setPosition(barRightLabelPosX, barPosY - 8);

		self.m_spriteRank = cc.Sprite:create(ResourceMgr:getRankBigIconByLevel(self.m_oldRankInfo.level));
		self.m_nodeCenter:addChild(self.m_spriteRank);
		self.m_spriteRank:setPosition(rankIconPosX, rankIconPosY);

		self.m_spriteRankText = cc.Sprite:create(ResourceMgr:getRankTextByLevel(self.m_oldRankInfo.level));
		self.m_nodeCenter:addChild(self.m_spriteRankText);
		self.m_spriteRankText:setPosition(rankTextPosX, rankTextPosY);

		self:resultAnimLight();
		self:subFamousBarAnimLight();
		-- 声望扣除前后是同一等级
		if self.m_oldRankInfo.level == self.m_newRankInfo.level then
			-- 增加声望等级降级特效
			if self.m_newRankInfo.level < 12 then
				local time = math.abs(addFamous) * progressSpeed;
				local progressTo = cc.ProgressTo:create(time, percent * 100);
				self.m_progressTimer:runAction(progressTo);
				self.m_labelRank:setString(self.m_newRankInfo.curExp .. " / " .. self.m_newRankInfo.levelUpExp);
			else
				self.m_progressTimer:setPercentage(100);
				self.m_labelRank:setString(self.m_newRankInfo.curExp .. " / 99999999");
			end
		else
			-- 声望降级
			self.m_labelRank:setString("0 / 0");
			local time = self.m_oldRankInfo.curExp * progressSpeed; 
			local progressTo = cc.ProgressTo:create(time, 0);

			local callfunc = cc.CallFunc:create(function()
				-- 降级特效
				self:animRankLevelDown();
			end)

			local sequence = cc.Sequence:create(progressTo, callfunc);
			self.m_progressTimer:runAction(sequence); 
		end
	end
end

function RankUpView:resultAnimLight()
	local lightAnim = ResourceMgr:getRankResultAnimByName("rank_light");
	lightAnim:setPosition(rankIconPosX, rankIconPosY);
	self.m_nodeCenter:addChild(lightAnim);
	lightAnim:getAnimation():play("anim01");
	lightAnim:getAnimation():setMovementEventCallFunc(function(armatureBack, movementType, movementID)
		if movementType == ccs.MovementEventType.complete then
			lightAnim:removeSelf();
			lightAnim = nil;
		end
	end)
end

function RankUpView:addFamousBarAnimLight()
	local barLightAnim = ResourceMgr:getRankResultAnimByName("rank_up_light");
	barLightAnim:setPosition(cc.p(barPosX, barPosY));
	self.m_nodeCenter:addChild(barLightAnim);
	barLightAnim:getAnimation():play("anim01");
	barLightAnim:getAnimation():setMovementEventCallFunc(function(armatureBack, movementType, movementID)
		if movementType == ccs.MovementEventType.complete then
			barLightAnim:removeSelf();
			barLightAnim = nil;
		end
	end)
end

function RankUpView:subFamousBarAnimLight()
	local barLightAnim = ResourceMgr:getRankResultAnimByName("rank_down_light");
	barLightAnim:setPosition(cc.p(barPosX, barPosY));
	self.m_nodeCenter:addChild(barLightAnim);
	barLightAnim:getAnimation():play("anim01");
	barLightAnim:getAnimation():setMovementEventCallFunc(function(armatureBack, movementType, movementID)
		if movementType == ccs.MovementEventType.complete then
			barLightAnim:removeSelf();
			barLightAnim = nil;
		end
	end)
end

function RankUpView:animRankUpdate()
	local rankUpdateAnim = ResourceMgr:getRankResultAnimByName("rank_up");
	rankUpdateAnim:setPosition(rankIconPosX, rankIconPosY);
	self.m_nodeCenter:addChild(rankUpdateAnim);
	rankUpdateAnim:getAnimation():play("anim01");
	rankUpdateAnim:getAnimation():setMovementEventCallFunc(function(armatureBack, movementType, movementID)
		if movementType == ccs.MovementEventType.complete then
			rankUpdateAnim:removeSelf();
			rankUpdateAnim = nil;
		end
	end)
	rankUpdateAnim:getAnimation():setFrameEventCallFunc(function( bone, event, originFrameIndex, currentFrameIndex )
		if event == "change" then

			self.m_spriteRank:setTexture(ResourceMgr:getRankBigIconByLevel(self.m_newRankInfo.level));

			self.m_spriteRankText:setTexture(ResourceMgr:getRankTextByLevel(self.m_newRankInfo.level));
			self.m_progressTimer:setPercentage(0);

			local percent = self.m_newRankInfo.curExp / self.m_newRankInfo.levelUpExp;
			print("percent: " , percent);
			local time = self.m_newRankInfo.curExp * progressSpeed;
			local progressTo = cc.ProgressTo:create(time, percent * 100);
			local callfunc = cc.CallFunc:create(function ()
				-- self:addProgressEffect(percent);
			end)
			local sequence = cc.Sequence:create(progressTo, callfunc);
			self.m_progressTimer:runAction(sequence);
			self.m_labelRank:setString(self.m_newRankInfo.curExp .. " / " .. self.m_newRankInfo.levelUpExp);
		end
	end)
end

function RankUpView:animRankLevelDown()
	local rankDownAnim = ResourceMgr:getRankResultAnimByName("rank_down");
	rankDownAnim:setPosition(rankIconPosX, rankIconPosY);
	self.m_nodeCenter:addChild(rankDownAnim);
	rankDownAnim:getAnimation():play("anim01");
	rankDownAnim:getAnimation():setMovementEventCallFunc(function(armatureBack, movementType, movementID)
		if movementType == ccs.MovementEventType.complete then
			rankDownAnim:removeSelf();
			rankDownAnim = nil;
		end
	end)
	rankDownAnim:getAnimation():setFrameEventCallFunc(function(bone, event, originFrameIndex, currentFrameIndex)
		if event == "change" then
			self.m_spriteRank:setTexture(ResourceMgr:getRankBigIconByLevel(self.m_newRankInfo.level));
			self.m_spriteRankText:setTexture(ResourceMgr:getRankTextByLevel(self.m_newRankInfo.level));
			self.m_labelRank:setString(self.m_newRankInfo.levelUpExp .. " / " .. self.m_newRankInfo.levelUpExp);
			self.m_progressTimer:setPercentage(100);
			local percent = self.m_newRankInfo.curExp / self.m_newRankInfo.levelUpExp;
			local time = (1 - percent) * 100 * progressSpeed;
			local progressTo = cc.ProgressTo:create(time, percent * 100);
			local callfunc = cc.CallFunc:create(function ()
				-- self:addProgressEffect(percent);
			end)
			local sequence = cc.Sequence:create(progressTo, callfunc);
			self.m_progressTimer:runAction(sequence);
			self.m_labelRank:setString(self.m_newRankInfo.curExp .. " / " .. self.m_newRankInfo.levelUpExp);
		end
	end)
end

function RankUpView:rankLabelAction(rank)
	local labelActionRank = cc.LabelBMFont:create("+" .. rank, "res/font/rank_up.fnt");
	labelActionRank:setPosition(barPosX, barPosY);
	self.m_nodeCenter:addChild(labelActionRank);
	labelActionRank:setScale(0);

	local scaleBigTo = cc.ScaleTo:create(0.3, 1);
	local fadeIn = cc.FadeIn:create(0.3);
	local inSpawn = cc.Spawn:create(scaleBigTo, fadeIn);

	local moveUpBy = cc.MoveBy:create(0.5, cc.p(0, 30));
	local fadeTo = cc.FadeTo:create(0.5, 100);
	local scaleOutTo = cc.ScaleTo:create(0.5, 0.7);
	local outSpawn = cc.Spawn:create(moveUpBy, fadeTo, scaleOutTo);

	local callFunc = cc.CallFunc:create(function ()
		labelActionRank:removeSelf();
	end)
	local sequence = cc.Sequence:create(inSpawn, cc.DelayTime:create(0.1), outSpawn, callFunc);
	labelActionRank:runAction(sequence);
end

function RankUpView:addProgressEffect(percent)

	local armature = ResourceMgr:getAnimArmatureByNameOnOthers("ui_upgrade_bar01");
	self.m_nodeCenter:addChild(armature);
	local armatureSize = armature:getContentSize();
	armature:setPosition(barPosX - armatureSize.width / 2, barPosY);

	armature:getAnimation():play("anim01");
	armature:setAnchorPoint(cc.p(0, 0.5));
	-- if percent < 0.5 then
	-- 	armature:setScaleX(0.5);
	-- else
		armature:setScaleX(percent);
	-- end
end

return RankUpView;