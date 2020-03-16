--local BlockLayer = require("app.views.common.BlockLayer")
-- local AnimationTool = require("app.utils.AnimationTool")
local ResourceMgr = require("app.utils.ResourceMgr");
local Tips = require("app.views.common.Tips");

--------------------
-- 战舰搜索动画弹窗
--------------------
local CCBSearchView = class("CCBSearchView", function ()
	return CCBLoader("ccbi/searchView/CCBSearchView.ccbi")
end)

function CCBSearchView:ctor()
	--BlockLayer:create():addTo(self.layer_root)
	if display.resolution  >= 2 then
		self.m_ccbNodeCenter:setScale(display.reduce);
	end
	self.m_listener = cc.EventListenerTouchOneByOne:create();
	self.m_listener:setSwallowTouches(true);
    self.m_listener:registerScriptHandler(function(touch, event) return true end, cc.Handler.EVENT_TOUCH_BEGAN);
    local eventDispatcher = self:getEventDispatcher();
    eventDispatcher:addEventListenerWithSceneGraphPriority(self.m_listener, self);
    
	self:createAnimation()
	--self.searchStarted = false
	--self.searchTime = -1
	-- self.tipsTexts = {
	-- 	"正在搜索战舰",
	-- 	"正在搜索战舰.",
	-- 	"正在搜索战舰..",
	-- 	"正在搜索战舰..."
	-- }

	self.updateTextTimer = 1
	self.updateTextStep = 1
end

function CCBSearchView:createAnimation()
	-- local animPath = "res/anims/mainAnim/anim_ui_seek/anim_ui_seek.ExportJson"
	-- ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(animPath)
	-- self.m_armature = ccs.Armature:create("anim_ui_seek");
	-- ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(animPath);
	-- self.node_anim:add(self.m_armature);

	-- self.m_armature:getAnimation():setMovementEventCallFunc(function(armatureBack, movementType, movementID) 
	-- 	self:animationEvent(armatureBack, movementType, movementID);
	-- end)
	local searchArmature = ResourceMgr:getEscortLootSearchArmature();
	self.m_ccbNodeAnim:addChild(searchArmature);
	searchArmature:getAnimation():play("anim01");
end

-- function CCBSearchView:animationEvent(armatureBack, movementType, movementID)
-- 	if movementType == ccs.MovementEventType.start then
		
-- 	elseif movementType == ccs.MovementEventType.complete then
-- 		if movementID == "start" then
-- 			self.m_armature:getAnimation():play("loop");
-- 			self.m_ccbBtnCancel:setVisible(true);
-- 		elseif movementID == "end" then
-- 			App:getRunningScene():getViewBase().m_ccbSearchView = nil;
-- 			self:removeSelf();
-- 		end
-- 	end
-- end

-- function CCBSearchView:update(delta)
-- 	if self.searchStarted and self.searchTime > 0 then
-- 		self:updateTipsText(delta)
-- 		self:startCountDown(delta)
-- 	end
-- end

-- function CCBSearchView:updateTipsText(delta)
-- 	self.updateTextTimer = self.updateTextTimer + delta
-- 	if self.updateTextTimer > 0.2 then
-- 		self.updateTextTimer = 0
-- 		self.updateTextStep = self.updateTextStep + 1

-- 		if self.updateTextStep > #self.tipsTexts then 
-- 			self.updateTextStep = 1 
-- 		end
-- 	end
-- end

-- function CCBSearchView:startCountDown(delta)
-- 	self.searchTime = self.searchTime - delta
-- 	if self.searchTime < 0 then
-- 		self:stopSearch()
-- 		self:onTimeOut()
-- 	end
-- end

-- function CCBSearchView:startSearch(searchTime)
-- 	-- self.searchStarted = true
-- 	-- self.searchTime = searchTime
-- 	-- self.label_text:setVisible(true)
-- 	self.m_armature:getAnimation():play("start")
-- end

function CCBSearchView:playCloseAnim()
	-- self.m_armature:getAnimation():play("end")
	-- self.m_ccbBtnCancel:setVisible(false);
	self:removeSelf();
end

-- function CCBSearchView:stopSearch()
-- 	self.searchStarted = false
-- 	self.searchTime = -1
-- 	-- self.label_text:setVisible(false)
-- 	-- self.anim:init(self.armature)
-- end

function CCBSearchView:onCancelTouched()
	Network:request("battle.matchHandler.cancel_wait", nil, function (rc, cancelData)
		-- dump(cancelData)
		if cancelData.code ~= 1 or cancelData.cancel ~= true then
			Tips:create(ServerCode[cancelData.code]);
			-- self:tips(GameData:get("code_map", cancelData.code)["desc"])
			-- return
		end
		
	end)
	self:playCloseAnim();
end

-- function CCBSearchView:onTimeOut()
-- 	print("time out")
-- end

-- function CCBSearchView:onCancel()
-- 	print("cancel")
-- end

return CCBSearchView