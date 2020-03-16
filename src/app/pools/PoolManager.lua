local Pool = require("app.pools.Pool")

---------------------------------------------------------
-- 缓存池管理器。用于缓存如子弹等频繁产生与销毁的对象，以优化性能
---------------------------------------------------------
local PoolManager = class("PoolManager")

function PoolManager:ctor(callback)
	self.callback = callback -- 用于创建对象，由使用者实现，需要返回对象
	self.pools = {}
end

function PoolManager:get(id)
	if id == nil then
		if not table.hasKey(self.pools, "temp") then 
			self.pools["temp"] = Pool:create()
		end
		local targetPool = self.pools["temp"]
		local targetObj = targetPool:get()
		if targetObj == nil then
			targetObj = self.callback()
			targetPool:insert(targetObj)
			return targetObj
		end

		return targetObj
	end

	if not table.hasKey(self.pools, id) then self.pools[id] = Pool:create() end

	local targetPool = self.pools[id]
	local targetObj = targetPool:get()

	if targetObj == nil then
		targetObj = self.callback(id)
		targetPool:insert(targetObj)
		return targetObj
	end

	return targetObj
end

function PoolManager:recycle(obj)
	-- local targetPool = self.pools[id]
	-- if targetPool == nil then print("PoolManager:recycle: 找不到对应id为"..id.."的池。") return end

	-- targetPool:recycle(obj)
	--其他设置在这里添加
	obj:setVisible(false)
end

function PoolManager:clear()
	for k, v in pairs(self.pools) do
		v:clear()
	end
end

return PoolManager