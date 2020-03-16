local CCBLeagueExchange = require("app.views.leagueView.CCBLeagueExchange");
local CCBLeagueFinance = require("app.views.leagueView.CCBLeagueFinance");
local CCBLeagueResearch = require("app.views.leagueView.CCBLeagueResearch");
local CCBLeagueTraining = require("app.views.leagueView.CCBLeagueTraining");
local CCBLeagueBase = require("app.views.leagueView.CCBLeagueBase");
local CCBLeagueBuild = require("app.views.leagueView.CCBLeagueBuild");

local league_build_desc = require("app.constants.league_build_desc");

local LeagueConsts = require("app.views.leagueView.LeagueConsts");
-------------------
-- CCB主界面
-------------------
local CCBLeagueScrollView = class("CCBLeagueScrollView", function()
	return CCBLoader("ccbi/leagueView/CCBLeagueScrollView.ccbi")
end)

function CCBLeagueScrollView:ctor()
	self:createTouchEvent();

	self.m_build_data = {};

	self.m_file = {CCBLeagueBase, CCBLeagueFinance, CCBLeagueTraining, 
		CCBLeagueResearch, CCBLeagueExchange};
end

function CCBLeagueScrollView:createTouchEvent()
	local listener = cc.EventListenerTouchOneByOne:create();
	listener:registerScriptHandler(function (touch, event) return self:onTouchBegan(touch, event) end, cc.Handler.EVENT_TOUCH_BEGAN);
	listener:registerScriptHandler(function (touch, event) return self:onTouchEnded(touch, event) end, cc.Handler.EVENT_TOUCH_ENDED);
	self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self);
end
function CCBLeagueScrollView:onTouchBegan(touch, event)
	self.m_beganPos = touch:getLocation();
	return true
end

function CCBLeagueScrollView:onTouchEnded(touch, event)
	local pos = touch:getLocation();
	if self.m_beganPos.x == pos.x and self.m_beganPos.y == pos.y then
		local convertIconPos = self:convertToNodeSpace(pos);
		for i=1,LeagueConsts.MAX_BUILD do
			local index = i*10 + 1;
			while(true) do
				local node = self:getChildByTag(index);
				if node == nil then break end
				if cc.rectContainsPoint(node:getBoundingBox(), convertIconPos) then
					self:onBtn(self.m_file[i], i);
					return
				end
				index = index + 1;		
			end
		end
	end
end

function CCBLeagueScrollView:onBtn(view, index)
	if self.m_build_data[index] == nil then
		self.m_build_data[index] = clone(league_build_desc[tostring(index)]);
	end

	if self.m_build_data[index].unlock_level <= 0 then--初始解锁（无需进行建造）
		App:getRunningScene():addChild(view:create({mapIndex = index}));
	else
		if UserDataMgr:isLeagueLeagueBuild()[index] == false then
			App:getRunningScene():addChild(CCBLeagueBuild:create({mapIndex = index}));
		else
			App:getRunningScene():addChild(view:create({mapIndex = index}));
		end
	end
end

function CCBLeagueScrollView:onBtnFinance()
	self:onBtn(CCBLeagueFinance, LeagueConsts.FINANCE);
end

function CCBLeagueScrollView:onBtnBase()
	self:onBtn(CCBLeagueBase, LeagueConsts.BASE);
end

function CCBLeagueScrollView:onBtnTraining()
	self:onBtn(CCBLeagueTraining, LeagueConsts.TRAINING);
end

function CCBLeagueScrollView:onBtnExchange()
	self:onBtn(CCBLeagueExchange, LeagueConsts.EXCHANGE);
end

function CCBLeagueScrollView:onBtnResearch()
	self:onBtn(CCBLeagueResearch, LeagueConsts.RESEARCH);
end

return CCBLeagueScrollView