local CCBFortLevel = require("app.views.shipView.CCBFortLevel")
local CCBFortQuality = require("app.views.shipView.CCBFortQuality")
local CCBFortSkill = require("app.views.shipView.CCBFortSkill")
--local BlockLayer = require("app.views.common.BlockLayer")
local ResourceMgr = require("app.utils.ResourceMgr");

------------------
-- 炮台列表窗口
------------------

local CCBFortView = class("CCBFortView", function ()
	return CCBLoader("ccbi/shipView/CCBFortView.ccbi")
end)

function CCBFortView:ctor()
	self:init()
end

function CCBFortView:init()
--	local blockLayer = BlockLayer:create():addTo(self.layer_block)

	if display.resolution >= 2 then
		self.m_ccbNodeCenter:setScale(display.reduce);
	end
	
	self.m_listener = cc.EventListenerTouchOneByOne:create();
	self.m_listener:setSwallowTouches(true);
    self.m_listener:registerScriptHandler(function(touch, event) return true end, cc.Handler.EVENT_TOUCH_BEGAN);
    local eventDispatcher = self:getEventDispatcher();
    eventDispatcher:addEventListenerWithSceneGraphPriority(self.m_listener, self);

	self.ccbLevel = CCBFortLevel:create()
	self.ccbQuality = CCBFortQuality:create()
	self.ccbSkill = CCBFortSkill:create()

	self.m_ccbNodePropertyInfo:add(self.ccbLevel)
	self.m_ccbNodePropertyInfo:add(self.ccbQuality)
	self.m_ccbNodePropertyInfo:add(self.ccbSkill)

	self.ccbLevel:setVisible(false)
	self.ccbQuality:setVisible(false)
	self.ccbSkill:setVisible(false)

	self:selectButton(2)

	self.m_ccbBtnQualityUp:setTitleBMFontForState(ResourceMgr:getFont(), cc.CONTROL_STATE_NORMAL);
	self.m_ccbBtnQualityUp:setTitleBMFontForState(ResourceMgr:getFont(), cc.CONTROL_STATE_DISABLED);

	self.m_ccbBtnLevelUp:setTitleBMFontForState(ResourceMgr:getFont(), cc.CONTROL_STATE_NORMAL);
	self.m_ccbBtnLevelUp:setTitleBMFontForState(ResourceMgr:getFont(), cc.CONTROL_STATE_DISABLED);

	self.m_ccbBtnSkillUp:setTitleBMFontForState(ResourceMgr:getFont(), cc.CONTROL_STATE_NORMAL);
	self.m_ccbBtnSkillUp:setTitleBMFontForState(ResourceMgr:getFont(), cc.CONTROL_STATE_DISABLED);

	self.m_ccbBtnQualityUp:setTitleColorForState(cc.c3b(204, 204, 204), cc.CONTROL_STATE_NORMAL);
	self.m_ccbBtnLevelUp:setTitleColorForState(cc.c3b(204, 204, 204), cc.CONTROL_STATE_NORMAL);
	self.m_ccbBtnSkillUp:setTitleColorForState(cc.c3b(204, 204, 204), cc.CONTROL_STATE_NORMAL);

	local listener = cc.EventListenerTouchOneByOne:create();
	listener:setSwallowTouches(true);
	listener:registerScriptHandler(function (touch, event) return true end, cc.Handler.EVENT_TOUCH_BEGAN);
	local eventDispatcher = self:getEventDispatcher();
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self);
end

-- function CCBFortView:createTabBar()
-- 	local titles = {"品质进阶", "等级提升", "技能升级"}
-- 	local res = {
-- 		plist = "ccbResources/common.plist",
-- 		bg_n = "ccbResources/common/btn_blue_n.png",
-- 		bg_h = "ccbResources/common/btn_blue_n.png",
-- 		bg_d = "ccbResources/common/btn_green_h.png",
-- 		resType = ccui.TextureResType.plistType,
-- 	}

-- 	local callback = function (index)
-- 		self:selectButton(index)
-- 	end

