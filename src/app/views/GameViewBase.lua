local CodeMap = require("app.constants.code_map")
local VersionLayer = require("app.views.common.VersionLayer")
local LoadingLayer = require("app.views.common.LoadingLayer")
local CCBSearchView = require("app.views.searchView.CCBSearchView")
local CCBDebugButton = require("app.views.debugView.CCBDebugButton")
--local CCBRevengeRequestPopup= require ("app.views.revengeView.CCBRevengeRequestPopup")

-----------------------
-- 界面基类，view继承此类
-----------------------
local GameViewBase = class("GameViewBase", cc.load("mvc").ViewBase)

function GameViewBase:onCreate()
    if self.init and type(self.init) == "function" then
        self:init()
    end

    local debugBtn = CCBDebugButton:create():setLocalZOrder(1000)
    self:addContent(debugBtn)
end

-- call every frame
function GameViewBase:baseUpdate(delta)
end

-- 添加版本号标签
-- function GameViewBase:addVersionLayer()
--     self:addContent(VersionLayer:create())
-- end

-- 弹出战舰搜索动画弹窗
function GameViewBase:popSearchView()
    -- if self.m_ccbSearchView == nil then
        self.m_ccbSearchView = CCBSearchView:create()
        self:addContent(self.m_ccbSearchView)
        -- self.m_ccbSearchView:startSearch(time)
    -- end
end

--弹出复仇请求
-- function GameViewBase:showRevengeRequestPopup(data)
--     --print("##########GameViewBase:showRevengeRequestPopup");
--     self.m_viewRevengeReques = CCBRevengeRequestPopup:create();
--     self:addContent(self.m_viewRevengeReques);
--     self.m_viewRevengeReques:setData(data);
-- end

return GameViewBase