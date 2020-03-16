local ResourceMgr = require("app.utils.ResourceMgr");
local DescripProp = require("app.views.common.DescripProp");
local CCBRewardProp = import(".CCBRewardProp");
--local CCBPopWindow = require("app.views.commonCCB.CCBPopWindow");
local CCBMessageBox = require("app.views.commonCCB.CCBMessageBox")

local CCBDomainBattleView = class("CCBDomainBattleView", function()
	return CCBLoader("ccbi/domainBattleView/CCBDomainBattleView.ccbi");
end)

local damageAward = require("app.constants.damage_award");
local Tips = require("app.views.common.Tips");

local damagePer = 10;

-- 说明  m_ccbNodeReward + i 系列 节点 
--		tag = 1    是精灵添加的节点（itemIcon, itemBg, itemFrame, 及已领取 图（tag为10 + i） ）
-- 		tag = 2	   显示奖励数目的圆圈底
-- 		tag = 3    奖励数目label
-- 		tag = 4    领取奖励按钮

function CCBDomainBattleView:ctor()
	if display.resolution  >= 2 then
		-- self.m_ccbSpriteBg:setScale(display.reduce);
		self.m_ccbSpriteBg:setScaleX(-display.reduce);
		self.m_ccbSpriteBg:setScaleY(display.reduce);
		self.m_ccbNodeLeftPart:setScale(display.reduce);
		self.m_ccbNodeRightPart:setScale(display.reduce);
	end
	self:enableNodeEvents();
	self:createListener();

	self.m_rewardBtn = {};
	self.m_damageAwardData = table.clone(damageAward);
	table.sort(self.m_damageAwardData, function(a, b)
		return a.id < b.id;
	end);

	self.m_descProp = nil;

	self.m_upDamageDiamond = 0;
	-- dump(self.m_damageAwardData);
	self.m_spriteSize = self.m_ccbSpriteDamageNumBar:getContentSize();
	self.m_ccbSpriteDamageNumBar:setTextureRect(cc.rect(0, 0, 0, 0));
end

function CCBDomainBattleView:onEnter()

end

function CCBDomainBattleView:onExit()
	if self.m_schedulerRemainTime then
		self:getScheduler():unscheduleScriptEntry(self.m_schedulerRemainTime);
		self.m_schedulerRemainTime = nil;
	end
	if self.m_schedulerTouch then
		self:getScheduler():unscheduleScriptEntry(self.m_schedulerTouch);
		self.m_schedulerTouch = nil;
	end
end

function CCBDomainBattleView:createListener()
	local listener = cc.EventListenerTouchOneByOne:create();
	listener:setSwallowTouches(false);
	listener:registerScriptHandler(function(touch, event) return self:onTouchBegan(touch, event) end, cc.Handler.EVENT_TOUCH_BEGAN);
	listener:registerScriptHandler(function(touch, event) self:onTouchMoved(touch, event) end, cc.Handler.EVENT_TOUCH_MOVED);
	listener:registerScriptHandler(function(touch, event) self:onTouchEnded(touch, event) end, cc.Handler.EVENT_TOUCH_ENDED);
	local eventDispatcher = self:getEventDispatcher();
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.m_ccbLayerTouch);
end

function CCBDomainBattleView:onTouchBegan(touch, event)

	self.m_beganPos = touch:getLocation();
	self.m_beganTime = 0;
	self.m_isTouchInBox = false;
	self.m_isDescCreate = false;
	self.m_boxIndex = 0;
	-- self.m_schedulerTouch = nil;
	self.m_touchTime = 0;
	self.m_previousPos = nil;

	if self.m_schedulerTouch then

		self:getScheduler():unscheduleScriptEntry(self.m_schedulerTouch);
		self.m_schedulerTouch = nil;
	end
	if self.m_descProp then
		self.m_descProp:removeSelf();
		self.m_descProp = nil;
	end

	for i = 1, 5 do
		local iconNode = self.m_ccbNodeRightPart:getChildByTag(i);
		local spriteNode = self.m_ccbNodeRightPart:getChildByTag(i):getChildByTag(1);
		-- local convertNodePos = spriteNode:convertToNodeSpace(self.m_beganPos);
		local convertIconPos = iconNode:convertToNodeSpace(self.m_beganPos);

		if cc.rectContainsPoint(spriteNode:getBoundingBox(), convertIconPos) then

			self.m_isTouchInBox = true;
			-- self.m_beganTime = os.time();
			self.m_boxIndex = i;
			
			self.m_schedulerTouch = self:getScheduler():scheduleScriptFunc(function(dt) self:countTouchTime(dt); end, 0, false);

			break;
		end

	end
	return true;
