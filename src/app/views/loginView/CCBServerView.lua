local NetworkConst = require("app.constants.NetworkConst");
local Tips = require("app.views.common.Tips");

local CCBServerView = class("CCBServerView", function ()
	return CCBLoader("ccbi/loginView/CCBServerView.ccbi")
end)

function CCBServerView:ctor()
    if not App:getRunningScene() then
        return;
    end

	self.m_data = {
		{title="测试服1",host=NetworkConst.TEST1_GATE_HOST,port=NetworkConst.TEST1_GATE_PORT},
		{title="测试服2",host=NetworkConst.TEST2_GATE_HOST,port=NetworkConst.TEST2_GATE_PORT}
	};

	for i=1, #self.m_data do
		if Network.GATE_HOST == self.m_data[i].host then
			self.m_ccbLabel:setString(self.m_data[i].title.." "..Network.GATE_HOST..":"..Network.GATE_PORT);
		end
	end

    App:getRunningScene():addChild(self, display.Z_LOADING+100, display.Z_LOADING+100);
end

function CCBServerView:onBtnServer(index)
	local data = self.m_data[index];
	if Network.GATE_HOST == data.host then
		return
	end

	local loadingLayer = App:getRunningScene():getChildByTag(display.Z_LOADING);
	if loadingLayer then
		loadingLayer:removeSelf();
	end
	local waitMsg = App:getRunningScene():getChildByTag(display.Z_LOADING+1);
	if waitMsg then
		waitMsg:removeSelf();
	end

	Network.GATE_HOST = data.host;
	Network.GATE_PORT = data.port;
	self.m_ccbLabel:setString(data.title.." "..data.host..":"..data.port);

	App:getRunningScene():getViewBase().m_ccbLoginView.m_ccbLayerLoginPopup:setVisible(false);
	App:getRunningScene():reconnect();
end

function CCBServerView:onBtnServer1()
	self:onBtnServer(1);
end

function CCBServerView:onBtnServer2()
	self:onBtnServer(2);
end

return CCBServerView