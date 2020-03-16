local ResourceMgr = require("app.utils.ResourceMgr");

local CCBEscortLootLog = class("CCBEscortLootLog", function()
	return CCBLoader("ccbi/escortView/CCBEscortLootLog");
end);

local scrollViewSize = cc.size(750, 420);
local lineHeight = 15;

local normalWhite = cc.c3b(255, 255, 255);
local successGreen = cc.c3b(0, 255, 0);
local failRed = cc.c3b(255, 0, 0);
local timeGray = cc.c3b(153, 153, 153);
local level_D_color = cc.c3b(214, 214, 214);
local level_C_color = cc.c3b(0, 255, 0);
local level_B_color = cc.c3b(0, 204, 255);
local level_A_color = cc.c3b(255, 0, 204);
local level_S_color = cc.c3b(255, 204, 0);
local coinYellow = cc.c3b(255, 255, 0);

function CCBEscortLootLog:ctor(data)
	if display.resolution >= 2 then
		self.m_ccbNodeCenter:setScale(display.reduce);
	end
	App:getRunningScene():addChild(self);
	self:createTouchListener();
	self.m_scrollHeightCount = 0;
	self.m_escortEventLogData = table.clone(require("app.constants.loot_event_description"));

	self:createScrollViewContainer();
	self:setLootLog(data);
end

function CCBEscortLootLog:createTouchListener()
	local listener = cc.EventListenerTouchOneByOne:create();
	listener:setSwallowTouches(true);
	listener:registerScriptHandler(function(touch, event) return self:onTouchBegan(touch, event); end, cc.Handler.EVENT_TOUCH_BEGAN);
	listener:registerScriptHandler(function(touch, event) self:onTouchEnded(touch, event); end, cc.Handler.EVENT_TOUCH_ENDED);
	local eventDispatcher = self:getEventDispatcher();
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.m_ccbLayerColor);
end

function CCBEscortLootLog:onTouchBegan(touch, event)
	print ("    began ~~~~~~~~~")
	return true;
end

function CCBEscortLootLog:onTouchEnded(touch, event)

end

function CCBEscortLootLog:createScrollViewContainer()
	self.m_nodeContainer = cc.Node:create();
	self.m_ccbScrollViewLootLog:setContainer(self.m_nodeContainer);
	self.m_nodeContainer:setContentSize(cc.size(scrollViewSize.width, 0));
	self.m_nodeLootLog = cc.Node:create();
	self.m_nodeContainer:addChild(self.m_nodeLootLog);
	self.m_nodeLootLog:setPosition(cc.p(0, 0));
end

function CCBEscortLootLog:setLootLog(data)
	-- dump(data);
  -- 4 = {
  --          "enemy_fort1" = 90010
  --          "enemy_fort2" = 90020
  --          "enemy_fort3" = 90014
  --          "enemy_name"  = "布朗伊芙"
  --          "enemy_ship"  = 70008
  --          "level"       = 5
  --          "money"       = 30
  --          "second_type" = 1
  --          "time"        = "18:04"
  --          "type"        = 3
  --      }
 	if #data == 0 then
 		local tipLabel = cc.LabelTTF:create();
 		tipLabel:setFontSize(25);
 		tipLabel:setString(Str[12018]);
 		self.m_ccbNodeCenter:addChild(tipLabel);
 		return;
 	end
	for i = 1, #data do 

		self.m_scrollHeightCount = self.m_scrollHeightCount - 20;
		local escortLogStr = self:getEscortLogStr(data[i]);
		local labelSize = self:getLabelSize(escortLogStr);
		local richTextWidth = scrollViewSize.width;
		local richTextHeight = math.ceil(labelSize.width / scrollViewSize.width) * labelSize.height;
		local richSize = cc.size(richTextWidth, richTextHeight);
		local richText = self:createRichTextEscortLog(data[i], richSize);
		self.m_nodeLootLog:addChild(richText);
		richText:setPosition(cc.p(scrollViewSize.width * 0.5, self.m_scrollHeightCount));


		-- local strTable = string.split(data[i], "|");
		-- local strLabel = "";
		-- for j = 1, #strTable do 
		-- 	strLabel = strLabel .. strTable[j];
		-- 	if j < #strTable then
		-- 		strLabel = strLabel .. "  ";
		-- 	end
		-- end

		self.m_scrollHeightCount = self.m_scrollHeightCount - richSize.height;
		self.m_scrollHeightCount = self.m_scrollHeightCount - 20;
		local lineSprite = cc.Sprite:create(ResourceMgr:getLootLogLine());
		self.m_nodeLootLog:addChild(lineSprite);
		local spriteSize = lineSprite:getContentSize();
		lineSprite:setPosition(cc.p(scrollViewSize.width * 0.5, self.m_scrollHeightCount - spriteSize.height * 0.5));
		self.m_scrollHeightCount = self.m_scrollHeightCount - spriteSize.height;
	end
	self.m_nodeContainer:setContentSize(cc.size(scrollViewSize.width, -self.m_scrollHeightCount));
	self.m_nodeLootLog:setPosition(cc.p(0, -self.m_scrollHeightCount));
	local offsetNum = scrollViewSize.height + self.m_scrollHeightCount;
	self.m_ccbScrollViewLootLog:setContentOffset(cc.p(0, offsetNum));
end

