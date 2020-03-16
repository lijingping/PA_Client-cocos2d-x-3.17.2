
local CCBMsgBox = class("CCBMsgBox", function ()
	return CCBLoader("ccbi/leagueActivity/CCBMsgBox.ccbi")
end)

function CCBMsgBox:ctor(params)
	--self.m_ccbLabelDesc:setString()
	self.m_params = params or {}
end

function CCBMsgBox:onBtnClose()
	self:removeSelf();
end

function CCBMsgBox:onBtnConfirm()
	self.m_params.callFun()

	self:onBtnClose()
end

return CCBMsgBox