local CCBWelcomeView = import(".CCBWelcomeView");

local WelcomeView = class("WelcomeView", require("app.views.GameViewBase"));

function WelcomeView:init()
	self.m_WelcomeView = CCBWelcomeView:create();
	self:addContent(self.m_WelcomeView);
end

return WelcomeView;