end

function CCBDomainBattleView:onTouchMoved(touch, event)
	if self.m_isTouchInBox then
		self.m_movePos = touch:getLocation();
		-- 移动弹框。
		-- if self.m_isDescCreate then
		-- 	if self.m_previousPos ~= nil and self.m_descProp then
		-- 		local addDisX = self.m_movePos.x - self.m_previousPos.x;
		-- 		local curPosX = self.m_descProp:getPositionX();
		-- 		self.m_descProp:setPositionX(curPosX + addDisX);
		-- 	end
		-- end
		local iconNode = self.m_ccbNodeRightPart:getChildByTag(self.m_boxIndex);
		local spriteNode = self.m_ccbNodeRightPart:getChildByTag(self.m_boxIndex):getChildByTag(1);
		-- local convertMovePos = spriteNode:convertToNodeSpace(self.m_movePos);
		local convertIconPos = iconNode:convertToNodeSpace(self.m_movePos);
		if not cc.rectContainsPoint(spriteNode:getBoundingBox(), convertIconPos) then
			if self.m_schedulerTouch then
				self:getScheduler():unscheduleScriptEntry(self.m_schedulerTouch);
				self.m_schedulerTouch = nil;
			end
			if self.m_descProp then
				self.m_descProp:removeSelf();
				self.m_descProp = nil;
			end
		end
		self.m_previousPos = self.m_movePos;
	end
end

function CCBDomainBattleView:onTouchEnded(touch, event)
	if self.m_isTouchInBox then
		if self.m_schedulerTouch then
			self:getScheduler():unscheduleScriptEntry(self.m_schedulerTouch);
			self.m_schedulerTouch = nil;
		end
		if self.m_descProp then
			self.m_descProp:removeSelf();
			self.m_descProp = nil;
		end
	end
end

function CCBDomainBattleView:countTouchTime(dt)
	self.m_touchTime = self.m_touchTime + dt;
	if self.m_touchTime > 0.6 and not self.m_isDescCreate then
		self.m_isDescCreate = true;
		if self.m_descProp == nil then
			self.m_descProp = DescripProp:create(1);
			self.m_descProp:setData(self.m_damageAwardData[tostring(self.m_boxIndex)]);

			local size = self.m_descProp:getScale9PicSize();
			-- local nodePosX = self.m_ccbNodeRightPart:getChildByTag(self.m_boxIndex):getPositionX();
			local nodePosY = self.m_ccbNodeRightPart:getChildByTag(self.m_boxIndex):getPositionY();
			self.m_descProp:setPositionY(nodePosY + display.height * 0.5 + 130 * 0.8 * 0.5 + size.height);
			if self.m_beganPos.x - size.width * 0.5 < 0 then
				self.m_descProp:setPositionX(size.width * 0.5);
			else
				self.m_descProp:setPositionX(self.m_beganPos.x);
			end
			self:addChild(self.m_descProp);
		end
	end
end

