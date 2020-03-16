local ResourceMgr = require("app.utils.ResourceMgr");
local Tips = require("app.views.common.Tips")
local CCBMessageBox = require("app.views.commonCCB.CCBMessageBox");
local CCBCommonGetPath = require("app.views.commonCCB.CCBCommonGetPath");

local escort_level_limit = 10
local domain_level_limit = 20

local CCBChannel = class("CCBChannel", function ()
	return CCBLoader("ccbi/mainView/CCBChannel.ccbi")
end)


local this = nil

function CCBChannel:ctor(parentNode)
	print("创建菜单");
	if display.resolution >= 2 then
        self.m_ccbNodeAnim:setScale(display.reduce);
        self.m_ccbNodeBtns:setScale(display.reduce);
    end
	self.m_nodeParent = parentNode;
	self:createCoverLayer();
	this = self

	self.m_exploreCoolTime = -1;
	self.m_updateScheduler = nil;
	self.m_ccbLabelExploreTime:setVisible(false);
	self.m_ccbSpriteExploreTimeTip:setVisible(false);

	self.m_Armature = nil;
	self.m_muneState = {true, true, true, false, true, false};
	self.m_ccbNodeBtns:setVisible(false);
	if UserDataMgr:getPlayerLevel() < domain_level_limit then
		self.m_muneState[5] = false;
		self.m_ccbSpriteDomainTip:setVisible(true);
	else
		self.m_ccbSpriteDomainTip:setVisible(false);
	end
	if UserDataMgr:getPlayerLevel() < escort_level_limit then
		self.m_muneState[3] = false;
		self.m_ccbSpriteEscortTip:setVisible(true);
	else
		self.m_ccbSpriteEscortTip:setVisible(false);
	end

	if UserDataMgr:getPlayerUnionLevel() > 0 then
		self.m_muneState[4] = true;
		self.m_ccbSpriteAllianceTip:setVisible(false);
	else
		self.m_ccbSpriteAllianceTip:setVisible(true)
	end

	self:LoadAnimation();
end

--屏蔽当前界面外的点击事件
function CCBChannel:createCoverLayer()
	self.m_listener = cc.EventListenerTouchOneByOne:create();
	self.m_listener:setSwallowTouches(true);
    self.m_listener:registerScriptHandler(function(touch, event) return true end, cc.Handler.EVENT_TOUCH_BEGAN);
    local eventDispatcher = self:getEventDispatcher();
    eventDispatcher:addEventListenerWithSceneGraphPriority(self.m_listener, self);
end

function CCBChannel:LoadAnimation()
	-- body
	self.m_Armature = ResourceMgr:getAramtureChannel();
	self.m_ccbNodeAnim:addChild(self.m_Armature);

	self.m_Armature:getAnimation():setMovementEventCallFunc(function(armatureBack, movementType, movementID) 
		if movementType == ccs.MovementEventType.complete then
			if movementID == "start" then
				self.m_Armature:getAnimation():play("idle");
				self.m_ccbNodeBtns:setVisible(true);
				self.m_ccbBtnCancel:setEnabled(true);
				self:requestExploreCoolTime();
			elseif movementID == "end" then
				self:exit();
			end
		end
	end)

	self.m_Armature:getAnimation():play("start");

	self.m_ccbBtnCancel:setOpacity(0);
	self.m_ccbBtnCancel:setEnabled(false);
	self.m_ccbBtnCancel:runAction(cc.FadeIn:create(0.5));
end

--pvp
function CCBChannel:onBtnMune1()
	if self.m_muneState[1] == false then
		print("mune1 close");
		return;
	end
	print("mune1 open");
	self.m_nodeParent:onBtnPvP();
	self:exit();
end

