local Tips = require("app.views.common.Tips");
local firstName = require("app.constants.firstname");
local secondName = require("app.constants.secondname");
local ResourceMgr = require("app.utils.ResourceMgr");


local CCBChangeName = class("CCBChangeName", function()
	return CCBLoader("ccbi/mainView/CCBChangeName.ccbi");
end)

local g_isForbidden = false; --是否存在非法字符
local g_surnameTable = {}
local g_nameTable = {}
local g_forbiddenCharacter = {"`", "~", "!", "@", "#", "%$", "%%","%^", "&", "%*", "%(", "%)",
	"_", "%+", "{", "}", "|", ":", "<", ">", "%?", "%[", "%]", ";", ",", "%.", "/", "\'", "\"",
	"\"", "：", "；", "“",  "”",  "‘", "’", "，", "。", "、", "【", "】", "%-", "=", "？", "！", " ",
	"……", "~","￥", "%%", "…", "&", "%*", "（", "）", "——", "+", "{", "}", "、", "《", "》", " " }		--非法字符

function CCBChangeName:ctor()
	if display.resolution >= 2 then
        self.m_ccbNodeCenter:setScale(display.reduce);
    end
	self:coverLayer();
	-- self:setNameLiatData();
	self:setName();
	self:chooseName();
end

--屏蔽层
function CCBChangeName:coverLayer()
	local listener = cc.EventListenerTouchOneByOne:create();
	listener:setSwallowTouches(true);
    listener:registerScriptHandler(function(touch, event) return true end, cc.Handler.EVENT_TOUCH_BEGAN);
    local eventDispatcher = self:getEventDispatcher();
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self);
end

--输入名字
function CCBChangeName:setName()

	local boxSize = self.m_ccbLayerNameEdit:getContentSize();
	self.m_editBox = cc.EditBox:create(boxSize, ResourceMgr:getAlpha0Sprite());
	self.m_editBox:setAnchorPoint(cc.p(0, 0));
	self.m_editBox:setFontSize(25);
	self.m_editBox:setFontColor(cc.c3b(255, 255, 255));
	self.m_editBox:setPlaceholderFontSize(25);
	self.m_editBox:setPlaceholderFontColor(cc.c3b(255, 255, 255));
	self.m_editBox:setText("");
	self.m_editBox:setMaxLength(14);

	local strFmt;
	--editBox输入事件
	local function editBoxTextEventHandle(stringEventName, pSender)

			
		if stringEventName == "changed" then
			
			strFmt = self.m_editBox:getText();
			-- print("changed ",strFmt)
			local editBoxLen, chNum, enNum = self:getStringLenth(strFmt);
			-- print(editBoxLen, chNum, enNum)
			if chNum > 7 then
				self.m_editBox:setText("");
			end
			if editBoxLen >= 14 then
				self.m_editBox:setMaxLength(chNum + enNum);
			else
				self.m_editBox:setMaxLength(14)
			end

		elseif stringEventName == "ended" then
			strFmt = self.m_editBox:getText()
			self:checkForbiddenCharacter(strFmt)
			
		elseif stringEventName == "return" then
			strFmt = self.m_editBox:getText()
			-- print("return ",strFmt)
			self:checkForbiddenCharacter(strFmt)
		end
	end	
	self.m_editBox:registerScriptEditBoxHandler(editBoxTextEventHandle)
	self.m_editBox:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE);
	self.m_editBox:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE);
	self.m_ccbLayerNameEdit:addChild(self.m_editBox);
end


--随机抽名字按钮
function CCBChangeName:onBtnRandomName()
	self:chooseName();
end
--确定按钮
function CCBChangeName:onBtnEnSure()

	local sendStr = self.m_editBox:getText();
	-- print(sendStr)
	-- print(PlaceHolderStr)
	-- print("g_isForbidden",g_isForbidden)

	if sendStr == "" then 					--名字是空字符
		Tips:create(Str[5005]);
	elseif g_isForbidden == false then 		--不存在非法字符
		self:sendNameData(sendStr);		
	elseif g_isForbidden == true then 		--存在非法字符
		Tips:create(Str[5009]);
	end	
end

--随机名字
function CCBChangeName:randomNameIndex()
	local firstIndex;
	local secondIndex;
	--math.randomseed(os.time());
	firstIndex = math.random(1,981);
	firstIndex = math.random(1,981);
	secondIndex = math.random(1,417);
	secondIndex = math.random(1,417);
	
	return firstIndex, secondIndex;
end

--选择名字
function CCBChangeName:chooseName()
	local firstIndex, secondIndex = self:randomNameIndex();
	-- print(firstIndex);
	-- print(secondIndex);
	local firstName = firstName[tostring(firstIndex)].first;
	local lastName = secondName[tostring(secondIndex)].second;
	local playerName = firstName..lastName;
	-- dump(playerName)
	
	local playerNameLenth, chNum, enNum = self:getStringLenth(playerName);
	if playerNameLenth <= 14 then
		self.m_editBox:setText(playerName);
	else
		self:chooseName();
	end
	self:checkForbiddenCharacter()
end

--长度计算
function CCBChangeName:getStringLenth(string)
	local len = string.len(string)
	local i = 1;
	local chCount = 0;
	local enCount = 0;
	while i <= len do
		if self:calcCharacterLength_UTF8(string.byte(string, i)) == 3 then
			chCount = chCount+1;
		elseif self:calcCharacterLength_UTF8(string.byte(string, i)) == 1 then
			enCount = enCount+1;
		end
		i = i+self:calcCharacterLength_UTF8(string.byte(string,i));
		-- i = i+1;
	end
	
	local stringLenth = chCount*2 + enCount*2;
	-- print(stringLenth);
	return stringLenth, chCount, enCount;
end

function CCBChangeName:calcCharacterLength_UTF8(ch)
	if ch >= 240 and ch <= 247 then
		return 4;
	elseif ch >= 224 and ch <= 239 then --中文
		return 3;
	elseif ch >= 192 and ch <= 223 then
		return 2;
	else --英文字符
		return 1;
	end
end

--检查是否有非法字符
function CCBChangeName:checkForbiddenCharacter()
	local sendStr = self.m_editBox:getText();
	g_isForbidden = false;
	for i = 1, #g_forbiddenCharacter do
		local forbidden = g_forbiddenCharacter[i]
		-- print(sendStr);
		-- print(forbidden);
		local checkCharacter = string.find(sendStr, forbidden)
		-- print(checkCharacter)
		if checkCharacter ~= nil then
			g_isForbidden = true;
		end
	end
end
--发送名字到服务器
function CCBChangeName:sendNameData(name)
	-- print(name)
	Network:request("game.userHandler.change_nickname", {nickname = name}, function (rc, data)
		if data["code"] ~= 1 then
			-- print(GameData:get("code_map", data.code)["desc"]);
			Tips:create(GameData:get("code_map", data.code)["desc"]);
			return
		end

		local CCBMainView = self:getParent();
		self:changeNameToNameBar(name);
		CCBMainView:showBottom();
		CCBMainView.m_ccbNodeTopHide:setVisible(true);
		CCBMainView.m_ccbNodeTop:setVisible(true);
		CCBMainView.m_ccbBtnOpenShipView:setVisible(true);
		CCBMainView.m_ccbBtnOpenProduceView:setVisible(true);
		self:removeSelf();	
	end)	
end

function CCBChangeName:changeNameToNameBar(name)
		UserDataMgr:setPlayerName(name)
		local CCBMainView = self:getParent();
		-- dump(CCBMainView)
		CCBMainView.m_ccbLabelName:setString(name);
end

return CCBChangeName