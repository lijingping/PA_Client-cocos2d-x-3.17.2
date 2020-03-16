--local AnimationTool = require("app.utils.AnimationTool")
local ResourceMgr = require("app.utils.ResourceMgr");

--------------------
-- Loading动画层
--------------------
local LoadingLayer = class("LoadingLayer", cc.Node)

function LoadingLayer:ctor()
    if not App:getRunningScene() then
        return;
    end

    self:setPosition(display.center);

    self:createCoverLayer();

    local width, height = display.getFullScreenSize()

    self.m_layerGray = cc.LayerColor:create(cc.c4b(0, 0, 0, 150), width, height);
    self.m_layerGray:setAnchorPoint(cc.p(0.5, 0.5));
    self.m_layerGray:setIgnoreAnchorPointForPosition(false);
    self:addChild(self.m_layerGray);
    
    self.m_armature = ResourceMgr:getCommonArmature("anim_loading");
    self:addChild(self.m_armature);

    self.m_armature:getAnimation():play("loading");
	--self.m_armature:setPosition(cc.p(width * 0.5, height * 0.5));

    local label = cc.LabelTTF:create("加载中...", "", 24);
    label:setPosition(cc.p(0, -100));
	self:addChild(label)

    App:getRunningScene():addChild(self, display.Z_LOADING, display.Z_LOADING);
end

function LoadingLayer:createCoverLayer()
    self.m_listener = cc.EventListenerTouchOneByOne:create();
    self.m_listener:setSwallowTouches(true);
    self.m_listener:registerScriptHandler(function(touch, event) return true end, cc.Handler.EVENT_TOUCH_BEGAN);
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self.m_listener, self);
end

function LoadingLayer:close()
    self:removeSelf();
end

return LoadingLayer