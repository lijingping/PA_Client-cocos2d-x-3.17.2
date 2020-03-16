
--------------------
-- 等待服务器消息返回
--------------------

local ResourceMgr = require("app.utils.ResourceMgr");


local WaitMsg = class("WaitMsg", cc.Node)

function WaitMsg:ctor()
    print("创建消息等待")
    if not App:getRunningScene() then
        return;
    end
    if App:getRunningScene():getChildByTag(display.Z_LOADING) then
        print(" 已经有加载提示页面了 ");
        return;
    end

    self:setPosition(display.center);

    self.m_listener = cc.EventListenerTouchOneByOne:create();
    self.m_listener:setSwallowTouches(true);
    self.m_listener:registerScriptHandler(function(touch, event) return true end, cc.Handler.EVENT_TOUCH_BEGAN);
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self.m_listener, self);    

    -- local width, height = display.getFullScreenSize()
    -- self.m_layerGray = cc.LayerColor:create(cc.c4b(0, 0, 0, 30), width, height);
    -- self.m_layerGray:setAnchorPoint(cc.p(0.5, 0.5));
    -- self.m_layerGray:ignoreAnchorPointForPosition(false);
    -- self:addChild(self.m_layerGray);
    
    self.m_armature = ResourceMgr:getCommonArmature("waitting_message");
    self:addChild(self.m_armature);

    self.m_armature:getAnimation():play("anim01");

    App:getRunningScene():addChild(self, display.Z_LOADING+1, display.Z_LOADING+1);
    if display.resolution >= 2 then
        self.m_armature:setScale(display.reduce);
    end
end

function WaitMsg:close()
    self:removeAllChildren();
    self:removeSelf();
end

return WaitMsg