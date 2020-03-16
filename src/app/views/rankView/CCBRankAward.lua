local ResourceMgr = require("app.utils.ResourceMgr");
local Tips = require("app.views.common.Tips");
local CCBCheckAward = require("app.views.rankView.CCBCheckAward");

local CCBRankAward = class("CCBRankAward", function ()
	return CCBLoader("ccbi/rankView/CCBRankAward.ccbi")
end)

function CCBRankAward:ctor()
	if display.resolution >= 2 then
		self.m_ccbNodeCenter:setScale(display.reduce);
	end
	
	self:createCoverLayer();

	local rankInfo = UserDataMgr:getPlayerRankInfo();
	self.m_ccbLabelRank:setString(rankInfo.name);

	local rankName = cc.Sprite:create(ResourceMgr:getRankTextByLevel(rankInfo.level));
	rankName:setScale(0.8);
	self.m_ccbNodeRankName:addChild(rankName);

	local rankIcon = cc.Sprite:create(ResourceMgr:getRankBigIconByLevel(rankInfo.level));
	rankIcon:setScale(0.6);
	self.m_ccbNodeRankIcon:addChild(rankIcon);

	--icon
	self.m_table_daily_rank_award = table.clone(require("app.constants.daily_rank_award"))[tostring(rankInfo.level)].award;

	self.m_nodeAwardItemIcon = cc.Node:create();
	local posx = 0;
	local distance = 127;
	local width = (#self.m_table_daily_rank_award-1)*distance;
	local isRankAwardGet = UserDataMgr:isRankAwardGet();
	self.m_nodeAwardItemIcon:setContentSize(cc.size(width, 0));
	for i, v in pairs(self.m_table_daily_rank_award) do
		local itemIconGroup = ResourceMgr:createReceiveRankAwardIcon(v.item_id, v.count);
		itemIconGroup:setPositionX(posx);
		itemIconGroup:setTag(i);
		self.m_nodeAwardItemIcon:addChild(itemIconGroup);
		posx = posx + distance;

		if isRankAwardGet then
			ResourceMgr:changeRankAwardIconReceiveState(itemIconGroup, isRankAwardGet);
		end
	end
	self.m_nodeAwardItemIcon:setPositionX(-width*0.5);
	self.m_ccbNodeIcon:addChild(self.m_nodeAwardItemIcon);

	self.m_ccbSpriteReceived:setVisible(isRankAwardGet);
	self.m_ccbSpriteReceiving:setVisible(not isRankAwardGet);
end

function CCBRankAward:createCoverLayer()
	local listener = cc.EventListenerTouchOneByOne:create();
	listener:setSwallowTouches(true);
    listener:registerScriptHandler(function(touch, event) return true end, cc.Handler.EVENT_TOUCH_BEGAN);

    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self.m_ccbLayerColor);
end

function CCBRankAward:onBtnCheck()
	self:removeSelf();

	App:getRunningScene():addChild(CCBCheckAward:create());
end

function CCBRankAward:onBtnReceive()
	if UserDataMgr:isRankAwardGet() then
		return Tips:create(Str[19001]);
	end

	Network:request("game.taskHandler.receive_rank_award", nil, function (rc, receiveData)
		if receiveData.code ~= 1 then
			Tips:create(ServerCode[reveiveData.code]);
			return;
		end

		UserDataMgr:setRankAwardGet(true);

		for i, v in pairs(self.m_table_daily_rank_award) do
			ResourceMgr:changeRankAwardIconReceiveState(self.m_nodeAwardItemIcon:getChildByTag(i), true);
		end

		self.m_ccbSpriteReceived:setVisible(true);
		self.m_ccbSpriteReceiving:setVisible(false);
	end)
end

function CCBRankAward:onBtnClose()
	self:removeSelf();
end

return CCBRankAward