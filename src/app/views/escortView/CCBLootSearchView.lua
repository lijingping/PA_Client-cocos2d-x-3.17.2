local ResourceMgr = require("app.utils.ResourceMgr")
local Tips = require("app.views.common.Tips");

local CCBLootSearchView = class("CCBLootSearchView",function()
	return CCBLoader("ccbi/escortView/CCBLootSearchView")
end)

local bone = {};

function CCBLootSearchView:ctor()
	
	self:createSearchArmature()
	self:createCoverLayer();
end

--遮罩
function CCBLootSearchView:createCoverLayer()
	self.m_listener = cc.EventListenerTouchOneByOne:create();
	self.m_listener:setSwallowTouches(true);
    self.m_listener:registerScriptHandler(function(touch, event) return true end, cc.Handler.EVENT_TOUCH_BEGAN);
    local eventDispatcher = self:getEventDispatcher();
    eventDispatcher:addEventListenerWithSceneGraphPriority(self.m_listener,self);
end

--搜索动画
function CCBLootSearchView:createSearchArmature()
	-- local searchArmaturePath = "res/anims/escort/choose_robbery1/choose_robbery1.ExportJson";
	-- ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(searchArmaturePath);
	-- self.m_searchArmature = ccs.Armature:create("choose_robbery1");
	self.m_searchArmature = ResourceMgr:getSearchArmature();
	self.m_ccbNodeSearchArmature:addChild(self.m_searchArmature);
	self:rollMerchantShip();
	ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(searchArmaturePath);
	self.m_searchArmature:getAnimation():play("start");
	self.m_searchArmature:getAnimation():setMovementEventCallFunc(function (armatureBack,movementType,movementID)
		if movementType == ccs.MovementEventType.complete then
			if movementID == "start" then
				self.m_searchArmature:getAnimation():play("loop")
			end
			if movementID == "end" then
				
			end
		end
	end)
end

--绑定骨骼
function CCBLootSearchView:rollMerchantShip()
	for i = 1,5 do
		local bgSkin = ccs.Skin:create("res/resources/escortView/".. i ..".png");	--暂时使用的测试图片，需用美术资源替换
		self.m_searchArmature:getBone("card"..i):addDisplay(bgSkin, 0)
		self.m_searchArmature:getBone("card"..i):changeDisplayWithIndex(0, true);
	end
end

--测试按钮，用于播放抢劫的end
function CCBLootSearchView:onBtnTestPlayEnd()
	print("测试按钮，用于播放抢劫的end")
	self:searchSuccess(4);
end

--搜索成功，roll到对手(card3显示选中的等级)
function CCBLootSearchView:searchSuccess(level)
	self.m_searchArmature:getAnimation():play("end");
	local index = level; --匹配到的护卫舰等级（先暂时定值）
	for i = 3,5 do
		if index > 4 then
			local bgSkin = ccs.Skin:create("res/resources/escortView/".. index ..".png"); --暂时使用的测试图片，需用美术资源替换
			self.m_searchArmature:getBone("card"..i):addDisplay(bgSkin, 0)
			self.m_searchArmature:getBone("card"..i):changeDisplayWithIndex(0, true);
			index = 1;
		else
			local bgSkin = ccs.Skin:create("res/resources/escortView/".. index ..".png"); --暂时使用的测试图片，需用美术资源替换
			self.m_searchArmature:getBone("card"..i):addDisplay(bgSkin, 0)
			self.m_searchArmature:getBone("card"..i):changeDisplayWithIndex(0, true);
			index = index + 1;
		end	
	end

	for i = 1,2 do
		if index > 4 then
			local bgSkin = ccs.Skin:create("res/resources/escortView/".. index ..".png"); --暂时使用的测试图片，需用美术资源替换
			self.m_searchArmature:getBone("card"..i):addDisplay(bgSkin, 0)
			self.m_searchArmature:getBone("card"..i):changeDisplayWithIndex(0, true);
			index = 1;
		else
			local bgSkin = ccs.Skin:create("res/resources/escortView/".. index ..".png"); --暂时使用的测试图片，需用美术资源替换
			self.m_searchArmature:getBone("card"..i):addDisplay(bgSkin, 0)
			self.m_searchArmature:getBone("card"..i):changeDisplayWithIndex(0, true);
			index = index + 1;
		end	
	end
end

--关闭打劫搜索
function CCBLootSearchView:onBtnClose()
	print("关闭")
	Network:request("loot_battle.lootHandler.cancel_find_merchant_ship", nil, function (rc, data)
		dump(data)
		if data.code ~= 1 then
			Tips:create(ServerCode[data.code]);
			self:removeSelf();
			return;
		end		

		self:removeSelf();
	end)
end

return CCBLootSearchView;