-- 	local direction = TabBar.HORIZONTAL
-- 	local fontConfig = {
-- 		fontSize = 28,
-- 		fontColor_h = cc.c3b(255, 255, 255),
-- 		fontColor_n = cc.c3b(255, 255, 255),
-- 	}

-- 	local padding = 30

-- 	return TabBar:create(titles, res, callback, direction, fontConfig, padding)
-- end

function CCBFortView:selectButton(index)
	self.m_ccbBtnQualityUp:setEnabled(true)
	self.m_ccbBtnLevelUp:setEnabled(true)
	self.m_ccbBtnSkillUp:setEnabled(true)

	self.ccbLevel:setVisible(false)
	self.ccbQuality:setVisible(false)
	self.ccbSkill:setVisible(false)

	if index == 1 then
		self.ccbQuality:setVisible(true)
		self.m_ccbBtnQualityUp:setEnabled(false)
	end

	if index == 2 then
		self.ccbLevel:setVisible(true)	
		self.m_ccbBtnLevelUp:setEnabled(false)
	end

	if index == 3 then
		self.ccbSkill:setVisible(true)		
		self.m_ccbBtnSkillUp:setEnabled(false)
	end
end

function CCBFortView:setData(data, shipData, isLevel)
	-- print("CCBFortView:setData: level : ",isLevel);
	-- dump(data)
	-- "<var>" = {
	--     "advance_item" = 3001
	--     "fort_desc"    = "NO.1炮台"
	--     "fort_name"    = "零式刀锋"
	--     "fort_type"    = 1
	--     "id"           = 90001
	--     "skill_id"     = 50001
	--     "star_const"   = 1
	-- }
	self.m_data = data;
	local fortID = data.id --table.clone(data)

	self:cleanData();

	local level = FortDataMgr:getUnlockFortLevel(fortID) or "nil"
	local quality = FortDataMgr:getUnlockFortQuality(fortID) or "nil"
	local fortType = FortDataMgr:getFortBaseType(fortID) or "nil"
	local hp = math.ceil(FortDataMgr:healthPoint(fortID, level)) or "nil"
	local atk = math.ceil(FortDataMgr:attack(fortID, level)) or "nil"
	local defence = math.ceil(FortDataMgr:defence(fortID, level)) or 0;
	-- local atk_high = fortData.attack_high or "nil"
	local speed = FortDataMgr:getAtkSpeedFactor(fortID,level) or "nil"
	-- local fortid = fortData["$fort_id"]
	local name = data.frot_name or ""

	-- local skillid = fortData.skill_id or nil
	local skillid = data.skill_id
	local skilldata = FortDataMgr:getSkillInfoBySkillID(skillid)
	local skillname = skilldata.name
	local skillLevel = FortDataMgr:getUnlockFortSkillLevel(fortID) or 1

	self:setFortIcon(fortID, quality);
	self:setIconLevel(level);
	self:setFortQualityIcon(quality);
	self:setFortSuitIcon(shipData, fortID);

	-- if quality == 1 then
	-- 	self.label_quality:setString("D")
	-- elseif quality == 2 then
	-- 	self.label_quality:setString("C")
	-- elseif quality == 3 then
	-- 	self.label_quality:setString("B")
	-- elseif quality == 4 then
	-- 	self.label_quality:setString("A")
	-- elseif quality == 5 then
	-- 	self.label_quality:setString("S")
	-- end

	-- local fortTypeIcon = cc.Sprite:create(ResourceMgr:getFortTypeIcon(fortType));
	-- self.m_ccbNodeTypeIcon:addChild(fortTypeIcon);

	if fortType == 1 then
		self.label_type:setString(Str[7124]);
	elseif fortType == 2 then
		self.label_type:setString(Str[7125]);
	elseif fortType == 3 then
		self.label_type:setString(Str[7126]);
	end
	

	self.m_ccbLabelHp:setString(hp)
	self.m_ccbLabelAtk:setString(atk)
	self.m_ccbLabelDefence:setString(defence);

	-- self.label_speed:setString(speed.."s")

	-- self.label_skill:setString(skillname.." Lv"..skillLevel)
	self.label_name:setString(name)

	local fortInfo = FortDataMgr:getFortBaseInfo(fortID);
	self.m_ccbLabelTalentDesc:setString(fortInfo.type_desc);

	local typeMarkCount = 0;
	local tagTotalSize = 0;

	for k, v in pairs(skilldata.skill_type) do 
		local typeSprite = cc.Sprite:create(ResourceMgr:getFortTalentTag(v));
		self.m_ccbNodeSkillType:addChild(typeSprite);
		local tagSize = typeSprite:getContentSize();
		typeSprite:setPositionX(tagTotalSize + tagSize.width * 0.5 + typeMarkCount * 10);
		tagTotalSize = tagTotalSize + tagSize.width;
		typeMarkCount = typeMarkCount + 1;
	end


	self.ccbQuality:setData(data);
	self.ccbSkill:setData(data);
	self.ccbLevel:setData(data, isLevel);
