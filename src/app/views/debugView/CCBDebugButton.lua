local debugView = require("app.views.debugView.debugView")

local CCBDebugButton = class("CCBDebugButton", function ()
	return CCBLoader("ccbi/debugView/CCBDebugButton.ccbi")
end)

function CCBDebugButton:ctor()

end

function CCBDebugButton:onCheatTouched()
	local debugView = debugView:create()
	self:add(debugView)
end

return CCBDebugButton