function CCBDomainBattleView:setDomainData(data)
	 	-- dump(data);
 -- "<var>" = {
 --     "code"                  = 1
 --     "day_limit"             = 5
 --     "next_add_need_diamond" = 10
 --     "player_info" = {
 --         "damage"           = 5470
 --         "damage_add_times" = 0
 --         "damage_rate"      = 0.001
 --         "nickname"         = "布朗伊芙"
 --         "rank"             = 1
 --         "remain_times"     = 3
 --         "uid"              = "cfcde2685ab4a9c2360e6bd6d2caf292"
 --     }
 --     "rank_info" = {
 --         1 = {
 --             "damage"      = 5470
 --             "damage_rate" = 0.001
 --             "nickname"    = "布朗伊芙"
 --             "rank"        = 1
 --         }
 --     }
 --     "receive_info" = {
 --         1 = 0
 --         2 = 0
 --         3 = 0
 --         4 = 0
 --         5 = 0
 --     }
 --     "remain_second"         = 9885
 -- }
 	self.m_data = data;
 	self.m_bossRemainTime = data.remain_second;
 	self.m_playerDamage = data.player_info.damage;
 	if data.player_info.rank == nil then
 		self.m_playerRank = 0;
 	else
 		self.m_playerRank = data.player_info.rank;
 	end
 	if self.m_playerRank == 0 then
 		self.m_ccbLabelMyScore:setString(Str[13001]);
 	else
 		self.m_ccbLabelMyScore:setString(self.m_playerRank);    -- 玩家本人排名
 	end

	self.m_ccbLabelMyDamage:setString(self.m_playerDamage);   -- 玩家本人伤害量

	-- 设置主页排行榜五人
	for i = 1, 5 do 
		if i <= #data.rank_info then
			self.m_ccbNodeLeftPart:getChildByTag(i):setString(data.rank_info[i].nickname);
		else
			self.m_ccbNodeLeftPart:getChildByTag(i):setString(Str[13001]);
		end
	end
	self.m_upDamageDiamond = data.next_add_need_diamond;
	local damageBMLabel = cc.LabelBMFont:create(Str[10012] .. "+" .. damagePer * data.player_info.damage_add_times .. "%", "res/font/damage_ex.fnt");
	self.m_ccbNodeAddDamageLabel:addChild(damageBMLabel);
	self.m_ccbLabelDiamond:setString(self.m_upDamageDiamond);   -- 同上 

	-- self.m_ccbBtnAddDamage     按钮怎么控制？
	-- self.m_ccbBtnAttack
	self.m_fightRemainTimes = data.player_info.remain_times;
	self.m_ccbLabelFightRemain:setString(self.m_fightRemainTimes .. " / " .. data.day_limit);

	if self.m_schedulerRemainTime == nil then
		self.m_schedulerRemainTime = self:getScheduler():scheduleScriptFunc(function(dt)
			self:setRemainTime(dt);
		end, 1, false);
	end

	self:setSelfRewardIcon(data);
end

function CCBDomainBattleView:setRemainTime(dt)
	self.m_bossRemainTime = self.m_bossRemainTime - 1;
	local hour = 0;
	local min = 0;
	local second = 0;
	hour = math.floor(self.m_bossRemainTime / 3600);
	min = math.floor((self.m_bossRemainTime % 3600) / 60);
	second = math.floor(self.m_bossRemainTime % 60);
	self.m_ccbLabelTime:setString(string.format("%02d:%02d:%02d", hour, min, second));
	if self.m_bossRemainTime <= 0 then

		-- 弹框提示

		self:getScheduler():unscheduleScriptEntry(self.m_schedulerRemainTime);
		self.m_schedulerRemainTime = nil;
	end
end

