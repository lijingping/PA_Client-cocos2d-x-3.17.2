local FrameLayer = require("app.views.common.FrameLayer")
local ResourceMgr = require("app.utils.ResourceMgr");
local Tips = require("app.views.common.Tips");

-------------------
-- 漂浮物层
-------------------
local FloatingObjLayer = class("FloatingObjLayer", cc.Node)

local moveSpeed = 150
local scaleSpeed = 0.025
local lifeTime = 30
-- local silverWing = "ccbResources/float_obj_silverWing.plist"
-- local silverWingFileNameRoot = "ccbResources/float_obj_silverWing/scene02_matter"
-- local silverWingFileCount = 6

function FloatingObjLayer:ctor(domainNum) -- 传入参数：星域 ：根据星域修改floatPicPath路径。
	--domainNum = 1;       ----------- 目前只有一种漂浮物，所以，这边命名  1   (scene1_floater)

	local frameLayer = FrameLayer:create()
	self:add(frameLayer)
	self.frameLayer = frameLayer
	self.m_frameSize = self.frameLayer:getContentSize();

	local listener = cc.EventListenerTouchOneByOne:create();
	listener:setSwallowTouches(false);
	listener:registerScriptHandler(function(touch, event) return self:onTouchBegan(touch, event) end, cc.Handler.EVENT_TOUCH_BEGAN);
	listener:registerScriptHandler(function(touch, event) self:onTouchMoved(touch, event) end, cc.Handler.EVENT_TOUCH_MOVED);
	listener:registerScriptHandler(function(touch, event) self:onTouchEnded(touch, event) end, cc.Handler.EVENT_TOUCH_ENDED);
	local eventDispatcher = self:getEventDispatcher();
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self);

	self.m_spriteNode = cc.Node:create();
	self.frameLayer:addChild(self.m_spriteNode);

	local randomImage = math.random(1, 6);
	randomImage = math.random(1, 6);
	if randomImage < 10 then
		randomImage = domainNum .. "0" .. randomImage;
	end
	self.m_floatingSprite = cc.Sprite:create(ResourceMgr:getFloatingByIndex(randomImage));

	self.m_spriteNode:addChild(self.m_floatingSprite);

	local spriteSize = self.m_floatingSprite:getContentSize();
	self.m_floatingSprite:setPosition(spriteSize.width / 2, spriteSize.height / 2);
	self.m_spriteNode:setContentSize(spriteSize);

	local armature = ResourceMgr:getAnimArmatureByNameOnMain("anim_hint01");
	armature:getAnimation():play("anim01");
	-- armature:setPosition(ccp(sprite:getContentSize().width * 0.5, sprite:getContentSize().height * 0.5));
	armature:setScale(2.5)
	armature:setPosition(spriteSize.width / 2, spriteSize.height / 2);
	self.m_spriteNode:addChild(armature);

	local startPos = self:getStartPos();
	self.m_spriteNode:setPosition(startPos);
	local startScale = self:getStartScale();
	self.m_spriteNode:setScale(startScale);

	local endPos = self:getEndPos(startPos);
	local endScale = self:getEndScale();
	local moveTime = self:getMoveTime();
	local moveToAction = cc.MoveTo:create(moveTime, endPos);
	local scaleToAction = cc.ScaleTo:create(moveTime, endScale);
	local spawnAction = cc.Spawn:create(moveToAction, scaleToAction);
	local callFunc = CCCallFunc:create(function () 
		self:getParent():getParent():setFreeFloating();
		self:removeSelf();
	end);
	local seq = cc.Sequence:create(spawnAction, callFunc);
	self.m_spriteNode:runAction(seq);
end

function FloatingObjLayer:onTouchBegan(touch, event)
	-- print("............onTouchBegan ....")
	-- dump(self.m_spriteNode:getBoundingBox());
	return true;
end

function FloatingObjLayer:onTouchMoved(touch, event)

end

function FloatingObjLayer:onTouchEnded(touch, event)
	local touchEndPos = touch:getLocation();
	if cc.rectContainsPoint(self.m_spriteNode:getBoundingBox(), touchEndPos) then
		self:requestCollectFloater();
		self:getParent():getParent():setFreeFloating();
		self:removeSelf();
	end
end

function FloatingObjLayer:requestCollectFloater()
	Network:request("game.activityHandler.search_floating_obj", nil, function (rc, data)
		print("点击漂浮物")
		if data["code"] ~= 1 then
			Tips:create(GameData:get("code_map", data.code)["desc"])
			return
		end

		-- if data.item_id == 10001 then
		-- 	Tips:create(string.format("获得%d星际币！", data.count));
		-- 	return;
		-- end

		-- local itemData = ItemDataMgr:getItemBaseInfo(data["item_id"])
		-- if itemData == nil then print("表里没有这个物品id") return end

		-- local count = data.count
		-- Tips:create(string.format("获得%d个%s！", count, itemData.name))
	end)
end

-- 获取起始坐标
function FloatingObjLayer:getStartPos()
	local sideRandom = math.random(1, 2);
	if sideRandom == 1 then   -- 左边
		return cc.p(-200, math.random(0, self.m_frameSize.height));
	else                      -- 右边
		return cc.p(self.m_frameSize.width + 200, math.random(0, self.m_frameSize.height));
	end
end

-- 获取起始倍数
function FloatingObjLayer:getStartScale()
	return math.random(30, 50) / 100;
end

-- 获取终点坐标
function FloatingObjLayer:getEndPos(startPos)
	if startPos.x < 0 then
		if startPos.y < self.m_frameSize.height / 2 then
			return cc.p(self.m_frameSize.width + 200, math.random(self.m_frameSize.height / 2, self.m_frameSize.height));
		else
			return cc.p(self.m_frameSize.width + 200, math.random(0, self.m_frameSize.height / 2));
		end
	else
		if startPos.y < self.m_frameSize.height / 2 then
			return cc.p(-200, math.random(self.m_frameSize.height / 2, self.m_frameSize.height));
		else
			return cc.p(-200, math.random(0, self.m_frameSize.height / 2));
		end
	end
end

-- 获取终点倍数
function FloatingObjLayer:getEndScale()
	return math.random(65, 85) / 100;
end

-- 获取随机事件
function FloatingObjLayer:getMoveTime()
	return math.random(12, 20);
end

return FloatingObjLayer