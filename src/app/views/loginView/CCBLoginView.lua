--local FrameLayer = require("app.views.common.FrameLayer")
--local NumberTips = require("app.views.common.NumberTips")
--local BattleResourceMgr = require("app.utils.BattleResourceMgr");
--local CCBEscortResult = require("app.views.escortView.CCBEscortResult");
local ResourceMgr = require("app.utils.ResourceMgr");
-- local RankUpView = require("app.views.common.RankUpView");
-- local BuffWordTips = require("app.views.common.BuffWordTips");
-- local PropDescPop = require("app.views.battle.PropDescPop");
local PlayerLevelUp = require("app.views.common.PlayerLevelUp");
local CCBServerView = require("app.views.loginView.CCBServerView");
--local LoadingResourceView = require("app.views.common.LoadingResourceView");

CC_SHOW_SERVER = true;
--------------
-- CCB登录界面
--------------
local CCBLoginView = class("CCBLoginView", function ()
	return CCBLoader("ccbi/loginView/CCBLoginView.ccbi")
end)

function CCBLoginView:ctor()
	print("    ccbLoginView:ctor()    ")
	self:enableNodeEvents();
	
	if display.resolution >= 2 then
		self:setScale(display.reduce)
	end

	self.editName = nil
	self.editPassword = nil

	self.m_isConnect = false;
	
	self.m_ccbLayerLoginPopup:setVisible(false)
	self.m_ccbSpriteText:setVisible(false)

	self:loadMusicFile();

	self:init()
	
	Audio:preloadMusic(12, "res/music/loginSceneBg.mp3");
	Audio:playMusic(12, true);
	-- dump(cc.FileUtils:getInstance():getStringFromFile("res.resources.common"));
			-- require "lfs";
			-- local filenum=0
			-- function traver(rootpath)
			-- 	local traverpath,attr
			-- 	for entry in lfs.dir(rootpath) do
			-- 		if entry~='.' and entry~='..' then
			-- 			traverpath = rootpath.."/"..entry
			-- 			attr = lfs.attributes(traverpath)
			-- 			if(type(attr)~="table") then --如果获取不到属性表则报错
			-- 				print('ERROR:'..traverpath..'is not a path')
			-- 				save:close()
			-- 				print("   执行     结束1  ");
			-- 			end
			-- 			if(attr.mode == "directory") then
			-- 				traver(traverpath)
			-- 			elseif attr.mode=="file" then
			-- 				filenum=filenum+1
			-- 				--处理函数
			-- 				dosomething(traverpath)					
			-- 			end
			-- 		end
			-- 	end
			-- end
			-- local filedir = "res/resources/exploreView"
			-- if(not traver(filedir)) then
			-- 	print("   执行结束  ");
			-- end


	-- local path = "res/resources/loginView";
	-- -- if not cc.FileUtils:getInstance():isAbsolutePath(path) then
	-- -- 	path = cc.FileUtils:getInstance():fullPathForFilename(path);
	-- -- end

	-- print("     path :   ", path);

	-- local getPath = newBattle.getResourcePath(path);
	-- dump(getPath);
	-- for i = 1, #getPath do
	-- 	local titleLabel3 = cc.LabelTTF:create();
	-- 	titleLabel3:setFontSize(30);
	-- 	self:addChild(titleLabel3);
	-- 	titleLabel3:setPosition(cc.p(display.cx, display.cy + 180 - 40 * (i - 1)));
	-- 	-- if getPath[1] ~= nil then
	-- 		titleLabel3:setString("string:" .. getPath[i]);
	-- 	-- else
	-- 	-- 	titleLabel3:setString("none");
	-- 	-- end
	-- end



	-- local paths = cc.FileUtils:getInstance():getWritablePath();
	-- dump(paths);
	-- local iter, dir_obj = lfs.dir(path);
	-- dump(iter);
	-- dump(dir_obj);

	-- function getFileName(str)
	--     local idx = str:match(".+()%.%w+$")
	--     if(idx) then
	--         return str:sub(1, idx-1)
	--     else
	--         return str
	--     end
	-- end

	-- --get file postfix
	-- function getExtension(str)
	--     return str:match(".+%.(%w+)$")
	-- end

	-- local pk = 0; 
	-- function fun(rootpath)
	--     for entry in lfs.dir(rootpath) do
	--         if entry ~= '.' and entry ~= '..' then
	--         	print(" !!!!!!!!1 ", rootpath);
	--         	print("  ~~~~~~~~~~~`", entry);
	--             local path = rootpath .. "/" .. entry
	--             print("  path ", path);

	--             if pk == 0 then
	--             	local titleLabel = cc.LabelTTF:create();
	-- 				titleLabel:setFontSize(20);
	-- 				self:addChild(titleLabel);
	-- 				titleLabel:setPosition(cc.p(display.cx, display.cy + 130));
	-- 				titleLabel:setString(path);
	-- 				pk = pk + 1;
	--             end
	--             local attr = lfs.attributes(path)

	-- 			local filename = getFileName(entry)

	-- 			if attr.mode ~= 'directory' then
	-- 				local postfix = getExtension(entry)
	-- 				print(filename .. '\t' .. attr.mode .. '\t' .. postfix)
	-- 			else
	-- 				print(filename .. '\t' .. attr.mode)
	-- 				fun(path)
	-- 			end
	--         end
	--     end
	-- end
	-- fun(path);

	-- local battleData = {
 --      animation = 13000,
 --      battle_type = 0,
 --      config = {
 --          f1 = {
 --              bullet_id = 90019,
 --              fort_id = 90019,
 --              fort_level = 99,
 --              fort_star_domain = 103,
 --              fort_type = 0,
 --              skill_level = 10
 --          },
 --          f2 = {
 --              bullet_id = 90020,
 --              fort_id = 90020,
 --              fort_level  = 99,
 --              fort_star_domain = 103,
 --              fort_type = 1,
 --              skill_level = 10
 --          },
 --          f3 = {
 --              bullet_id = 90021,
 --              fort_id = 90021,
 --              fort_level = 99,
 --              fort_star_domain = 103,
 --              fort_type = 2,
 --              skill_level = 10
 --          },
 --          f4 = {
 --              bullet_id = 90019,
 --              fort_id = 90019,
 --              fort_level = 99,
 --              fort_star_domain = 103,
 --              fort_type = 0,
 --              skill_level = 10
 --          },
 --          f5 = {
 --              bullet_id = 90020,
 --              fort_id = 90020,
 --              fort_level = 99,
 --              fort_star_domain = 103,
 --              fort_type = 1,
 --              skill_level = 10
 --          },
 --          f6 = {
 --              bullet_id = 90021,
 --              fort_id = 90021,
 --              fort_level = 99,
 --              fort_star_domain = 103,
 --              fort_type = 2,
 --              skill_level = 10
 --          },
 --          hp1 = 486678,
 --          hp2 = 486678,
 --          item1 = {
 --          },
 --          item2 = {
 --          },
 --          level1 = 99,
 --          level2 = 99,
 --          name_1 = "毫无还击能力的训练机器人",
 --          name_2 = "艾尔索普奥德丽",
 --          power_1 = 0,
 --          power_2 = 520241,
 --          ship1 = 70001,
 --          ship2 = 70007,
 --          ship_skill_level1 = 10,
 --          ship_skill_level2 = 10,
 --          sid_2 = "connector-server-1",
 --          uid_1 = "robot",
 --          uid_2 = "cfcde2685ab4aa52209ca97148571c9b"
 --      },
 --      energy_refresh_time = "15,20,27,16,30,18,30,20,23,23",
 --      energy_string = "1,0,0,0,1,1,1,1,1,0,1,0#0,1,0,1,1,0,0,0,1,0,1,0#1,2,0,0,1,0,0,1,0,1,1,0#0,0,0,1,0,0,1,1,0,0,1,0#1,2,0,0,0,1,0,1,0,0,1,0#1,2,1,1,0,1,0,0,0,0,0,0#1,0,1,1,0,1,1,1,0,0,1,1#1,0,1,0,1,1,0,1,0,0,1,0#2,2,1,1,0,0,0,1,0,1,1,1#1,2,0,0,0,0,1,0,1,1,1,0#",
 --      is_uid1 = false, -- 是否是玩家1
 --      name_1 = "毫无还击能力的训练机器人",
 --      name_2 = "艾尔索普奥德丽",
 --      power_1 = 0,
 --      power_2 = 520241,
 --      uid_1 = "robot",
 --      uid_2 = "cfcde2685ab4aa52209ca97148571c9b"
 --  }
	-- local loadView = LoadingResourceView:create(battleData);
	-- self:addChild(loadView);
	-- loadView:setPosition(display.cx, display.cy);



	-- local f = function(a)
	--     return function() a = a + 1 return a end 
	-- end
	 
	-- local up = f(12)
	-- print(up);
	-- local n1 = up()
	-- local n2 = up()
	-- print(n1, n2)
	-- up = f(34)
	-- local n1 = up()
	-- local n2 = up()
	-- -- print(n1, n2)
	
	-- local str = "33456abcdefg";
	-- print(string.byte(str, 1, 8)); -- 51	51	52	53	54	97	98	99(ASCII码)
	-- print(string.byte(str, 3));    -- 52

	-- local t = {"a", "b", "ggr.", "g^de"};
	-- print(unpack(t));--a	b	ggr.	g^de

	-- dump(newBattle.getBattleTestNumber());
