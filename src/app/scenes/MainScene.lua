local Tips = require("app.views.common.Tips");
-----------------------
-- 主场景
-----------------------
local MainScene = class("MainScene", require("app.scenes.GameSceneBase"))

function MainScene:init()
	self:initView("mainView.MainView")
end

function MainScene:notifyHasFloatingObj(data)
	self:getViewBase().m_ccbMainView:appearFloatingObj();
end

return MainScene