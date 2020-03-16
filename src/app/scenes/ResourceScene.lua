local Tips = require("app.views.common.Tips");
------------
-- 资源库场景-新
------------
local ResourceScene = class("ResourceScene", require("app.scenes.GameSceneBase"))

function ResourceScene:init()
	-- print("###ResourceScene:init");
	self:initView("resView.ResourceView")
end

return ResourceScene