--[[
	local numTable = {};
	numTable[1] = 1;
	numTable[2] = 1;
	for i = 3, 140 do
		numTable[i] = numTable[i - 1] + numTable[i - 2];
		print(numTable[i]);
	end
	print("~~~斐波那锲", numTable[140]);
	print(2^50);
]]
end

-- function testFunction(a, b)
-- 	print("  第二个参数： ", b);
-- 	local functionb = function(c)
-- 		return testFunction(c, a);
-- 	end
-- 	return functionb;
-- end 闭包测试

function CCBLoginView:onEnter()
	local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)--设为false向下传递触摸
    listener:registerScriptHandler(function(touch, event) return self:onTouchBegan(touch, event) end, cc.Handler.EVENT_TOUCH_BEGAN )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self);

	if CC_SHOW_SERVER then 
		self:runAction(cc.Sequence:create(cc.DelayTime:create(0.6), cc.CallFunc:create(function()
			CCBServerView:create();
		end)));
	end
end

function CCBLoginView:onExit()

end

function CCBLoginView:onConnectSuccessed()
	--print("CCBLoginView:onConnectSuccessed");
	self.m_isConnect = true;

	self.m_ccbSpriteText:stopAllActions();
	self.m_ccbSpriteText:setVisible(true)
	local action1 = cc.FadeTo:create(1, 50)
	local action2 = cc.FadeTo:create(1, 255)
	local seq = cc.Sequence:create(action1, action2)
	local action = cc.RepeatForever:create(seq)
	self.m_ccbSpriteText:runAction(action)