function CCBDomainBattleView:setSelfRewardIcon(data)
	local damageStandard = 0;
	for i = 1, 5 do
		local iconNode = self.m_ccbNodeRightPart:getChildByTag(i);
		local iconSpriteNode = iconNode:getChildByTag(1);
		local childNodeSize = iconSpriteNode:getContentSize();

		local awardItemID = self.m_damageAwardData[tostring(i)].items[1].item_id;
		local awardItemCount = self.m_damageAwardData[tostring(i)].items[1].count;
		local awardItemLevel = ItemDataMgr:getItemLevelByID(awardItemID);

		local bgPath = ResourceMgr:getItemBGByQuality(awardItemLevel + 1);
		local bgSprite = cc.Sprite:create(bgPath);
		iconSpriteNode:addChild(bgSprite, 1, 1);
		bgSprite:setPosition(cc.p(childNodeSize.width * 0.5, childNodeSize.height * 0.5));

		local itemImg = ResourceMgr:getItemIconByID(awardItemID);
		local itemSprite = cc.Sprite:create(itemImg);
		iconSpriteNode:addChild(itemSprite, 2, 2);
		itemSprite:setPosition(cc.p(childNodeSize.width * 0.5, childNodeSize.height * 0.5));

		local frameSprite = cc.Sprite:create(ResourceMgr:getItemBoxFrameByQuality(awardItemLevel + 1));
		frameSprite:setPosition(cc.p(childNodeSize.width * 0.5, childNodeSize.height * 0.5));
		iconSpriteNode:addChild(frameSprite, 3, 3);

		-- local receiveBtn = ccui.Button:create(itemImg, itemImg, itemImg);
		-- receiveBtn:setPosition(childNodeSize.width * 0.5, childNodeSize.height * 0.5);
		-- iconSpriteNode:addChild(receiveBtn);
		-- receiveBtn:addClickEventListener(function()
		-- 	print(" 接受  按钮    ： ", i);
		-- 	if data.player_info.damage < self.m_damageAwardData[tostring(i)].damage then
		-- 		Tips:create("伤害未达标，无法领取");
		-- 	else
		-- 		Network:request("domain_battle.domainHandler.receiveDamageAward", {award_level = i}, function(rc, data)
		-- 			if data.code ~= 1 then
		-- 				Tips:create(GameData:get("code_map", data.code)["desc"] or "领取个人奖励失败");
		-- 				return;
		-- 			end
		-- 			receiveBtn:setEnabled(false);
		-- 			self:setNodeGray(iconNode, i);
		-- 		end)
		-- 	end
		-- end)

		iconNode:getChildByTag(3):setString(awardItemCount);
		local damage = self.m_damageAwardData[tostring(i)].damage;
		local damageStr = damage;
		if damage > 10000 then
			damage = damage * 0.0001;
			damageStr = damage .. Str[10011];
		end
		self.m_ccbNodeRightPart:getChildByTag(10 + i):setString(damageStr);

		if i <= 4 then
			if self.m_playerDamage >= self.m_damageAwardData[tostring(i + 1)].damage then
				local arrowSprite = cc.Sprite:create(ResourceMgr:getDomainGoldArrowImg());
				self.m_ccbNodeRightPart:getChildByTag(20 + i):addChild(arrowSprite);
			else
				local arrowSprite = cc.Sprite:create(ResourceMgr:getDomainWhiteArrowImg());
				self.m_ccbNodeRightPart:getChildByTag(20 + i):addChild(arrowSprite);
			end
		end
		if self.m_playerDamage >= self.m_damageAwardData[tostring(i)].damage then -- 伤害达标
			damageStandard = damageStandard + 1;
			if data.receive_info[i] == 1 then    -- 奖励已领取（置灰）
				iconNode:getChildByTag(4):setEnabled(false);
				self:setNodeGray(iconSpriteNode, i);
			else
				local frameAnim = ResourceMgr:getAnimArmatureShowEffectCircle();
				iconNode:addChild(frameAnim, 5, 5);
				frameAnim:setScale(0.9);
				frameAnim:getAnimation():play("anim01");
			end
		end
	end

	local widthPercent = 0;
	if damageStandard == 1 then
		widthPercent = 7;
	elseif damageStandard > 1 then
		if damageStandard == 5 then
			widthPercent = 100;
		else
			widthPercent = 7 + (damageStandard - 1) * 23;
		end
	end
	local showWidth = self.m_spriteSize.width * widthPercent * 0.01;
	self.m_ccbSpriteDamageNumBar:setTextureRect(cc.rect(0, 0, showWidth, self.m_spriteSize.height));
end

