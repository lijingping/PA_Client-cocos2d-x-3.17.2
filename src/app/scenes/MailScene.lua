-- local Tips = require("app.views.common.Tips");

-----------------
-- 邮件场景
-----------------
local MailScene = class("MailScene", require("app.scenes.GameSceneBase"))

function MailScene:init()
	self:initView("mailView.MailView")
end

-- 设置小红点的操作，在当前页面的话
-- function MailScene:setHintByNewMailData(data)
-- 	self.m_mailView:setHintByNewMailData(data);
-- end

return MailScene