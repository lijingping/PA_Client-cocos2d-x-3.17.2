local ResourceMgr = require("app.utils.ResourceMgr");
local FrameLayer = require("app.views.common.FrameLayer")
local CCBLeagueScrollView = require("app.views.leagueView.CCBLeagueScrollView");
local CCBLeagueInfo = require("app.views.leagueView.CCBLeagueInfo")
local CCBLeagueDonate = require("app.views.leagueView.CCBLeagueDonate")
local CCBChatView = require("app.views.chatView.CCBChatView");
-------------------
-- CCB主界面
-------------------
local CCBLeagueView = class("CCBLeagueView", function ()
	return CCBLoader("ccbi/leagueView/CCBLeagueView.ccbi")
end)

function CCBLeagueView:ctor()
	--if display.resolution >= 2 then
    	--self.m_ccbNodeRightList:setScale(display.reduce);
    --end

	self.frameLayer = FrameLayer:create():addTo(self.root_layer)
	self.m_ccbNodeTop:setPositionY(self.frameLayer.top);
	self.m_ccbNodeBottom:setPositionY(self.frameLayer.bottom);


	self.m_ccbScrollView:setContainer(CCBLeagueScrollView:create())
	self.m_ccbScrollView:setContentOffset(cc.p(-260, -126));

	local data = UserDataMgr.m_leagueData[UserDataMgr.m_leagueAid];
	self.m_ccbLabelName:setString(data.name)
	self.m_ccbLabelChairname:setString(data.chairman_name)
	self.m_ccbNodeHead:addChild(cc.Sprite:create(ResourceMgr:getLeagueBadgeByIconID(data.iconID)));
end

function CCBLeagueView:onBtnInfo()
	App:getRunningScene():addChild(CCBLeagueInfo:create());
end

function CCBLeagueView:onBtnOpenFightView()
	local viewBase = App:enterScene("LeagueFightScene"):getViewBase();
	viewBase:setLastSceneName("LeagueScene");
end

function CCBLeagueView:onBtnOpenChatView()
	local chatView = CCBChatView:create();
	chatView:setName("CCBChatView");
	chatView:onBtnAlliance();
	App:getRunningScene():addChild(chatView);
end

function CCBLeagueView:onBtnOpenShopView()
	local viewBase = App:enterScene("ShopScene"):getViewBase();
 	viewBase:openLeague();
  	viewBase:setLastSceneName("LeagueScene");
end

function CCBLeagueView:onBtnOpenLeagueActivity()
	App:getRunningScene():getViewBase():createActivity();
end

function CCBLeagueView:onBtnOpenContributeView()
	App:getRunningScene():addChild(CCBLeagueDonate:create());
end

function CCBLeagueView:onBtnMoney()
	print("--------CCBLeagueView-----------")
end

return CCBLeagueView