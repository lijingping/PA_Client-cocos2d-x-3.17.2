local _GameData = require("app.data._GameData")


--------------
-- 缓存数据配表
--------------
local GameData = class("GameData")

local path = "app.constants."

function GameData:ctor()
	self.data = {}

	for k,v in pairs(_GameData) do
		self:cacheData(v.list, v.tag)
	end
end

function GameData:cacheData(list, tag)
	local dataList = table.clone(require(path..list))
	local newDataList = {}

	for k,v in pairs(dataList) do
		if tag == "key" then
			newDataList[k] = v
		else
			newDataList[v[tag]] = v
		end
	end

	self.data[list] = newDataList
end

function GameData:get(list, key)
	if key then
		if self.data[list][key] then
			return table.clone(self.data[list][key])
		end
	else
		if self.data[list] then
			return table.clone(self.data[list])
		end
	end
end

return GameData