end

-- 设置图标
function CCBFortView:setFortIcon(fortID, quality)
	local iconBgSprite = cc.Sprite:create(ResourceMgr:getItemBGByQuality(quality));
	self.m_ccbNodeFortViewIcon:addChild(iconBgSprite);
	local iconSprite = cc.Sprite:create(ResourceMgr:getFortIconByID(fortID));
	self.m_ccbNodeFortViewIcon:addChild(iconSprite);
	local iconBoxSprite = cc.Sprite:create(ResourceMgr:getItemBoxFrameByQuality(quality));
	self.m_ccbNodeFortViewIcon:addChild(iconBoxSprite);
end

-- 设置图标里边的等级
function CCBFortView:setIconLevel(level)
	self.m_ccbLabelFortLevel:setString("Lv " .. level);
end

function CCBFortView:setFortQualityIcon(quality)
	-- print("ccbFortView:setFORTqualityicon   ", quality)
	local qualitySprite = cc.Sprite:create(ResourceMgr:getFortQualitySpriteByQualityNumber(quality));
	self.m_ccbNodeQualityIcon:addChild(qualitySprite);
end

function CCBFortView:setFortSuitIcon(shipData, fortID)
	for i = 1, 3 do 
 		local suitFort = "fort_id" .. i;
 		if shipData[suitFort] == fortID then
 			local fortIconSuit = cc.Sprite:create(ResourceMgr:getFortSuitLogo());
 			self.m_ccbNodeQualityIcon:addChild(fortIconSuit);
 			fortIconSuit:setPosition(cc.p(-15 - self.m_ccbNodeQualityIcon:getPositionX(), -1 - self.m_ccbNodeQualityIcon:getPositionY()));
 			break;
		end
 	end
end

function CCBFortView:setFortSkillDesc(desc)
	local skillid = self.m_data.skill_id
	local skilldata = FortDataMgr:getSkillInfoBySkillID(skillid)
	local skillname = skilldata.name
	local skillLevel = FortDataMgr:getUnlockFortSkillLevel(self.m_data.id) or 1
	self.m_ccbLabelSkillName:setString(skillname .. "（Lv." .. skillLevel .. "）");
	self.m_ccbLabelSkillDesc:setString(desc);
end

-- 清楚数据
function CCBFortView:cleanData()
	self.m_ccbNodeFortViewIcon:removeAllChildren();
	self.m_ccbLabelFortLevel:setString("");
	self.m_ccbNodeQualityIcon:removeAllChildren();
	self.m_ccbNodeSkillType:removeAllChildren();
end

function CCBFortView:onBtnQualityUp()
	self:selectButton(1)

end

function CCBFortView:onBtnSkillUp()
	self:selectButton(3)
end

function CCBFortView:onBtnLevelUp()
	self:selectButton(2)
end

function CCBFortView:onSkillClicked()
	-- body
end

function CCBFortView:onCloseClicked()
	self:removeSelf();
end

return CCBFortView