--星球探险
function CCBChannel:onBtnMune2()
	if self.m_muneState[2] == false then
		Tips:create(Str[17002]);
		return;
	end

	if self.m_exploreCoolTime > 0 then
		Tips:create(Str[17002]);
		return;
	end

	print("mune2 open");
	local ccbCostCoinsMsgBox = CCBMessageBox:create(Str[3004], Str[17001], MB_OKCANCEL);
	ccbCostCoinsMsgBox.onBtnOK = function ()
		local plantExploreItemId = 4013;
		if ItemDataMgr:getItemCount(plantExploreItemId) < 1 then--进行星球探索需要消耗探险地图x1
			CCBCommonGetPath:create(plantExploreItemId);

			ccbCostCoinsMsgBox:removeSelf();
		else
			if self.m_exploreCoolTime <= 0 then
				self.m_nodeParent:planetExplore();
				self:exit();
				
				ccbCostCoinsMsgBox:removeSelf();
			else
				Tips:create(Str[17002])
			end
		end
	end
	ccbCostCoinsMsgBox.onBtnCancel = function ()
		ccbCostCoinsMsgBox:removeSelf();
	end
end

--护送贩售舰
function CCBChannel:onBtnMune3()
	if self.m_muneState[3] == false then
		Tips:create(Str[11005]..escort_level_limit);
		return;
	end
	print("mune3 open");
	self.m_nodeParent:onBtnEscort();
	self:exit();
end

--殖民星争夺
function CCBChannel:onBtnMune4()
	if self.m_muneState[4] == false then
		Tips:create(Str[11006]);
		return;
	end
	App:enterScene("LeagueFightScene");
	self:exit();
end

--公域混战
function CCBChannel:onBtnMune5()
	if self.m_muneState[5] == false then
		Tips:create(Str[11005]..domain_level_limit);
		return;
	end
	print("mune5 open");
	self.m_nodeParent:enterDomainView();
	self:exit();
end

--反攻地球
function CCBChannel:onBtnMune6()
	if self.m_muneState[6] == false then
		Tips:create(Str[11007]);
		return;
	end
	print("mune6 open");
	self:exit();
end

--取消
function CCBChannel:onBtnCancel()
	self.m_ccbNodeBtns:setVisible(false);
	self.m_Armature:getAnimation():play("end");

	self.m_ccbBtnCancel:setEnabled(false);
	self.m_ccbBtnCancel:runAction(cc.FadeOut:create(0.5));
end

function CCBChannel:exit()
	self:unscheduleScriptEntry();
	self:removeSelf();
	this = nil
end

function CCBChannel:requestExploreCoolTime()
	print("请求探索CD");
	Network:request("game.userHandler.query_explore_cd", nil, function (rc, receiveData)
		if receiveData.code ~= 1 then
			Tips:create(Str[8005]);
			return;
		end

		if this then
			this:updateExploreCoolTime(receiveData.explore_cd);
		end
	end)
end

function CCBChannel:updateExploreCoolTime(time)
	print("探索CD倒计时，CD时间：", time);
	local lastTime = time;
	self.m_exploreCoolTime = time;
	if time > 0 then
		self.m_ccbLabelExploreTime:setString(self:setStrTimeFormat(lastTime));	
		self.m_ccbLabelExploreTime:setVisible(true);
		self.m_ccbSpriteExploreTimeTip:setVisible(true);

		self.m_updateScheduler = self:getScheduler():scheduleScriptFunc(
			function()
				-- 1秒更新1次 
				self.m_ccbLabelExploreTime:setString(self:setStrTimeFormat(lastTime));				
				lastTime = lastTime - 1;

				if lastTime < 0 then
					self.m_ccbLabelExploreTime:setVisible(false);
					self.m_ccbSpriteExploreTimeTip:setVisible(false);

					self.m_exploreCoolTime = 0;
					self:unscheduleScriptEntry();
				end
	 		end, 
	 	1, false);
	end
end

function CCBChannel:setStrTimeFormat(time)
	-- print("CD时间", time);
	local hour = math.floor(time / 3600);
	local minute = math.floor((time % 3600) / 60);
	local second = time % 60;
	return string.format("%02d:%02d:%02d", hour, minute, second);
end

function CCBChannel:unscheduleScriptEntry()
	if self.m_updateScheduler then
		self:getScheduler():unscheduleScriptEntry(self.m_updateScheduler);
		self.m_updateScheduler = nil;
	end
end

return CCBChannel