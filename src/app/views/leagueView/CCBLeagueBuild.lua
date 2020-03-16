local league_build_desc = require("app.constants.league_build_desc");
local exchange_data = require("app.constants.league_upgrade_exchange");
local finance_data = require("app.constants.league_upgrade_finance");
local research_data = require("app.constants.league_upgrade_research");
local training_data = require("app.constants.league_upgrade_training");
local base_data = require("app.constants.league_upgrade_base");
local LeagueConsts = require("app.views.leagueView.LeagueConsts");
local CCBLeagueBase = require("app.views.leagueView.CCBLeagueBase");
local CCBLeagueDonate = require("app.views.leagueView.CCBLeagueDonate")
-------------------
-- CCB主界面
-------------------
local CCBLeagueBuild = class("CCBLeagueBuild", function ()
	return CCBLoader("ccbi/leagueView/CCBLeagueBuild.ccbi")
end)

function CCBLeagueBuild:ctor(params)
	if display.resolution >= 2 then
		self.m_ccbLayerCenter:setScale(display.reduce);
    end

    self.m_params = params;
	
	local data = {base_data, finance_data, training_data, research_data, exchange_data};
	self.m_data = data[self.m_params.mapIndex]["1"];

	self.m_ccbSpriteTitle:setTexture(LeagueConsts.titleRes[params.mapIndex]);
	self.m_ccbSpriteIcon:setTexture(LeagueConsts.iconRes[params.mapIndex]);
	self.m_ccbLabelDesc:setString(league_build_desc[tostring(params.mapIndex)].desc);

	self.m_needLevel = self.m_data.total_level or self.m_data.base_level;

	self.m_ccbLabelLevel:setString(self.m_needLevel)
		:setColor(self.m_needLevel > UserDataMgr:getLeagueBuildLevel()[LeagueConsts.BASE] and cc.RED or cc.WHITE);
	self.m_ccbLabelMoney:setString(self.m_data.need_items[1].count)
		:setColor(self.m_data.need_items[1].count > UserDataMgr:getLeagueMoney() and cc.RED or cc.WHITE);

	if self.m_data.base_level then
		self.m_ccbLabelAttrTitle:setString(Str[24024])
	end
end

function CCBLeagueBuild:onBtnClose()
	self:removeSelf();
end

function CCBLeagueBuild:onBtnBuild()
	if self.m_needLevel > UserDataMgr:getLeagueBuildLevel()[LeagueConsts.BASE] then
		local ccbMessageBox = CCBMessageBox:create(Str[3004], Str[24015], MB_YESNO); 
		ccbMessageBox.onBtnOK = function ()
			App:getRunningScene():addChild(CCBLeagueBase:create({mapIndex = LeagueConsts.BASE}));

			ccbMessageBox:removeSelf();
		end
		ccbMessageBox.onBtnCancel = function ()
			ccbMessageBox:removeSelf();
		end
	elseif tonumber(self.m_ccbLabelLevel:getString()) > UserDataMgr:getLeagueMoney() then
		local ccbMessageBox = CCBMessageBox:create(Str[3004], Str[24023], MB_YESNO); 
		ccbMessageBox.onBtnOK = function ()
			App:getRunningScene():addChild(CCBLeagueDonate:create());

			ccbMessageBox:removeSelf();

			self:onBtnClose();
		end
		ccbMessageBox.onBtnCancel = function ()
			ccbMessageBox:removeSelf();
		end
	else
		local isUpgrade = UserDataMgr:isLeagueChairman() or UserDataMgr:isLeagueSubChairman();
		if isUpgrade then
			UserDataMgr:isLeagueLeagueBuild(self.m_params.mapIndex, true);
			Tips:create("建造完成");

			self:onBtnClose();
		else
			Tips:create(Str[24017]);
		end
	end
end

return CCBLeagueBuild