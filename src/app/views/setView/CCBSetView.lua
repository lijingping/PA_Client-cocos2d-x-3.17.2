local CCBHelpView = require("app.views.helpView.CCBHelpView");
local Tips = require("app.views.common.Tips")
local CCBMessageBox = require("app.views.commonCCB.CCBMessageBox");

local CCBSetView = class("CCBSetView", function ()
	return CCBLoader("ccbi/setView/CCBSetView.ccbi")
end)

function CCBSetView:ctor()
	if display.resolution >= 2 then
		self.m_ccbNodeCenter:setScale(display.reduce);
	end
	self:createCoverLayer();

	self.userDefault = cc.UserDefault:getInstance();
	local nMusic = self.userDefault:getStringForKey("musicVolume", 1);
	self:setMusic(tonumber(nMusic));

	local nEffects = self.userDefault:getStringForKey("effectsVolume", 1);
	self:setEffects(tonumber(nEffects));
end

function CCBSetView:createCoverLayer()
	local listener = cc.EventListenerTouchOneByOne:create();
	listener:setSwallowTouches(true);
    listener:registerScriptHandler(function(touch, event) return true end, cc.Handler.EVENT_TOUCH_BEGAN);

    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self.m_ccbLayerColor);
end

function CCBSetView:onBtnHelp()
	self:onBtnClose();

	App:getRunningScene():addChild(CCBHelpView:create());
end

function CCBSetView:onBtnLogout()
	-- 1
	--[[
		local scene = App:enterScene("LoginScene");
		scene:getViewBase().m_ccbLoginView:onConnectSuccessed();
		local account, password = scene:onConnectSuccessed() -- 取出已保存在本地的帐号密码(如有)
		scene:getViewBase().m_ccbLoginView:setDefaultInfo(account, password);
	]]
	-- 2 App:enterScene("LoginScene"):onConnectSuccessed(1);
	-- 3
	local ccbMessageBox = CCBMessageBox:create(Str[3036], "当前接口可以退到登入界面，接入正式服务器，敬请期待", MB_OK); -- 道具不足
	ccbMessageBox.onBtnOK = function ()
		ccbMessageBox:removeSelf();
		
		Network:request("login.userHandler.logout", nil, function (rc, data)
			if data["code"] ~= 1 then
				Tips:create(ServerCode[data.code]);
				return
			end

			local function askSeed(rc, seed)
				if rc ~= 0 then
					Tips:create("获取服务器随机种子失败, code:" .. rc);
				else
					Network.seed = seed;
					App:enterScene("LoginScene"):onConnectSuccessed(seed);

					ItemDataMgr:Init();
					FortDataMgr:Init();
					ProduceDataMgr:Init();
					UserDataMgr:Init();
					ShipDataMgr:Init();
					EscortDataMgr:Init();
					MailDataMgr:Init();
					FriendDataMgr:Init();
					RevengeDataMgr:Init();
					ChatDataMgr:Init();
				end
			end
			Network:request("connector.entryHandler.askSeed", nil, askSeed);
		end)
	end
end

function CCBSetView:setMusic(nValue)
	Audio:setMusicVolume(nValue);
	self.m_ccbSpriteMusicClose:setVisible(nValue == 0);
	self.m_ccbSpriteMusicOpen:setVisible(nValue == 1);
	self.userDefault:setStringForKey("musicVolume", nValue);
	self.userDefault:flush();
end

function CCBSetView:onBtnMusicClose()
	self:setMusic(0);
end

function CCBSetView:onBtnMusicOpen()
	self:setMusic(1);
end

function CCBSetView:setEffects(nValue)
	Audio:setEffectsVolume(nValue);
	self.m_ccbSpriteEffectsClose:setVisible(nValue == 0);
	self.m_ccbSpriteEffectsOpen:setVisible(nValue == 1);
	self.userDefault:setStringForKey("effectsVolume", nValue);
	self.userDefault:flush();
end

function CCBSetView:onBtnEffectsClose()
	self:setEffects(0);
end

function CCBSetView:onBtnEffectsOpen()
	self:setEffects(1);
end

function CCBSetView:onBtnClose()
	self:removeSelf();
end

return CCBSetView