local Tips = require("app.views.common.Tips");
local ResourceMgr = require("app.utils.ResourceMgr");

local CCBFortMainCell = class("CCBFortMainCell", function()
	return CCBLoader("ccbi/shipView/CCBFortMainCell.ccbi")
end)

local qualityIconPos = cc.p(-38, 38);
local equipIconPos = cc.p(12, 24);
local suitIconPos = cc.p(-15, -1);
-- -- 层级备注
-- 解锁/转换炮台标志
-- 已装备标志
-- 套装
-- 品质
-- 选中框

function CCBFortMainCell:ctor()
	self:init();

end

function CCBFortMainCell:init()

end

  -- ["90001"] = {
  --   id = 90001,
  --   fort_name = "零式刀锋",
  --   fort_type = 1,
  --   type_desc = "生命值低于50%伤害增加15%",
  --   fort_desc = "NO.1炮台",
  --   skill_id = 50001,
  --   star_const = 1,
  --   advance_item = 3001,
  --   skill_time = 0.5
  -- },

    -- 6 = {
    --      "exp"         = 0
    --      "id"          = 90010
    --      "level"       = 1
    --      "quality"     = 1
    --      "skill_id"    = 50010
    --      "skill_level" = 1
    --  }

function CCBFortMainCell:setData(data, shipData)
	-- dump(data);
	self:cleanNode();
	self.m_data = data;
	self.m_shipData = shipData;
	local fortID = self.m_data.id;
	local isFortUnlock = FortDataMgr:isUnlockFort(fortID);
	local quality = 0;
	if isFortUnlock then
		quality = FortDataMgr:getUnlockFortQuality(fortID);
	else
		quality = 1;
	end
	local fortIconBg = cc.Sprite:create(ResourceMgr:getItemBGByQuality(quality));
	local fortIcon = cc.Sprite:create(ResourceMgr:getItemIconByID(fortID));
	local fortIconFrame = cc.Sprite:create(ResourceMgr:getItemBoxFrameByQuality(quality));
	self.m_ccbNodeFortIcon:addChild(fortIconBg);
	self.m_ccbNodeFortIcon:addChild(fortIcon);
	self.m_ccbNodeFortIcon:addChild(fortIconFrame);

	self:setFortIsUnlock(isFortUnlock, fortID);
	self:setEquipSprite();
	self:setSuitSprite();
	self:setQualitySprite(quality);
	self:setSelectFrame();

	local fortName = FortDataMgr:getFortBaseName(fortID);
	self.m_ccbLabelFortName:setString(fortName);
end

function CCBFortMainCell:setFortIsUnlock(isUnlock, fortID)
	if isUnlock then
		self.m_ccbLabelFortLevel:setString("Lv." .. FortDataMgr:getUnlockFortLevel(fortID));
	else
		self.m_ccbLabelFortLevel:setString("");
		local fortAdvanceList = FortDataMgr:getAdvanceInfo();
		local materialNeed = fortAdvanceList[tostring(1)].consume_item;

		local currentHave = ItemDataMgr:getItemCount(self.m_data.advance_item);
		local lockSprite = nil;
		if currentHave >= materialNeed then
			lockSprite = cc.Sprite:create(ResourceMgr:getFortLockEnoughMaterial());
		else
			lockSprite = cc.Sprite:create(ResourceMgr:getFortLockNotEnough());
		end
		self.m_ccbNodeFortIcon:addChild(lockSprite);
	end
end

function CCBFortMainCell:setEquipSprite()
	local equipFortData = FortDataMgr:getEquipFortData();
	for k, v in pairs(equipFortData) do
		if self.m_data.id == v.fort_id then
			local equipSprite = cc.Sprite:create(ResourceMgr:getMarkEquipSprite());
			equipSprite:setPosition(equipIconPos);
			self.m_ccbNodeFortIcon:addChild(equipSprite);
			break;
		end
	end
end

function CCBFortMainCell:setSuitSprite()
	for i = 1, 3 do 
		local suitFort = "fort_id" .. i;
		if self.m_shipData[suitFort] == self.m_data.id then
			local suitSprite = cc.Sprite:create(ResourceMgr:getFortSuitLogo());
			suitSprite:setPosition(suitIconPos);
			self.m_ccbNodeFortIcon:addChild(suitSprite);
			break;
		end
	end
end

function CCBFortMainCell:setQualitySprite(quality)
	local qualitySprite = cc.Sprite:create(ResourceMgr:getFortQualitySpriteByQualityNumber(quality));
	qualitySprite:setPosition(qualityIconPos);
	self.m_ccbNodeFortIcon:addChild(qualitySprite);
end

function CCBFortMainCell:setSelectFrame()
	if FortDataMgr:getSelectedFort() == self.m_data.id then
		local selectSprite = cc.Sprite:create(ResourceMgr:getItemSelectFrame());
		self.m_ccbNodeFortIcon:addChild(selectSprite);
	end
end

function CCBFortMainCell:cleanNode()
	self.m_ccbNodeFortIcon:removeAllChildren();
	self.m_ccbNodeSelectFrame:removeAllChildren();
end

function CCBFortMainCell:getFortID()
	return self.m_data.id;
end

return CCBFortMainCell