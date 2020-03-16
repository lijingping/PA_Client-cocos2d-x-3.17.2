local ResourceMgr = require("app.utils.ResourceMgr");
local CCBBuffCell = class("CCBBuffCell", function()
	return CCBLoader("ccbi/mainView/CCBBuffCell.ccbi")
end)

function CCBBuffCell:ctor()

end

function CCBBuffCell:setData(data)
	self.m_ccbNodeIcon:removeAllChildren();
	local node = ResourceMgr:createItemIcon(data.iconID);
	node:setScale(0.8);
	self.m_ccbNodeIcon:addChild(node);
	self.m_ccbLabelBuffTime:setString(self:setStrTimeFormat(data.time));
	self.m_ccbLabelBuffDesc:setString(data.str);
end

function CCBBuffCell:setStrTimeFormat(time)
	local hour = math.floor(time / 3600);
	local minute = math.floor((time % 3600) / 60);
	local second = time % 60;
	return string.format("%02d:%02d:%02d", hour, minute, second);
end


return CCBBuffCell;