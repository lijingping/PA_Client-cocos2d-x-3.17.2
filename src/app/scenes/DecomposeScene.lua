-- 分解场景
-----------------------
local DecomposeScene = class("DecomposeScene", require("app.scenes.GameSceneBase"))

function DecomposeScene:init()
	self:initView("decomposeView.DecomposeView")
end

return DecomposeScene