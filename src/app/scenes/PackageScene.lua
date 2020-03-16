------------
-- 资源库场景-新
------------
local PackageScene = class("PackageScene", require("app.scenes.GameSceneBase"))

function PackageScene:init()
	self:initView("packageView.PackageView")
end

return PackageScene