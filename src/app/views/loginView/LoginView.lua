local CCBLoginView = require("app.views.loginView.CCBLoginView")


---------------
-- 登录界面
---------------
local LoginView = class("LoginView", require("app.views.GameViewBase"))

function LoginView:init()
	-- print("$$$$$$$$$$$$$$$$$", self)
	self.m_ccbLoginView = CCBLoginView:create()
	self:addContent(self.m_ccbLoginView)
	--self:addVersionLayer()
end

function LoginView:setDefaultInfo(data)
	local account = data.account
	local password = data.password
	self.m_ccbLoginView:setDefaultInfo(account, password)
end

-- function LoginView:onConnectSuccessed()
-- 	self.m_loginView:onConnectSuccessed()
-- end

return LoginView