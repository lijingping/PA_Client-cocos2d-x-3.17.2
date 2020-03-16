---------------
--  任务界面
---------------

local CCBTitlePanel = require("app.views.commonCCB.CCBTitlePanel")
local CCBTaskView = import(".CCBTaskView");

local TaskView = class("TaskView", require("app.views.GameViewBase"));

function TaskView:init()
	print("TaskView:init");
	self.m_ccbTitlePanel = CCBTitlePanel:create("taskView");
	self.m_ccbTitlePanel:setPosition(display.center);
	self:addChild(self.m_ccbTitlePanel, 2, 2);

	self.m_ccbTitlePanel.onBtnBack = function ()
		App:enterScene("MainScene");
	end

	self.m_taskView = CCBTaskView:create();
	self:addContent(self.m_taskView);
end

return TaskView;