function CCBDomainBattleView:onBtnShowReward()
	print("显示奖励");
	Network:request("domain_battle.domainHandler.queryRankInfo", {start = 1, count = 10}, function(rc, data)
		if data.code ~= 1 then 
			Tips:create(ServerCode[data.code]);
			return;
		end

		self.m_ccbRewardView = CCBRewardProp:create(self.m_playerRank);
		self.m_ccbRewardView:setData(data, self.m_data.player_info);
		App:getRunningScene():addChild(self.m_ccbRewardView, display.Z_UILAYER);
	end)

end

function CCBDomainBattleView:onBtnAddDamage()
	print("使用钻石增加伤害");
	if UserDataMgr:getPlayerDiamond() >= self.m_upDamageDiamond then
		local ccbMessageBox = CCBMessageBox:create(Str[3042], string.format(Str[4042], self.m_upDamageDiamond, damagePer), MB_YESNO); --“增加伤害”，"花费%d钻石提升%d%%伤害?"
		ccbMessageBox.onBtnOK = function ()
			self:addDamageRequest();
			ccbMessageBox:removeSelf();
		end
		ccbMessageBox.onBtnCancel = function ()
			ccbMessageBox:removeSelf();
		end
	else
		local ccbMessageBox = CCBMessageBox:create(Str[3016], Str[4004], MB_YESNO); --“购买钻石”，"钻石不足，是否前往充值页面？"
		ccbMessageBox.onBtnOK = function ()
			App:enterScene("ShopScene");
			ccbMessageBox:removeSelf();
		end
		ccbMessageBox.onBtnCancel = function ()
			ccbMessageBox:removeSelf();
		end
	end
end

function CCBDomainBattleView:addDamageRequest()
	Network:request("domain_battle.domainHandler.buyDamageAddition", nil, function(rc, data)
		if data.code ~= 1 then
			Tips:create(ServerCode[data.code]);
			return;
		end

		-- 目前增加伤害无上限
		Tips:create(Str[10017]);
		self.m_upDamageDiamond = data.next_add_need_diamond;
		self.m_ccbNodeAddDamageLabel:removeAllChildren();
		local damageBMLabel = cc.LabelBMFont:create(Str[10012] .. "+" .. damagePer * data.damage_add_times .. "%", "res/font/damage_ex.fnt");
		self.m_ccbNodeAddDamageLabel:addChild(damageBMLabel);
		self.m_ccbLabelDiamond:setString(self.m_upDamageDiamond);
		self:playAddDamageSuccessAnim();
	end)
end

function CCBDomainBattleView:playAddDamageSuccessAnim()
	local animPosX = self.m_ccbBtnAddDamage:getPositionX();
	local animPosY = self.m_ccbBtnAddDamage:getPositionY();
	local anim = ResourceMgr:getDomainUIAnim("fx_boss_buffup");
	anim:setPosition(animPosX, animPosY);
	self.m_ccbNodeRightPart:addChild(anim);
	anim:getAnimation():play("anim01");
	anim:getAnimation():setMovementEventCallFunc(function(armatureBack, movementType, movementID)
		if movementType == ccs.MovementEventType.complete then
			anim:removeSelf();
			anim = nil;
		end
	end)
end

function CCBDomainBattleView:onBtnAttackBoss()
	print("攻击boss");
	if self.m_fightRemainTimes <= 0 then
		Tips:create(Str[13007]);
	else
		self.m_ccbBtnAttack:setEnabled(false);
		Network:request("domain_battle.domainHandler.attackBoss", nil, function(rc, data)
			if data.code ~= 1 then
				Tips:create(ServerCode[data.code] or Str[13006]);
				self.m_ccbBtnAttack:setEnabled(true);
				return;
			end
		end)
	end
end

function CCBDomainBattleView:setNodeGray(node, index)
	-- display.setGray(node);    -- 对单个精灵
	display.setGray(node:getChildByTag(1));
	display.setGray(node:getChildByTag(2));
	display.setGray(node:getChildByTag(3));

	local receiveSprite = cc.Sprite:create(ResourceMgr:getItemReceiveImg());
	receiveSprite:setPosition(node:getContentSize().width * 0.5, node:getContentSize().height * 0.5);
	node:addChild(receiveSprite, 4, 10 + index);
