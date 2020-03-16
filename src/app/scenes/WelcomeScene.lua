--[[
	热更新界面
--]]
local WelcomeScene = class("WelcomeScene", require("app.scenes.GameSceneBase"));

function WelcomeScene:init()
	self:initView("welcomeView.WelcomeView");
end

return WelcomeScene;
