
local ResourceMgr = require("app.utils.ResourceMgr");
local CCBExchangeCoin = require("app.views.commonCCB.CCBExchangeCoin");
local league_create = require("app.constants.league_create");
local CCBChangeBadge = require("app.views.leagueView.CCBChangeBadge")
-------------------
-- CCB主界面
-------------------
local CCBLeagueCreate = class("CCBLeagueCreate", function ()
	return CCBLoader("ccbi/leagueView/CCBLeagueCreate.ccbi")
end)

local this
function CCBLeagueCreate:ctor()
	this = self;

	if display.resolution >= 2 then
    	self.m_ccbLayerCenter:setScale(display.reduce);
    end

	self.m_nameEditBox = self:createEditBox(self.m_ccbNodeInput, 21, Str[24003]);
	self.m_notifyEditBox = self:createEditBox(self.m_ccbNodeNodify, 50, Str[24018]);

	self.m_ccbSpriteBadge:setTexture(ResourceMgr:getLeagueBadgeByIconID(1));

	self.m_ccblabelCost:setString(league_create["1"].cost)
end

function function_name( ... )
	self.m_ccblabelCost:setString(league_create["1"].cost)
end

function CCBLeagueCreate:createEditBox(parent, nMaxLength, strPlaceHolder)
	-- 创建EditBox
	local boxSize = parent:getContentSize();
	local editBox = cc.EditBox:create(boxSize, "res/resources/friendView/friend_input.png");
	editBox:setAnchorPoint(cc.p(0, 0));
	editBox:setFontSize(20);
	editBox:setFontColor(cc.c3b(255, 255, 255));
	editBox:setPlaceholderFontSize(20);
	editBox:setPlaceholderFontColor(cc.c3b(102, 102, 102));
	editBox:setPlaceHolder(strPlaceHolder);
	editBox:setMaxLength(nMaxLength);
	editBox:setReturnType(cc.KEYBOARD_RETURNTYPE_GO);
	editBox:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE);
	parent:addChild(editBox);

	local function editBoxTextEventHandle(stringEventName, pSender)
		if stringEventName == "changed" then
			local editBoxLen, chNum, enNum = Utils:getStringLenth(pSender:getText());
			if editBoxLen >= nMaxLength then
				pSender:setMaxLength(chNum + enNum);
			else
				pSender:setMaxLength(nMaxLength);
			end
		end
	end	
	editBox:registerScriptEditBoxHandler(editBoxTextEventHandle);

	return editBox;
end

function CCBLeagueCreate:onBtnClose()
	this = nil
	self:removeSelf();
end

function CCBLeagueCreate:onBtnCreate()
	if UserDataMgr:getPlayerGoldCoin() < tonumber(self.m_ccblabelCost:getString()) then
		local ccbMessageBox = CCBMessageBox:create(Str[3004], Str[24019], MB_YESNO); --“购买钻石”，"钻石不足，是否前往充值页面？"
		ccbMessageBox.onBtnOK = function ()
			CCBExchangeCoin:create();

			ccbMessageBox:removeSelf();
		end
		ccbMessageBox.onBtnCancel = function ()
			ccbMessageBox:removeSelf();
		end
	else
		--[[
			1、联盟名字是否重复
			2、联盟名字长度不符合
			3、联盟名字中是否包含敏感文字
		]]
		--这边还需要判断 名称和公告字数在要求范围内
		if #self.m_nameEditBox:getText() <= 0 then
			Tips:create(Str[24021]);
		elseif #self.m_notifyEditBox:getText() <= 0 then
			Tips:create(Str[24020]);
		else
			local editBoxLen = Utils:getStringLenth(self.m_nameEditBox:getText());
			if editBoxLen < 2 then
				Tips:create(Str[24003]);
			else
				Tips:create(Str[24002]);

				local i = #UserDataMgr.m_leagueData+1
				local data = {}
				data.id = i
				data.aid = i
				data.name = self.m_nameEditBox:getText()
				data.state = 2--"需要审批"
				data.chairman_name = UserDataMgr:getPlayerName()
				data.notice = self.m_notifyEditBox:getText()
				data.level=1
				data.power=100+i
				data.member_count=10
				data.member_limit =50
				UserDataMgr.m_leagueData[i] = data;

				UserDataMgr:setPlayerUnionLevel(1);
				UserDataMgr.m_leagueAid = data.aid

				App:getRunningScene():getViewBase().m_ccbLeagueApply:removeSelf();
				App:getRunningScene():getViewBase():createView();

				self:removeSelf();
			end
		end
	end
end

function CCBLeagueCreate:onBtnChangeIcon()
	if #self.m_nameEditBox:getText() <= 0 then
		Tips:create(Str[24001]);
	end
	local changeBadge = CCBChangeBadge:create();
	changeBadge:setLeagueName(self.m_nameEditBox:getText());
	changeBadge:setCallFunc(function(params)
		if this then
			this.m_ccbSpriteBadge:setTexture(params.iconTexture)
		end
	end)
	App:getRunningScene():addChild(changeBadge)
end

return CCBLeagueCreate