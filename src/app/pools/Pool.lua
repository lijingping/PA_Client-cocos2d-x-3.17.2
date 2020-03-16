-------------------------
-- 定义缓存池
-------------------------
local Pool = class("Pool")

function Pool:ctor()
	self.objs = {}
end

function Pool:get()
	for k, v in pairs(self.objs) do
		if not v:isVisible() then 
			v:setVisible(true)
			return v 
		end
	end
end

function Pool:insert(obj)
	table.insert(self.objs, obj)
end

-- function Pool:recycle(obj)
-- 	obj:setVisible(false)
-- end

function Pool:clear()
	for k, v in pairs(self.objs) do
		v:removeSelf()
	end

	self = nil
end

return Pool