end

function CCBLoginView:onTouchBegan(touch, event)
	if self.m_isConnect == true then
		self.m_ccbSpriteText:stopAllActions();
		self.m_ccbSpriteText:setVisible(false)	
		self.m_ccbLayerLoginPopup:setVisible(true)
	end
	return true;
end

function CCBLoginView:onBtnEnterGame()
	print("CCBLoginView:onBtnEnterGame")

	local accountText = self.editName:getText()
	local passwordText = self.editPassword:getText()

	local data = {
		account = accountText,
		password = passwordText,
	}
	App:getRunningScene():requestLogin(data);
end

function CCBLoginView:setDefaultInfo(account, password)
	if type(account) == "string" then
		self.editName:setText(account)
	end

	if type(password) == "string" then
		self.editPassword:setText(password)
	end
end

function CCBLoginView:init()	
	local size = self.accountLayer:getContentSize()
	local nameBox = cc.Scale9Sprite:create("res/resources/loginView/login_input.png")
	-- nameBox:initWithSpriteFrameName()
	nameBox:setContentSize(size)

	local passwordBox = cc.Scale9Sprite:create("res/resources/loginView/login_input.png")
	-- passwordBox:initWithSpriteFrameName()
	passwordBox:setContentSize(size)

	local editName = cc.EditBox:create(size, nameBox, nil, nil);
	editName:setPosition(size.width * 0.5, size.height * 0.5);
    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    if kTargetIphone == targetPlatform or kTargetIpad == targetPlatform then
		editName:setFontName("simhei")
	else
		editName:setFontName("fonts/simhei.ttf")
	end
    editName:setFontSize(28)
    editName:setPlaceholderFontSize(20)
    editName:setFontColor(cc.c3b(255,255,255))
    editName:setPlaceHolder("请输入账号")
    editName:setPlaceholderFontColor(cc.c3b(128,128,128))
    editName:setMaxLength(16)
    
	local function editBoxTextEventHandle(stringEventName, pSender)
		if stringEventName == "changed" then
			local nameIsEn = self:editNameIsEnglish(editName:getText());
   			if nameIsEn == false then
    			editName:setText("")
			end
		end
	end	
    editName:registerScriptEditBoxHandler(editBoxTextEventHandle)
    editName:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE )
    editName:setInputMode(cc.EDITBOX_INPUT_MODE_EMAILADDR)
    editName:setInputFlag(cc.EDITBOX_INPUT_FLAG_INITIAL_CAPS_WORD)

   
    local size = self.passwordLayer:getContentSize()
	local editPassword = cc.EditBox:create(size, passwordBox, nil, nil)
	editPassword:setPosition(size.width * 0.5, size.height * 0.5);
    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    if kTargetIphone == targetPlatform or kTargetIpad == targetPlatform then
		editPassword:setFontName("simhei")
	else
		editPassword:setFontName("fonts/simhei.ttf")
	end
    editPassword:setFontSize(28)
    editPassword:setPlaceholderFontSize(20)
    editPassword:setFontColor(cc.c3b(255,255,255))
    editPassword:setPlaceHolder("请输入密码")
    editPassword:setPlaceholderFontColor(cc.c3b(128,128,128))
    editPassword:setMaxLength(20)
    editPassword:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    editPassword:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    editPassword:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)


    self.accountLayer:addChild(editName)
    self.passwordLayer:addChild(editPassword)

    self.editName = editName
    self.editPassword = editPassword