end

function CCBDomainBattleView:removeGray(node, index)  -- node 传 self.m_ccbNodeAddSprite1
	display.removeShader(node:getChildByTag(1));
	display.removeShader(node:getChildByTag(2));
	display.removeShader(node:getChildByTag(3));
	node:removeChildByTag(10 + index);
end

function CCBDomainBattleView:onBtnReward1()
	if self.m_isDescCreate then
		return;
	end
	if self.m_playerDamage < self.m_damageAwardData["1"].damage then
		Tips:create(Str[13002]);
	else
		Network:request("domain_battle.domainHandler.receiveDamageAward", {award_level = 1}, function(rc, data)
			if data.code ~= 1 then
				Tips:create(ServerCode[data.code]);
				return;
			end

			-- dump(data);
			local iconNode = self.m_ccbNodeRightPart:getChildByTag(1);
			iconNode:removeChildByTag(5);
			iconNode:getChildByTag(4):setEnabled(false);
			self:setNodeGray(iconNode:getChildByTag(1), 1);
		end)
	end
end

function CCBDomainBattleView:onBtnReward2()
	if self.m_isDescCreate then
		return;
	end
	if self.m_playerDamage < self.m_damageAwardData["2"].damage then
		Tips:create(Str[13002]);
	else
		Network:request("domain_battle.domainHandler.receiveDamageAward", {award_level = 2}, function(rc, data)
			if data.code ~= 1 then
				Tips:create(ServerCode[data.code]);
				return;
			end
			local iconNode = self.m_ccbNodeRightPart:getChildByTag(2);
			iconNode:removeChildByTag(5);
			iconNode:getChildByTag(4):setEnabled(false);
			self:setNodeGray(iconNode:getChildByTag(1), 2);
		end)
	end
end

function CCBDomainBattleView:onBtnReward3()
	if self.m_isDescCreate then
		return;
	end	
	if self.m_playerDamage < self.m_damageAwardData["3"].damage then
		Tips:create(Str[13002]);
	else
		Network:request("domain_battle.domainHandler.receiveDamageAward", {award_level = 3}, function(rc, data)
			if data.code ~= 1 then
				Tips:create(ServerCode[data.code]);
				return;
			end
			local iconNode = self.m_ccbNodeRightPart:getChildByTag(3);
			iconNode:removeChildByTag(5);
			iconNode:getChildByTag(4):setEnabled(false);
			self:setNodeGray(iconNode:getChildByTag(1), 3);
		end)
	end
end

function CCBDomainBattleView:onBtnReward4()
	if self.m_isDescCreate then
		return;
	end
	if self.m_playerDamage < self.m_damageAwardData["4"].damage then
		Tips:create(Str[13002]);
	else
		Network:request("domain_battle.domainHandler.receiveDamageAward", {award_level = 4}, function(rc, data)
			if data.code ~= 1 then
				Tips:create(ServerCode[data.code]);
				return;
			end
			local iconNode = self.m_ccbNodeRightPart:getChildByTag(4);
			iconNode:removeChildByTag(5);
			iconNode:getChildByTag(4):setEnabled(false);
			self:setNodeGray(iconNode:getChildByTag(1), 4);
		end)
	end
end

function CCBDomainBattleView:onBtnReward5()
	if self.m_isDescCreate then
		return;
	end
	if self.m_playerDamage < self.m_damageAwardData["5"].damage then
		Tips:create(Str[13002]);
	else
		Network:request("domain_battle.domainHandler.receiveDamageAward", {award_level = 5}, function(rc, data)
			if data.code ~= 1 then
				Tips:create(ServerCode[data.code]);
				return;
			end
			local iconNode = self.m_ccbNodeRightPart:getChildByTag(5);
			iconNode:removeChildByTag(5);
			iconNode:getChildByTag(4):setEnabled(false);
			self:setNodeGray(iconNode:getChildByTag(1), 5);
		end)
	end
end

return CCBDomainBattleView;