local FrameLayer = require("app.views.common.FrameLayer")

-- 用于显示版本号
local VersionLayer = class("VersionLayer", cc.Node)

function VersionLayer:ctor()
	local frameLayer = FrameLayer:create():addTo(self)
	local versionLabel = cc.LabelTTF:create("V"..APP_VERSION, "", 20)
	versionLabel:align(cc.p(1, 0), frameLayer.width - 10, 10)
	frameLayer:add(versionLabel)
end

return VersionLayer