end

function CCBLoginView:editNameIsEnglish(editName)
	local isNameEn = true;
	for i=1, #editName do
		local editNameAscII = string.byte(editName, i)
		if editNameAscII > 127 then
			isNameEn = false;
		else
			isNameEn = true;
		end
	end
	return isNameEn
end

-- 注释
	-- 主界面各个星域的背景音乐 1 - 5 

	-- 按钮点击音效 11
	-- 登陆页面的背景音乐 12
	-- 解锁战舰音效 13
	-- 战斗场景的背景音乐 31 - 34
	-- boss战斗场景的背景音乐 35

	-- battle背景音乐  101
	-- battle飞船喷射（需减弱）音效 102
	-- battle胜利音效 103
	-- battle失败音效 104
	-- 导弹道具发射 105
	-- 导弹道具爆炸 106
	-- 释放技能 107
	-- 炮台损毁音效 108
	-- 战舰损毁音效 109
	-- 能量体爆炸 110
	-- 能量体buff吸收音效 111
	-- NPC出场和离场 112
	-- NPC开火音效 113
	-- 使用道具（非导弹） 114
	-- 单体伤害 115
	-- 群体伤害 116

	-- 子弹音效 bullet_ 90001 - 90030 
	-- 技能音效 skill_ 50001 - 50030
	-- 飞船技能音效 ship_ 70001 - 70010

	-- 不确定音效，这边不加载了，要用再载。
function CCBLoginView:loadMusicFile()
	Audio:preloadEffect(11, "res/music/clickButton.mp3");
	Audio:preloadEffect(13, "res/music/unlockShip.mp3");
	-- Audio:preloadMusic(101, "res/music/battleSceneBg.mp3"); -- 战斗背景音乐
	Audio:preloadEffect(102, "res/music/battleShipFlyFire.mp3"); -- 喷射音效
	Audio:preloadEffect(103, "res/music/battleSuccess.mp3");
	Audio:preloadEffect(104, "res/music/battleFail.mp3");
	Audio:preloadEffect(105, "res/music/shellPropFire.mp3");
	Audio:preloadEffect(106, "res/music/shellPropBurst.mp3");
	Audio:preloadEffect(107, "res/music/skillFire.mp3");
	Audio:preloadEffect(108, "res/music/fortDestroy.mp3");
	Audio:preloadEffect(109, "res/music/shipDestroy.mp3");
	Audio:preloadEffect(110, "res/music/energyBurst.mp3");
	Audio:preloadEffect(111, "res/music/energyGain.mp3");
	Audio:preloadEffect(112, "res/music/NPC_move.mp3");
	Audio:preloadEffect(113, "res/music/NPC_fire.mp3");
	Audio:preloadEffect(114, "res/music/useProp.mp3");
	Audio:preloadEffect(115, "res/music/damageSingle.mp3");
	Audio:preloadEffect(116, "res/music/damageWhole.mp3");
end

return CCBLoginView