local Tips = require("app.views.common.Tips");

----------------------
-- 生产场景
----------------------
local ProduceScene2 = class("ProduceScene2", require("app.scenes.GameSceneBase"))

function ProduceScene2:init()
	self:initView("produceView.ProduceView2")
end

return ProduceScene2