function CCBEscortLootLog:getEscortLogStr(data)
	-- {
    --     time: string;   //xx:xx
    --     type: number;   //事件类型 1随机事件|2护送方遭遇打劫|3打劫日志
    --     second_type: number;    //描述的数组第几个,从1开始(如果type=2|3,则secondtype 1也代表胜利|2输)
    --     money: number;  //获取|失去星际币数量
    --     enemy_name: string | undefined;
    --     level: number | undefined;
    --     enemy_ship: number | undefined;
    --     enemy_fort1: number | undefined;
    --     enemy_fort2: number | undefined;
    --     enemy_fort3: number | undefined;
    -- }

    -- type 1:money.    2:time, enemy_name, lootResult(用second_type判), money  
    -- 3:打劫日志（这里不需要）time, enemy_name, level, money || lootResult
		-- 测试
-- 	dump(self.m_escortEventLogData["2"].desc_list);
-- 	"<var>" = {
--     1 = "遭到|的打劫,|获得星际币"
--     2 = "遭到|的打劫,|失去星际币"
-- }

      --  "打劫了 | 护送的 |贩售舰,战斗胜利获得星际币",
      -- "打劫了|护送的|贩售舰,|空手而回."

	local descLog = self.m_escortEventLogData[tostring(data.type)].desc_list[data.second_type];
	-- print(" 护送日志  字符串", descLog);
	local descLogTable = string.split(descLog, "|");
	-- dump(descLogTable);
	local str = "";
	if data.type == 3 then
		str = data.time .. "  " .. descLogTable[1] .. " " .. data.enemy_name .. " " .. descLogTable[2] .. " ";
		local levelStr = self:getShipLevelStrByLevel(data.level);
		str = str .. levelStr .. descLogTable[3] .. " ";
		if data.second_type == 1 then
			str = str .. "+" .. data.money;
		elseif data.second_type == 2 then
			str = str .. Str[12020] .. descLogTable[4];
		end
	else
		print("  这里是打劫日志。  没有护送日志！！！！  ")
	end
	return str;
end

function CCBEscortLootLog:getLabelSize(str)
	local logLabel = cc.LabelTTF:create();
	logLabel:setFontSize(18);
	logLabel:setDimensions(cc.size(0, 0));
	logLabel:setString(str);
	-- logLabel:setAnchorPoint(cc.p(0.5, 0));
	-- logLabel:setPosition(cc.p(scrollViewSize.width * 0.5, self.m_escortLogCountY));
	-- self.m_nodeAddLabel:addChild(logLabel);
	local labelSize = logLabel:getContentSize();
	return labelSize;
end

function CCBEscortLootLog:createRichTextEscortLog(data, size)
	local richText = ccui.RichText:create();
	richText:ignoreContentAdaptWithSize(false);
	richText:setSize(size);
	richText:setAnchorPoint(cc.p(0.5, 1));

	local descLog = self.m_escortEventLogData[tostring(data.type)].desc_list[data.second_type];
	local descLogTable = string.split(descLog, "|");
	if data.type == 3 then
		local timeText = ccui.RichElementText:create(1, timeGray, 255, data.time, "", 18);
		richText:pushBackElement(timeText);
		local str1 = "  " .. descLogTable[1] .. " " .. data.enemy_name .. " " .. descLogTable[2] .. " ";
		local enemyNameText = ccui.RichElementText:create(2, normalWhite, 255, str1, "", 18);
		richText:pushBackElement(enemyNameText);
		local levelStr = self:getShipLevelStrByLevel(data.level);
		local levelText = nil;
		if data.level == 1 then
			levelText = ccui.RichElementText:create(3, level_D_color, 255, levelStr, "", 18);
		elseif data.level == 2 then
			levelText = ccui.RichElementText:create(3, level_C_color, 255, levelStr, "", 18);
		elseif data.level == 3 then
			levelText = ccui.RichElementText:create(3, level_B_color, 255, levelStr, "", 18);
		elseif data.level == 4 then
			levelText = ccui.RichElementText:create(3, level_A_color, 255, levelStr, "", 18);
		elseif data.level == 5 then
			levelText = ccui.RichElementText:create(3, level_S_color, 255, levelStr, "", 18);
		end
		richText:pushBackElement(levelText);
		local shipDescText = ccui.RichElementText:create(4, normalWhite, 255, descLogTable[3] .. " ", "", 18);
		richText:pushBackElement(shipDescText);
		if data.second_type == 1 then
			local moneyStr = Str[10002] .. "*" .. data.money;
			local moneyText = ccui.RichElementText:create(5, coinYellow, 255, moneyStr, "", 18);
			richText:pushBackElement(moneyText);
		elseif data.second_type == 2 then
			local battleResultText = ccui.RichElementText:create(5, failRed, 255, Str[12020], "", 18);
			richText:pushBackElement(battleResultText);
			local finalText = ccui.RichElementText:create(6, normalWhite, 255, descLogTable[4], "", 18);
			richText:pushBackElement(finalText);
		end
	else
		print("   这里是打劫日志。 没有护送日志！！！！ ")
	end

	return richText;
end

function CCBEscortLootLog:getShipLevelStrByLevel(level)
	local levelStr = "";
	if level == 1 then
		levelStr = "D";
	elseif level == 2 then
		levelStr = "C";
	elseif level == 3 then
		levelStr = "B";
	elseif level == 4 then
		levelStr = "A";
	elseif level == 5 then
		levelStr = "S";
	end
	return levelStr .. Str[12021];
end

function CCBEscortLootLog:onBtnClose()
	self:removeSelf();
end

return CCBEscortLootLog;