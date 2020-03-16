local Tips = require("app.views.common.Tips");
--------------
-- 复仇列表场景(未完成)
--------------
local RevengeScene = class("RevengeScene", require("app.scenes.GameSceneBase"))

function RevengeScene:init()
	print("RevengeScene:init")
	self:initView("revengeView.RevengeView")
end

function RevengeScene:notifyIsAcceptRevenge(reveiveData)
	--dump(reveiveData)
	if reveiveData.code ~= 1 then
		return;
	end
	if reveiveData.accept == false then
		self:getViewBase().m_ccbRevengeView:setListInRequest(reveiveData.target_uid);
	end
end

return RevengeScene