
local LeagueConsts = require("app.views.leagueView.LeagueConsts");
local CCBLeagueDonate = require("app.views.leagueView.CCBLeagueDonate")
-------------------
-- CCB主界面
-------------------
local CCBLeagueUpgrade = class("CCBLeagueUpgrade", function ()
	return CCBLoader("ccbi/leagueView/CCBLeagueUpgrade.ccbi")
end)

function CCBLeagueUpgrade:ctor(params)
	if display.resolution >= 2 then
    	self.m_ccbLayerCenter:setScale(display.reduce);
    end

    self.m_params = params or {};

	self.m_ccbSpriteTitle:setTexture(LeagueConsts.titleRes[params.mapIndex]);

	self.m_ccbLabelCurLevel:setString(self.m_params.conf_data.level);
	self.m_ccbLabelNewLevel:setString(self.m_params.upgrade_conf_data.level);

	local money = self.m_params.upgrade_conf_data.need_items[1].count;
	self.m_ccbLabelMoney:setString(money);
	self.m_ccbLabelMoney:setColor(UserDataMgr:getLeagueMoney() < money and cc.RED or cc.WHITE)

	if self.m_params.mapIndex == LeagueConsts.BASE then
		self.m_ccbLabelAttr3:setString(self.m_params.upgrade_conf_data.upgrade_limit);
		self.m_ccbLabelAttr4:setString(self.m_params.conf_data.upgrade_limit);

		self.m_ccbLabelAttr5:setString(self.m_params.conf_data.member_limit);
		self.m_ccbLabelAttr6:setString(self.m_params.upgrade_conf_data.member_limit);

		self.m_needLevel = self.m_params.upgrade_conf_data.total_level;
	else
		self.m_ccbLabelNeedLevelTitle:setString(Str[24024]);
		self.m_needLevel = self.m_params.upgrade_conf_data.base_level;
		if self.m_params.mapIndex == LeagueConsts.RESEARCH then
			self.m_ccbLabelAttrTitle3:setString(Str[24025]);
			self.m_ccbLabelAttrTitle4:setString(Str[24025]);
			self.m_ccbLabelAttr3:setString(self.m_params.conf_data.time);
			self.m_ccbLabelAttr3:setPositionX(self.m_ccbLabelAttr3:getPositionX()-16);
			self.m_ccbLabelAttr4:setString(self.m_params.upgrade_conf_data.time);
			self.m_ccbLabelAttr4:setPositionX(self.m_ccbLabelAttr4:getPositionX()-16);
			--self.m_ccbLabelAttr3:setString(self.m_params.conf_data.time);
			--self.m_ccbLabelAttr4:setString(self.m_params.upgrade_conf_data.time);

			self.m_ccbLabelAttrTitle5:setString(Str[24026]);
			self.m_ccbLabelAttrTitle6:setString(Str[24026]);
			self.m_ccbLabelAttr5:setString(self.m_params.conf_data.research_cost[1].count);
			self.m_ccbLabelAttr6:setString(self.m_params.upgrade_conf_data.research_cost[1].count);
		else
			self.m_ccbSpriteArrow3:setVisible(false);
			self.m_ccbSpriteAttr5:setVisible(false);
			self.m_ccbSpriteAttr6:setVisible(false);

			if self.m_params.mapIndex == LeagueConsts.FINANCE then
				self.m_ccbLabelAttrTitle3:setString(Str[24027]);
				self.m_ccbLabelAttrTitle4:setString(Str[24027]);
				self.m_ccbLabelAttr3:setString(string.format("%d%%", self.m_params.conf_data.coin_reward*100));
				self.m_ccbLabelAttr4:setString(string.format("%d%%", self.m_params.upgrade_conf_data.coin_reward*100));
			elseif self.m_params.mapIndex == LeagueConsts.TRAINING then
				self.m_ccbLabelAttrTitle3:setString(Str[24028]);
				self.m_ccbLabelAttrTitle4:setString(Str[24028]);
				self.m_ccbLabelAttr3:setString(string.format("%d%%", self.m_params.conf_data.exp_reward*100));
				self.m_ccbLabelAttr4:setString(string.format("%d%%", self.m_params.upgrade_conf_data.exp_reward*100));
			elseif self.m_params.mapIndex == LeagueConsts.EXCHANGE then
				self.m_ccbLabelAttrTitle3:setString(Str[24029]);
				self.m_ccbLabelAttrTitle4:setString(Str[24029]);
				self.m_ccbLabelAttr3:setString(self.m_params.conf_data.rate);
				self.m_ccbLabelAttr4:setString(self.m_params.upgrade_conf_data.rate);
			end
		end
	end

	self.m_ccbLabelNeedLevel:setString(self.m_needLevel);
	self.m_ccbLabelNeedLevel:setColor(UserDataMgr:isLeagueBuildTotalLevel() < self.m_needLevel and cc.RED or cc.WHITE);
end

function CCBLeagueUpgrade:onBtnClose()
	self:removeSelf();
end

function CCBLeagueUpgrade:onBtnUpgrade()
	if self.m_params.isHighestLevel then
		Tips:create(Str[24011]);
	elseif UserDataMgr:isLeagueBuildTotalLevel() < self.m_needLevel then
		if self.m_params.mapIndex == LeagueConsts.BASE then
			Tips:create(Str[24012]);
		else
			Tips:create(Str[24015]);
		end
	elseif UserDataMgr:getLeagueMoney() < tonumber(self.m_ccbLabelMoney:getString()) then
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
			local level = UserDataMgr:getLeagueBuildLevel()[self.m_params.mapIndex];
			UserDataMgr:getLeagueBuildLevel()[self.m_params.mapIndex] = level + 1;
		else
			Tips:create(Str[24016]);
		end
	end
end

return CCBLeagueUpgrade