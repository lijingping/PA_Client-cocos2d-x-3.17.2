local CCBMainView = require("app.views.mainView.CCBMainView")

---------------
-- 主界面
---------------
local MainView = class("MainView", require("app.views.GameViewBase"))

function MainView:init()
	self.m_ccbMainView = CCBMainView:create();
	self:addContent(self.m_ccbMainView);

	self.m_ccbMainView:updateView();
end

return MainView